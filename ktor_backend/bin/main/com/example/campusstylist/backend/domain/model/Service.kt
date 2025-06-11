package com.example.campusstylist.backend.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class Service(
    val id: Long? = null,
    val name: String,
    val price: Double
)