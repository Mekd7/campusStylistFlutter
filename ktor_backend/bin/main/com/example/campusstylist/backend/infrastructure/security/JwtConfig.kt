package com.example.campusstylist.backend.infrastructure.security

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import java.util.*

object JwtConfig {
    private const val SECRET = "your-secret-key" // Replace with a secure key
    private const val ISSUER = "campusstylist"
    private const val VALIDITY = 24 * 60 * 60 * 1000 // 24 hours in milliseconds

    fun configureJwt(): AuthenticationConfig.() -> Unit = {
        jwt("auth-jwt") {
            verifier(
                JWT.require(Algorithm.HMAC256(SECRET))
                    .withIssuer(ISSUER)
                    .build()
            )
            validate { credential ->
                val email = credential.payload.getClaim("email").asString()
                if (email != null) {
                    JWTPrincipal(credential.payload)
                } else null
            }
        }
    }

    fun generateToken(email: String): String {
        return JWT.create()
            .withIssuer(ISSUER)
            .withClaim("email", email)
            .withExpiresAt(Date(System.currentTimeMillis() + VALIDITY))
            .sign(Algorithm.HMAC256(SECRET))
    }
}