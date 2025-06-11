package com.example.campusstylist.backend

import com.example.campusstylist.backend.application.controller.*
import com.example.campusstylist.backend.domain.model.Service
import com.example.campusstylist.backend.domain.service.*
import com.example.campusstylist.backend.infrastructure.DatabaseConfig
import com.example.campusstylist.backend.infrastructure.repository.*
import com.example.campusstylist.backend.infrastructure.security.JwtConfig
import com.example.campusstylist.backend.infrastructure.table.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.plugins.statuspages.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.server.http.content.*
import kotlinx.serialization.json.Json
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import org.slf4j.LoggerFactory
import java.io.File

fun main() {
    embeddedServer(Netty, port = 8080, host = "0.0.0.0") {
        module()
    }.start(wait = true)
}

fun Application.module() {
    val logger = LoggerFactory.getLogger("MainKt")

    // Initialize database
    try {
        DatabaseConfig.init()
        logger.info("Database initialized successfully.")
    } catch (e: Exception) {
        logger.error("Failed to initialize database: ${e.message}", e)
        throw RuntimeException("Cannot start application without database connection", e)
    }

    // Create tables if missing
    transaction {
        SchemaUtils.createMissingTablesAndColumns(Users, Posts, Requests, Bookings, Services)
        logger.info("Database schema checked and updated if necessary.")
    }

    // Configure JSON serialization
    install(ContentNegotiation) {
        json(Json {
            prettyPrint = true
            isLenient = true
            ignoreUnknownKeys = true
        })
    }

    // Handle exceptions
    install(StatusPages) {
        exception<IllegalArgumentException> { call, cause ->
            logger.warn("Validation error: ${cause.message}", cause)
            call.respond(
                HttpStatusCode.BadRequest,
                mapOf("error" to "Bad Request", "message" to cause.message)
            )
        }
        exception<Throwable> { call, cause ->
            logger.error("Unhandled error: ${cause.message}", cause)
            call.respond(
                HttpStatusCode.InternalServerError,
                mapOf("error" to "Internal Server Error", "message" to cause.message)
            )
        }
    }

    // Configure JWT authentication
    install(Authentication) {
        JwtConfig.configureJwt().invoke(this)
    }

    // Initialize repositories and services
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

    // Seed services if empty
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
        // Optionally, proceed with a warning instead of crashing
        logger.warn("Proceeding without seeding Services table due to error.")
    }

    // Configure routing
    routing {
        // Serve static files from the uploads directory
        val uploadsDir = File("uploads")
        if (!uploadsDir.exists()) {
            uploadsDir.mkdirs()
            logger.info("Created uploads directory at ${uploadsDir.absolutePath}")
        }
        staticFiles("/uploads", uploadsDir) {
            enableAutoHeadResponse()
        }

        authRoutes(userService)
        userRoutes(userService)
        postRoutes(postService, userService)
        requestRoutes(requestService, userService)
        bookingRoutes(bookingService, userService)
        serviceRoutes(serviceService)
    }
}