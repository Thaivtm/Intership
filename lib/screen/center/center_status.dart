abstract class CenterState {}

class CenterStateLoading extends CenterState {}

class CenterStateLoaded extends CenterState {
  final String role;

  CenterStateLoaded(this.role);
}

class CenterStatePendingApproval extends CenterState {}

class CenterStateError extends CenterState {}
