import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'admin@staff.com');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            // padding: const EdgeInsets.all(32),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  // Перенаправляємо залежно від ролі
                  if (state.role == 'admin' || state.role == 'hr') {
                    context.go('/');
                  } else {
                    context.go('/cabinet');
                  }
                } else if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('StaffFlow HRM', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Пароль', border: OutlineInputBorder()),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976D2), foregroundColor: Colors.white),
                        onPressed: state is AuthLoading 
                            ? null 
                            : () => context.read<AuthCubit>().login(_emailController.text, _passwordController.text),
                        child: state is AuthLoading 
                            ? const CircularProgressIndicator(color: Colors.white) 
                            : const Text('Увійти'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}