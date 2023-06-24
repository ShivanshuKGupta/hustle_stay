import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hustle_stay/main.dart';
import 'package:hustle_stay/models/message.dart';
import 'package:hustle_stay/models/user.dart';
import 'package:image_picker/image_picker.dart';

/// Ask the user for an image
/// uploads it on cloud and
/// return the download URL
Future<String?> getLocalImageOnCloud(context,
    {required String fileName}) async {
  const int imageQuality = 50;
  const double maxWidth = double.infinity;
  const double maxHeight = double.infinity;

  File? imageFile = await Navigator.of(context).push<File?>(
    DialogRoute(
      context: context,
      builder: (context) => AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        scrollable: true,
        actionsPadding: const EdgeInsets.all(10),
        buttonPadding: const EdgeInsets.all(20),
        actions: [
          IconButton(
            iconSize: 30,
            onPressed: () async {
              final imagePicker = ImagePicker();
              final pickedImage = await imagePicker.pickImage(
                imageQuality: imageQuality,
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                source: ImageSource.gallery,
              );
              if (pickedImage == null) {
                return;
              }
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop(File(pickedImage.path));
            },
            icon: const Icon(Icons.image_rounded),
          ),
          IconButton(
            iconSize: 30,
            onPressed: () async {
              final imagePicker = ImagePicker();
              final pickedImage = await imagePicker.pickImage(
                imageQuality: imageQuality,
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                source: ImageSource.camera,
              );
              if (pickedImage == null) {
                return;
              }
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop(File(pickedImage.path));
            },
            icon: const Icon(Icons.camera_alt_rounded),
          ),
        ],
      ),
    ),
  );
  return uploadImage(context, imageFile, currentUser.email!, fileName);
}

bool isImage(MessageData msg) {
  RegExp regex = RegExp(r"!\[.*\]\(.*\)");
  return regex.hasMatch(msg.txt);
}

Future<String?> uploadImage(
    context, File? imageFile, String path, String fileName) async {
  if (imageFile == null) return null;
  final downloadURL = await Navigator.of(context).push<String?>(
    DialogRoute(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final ref = storage.ref().child(path).child(fileName);
          final uploadTask = ref.putFile(imageFile);
          return AlertDialog(
            title: const Text('Uploading...'),
            actionsAlignment: MainAxisAlignment.center,
            scrollable: true,
            actionsPadding: const EdgeInsets.all(10),
            buttonPadding: const EdgeInsets.all(20),
            content: Column(
              children: [
                Image.file(imageFile),
                StreamBuilder(
                  stream: uploadTask.snapshotEvents,
                  builder: ((context, snapshot) {
                    if (!snapshot.hasData) {
                      return const LinearProgressIndicator();
                    }
                    if (snapshot.data!.state == TaskState.success) {
                      ref
                          .getDownloadURL()
                          .then((value) => Navigator.of(context).pop(value));
                    }
                    switch (snapshot.data!.state) {
                      case TaskState.paused:
                        return LinearProgressIndicator(
                          value: snapshot.data!.bytesTransferred /
                              snapshot.data!.totalBytes,
                          color: Colors.orange,
                        );
                      case TaskState.running:
                        return LinearProgressIndicator(
                          value: snapshot.data!.bytesTransferred /
                              snapshot.data!.totalBytes,
                        );
                      case TaskState.success:
                        return const LinearProgressIndicator();
                      case TaskState.canceled:
                      case TaskState.error:
                        return LinearProgressIndicator(
                          value: snapshot.data!.bytesTransferred /
                              snapshot.data!.totalBytes,
                          color: Colors.red,
                        );
                    }
                  }),
                ),
              ],
            ),
            actions: [
              StreamBuilder(
                stream: uploadTask.snapshotEvents,
                builder: (ctx, snapshot) {
                  return TextButton.icon(
                    label: Text(uploadTask.snapshot.state == TaskState.paused
                        ? 'Resume'
                        : 'Pause'),
                    onPressed: () {
                      if (uploadTask.snapshot.state == TaskState.paused) {
                        uploadTask.resume();
                      } else {
                        uploadTask.pause();
                      }
                    },
                    icon: Icon(
                      uploadTask.snapshot.state == TaskState.paused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                    ),
                  );
                },
              ),
              TextButton.icon(
                label: const Text('Cancel'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  await uploadTask.cancel();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(null);
                },
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          );
        }),
  );
  return downloadURL;
}
