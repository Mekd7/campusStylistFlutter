package com.example.campusstylist.backend.domain.service

import com.example.campusstylist.backend.domain.model.Post
import com.example.campusstylist.backend.infrastructure.repository.PostRepository
import org.jetbrains.exposed.sql.transactions.transaction

class PostService(private val postRepository: PostRepository) {

    fun create(post: Post): Post {
        return transaction {
            postRepository.create(post)
        }
    }

    fun getAll(): List<Post> {
        return transaction {
            postRepository.findAll()
        }
    }

    fun getById(id: Long): Post? {
        return transaction {
            postRepository.findById(id)
        }
    }

    fun update(post: Post): Boolean {
        return transaction {
            postRepository.update(post)
        }
    }

    fun delete(id: Long): Boolean {
        return transaction {
            postRepository.delete(id)
        }
    }
}