class Booking {
  final int? id;
  final int userId;
  final int hairstylistId;
  final String date;
  final String time;
  final String service;

  Booking({
    this.id,
    required this.userId,
    required this.hairstylistId,
    required this.date,
    required this.time,
    required this.service,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int?,
      userId: json['userId'] as int? ?? 0,
      hairstylistId: json['hairstylistId'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      service: json['service'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'hairstylistId': hairstylistId,
      'date': date,
      'time': time,
      'service': service,
    };
  }
}