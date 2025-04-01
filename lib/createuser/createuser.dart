import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartcampusadmin/createuser/bloc/manageusers_bloc.dart';
import 'package:smartcampusadmin/layout/layout.dart';
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
  bool _obscurePassword = true;
  bool _isValidEmail = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _hasMinLength = false;

  void _validatePassword(String password) {
    setState(() {
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasMinLength = password.length >= 8;
    });
  }

  void _validateEmail(String email) {
    setState(() {
      _isValidEmail = email.trim().toLowerCase().endsWith('@nandhaengg.org');
    });
  }

  bool get _isPasswordValid =>
      _hasUpperCase &&
      _hasLowerCase &&
      _hasNumber &&
      _hasSpecialChar &&
      _hasMinLength;

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
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Create User",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(28),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.person_add_rounded,
                      size: 28,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Create New User",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter user details to create a new account",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                // Username field
                _buildLabel("Username"),
                const SizedBox(height: 8),
                _buildTextField(
                  "Enter username",
                  _usernameController,
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 24),

                // Email field
                _buildLabel("Email Address"),
                const SizedBox(height: 8),
                _buildTextField(
                  "Enter email address",
                  _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: _validateEmail,
                ),
                const SizedBox(height: 4),
                if (_emailController.text.isNotEmpty && !_isValidEmail)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 14,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Only @nandhaengg.org domain emails are allowed",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                    child: Text(
                      "Only @nandhaengg.org domain emails are allowed",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Password field
                _buildLabel("Temporary Password"),
                const SizedBox(height: 8),
                _buildTextField(
                  "Enter temporary password",
                  _passwordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  onChanged: _validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                // Password requirements
                const SizedBox(height: 16),
                _buildPasswordRequirements(),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: BlocConsumer<ManageusersBloc, ManageusersState>(
                    listener: (context, state) {
                      if (state is CreateUsersSucessState) {
                        showsnakbar(context, "User Created Successfully");
                        navigatorpushandremove(context, LayoutPage());
                      }
                      if (state is CreateUsersFailedState) {
                        showsnakbar(context, state.errors);
                      }
                    },
                    builder: (context, state) {
                      if (state is CreateUsersLoadingState) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _canSubmit()
                              ? () {
                                  BlocProvider.of<ManageusersBloc>(context).add(
                                    CreateUserEvent(
                                      name: _usernameController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    ),
                                  );
                                }
                              : null,
                          child: const Text(
                            "Create User",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }

  bool _canSubmit() {
    return _usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _isPasswordValid &&
        _isValidEmail;
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Password Requirements:",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _buildRequirement("At least 8 characters", _hasMinLength),
        _buildRequirement("At least one uppercase letter (A-Z)", _hasUpperCase),
        _buildRequirement("At least one lowercase letter (a-z)", _hasLowerCase),
        _buildRequirement("At least one number (0-9)", _hasNumber),
        _buildRequirement(
            "At least one special character (!@#\$%^&*)", _hasSpecialChar),
      ],
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isMet ? Colors.green : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
