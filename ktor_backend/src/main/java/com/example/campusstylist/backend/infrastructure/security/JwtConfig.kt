package com.example.campusstylist.backend.infrastructure.security

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import java.util.concurrent.ConcurrentHashMap
import java.util.*

object JwtConfig {
    private const val SECRET = "mySuperSecretKey1234567890abcdef" // Load from env in production
    private const val ISSUER = "http://localhost:8080/"
    private const val AUDIENCE = "campusstylist-api"
    private const val VALIDITY = 24 * 60 * 60 * 1000 // 24 hours in milliseconds

    // Token blacklist to store invalidated tokens and their expiration times
    private val tokenBlacklist = ConcurrentHashMap<String, Long>()

    fun configureJwt(): AuthenticationConfig.() -> Unit = {
        jwt("auth-jwt") {
            verifier(
                JWT.require(Algorithm.HMAC256(SECRET))
                    .withIssuer(ISSUER)
                    .withAudience(AUDIENCE)
                    .build()
            )
            validate { credential ->
                // Extract the token from the payload's "jti" (JWT ID) claim (if you want to track blacklisting)
                val tokenId = credential.payload.id
                if (tokenId != null) {
                    val isBlacklisted = tokenBlacklist[tokenId]?.let { expiry ->
                        expiry > System.currentTimeMillis()
                    } ?: false

                    if (!isBlacklisted && credential.payload.getClaim("email").asString().isNotEmpty()) {
                        JWTPrincipal(credential.payload)
                    } else {
                        null
                    }
                } else {
                    null
                }
            }
        }
    }

    fun generateToken(email: String): String {
        return JWT.create()
            .withIssuer(ISSUER)
            .withAudience(AUDIENCE)
            .withClaim("email", email)
            .withExpiresAt(Date(System.currentTimeMillis() + VALIDITY))
            .withJWTId(UUID.randomUUID().toString()) // Add a unique ID to track blacklisting
            .sign(Algorithm.HMAC256(SECRET))
    }

    fun verifyToken(token: String): String? {
        return try {
            val verifier = JWT.require(Algorithm.HMAC256(SECRET))
                .withIssuer(ISSUER)
                .withAudience(AUDIENCE)
                .build()
            val decodedJWT = verifier.verify(token)
            decodedJWT.getClaim("email").asString()
        } catch (e: Exception) {
            null
        }
    }

    fun blacklistToken(tokenId: String, expirationTime: Long) {
        tokenBlacklist[tokenId] = expirationTime
    }

    fun isTokenBlacklisted(tokenId: String): Boolean {
        return tokenBlacklist[tokenId]?.let { expiry ->
            expiry > System.currentTimeMillis()
        } ?: false
    }
}