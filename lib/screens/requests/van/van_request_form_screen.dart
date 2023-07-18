import 'package:flutter/material.dart';
import 'package:hustle_stay/models/requests/van/van_request.dart';
import 'package:hustle_stay/tools.dart';
import 'package:hustle_stay/widgets/complaints/select_one.dart';
import 'package:hustle_stay/widgets/requests/grid_tile_logo.dart';

class VanRequestFormScreen extends StatefulWidget {
  final String title;
  final Icon icon;
  VanRequest? request;
  VanRequestFormScreen({
    super.key,
    required this.title,
    required this.icon,
    this.request,
  });

  @override
  State<VanRequestFormScreen> createState() => _VanRequestFormScreenState();
}

class _VanRequestFormScreenState extends State<VanRequestFormScreen> {
  @override
  void initState() {
    super.initState();
    widget.request ??= VanRequest();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GridTileLogo(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      title: widget.title,
                      icon: widget.icon,
                      color: theme.colorScheme.background,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                OutlinedButton.icon(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1997),
                      lastDate: DateTime.now(),
                    );
                  },
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: const Text('Which day?'),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () {
                    showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                  },
                  icon: const Icon(Icons.access_time_rounded),
                  label: const Text('When?'),
                ),
                const SizedBox(height: 20),
                SelectOne(
                  title: 'Reason?',
                  subtitle: '(optional)',
                  allOptions: const [
                    'Train Arrival',
                    'Train Departure',
                    'Other'
                  ],
                  onChange: (value) {
                    return true;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Please specify the reason here',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  maxLines: null,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    showMsg(context, 'Submitting a request');
                  },
                  icon: const Icon(Icons.done),
                  label: const Text('Post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
