import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImage extends StatefulWidget {
  final void Function(File fileImage) onChanged;
  File? img;
  String? url;
  ProfileImage({super.key, required this.onChanged, this.img, this.url});

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        CircleAvatar(
          backgroundImage: widget.img == null
              ? (widget.url == null
                  ? null
                  : CachedNetworkImageProvider(widget.url!) as ImageProvider)
              : FileImage(widget.img!),
          radius: 50,
          child: widget.img != null || widget.url != null
              ? null
              : const Icon(
                  Icons.person_rounded,
                  size: 50,
                ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: IconButton(
            color: Theme.of(context).colorScheme.primary,
            style: IconButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.background.withOpacity(0.5)),
            onPressed: () {
              ImagePicker()
                  .pickImage(
                source: ImageSource.camera,
                preferredCameraDevice: CameraDevice.front,
                imageQuality: 50,
                maxWidth: 200,
              )
                  .then((value) {
                if (value == null) return;
                setState(() => widget.img = File(value.path));
                widget.onChanged(widget.img!);
              });
            },
            icon: const Icon(Icons.camera_rounded),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: IconButton(
              color: Theme.of(context).colorScheme.primary,
              style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .background
                      .withOpacity(0.5)),
              onPressed: () {
                ImagePicker()
                    .pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 50,
                  maxWidth: 200,
                )
                    .then((value) {
                  if (value == null) return;
                  setState(() => widget.img = File(value.path));
                  widget.onChanged(widget.img!);
                });
              },
              icon: const Icon(Icons.image_rounded)),
        )
      ],
    );
  }
}
