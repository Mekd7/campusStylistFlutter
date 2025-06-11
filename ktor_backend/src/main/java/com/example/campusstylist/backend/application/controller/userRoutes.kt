package com.example.campusstylist.backend.application.controller

import com.example.campusstylist.backend.domain.model.Role
import com.example.campusstylist.backend.domain.model.User
import com.example.campusstylist.backend.infrastructure.security.JwtConfig
import com.example.campusstylist.backend.domain.service.UserService
import io.ktor.http.*
import io.ktor.http.content.*
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.serialization.SerializationException
import java.sql.SQLException
import java.util.concurrent.ConcurrentHashMap
import com.auth0.jwt.JWT

val tokenBlacklist = ConcurrentHashMap<String, Long>()

fun Route.userRoutes(userService: UserService) {
    authenticate("auth-jwt") {
        // Create profile (both roles, post-signup)
        post("/profile") {
            try {
                val principal = call.principal<JWTPrincipal>()
                val email = principal?.payload?.getClaim("email")?.asString()
                    ?: return@post call.respond(
                        HttpStatusCode.Unauthorized,
                        mapOf("error" to "Unauthorized", "message" to "Invalid token")
                    )
                val user = userService.findByEmail(email)
                    ?: return@post call.respond(
                        HttpStatusCode.Unauthorized,
                        mapOf("error" to "Unauthorized", "message" to "User not found")
                    )

                if (user.hasCreatedProfile) {
                    return@post call.respond(
                        HttpStatusCode.BadRequest,
                        mapOf("error" to "Profile already exists", "message" to "Profile already created")
                    )
                }

                val multipartData = call.receiveMultipart()
                var username: String? = null
                var bio: String? = null
                var profilePictureUrl: String? = null

                multipartData.forEachPart { part ->
                    when (part) {
                        is PartData.FormItem -> {
                            when (part.name) {
                                "username" -> username = part.value
                                "bio" -> bio = part.value
                            }
                        }
                        is PartData.FileItem -> {
                            profilePictureUrl = handleFileUpload(part)
                        }
                        else -> part.dispose()
                    }
                }

                if (username.isNullOrBlank() || bio.isNullOrBlank()) {
                    return@post call.respond(
                        HttpStatusCode.BadRequest,
                        mapOf("error" to "Invalid input", "message" to "Username and bio are required")
                    )
                }

                val success = userService.createProfile(user.id!!, username!!, bio!!, profilePictureUrl)
                if (success) {
                    call.respond(HttpStatusCode.Created, mapOf("message" to "Profile created successfully"))
                } else {
                    call.respond(HttpStatusCode.NotFound, mapOf("error" to "Not found", "message" to "User not found"))
                }
            } catch (e: SerializationException) {
                call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid JSON", "message" to e.message))
            } catch (e: SQLException) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
            } catch (e: Exception) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }

        // Get profile (both roles)
        get("/profile/{id}") {
            try {
                val principal = call.principal<JWTPrincipal>()
                val email = principal?.payload?.getClaim("email")?.asString()
                    ?: return@get call.respond(
                        HttpStatusCode.Unauthorized,
                        mapOf("error" to "Unauthorized", "message" to "Invalid token")
                    )
                val id = call.parameters["id"]?.toLongOrNull()
                    ?: return@get call.respond(
                        HttpStatusCode.BadRequest,
                        mapOf("error" to "Invalid input", "message" to "Invalid user ID")
                    )
                val user = userService.findByEmail(email)
                    ?: return@get call.respond(
                        HttpStatusCode.Unauthorized,
                        mapOf("error" to "Unauthorized", "message" to "User not found")
                    )
                if (user.id != id) {
                    return@get call.respond(
                        HttpStatusCode.Forbidden,
                        mapOf("error" to "Forbidden", "message" to "You can only access your own profile")
                    )
                }
                call.respond(user)
            } catch (e: SQLException) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
            } catch (e: Exception) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }

        // Update profile (both roles)
        put("/profile/{id}") {
            try {
                val principal = call.principal<JWTPrincipal>()
                val email = principal?.payload?.getClaim("email")?.asString()
                    ?: return@put call.respond(
                        HttpStatusCode.Unauthorized,
                        mapOf("error" to "Unauthorized", "message" to "Invalid token")
                    )
                val id = call.parameters["id"]?.toLongOrNull()
                    ?: return@put call.respond(
                        HttpStatusCode.BadRequest,
                        mapOf("error" to "Invalid input", "message" to "Invalid user ID")
                    )
                val user = userService.findByEmail(email)
                    ?: return@put call.respond(
                        HttpStatusCode.Unauthorized,
                        mapOf("error" to "Unauthorized", "message" to "User not found")
                    )
                if (user.id != id) {
                    return@put call.respond(
                        HttpStatusCode.Forbidden,
                        mapOf("error" to "Forbidden", "message" to "You can only update your own profile")
                    )
                }

                val multipartData = call.receiveMultipart()
                var username: String? = null
                var bio: String? = null
                var profilePictureUrl: String? = null

                multipartData.forEachPart { part ->
                    when (part) {
                        is PartData.FormItem -> {
                            when (part.name) {
                                "username" -> username = part.value
                                "bio" -> bio = part.value
                            }
                        }
                        is PartData.FileItem -> {
                            profilePictureUrl = handleFileUpload(part)
                        }
                        else -> part.dispose()
                    }
                }

                // Use existing values if not provided
                val updatedUser = user.copy(
                    username = if (!username.isNullOrBlank()) username else user.username,
                    bio = if (!bio.isNullOrBlank()) bio else user.bio,
                    profilePicture = profilePictureUrl ?: user.profilePicture
                )

                val updated = userService.update(updatedUser)
                if (updated) {
                    call.respond(HttpStatusCode.OK, mapOf("message" to "Profile updated successfully"))
                } else {
                    call.respond(HttpStatusCode.NotFound, mapOf("error" to "Not found", "message" to "User not found"))
                }
            } catch (e: SerializationException) {
                call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid JSON", "message" to e.message))
            } catch (e: SQLException) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
            } catch (e: Exception) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }

        // Delete account (both roles)
        delete("/profile/{id}") {
            try {
                val principal = call.principal<JWTPrincipal>()
                val email = principal?.payload?.getClaim("email")?.asString()
                    ?: return@delete call.respond(
                        HttpStatusCode.Unauthorized,
                        mapOf("error" to "Unauthorized", "message" to "Invalid token")
                    )
                val id = call.parameters["id"]?.toLongOrNull()
                    ?: return@delete call.respond(
                        HttpStatusCode.BadRequest,
                        mapOf("error" to "Invalid input", "message" to "Invalid user ID")
                    )
                val user = userService.findByEmail(email)
                    ?: return@delete call.respond(
                        HttpStatusCode.Unauthorized,
                        mapOf("error" to "Unauthorized", "message" to "User not found")
                    )
                if (user.id != id) {
                    return@delete call.respond(
                        HttpStatusCode.Forbidden,
                        mapOf("error" to "Forbidden", "message" to "You can only delete your own profile")
                    )
                }
                val success = userService.delete(id)
                if (success) {
                    call.respond(HttpStatusCode.NoContent)
                } else {
                    call.respond(HttpStatusCode.NotFound, mapOf("error" to "Not found", "message" to "User not found"))
                }
            } catch (e: SQLException) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
            } catch (e: Exception) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }
    }

    // Logout (both roles, authentication optional)
    post("/logout") {
        try {
            val token = call.request.header("Authorization")?.removePrefix("Bearer ") ?: run {
                call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Missing token"))
                return@post
            }

            // Verify token first (optional but recommended)
            try {
                val decodedJWT = JwtConfig.verifyToken(token)
                if (decodedJWT != null) {
                    val expiry = JWT.decode(token).expiresAt?.time ?: System.currentTimeMillis()
                    JwtConfig.blacklistToken(JWT.decode(token).id, expiry)
                }
            } catch (e: Exception) {
                // Token is invalid anyway, but we'll still process logout
            }

            call.respond(HttpStatusCode.OK, mapOf("message" to "Logged out successfully"))
        } catch (e: Exception) {
            call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
        }
    }
}