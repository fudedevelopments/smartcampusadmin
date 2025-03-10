import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smartcampusadmin/createuser/manageuserRepo.dart';
import 'package:smartcampusadmin/utils.dart';

part 'manageusers_event.dart';
part 'manageusers_state.dart';

class ManageusersBloc extends Bloc<ManageusersEvent, ManageusersState> {
  ManageusersBloc() : super(ManageusersInitial()) {
    on<CreateUserEvent>(createUserEvent);
  }

  void createUserEvent(
      CreateUserEvent event, Emitter<ManageusersState> emit) async {
    emit(CreateUsersLoadingState());
    final createusers = await ManageuserMethod().createUser(
        email: event.email, name: event.name, password: event.password);
    handlebloc(
        statuscode: createusers[0],
        success: () {
          emit(CreateUsersSucessState(userId: createusers[1]));
        },
        failure: () {
          emit(CreateUsersFailedState(errors: createusers[1]));
        });
  }
}
