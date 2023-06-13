import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImage extends StatefulWidget {
  final void Function(File fileImage) onChanged;
  const ProfileImage({super.key, required this.onChanged});

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  XFile? _pickedImage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        CircleAvatar(
          backgroundImage:
              _pickedImage == null ? null : FileImage(File(_pickedImage!.path)),
          radius: 50,
          child: _pickedImage != null
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
                maxWidth: 140,
              )
                  .then((value) {
                if (value == null) return;
                setState(() => _pickedImage = value);
                widget.onChanged(File(_pickedImage!.path));
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
                        preferredCameraDevice: CameraDevice.front)
                    .then((value) {
                  if (value == null) return;
                  setState(() => _pickedImage = value);
                });
              },
              icon: const Icon(Icons.image_rounded)),
        )
      ],
    );
  }
}
