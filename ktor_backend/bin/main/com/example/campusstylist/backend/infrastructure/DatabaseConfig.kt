package com.example.campusstylist.backend.infrastructure

import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.SchemaUtils
import org.jetbrains.exposed.sql.transactions.transaction
import com.example.campusstylist.backend.infrastructure.table.Users
import com.example.campusstylist.backend.infrastructure.table.Posts
import com.example.campusstylist.backend.infrastructure.table.Requests
import com.example.campusstylist.backend.infrastructure.table.Bookings
import com.example.campusstylist.backend.infrastructure.table.Services

object DatabaseConfig {
    fun init() {
        val config = HikariConfig().apply {
            jdbcUrl = "jdbc:postgresql://localhost:5432/campusstylist"
            driverClassName = "org.postgresql.Driver"
            username = "postgres"
            password = "Mekd7777"
            maximumPoolSize = 10
        }
        val dataSource = HikariDataSource(config)
        Database.connect(dataSource)

        transaction {
            SchemaUtils.create(Users, Posts, Requests, Bookings, Services)
        }
    }
}