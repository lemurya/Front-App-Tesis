// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba_2/features/camera/camera_bloc.dart';
import 'package:prueba_2/features/history/description_screen.dart';
import 'package:prueba_2/features/history/predict_model.dart';
import 'package:prueba_2/main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _imageFile; // To store the taken picture

  bool isEmptyCamera = true;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (v) async {
        final cameras = await availableCameras();
        if (cameras.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cameras found on this device.')),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return MainScreen(initialIndex: 0);
              },
            ),
            ModalRoute.withName('/'),
          );
          return;
        }
        setState(() {
          isEmptyCamera = false;
        });
        _controller = CameraController(
          cameras[0],
          ResolutionPreset.medium,
        );
        _initializeControllerFuture = _controller.initialize();
      },
    );
  }

  final cameraBloc = CameraBloc();
  Future<void> _takePicture() async {
    await _initializeControllerFuture;
    try {
      final XFile image = await _controller.takePicture();
      setState(() => _imageFile = image);
      // Enviar imagen al backend
      final response = await cameraBloc.uploadImageWithResponse(image.path);
      if (response != null) {
        GoRouter.of(
          context,
        ).pushReplacementNamed(
          DescriptionScreen.name,
          extra: PredictModel.fromJson(response),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo procesar la imagen'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Excepción en _takePicture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error Interno del App'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmptyCamera) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Toma una foto')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                CameraPreview(_controller),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 100,
                        height: 150,
                        child: Image.file(
                          File(_imageFile!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FloatingActionButton(
                    onPressed: _takePicture,
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
