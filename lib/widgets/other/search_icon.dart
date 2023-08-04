import 'package:flutter/material.dart';
import 'package:hustle_stay/tools.dart';

// ignore: must_be_immutable
class SearchIconWidget extends StatefulWidget {
  IconData? icon;
  final void Function(IconData icon) onChange;
  SearchIconWidget({super.key, required this.onChange, this.icon});

  @override
  State<SearchIconWidget> createState() => _SearchIconWidgetState();
}

class _SearchIconWidgetState extends State<SearchIconWidget> {
  final _txtController = TextEditingController();

  int? searchNumber;

  @override
  void initState() {
    super.initState();
    searchNumber = widget.icon == null
        ? Icons.category_rounded.codePoint
        : widget.icon!.codePoint;
    _txtController.text = searchNumber!.toRadixString(16);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose an icon'),
      actions: [
        TextField(
          controller: _txtController,
          onChanged: (value) {
            setState(() {
              searchNumber = int.tryParse(value.trim(), radix: 16);
              if (searchNumber != null && (searchNumber! < 0)) {
                searchNumber = null;
              }
            });
          },
          decoration: InputDecoration(
            hintText: 'Search Icon with HexCode',
            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 1),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          keyboardType: TextInputType.text,
        ),
        linkText(
          context,
          title: 'List of all icons with indexes',
          url: 'https://api.flutter.dev/flutter/material/Icons-class.html',
        ),
      ],
      content: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 120,
        ),
        itemCount: searchNumber == null ? 4096 : 1,
        itemBuilder: (context, index) {
          if (searchNumber == null) {
            return TextButton.icon(
              label: Text(index.toRadixString(16).padLeft(3)),
              onPressed: () {
                widget.icon = IconData(index, fontFamily: Icons.abc.fontFamily);
                widget.onChange(widget.icon!);
              },
              icon: Icon(
                IconData(
                  index,
                  fontFamily: Icons.abc.fontFamily,
                ),
              ),
            );
          } else {
            return TextButton.icon(
              label: Text((searchNumber!.toRadixString(16)).padLeft(3)),
              onPressed: () {
                widget.icon =
                    IconData(searchNumber!, fontFamily: Icons.abc.fontFamily);
                widget.onChange(widget.icon!);
              },
              icon: Icon(
                IconData(
                  searchNumber!,
                  fontFamily: Icons.abc.fontFamily,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
