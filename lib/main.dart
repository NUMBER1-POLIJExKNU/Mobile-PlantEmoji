import 'dart:async';
import 'dart:math' as math;
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
  String _dialogue = "Happy to see you!";

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
        _updateDialogue();
      });
    }
  }

  void _updateDialogue() {
    if (_sensorData == null) return;

    if (_sensorData!.soilPH > 7.5) {
      _dialogue = "My leaves filed a complaint— my soil is too alkaline —don't add anything by yourself.";
    } else if (_sensorData!.soilPH < 6.0) {
      _dialogue = "The soil is getting a bit acidic, help!";
    } else if (_sensorData!.temperature > 30) {
      _dialogue = "It's a bit hot today, isn't it?";
    } else {
      _dialogue = "I'm feeling great today!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Global Sky Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Opacity(
              opacity: 0.6,
              child: Image.asset('assets/design/cloud1.png', width: 120),
            ),
          ),

          SafeArea(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  margin: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE56997), // Pink casing
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: const Color(0xFFD04A7B), width: 6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(10, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade400, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(painter: JamkachuInnerPainter()),
                          ),
                          Column(
                            children: [
                              // TOP BAR
                              const Expanded(
                                flex: 2,
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

                              // MIDDLE AREA (Jamkachu)
                              Expanded(
                                flex: 5,
                                child: Stack(
                                  children: [
                                    // Dialogue Bubble
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      right: 10,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(color: Colors.black12),
                                          ),
                                          child: Text(
                                            '"$_dialogue"',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 10, color: Colors.black87),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          AnimatedPixelCharacter(),
                                          const Text(
                                            'JAMKACHU',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF386641),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3E96B),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Text('Best Friend 🤝', style: TextStyle(fontSize: 8)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // AI Chat NPC
                                    const Positioned(
                                      bottom: 5,
                                      left: 0,
                                      right: 0,
                                      child: AiNpcCharacter(),
                                    ),
                                  ],
                                ),
                              ),

                              // BOTTOM BAR
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      FooterIconButton(
                                        assetPath: 'assets/logo/home.png',
                                        tooltip: 'Home',
                                        pageBuilder: (context) => HomePage(sensorData: _sensorData),
                                      ),
                                      FooterIconButton(
                                        assetPath: 'assets/logo/camera.png',
                                        tooltip: 'Camera',
                                        pageBuilder: (context) => const FooterPage(title: 'Camera'),
                                      ),
                                      FooterIconButton(
                                        assetPath: 'assets/logo/inventory.png',
                                        tooltip: 'Collection',
                                        pageBuilder: (context) => const CollectionPage(),
                                      ),
                                      FooterIconButton(
                                        assetPath: 'assets/logo/chara.png',
                                        tooltip: 'Character',
                                        pageBuilder: (context) => const FooterPage(title: 'Character'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- HOME PAGE ---
class HomePage extends StatelessWidget {
  final SensorData? sensorData;
  const HomePage({super.key, this.sensorData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(color: Colors.black87, fontFamily: 'Courier')),
        backgroundColor: const Color(0xFFE56997),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildMissionCard(),
            const SizedBox(height: 16),
            _buildTeacherButton(),
            const SizedBox(height: 16),
            _buildGardenVitals(),
            const SizedBox(height: 16),
            _buildQuizCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF8BC34A), width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('JAMKACHU STATUS', style: TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold)),
          const Text('Bond Lv. 16', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: LinearProgressIndicator(value: 0.55, backgroundColor: Colors.grey.shade200, color: const Color(0xFF8BC34A), minHeight: 12, borderRadius: BorderRadius.circular(6))),
              const SizedBox(width: 10),
              const Text('HP 55%', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChip('⭐ 458 XP'),
              _buildChip('🌱 31 Days'),
              _buildChip('🌰 2 Seeds'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFDCEDC8))),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMissionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF8BC34A), width: 2)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("TODAY'S MISSION", style: TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(children: [Icon(Icons.local_fire_department, color: Colors.orange, size: 16), SizedBox(width: 8), Text('Balance My Soil', style: TextStyle(fontWeight: FontWeight.bold))]),
        ],
      ),
    );
  }

  Widget _buildTeacherButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: const Color(0xFF8BC34A), borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Color(0xFF689F38), offset: Offset(0, 4))]),
      child: const Center(child: Text('Check my soil with a teacher 👩‍🏫', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildGardenVitals() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        children: [
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('GARDEN VITALS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Text('View details >', style: TextStyle(fontSize: 10, color: Colors.grey))]),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.4,
            children: [
              _buildVitalItem('TEMP', '${sensorData?.temperature.toStringAsFixed(1) ?? "--"}°C', Icons.thermostat),
              _buildVitalItem('HUMIDITY', '${sensorData?.humidity ?? "--"}%', Icons.water_drop),
              _buildVitalItem('LIGHT', '${sensorData?.light ?? "--"}%', Icons.wb_sunny),
              _buildVitalItem('SOIL', 'pH ${sensorData?.soilPH.toStringAsFixed(1) ?? "--"}', Icons.science),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Icon(icon, size: 14, color: Colors.pink), const SizedBox(width: 4), Text(title, style: const TextStyle(fontSize: 8, color: Colors.grey))]),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('last 20:29', style: TextStyle(fontSize: 8, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildQuizCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFFFDE7), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFFF176))),
      child: Row(
        children: [
          const Icon(Icons.psychology, color: Colors.pink, size: 32),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("TODAY'S QUIZ", style: TextStyle(fontSize: 8, color: Colors.orange, fontWeight: FontWeight.bold)), Text('0/3 complete', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.amber)), child: const Text('+9 XP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

// --- COLLECTION PAGE ---
class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E272E),
      appBar: AppBar(
        title: const Text('Collection', style: TextStyle(color: Colors.white, fontFamily: 'Courier')),
        backgroundColor: const Color(0xFFE56997),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.emoji_events, color: Colors.amber, size: 28)), const SizedBox(width: 12), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DISCOVERY BOOK', style: TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold)), Text('Collection', style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold))])]),
            const SizedBox(height: 20),
            Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(15)), child: Row(children: [_buildTab('Moods', active: true), _buildTab('Badges'), _buildTab('Story'), _buildTab('Wisdom')])),
            const SizedBox(height: 20),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.gamepad, color: Colors.deepPurpleAccent, size: 24), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('JAMKACHU MOOD DEX', style: TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold)), Text('Discover every expression', style: TextStyle(fontSize: 10, color: Colors.white70))])), Text('6/8', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))])),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10,
              children: [
                _buildMoodTile('Happy', '😊', active: true, selected: true),
                _buildMoodTile('Hot', '🔥', active: true),
                _buildMoodTile('Locked', '?', active: false),
                _buildMoodTile('Dry', '💨', active: true),
                _buildMoodTile('Locked', '?', active: false),
                _buildMoodTile('Sleepy', '🌙', active: true),
              ],
            ),
            const SizedBox(height: 20),
            _buildMoodDetailCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, {bool active = false}) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: active ? const Color(0xFF8BC34A) : Colors.transparent, borderRadius: BorderRadius.circular(12)), child: Center(child: Text(label, style: TextStyle(color: active ? Colors.black87 : Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)))));
  }

  Widget _buildMoodTile(String name, String emoji, {bool active = false, bool selected = false}) {
    return Container(
      decoration: BoxDecoration(color: selected ? Colors.green.withOpacity(0.2) : Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: selected ? Colors.green : Colors.white10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: 28, color: Colors.white.withOpacity(active ? 1.0 : 0.2))),
          const SizedBox(height: 4),
          Text(name, style: TextStyle(fontSize: 8, color: active ? Colors.white : Colors.white30)),
        ],
      ),
    );
  }

  Widget _buildMoodDetailCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Container(height: 130, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE8F5E9), Color(0xFF8BC34A)]), borderRadius: BorderRadius.vertical(top: Radius.circular(20))), child: Stack(children: [Center(child: Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Text('😊', style: TextStyle(fontSize: 44)))), const Positioned(bottom: 16, left: 16, child: Text('Happy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)))])),
          Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildSection('WHY THIS MOOD?', 'In the Comfort Zone', 'All sensor values are within the ideal range.'), const SizedBox(height: 16), _buildSection('SAFE NEXT MOVE', 'Keep Stability', 'Maintain these conditions for optimal growth.')])),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String sub, String text) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.lightbulb, color: Colors.amber, size: 14), const SizedBox(width: 6), Text(title, style: const TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold))]), const SizedBox(height: 4), Text(sub, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(text, style: const TextStyle(fontSize: 11, color: Colors.white70))]);
  }
}

