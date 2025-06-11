package com.example.campusstylist.backend.application.controller

import com.example.campusstylist.backend.data.AuthRequest
import com.example.campusstylist.backend.data.LoginRequest
import com.example.campusstylist.backend.data.AuthResponse
import com.example.campusstylist.backend.domain.service.UserService
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.serialization.SerializationException
import org.slf4j.LoggerFactory

fun Route.authRoutes(userService: UserService) {
    val logger = LoggerFactory.getLogger("AuthRoutes")

    route("/auth") {
        post("/register") {
            try {
                val request = call.receive<AuthRequest>()
                logger.debug("Received register request: $request")

                if (request.role.uppercase() !in listOf("CLIENT", "HAIRDRESSER")) {
                    logger.warn("Invalid role: ${request.role}")
                    call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid role", "message" to "Role must be CLIENT or HAIRDRESSER"))
                    return@post
                }
                if (request.email.isBlank() || request.password.isBlank()) {
                    logger.warn("Empty email or password: email=${request.email}")
                    call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid input", "message" to "Email and password are required"))
                    return@post
                }
                val response = userService.signup(request.email, request.password, request.role.uppercase())
                call.respond(HttpStatusCode.Created, response)
            } catch (e: SerializationException) {
                logger.error("Serialization error: ${e.message}", e)
                call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid JSON", "message" to e.message))
            } catch (e: IllegalArgumentException) {
                logger.warn("Signup failed: ${e.message}")
                call.respond(HttpStatusCode.Conflict, mapOf("error" to "Conflict", "message" to (e.message ?: "Email already exists")))
            } catch (e: Exception) {
                logger.error("Unexpected error: ${e.message}", e)
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }

        post("/login") {
            try {
                val request = call.receive<LoginRequest>()
                logger.debug("Received login request: email=${request.email}")

                if (request.email.isBlank() || request.password.isBlank()) {
                    logger.warn("Empty email or password: email=${request.email}")
                    call.respond(
                        HttpStatusCode.BadRequest,
                        mapOf("error" to "Invalid input", "message" to "Email and password are required")
                    )
                    return@post
                }

                val response = userService.signin(request.email, request.password)
                if (response != null) {
                    call.respond(HttpStatusCode.OK, response)
                } else {
                    logger.warn("Invalid credentials for email: ${request.email}")
                    call.respond(
                        HttpStatusCode.Unauthorized,
                        mapOf("error" to "Unauthorized", "message" to "Invalid credentials")
                    )
                }
            } catch (e: SerializationException) {
                logger.error("Serialization error: ${e.message}", e)
                call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid JSON", "message" to e.message))
            } catch (e: Exception) {
                logger.error("Unexpected error: ${e.message}", e)
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }

        get("/user/me") {
            try {
                val token = call.request.header("Authorization")?.removePrefix("Bearer ") ?: run {
                    call.respond(HttpStatusCode.Unauthorized, mapOf("error" to "Missing token"))
                    return@get
                }

                val email = userService.getUserIdFromToken(token) ?: run {
                    call.respond(HttpStatusCode.Unauthorized, mapOf("error" to "Invalid token"))
                    return@get
                }

                val user = userService.findByEmail(email) ?: run {
                    call.respond(HttpStatusCode.NotFound, mapOf("error" to "User not found"))
                    return@get
                }

                val response = AuthResponse(
                    token = token,  // Assuming you want to return the token as part of the response as well
                    role = user.role.name,
                    userId = user.id.toString(),
                    hasCreatedProfile = user.hasCreatedProfile
                )

                call.respond(HttpStatusCode.OK, response)
            } catch (e: Exception) {
                logger.error("Error fetching user profile: ${e.message}", e)
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }

    }
}