package com.example.campusstylist.backend.infrastructure.table

import com.example.campusstylist.backend.domain.model.Role
import org.jetbrains.exposed.sql.Table

object Users : Table() {
    val id = long("id").autoIncrement()
//    val email = varchar("email", 255).uniqueIndex() // Added email as unique identifier
    val username = varchar("username", 255) // Removed uniqueIndex since email is the identifier
    val password = varchar("password", 255)
    val role = enumeration("role", Role::class)
    val profilePicture = text("profile_picture").nullable()
    val bio = text("bio").nullable()
    val name = varchar("name", 255).nullable()
    val hasCreatedProfile = bool("has_created_profile").default(false)
    override val primaryKey = PrimaryKey(id)
}

object Posts : Table() {
    val id = long("id").autoIncrement()
    val userId = long("user_id").references(Users.id)
    val pictureUrl = text("picture_url")
    val description = text("description")
    override val primaryKey = PrimaryKey(id)
}

object Requests : Table() {
    val id = long("id").autoIncrement()
    val clientId = long("client_id").references(Users.id)
    val hairstylistId = long("hairstylist_id").references(Users.id)
    val service = varchar("service", 255)
    val status = varchar("status", 50).default("Pending")
    override val primaryKey = PrimaryKey(id)
}

object Bookings : Table() {
    val id = long("id").autoIncrement()
    val clientId = long("client_id").references(Users.id)
    val hairstylistId = long("hairstylist_id").references(Users.id)
    val service = varchar("service", 255)
    val price = double("price")
    val date = varchar("date", 50) // ISO 8601 format
    val status = varchar("status", 50).default("Pending")
    override val primaryKey = PrimaryKey(id)
}

object Services : Table() {
    val id = long("id").autoIncrement()
    val name = varchar("name", 255)
    val price = double("price")
    override val primaryKey = PrimaryKey(id)
}