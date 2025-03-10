import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartcampusadmin/createuser/bloc/manageusers_bloc.dart';
import 'package:smartcampusadmin/layout/layout.dart';
import 'package:smartcampusadmin/users/userspage.dart';
import 'package:smartcampusadmin/utils.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Create User"),
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create User",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField("Username", _usernameController),
              const SizedBox(height: 10),
              _buildTextField("Email", _emailController),
              const SizedBox(height: 10),
              _buildTextField("Temporary Password", _passwordController,
                  obscureText: true),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: BlocConsumer<ManageusersBloc, ManageusersState>(
                  listener: (context, state) {
                    if (state is CreateUsersSucessState) {
                      showsnakbar(context, "User Created SuccessFully");
                      navigationpush(context, LayoutPage());
                    }
                    if (state is CreateUsersFailedState) {
                      showsnakbar(context, state.errors);
                    }
                  },
                  builder: (context, state) {
                    if (state is CreateUsersLoadingState) {
                      return Center(child: const CircularProgressIndicator());
                    } else {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          BlocProvider.of<ManageusersBloc>(context).add(
                              CreateUserEvent(
                                  name: _usernameController.text,
                                  email: _emailController.text,
                                  password: _passwordController.text));
                        },
                        child: const Text(
                          "Submit",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
