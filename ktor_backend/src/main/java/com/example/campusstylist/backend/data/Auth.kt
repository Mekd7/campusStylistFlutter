package com.example.campusstylist.backend.data

import kotlinx.serialization.Serializable

@Serializable
data class AuthRequest(
    val email: String,
    val password: String,
    val role: String
)

@Serializable
data class LoginRequest(
    val email: String,
    val password: String
)

@Serializable
data class AuthResponse(
    val token: String,
    val role: String,
    val userId: String, // Added userId to match UserService and frontend
    val hasCreatedProfile: Boolean
)

