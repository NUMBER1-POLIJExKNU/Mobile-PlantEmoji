import 'dart:async';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'sensor_data.dart';

void main() {
  runApp(const TamagotchiApp());
}

class TamagotchiApp extends StatelessWidget {
  const TamagotchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tamagotchi Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Courier',
      ),
      home: const TamagotchiDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TamagotchiDashboard extends StatefulWidget {
  const TamagotchiDashboard({super.key});

  @override
  State<TamagotchiDashboard> createState() => _TamagotchiDashboardState();
}

class _TamagotchiDashboardState extends State<TamagotchiDashboard> {
  final ApiService _apiService = ApiService();
  SensorData? _sensorData;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final data = await _apiService.fetchLatestSensorData();
    if (mounted) {
      setState(() {
        _sensorData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE4F2), // Light background for contrast
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 16,
              left: 16,
              child: Opacity(
                opacity: 0.85,
                child: Image.asset('assets/design/cloud1.png', width: 96, height: 96),
              ),
            ),
            Positioned(
              top: 20,
              right: 22,
              child: Opacity(
                opacity: 0.85,
                child: Image.asset('assets/design/butterfly.png', width: 88, height: 88),
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
            Center(
              child: AspectRatio(
                aspectRatio: 1.0, // Square like the reference screen
                child: Container(
                  margin: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE56997), // Pink casing
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: const Color(0xFFD04A7B),
                      width: 6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(10, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0), // Padding inside the casing
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(2, 2),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Column(
                        children: [
                          // TOP BAR
                          Expanded(
                            flex: 2,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(painter: DottedYellowPainter()),
                                ),
                                const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(Icons.restaurant, size: 36, color: Colors.black87),
                                      Icon(Icons.lightbulb_outline, size: 36, color: Colors.black87),
                                      Icon(Icons.sports_baseball, size: 36, color: Colors.black87),
                                      Icon(Icons.vaccines, size: 36, color: Colors.black87),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // MIDDLE SECTION
                          Expanded(
                            flex: 5,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(painter: CheckerboardPainter()),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedPixelCharacter(),
                                    const SizedBox(height: 10),
                                    if (_sensorData != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.pink.shade200),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              '${_sensorData!.temperature.toStringAsFixed(1)}°C | ${_sensorData!.humidity}% Hum',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            Text(
                                              'Light: ${_sensorData!.light} | pH: ${_sensorData!.soilPH.toStringAsFixed(1)}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      const CircularProgressIndicator(strokeWidth: 2),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // BOTTOM BAR
                          Expanded(
                            flex: 2,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(painter: DottedYellowPainter(reverseFlowers: true)),
                                ),
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      FooterIconButton(
                                        assetPath: 'assets/logo/home.png',
                                        tooltip: 'Home',
                                        page: const FooterPage(title: 'Home'),
                                      ),
                                      FooterIconButton(
                                        assetPath: 'assets/logo/camera.png',
                                        tooltip: 'Camera',
                                        page: const FooterPage(title: 'Camera'),
                                      ),
                                      FooterIconButton(
                                        assetPath: 'assets/logo/inventory.png',
                                        tooltip: 'Inventory',
                                        page: const FooterPage(title: 'Inventory'),
                                      ),
                                      FooterIconButton(
                                        assetPath: 'assets/logo/chara.png',
                                        tooltip: 'Character',
                                        page: const FooterPage(title: 'Character'),
                                      ),
                                    ],
                                  ),
                                ),
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
          ],
        ),
      ),
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
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => widget.page),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 76,
          height: 76,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: [
              if (_hovering)
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
            border: Border.all(
              color: _hovering ? Colors.pink.shade200.withOpacity(0.9) : Colors.transparent,
              width: 2,
            ),
          ),
          transform: Matrix4.identity()..scale(_hovering ? 1.06 : 1.0),
          child: Tooltip(
            message: widget.tooltip,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                widget.assetPath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
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
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// CUSTOM PAINTERS & WIDGETS
// ---------------------------------------------------------

class AnimatedPixelCharacter extends StatefulWidget {
  @override
  _AnimatedPixelCharacterState createState() => _AnimatedPixelCharacterState();
}

class _AnimatedPixelCharacterState extends State<AnimatedPixelCharacter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -8.0, end: 8.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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

class PixelPainter extends CustomPainter {
  final List<List<int>> sprite = [
    [0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0,1,2,2,2,1,0,1,2,2,2,1,0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,1,2,2,3,3,1,4,1,3,3,2,2,1,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,1,2,2,3,3,3,1,4,1,3,3,3,2,2,1,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,1,2,2,3,3,3,3,1,4,1,3,3,3,3,2,2,1,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,1,2,3,3,3,3,4,1,4,1,4,3,3,3,3,2,1,0,0,0,0,0,0,0],
    [0,0,1,1,1,0,0,1,2,3,3,3,3,4,1,4,1,4,3,3,3,3,2,1,0,0,1,1,1,0,0],
    [0,1,2,2,2,1,0,1,3,3,3,4,4,4,1,4,1,4,4,4,3,3,3,1,0,1,2,2,2,1,0],
    [1,2,2,3,3,1,1,3,3,3,4,4,4,4,1,4,1,4,4,4,4,3,3,3,1,1,3,3,2,2,1],
    [1,2,3,3,3,3,3,1,4,4,4,4,4,4,1,4,1,4,4,4,4,4,4,1,3,3,3,3,3,2,1],
    [1,2,3,3,3,3,3,3,1,4,4,4,4,4,1,4,1,4,4,4,4,4,1,3,3,3,3,3,3,2,1],
    [0,1,2,3,3,3,3,3,3,1,4,4,4,4,1,4,1,4,4,4,4,1,3,3,3,3,3,3,2,1,0],
    [0,1,1,2,3,3,3,3,3,1,4,4,4,4,1,4,1,4,4,4,4,1,3,3,3,3,3,2,1,1,0],
    [0,0,1,1,2,2,3,3,3,1,4,4,4,4,1,4,1,4,4,4,4,1,3,3,3,2,2,1,1,0,0],
    [0,0,0,1,1,2,2,2,3,1,4,4,4,4,1,4,1,4,4,4,4,1,3,2,2,2,1,1,0,0,0],
    [0,0,0,0,1,1,1,1,1,1,1,1,1,1,4,4,4,1,1,1,1,1,1,1,1,1,1,0,0,0,0],
    [0,0,1,5,5,5,5,5,5,5,5,5,5,5,5,4,5,5,5,5,5,5,5,5,5,5,5,1,0,0,0],
    [0,0,1,5,5,6,5,5,5,5,5,6,5,5,5,5,5,5,5,6,5,5,5,5,5,6,5,5,1,0,0],
    [0,0,1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,1,0,0],
    [0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
    [0,1,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,1,0],
    [0,1,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,1,0],
    [0,1,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,1,0],
    [0,0,1,1,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,1,1,0,0],
    [0,0,0,1,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,1,0,0,0],
    [0,0,0,1,7,7,7,7,7,7,1,1,7,7,7,7,7,7,7,1,1,7,7,7,7,7,7,1,0,0,0],
    [0,0,0,1,7,7,9,9,9,9,1,1,7,7,7,7,7,7,7,1,1,9,9,9,9,7,7,1,0,0,0],
    [0,0,0,1,7,7,9,9,9,9,7,7,7,7,1,7,1,7,7,7,7,9,9,9,9,7,7,1,0,0,0],
    [0,0,0,1,7,7,7,9,9,7,7,7,7,7,1,1,1,7,7,7,7,7,9,9,7,7,7,1,0,0,0],
    [0,0,0,0,1,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,1,0,0,0,0],
    [0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0]
  ];

  @override
  void paint(Canvas canvas, Size size) {
    double pixelSize = size.width / sprite[0].length;
    Paint pBlack = Paint()..color = const Color(0xFF1a1c2c);
    Paint pLightGreen = Paint()..color = const Color(0xFFa7f070);
    Paint pGreen = Paint()..color = const Color(0xFF38b764);
    Paint pDarkGreen = Paint()..color = const Color(0xFF185a3a);
    Paint pBrown = Paint()..color = const Color(0xFF593122);
    Paint pYellow = Paint()..color = const Color(0xFFf3e96b);
    Paint pOrange = Paint()..color = const Color(0xFFf4b41b);
    Paint pDarkOrange = Paint()..color = const Color(0xFFe28c22);
    Paint pPink = Paint()..color = const Color(0xFFff77a8);
    
    for (int y = 0; y < sprite.length; y++) {
      for (int x = 0; x < sprite[y].length; x++) {
        Paint? p;
        switch (sprite[y][x]) {
          case 1: p = pBlack; break;
          case 2: p = pLightGreen; break;
          case 3: p = pGreen; break;
          case 4: p = pDarkGreen; break;
          case 5: p = pBrown; break;
          case 6: p = pYellow; break;
          case 7: p = pOrange; break;
          case 8: p = pDarkOrange; break;
          case 9: p = pPink; break;
        }
        if (p != null) {
          canvas.drawRect(Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize), p);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DottedYellowPainter extends CustomPainter {
  final bool reverseFlowers;
  DottedYellowPainter({this.reverseFlowers = false});

  @override
  void paint(Canvas canvas, Size size) {
    // Base yellow background
    Paint yellow = Paint()..color = const Color(0xFFFFF7B0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), yellow);
    
    // Halftone / Dotted pattern
    Paint dot = Paint()..color = const Color(0xFFEBDC50);
    double spacing = 4.0;
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 0.7, dot);
      }
    }
    
    // Faint flower decorations
    Paint pink = Paint()..color = const Color(0xFFF9B8CE).withOpacity(0.85);
    Paint blue = Paint()..color = const Color(0xFF9FDBF0).withOpacity(0.85);
    
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
    canvas.drawCircle(center, 14, paint); // center
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paintBlue = Paint()..color = const Color(0xFFBCE3F0);
    Paint paintPink = Paint()..color = const Color(0xFFF3C4D6);
    Paint paintWhite = Paint()..color = const Color(0xFFFBF4FA);
    
    // Base white
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintWhite);
    
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(0.5); // Rotation to create diagonal checkerboard
    
    double tileSize = 35.0;
    for (int i = -15; i < 15; i++) {
      for (int j = -15; j < 15; j++) {
        if ((i + j) % 2 == 0) {
          Paint paint = (i % 2 == 0) ? paintBlue : paintPink;
          canvas.drawRect(
            Rect.fromLTWH(i * tileSize, j * tileSize, tileSize, tileSize), 
            paint
          );
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
