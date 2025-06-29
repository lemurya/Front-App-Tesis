// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prueba_2/features/camera/camera_bloc.dart';

class HomeScreen extends StatefulWidget {
  final Function() onTapCamera;
  const HomeScreen({super.key, required this.onTapCamera});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final cameraBloc = CameraBloc();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 50,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ElevatedButton.icon(
            onPressed: widget.onTapCamera,
            icon: const Icon(Icons.camera_alt, size: 34, color: Colors.white),
            label: const Text(
              'Identificar',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.all(20),
              minimumSize: const Size(300, 100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await upLoadimageProccess(context);
            },
            icon: const Icon(Icons.upload, size: 34, color: Colors.white),
            label: const Text(
              'Subir',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[300],
              padding: const EdgeInsets.all(20),
              minimumSize: const Size(300, 100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> upLoadimageProccess(BuildContext context) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      await cameraBloc.uploadImage(pickedFile.path, context);
    }
  }
}
