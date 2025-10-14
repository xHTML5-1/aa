import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'core/coffee_image_analyzer.dart';
import 'core/constellation_pattern.dart';
import 'core/fortune_vault.dart';
import 'widgets/constellation_painter.dart';
import 'widgets/scan_overlay.dart';
import 'widgets/starfield.dart';

class CoffeeFortuneApp extends StatelessWidget {
  const CoffeeFortuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kahve Falı Orkestrası',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A3CBC)),
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Poppins',
      ),
      home: const FortuneHomePage(),
    );
  }
}

enum ReadingStage {
  idle,
  validating,
  scanning,
  marking,
  revealing,
}

class FortuneHomePage extends StatefulWidget {
  const FortuneHomePage({super.key});

  @override
  State<FortuneHomePage> createState() => _FortuneHomePageState();
}

class _FortuneHomePageState extends State<FortuneHomePage>
    with TickerProviderStateMixin {
  Uint8List? _selectedImage;
  ReadingStage _stage = ReadingStage.idle;
  String? _error;
  String? _fortune;
  ConstellationPattern? _constellation;
  late final AnimationController _scanController;
  late final AnimationController _constellationController;
  late final AnimationController _galaxyController;
  final CoffeeImageAnalyzer _analyzer = CoffeeImageAnalyzer();

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _constellationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _galaxyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _constellationController.dispose();
    _galaxyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() {
      _error = null;
      _fortune = null;
      _constellation = null;
      _stage = ReadingStage.validating;
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );

    if (!mounted) {
      return;
    }

    if (result == null || result.files.isEmpty) {
      setState(() {
        _stage = ReadingStage.idle;
      });
      return;
    }

    final file = result.files.first;
    final bytes = file.bytes;

    if (bytes == null) {
      setState(() {
        _stage = ReadingStage.idle;
        _error = 'Seçilen görsel okunamadı. Lütfen tekrar deneyin.';
      });
      return;
    }

    setState(() {
      _selectedImage = bytes;
    });

    await _runAnalysis(bytes);
  }

  Future<void> _runAnalysis(Uint8List bytes) async {
    setState(() {
      _stage = ReadingStage.validating;
    });

    final result = await _analyzer.analyze(bytes);

    if (!mounted) {
      return;
    }

    if (!result.isValid) {
      setState(() {
        _stage = ReadingStage.idle;
        _error = result.reason ??
            'Bu görselde telve ve fincan izleri algılanamadı. Lütfen gerçek bir kahve falı fotoğrafı seçin.';
      });
      return;
    }

    setState(() {
      _stage = ReadingStage.scanning;
      _constellation = result.constellation;
    });

    _scanController
      ..reset()
      ..repeat(reverse: false);

    await Future<void>.delayed(const Duration(milliseconds: 2800));

    if (!mounted) {
      return;
    }

    _scanController.stop();

    setState(() {
      _stage = ReadingStage.marking;
    });

    _constellationController
      ..reset()
      ..forward();

    await Future<void>.delayed(const Duration(milliseconds: 1900));

    if (!mounted) {
      return;
    }

    setState(() {
      _stage = ReadingStage.revealing;
      _fortune = FortuneVault.pickFortune(seed: bytes.hashCode);
    });

    _galaxyController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.headlineMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );
    final bodyStyle = theme.textTheme.bodyLarge?.copyWith(
      color: Colors.white70,
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _galaxyController,
            builder: (context, _) {
              final progress = Curves.easeOut.transform(_galaxyController.value);
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(const Color(0xFF05030F), const Color(0xFF12063A), progress)!,
                      Color.lerp(const Color(0xFF12063A), const Color(0xFF431B76), progress)!,
                      Color.lerp(const Color(0xFF431B76), const Color(0xFF02010B), progress)!,
                    ],
                  ),
                ),
              );
            },
          ),
          if (_stage == ReadingStage.revealing)
            AnimatedOpacity(
              opacity: _galaxyController.value,
              duration: const Duration(milliseconds: 800),
              child: Starfield(
                animation: _galaxyController,
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Kahve Falı Orkestrası', style: headlineStyle),
                  const SizedBox(height: 8),
                  Text(
                    'Gerçek bir kahve fincanı ve telve fotoğrafını yükle, yıldızlar sana özel bir fal fısıldasın.',
                    textAlign: TextAlign.center,
                    style: bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: _stage == ReadingStage.validating
                            ? null
                            : () {
                                unawaited(_pickImage());
                              },
                        icon: const Icon(Icons.file_upload_outlined),
                        label: const Text('Fincan Fotoğrafı Yükle'),
                      ),
                      if (_selectedImage != null)
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                              _fortune = null;
                              _constellation = null;
                              _stage = ReadingStage.idle;
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Yeni Fal Çek'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (_selectedImage == null) {
                          return _EmptyState(stage: _stage);
                        }
                        return _buildPreview(constraints.biggest);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              _error!,
                              style: bodyStyle?.copyWith(color: Colors.redAccent.shade100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_fortune != null)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 900),
                      opacity: _stage == ReadingStage.revealing ? 1 : 0,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16, top: 8),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.08),
                              Colors.purple.withOpacity(0.12),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.35),
                              blurRadius: 32,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          _fortune!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(Size size) {
    final constellation = _constellation;
    final image = _selectedImage;
    if (image == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 640),
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Image.memory(
                    image,
                    key: ValueKey<int>(image.hashCode),
                    fit: BoxFit.cover,
                  ),
                ),
                if (_stage == ReadingStage.scanning)
                  ScanOverlay(animation: _scanController),
                if (constellation != null && _stage != ReadingStage.validating)
                  AnimatedBuilder(
                    animation: _constellationController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: ConstellationPainter(
                          pattern: constellation,
                          progress: _stage == ReadingStage.marking ||
                                  _stage == ReadingStage.revealing
                              ? CurvedAnimation(
                                  parent: _constellationController,
                                  curve: Curves.easeOutCubic,
                                ).value
                              : 0,
                        ),
                      );
                    },
                  ),
                if (_stage == ReadingStage.validating)
                  const _BusyOverlay(message: 'Fincan taraması yapılıyor...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.stage});

  final ReadingStage stage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = theme.textTheme.titleLarge?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
    final body = theme.textTheme.bodyLarge?.copyWith(color: Colors.white70);

    final message = switch (stage) {
      ReadingStage.validating => 'Görsel analiz ediliyor... Telveler aranıyor.',
      ReadingStage.scanning => 'Tarama başlıyor! Finacın sırları çözülüyor.',
      ReadingStage.marking => 'Telve izleri işaretleniyor, dikkatle bak.',
      ReadingStage.revealing => 'Kozmik bağlar kuruluyor, fal birazdan burada.',
      _ => 'Kahve fincanının içindeki evreni göster; telve fotoğrafını yükle.',
    };

    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 600),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            color: Colors.white.withOpacity(0.04),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.coffee_maker_outlined, color: Colors.white70, size: 72),
              const SizedBox(height: 16),
              Text('Telve için hazırız', style: title, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(message, style: body, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusyOverlay extends StatelessWidget {
  const _BusyOverlay({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: Colors.black.withOpacity(0.45),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.black.withOpacity(0.72),
            border: Border.all(color: Colors.purpleAccent.withOpacity(0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.purpleAccent),
              ),
              const SizedBox(width: 16),
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
