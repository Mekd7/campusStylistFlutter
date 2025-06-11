package com.example.campusstylist.backend.domain.model

enum class Role(val dbValue: Int) {
    CLIENT(0),
    HAIRDRESSER(1);

    companion object {
        fun fromDbValue(value: Int): Role {
            return values().find { it.dbValue == value }
                ?: throw IllegalArgumentException("Invalid role value: $value")
        }
    }
}
