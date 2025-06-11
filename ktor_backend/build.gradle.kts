plugins {
    application
    alias(libs.plugins.jetbrains.kotlin.jvm)
    alias(libs.plugins.kotlinx.serialization)
    id("io.ktor.plugin") version "2.3.12"
}

application {
    mainClass.set("com.example.campusstylist.backend.MainKt")
}

dependencies {
    implementation("org.mindrot:jbcrypt:0.4")
    implementation("io.ktor:ktor-server-status-pages:2.3.12")
    implementation(libs.ktor.server.core)
    implementation(libs.ktor.server.netty)
    implementation(libs.ktor.server.content.negotiation)
    implementation(libs.ktor.serialization.kotlinx.json)
    implementation(libs.logback.classic)
    implementation(libs.exposed.core)
    implementation(libs.exposed.jdbc)
    implementation(libs.postgresql)
    implementation(libs.ktor.server.auth)
    implementation(libs.ktor.server.auth.jwt)
    implementation(libs.hikari)
    implementation(libs.java.jwt)
    testImplementation(libs.junit)
    testImplementation(libs.ktor.server.tests)
    implementation("com.auth0:java-jwt:4.4.0")
}