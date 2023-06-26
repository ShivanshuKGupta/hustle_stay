import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final Future<void> Function(BuildContext)? delete;
  final Future<void> Function(BuildContext)? copy;
  final void Function(BuildContext)? info;
  final Widget image;
  const ImagePreview(
      {super.key, this.delete, this.copy, this.info, required this.image});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (delete != null)
            IconButton(
              onPressed: () => delete!(context),
              icon: const Icon(Icons.delete_rounded),
            ),
          if (copy != null)
            IconButton(
              onPressed: () => copy!(context),
              icon: const Icon(Icons.copy_rounded),
            ),
          if (info != null)
            IconButton(
              onPressed: () => info!(context),
              icon: const Icon(Icons.info_outline_rounded),
            ),
        ],
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: InteractiveViewer(
          maxScale: 5,
          child: image,
        ),
      ),
    );
  }
}
