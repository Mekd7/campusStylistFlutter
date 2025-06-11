package com.example.campusstylist.backend.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class Post(
    val id: Long? = null,
    val userId: Long,
    val pictureUrl: String,
    val description: String
)