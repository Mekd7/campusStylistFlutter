package com.example.campusstylist.backend.application.controller

import com.example.campusstylist.backend.domain.model.Request
import com.example.campusstylist.backend.domain.service.RequestService
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Route.requestRoutes(requestService: RequestService) {
    authenticate("auth-jwt") {
        post("/requests") {
            val request = call.receive<Request>()
            val createdRequest = requestService.create(request)
            call.respond(HttpStatusCode.Created, createdRequest)
        }

        get("/requests/{hairstylistId}") {
            val hairstylistId = call.parameters["hairstylistId"]?.toLongOrNull() ?: return@get call.respond(HttpStatusCode.BadRequest)
            val requests = requestService.getByHairstylistId(hairstylistId)
            call.respond(requests)
        }

        post("/requests/decline/{id}") {
            val id = call.parameters["id"]?.toLongOrNull() ?: return@post call.respond(HttpStatusCode.BadRequest)
            val success = requestService.decline(id)
            if (success) {
                call.respond(HttpStatusCode.OK)
            } else {
                call.respond(HttpStatusCode.NotFound)
            }
        }
    }
}