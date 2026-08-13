import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'sensor_data.dart';
import 'diary_entry.dart';

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

enum _ScreenMode { dashboard, garden, camera, collection, diary }

class _TamagotchiDashboardState extends State<TamagotchiDashboard> {
  final ApiService _apiService = ApiService();
  SensorData? _sensorData;
  List<DiaryEntry> _diaryEntries = [];
  List<String> _unlockedIds = ['comfort', 'badge_1', 'story_1', 'wisdom_1']; // Initial defaults
  Timer? _timer;
  Timer? _clockTimer;
  bool _isDay = true;
  String _dialogue = "Happy to see you!";
  _ScreenMode _mode = _ScreenMode.dashboard;
  int _plantLevel = 1; // Track plant growth level (1-5: seed, 6-10: babby, 11-15: flower, 16+: harvest)

  @override
  void initState() {
    super.initState();
    _updateTimeOfDay();
    _fetchInitialData();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchData();
    });
    _clockTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateTimeOfDay();
    });
  }

  Future<void> _fetchInitialData() async {
    await Future.wait([
      _fetchData(),
      _loadDiary(),
      _loadUnlockedCollections(),
    ]);
  }

  Future<void> _loadDiary() async {
    final entries = await _apiService.fetchDiaryEntries();
    if (mounted) {
      setState(() {
        _diaryEntries = entries;
        _updatePlantLevel();
      });
    }
  }

  Future<void> _loadUnlockedCollections() async {
    final ids = await _apiService.fetchUnlockedCollectionIds();
    if (mounted && ids.isNotEmpty) {
      setState(() => _unlockedIds = ids);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  void _updateTimeOfDay() {
    final hour = DateTime.now().hour;
    final isDayNow = hour >= 6 && hour < 18;
    if (isDayNow != _isDay) {
      setState(() {
        _isDay = isDayNow;
      });
    }
  }

  Future<void> _fetchData() async {
    final data = await _apiService.fetchLatestSensorData();
    if (mounted) {
      setState(() {
        _sensorData = data;
        _updateDialogue();
        _checkAchievements();
      });
    }
  }

  void _checkAchievements() {
    if (_sensorData == null) return;
    
    bool changed = false;
    
    // Auto-unlock logic based on sensor triggers
    if (_sensorData!.soilPH > 8.5 && !_unlockedIds.contains('soil_alkaline')) {
      _unlockedIds.add('soil_alkaline');
      changed = true;
    }
    if (_sensorData!.soilPH < 5.5 && !_unlockedIds.contains('soil_acidic')) {
      _unlockedIds.add('soil_acidic');
      changed = true;
    }
    if (_sensorData!.temperature > 32 && !_unlockedIds.contains('overheat')) {
      _unlockedIds.add('overheat');
      changed = true;
    }
    
    if (changed) {
      setState(() {});
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

  String _getPlantAsset() {
    if (_plantLevel <= 5) {
      return 'assets/plant/plant_seed.png';
    } else if (_plantLevel <= 10) {
      return 'assets/plant/plant_babby.png';
    } else if (_plantLevel <= 15) {
      return 'assets/plant/plant_flower.png';
    } else {
      return 'assets/plant/plant_harvest_time.png';
    }
  }

  void _updatePlantLevel() {
    if (_diaryEntries.isNotEmpty) {
      _plantLevel = _diaryEntries.length + 1; // Level increases with diary entries
    }
  }

  void _openScreen(_ScreenMode mode) {
    setState(() => _mode = mode);
  }

  void _goHome() {
    setState(() => _mode = _ScreenMode.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Global Sky Background
          Image.asset(
            _isDay
                ? 'assets/background/sunny_background.png'
                : 'assets/background/night_background.png',
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Opacity(
              opacity: _isDay ? 0.6 : 0.15,
              child: Image.asset('assets/design/cloud1.png', width: 120),
            ),
          ),

          SafeArea(
            child: Center(
              child: AspectRatio(
                aspectRatio: 0.65, // More vertical for mobile
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE56997), // Pink casing
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: const Color(0xFFD04A7B), width: 8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.shade300, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(27),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(painter: JamkachuInnerPainter(isDay: _isDay)),
                          ),
                          // Only the INNER screen content switches
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _mode == _ScreenMode.dashboard
                                ? _buildDashboardScreen()
                                : _buildSubScreen(),
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

  Widget _buildDashboardScreen() {
    return Column(
      key: const ValueKey('dashboard'),
      children: [
        const Expanded(flex: 1, child: SizedBox.shrink()),
        Expanded(
          flex: 7,
          child: Stack(
            children: [
              Positioned(
                top: 20,
                left: 15,
                right: 15,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                      ],
                    ),
                    child: Text(
                      '"$_dialogue"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.2),
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    AnimatedPixelCharacter(assetPath: _getPlantAsset()),
                    const SizedBox(height: 10),
                    Text(
                      'JAMKACHU',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: _isDay ? const Color(0xFF386641) : const Color(0xFFFFFFFF),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E96B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black.withOpacity(0.1)),
                      ),
                      child: const Text(
                        'BEST FRIEND',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                bottom: 15,
                left: 0,
                right: 0,
                child: AiNpcCharacter(),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FooterIconButton(
                  assetPath: 'assets/logo/home.png',
                  tooltip: 'Home',
                  onTap: () => _openScreen(_ScreenMode.garden),
                ),
                FooterIconButton(
                  assetPath: 'assets/logo/camera.png',
                  tooltip: 'Camera',
                  onTap: () => _openScreen(_ScreenMode.camera),
                ),
                FooterIconButton(
                  assetPath: 'assets/logo/collection.png',
                  tooltip: 'Collection',
                  onTap: () => _openScreen(_ScreenMode.collection),
                ),
                FooterIconButton(
                  assetPath: 'assets/logo/Diary.png',
                  tooltip: 'Diary',
                  onTap: () => _openScreen(_ScreenMode.diary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubScreen() {
    late final String title;
    late final Widget content;

    switch (_mode) {
      case _ScreenMode.garden:
        title = 'My Garden';
        content = _GardenScreenContent(sensorData: _sensorData);
        break;
      case _ScreenMode.camera:
        title = 'Camera';
        content = const _PlaceholderScreenContent(assetPath: 'assets/logo/camera.png', label: 'Camera feature coming soon');
        break;
      case _ScreenMode.collection:
        title = 'Collection';
        content = _CollectionScreenContent(unlockedIds: _unlockedIds);
        break;
      case _ScreenMode.diary:
        title = 'Diary';
        content = _DiaryScreenContent(
          entries: _diaryEntries,
          isDay: _isDay,
          onAddEntry: (entry) async {
            final success = await _apiService.saveDiaryEntry(entry);
            if (success) {
              _loadDiary();
            }
          },
        );
        break;
      case _ScreenMode.dashboard:
        title = '';
        content = const SizedBox.shrink();
        break;
    }

    return Column(
      key: ValueKey(_mode),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Row(
            children: [
              _BackButton(onTap: _goHome),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: _isDay ? const Color(0xFF386641) : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 32),
            ],
          ),
        ),
        Expanded(child: content),
      ],
    );
  }
}

// --- GARDEN MONITORING ---
class _GardenScreenContent extends StatelessWidget {
  final SensorData? sensorData;
  const _GardenScreenContent({required this.sensorData});

  static const _dummyBondLevel = 4;
  static const _dummyHp = 0.72;
  static const _dummyXp = 128;
  static const _dummyDays = 12;

  @override
  Widget build(BuildContext context) {
    final tempStr = sensorData != null ? '${sensorData!.temperature.toStringAsFixed(1)}°C' : '--°C';
    final humidityStr = sensorData != null ? '${sensorData!.humidity}%' : '--%';
    final lightStr = sensorData != null ? '${sensorData!.light}%' : '--%';
    final soilStr = sensorData != null ? 'pH ${sensorData!.soilPH.toStringAsFixed(1)}' : 'pH --';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Column(
        children: [
          _SectionLabel(text: 'JAMKACHU STATUS'),
          const SizedBox(height: 6),
          _StatusJamkachuCard(
            bondLevel: _dummyBondLevel,
            hp: _dummyHp,
            xp: _dummyXp,
            days: _dummyDays,
          ),
          const SizedBox(height: 14),
          _SectionLabel(text: 'GARDEN CONDITIONS'),
          const SizedBox(height: 6),
          _GardenVitalsCard(
            temp: tempStr,
            humidity: humidityStr,
            light: lightStr,
            soil: soilStr,
          ),
          if (sensorData == null)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Waiting for sensor data...',
                style: TextStyle(fontSize: 9, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusJamkachuCard extends StatelessWidget {
  final int bondLevel;
  final double hp;
  final int xp;
  final int days;

  const _StatusJamkachuCard({
    required this.bondLevel,
    required this.hp,
    required this.xp,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8BC34A), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF8BC34A), width: 2),
                ),
                child: const Center(child: Image(image: AssetImage('assets/plant/plant_babby.png'), fit: BoxFit.contain)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ikatan Lv. $bondLevel', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text('Jamkachu', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.favorite, size: 14, color: Colors.redAccent),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: hp,
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xFF8BC34A),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('HP ${(hp * 100).round()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatChip(assetPath: 'assets/Collection/image 1031.png', label: '$xp XP')),
              const SizedBox(width: 8),
              Expanded(child: _StatChip(assetPath: 'assets/design/butterfly.png', label: '$days Days')),
            ],
          ),
        ],
      ),
    );
  }
}

class _GardenVitalsCard extends StatelessWidget {
  final String temp;
  final String humidity;
  final String light;
  final String soil;

  const _GardenVitalsCard({required this.temp, required this.humidity, required this.light, required this.soil});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: [
          _VitalTile(icon: Icons.thermostat, color: Colors.orange, label: 'TEMP', value: temp),
          _VitalTile(icon: Icons.water_drop, color: Colors.blue, label: 'AIR', value: humidity),
          _VitalTile(icon: Icons.wb_sunny, color: Colors.amber, label: 'LIGHT', value: light),
          _VitalTile(icon: Icons.science, color: Colors.brown, label: 'SOIL', value: soil),
        ],
      ),
    );
  }
}

class _VitalTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _VitalTile({required this.icon, required this.color, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String? icon;
  final String? assetPath;
  final String label;
  const _StatChip({this.icon, this.assetPath, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCEDC8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (assetPath != null)
            SizedBox(width: 16, height: 16, child: Image.asset(assetPath!, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => Text(icon ?? '', style: const TextStyle(fontSize: 11))))
          else if (icon != null)
            Text(icon!, style: const TextStyle(fontSize: 11))
          else
            const SizedBox.shrink(),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF689F38), letterSpacing: 0.5),
      ),
    );
  }
}

// --- COLLECTION SCREEN ---
class CollectionItem {
  final String id;
  final String title;
  final String? subtitleEn;
  final String emoji;
  final String? assetPath;
  final bool locked;
  final bool isNew;
  final String detailBadgeLabel;
  final String detailDescription;
  final String whyTitle;
  final String whyBody;
  final String actionBody;

  const CollectionItem({
    required this.id,
    required this.title,
    this.subtitleEn,
    required this.emoji,
    this.assetPath,
    this.locked = false,
    this.isNew = false,
    this.detailBadgeLabel = '',
    this.detailDescription = '',
    this.whyTitle = '',
    this.whyBody = '',
    this.actionBody = '',
  });
}

const List<CollectionItem> _moods = [
  CollectionItem(id: 'comfort', title: 'All Comfortable', emoji: '🌟', assetPath: 'assets/Collection/image 1023.png'),
  CollectionItem(
    id: 'overheat',
    title: 'Too Hot',
    subtitleEn: 'Overheating',
    emoji: '🥵',
    assetPath: 'assets/mood_card/overheat.png',
    detailBadgeLabel: 'MOOD DISCOVERED',
    detailDescription: '📡 The temperature sensor detected air that is too hot.',
    whyTitle: 'Too Hot to Grow',
    whyBody: 'Air that is too hot makes leaves lose water faster and slows down photosynthesis.',
    actionBody: 'Provide shade, move away from hot glass, or add airflow.',
  ),
  CollectionItem(
    id: 'too_cold',
    title: 'Too Cold',
    subtitleEn: 'Too Cold',
    emoji: '🥶',
    assetPath: 'assets/weather/cloud.png',
    detailBadgeLabel: 'MOOD DISCOVERED',
    detailDescription: '📡 The temperature sensor detected air that is too cold.',
    whyTitle: 'Too Cold to Grow',
    whyBody: 'Low temperatures slow down the plant\'s metabolism.',
    actionBody: 'Move to a warmer spot or reduce exposure to cold wind.',
  ),
  CollectionItem(
    id: 'dry_air',
    title: 'Dry Air',
    subtitleEn: 'Dry Air',
    emoji: '🍂',
    assetPath: 'assets/mood_card/dry_air.png',
    detailBadgeLabel: 'MOOD DISCOVERED',
    detailDescription: '📡 The humidity sensor detected air that is too dry.',
    whyTitle: 'Dry Air Causes Wilting',
    whyBody: 'Low humidity speeds up water evaporation from leaves.',
    actionBody: 'Mist around the leaves or place a water container nearby.',
  ),
  CollectionItem(id: 'humidity_locked', title: 'Air', emoji: '💧', assetPath: 'assets/Collection/image 1032.png'),
  CollectionItem(
    id: 'low_light',
    title: 'Low Light',
    subtitleEn: 'Low Light',
    emoji: '😴',
    assetPath: 'assets/mood_card/sleepy.png',
    detailBadgeLabel: 'MOOD DISCOVERED',
    detailDescription: '📡 The light sensor detected insufficient lighting.',
    whyTitle: 'Not Enough Light',
    whyBody: 'Without enough light, the plant struggles to produce energy.',
    actionBody: 'Move to a brighter spot or increase light duration.',
  ),
  CollectionItem(
    id: 'soil_acidic',
    title: 'Soil Too Acidic',
    subtitleEn: 'Soil Acidic',
    emoji: '🧪',
    assetPath: 'assets/Collection/image 1031.png',
    detailBadgeLabel: 'MOOD DISCOVERED',
    detailDescription: '📡 The pH sensor detected soil that is too acidic.',
    whyTitle: 'Acidic Soil Blocks Roots',
    whyBody: 'Soil pH that is too low makes it hard for roots to absorb nutrients.',
    actionBody: 'Wait for a recommendation after the sensor verifies the condition.',
  ),
  CollectionItem(
    id: 'soil_alkaline',
    title: 'Soil Too Alkaline',
    subtitleEn: 'Soil Alkaline',
    emoji: '🧂',
    assetPath: 'assets/weather/rain.png',
    detailBadgeLabel: 'MOOD DISCOVERED',
    detailDescription: '📡 The pH sensor detected soil that is too alkaline.',
    whyTitle: 'Alkaline Soil Blocks Roots',
    whyBody: 'Soil pH that is too high makes some nutrients less available.',
    actionBody: 'Wait for a recommendation after the sensor verifies the condition.',
  ),
];

const List<CollectionItem> _badges = [
  CollectionItem(id: 'badge_1', title: 'First Caretaker', emoji: '🏅', assetPath: 'assets/Collection/image 1033.png'),
  CollectionItem(id: 'badge_2', title: '7-Day Streak', emoji: '🔥', assetPath: 'assets/design/butterfly.png'),
];

const List<CollectionItem> _stories = [
  CollectionItem(id: 'story_1', title: 'First Encounter', emoji: '📜', assetPath: 'assets/Collection/image 1024.png'),
];

const List<CollectionItem> _wisdoms = [
  CollectionItem(id: 'wisdom_1', title: 'Yellow Leaves?', emoji: '🍃', assetPath: 'assets/plant/plant_flower.png'),
];

class _CollectionScreenContent extends StatefulWidget {
  final List<String> unlockedIds;
  const _CollectionScreenContent({required this.unlockedIds});
  @override
  State<_CollectionScreenContent> createState() => _CollectionScreenContentState();
}

class _CollectionScreenContentState extends State<_CollectionScreenContent> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  @override
  void initState() { super.initState(); _tabController = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(12)),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(color: const Color(0xFF386641), borderRadius: BorderRadius.circular(10)),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF386641),
              labelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(child: SizedBox(height: 32, child: Image(image: AssetImage('assets/Collection/image 1023.png'), fit: BoxFit.contain))),
                Tab(child: SizedBox(height: 32, child: Image(image: AssetImage('assets/Collection/image 1033.png'), fit: BoxFit.contain))),
                Tab(child: SizedBox(height: 32, child: Image(image: AssetImage('assets/Collection/image 1024.png'), fit: BoxFit.contain))),
                Tab(child: SizedBox(height: 32, child: Image(image: AssetImage('assets/plant/plant_flower.png'), fit: BoxFit.contain))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CollectionTab(title: 'MOOD DEX', subtitle: 'Expressions', items: _moods, unlockedIds: widget.unlockedIds, compact: true),
                _CollectionTab(title: 'BADGES', subtitle: 'Achievements', items: _badges, unlockedIds: widget.unlockedIds, compact: true),
                _CollectionTab(title: 'STORY', subtitle: 'History', items: _stories, unlockedIds: widget.unlockedIds, compact: true),
                _CollectionTab(title: 'WISDOM', subtitle: 'Tips', items: _wisdoms, unlockedIds: widget.unlockedIds, compact: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionTab extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<CollectionItem> items;
  final List<String> unlockedIds;
  final bool compact;
  const _CollectionTab({required this.title, required this.subtitle, required this.items, required this.unlockedIds, this.compact = false});
  @override
  State<_CollectionTab> createState() => _CollectionTabState();
}

class _CollectionTabState extends State<_CollectionTab> {
  late CollectionItem _selected;
  @override
  void initState() {
    super.initState();
    _selected = widget.items.firstWhere((i) => widget.unlockedIds.contains(i.id), orElse: () => widget.items.first);
  }
  @override
  Widget build(BuildContext context) {
    final unlockedCount = widget.items.where((i) => widget.unlockedIds.contains(i.id)).length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF8BC34A), width: 2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF689F38))), Text(widget.subtitle, style: const TextStyle(fontSize: 10))])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(8)), child: Text('$unlockedCount/${widget.items.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.0),
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isUnlocked = widget.unlockedIds.contains(item.id);
                  final isSelected = _selected.id == item.id;
                  return GestureDetector(onTap: !isUnlocked ? null : () => setState(() => _selected = item), child: _CollectionTile(item: item, selected: isSelected, unlocked: isUnlocked));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ItemDetailCard(item: _selected, unlocked: widget.unlockedIds.contains(_selected.id)),
      ],
    );
  }
}

