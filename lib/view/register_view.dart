import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_app/controller/auth_controller.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  final AuthController auth = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Email Field
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Email is required";
                  }

                  if (!GetUtils.isEmail(value.trim())) {
                    return "Enter a valid email";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// Password Field
              TextFormField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password is required";
                  }

                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              /// Register Button
              Obx(
                () => ElevatedButton(
                  onPressed: auth.isLoading.value
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            bool ok = await auth.register(
                              emailController.text.trim(),
                              passController.text.trim(),
                            );

                            if (ok) {
                              Get.offAllNamed('/todo');
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: auth.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Register"),
                ),
              ),

              const SizedBox(height: 16),

              /// Login navigation
              TextButton(
                onPressed: () => Get.toNamed('/login'),
                child: const Text("Already have account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
