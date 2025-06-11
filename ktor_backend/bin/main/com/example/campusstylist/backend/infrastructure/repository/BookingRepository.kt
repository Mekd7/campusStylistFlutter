package com.example.campusstylist.backend.infrastructure.repository

import com.example.campusstylist.backend.domain.model.Booking
import com.example.campusstylist.backend.infrastructure.table.Bookings
import org.jetbrains.exposed.sql.*
//import org.jetbrains.exposed.sql.op.Op
import org.jetbrains.exposed.sql.transactions.transaction

class BookingRepository {
    fun create(booking: Booking): Booking = transaction {
        val id = Bookings.insert {
            it[clientId] = booking.clientId
            it[hairstylistId] = booking.hairstylistId
            it[service] = booking.service
            it[price] = booking.price
            it[date] = booking.date
            it[status] = booking.status
        } get Bookings.id
        booking.copy(id = id)
    }

    fun findByUserId(userId: Long, isHairstylist: Boolean): List<Booking> = transaction {
        val column = if (isHairstylist) Bookings.hairstylistId else Bookings.clientId
        Bookings.select { Op.build { column eq userId } }
            .map {
                Booking(
                    id = it[Bookings.id],
                    clientId = it[Bookings.clientId],
                    hairstylistId = it[Bookings.hairstylistId],
                    service = it[Bookings.service],
                    price = it[Bookings.price],
                    date = it[Bookings.date],
                    status = it[Bookings.status]
                )
            }
    }

    fun findByHairstylistIdAndDate(hairstylistId: Long, date: String): List<Booking> = transaction {
        val dateOnly = date.substring(0, 10) // Extract "YYYY-MM-DD" from "YYYY-MM-DDTHH:MM:SSZ"
        Bookings.select { Op.build { (Bookings.hairstylistId eq hairstylistId) and (Bookings.date like "$dateOnly%") } }
            .map {
                Booking(
                    id = it[Bookings.id],
                    clientId = it[Bookings.clientId],
                    hairstylistId = it[Bookings.hairstylistId],
                    service = it[Bookings.service],
                    price = it[Bookings.price],
                    date = it[Bookings.date],
                    status = it[Bookings.status]
                )
            }
    }

    fun update(booking: Booking): Boolean = transaction {
        booking.id?.let {
            Bookings.update({ Op.build { Bookings.id eq it } }) {
                it[service] = booking.service
                it[price] = booking.price
                it[date] = booking.date
                it[status] = booking.status
            } > 0
        } ?: false
    }
}