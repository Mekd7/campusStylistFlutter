package com.example.campusstylist.backend.application.controller

import com.example.campusstylist.backend.domain.model.Post
import com.example.campusstylist.backend.domain.service.PostService
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
import org.slf4j.LoggerFactory
import java.sql.SQLException

fun Route.postRoutes(postService: PostService, userService: UserService) {
    val logger = LoggerFactory.getLogger("PostRoutes")

    authenticate("auth-jwt") {
        post("/posts") {
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

                val multipartData = call.receiveMultipart()
                var description: String? = null
                var pictureUrl: String? = null

                multipartData.forEachPart { part ->
                    when (part) {
                        is PartData.FormItem -> {
                            when (part.name) {
                                "description" -> description = part.value
                            }
                        }
                        is PartData.FileItem -> {
                            pictureUrl = handleFileUpload(part)
                        }
                        else -> part.dispose()
                    }
                }

                if (description.isNullOrBlank() || pictureUrl.isNullOrBlank()) {
                    logger.warn("Invalid input: description=$description, pictureUrl=$pictureUrl")
                    return@post call.respond(
                        HttpStatusCode.BadRequest,
                        mapOf("error" to "Invalid input", "message" to "Picture and description are required")
                    )
                }

                val post = Post(
                    id = null,
                    userId = user.id!!,
                    pictureUrl = pictureUrl!!,
                    description = description!!
                )

                logger.debug("Creating post for userId=${user.id}: $post")
                val createdPost = postService.create(post)
                call.respond(HttpStatusCode.Created, createdPost)
            } catch (e: SerializationException) {
                logger.error("Serialization error: ${e.message}", e)
                call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid JSON", "message" to e.message))
            } catch (e: SQLException) {
                logger.error("Database error: ${e.message}", e)
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
            } catch (e: Exception) {
                logger.error("Server error: ${e.message}", e)
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }

        get("/posts") {
            try {
                val posts = postService.getAll()
                call.respond(posts)
            } catch (e: SQLException) {
                logger.error("Database error: ${e.message}", e)
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
            } catch (e: Exception) {
                logger.error("Server error: ${e.message}", e)
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }

        get("/posts/{id}") {
            try {
                val id = call.parameters["id"]?.toLongOrNull()
                    ?: return@get call.respond(
                        HttpStatusCode.BadRequest,
                        mapOf("error" to "Invalid input", "message" to "Invalid post ID")
                    )
                val post = postService.getById(id)
                if (post != null) {
                    call.respond(post)
                } else {
                    call.respond(HttpStatusCode.NotFound, mapOf("error" to "Not found", "message" to "Post not found"))
                }
            } catch (e: SQLException) {
                logger.error("Database error: ${e.message}", e)
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
            } catch (e: Exception) {
                logger.error("Server error: ${e.message}", e)
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }

        put("/posts/{id}") {
            try {
                val id = call.parameters["id"]?.toLongOrNull()
                    ?: return@put call.respond(
                        HttpStatusCode.BadRequest,
                        mapOf("error" to "Invalid input", "message" to "Invalid post ID")
                    )
                val principal = call.principal<JWTPrincipal>()
                val email = principal?.payload?.getClaim("email")?.asString()
                    ?: return@put call.respond(
                        HttpStatusCode.Unauthorized,
                        mapOf("error" to "Unauthorized", "message" to "Invalid token")
                    )
                val user = userService.findByEmail(email)
                    ?: return@put call.respond(
                        HttpStatusCode.Unauthorized,
                        mapOf("error" to "Unauthorized", "message" to "User not found")
                    )
                val existingPost = postService.getById(id)
                    ?: return@put call.respond(
                        HttpStatusCode.NotFound,
                        mapOf("error" to "Not found", "message" to "Post not found")
                    )
                if (existingPost.userId != user.id) {
                    return@put call.respond(
                        HttpStatusCode.Forbidden,
                        mapOf("error" to "Forbidden", "message" to "You can only edit your own posts")
                    )
                }

                val multipartData = call.receiveMultipart()
                var description: String? = null
                var pictureUrl: String? = null

                multipartData.forEachPart { part ->
                    when (part) {
                        is PartData.FormItem -> {
                            when (part.name) {
                                "description" -> description = part.value
                            }
                        }
                        is PartData.FileItem -> {
                            pictureUrl = handleFileUpload(part)
                        }
                        else -> part.dispose()
                    }
                }

                if (description.isNullOrBlank() || pictureUrl.isNullOrBlank()) {
                    logger.warn("Invalid input: description=$description, pictureUrl=$pictureUrl")
                    return@put call.respond(
                        HttpStatusCode.BadRequest,
                        mapOf("error" to "Invalid input", "message" to "Picture and description are required")
                    )
                }

                val updatedPost = existingPost.copy(
                    description = description!!,
                    pictureUrl = pictureUrl!!
                )
                logger.debug("Updating post id=$id: $updatedPost")
                val updated = postService.update(updatedPost)
                if (updated) {
                    call.respond(HttpStatusCode.OK, mapOf("message" to "Post updated"))
                } else {
                    call.respond(HttpStatusCode.NotFound, mapOf("error" to "Not found", "message" to "Post not found"))
                }
            } catch (e: SerializationException) {
                logger.error("Serialization error: ${e.message}", e)
                call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid JSON", "message" to e.message))
            } catch (e: SQLException) {
                logger.error("Database error: ${e.message}", e)
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
            } catch (e: Exception) {
                logger.error("Server error: ${e.message}", e)
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }

        delete("/posts/{id}") {
            try {
                val id = call.parameters["id"]?.toLongOrNull()
                    ?: return@delete call.respond(
                        HttpStatusCode.BadRequest,
                        mapOf("error" to "Invalid input", "message" to "Invalid post ID")
                    )
                val principal = call.principal<JWTPrincipal>()
                val email = principal?.payload?.getClaim("email")?.asString()
                    ?: return@delete call.respond(
                        HttpStatusCode.Unauthorized,
                        mapOf("error" to "Unauthorized", "message" to "Invalid token")
                    )
                val user = userService.findByEmail(email)
                    ?: return@delete call.respond(
                        HttpStatusCode.Unauthorized,
                        mapOf("error" to "Unauthorized", "message" to "User not found")
                    )
                val post = postService.getById(id)
                    ?: return@delete call.respond(
                        HttpStatusCode.NotFound,
                        mapOf("error" to "Not found", "message" to "Post not found")
                    )
                if (post.userId != user.id) {
                    return@delete call.respond(
                        HttpStatusCode.Forbidden,
                        mapOf("error" to "Forbidden", "message" to "You can only delete your own posts")
                    )
                }
                logger.debug("Deleting post id=$id")
                val success = postService.delete(id)
                if (success) {
                    call.respond(HttpStatusCode.NoContent)
                } else {
                    call.respond(HttpStatusCode.NotFound, mapOf("error" to "Not found", "message" to "Post not found"))
                }
            } catch (e: SQLException) {
                logger.error("Database error: ${e.message}", e)
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
            } catch (e: Exception) {
                logger.error("Server error: ${e.message}", e)
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }
    }
}