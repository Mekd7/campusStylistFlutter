package com.example.campusstylist.backend.infrastructure.repository

import com.example.campusstylist.backend.domain.model.User
import com.example.campusstylist.backend.infrastructure.table.Users
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq // Corrected import!

class UserRepository {
    fun create(user: User): User = transaction {
        val id = Users.insert {
            it[username] = user.username
            it[password] = user.password
            it[role] = user.role
            it[profilePicture] = user.profilePicture
            it[bio] = user.bio
            it[name] = user.name
            it[hasCreatedProfile] = user.hasCreatedProfile
        } get Users.id
        user.copy(id = id)
    }

    fun findByUsername(username: String): User? = transaction {
        Users.select { Users.username eq username }
            .map {
                User(
                    id = it[Users.id],
                    username = it[Users.username],
                    password = it[Users.password],
                    role = it[Users.role],
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
            Users.update({ Users.id eq it }) {
                it[profilePicture] = user.profilePicture
                it[bio] = user.bio
                it[name] = user.name
                it[hasCreatedProfile] = user.hasCreatedProfile
            } > 0
        } ?: false
    }

    fun delete(id: Long): Boolean = transaction {
        Users.deleteWhere { Users.id eq id } > 0
    }
}
