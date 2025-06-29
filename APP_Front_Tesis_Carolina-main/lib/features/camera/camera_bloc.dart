// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:prueba_2/features/history/description_screen.dart';
import 'package:prueba_2/features/history/predict_model.dart';
import 'package:prueba_2/main.dart';

class CameraBloc {
  // Private constructor
  CameraBloc._internal();

  // The single instance
  static final CameraBloc _instance = CameraBloc._internal();

  // Factory constructor returns the same instance
  factory CameraBloc() => _instance;

  Future<void> openCamera(BuildContext context) async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontraron cámaras en este dispositivo.'),
        ),
      );
      return;
    }
    GoRouter.of(context).pushNamed(MainScreen.name, extra: 1);
  }

  Future<void> uploadImage(String imagePath, BuildContext context) async {
    if (!context.mounted) return;
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        (
          X509Certificate cert,
          String host,
          int port,
        ) => true;
    client.connectionTimeout = const Duration(seconds: 30);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8000/predict/'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imagePath,
        filename: p.basename(imagePath),
      ),
    );

    try {
      debugPrint('Enviando solicitud a: ${request.url}');
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.purple,
              strokeWidth: 6.0,
            ),
          );
        },
      );
      var response = await request.send();
      Navigator.of(context).pop();
      debugPrint('Status code: ${response.statusCode}');
      var responseBody = await response.stream.bytesToString();
      debugPrint('Respuesta completa: $responseBody');
      // Cerrar loader
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        // Convertir List<String> a List<Map<String, String>>
        final model = PredictModel.fromJson(data);
        appRouter.pushReplacementNamed(
          DescriptionScreen.name,
          extra: model,
        );
        return;
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Excepción al enviar a ${request.url}: ${response.statusCode}',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excepción al enviar a ${request.url}: $response'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Excepción al enviar a ${request.url}: $e');
      // Cerrar loader en caso de error
      Navigator.of(context).pop();
      debugPrint('Excepción al enviar a ${request.url}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excepción al enviar a ${request.url}: $e'),
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> uploadImageWithResponse(
    String imagePath,
  ) async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) =>
            true; // Permitir certificados autofirmados para el túnel
    client.connectionTimeout = const Duration(seconds: 30);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8000/predict/'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imagePath,
        filename: p.basename(imagePath),
      ),
    );

    try {
      debugPrint('Enviando solicitud a: ${request.url}');
      var response = await request.send();
      debugPrint('Status code: ${response.statusCode}');
      var responseBody = await response.stream.bytesToString();
      debugPrint('Respuesta completa: $responseBody');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(responseBody));
      } else {
        debugPrint('Error: ${response.statusCode} - $responseBody');
        return null;
      }
    } catch (e) {
      debugPrint('Error al enviar a ${request.url}: $e');
      return null;
    }
  }
}
