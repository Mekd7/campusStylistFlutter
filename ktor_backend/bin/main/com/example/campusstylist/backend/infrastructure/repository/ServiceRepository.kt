package com.example.campusstylist.backend.infrastructure.repository

import com.example.campusstylist.backend.domain.model.Service
import com.example.campusstylist.backend.infrastructure.table.Services
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction

class ServiceRepository {
    fun create(service: Service): Service = transaction {
        val id = Services.insert {
            it[name] = service.name
            it[price] = service.price
        } get Services.id
        service.copy(id = id)
    }

    fun findAll(): List<Service> = transaction {
        Services.selectAll().map {
            Service(
                id = it[Services.id],
                name = it[Services.name],
                price = it[Services.price]
            )
        }
    }
}