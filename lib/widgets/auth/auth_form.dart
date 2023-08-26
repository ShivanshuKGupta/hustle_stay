import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/other/loading_elevated_button.dart';

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
  /// TODO: remove the below default values when moving to production
  String _email = kDebugMode ? "code_soc@students.iiitr.ac.in" : '',
      _password = kDebugMode ? "123456" : '';

  final _formkey = GlobalKey<FormState>();

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formkey.currentState!.validate()) return;
    _formkey.currentState!.save();
    await widget.onSubmit(_email.trim(), _password);
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
            validator: (email) => Validate.email(email),
            onChanged: (value) => _email = value,
            onSaved: (value) {
              _email = value!;
            },
          ),

          /// The textfield for Password
          TextFormField(
            key: const ValueKey('pwd'),
            initialValue: _password,
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
          LoadingElevatedButton(
            onPressed: _save,
            icon: const Icon(Icons.login_rounded),
            label: const Text('Login'),
          ),

          /// The textbutton for reset
          LoadingElevatedButton(
            style: TextButton.styleFrom(
              side: BorderSide.none,
              foregroundColor: Colors.blue,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            onPressed: () async {
              _email = _email.trim();
              String? err = Validate.email(_email, required: true);
              if (err != null) {
                showMsg(context, err);
                return;
              }
              if (await askUser(context, 'Send a password reset link for',
                      description: "$_email ?", yes: true, no: true) ==
                  'yes') {
                await auth.sendPasswordResetEmail(email: _email);
              }
            },
            icon: const Icon(Icons.lock_reset_rounded),
            label: const Text('Reset password'),
          ),
        ],
      ),
    );
  }
}
