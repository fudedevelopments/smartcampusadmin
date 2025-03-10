// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'manageusers_bloc.dart';

@immutable
sealed class ManageusersEvent {}


class CreateUserEvent extends ManageusersEvent {
  final String name;
  final String email;
  final String password;
  CreateUserEvent({
    required this.name,
    required this.email,
    required this.password,
  });
 
}
