import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../models/user.dart'; // Make sure User model is imported if needed for constructor
import '../services/api_service.dart';

class ClientHomeViewModel extends ChangeNotifier {
  List<Post> _posts = [];
  List<Post> get posts => _posts;

  Map<String, String> _userNames = {};
  Map<String, String> get userNames => _userNames;

  final ApiService _apiService;

  ClientHomeViewModel(this._apiService);

  Future<void> fetchData({String? token}) async {
    try {
      if (token == null) throw Exception('Token required');
      _posts = await _apiService.getAllPosts(token);
      for (var post in _posts) {
        if (!_userNames.containsKey(post.userId.toString())) {
          final user = await _apiService.getUserById(post.userId.toString(), token);
          _userNames[post.userId.toString()] = user.username ?? 'Hairdresser ${post.userId}';
        }
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data for Client Home, using dummy data: $e');
      }

      // --- DUMMY DATA TO MATCH NEW DESIGN ---
      const imageUrl = 'https://cdn.shopify.com/s/files/1/0641/2831/9725/files/what_are_bohemian_braids.webp?v=1747219302';

      _posts = [
        Post(id: 1, userId: 123, pictureUrl: imageUrl, description: 'Bohemian Braids'),
        Post(id: 2, userId: 456, pictureUrl: imageUrl, description: 'Summer Styles'),
        Post(id: 3, userId: 789, pictureUrl: imageUrl, description: 'Weekend Looks'),
      ];
      _userNames = {
        '123': 'Ashley Gram',
        '456': 'Jessica Doe',
        '789': 'Sarah Bee',
      };
      notifyListeners();
    }
  }
}