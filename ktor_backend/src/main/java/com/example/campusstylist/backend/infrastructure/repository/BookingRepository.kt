package com.example.campusstylist.backend.infrastructure.repository

import com.example.campusstylist.backend.domain.model.Booking
import com.example.campusstylist.backend.infrastructure.table.Bookings
import com.example.campusstylist.backend.infrastructure.table.Users
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import org.postgresql.util.PSQLException
import org.slf4j.LoggerFactory

class BookingRepository {
    private val logger = LoggerFactory.getLogger(BookingRepository::class.java)

    fun create(booking: Booking): Booking = transaction {
        try {
            // Validate foreign keys
            val clientExists = Users.select { Users.id eq booking.clientId }.count() > 0
            val hairstylistExists = Users.select { Users.id eq booking.hairstylistId }.count() > 0
            if (!clientExists || !hairstylistExists) {
                throw IllegalArgumentException("Invalid clientId or hairstylistId")
            }
            val id = Bookings.insert {
                it[clientId] = booking.clientId
                it[hairstylistId] = booking.hairstylistId
                it[service] = booking.service
                it[price] = booking.price
                it[date] = booking.date
                it[status] = booking.status
                it[username] = booking.username // Added to match table schema
            } get Bookings.id
            booking.copy(id = id)
        } catch (e: PSQLException) {
            logger.error("Failed to create booking: ${e.message}", e)
            throw IllegalStateException("Database error: ${e.message}", e)
        } catch (e: IllegalArgumentException) {
            logger.warn("Invalid booking data: ${e.message}")
            throw e
        }
    }

    fun findByUserId(userId: Long, isHairdresser: Boolean): List<Booking> = transaction {
        try {
            val column = if (isHairdresser) Bookings.hairstylistId else Bookings.clientId
            Bookings.select { column eq userId }
                .map {
                    Booking(
                        id = it[Bookings.id],
                        clientId = it[Bookings.clientId],
                        hairstylistId = it[Bookings.hairstylistId],
                        service = it[Bookings.service],
                        price = it[Bookings.price],
                        date = it[Bookings.date],
                        status = it[Bookings.status],
                        username = it[Bookings.username] // Added to match table schema
                    )
                }
        } catch (e: PSQLException) {
            logger.error("Failed to find bookings: ${e.message}", e)
            throw IllegalStateException("Database error: ${e.message}", e)
        }
    }

    fun findByHairstylistIdAndDate(hairstylistId: Long, date: String): List<Booking> = transaction {
        try {
            val dateOnly = date.substring(0, 10) // Extract "YYYY-MM-DD"
            Bookings.select { (Bookings.hairstylistId eq hairstylistId) and (Bookings.date like "$dateOnly%") }
                .map {
                    Booking(
                        id = it[Bookings.id],
                        clientId = it[Bookings.clientId],
                        hairstylistId = it[Bookings.hairstylistId],
                        service = it[Bookings.service],
                        price = it[Bookings.price],
                        date = it[Bookings.date],
                        status = it[Bookings.status],
                        username = it[Bookings.username] // Added to match table schema
                    )
                }
        } catch (e: PSQLException) {
            logger.error("Failed to find bookings: ${e.message}", e)
            throw IllegalStateException("Database error: ${e.message}", e)
        }
    }

    fun update(booking: Booking): Boolean = transaction {
        try {
            logger.info("Attempting to update booking with ID: ${booking.id}")
            booking.id?.let {
                val updatedRows = Bookings.update({ Bookings.id eq it }) {
                    it[service] = booking.service
                    it[price] = booking.price
                    it[date] = booking.date
                    it[status] = booking.status
                    it[username] = booking.username // Added to match table schema
                }
                if (updatedRows > 0) {
                    logger.info("Booking with ID: $it updated successfully.")
                    return@transaction true
                } else {
                    logger.warn("No booking found with ID: $it.")
                    return@transaction false
                }
            } ?: run {
                logger.warn("Booking ID is null.")
                return@transaction false
            }
        } catch (e: PSQLException) {
            logger.error("Failed to update booking: ${e.message}", e)
            throw IllegalStateException("Database error: ${e.message}", e)
        }
    }
}