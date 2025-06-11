package com.example.campusstylist.backend.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class Booking(
    val id: Long? = null,
    val clientId: Long,
    val hairstylistId: Long,
    val service: String,
    val price: Double,
    val date: String, // ISO 8601 format, e.g., "2025-05-05T00:00:00Z"
    val status: String = "Pending",
    val username: String? = null // Added to match Bookings table
)