// --- COMMON WIDGETS ---
class FooterIconButton extends StatefulWidget {
  final String assetPath;
  final String tooltip;
  final WidgetBuilder pageBuilder;
  const FooterIconButton({super.key, required this.assetPath, required this.tooltip, required this.pageBuilder});
  @override
  State<FooterIconButton> createState() => _FooterIconButtonState();
}

class _FooterIconButtonState extends State<FooterIconButton> {
  bool _hovering = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true), onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: widget.pageBuilder)),
        child: AnimatedContainer(duration: const Duration(milliseconds: 150), width: 70, height: 70, decoration: BoxDecoration(color: _hovering ? Colors.pink.withOpacity(0.1) : Colors.transparent, shape: BoxShape.circle), transform: Matrix4.identity()..scale(_hovering ? 1.1 : 1.0), child: Padding(padding: const EdgeInsets.all(12.0), child: Image.asset(widget.assetPath, fit: BoxFit.contain))),
      ),
    );
  }
}

class FooterPage extends StatelessWidget {
  final String title;
  const FooterPage({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title), backgroundColor: const Color(0xFFE56997)), body: Center(child: Text('Welcome to $title page!')));
  }
}

class JamkachuInnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE1F5FE), Color(0xFFFFFFFF)]).createShader(rect));
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.2), 60, Paint()..color = const Color(0xFFFFF176).withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40));
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.2), 30, Paint()..color = const Color(0xFFFFF176).withOpacity(0.5));
    final Paint dot = Paint()..color = Colors.grey.withOpacity(0.2);
    for (double i = 0; i < size.width; i += size.width/10) for (double j = 0; j < size.height; j += size.width/10) canvas.drawCircle(Offset(i, j), 1.5, dot);
    final double gh = size.height * 0.22;
    canvas.drawRect(Rect.fromLTWH(0, size.height - gh, size.width, gh), Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF8BC34A), Color(0xFF689F38)]).createShader(Rect.fromLTWH(0, size.height - gh, size.width, gh)));
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class AiNpcCharacter extends StatefulWidget {
  const AiNpcCharacter({super.key});
  @override
  _AiNpcCharacterState createState() => _AiNpcCharacterState();
}

