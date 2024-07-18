import 'package:meta/meta.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String username;
  final String? avatarUrl;
  final bool hasUnreadNotifications;

  ProfileLoaded({
    required this.username,
    this.avatarUrl,
    required this.hasUnreadNotifications,
  });
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});
}
