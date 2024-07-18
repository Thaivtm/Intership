// profile_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/role/Teacher/Profie/notification/notification.dart';
import 'package:flutter_application_1/role/Teacher/Profie/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileCubit() : super(ProfileInitial());

  void getCurrentUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchUserData(user.uid);
      }
    });
  }

  Future<void> fetchUserData(String uid) async {
    try {
      emit(ProfileLoading());
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        String username = userDoc['user_Name'];
        String? avatarUrl = userDoc['avatar'];
        bool hasUnreadNotifications = await NotiTeacher.hasUnreadNotifications(_firestore, uid);
        emit(ProfileLoaded(username: username, avatarUrl: avatarUrl, hasUnreadNotifications: hasUnreadNotifications));
      } else {
        emit(ProfileError(message: 'User data not found'));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> refreshProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await fetchUserData(user.uid);
    }
  }
}
