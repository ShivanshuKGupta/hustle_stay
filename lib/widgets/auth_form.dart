import 'package:flutter/material.dart';

import '../tools.dart';

class AuthForm extends StatefulWidget {
  final Future<void> Function(
    String email,
    String password,
  ) onSubmit;
  const AuthForm({super.key, required this.onSubmit});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  String _email = "code_soc@students.iiitr.ac.in", _password = "123456";
  // TODO: remove the above default values when moving to production
  final _formkey = GlobalKey<FormState>();

  bool _loading = false;

  void _save() async {
    FocusScope.of(context).unfocus();
    if (!_formkey.currentState!.validate()) return;
    _formkey.currentState!.save();
    setState(() {
      _loading = true;
    });
    try {
      await widget.onSubmit(_email.trim(), _password);
    } catch (e) {
      showMsg(context, e.toString());
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            key: const ValueKey('email'),
            initialValue: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              icon: const Icon(Icons.email_rounded),
              iconColor: Theme.of(context).colorScheme.onBackground,
              label: const Text('Email'),
            ),
            enabled: !_loading,
            validator: (email) => Validate.email(email),
            onSaved: (value) {
              _email = value!;
            },
          ),
          TextFormField(
            key: const ValueKey('pwd'),
            initialValue: _password,
            enabled: !_loading,
            decoration: const InputDecoration(
                icon: Icon(Icons.password_rounded), label: Text('Password')),
            obscureText: true,
            // no validator is mentioned here because during login password check is not required
            // validator: (pwd) => Validate.password(pwd),
            onSaved: (value) {
              _password = value!;
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _loading ? null : _save,
            icon: const Icon(
              Icons.login_rounded,
            ),
            label: _loading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(),
                  )
                : const Text('Login'),
          ),
        ],
      ),
    );
  }
}
