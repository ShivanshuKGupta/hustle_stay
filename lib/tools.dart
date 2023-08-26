import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget which is primarily used to show a [CircularProgressIndicator]
/// in a sizedbox
SizedBox circularProgressIndicator({
  double? height = 16,
  double? width = 16,
}) {
  final widget = Animate(
    onComplete: (controller) {
      controller.repeat();
    },
  ).custom(
      duration: const Duration(seconds: 2), // Adjust the duration as needed
      curve: Curves.linear,
      builder: (context, value, child) {
        final colors = <Color>[
          Colors.blue,
          Colors.red,
          Colors.orange,
          Colors.yellow,
          Colors.green,
          Colors.cyan,
          Colors.indigo,
          Colors.purple,
        ];

        return CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            colors[(value * colors.length).floor() % colors.length],
          ),
        );
      });
  widget.onComplete;
  return SizedBox(
    height: height,
    width: width,
    child: widget,
  );
}

extension StringExtensions on String {
  String toPascalCase() {
    if (isEmpty) return this;

    // Split the string by whitespace and capitalize the first letter of each word
    return split(' ').map((word) {
      if (word.isNotEmpty) {
        return '${word[0].toUpperCase()}${word.substring(1)}';
      }
      return '';
    }).join(' ');
  }
}

/// a widget which works like a clickable link
/// can be used to open a [url]
/// or can be used to initaite a call to [phone]
/// or redirect to whatsapp, if [whatsapp]=true
Widget linkText(
  context, {
  required String title,
  String? url,
  String? phone, // phone number without +91 in the starting
  bool whatsapp = false,
  IconData? icon,
}) {
  // both the url and the phone number can't be null
  // and both the url and the phone number can be specified at the same time
  assert((url == null) ^ (phone == null));
  String newUrl = url ?? "";
  if (phone != null) {
    url = "tel:+91$phone";
  }
  if (whatsapp) {
    url = "wa.me/91$phone";
  }
  return GestureDetector(
    child: ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (rect) {
        return const LinearGradient(colors: [Colors.blue, Colors.deepPurple])
            .createShader(rect);
      },
      child: icon != null
          ? Icon(icon)
          : Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
    ),
    onTap: () {
      launchUrl(Uri.parse(newUrl));
    },
  );
}

/// shows a text in word art, you can customize the colors in it
/// and the text style as well
Widget shaderText(
  BuildContext context, {
  required String title,
  TextStyle? style,
  colors = const [Colors.deepPurpleAccent, Colors.blue],
}) {
  return ShaderMask(
    blendMode: BlendMode.srcATop,
    shaderCallback: (rect) {
      return LinearGradient(colors: colors).createShader(rect);
    },
    child: Text(
      title,
      style: style,
    ),
  );
}

/// shows a quick message with a cross button
void showMsg(BuildContext context, String message, {Icon? icon}) {
  showSnackBar(
    context,
    SnackBar(content: Text(message), showCloseIcon: true),
  );
}

