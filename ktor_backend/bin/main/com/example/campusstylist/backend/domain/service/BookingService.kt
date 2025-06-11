package com.example.campusstylist.backend.domain.service

import com.example.campusstylist.backend.domain.model.Booking
import com.example.campusstylist.backend.infrastructure.repository.BookingRepository
import org.jetbrains.exposed.sql.transactions.transaction

class BookingService(private val bookingRepository: BookingRepository) {

    fun create(booking: Booking): Booking? {
        return transaction {
            bookingRepository.create(booking)
        }
    }

    fun getByUserId(userId: Long, isHairstylist: Boolean): List<Booking> {
        return transaction {
            bookingRepository.findByUserId(userId, isHairstylist)
        }
    }

    fun update(booking: Booking): Boolean {
        return transaction {
            bookingRepository.update(booking)
        }
    }
}