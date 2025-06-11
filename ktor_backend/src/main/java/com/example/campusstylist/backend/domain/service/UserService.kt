package com.example.campusstylist.backend.domain.service

import com.auth0.jwt.JWT
import com.example.campusstylist.backend.data.AuthResponse
import com.example.campusstylist.backend.domain.model.Role
import com.example.campusstylist.backend.domain.model.User
import com.example.campusstylist.backend.infrastructure.repository.UserRepository
import com.example.campusstylist.backend.infrastructure.security.JwtConfig
import org.mindrot.jbcrypt.BCrypt
import org.slf4j.LoggerFactory
import com.auth0.jwt.algorithms.Algorithm.HMAC256
import org.jetbrains.exposed.sql.transactions.transaction

class UserService(private val userRepository: UserRepository) {
    private val logger = LoggerFactory.getLogger(UserService::class.java)

    fun signup(email: String, password: String, role: String): AuthResponse {
        logger.debug("Processing signup: email=$email, role=$role")
        val parsedRole = try {
            Role.valueOf(role.uppercase())
        } catch (e: IllegalArgumentException) {
            logger.warn("Invalid role: $role")
            throw IllegalArgumentException("Invalid role: $role")
        }

        val user = User(
            id = null,
            email = email,
            username = null,
            password = hashPassword(password),
            role = parsedRole,
            profilePicture = null,
            bio = null,
            name = null,
            hasCreatedProfile = false
        )

        return transaction {
            userRepository.findByEmail(email)?.let {
                logger.warn("Email already exists: $email")
                throw IllegalArgumentException("Email already exists")
            }
            val createdUser = userRepository.create(user)
            logger.debug("User created: email=$email, role=${createdUser.role}")
            if (createdUser.id == null) {
                throw IllegalStateException("User ID was not generated during signup")
            }
            AuthResponse(
                token = JwtConfig.generateToken(createdUser.email),
                role = createdUser.role.name,
                userId = createdUser.id.toString(),
                hasCreatedProfile = createdUser.hasCreatedProfile
            )
        }
    }

    fun signin(email: String, password: String): AuthResponse? {
        logger.debug("Processing signin: email=$email")
        val user = transaction {
            userRepository.findByEmail(email)
        } ?: run {
            logger.warn("User not found: email=$email")
            return null
        }

        if (!verifyPassword(password, user.password)) {
            logger.warn("Invalid password for email: $email")
            return null
        }

        logger.debug("Signin successful: email=$email, role=${user.role}")
        if (user.id == null) {
            logger.error("User ID is null for email: $email")
            return null
        }
        return AuthResponse(
            token = JwtConfig.generateToken(user.email),
            role = user.role.name,
            userId = user.id.toString(),
            hasCreatedProfile = user.hasCreatedProfile
        )
    }

    fun findByEmail(email: String): User? {
        return transaction {
            userRepository.findByEmail(email)
        }
    }

    fun createProfile(userId: Long, username: String, bio: String?, profilePicture: String?): Boolean {
        return transaction {
            val user = userRepository.findById(userId) ?: return@transaction false
            val updatedUser = user.copy(
                username = username,
                bio = bio,
                profilePicture = profilePicture ?: "/uploads/default.jpg",
                hasCreatedProfile = true
            )
            userRepository.update(updatedUser)
        }
    }

    fun update(user: User): Boolean {
        return transaction {
            val updatedUser = user.copy(
                password = if (user.password != findByEmail(user.email)?.password) hashPassword(user.password) else user.password
            )
            userRepository.update(updatedUser)
        }
    }

    fun delete(id: Long): Boolean {
        return transaction {
            userRepository.delete(id)
        }
    }

    private fun hashPassword(password: String): String {
        return BCrypt.hashpw(password, BCrypt.gensalt())
    }

    private fun verifyPassword(rawPassword: String, hashedPassword: String): Boolean {
        return BCrypt.checkpw(rawPassword, hashedPassword)
    }

    fun getUserIdFromToken(token: String): String? {
        return try {
            val email = JwtConfig.verifyToken(token)
            if (email == null) {
                logger.error("Failed to verify token: Invalid or missing email claim")
            }
            email
        } catch (e: Exception) {
            logger.error("Failed to verify token: ${e.message}")
            null
        }
    }
}