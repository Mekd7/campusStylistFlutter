package com.example.campusstylist.backend.application.controller

import io.ktor.http.content.*
import org.slf4j.LoggerFactory
import java.io.File
import java.util.*

suspend fun handleFileUpload(part: PartData.FileItem): String? {
    val logger = LoggerFactory.getLogger("FileUploadUtils")
    try {
        val fileName = part.originalFileName ?: return null
        val extension = fileName.substringAfterLast(".", "").lowercase()
        if (extension !in listOf("jpg", "jpeg", "png")) {
            logger.warn("Unsupported file type: $extension")
            return null // Only allow specific image types
        }
        val uniqueFileName = "${UUID.randomUUID()}.$extension" // Prevent name collisions
        val fileBytes = part.streamProvider().readBytes()
        return saveFile(uniqueFileName, fileBytes)
    } catch (e: Exception) {
        logger.error("Error uploading file: ${e.message}", e)
        throw e
    }
}

suspend fun saveFile(fileName: String, fileBytes: ByteArray): String {
    val logger = LoggerFactory.getLogger("FileUploadUtils")
    try {
        val dir = File("uploads")
        if (!dir.exists()) {
            logger.info("Creating uploads directory: ${dir.absolutePath}")
            dir.mkdirs()
        }
        val file = File(dir, fileName)
        file.writeBytes(fileBytes)
        logger.debug("File saved: ${file.absolutePath}")
        return "/uploads/$fileName" // Return relative URL path
    } catch (e: Exception) {
        logger.error("Error saving file $fileName: ${e.message}", e)
        throw e
    }
}