/// clears current snackbar and shows a new one
showSnackBar(BuildContext context, SnackBar snackBar) {
  ScaffoldMessenger.of(context).clearSnackBars();
  return ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Color colorPickerAttendance(String resp) {
  switch (resp) {
    case 'present':
      return Colors.greenAccent;

    case 'absent':
      return Colors.redAccent;

    case 'onInternship':
      return Colors.orangeAccent;

    case 'onLeave':
      return Colors.cyanAccent;

    default:
      return Colors.yellowAccent;
  }
}

/// contains validating functions for input text fields
class Validate {
  static String? email(String? email, {bool required = true}) {
    if (email != null) email = email.trim();
    if (email == null || email.isEmpty) {
      return required ? "Email is required" : null;
    }
    if (!(email.contains('@') && email.contains('.'))) {
      return "Enter a valid email";
    }
    return null;
  }

  static String? name(String? name, {bool required = true}) {
    if (name != null) name = name.trim();
    if (name == null || name.isEmpty) {
      return required ? "Username is required" : null;
    }
    for (final ch in name.characters) {
      if (!(ch.compareTo('a') >= 0 && ch.compareTo('z') <= 0) &&
          !(ch.compareTo('A') >= 0 && ch.compareTo('Z') <= 0) &&
          ch.compareTo(' ') != 0) {
        return "Enter a valid name";
      }
    }
    return null;
  }

  static String? text(String? txt, {bool required = true}) {
    if (txt != null) txt = txt.trim();
    if (txt == null || txt.isEmpty) {
      return required ? "This is required" : null;
    }
    return null;
  }

  static String? phone(String? phoneNumber, {bool required = true}) {
    if (phoneNumber != null) {
      String newPhoneNumber = "";
      for (final ch in phoneNumber.characters) {
        if (ch.compareTo(' ') == 0) continue;
        newPhoneNumber += ch;
      }
      phoneNumber = newPhoneNumber;
    }
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return required ? "Phone Number is required" : null;
    }
    bool firstCharacter = true;
    for (final ch in phoneNumber.characters) {
      if (firstCharacter && ch.compareTo('+') == 0) {
      } else if (!(ch.compareTo('0') >= 0 && ch.compareTo('9') <= 0)) {
        return "Enter a valid number";
      }
      firstCharacter = false;
    }
    return null;
  }

  static String? integer(String? number, {bool required = true}) {
    if (number == null || number.isEmpty) {
      return required ? "This is required" : null;
    }
    for (final ch in number.characters) {
      if (!(ch.compareTo('0') >= 0 && ch.compareTo('9') <= 0)) {
        return "Enter a valid integer";
      }
    }
    return null;
  }

  static String? password(String? pwd, {bool required = true}) {
    if (pwd == null || pwd.isEmpty) {
      return required ? "Password is required" : null;
    }
    bool small = false, big = false, num = false, special = false;
    if (pwd.length < 8) return "Password is too short";
    for (final ch in pwd.characters) {
      if (ch.compareTo('a') >= 0 && ch.compareTo('z') <= 0) {
        small = true;
      } else if (ch.compareTo('A') >= 0 && ch.compareTo('Z') <= 0) {
        big = true;
      } else if (ch.compareTo('0') >= 0 && ch.compareTo('9') <= 0) {
        num = true;
      } else {
        special = true;
      }
    }
    if (!small) {
      return "Password must contain a small letter";
    }
    if (!big) {
      return "Password must contain a capital letter";
    }
    if (!num) {
      return "Password must contain a number";
    }
    if (!special) {
      return "Password must contain a special character";
    }
    return null;
  }
}

/// Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>newPage));
navigatorPush<T>(context, newPage) async {
  return Navigator.of(context)
      .push<T>(MaterialPageRoute(builder: (ctx) => newPage));
}

/// A quick ready-made alertbox with yes/no/cancel etc. buttons
/// This is used to ask user about some quick confirmations or
/// to show him a message
Future<String?> askUser(
  context,
  String msg, {
  String? description,
  bool yes = false,
  bool ok = false,
  bool no = false,
  bool cancel = false,
  List<String> custom = const [],
}) async {
  List<Widget> buttons = [
    if (ok == true)
      TextButton.icon(
        label: const Text("OK"),
        onPressed: () {
          Navigator.of(context).pop("ok");
        },
        icon: const Icon(Icons.check_rounded),
      ),
    if (yes == true)
      TextButton.icon(
        label: const Text("Yes"),
        onPressed: () {
          Navigator.of(context).pop("yes");
        },
        icon: const Icon(Icons.check_rounded),
      ),
    if (no == true)
      TextButton.icon(
        label: const Text("No"),
        onPressed: () {
          Navigator.of(context).pop("no");
        },
        icon: const Icon(Icons.close_rounded),
      ),
    if (cancel == true)
      TextButton.icon(
        label: const Text("Cancel"),
        onPressed: () {
          Navigator.of(context).pop("cancel");
        },
        icon: const Icon(Icons.close_rounded),
      ),
    ...custom.map(
      (e) => TextButton(
        onPressed: () {
          Navigator.of(context).pop(e);
        },
        child: Text(e),
      ),
    ),
  ];
  if (buttons.isEmpty) {
    buttons.add(
      TextButton.icon(
        label: const Text("OK"),
        onPressed: () {
          Navigator.of(context).pop("ok");
        },
        icon: const Icon(Icons.check_rounded),
      ),
    );
  }
  return await Navigator.push(
    context,
    DialogRoute(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(msg),
        content: description != null ? Text(description) : null,
        actions: buttons,
        actionsAlignment: MainAxisAlignment.spaceAround,
      ),
    ),
  );
}

