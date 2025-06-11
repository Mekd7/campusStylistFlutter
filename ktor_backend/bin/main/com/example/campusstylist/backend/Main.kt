package com.example.campusstylist.backend

import com.example.campusstylist.backend.application.controller.*
import com.example.campusstylist.backend.domain.model.Service
import com.example.campusstylist.backend.domain.service.*
import com.example.campusstylist.backend.infrastructure.DatabaseConfig
import com.example.campusstylist.backend.infrastructure.repository.*
import com.example.campusstylist.backend.infrastructure.security.JwtConfig
import com.example.campusstylist.backend.infrastructure.table.Services
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.routing.*
import io.ktor.serialization.kotlinx.json.*
import org.jetbrains.exposed.sql.transactions.transaction
import org.slf4j.LoggerFactory
import org.jetbrains.exposed.sql.*

fun main() {
    embeddedServer(Netty, port = 8080, host = "0.0.0.0") {
        install(ContentNegotiation) {
            json()
        }
        install(Authentication, JwtConfig.configureJwt())
        DatabaseConfig.init()
        val userRepository = UserRepository()
        val postRepository = PostRepository()
        val requestRepository = RequestRepository()
        val bookingRepository = BookingRepository()
        val serviceRepository = ServiceRepository()
        val userService = UserService(userRepository)
        val postService = PostService(postRepository)
        val requestService = RequestService(requestRepository)
        val bookingService = BookingService(bookingRepository)
        val serviceService = ServiceService(serviceRepository)

        // Seed services
        val logger = LoggerFactory.getLogger("MainKt")
        try {
            transaction {
                val serviceCount = Services.selectAll().count()
                if (serviceCount == 0L) {
                    logger.info("Seeding Services table...")
                    serviceService.create(Service(name = "Basic Haircut", price = 200.0))
                    serviceService.create(Service(name = "Layered Cut", price = 300.0))
                    serviceService.create(Service(name = "Braids", price = 500.0))
                    serviceService.create(Service(name = "Cornrows", price = 600.0))
                    serviceService.create(Service(name = "Updo", price = 400.0))
                    serviceService.create(Service(name = "Hair Coloring", price = 800.0))
                    serviceService.create(Service(name = "Hair Treatment", price = 700.0))
                    serviceService.create(Service(name = "Extensions", price = 1200.0))
                    logger.info("Services table seeded successfully.")
                } else {
                    logger.info("Services table already contains $serviceCount records.")
                }
            }
        } catch (e: Exception) {
            logger.error("Failed to seed Services table: ${e.message}", e)
            throw RuntimeException("Failed to initialize application due to seeding error", e)
        }

        routing {
            authRoutes(userService)
            userRoutes(userService)
            postRoutes(postService, userService)
            requestRoutes(requestService)
            bookingRoutes(bookingService)
            serviceRoutes(serviceService)
        }
    }.start(wait = true)
}