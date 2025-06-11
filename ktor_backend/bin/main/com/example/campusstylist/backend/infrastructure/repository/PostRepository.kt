package com.example.campusstylist.backend.infrastructure.repository

import com.example.campusstylist.backend.domain.model.Post
import com.example.campusstylist.backend.infrastructure.table.Posts
import org.jetbrains.exposed.sql.*
//import org.jetbrains.exposed.sql.op.Op
import org.jetbrains.exposed.sql.transactions.transaction

class PostRepository {
    fun create(post: Post): Post = transaction {
        val id = Posts.insert {
            it[userId] = post.userId
            it[pictureUrl] = post.pictureUrl
            it[description] = post.description
        } get Posts.id
        post.copy(id = id)
    }

    fun findAll(): List<Post> = transaction {
        Posts.selectAll().map {
            Post(
                id = it[Posts.id],
                userId = it[Posts.userId],
                pictureUrl = it[Posts.pictureUrl],
                description = it[Posts.description]
            )
        }
    }

    fun findById(id: Long): Post? = transaction {
        Posts.select { Op.build { Posts.id eq id } }
            .map {
                Post(
                    id = it[Posts.id],
                    userId = it[Posts.userId],
                    pictureUrl = it[Posts.pictureUrl],
                    description = it[Posts.description]
                )
            }
            .singleOrNull()
    }

    fun update(post: Post): Boolean = transaction {
        post.id?.let {
            Posts.update({ Op.build { Posts.id eq it } }) {
                it[pictureUrl] = post.pictureUrl
                it[description] = post.description
            } > 0
        } ?: false
    }

    fun delete(id: Long): Boolean = transaction {
        Posts.deleteWhere { Op.build { Posts.id eq id } } > 0
    }
}