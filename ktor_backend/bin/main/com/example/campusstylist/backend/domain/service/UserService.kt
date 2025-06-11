package com.example.campusstylist.backend.domain.service

import com.example.campusstylist.backend.domain.model.Role
import com.example.campusstylist.backend.domain.model.User
import com.example.campusstylist.backend.infrastructure.repository.UserRepository
import com.example.campusstylist.backend.infrastructure.security.JwtConfig
import org.jetbrains.exposed.sql.transactions.transaction

class UserService(private val userRepository: UserRepository) {

    fun signup(username: String, password: String, role: String): Map<String, Any> {
        val parsedRole = try {
            Role.valueOf(role.uppercase()) // Use uppercase() on the role string from the request
        } catch (e: IllegalArgumentException) {
            throw IllegalArgumentException("Invalid role: $role")
        }

        val newUser = User(
            id = null,
            username = username,
            password = hashPassword(password),
            role = parsedRole,
            hasCreatedProfile = false
        )

        return transaction {
            userRepository.findByUsername(newUser.username)?.let {
                throw IllegalArgumentException("Username already exists")
            }
            userRepository.create(newUser)
            mapOf(
                "token" to JwtConfig.generateToken(newUser.username),
                "role" to newUser.role.name,
                "hasCreatedProfile" to false
            )
        }
    }

    fun signin(username: String, password: String): Map<String, Any>? {
        val user = transaction {
            userRepository.findByUsername(username)
        } ?: return null

        if (!verifyPassword(password, user.password)) {
            return null
        }

        return mapOf(
            "token" to JwtConfig.generateToken(user.username),
            "role" to user.role.name,
            "hasCreatedProfile" to (user.hasCreatedProfile ?: false)
        )
    }

    fun findByUsername(username: String): User? {
        return transaction {
            userRepository.findByUsername(username)
        }
    }

    fun update(user: User): Boolean {
        return transaction {
            userRepository.update(user)
        }
    }

    fun delete(id: Long): Boolean {
        return transaction {
            userRepository.delete(id)
        }
    }

    private fun hashPassword(password: String): String {
        return password
    }

    private fun verifyPassword(rawPassword: String, hashedPassword: String): Boolean {
        return rawPassword == hashedPassword
    }
}