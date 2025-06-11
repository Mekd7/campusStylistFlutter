// File: lib/ui/viewmodel/post_detail_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../models/hairdresser_post.dart';

class PostDetailViewModel extends ChangeNotifier {
  final List<HairdresserPost> _posts = [
    HairdresserPost(
      imageUrl: 'https://via.placeholder.com/300',
      serviceName: 'Knotless Goddess Braids',
      length: '16 inches',
      duration: '5 hours',
    ),
    HairdresserPost(
      imageUrl: 'https://via.placeholder.com/300',
      serviceName: 'Straight',
      length: 'Long',
      duration: '3 hours',
    ),
  ];

  List<HairdresserPost> get posts => List.unmodifiable(_posts);

  HairdresserPost? getPostByServiceName(String serviceName) {
    try {
      return _posts.firstWhere((post) => post.serviceName == serviceName);
    } catch (e) {
      return null;
    }
  }

  void deletePost(String serviceName) {
    _posts.removeWhere((post) => post.serviceName == serviceName);
    notifyListeners();
  }
}