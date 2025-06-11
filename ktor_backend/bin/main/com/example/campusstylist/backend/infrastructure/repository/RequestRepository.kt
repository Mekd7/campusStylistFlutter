package com.example.campusstylist.backend.infrastructure.repository

import com.example.campusstylist.backend.domain.model.Request
import com.example.campusstylist.backend.infrastructure.table.Requests
import org.jetbrains.exposed.sql.*
//import org.jetbrains.exposed.sql.op.Op
import org.jetbrains.exposed.sql.transactions.transaction

class RequestRepository {
    fun create(request: Request): Request = transaction {
        val id = Requests.insert {
            it[clientId] = request.clientId
            it[hairstylistId] = request.hairstylistId
            it[service] = request.service
            it[status] = request.status
        } get Requests.id
        request.copy(id = id)
    }

    fun findByHairstylistId(hairstylistId: Long): List<Request> = transaction {
        Requests.select { Op.build { Requests.hairstylistId eq hairstylistId } }
            .map {
                Request(
                    id = it[Requests.id],
                    clientId = it[Requests.clientId],
                    hairstylistId = it[Requests.hairstylistId],
                    service = it[Requests.service],
                    status = it[Requests.status]
                )
            }
    }

    fun decline(id: Long): Boolean = transaction {
        Requests.update({ Op.build { Requests.id eq id } }) {
            it[status] = "Declined"
        } > 0
    }
}