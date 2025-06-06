import 'package:flutter/material.dart';
import '../models/post.dart';

class ClientHomeViewModel extends ChangeNotifier {
  final List<Post> _posts = [
    Post(
      hairdresserName: 'Ashley Gram',
      imagePath: 'assets/images/braid.jpg',
      hairdresserId: 'hairdresser1',
    ),
    Post(
      hairdresserName: 'Jane Doe',
      imagePath: 'assets/images/straight.jpg',
      hairdresserId: 'hairdresser2',
    ),
    Post(
      hairdresserName: 'Emma Smith',
      imagePath: 'assets/images/braid.jpg',
      hairdresserId: 'hairdresser3',
    ),
  ];

  List<Post> get posts => _posts;

  ClientHomeViewModel() {
    // Mock data already initialized in _posts
  }
}