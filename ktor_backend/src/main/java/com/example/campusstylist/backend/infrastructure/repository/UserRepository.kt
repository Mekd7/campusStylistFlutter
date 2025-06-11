package com.example.campusstylist.backend.infrastructure.repository

import com.example.campusstylist.backend.domain.model.User
import com.example.campusstylist.backend.infrastructure.table.Users
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import org.slf4j.LoggerFactory
import org.postgresql.util.PSQLException
import com.example.campusstylist.backend.domain.model.Role

class UserRepository {
    private val logger = LoggerFactory.getLogger(UserRepository::class.java)

    fun create(user: User): User = transaction {
        try {
            val id = Users.insert {
                it[email] = user.email
                it[username] = user.username
                it[password] = user.password
                it[role] = user.role.dbValue // Use dbValue for consistent integer storage
                it[profilePicture] = user.profilePicture
                it[bio] = user.bio
                it[name] = user.name
                it[hasCreatedProfile] = user.hasCreatedProfile
            } get Users.id
            logger.debug("Created user with id=$id, email=${user.email}")
            user.copy(id = id)
        } catch (e: PSQLException) {
            logger.error("Failed to create user: ${e.message}", e)
            throw IllegalStateException("Database error: ${e.message}", e)
        }
    }

    fun findById(id: Long): User? = transaction {
        Users.select { Users.id eq id }
            .map {
                User(
                    id = it[Users.id],
                    email = it[Users.email],
                    username = it[Users.username],
                    password = it[Users.password],
                    role = Role.fromDbValue(it[Users.role]), // Use fromDbValue to convert back to Role
                    profilePicture = it[Users.profilePicture],
                    bio = it[Users.bio],
                    name = it[Users.name],
                    hasCreatedProfile = it[Users.hasCreatedProfile]
                )
            }
            .singleOrNull()
    }

    fun findByEmail(email: String): User? = transaction {
        Users.select { Users.email eq email }
            .map {
                User(
                    id = it[Users.id],
                    email = it[Users.email],
                    username = it[Users.username],
                    password = it[Users.password],
                    role = Role.fromDbValue(it[Users.role]), // Use fromDbValue
                    profilePicture = it[Users.profilePicture],
                    bio = it[Users.bio],
                    name = it[Users.name],
                    hasCreatedProfile = it[Users.hasCreatedProfile]
                )
            }
            .singleOrNull()
    }

    fun update(user: User): Boolean = transaction {
        user.id?.let {
            try {
                Users.update({ Users.id eq it }) { update ->
                    if (user.email != null) update[email] = user.email
                    if (user.username != null) update[username] = user.username
                    if (user.password != null) update[password] = user.password
                    if (user.role != null) update[role] = user.role.dbValue
                    if (user.profilePicture != null) update[profilePicture] = user.profilePicture
                    if (user.bio != null) update[bio] = user.bio
                    if (user.name != null) update[name] = user.name
                    if (user.hasCreatedProfile != null) update[hasCreatedProfile] = user.hasCreatedProfile
                } > 0
            } catch (e: PSQLException) {
                logger.error("Failed to update user id=$it: ${e.message}", e)
                throw IllegalStateException("Database error: ${e.message}", e)
            }
        } ?: false
    }

    fun delete(id: Long): Boolean = transaction {
        try {
            Users.deleteWhere { Users.id eq id } > 0
        } catch (e: PSQLException) {
            logger.error("Failed to delete user id=$id: ${e.message}", e)
            throw IllegalStateException("Database error: ${e.message}", e)
        }
    }
}