class _CollectionTile extends StatelessWidget {
  final CollectionItem item;
  final bool selected;
  final bool unlocked;
  const _CollectionTile({required this.item, required this.selected, required this.unlocked});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(color: selected ? const Color(0xFF8BC34A).withOpacity(0.1) : const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? const Color(0xFF8BC34A) : Colors.grey.shade300, width: selected ? 2 : 1)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (unlocked && item.assetPath != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(item.assetPath!, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => Text(item.emoji, style: const TextStyle(fontSize: 24))),
            ),
          )
        else if (unlocked)
          Text(item.emoji, style: const TextStyle(fontSize: 24))
        else
          const Icon(Icons.lock, size: 24, color: Colors.grey),
        const SizedBox(height: 4),
        Text(item.title, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: unlocked ? Colors.black87 : Colors.grey))
      ]),
    );
  }
}

class _ItemDetailCard extends StatelessWidget {
  final CollectionItem item;
  final bool unlocked;
  const _ItemDetailCard({required this.item, required this.unlocked});
  @override
  Widget build(BuildContext context) {
    if (!unlocked) return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)), child: const Column(children: [Icon(Icons.lock, size: 32, color: Colors.grey), Text('Not unlocked yet', style: TextStyle(fontWeight: FontWeight.bold))]));
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFEAF7ED), Color(0xFF8BC34A)]), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))), child: Row(children: [
          if (item.assetPath != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Image.asset(item.assetPath!, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => Text(item.emoji, style: const TextStyle(fontSize: 32))),
              ),
            )
          else
            Text(item.emoji, style: const TextStyle(fontSize: 32)),
          Expanded(child: Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
        ])),
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (item.whyTitle.isNotEmpty) _DetailSection(icon: '💡', label: 'WHY?', title: item.whyTitle, body: item.whyBody), if (item.actionBody.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: _DetailSection(icon: '🎯', label: 'ACTION', title: '', body: item.actionBody))])),
      ]),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String icon;
  final String label;
  final String title;
  final String body;
  const _DetailSection({required this.icon, required this.label, required this.title, required this.body});
  @override
  Widget build(BuildContext context) {
    IconData iconData;
    if (icon == '💡') {
      iconData = Icons.lightbulb;
    } else if (icon == '🎯') {
      iconData = Icons.flag;
    } else {
      iconData = Icons.info;
    }
    return Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF7F9F4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE0E7D4))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(iconData, size: 16, color: const Color(0xFF689F38)), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF689F38)))]), const SizedBox(height: 4), if (title.isNotEmpty) Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), Text(body, style: const TextStyle(fontSize: 11, color: Colors.black54))]));
  }
}

