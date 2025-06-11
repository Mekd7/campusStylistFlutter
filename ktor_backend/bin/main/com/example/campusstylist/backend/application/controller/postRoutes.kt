package com.example.campusstylist.backend.application.controller

import com.example.campusstylist.backend.domain.model.Post
import com.example.campusstylist.backend.domain.service.PostService
import com.example.campusstylist.backend.domain.service.UserService
import com.example.campusstylist.backend.infrastructure.table.Users.username
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Route.postRoutes(postService: PostService, userService: UserService) {
    authenticate("auth-jwt") {
        post("/posts") {
            val post = call.receive<Post>()
            val principal = call.principal<JWTPrincipal>()
            val email = principal?.payload?.getClaim("email")?.asString() ?: return@post call.respond(HttpStatusCode.Unauthorized)
            val user = userService.findByUsername(username = String()) ?: return@post call.respond(HttpStatusCode.Unauthorized)
            if (post.userId != user.id) {
                return@post call.respond(HttpStatusCode.Forbidden, "You can only create posts for yourself")
            }
            val createdPost = postService.create(post)
            call.respond(HttpStatusCode.Created, createdPost)
        }

        get("/posts") {
            val posts = postService.getAll()
            call.respond(posts)
        }

        get("/posts/{id}") {
            val id = call.parameters["id"]?.toLongOrNull() ?: return@get call.respond(HttpStatusCode.BadRequest)
            val post = postService.getById(id)
            if (post != null) {
                call.respond(post)
            } else {
                call.respond(HttpStatusCode.NotFound)
            }
        }

        put("/posts/{id}") {
            val id = call.parameters["id"]?.toLongOrNull() ?: return@put call.respond(HttpStatusCode.BadRequest)
            val principal = call.principal<JWTPrincipal>()
            val email = principal?.payload?.getClaim("email")?.asString() ?: return@put call.respond(HttpStatusCode.Unauthorized)
            val user = userService.findByUsername(username = String())  ?: return@put call.respond(HttpStatusCode.Unauthorized)
            val post = postService.getById(id) ?: return@put call.respond(HttpStatusCode.NotFound)
            if (post.userId != user.id) {
                return@put call.respond(HttpStatusCode.Forbidden, "You can only edit your own posts")
            }
            val updatedPost = call.receive<Post>()
            val updated = postService.update(updatedPost.copy(id = id))
            if (updated) {
                call.respond(HttpStatusCode.OK)
            } else {
                call.respond(HttpStatusCode.NotFound)
            }
        }

        delete("/posts/{id}") {
            val id = call.parameters["id"]?.toLongOrNull() ?: return@delete call.respond(HttpStatusCode.BadRequest)
            val principal = call.principal<JWTPrincipal>()
            val email = principal?.payload?.getClaim("email")?.asString() ?: return@delete call.respond(HttpStatusCode.Unauthorized)
            val user = userService.findByUsername(username = String())  ?: return@delete call.respond(HttpStatusCode.Unauthorized)
            val post = postService.getById(id) ?: return@delete call.respond(HttpStatusCode.NotFound)
            if (post.userId != user.id) {
                return@delete call.respond(HttpStatusCode.Forbidden, "You can only delete your own posts")
            }
            val success = postService.delete(id)
            if (success) {
                call.respond(HttpStatusCode.NoContent)
            } else {
                call.respond(HttpStatusCode.NotFound)
            }
        }
    }
}