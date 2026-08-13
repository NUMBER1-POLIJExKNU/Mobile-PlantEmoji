import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'api_service.dart';

class CameraScreen extends StatefulWidget {
  final ApiService apiService;

  const CameraScreen({super.key, required this.apiService});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _loading = true;
  bool _scanning = false;
  String? _error;
  String? _result;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw StateError('No camera was found on this device.');
      }
      final camera = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _loading = false;
      });
    } on CameraException catch (error) {
      _showInitializationError(
        error.code == 'CameraAccessDenied'
            ? 'Camera permission was denied. Allow camera access and reload.'
            : 'Camera error: ${error.description ?? error.code}',
      );
    } catch (error) {
      _showInitializationError(error.toString());
    }
  }

  void _showInitializationError(String message) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = message;
    });
  }

  Future<Uint8List> _prepareJpeg(Uint8List bytes) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null)
      throw StateError('The captured image could not be read.');

    img.Image resized = decoded;
    if (decoded.width > 720 || decoded.height > 720) {
      resized = decoded.width >= decoded.height
          ? img.copyResize(decoded, width: 720)
          : img.copyResize(decoded, height: 720);
    }

    for (final quality in [72, 60, 48, 36]) {
      final encoded = Uint8List.fromList(
        img.encodeJpg(resized, quality: quality),
      );
      if (encoded.length <= 195 * 1024) return encoded;
    }
    final compact = img.copyResize(resized, width: 480);
    return Uint8List.fromList(img.encodeJpg(compact, quality: 32));
  }

  Future<void> _captureAndScan() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _scanning)
      return;

    setState(() {
      _scanning = true;
      _error = null;
      _result = null;
    });
    try {
      final photo = await controller.takePicture();
      final jpeg = await _prepareJpeg(await photo.readAsBytes());
      if (jpeg.length > 200 * 1024) {
        throw StateError(
          'The photo is still too large. Move closer and try again.',
        );
      }
      final scan = await widget.apiService.scanPlant(base64Encode(jpeg));
      if (!mounted) return;
      setState(() {
        _result = scan.ok ? scan.message : null;
        _error = scan.ok ? null : scan.message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Scan failed: $error');
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _controller == null) {
      return _CameraMessage(
        icon: Icons.no_photography,
        message: _error!,
        buttonLabel: 'Try again',
        onPressed: () {
          setState(() {
            _loading = true;
            _error = null;
          });
          _initializeCamera();
        },
      );
    }

    final controller = _controller!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: ColoredBox(
                color: Colors.black,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CameraPreview(controller),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_result != null)
            _ResultCard(message: _result!, isError: false)
          else if (_error != null)
            _ResultCard(message: _error!, isError: true)
          else
            const Text(
              'Point the camera at the plant, then capture one photo for AI advice.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _scanning ? null : _captureAndScan,
              icon: _scanning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt),
              label: Text(_scanning ? 'Scanning…' : 'Capture & Scan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String message;
  final bool isError;

  const _ResultCard({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isError ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 9),
      ),
    );
  }
}

class _CameraMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _CameraMessage({
    required this.icon,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
