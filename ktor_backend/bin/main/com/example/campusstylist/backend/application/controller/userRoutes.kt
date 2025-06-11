package com.example.campusstylist.backend.application.controller



import com.example.campusstylist.backend.domain.service.UserService
import io.ktor.http.HttpStatusCode // Add this import
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

data class AuthRequest(
    val username: String,
    val password: String,
    val role: String = ""
)

fun Route.userRoutes(userService: UserService) {
    route("/auth") {
        post("/register") {
            val request = call.receive<AuthRequest>()
            val response = try {
                userService.signup(request.username, request.password, request.role)
            } catch (e: IllegalArgumentException) {
                call.respond(HttpStatusCode.BadRequest, e.message ?: "Invalid request")
                return@post
            }
            call.respond(response)
        }

        post("/login") {
            val request = call.receive<AuthRequest>()
            val response = userService.signin(request.username, request.password)
            if (response != null) {
                call.respond(response)
            } else {
                call.respond(HttpStatusCode.Unauthorized, "Invalid credentials")
            }
        }
    }
}