import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

SizedBox circularProgressIndicator({
  double? height = 16,
  double? width = 16,
}) {
  return SizedBox(
    height: height,
    width: width,
    child: const CircularProgressIndicator(),
  );
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
