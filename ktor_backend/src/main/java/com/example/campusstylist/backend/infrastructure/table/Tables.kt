package com.example.campusstylist.backend.infrastructure.table

import com.example.campusstylist.backend.domain.model.Role
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.dao.id.LongIdTable

object Users : Table() {
    val id = long("id").autoIncrement()
    val email = varchar("email", 255).uniqueIndex()
    val username = varchar("username", 255).uniqueIndex().nullable()
    val password = varchar("password", 255)
    val role = integer("role") // Changed to integer to match Role.dbValue
    val profilePicture = text("profile_picture").nullable()
    val bio = text("bio").nullable()
    val name = varchar("name", 255).nullable()
    val hasCreatedProfile = bool("has_created_profile").default(false)
    override val primaryKey = PrimaryKey(id)
}

object Bookings : Table() {
    val id = long("id").autoIncrement()
    val clientId = long("client_id") references Users.id
    val hairstylistId = long("hairstylist_id") references Users.id
    val service = varchar("service", 255)
    val price = double("price")
    val date = varchar("date", 50)
    val status = varchar("status", 50)
    val username = varchar("username", 255).nullable()
    override val primaryKey = PrimaryKey(id)
}

object Requests : Table() {
    val id = long("id").autoIncrement()
    val clientId = long("client_id") references Users.id
    val hairstylistId = long("hairstylist_id") references Users.id
    val service = varchar("service", 255)
    val status = varchar("status", 50)
    val username = varchar("username", 255).nullable()
    override val primaryKey = PrimaryKey(id)
}

object Posts : LongIdTable() {
    val userId = long("user_id") references Users.id
    val pictureUrl = text("picture_url")
    val description = text("description")
}


object Services : Table() {
    val id = long("id").autoIncrement()
    val name = varchar("name", 255).uniqueIndex()
    override val primaryKey = PrimaryKey(id)
    val price = double("price")
}