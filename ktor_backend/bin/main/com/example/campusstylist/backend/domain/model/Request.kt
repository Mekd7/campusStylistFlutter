package com.example.campusstylist.backend.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class Request(
    val id: Long? = null,
    val clientId: Long,
    val hairstylistId: Long,
    val service: String,
    val status: String = "Pending"
)