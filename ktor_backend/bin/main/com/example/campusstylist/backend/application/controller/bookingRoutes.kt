package com.example.campusstylist.backend.application.controller

import com.example.campusstylist.backend.domain.model.Booking
import com.example.campusstylist.backend.domain.service.BookingService
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Route.bookingRoutes(bookingService: BookingService) {
    authenticate("auth-jwt") {
        post("/bookings") {
            val booking = call.receive<Booking>()
            val createdBooking = bookingService.create(booking)
            if (createdBooking != null) {
                call.respond(HttpStatusCode.Created, createdBooking)
            } else {
                call.respond(HttpStatusCode.Conflict, "Hairstylist is not available on this date")
            }
        }

        get("/bookings/{userId}") {
            val userId = call.parameters["userId"]?.toLongOrNull() ?: return@get call.respond(HttpStatusCode.BadRequest)
            val isHairstylist = call.request.queryParameters["isHairstylist"]?.toBoolean() ?: false
            val bookings = bookingService.getByUserId(userId, isHairstylist)
            call.respond(bookings)
        }

        put("/bookings/{id}") {
            val id = call.parameters["id"]?.toLongOrNull() ?: return@put call.respond(HttpStatusCode.BadRequest)
            val booking = call.receive<Booking>()
            val updated = bookingService.update(booking.copy(id = id))
            if (updated) {
                call.respond(HttpStatusCode.OK)
            } else {
                call.respond(HttpStatusCode.NotFound)
            }
        }
    }
}