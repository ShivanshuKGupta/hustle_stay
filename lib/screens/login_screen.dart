import 'package:flutter/material.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:hustle_stay/tools/tools.dart';
import 'package:hustle_stay/tools/user_tools.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "/";
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  User user = User(type: UserType.student);
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadAllUsers();
      SharedPreferences.getInstance().then((prefs) {
        String? userName = prefs.getString('userName');
        String? pwd = prefs.getString('pwd');
        if (userName == null || pwd == null) {
          return;
        }
        print(userName);
        print(pwd);
        user.rollNo = userName;
        user.password = pwd;

        setState(() {
          _loading = true;
        });
        try {
          login(user.rollNo!, user.password!);
        } catch (e) {
          print("got error: $e");
          showMsg(context, e.toString());
          setState(() {
            _loading = false;
          });
          return;
        }
        setState(() {
          _loading = false;
        });
      });
      print('After Build');
    });
  }

  void _login(BuildContext context) {
    if (_formKey.currentState != null) {
      if (!_formKey.currentState!.validate()) return;
      _formKey.currentState!.save();
    }
    setState(() {
      _loading = true;
    });
    try {
      login(user.rollNo!, user.password!);
      Navigator.of(context).pushReplacementNamed(HomePage.routeName);
    } catch (e) {
      print("got error: $e");
      showMsg(context, e.toString());
      setState(() {
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = false;
    });
    // saving state
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('userName', '${user.rollNo}');
      prefs.setString('pwd', '${user.password}');
      print("State saved.");
    });
    if (!context.mounted) return;
    showMsg(context, "Logged In");
    Navigator.of(context).pushReplacementNamed(HomePage.routeName);
  }

  _reset() {
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 30,
                  ),
                  Text('Fetching User Info'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () {
                return _loadAllUsers();
              },
              child: Stack(
                children: [
                  ListView(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            maxLength: 9,
                            decoration: const InputDecoration(
                              label: Text("Roll number"),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return "Roll number cannot be empty";
                              }
                              if (value.length < 9) {
                                return "Length cannot be less than 9";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              user.rollNo = value;
                            },
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                              label: Text("Password"),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password cannot be empty";
                              }
                            },
                            onSaved: (value) {
                              user.password = value;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton.icon(
                                onPressed:
                                    _loading ? null : () => _login(context),
                                icon: const Icon(Icons.login_rounded),
                                label: _loading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator())
                                    : const Text('Login'),
                              ),
                              TextButton.icon(
                                onPressed: _reset,
                                icon: const Icon(Icons.delete),
                                label: const Text('Reset'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _loadAllUsers() async {
    try {
      await fetchAllUsers();
    } catch (e) {
      print("error in fetching users");
      showMsg(context, e.toString());
    }
    setState(() {});
  }
}
