import 'package:flutter/foundation.dart';
import '../components/footer.dart';

class Post {
  final String serviceName;
  final String? imagePath;

  Post({required this.serviceName, this.imagePath});
}

class PostDetailViewModel extends ChangeNotifier {
  final List<Post> _posts = [
    Post(serviceName: 'Braids', imagePath: 'assets/images/braid.png'),
    // Add more mock posts as needed
  ];

  Post? getPostByServiceName(String serviceName) {
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