Future<dynamic> loadingIndicator(
  context,
  Future<dynamic> Function() loader,
  String title, {
  String? description,
  bool cancel = false,
}) async {
  bool dialogExists = true;
  List<Widget> buttons = [
    if (cancel == true)
      TextButton.icon(
        label: const Text("Cancel"),
        onPressed: () {
          dialogExists = false;
          Navigator.of(context).pop(null);
        },
        icon: const Icon(Icons.close_rounded),
      ),
  ];
  Navigator.push(
    context,
    DialogRoute(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            circularProgressIndicator(),
            if (description != null) Text(description),
          ],
        ),
        actions: buttons,
        actionsAlignment: MainAxisAlignment.spaceAround,
      ),
    ),
  );
  final ans = await loader();
  if (dialogExists) {
    Navigator.of(context).pop();
  }
  return ans;
}

Future<String?> promptUser(BuildContext context,
    {String? question, String? description}) async {
  String? ans;
  List<Widget> buttons = [
    TextButton.icon(
      label: const Text("Submit"),
      onPressed: () {
        Navigator.of(context).pop(ans);
      },
      icon: const Icon(Icons.check_rounded),
    ),
  ];
  return await Navigator.push(
    context,
    DialogRoute(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (question != null) Text(question),
            if (description != null)
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
        content: TextFormField(
          onChanged: (value) => ans = value,
          decoration: InputDecoration(
            hintText: 'Enter your input here',
            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 1),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          maxLines: 1,
          minLines: 1,
          keyboardType: TextInputType.text,
        ),
        actions: buttons,
        actionsAlignment: MainAxisAlignment.spaceAround,
      ),
    ),
  );
}

String getMonth(int index) {
  late final String month;
  switch (index) {
    case 1:
      month = 'Jan';
      break;
    case 2:
      month = 'Feb';
      break;
    case 3:
      month = 'Mar';
      break;
    case 4:
      month = 'Apr';
      break;
    case 5:
      month = 'May';
      break;
    case 6:
      month = 'June';
      break;
    case 7:
      month = 'July';
      break;
    case 8:
      month = 'Aug';
      break;
    case 9:
      month = 'Sept';
      break;
    case 10:
      month = 'Oct';
      break;
    case 11:
      month = 'Nov';
      break;
    case 12:
      month = 'Dec';
      break;
  }
  return month;
}

/// A function to show date in this format
/// Can have also used intl, but prefered this
String ddmmyyyy(DateTime dateTime) {
  return DateFormat.yMMMMd().format(dateTime);
}

/// A function to show time in a certain format
String timeFrom(DateTime dateTime) {
  return "${dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour < 12 ? 'am' : 'pm'}";
}

/// Glass Widget
class GlassWidget extends StatelessWidget {
  final double radius;
  final Widget child;
  final double blur;
  const GlassWidget(
      {super.key, this.radius = 0, required this.child, this.blur = 15});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      ),
    );
  }
}

List<Color> colorList = const [
  Colors.pinkAccent,
  Colors.purpleAccent,
  Colors.cyanAccent,
  Colors.greenAccent,
  Colors.orangeAccent,
  Colors.blueAccent,
  Colors.deepOrangeAccent,
  Colors.yellowAccent,
  Colors.tealAccent,
  Colors.limeAccent,
  Colors.lightGreenAccent,
  Colors.indigoAccent,
  Colors.deepPurpleAccent,
  Colors.amberAccent
];

Future<Color> showColorPicker(BuildContext context, Color defaultColor) async {
  Color chosenColor = defaultColor;
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Pick a color!'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: defaultColor,
          onColorChanged: (color) => chosenColor = color,
        ),
      ),
      actions: <Widget>[
        ElevatedButton.icon(
          icon: const Icon(Icons.done_rounded),
          label: const Text('Done'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
  return chosenColor;
}
