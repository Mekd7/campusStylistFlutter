package com.example.campusstylist.backend.application.controller

import com.example.campusstylist.backend.domain.service.ServiceService
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.sql.SQLException

fun Route.serviceRoutes(serviceService: ServiceService) {
    get("/services") {
        try {
            val services = serviceService.getAll()
            call.respond(services)
        } catch (e: SQLException) {
            call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
        } catch (e: Exception) {
            call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
        }
    }
}