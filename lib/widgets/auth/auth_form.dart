import 'package:flutter/material.dart';

import 'package:hustle_stay/tools.dart';

/// It is Form made for Authenticating users using email and password
/// Just give it [onSubmit] function and you're ready to go
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

  /// TODO: remove the above default values when moving to production

  /// The form key
  final _formkey = GlobalKey<FormState>();

  /// a laoding var indicating the current state of the form
  bool _loading = false;

  /// This Function is called when the save button is pressed
  void _save() async {
    FocusScope.of(context).unfocus();
    if (!_formkey.currentState!.validate()) return;
    _formkey.currentState!.save();
    setState(() {
      _loading = true;
    });
    try {
      await widget.onSubmit(_email.trim(), _password);
      return;
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
          /// The textfield for email
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

          /// The textfield for Password
          TextFormField(
            key: const ValueKey('pwd'),
            initialValue: _password,
            enabled: !_loading,
            decoration: const InputDecoration(
                icon: Icon(Icons.password_rounded), label: Text('Password')),
            obscureText: true,

            /// no validator is mentioned here because during login password check is not required
            /// validator: (pwd) => Validate.password(pwd),
            onSaved: (value) {
              _password = value!;
            },
          ),
          const SizedBox(height: 10),

          /// The elevated button for save
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

          /// The textbutton for reset
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            onPressed: () {
              // TODO: add a google oauth provider
              showMsg(context, "TODO: add a google oauth provider");
            },
            icon: const Icon(Icons.web),
            label: const Text('Google OAuth Provider'),
          ),
        ],
      ),
    );
  }
}
