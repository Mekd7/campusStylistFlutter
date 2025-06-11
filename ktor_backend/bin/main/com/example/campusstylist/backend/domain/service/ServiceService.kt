package com.example.campusstylist.backend.domain.service

import com.example.campusstylist.backend.domain.model.Service
import com.example.campusstylist.backend.infrastructure.repository.ServiceRepository
import org.jetbrains.exposed.sql.transactions.transaction

class ServiceService(private val serviceRepository: ServiceRepository) {

    fun create(service: Service): Service {
        return transaction {
            serviceRepository.create(service)
        }
    }

    fun getAll(): List<Service> {
        return transaction {
            serviceRepository.findAll()
        }
    }
}