// --- DIARY SCREEN ---

class _DiaryScreenContent extends StatefulWidget {
  final List<DiaryEntry> entries;
  final bool isDay; 
  final Function(DiaryEntry) onAddEntry;
  const _DiaryScreenContent({required this.entries,
  required this.isDay,
   required this.onAddEntry});
  @override
  State<_DiaryScreenContent> createState() => _DiaryScreenContentState();
}

class _DiaryScreenContentState extends State<_DiaryScreenContent> {
  String _selectedStage = 'thrive';
  final List<String> _stages = const ['thrive', 'starting to adapt', 'growing', 'flourish', ' mature plant'];
  @override
  Widget build(BuildContext context) {
    final featuredEntry = widget.entries.isNotEmpty ? widget.entries.first : null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Document its growth journey.',
          style: TextStyle(fontSize: 10, color: widget.isDay ? Colors.black54 : Colors.white),
        ),                                                                                        
        const SizedBox(height: 12),
        _SectionLabel(text: 'Selected memories'),
        if (featuredEntry != null) _DiaryFeaturedCard(entry: featuredEntry) else const Center(child: Text('No memories yet.', style: TextStyle(fontSize: 9))),
        const SizedBox(height: 14),
        _DiaryTimelineList(entries: widget.entries),
        const SizedBox(height: 16),
        _SectionLabel(text: 'ADD NOTES'),
        _DiaryAddNoteForm(stages: _stages, selectedStage: _selectedStage, onStageChanged: (v) => setState(() => _selectedStage = v), onSubmit: widget.onAddEntry),
        const SizedBox(height: 16),
        _SectionLabel(text: 'PREVIOUS NOTES'),
        ...widget.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _DiarySnapshotCard(entry: e))),
      ]),
    );
  }
}

