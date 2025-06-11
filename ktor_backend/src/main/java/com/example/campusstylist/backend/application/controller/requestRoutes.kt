package com.example.campusstylist.backend.application.controller

import com.example.campusstylist.backend.domain.model.Request
import com.example.campusstylist.backend.domain.service.RequestService
import com.example.campusstylist.backend.domain.service.UserService
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.serialization.SerializationException
import java.sql.SQLException

fun Route.requestRoutes(requestService: RequestService, userService: UserService) {
    authenticate("auth-jwt") {
        post("/requests") {
            try {
                val principal = call.principal<JWTPrincipal>()
                val email = principal?.payload?.getClaim("email")?.asString() ?: return@post call.respond(HttpStatusCode.Unauthorized, mapOf("error" to "Unauthorized", "message" to "Invalid token"))
                val user = userService.findByEmail(email) ?: return@post call.respond(HttpStatusCode.Unauthorized, mapOf("error" to "Unauthorized", "message" to "User not found"))
                val request = call.receive<Request>()
                if (request.clientId != user.id) {
                    return@post call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Forbidden", "message" to "You can only create requests for yourself"))
                }
                if (request.service.isBlank()) {
                    return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid input", "message" to "Service is required"))
                }
                val createdRequest = requestService.create(request)
                call.respond(HttpStatusCode.Created, createdRequest)
            } catch (e: SerializationException) {
                call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid JSON", "message" to e.message))
            } catch (e: SQLException) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
            } catch (e: Exception) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }

        get("/requests/{hairstylistId}") {
            try {
                val hairstylistId = call.parameters["hairstylistId"]?.toLongOrNull() ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid input", "message" to "Invalid hairstylist ID"))
                val principal = call.principal<JWTPrincipal>()
                val email = principal?.payload?.getClaim("email")?.asString() ?: return@get call.respond(HttpStatusCode.Unauthorized, mapOf("error" to "Unauthorized", "message" to "Invalid token"))
                val user = userService.findByEmail(email) ?: return@get call.respond(HttpStatusCode.Unauthorized, mapOf("error" to "Unauthorized", "message" to "User not found"))
                if (user.id != hairstylistId) {
                    return@get call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Forbidden", "message" to "You can only view your own requests"))
                }
                val requests = requestService.getByHairstylistId(hairstylistId)
                call.respond(requests)
            } catch (e: SQLException) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
            } catch (e: Exception) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }

        put("/requests/{id}/decline") {
            try {
                val id = call.parameters["id"]?.toLongOrNull() ?: return@put call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid input", "message" to "Invalid request ID"))
                val principal = call.principal<JWTPrincipal>()
                val email = principal?.payload?.getClaim("email")?.asString() ?: return@put call.respond(HttpStatusCode.Unauthorized, mapOf("error" to "Unauthorized", "message" to "Invalid token"))
                val user = userService.findByEmail(email) ?: return@put call.respond(HttpStatusCode.Unauthorized, mapOf("error" to "Unauthorized", "message" to "User not found"))
                val request = requestService.getById(id) ?: return@put call.respond(HttpStatusCode.NotFound, mapOf("error" to "Not found", "message" to "Request not found"))
                if (request.hairstylistId != user.id) {
                    return@put call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Forbidden", "message" to "You can only decline your own requests"))
                }
                val success = requestService.decline(id)
                if (success) {
                    call.respond(HttpStatusCode.OK, mapOf("message" to "Request declined"))
                } else {
                    call.respond(HttpStatusCode.NotFound, mapOf("error" to "Not found", "message" to "Request not found"))
                }
            } catch (e: SQLException) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
            } catch (e: Exception) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }
    }
}