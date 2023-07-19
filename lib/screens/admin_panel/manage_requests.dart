import 'package:flutter/material.dart';

class ManageRequest extends StatefulWidget {
  const ManageRequest({super.key});

  @override
  State<ManageRequest> createState() => _ManageRequestState();
}

class _ManageRequestState extends State<ManageRequest> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Request page'),
      ),
    );
  }
}