class _DiaryFeaturedCard extends StatelessWidget {
  final DiaryEntry entry;
  const _DiaryFeaturedCard({required this.entry});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF8BC34A), width: 2)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(aspectRatio: 16 / 9, child: Container(color: const Color(0xFFF1F8E9), child: const Center(child: Image(image: AssetImage('assets/plant/plant_flower.png'), fit: BoxFit.contain)))),
        Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF386641), borderRadius: BorderRadius.circular(10)), child: Text(entry.stage, style: const TextStyle(fontSize: 8, color: Colors.white))), const SizedBox(width: 6), Text(entry.date, style: const TextStyle(fontSize: 9))]), if (entry.quote.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text('"${entry.quote}"', style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic)))]))
      ]),
    );
  }
}

class _DiaryTimelineList extends StatelessWidget {
  final List<DiaryEntry> entries;
  const _DiaryTimelineList({required this.entries});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade300)),
      child: Column(children: [for (var e in entries.take(3)) ListTile(leading: SizedBox(width: 24, height: 24, child: Image.asset('assets/plant/plant_babby.png', fit: BoxFit.contain)), title: Text('Perkembangan: ${e.stage}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), subtitle: Text(e.date, style: const TextStyle(fontSize: 8)))]),
    );
  }
}

class _DiaryAddNoteForm extends StatefulWidget {
  final List<String> stages;
  final String selectedStage;
  final ValueChanged<String> onStageChanged;
  final Function(DiaryEntry) onSubmit;
  const _DiaryAddNoteForm({required this.stages, required this.selectedStage, required this.onStageChanged, required this.onSubmit});
  @override
  State<_DiaryAddNoteForm> createState() => _DiaryAddNoteFormState();
}

class _DiaryAddNoteFormState extends State<_DiaryAddNoteForm> {
  final _heightController = TextEditingController();
  final _leafController = TextEditingController();
  final _noteController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 6, children: widget.stages.map((s) => GestureDetector(onTap: () => widget.onStageChanged(s), child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: s == widget.selectedStage ? const Color(0xFF386641) : const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(8)), child: Text(s, style: TextStyle(fontSize: 8, color: s == widget.selectedStage ? Colors.white : Colors.black87))))).toList()),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: _DiaryMiniField(controller: _heightController, label: 'Height (cm)', keyboardType: TextInputType.number)), const SizedBox(width: 8), Expanded(child: _DiaryMiniField(controller: _leafController, label: 'Leaf', keyboardType: TextInputType.number))]),
        const SizedBox(height: 8),
        _DiaryMiniField(controller: _noteController, label: 'Notes', maxLines: 2),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
          final entry = DiaryEntry(id: DateTime.now().toString(), date: '${DateTime.now().day} ${DateTime.now().month} ${DateTime.now().year}', stage: widget.selectedStage, quote: _noteController.text, heightCm: double.tryParse(_heightController.text), leafCount: int.tryParse(_leafController.text));
          widget.onSubmit(entry);
          _noteController.clear(); _heightController.clear(); _leafController.clear();
        }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF386641)), child: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 11)))),
      ]),
    );
  }
}

