import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screen/center/center_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CenterCubit extends Cubit<CenterState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CenterCubit() : super(CenterStateLoading());

  void getRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRole = await fetchRoleFromDatabase(user.uid);
      if (userRole == 'Pending') {
        emit(CenterStatePendingApproval());
      } else {
        emit(CenterStateLoaded(userRole));
      }
    } else {
      emit(CenterStateError());
    }
  }

  Future<String> fetchRoleFromDatabase(String uid) async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snapshot.exists) {
      final status = snapshot.data()?['status'];
      if (status == 'approved') {
        return snapshot.data()?['role'] ?? 'Unknown';
      } else {
        return 'Pending';
      }
    } else {
      return 'Unknown';
    }
  }
}

