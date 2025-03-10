part of 'manageusers_bloc.dart';

@immutable
sealed class ManageusersState {}

final class ManageusersInitial extends ManageusersState {}


class CreateUsersSucessState extends ManageusersState{
    final String userId;

  CreateUsersSucessState({required this.userId});
}

class CreateUsersFailedState extends ManageusersState{
  final String errors;

  CreateUsersFailedState({required this.errors});

}


class CreateUsersLoadingState extends ManageusersState{}
