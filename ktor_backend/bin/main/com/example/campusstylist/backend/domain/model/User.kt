package com.example.campusstylist.backend.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class User(
    val id: Long? = null,
    val username: String,
    val password: String,
    val role: Role,
    val profilePicture: String? = null,
    val bio: String? = null,
    val name: String? = null,
    val hasCreatedProfile: Boolean = false
)

//enum class Role {
//    STUDENT, HAIRDRESSER
//}