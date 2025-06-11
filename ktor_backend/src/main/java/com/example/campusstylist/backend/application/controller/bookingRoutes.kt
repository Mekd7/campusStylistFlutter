package com.example.campusstylist.backend.application.controller

import com.example.campusstylist.backend.domain.model.Booking
import com.example.campusstylist.backend.domain.service.BookingService
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

fun Route.bookingRoutes(bookingService: BookingService, userService: UserService) {
    authenticate("auth-jwt") {
        post("/bookings") {
            try {
                val principal = call.principal<JWTPrincipal>()
                val email = principal?.payload?.getClaim("email")?.asString() ?: return@post call.respond(HttpStatusCode.Unauthorized, mapOf("error" to "Unauthorized", "message" to "Invalid token"))
                val user = userService.findByEmail(email) ?: return@post call.respond(HttpStatusCode.Unauthorized, mapOf("error" to "Unauthorized", "message" to "User not found"))
                val booking = call.receive<Booking>()
                if (booking.clientId != user.id) {
                    return@post call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Forbidden", "message" to "You can only create bookings for yourself"))
                }
                // Validate booking
                if (booking.service.isBlank() || booking.price <= 0 || booking.date.isBlank()) {
                    return@post call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid input", "message" to "Service, price, and date are required"))
                }

                val createdBooking = bookingService.create(booking)
                if (createdBooking != null) {
                    call.respond(HttpStatusCode.Created, createdBooking)
                } else {
                    call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to "Failed to create booking"))
                }
            } catch (e: SerializationException) {
                call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid JSON", "message" to e.message))
            } catch (e: SQLException) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
            } catch (e: Exception) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }

        get("/bookings") {
            try {
                val hairstylistId = call.request.queryParameters["hairstylistId"]?.toLongOrNull() ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid input", "message" to "Hairstylist ID is required"))
                val date = call.request.queryParameters["date"] ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid input", "message" to "Date is required"))
                val principal = call.principal<JWTPrincipal>()
                val email = principal?.payload?.getClaim("email")?.asString() ?: return@get call.respond(HttpStatusCode.Unauthorized, mapOf("error" to "Unauthorized", "message" to "Invalid token"))
                val user = userService.findByEmail(email) ?: return@get call.respond(HttpStatusCode.Unauthorized, mapOf("error" to "Unauthorized", "message" to "User not found"))
                val bookings = bookingService.getByHairstylistIdAndDate(hairstylistId, date)
                call.respond(bookings)
            } catch (e: SQLException) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
            } catch (e: Exception) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }

        get("/bookings/{userId}") {
            try {
                val userId = call.parameters["userId"]?.toLongOrNull() ?: return@get call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid input", "message" to "Invalid user ID"))
                val principal = call.principal<JWTPrincipal>()
                val email = principal?.payload?.getClaim("email")?.asString() ?: return@get call.respond(HttpStatusCode.Unauthorized, mapOf("error" to "Unauthorized", "message" to "Invalid token"))
                val user = userService.findByEmail(email) ?: return@get call.respond(HttpStatusCode.Unauthorized, mapOf("error" to "Unauthorized", "message" to "User not found"))
                if (user.id != userId) {
                    return@get call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Forbidden", "message" to "You can only view your own bookings"))
                }
                val isHairdresser = call.request.queryParameters["isHairdresser"]?.toBoolean() ?: false
                val bookings = bookingService.getByUserId(userId, isHairdresser)
                call.respond(bookings)
            } catch (e: SQLException) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
            } catch (e: Exception) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }

        put("/bookings/{id}") {
            try {
                val id = call.parameters["id"]?.toLongOrNull() ?: return@put call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid input", "message" to "Invalid booking ID"))
                val principal = call.principal<JWTPrincipal>()
                val email = principal?.payload?.getClaim("email")?.asString() ?: return@put call.respond(HttpStatusCode.Unauthorized, mapOf("error" to "Unauthorized", "message" to "Invalid token"))
                val user = userService.findByEmail(email) ?: return@put call.respond(HttpStatusCode.Unauthorized, mapOf("error" to "Unauthorized", "message" to "User not found"))
                val booking = call.receive<Booking>()
                if (booking.clientId != user.id && booking.hairstylistId != user.id) {
                    return@put call.respond(HttpStatusCode.Forbidden, mapOf("error" to "Forbidden", "message" to "You can only update your own bookings"))
                }
                val updated = bookingService.update(booking.copy(id = id))
                if (updated) {
                    call.respond(HttpStatusCode.OK, mapOf("message" to "Booking updated"))
                } else {
                    call.respond(HttpStatusCode.NotFound, mapOf("error" to "Not found", "message" to "Booking not found"))
                }
            } catch (e: SerializationException) {
                call.respond(HttpStatusCode.BadRequest, mapOf("error" to "Invalid JSON", "message" to e.message))
            } catch (e: SQLException) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Database error", "message" to e.message))
            } catch (e: Exception) {
                call.respond(HttpStatusCode.InternalServerError, mapOf("error" to "Server error", "message" to e.message))
            }
        }
    }
}