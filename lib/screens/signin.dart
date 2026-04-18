import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/services/auth.dart';
import 'package:pokedex/screens/register.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninState();
}

class _SigninState extends State<SigninPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final Color pokeRed = const Color(0xFFE3350D);
  final Color darkCharcoal = const Color(0xFF313131);
  final Color waterBlue = const Color(0xFF30A7D7);
  final Color offWhite = const Color(0xFFF2F2F2);
  final Color oliveGreen = const Color(0xFF808000);

  Future<void> _signin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final auth = context.read<AuthService>();
    final result = await auth.signin(username, password);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Go back to home page (already logged in via Provider)
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Sign In Failed'),
            content: Text(result['message']),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhite,
      appBar: AppBar(
        title: const Text('SIGN IN', style: TextStyle(color: Colors.white)),
        backgroundColor: pokeRed,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: oliveGreen, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('SIGN IN',
                      style: TextStyle(fontSize: 24, color: darkCharcoal, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _signin(),
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? CircularProgressIndicator(color: pokeRed)
                      : ElevatedButton(
                          onPressed: _signin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: oliveGreen,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('SIGN IN'),
                        ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                    child: Text('Register New Trainer', style: TextStyle(color: waterBlue)),
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