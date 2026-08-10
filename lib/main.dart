import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

final AudioManager audioManager = AudioManager();

class AudioManager {
  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<bool> muted = ValueNotifier<bool>(false);

  Future<void> init() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setSource(AssetSource('music/backsound-smartfarm.mp3'));
      await _player.setVolume(1.0);
      await _player.resume();
    } catch (_) {
      // Ignore audio initialization failures.
    }
  }

  Future<void> toggleMute() async {
    final shouldMute = !muted.value;
    muted.value = shouldMute;
    await _player.setVolume(shouldMute ? 0.0 : 1.0);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await audioManager.init();
  runApp(const TamagotchiApp());
}

class TamagotchiApp extends StatelessWidget {
  const TamagotchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tamagotchi Dashboard',
      theme: ThemeData(primarySwatch: Colors.pink, fontFamily: 'Courier'),
      home: const TamagotchiDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyApp extends TamagotchiApp {
  const MyApp({super.key});
}

class TamagotchiDashboard extends StatelessWidget {
  const TamagotchiDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE4F2),
      body: SafeArea(
        child: TamagotchiBackground(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: tamagotchiCaseDecoration(),
                padding: const EdgeInsets.all(24),
                child: Container(
                  decoration: tamagotchiScreenDecoration(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: DottedYellowPainter(),
                                ),
                              ),
                              const Center(child: TopActionIcons()),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: CheckerboardPainter(),
                                ),
                              ),
                              const Center(child: AnimatedPixelCharacter()),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: DottedYellowPainter(
                                    reverseFlowers: true,
                                  ),
                                ),
                              ),
                              const Center(child: FooterNavigation()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TamagotchiBackground extends StatelessWidget {
  final Widget child;

  const TamagotchiBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 16,
          left: 16,
          child: Opacity(
            opacity: 0.85,
            child: Image.asset(
              'assets/design/cloud1.png',
              width: 96,
              height: 96,
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 22,
          child: Opacity(
            opacity: 0.85,
            child: Image.asset(
              'assets/design/butterfly.png',
              width: 88,
              height: 88,
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 34,
          child: Opacity(
            opacity: 0.85,
            child: Image.asset('assets/design/love.png', width: 74, height: 74),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: ValueListenableBuilder<bool>(
            valueListenable: audioManager.muted,
            builder: (context, isMuted, child) {
              return GestureDetector(
                onTap: audioManager.toggleMute,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.pink.shade200, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset('assets/music/music-logo.png', width: 42, height: 42),
                      if (isMuted)
                        Transform.rotate(
                          angle: -0.4,
                          child: Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        child,
      ],
    );
  }
}

BoxDecoration tamagotchiCaseDecoration() {
  return BoxDecoration(
    color: const Color(0xFFE56997),
    borderRadius: BorderRadius.circular(40),
    border: Border.all(color: const Color(0xFFD04A7B), width: 6),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 20,
        offset: const Offset(10, 10),
      ),
    ],
  );
}

BoxDecoration tamagotchiScreenDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.grey.shade400, width: 2),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 5,
        offset: const Offset(2, 2),
      ),
    ],
  );
}

class TopActionIcons extends StatelessWidget {
  const TopActionIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(Icons.restaurant, size: 36, color: Colors.black87),
        Icon(Icons.lightbulb_outline, size: 36, color: Colors.black87),
        Icon(Icons.sports_baseball, size: 36, color: Colors.black87),
        Icon(Icons.vaccines, size: 36, color: Colors.black87),
      ],
    );
  }
}

class FooterNavigation extends StatelessWidget {
  const FooterNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        FooterIconButton(
          assetPath: 'assets/logo/home.png',
          tooltip: 'Home',
          page: FooterPage(title: 'Home'),
        ),
        FooterIconButton(
          assetPath: 'assets/logo/camera.png',
          tooltip: 'Camera',
          page: CameraDetectionPage(),
        ),
        FooterIconButton(
          assetPath: 'assets/logo/inventory.png',
          tooltip: 'Inventory',
          page: FooterPage(title: 'Inventory'),
        ),
        FooterIconButton(
          assetPath: 'assets/logo/chara.png',
          tooltip: 'Character',
          page: FooterPage(title: 'Character'),
        ),
      ],
    );
  }
}

class FooterIconButton extends StatefulWidget {
  final String assetPath;
  final String tooltip;
  final Widget page;