class _DiaryMiniField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;
  const _DiaryMiniField({required this.controller, required this.label, this.keyboardType, this.maxLines = 1});
  @override
  Widget build(BuildContext context) {
    return TextField(controller: controller, keyboardType: keyboardType, maxLines: maxLines, style: const TextStyle(fontSize: 10), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(fontSize: 9), isDense: true, contentPadding: const EdgeInsets.all(8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))));
  }
}

class _DiarySnapshotCard extends StatelessWidget {
  final DiaryEntry entry;
  const _DiarySnapshotCard({required this.entry});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade300)),
      padding: const EdgeInsets.all(10),
      child: Row(children: [Container(width: 40, height: 40, color: const Color(0xFFF1F8E9), child: const Icon(Icons.eco, size: 20, color: Color(0xFF8BC34A))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(entry.stage, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF386641))), const SizedBox(width: 6), Text(entry.date, style: const TextStyle(fontSize: 8, color: Colors.grey))]), if (entry.quote.isNotEmpty) Text(entry.quote, maxLines: 1, style: const TextStyle(fontSize: 9))]))]),
    );
  }
}

// --- COMMON UI WIDGETS ---

class JamkachuInnerPainter extends CustomPainter {
  final bool isDay;
  JamkachuInnerPainter({required this.isDay});
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: isDay ? [const Color(0xFFE1F5FE), const Color(0xFFFFFFFF)] : [const Color(0xFF0D1B2A), const Color(0xFF1B263B)]).createShader(rect));
    final Paint dot = Paint()..color = Colors.grey.withOpacity(isDay ? 0.2 : 0.12);
    for (double x = 0; x < size.width; x += size.width / 10) { for (double y = 0; y < size.height; y += size.width / 10) { canvas.drawCircle(Offset(x, y), 1.5, dot); } }
    final double gh = size.height * 0.22;
    canvas.drawRect(Rect.fromLTWH(0, size.height - gh, size.width, gh), Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: isDay ? [const Color(0xFF8BC34A), const Color(0xFF689F38)] : [const Color(0xFF33691E), const Color(0xFF1B5E20)]).createShader(Rect.fromLTWH(0, size.height - gh, size.width, gh)));
  }
  @override
  bool shouldRepaint(JamkachuInnerPainter old) => old.isDay != isDay;
}

