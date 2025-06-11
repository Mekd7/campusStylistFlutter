import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// No 'provider' or 'auth_repository' import needed here.
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/create_profile_screen.dart';
import '../screens/client_home.dart';
import '../screens/hairdresser_home.dart';
import '../screens/client_profile.dart';
import '../screens/hairdresser_profile_screen.dart';
import '../screens/hairdresser_post_detail_screen.dart';
import '../screens/manage_schedule_screen.dart';
import '../screens/orders.dart';
import '../screens/booking_screen.dart' as bookingScreen;
import '../screens/add_booking_screen.dart';
import '../screens/edit_booking_screen.dart';
import '../screens/my_requests_screen.dart';
import '../screens/profile_visit_screen.dart';
import '../screens/post_detail_screen.dart';
import '../screens/edit_profile.dart';
import '../screens/add_post_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(
        onNavigateToSignUp: () => context.go('/signup'),
        onLoginSuccess: (token, isHairdresser, userId) {
          if (isHairdresser) {
            context.go('/hairdresserHome/$token');
          } else {
            context.go('/clientHome/$token');
          }
        },
      ),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => SignUpScreen(
        onNavigateToLogin: () => context.go('/login'),
        onSignupSuccess: (role, hasCreatedProfile, userId, token) {
          final isHairdresser = role.toUpperCase() == 'HAIRDRESSER';
          context.go('/createProfile/$isHairdresser/$token');
        },
      ),
    ),
    GoRoute(
      path: '/createProfile/:isHairdresser/:token',
      builder: (context, state) {
        final isHairdresser = state.pathParameters['isHairdresser'] == 'true';
        final token = state.pathParameters['token'] ?? '';
        return CreateProfileScreen(
          isHairdresser: isHairdresser,
          token: token,
          onProfileCreated: () {
            if (isHairdresser) {
              context.go('/hairdresserHome/$token');
            } else {
              context.go('/clientHome/$token');
            }
          },
        );
      },
    ),
    GoRoute(
      path: '/clientHome/:token',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        return ClientHomeScreen(
          token: token,
          onLogout: () => context.go('/login'),
          onHomeClick: () => context.go('/clientHome/$token'),
          onOrdersClick: () => context.push('/orders/$token'),
          onProfileClick: () => context.push('/clientProfile/$token'),
          onHairdresserProfileClick: (hairdresserId) =>
              context.push('/profileVisit/$token/$hairdresserId'),
        );
      },
    ),
    GoRoute(
      path: '/hairdresserHome/:token',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        return HairdresserHomeScreen(
          token: token,
          onLogout: () => context.go('/login'),
          onHomeClick: () => context.go('/hairdresserHome/$token'),
          onRequestsClick: () => context.push('/myRequests/$token'),
          onScheduleClick: () => context.push('/manageSchedule/$token'),
          onProfileClick: (id) => context.push('/hairdresserProfile/$token/$id'), // Fixed type
        );
      },
    ),
    GoRoute(
      path: '/hairdresserProfile/:token/:hairdresserId',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        final hairdresserId = state.pathParameters['hairdresserId'] ?? '';
        return HairDresserProfileScreen(
          token: token,
          hairdresserId: hairdresserId,
          onHomeClick: () => context.go('/hairdresserHome/$token'),
          onOrdersClick: () => context.go('/myRequests/$token'),
          onProfileClick: () => context.go('/hairdresserProfile/$token/$hairdresserId'),
          onPostClick: (post) => context.push(
            '/hairdresserPostDetail/$token/$hairdresserId/${post.id}/${Uri.encodeComponent(post.pictureUrl)}/${Uri.encodeComponent(post.description)}',
          ),
          navController: (route) => context.push(route),
        );
      },
    ),
    GoRoute(
      path: '/hairdresserPostDetail/:token/:hairdresserId/:postId/:pictureUrl/:description',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        final hairdresserId = state.pathParameters['hairdresserId'] ?? '';
        final postId = int.tryParse(state.pathParameters['postId'] ?? '0') ?? 0;
        final pictureUrl = Uri.decodeComponent(state.pathParameters['pictureUrl'] ?? '');
        final description = Uri.decodeComponent(state.pathParameters['description'] ?? '');
        return HairDresserPostDetailScreen(
          token: token,
          hairdresserId: hairdresserId,
          postId: postId,
          pictureUrl: pictureUrl,
          description: description,
          onHomeClick: () => context.go('/hairdresserHome/$token'),
          onOrdersClick: () => context.go('/myRequests/$token'),
          onProfileClick: () => context.go('/hairdresserProfile/$token/$hairdresserId'),
          onBackClick: () => context.pop(),
        );
      },
    ),
    GoRoute(
      path: '/clientProfile/:token',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        return ClientProfileScreen(
          token: token,
          onLogout: () => context.go('/login'),
          onHomeClick: () => context.go('/clientHome/$token'),
          onOrdersClick: () => context.go('/orders/$token'),
          onProfileClick: () => context.go('/clientProfile/$token'),
          navigateToLogin: () => context.go('/login'),
          onEditProfileClick: () => context.push('/editProfile/$token'),
        );
      },
    ),
    GoRoute(
      path: '/orders/:token',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        return OrderScreen(
          token: token,
          onBackClick: () => context.pop(),
          onHomeClick: () => context.go('/clientHome/$token'),
          onOrdersClick: () => context.go('/orders/$token'),
          onProfileClick: () => context.go('/clientProfile/$token'),
        );
      },
    ),
    GoRoute(
      path: '/manageSchedule/:token',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        return ManageScheduleScreen(
          token: token,
          onLogout: () => context.go('/login'),
          onHomeClick: () => context.go('/hairdresserHome/$token'),
          onRequestsClick: () => context.go('/myRequests/$token'),
          onScheduleClick: () => context.go('/manageSchedule/$token'),
          onProfileClick: (id) => context.go('/hairdresserProfile/$token/$id'), // Fixed type
          navController: (route) => context.push(route),
        );
      },
    ),
    GoRoute(
      path: '/myRequests/:token',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        return MyRequestsScreen(
          token: token,
          onLogout: () => context.go('/login'),
          onHomeClick: () => context.go('/hairdresserHome/$token'),
          onRequestsClick: () => context.go('/myRequests/$token'),
          onScheduleClick: () => context.go('/manageSchedule/$token'),
          onProfileClick: (id) => context.go('/hairdresserProfile/$token/$id'), // Fixed type
        );
      },
    ),
    GoRoute(
      path: '/addBooking/:token',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        return AddBookingScreen(
          onBackClick: () => context.pop(),
          navController: (route) => context.push(route),
        );
      },
    ),
    GoRoute(
      path: '/editBooking/:token',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        return EditBookingScreen(
          token: token,
          onBackClick: () => context.pop(),
          navController: (route) => context.push(route),
        );
      },
    ),
    GoRoute(
      path: '/profileVisit/:token/:hairdresserId',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        final hairdresserId = state.pathParameters['hairdresserId'] ?? '';
        return ProfileVisitScreen(
          token: token,
          onHomeClick: () => context.go('/clientHome/$token'),
          onOrdersClick: () => context.go('/orders/$token'),
          onProfileClick: () => context.go('/clientProfile/$token'),
          onBookClick: () => context.push('/booking/$token/$hairdresserId'),
          navController: (route) => context.push(route),
        );
      },
    ),
    GoRoute(
      path: '/booking/:token/:hairstylistId',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        final hairstylistId = int.tryParse(state.pathParameters['hairstylistId'] ?? '0') ?? 0;
        return bookingScreen.BookingScreen(
          token: token,
          hairstylistId: hairstylistId,
          onBookingConfirmed: () => context.go('/orders/$token'),
          onHomeClick: () => context.go('/clientHome/$token'),
          onOrdersClick: () => context.go('/orders/$token'),
          onProfileClick: () => context.go('/clientProfile/$token'),
        );
      },
    ),
    GoRoute(
      path: '/postDetail/:token/:serviceName/:description',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        final serviceName = Uri.decodeComponent(state.pathParameters['serviceName'] ?? '');
        final description = Uri.decodeComponent(state.pathParameters['description'] ?? '');
        return PostDetailScreen(
          token: token,
          serviceName: serviceName,
          description: description,
          onHomeClick: () => context.go('/clientHome/$token'),
          onOrdersClick: () => context.go('/orders/$token'),
          onProfileClick: () => context.go('/clientProfile/$token'),
          onBackClick: () => context.pop(),
        );
      },
    ),
    GoRoute(
      path: '/editProfile/:token',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        return EditProfileScreen(
          token: token,
          onSaveChanges: (newName, newBio) => context.pop(),
          onBackClick: () => context.pop(),
        );
      },
    ),
    GoRoute(
      path: '/addPost/:token',
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        return AddPostScreen(
          token: token,
          onBackClick: () => context.pop(),
          navController: (route) => context.push(route),
        );
      },
    ),
  ],
);