  const FooterIconButton({
    super.key,
    required this.assetPath,
    required this.tooltip,
    required this.page,
  });

  @override
  State<FooterIconButton> createState() => _FooterIconButtonState();
}

class _FooterIconButtonState extends State<FooterIconButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => widget.page));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 68,
          height: 68,
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..scaleByDouble(
              _hovering ? 1.06 : 1.0,
              _hovering ? 1.06 : 1.0,
              1,
              1,
            ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: [
              if (_hovering)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
            border: Border.all(
              color: _hovering
                  ? Colors.pink.shade200.withValues(alpha: 0.9)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Tooltip(
            message: widget.tooltip,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(widget.assetPath, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

class CameraDetectionPage extends StatefulWidget {
  const CameraDetectionPage({super.key});

  @override
  State<CameraDetectionPage> createState() => _CameraDetectionPageState();
}

class _CameraDetectionPageState extends State<CameraDetectionPage> {
  final EnvironmentClassifier _classifier = EnvironmentClassifier();

  CameraController? _cameraController;
  DetectionResult? _latestResult;
  DateTime _lastInferenceAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _booting = true;
  bool _detecting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_openCamera());
  }

  Future<void> _openCamera() async {
    try {
      await _classifier.load();

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('noCamera', 'No camera found on this device.');
      }

      final camera = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();
      await controller.startImageStream(_handleCameraImage);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _booting = false;
      });
    } on CameraException catch (error) {
      _showCameraError(error.description ?? error.code);
    } catch (error) {
      _showCameraError(error.toString());
    }
  }

  void _showCameraError(String message) {
    if (!mounted) {
      return;
    }

    setState(() {
      _booting = false;
      _errorMessage = message;
    });
  }

  void _handleCameraImage(CameraImage image) {
    final now = DateTime.now();
    if (_detecting ||
        now.difference(_lastInferenceAt) < const Duration(milliseconds: 850)) {
      return;
    }

    _detecting = true;
    _lastInferenceAt = now;

    unawaited(() async {
      try {
        final result = await _classifier.classify(
          image,
          rotation: _cameraController?.description.sensorOrientation ?? 0,
        );

        if (mounted) {
          setState(() => _latestResult = result);
        }
      } catch (error) {
        if (mounted && _latestResult == null) {
          setState(() => _errorMessage = 'Detection failed: $error');
        }
      } finally {
        _detecting = false;
      }
    }());
  }

  @override
  void dispose() {
    final controller = _cameraController;
    if (controller != null) {
      unawaited(controller.dispose());
    }
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE4F2),
      appBar: AppBar(
        title: const Text('Environment Camera'),
        backgroundColor: const Color(0xFFE56997),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: TamagotchiBackground(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final shellWidth = math.min(constraints.maxWidth - 28, 430.0);
                final shellHeight = math.min(constraints.maxHeight - 28, 680.0);

                return Container(
                  width: shellWidth,
                  height: shellHeight,
                  margin: const EdgeInsets.all(14),
                  padding: const EdgeInsets.all(18),
                  decoration: tamagotchiCaseDecoration(),
                  child: Container(
                    decoration: tamagotchiScreenDecoration(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 78,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: DottedYellowPainter(),
                                  ),
                                ),
                                const Center(child: TopActionIcons()),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CustomPaint(painter: CheckerboardPainter()),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: _buildCameraPanel(),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 122,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: DottedYellowPainter(
                                      reverseFlowers: true,
                                    ),
                                  ),
                                ),
                                Center(child: _buildResultPanel()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPanel() {
    final controller = _cameraController;

    if (_booting) {
      return const DetectionMessage(
        icon: Icons.camera_alt,
        title: 'Opening camera',
        subtitle: 'Loading model and camera preview...',
      );
    }

    if (_errorMessage != null) {
      return DetectionMessage(
        icon: Icons.error_outline,
        title: 'Camera unavailable',
        subtitle: _errorMessage!,
      );
    }

    if (controller == null || !controller.value.isInitialized) {
      return const DetectionMessage(
        icon: Icons.videocam_off_outlined,
        title: 'Preview not ready',
        subtitle: 'Please reopen the camera page.',
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(controller),
            const _ScanFrame(),
            Positioned(
              top: 12,
              left: 12,
              child: _StatusChip(
                label: _detecting ? 'Detecting' : 'Live camera',
                color: _detecting
                    ? const Color(0xFFF4B41B)
                    : const Color(0xFF38B764),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPanel() {
    final result = _latestResult;

    if (result == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Point camera at the environment',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            SizedBox(height: 6),
            Text(
              'Waiting for Safe / Foreign detection',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    final isSafe = result.label.toLowerCase().contains('safe');
    final color = isSafe ? const Color(0xFF38B764) : const Color(0xFFE56997);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black87, width: 2),
            ),
            child: Icon(
              isSafe ? Icons.verified_outlined : Icons.warning_amber_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: result.confidence.clamp(0.0, 1.0).toDouble(),
                    color: color,
                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Confidence ${(result.confidence * 100).clamp(0, 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetectionMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const DetectionMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 2),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 42, color: const Color(0xFFE56997)),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.88),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class EnvironmentClassifier {
  static const String _modelPath = 'assets/models/model_unquant.tflite';
  static const String _labelPath = 'assets/models/labels.txt';

  Interpreter? _interpreter;
  List<String> _labels = const [];
  late List<int> _inputShape;
  late List<int> _outputShape;
  late int _inputHeight;
  late int _inputWidth;
  late int _inputChannels;
  late int _outputSize;

  Future<void> load() async {
    if (_interpreter != null) {
      return;
    }

    final options = InterpreterOptions()..threads = 2;
    _interpreter = await Interpreter.fromAsset(_modelPath, options: options);
    _interpreter!.allocateTensors();

    _inputShape = _interpreter!.getInputTensor(0).shape;
    _outputShape = _interpreter!.getOutputTensor(0).shape;

    if (_inputShape.length != 4) {
      throw StateError('Unsupported model input shape: $_inputShape');
    }

    _inputHeight = _inputShape[1];
    _inputWidth = _inputShape[2];
    _inputChannels = _inputShape[3];
    _outputSize = _outputShape.reduce((value, item) => value * item);

    if (_inputChannels != 3) {
      throw StateError('Unsupported model channel count: $_inputChannels');
    }

    final labelData = await rootBundle.loadString(_labelPath);
    _labels = labelData
        .split('\n')
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .map((label) => label.replaceFirst(RegExp(r'^\d+\s+'), ''))
        .toList(growable: false);
  }

  Future<DetectionResult> classify(
    CameraImage cameraImage, {
    int rotation = 0,
  }) async {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError('Classifier has not been loaded.');
    }

    var image = _cameraImageToImage(cameraImage);
    if (rotation != 0) {
      image = img.copyRotate(image, angle: rotation);
    }

    final squareSize = math.min(image.width, image.height);
    final crop = img.copyCrop(
      image,
      x: (image.width - squareSize) ~/ 2,
      y: (image.height - squareSize) ~/ 2,
      width: squareSize,
      height: squareSize,
    );
    final resized = img.copyResize(
      crop,
      width: _inputWidth,
      height: _inputHeight,
      interpolation: img.Interpolation.linear,
    );

    final input = Float32List(_inputHeight * _inputWidth * _inputChannels);
    var inputIndex = 0;
    for (var y = 0; y < _inputHeight; y++) {
      for (var x = 0; x < _inputWidth; x++) {
        final pixel = resized.getPixel(x, y);
        input[inputIndex++] = (pixel.r.toDouble() - 127.5) / 127.5;
        input[inputIndex++] = (pixel.g.toDouble() - 127.5) / 127.5;
        input[inputIndex++] = (pixel.b.toDouble() - 127.5) / 127.5;
      }
    }

    final output = List<double>.filled(
      _outputSize,
      0,
    ).reshape<double>(_outputShape);
    interpreter.run(input.reshape<double>(_inputShape), output);

    var bestIndex = 0;
    final scores = output.flatten<double>();
    var bestScore = scores[0];
    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestIndex = i;
        bestScore = scores[i];
      }
    }

    return DetectionResult(
      label: bestIndex < _labels.length
          ? _labels[bestIndex]
          : 'Class $bestIndex',
      confidence: bestScore,
    );
  }

  img.Image _cameraImageToImage(CameraImage image) {
    if (image.format.group == ImageFormatGroup.bgra8888) {
      return _bgra8888ToImage(image);
    }

    return _yuv420ToImage(image);
  }

  img.Image _bgra8888ToImage(CameraImage image) {
    final plane = image.planes.first;
    final output = img.Image(width: image.width, height: image.height);
    final pixelStride = plane.bytesPerPixel ?? 4;

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final index = y * plane.bytesPerRow + x * pixelStride;
        final b = plane.bytes[index];
        final g = plane.bytes[index + 1];
        final r = plane.bytes[index + 2];
        output.setPixelRgb(x, y, r, g, b);
      }
    }

    return output;
  }

  img.Image _yuv420ToImage(CameraImage image) {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    final output = img.Image(width: image.width, height: image.height);
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final yIndex = y * yPlane.bytesPerRow + x;
        final uvIndex =
            (y ~/ 2) * uPlane.bytesPerRow + (x ~/ 2) * uvPixelStride;

        final yValue = yPlane.bytes[yIndex].toDouble();
        final uValue = uPlane.bytes[uvIndex].toDouble() - 128;
        final vValue = vPlane.bytes[uvIndex].toDouble() - 128;

        final r = (yValue + 1.402 * vValue).round().clamp(0, 255);
        final g = (yValue - 0.344136 * uValue - 0.714136 * vValue)
            .round()
            .clamp(0, 255);
        final b = (yValue + 1.772 * uValue).round().clamp(0, 255);

        output.setPixelRgb(x, y, r, g, b);
      }
    }

    return output;
  }

  void dispose() {
    _interpreter?.close();
  }
}

class DetectionResult {
  final String label;
  final double confidence;

  const DetectionResult({required this.label, required this.confidence});
}

class FooterPage extends StatelessWidget {
  final String title;

  const FooterPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFE56997),
      ),
      body: Center(
        child: Text(
          'Welcome to the $title page!',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class AnimatedPixelCharacter extends StatefulWidget {
  const AnimatedPixelCharacter({super.key});

  @override
  State<AnimatedPixelCharacter> createState() => _AnimatedPixelCharacterState();
}

class _AnimatedPixelCharacterState extends State<AnimatedPixelCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Image.asset(
            'assets/logo/plant.png',
            width: 160,
            height: 160,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}

class DottedYellowPainter extends CustomPainter {
  final bool reverseFlowers;

  DottedYellowPainter({this.reverseFlowers = false});

  @override
  void paint(Canvas canvas, Size size) {
    final yellow = Paint()..color = const Color(0xFFFFF7B0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), yellow);

    final dot = Paint()..color = const Color(0xFFEBDC50);
    const spacing = 4.0;
    for (var i = 0.0; i < size.width; i += spacing) {
      for (var j = 0.0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 0.7, dot);
      }
    }

    final pink = Paint()
      ..color = const Color(0xFFF9B8CE).withValues(alpha: 0.85);
    final blue = Paint()
      ..color = const Color(0xFF9FDBF0).withValues(alpha: 0.85);

    if (reverseFlowers) {
      _drawFlower(canvas, Offset(size.width * 0.25, size.height / 2), pink);
      _drawFlower(canvas, Offset(size.width * 0.75, size.height / 2), blue);
    } else {
      _drawFlower(canvas, Offset(size.width * 0.25, size.height / 2), blue);
      _drawFlower(canvas, Offset(size.width * 0.75, size.height / 2), pink);
    }
  }

  void _drawFlower(Canvas canvas, Offset center, Paint paint) {
    canvas.drawCircle(center + const Offset(-9, -9), 11, paint);
    canvas.drawCircle(center + const Offset(9, -9), 11, paint);
    canvas.drawCircle(center + const Offset(-9, 9), 11, paint);
    canvas.drawCircle(center + const Offset(9, 9), 11, paint);
    canvas.drawCircle(center, 14, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBlue = Paint()..color = const Color(0xFFBCE3F0);
    final paintPink = Paint()..color = const Color(0xFFF3C4D6);
    final paintWhite = Paint()..color = const Color(0xFFFBF4FA);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintWhite);

    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(0.5);

    const tileSize = 35.0;
    for (var i = -15; i < 15; i++) {
      for (var j = -15; j < 15; j++) {
        if ((i + j) % 2 == 0) {
          final paint = i % 2 == 0 ? paintBlue : paintPink;
          canvas.drawRect(
            Rect.fromLTWH(i * tileSize, j * tileSize, tileSize, tileSize),
            paint,
          );
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
