
import 'package:chat/controllers/auth_controoler.dart';
import 'package:chat/routes/app_routes.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formkey = GlobalKey<FormState>();

  final _displaynameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confairmpassword = TextEditingController();

  final AuthController _authController = Get.find<AuthController>();

  bool _obsecurePassword = true;
  bool _obsecretconfairmpassword = true;

  @override
  void dispose() {
    _displaynameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confairmpassword.dispose();
    super.dispose();
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(Icons.arrow_back),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Creat Account",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "fill in your details to get started",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textsecondrycolor,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ===== Name Field =====
                  TextFormField(
                    controller: _displaynameController,
                    decoration: InputDecoration(
                      labelText: "Display name",
                      prefixIcon: const Icon(Icons.person_outline),
                      hintText: "Enter your name",
                      enabledBorder: _buildBorder(AppTheme.bordercolor),
                      focusedBorder: _buildBorder(AppTheme.primecolor),
                      errorBorder: _buildBorder(Colors.red),
                      focusedErrorBorder: _buildBorder(Colors.red),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your name";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ===== Email Field =====
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      hintText: "Enter your email",
                      enabledBorder: _buildBorder(AppTheme.bordercolor),
                      focusedBorder: _buildBorder(AppTheme.primecolor),
                      errorBorder: _buildBorder(Colors.red),
                      focusedErrorBorder: _buildBorder(Colors.red),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      }
                      if (!GetUtils.isEmail(value.trim())) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ===== Password Field =====
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obsecurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: "Enter your password",
                      enabledBorder: _buildBorder(AppTheme.bordercolor),
                      focusedBorder: _buildBorder(AppTheme.primecolor),
                      errorBorder: _buildBorder(Colors.red),
                      focusedErrorBorder: _buildBorder(Colors.red),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obsecurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obsecurePassword = !_obsecurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _confairmpassword,
                    obscureText: _obsecretconfairmpassword,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: "Repeat password",
                      enabledBorder: _buildBorder(AppTheme.bordercolor),
                      focusedBorder: _buildBorder(AppTheme.primecolor),
                      errorBorder: _buildBorder(Colors.red),
                      focusedErrorBorder: _buildBorder(Colors.red),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obsecretconfairmpassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obsecretconfairmpassword =
                                !_obsecretconfairmpassword;
                          });
                        },
                      ),
                    ),
                    onChanged: (_) {
                      _formkey.currentState?.validate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password";
                      }
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _authController.isloading
                                ? null
                                : () {
                                  if (_formkey.currentState?.validate() ??
                                      false) {
                                    _authController
                                        .registerwithemailandpassword(
                                          _emailController.text,
                                          _passwordController.text,
                                          _displaynameController.text,
                                        );
                                  }
                                },
                        child:
                            _authController.isloading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text("Creat Account"),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppTheme.bordercolor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "OR",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Expanded(child: Divider(color: AppTheme.bordercolor)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.login),
                        child: Text(
                          " Sign In",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primecolor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
