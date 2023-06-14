import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  static String? email(String? email) {
    if (email == null || email.isEmpty) return "Email is required";
    if (!(email.contains('@') && email.contains('.'))) {
      return "Enter a valid email";
    }
    return null;
  }

  static String? name(String? name) {
    if (name == null || name.isEmpty) return "Username is required";
    for (final ch in name.characters) {
      if (!(ch.compareTo('a') >= 0 && ch.compareTo('z') <= 0) &&
          !(ch.compareTo('A') >= 0 && ch.compareTo('Z') <= 0) &&
          ch.compareTo(' ') != 0) {
        return "Enter a valid name";
      }
    }
    return null;
  }

  static String? password(String? pwd) {
    if (pwd == null || pwd.isEmpty) return "Password is required";
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
