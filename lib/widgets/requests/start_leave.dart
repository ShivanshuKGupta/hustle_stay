import 'package:flutter/material.dart';
import 'package:hustle_stay/widgets/other/select_one.dart';
import 'package:intl/intl.dart';

class StartLeave extends StatefulWidget {
  const StartLeave({super.key});

  @override
  State<StartLeave> createState() => _StartLeaveState();
}

class _StartLeaveState extends State<StartLeave> {
  DateTime? selectedDate;
  TextEditingController reasonVal = TextEditingController();
  List<String> reasons = [
    'Internship',
    'Family Emergency',
    'Mid-Sem Break',
    'End-Sem Break',
    'Medical Issue/Emergency',
    'Other-Please specify'
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_month),
            label: selectedDate == null
                ? const Text('Select Dates')
                : Text(DateFormat('yyyy-MM-dd').format(selectedDate!))),
        SelectOne(
          allOptions: reasons.toSet(),
          onChange: (chosenOption) {
            reasonVal.text = chosenOption;
            return true;
          },
        )
        // ,
        // if(reasonVal.text=='Other-Please specify')
      ],
    );
  }
}
