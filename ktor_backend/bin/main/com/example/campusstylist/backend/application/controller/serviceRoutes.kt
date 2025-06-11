package com.example.campusstylist.backend.application.controller

import com.example.campusstylist.backend.domain.service.ServiceService
import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Route.serviceRoutes(serviceService: ServiceService) {
    get("/services") {
        val services = serviceService.getAll()
        call.respond(services)
    }
}