class AiNpcCharacter extends StatefulWidget {
  const AiNpcCharacter({super.key});
  @override
  _AiNpcCharacterState createState() => _AiNpcCharacterState();
}

class _AiNpcCharacterState extends State<AiNpcCharacter> {
  double _posX = 0.0; late Timer _t;
  @override
  void initState() { super.initState(); _t = Timer.periodic(const Duration(seconds: 3), (t) { if (mounted) setState(() { _posX = math.Random().nextDouble() * 140 - 70; }); }); }
  @override
  void dispose() { _t.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) { return AnimatedContainer(duration: const Duration(seconds: 2), transform: Matrix4.translationValues(_posX, 0, 0), child: Column(children: [Container(padding: const EdgeInsets.all(2), color: Colors.yellow, child: const Text('Farmer', style: TextStyle(fontSize: 6))), Image.asset('assets/logo/npc.png', width: 50, height: 50, fit: BoxFit.contain)])); }
}

class AnimatedPixelCharacter extends StatefulWidget {
  final String assetPath;
  const AnimatedPixelCharacter({required this.assetPath});
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
  Widget build(BuildContext context) { return AnimatedBuilder(animation: _a, builder: (ctx, child) => Transform.translate(offset: Offset(0, _a.value), child: Image.asset(widget.assetPath, width: 120, height: 120, fit: BoxFit.contain))); }
}

class FooterIconButton extends StatelessWidget {
  final String assetPath;
  final String tooltip;
  final VoidCallback onTap;
  const FooterIconButton({super.key, required this.assetPath, required this.tooltip, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Tooltip(message: tooltip, child: GestureDetector(onTap: onTap, child: SizedBox(width: 50, height: 50, child: Padding(padding: const EdgeInsets.all(8.0), child: Image.asset(assetPath, fit: BoxFit.contain)))));
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF8BC34A))), child: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF386641))));
  }
}

class _PlaceholderScreenContent extends StatelessWidget {
  final String? emoji;
  final String? assetPath;
  final String label;
  const _PlaceholderScreenContent({this.emoji, this.assetPath, required this.label});
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      if (assetPath != null)
        SizedBox(width: 80, height: 80, child: Image.asset(assetPath!, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => Text(emoji ?? '', style: const TextStyle(fontSize: 32))))
      else if (emoji != null)
        Text(emoji!, style: const TextStyle(fontSize: 32))
      else
        const SizedBox.shrink(),
      const SizedBox(height: 16),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey))
    ]));
  }
}