class _AiNpcCharacterState extends State<AiNpcCharacter> with SingleTickerProviderStateMixin {
  double _posX = 0.0; bool _faceRight = true; late Timer _t;
  @override
  void initState() { super.initState(); _t = Timer.periodic(const Duration(seconds: 3), (t) { if (mounted) setState(() { _posX = math.Random().nextDouble() * 140 - 70; _faceRight = math.Random().nextBool(); }); }); }
  @override
  void dispose() { _t.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) { return AnimatedContainer(duration: const Duration(seconds: 2), curve: Curves.easeInOut, transform: Matrix4.translationValues(_posX, 0, 0), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: const Color(0xFFF3E96B), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black, width: 1)), child: const Text('AI CHAT', style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold))), Transform(alignment: Alignment.center, transform: Matrix4.rotationY(_faceRight ? 0 : math.pi), child: Image.asset('assets/logo/chara.png', width: 32, height: 32))])); }
}

class AnimatedPixelCharacter extends StatefulWidget {
  @override
  _AnimatedPixelCharacterState createState() => _AnimatedPixelCharacterState();
}

class _AnimatedPixelCharacterState extends State<AnimatedPixelCharacter> with SingleTickerProviderStateMixin {
  late AnimationController _c; late Animation<double> _a;
  @override
  void initState() { super.initState(); _c = AnimationController(duration: const Duration(milliseconds: 900), vsync: this)..repeat(reverse: true); _a = Tween<double>(begin: -5.0, end: 5.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) { return AnimatedBuilder(animation: _a, builder: (ctx, child) => Transform.translate(offset: Offset(0, _a.value), child: Image.asset('assets/logo/plant.png', width: 130, height: 130, fit: BoxFit.contain))); }
}
