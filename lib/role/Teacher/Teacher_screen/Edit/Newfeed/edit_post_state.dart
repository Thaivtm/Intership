import 'package:meta/meta.dart';

@immutable
abstract class EditPostState {}

class EditPostInitial extends EditPostState {}

class EditPostLoading extends EditPostState {}

class EditPostLoaded extends EditPostState {
  final String content;

  EditPostLoaded({required this.content});
}

class EditPostUpdated extends EditPostState {}

class EditPostError extends EditPostState {
  final String message;

  EditPostError({required this.message});
}
