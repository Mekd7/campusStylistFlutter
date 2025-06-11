package com.example.campusstylist.backend.domain.service

import com.example.campusstylist.backend.domain.model.Request
import com.example.campusstylist.backend.infrastructure.repository.RequestRepository
import org.jetbrains.exposed.sql.transactions.transaction

class RequestService(private val requestRepository: RequestRepository) {

    fun create(request: Request): Request {
        return transaction {
            requestRepository.create(request)
        }
    }

    fun getByHairstylistId(hairstylistId: Long): List<Request> {
        return transaction {
            requestRepository.findByHairstylistId(hairstylistId)
        }
    }

    fun getById(id: Long): Request? {
        return transaction {
            requestRepository.findById(id)
        }
    }

    fun decline(id: Long): Boolean {
        return transaction {
            requestRepository.decline(id)
        }
    }
}