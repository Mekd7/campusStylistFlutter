package com.example.campusstylist.backend.application.controller

import com.example.campusstylist.backend.domain.model.User
import com.example.campusstylist.backend.domain.service.UserService
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Route.authRoutes(userService: UserService) {
    route("/auth") {
        post("/register") {
            val user = call.receive<User>()
            try {
                val result = userService.signup(user.username, user.password, user.role.name) // Pass role name as String
                call.respond(HttpStatusCode.Created, result) // Respond with the result from signup
            } catch (e: IllegalArgumentException) {
                call.respond(HttpStatusCode.Conflict, e.message ?: "Username already exists")
            }
        }

        post("/login") {
            val user = call.receive<User>()
            val result = userService.signin(user.username, user.password) // Get result from signin
            if (result != null) {
                call.respond(HttpStatusCode.OK, result) // Respond with the result
            } else {
                call.respond(HttpStatusCode.Unauthorized, "Invalid credentials")
            }
        }
    }
}

