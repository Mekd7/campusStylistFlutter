package com.example.campusstylist.backend.infrastructure.repository

import com.example.campusstylist.backend.domain.model.Request
import com.example.campusstylist.backend.infrastructure.table.Requests
import com.example.campusstylist.backend.infrastructure.table.Users
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import org.postgresql.util.PSQLException
import org.slf4j.LoggerFactory

class RequestRepository {
    private val logger = LoggerFactory.getLogger(RequestRepository::class.java)

    fun create(request: Request): Request = transaction {
        try {
            // Validate foreign keys
            val clientExists = Users.select { Users.id eq request.clientId }.count() > 0
            val hairstylistExists = Users.select { Users.id eq request.hairstylistId }.count() > 0
            if (!clientExists || !hairstylistExists) {
                throw IllegalArgumentException("Invalid clientId or hairstylistId")
            }
            val id = Requests.insert {
                it[clientId] = request.clientId
                it[hairstylistId] = request.hairstylistId
                it[service] = request.service
                it[status] = request.status
            } get Requests.id
            request.copy(id = id)
        } catch (e: PSQLException) {
            logger.error("Failed to create request: ${e.message}", e)
            throw IllegalStateException("Database error: ${e.message}", e)
        } catch (e: IllegalArgumentException) {
            logger.warn("Invalid request data: ${e.message}")
            throw e
        }
    }

    fun findByHairstylistId(hairstylistId: Long): List<Request> = transaction {
        try {
            Requests.select { Requests.hairstylistId eq hairstylistId }
                .map {
                    Request(
                        id = it[Requests.id],
                        clientId = it[Requests.clientId],
                        hairstylistId = it[Requests.hairstylistId],
                        service = it[Requests.service],
                        status = it[Requests.status]
                    )
                }
        } catch (e: PSQLException) {
            logger.error("Failed to find requests: ${e.message}", e)
            throw IllegalStateException("Database error: ${e.message}", e)
        }
    }

    fun findById(id: Long): Request? = transaction {
        try {
            Requests.select { Requests.id eq id }
                .map {
                    Request(
                        id = it[Requests.id],
                        clientId = it[Requests.clientId],
                        hairstylistId = it[Requests.hairstylistId],
                        service = it[Requests.service],
                        status = it[Requests.status]
                    )
                }
                .singleOrNull()
        } catch (e: PSQLException) {
            logger.error("Failed to find request: ${e.message}", e)
            throw IllegalStateException("Database error: ${e.message}", e)
        }
    }

    fun decline(id: Long): Boolean = transaction {
        try {
            Requests.update({ Requests.id eq id }) {
                it[status] = "Declined"
            } > 0
        } catch (e: PSQLException) {
            logger.error("Failed to decline request: ${e.message}", e)
            throw IllegalStateException("Database error: ${e.message}", e)
        }
    }
}