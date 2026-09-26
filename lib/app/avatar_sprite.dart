import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/account/avatar_look.dart';
import 'avatar_palette.dart';

class AvatarSpriteAssets {
  AvatarSpriteAssets(this.images, this.index, this.program);
  final Map<String, ui.Image> images;
  final Map<String, dynamic> index;
  final ui.FragmentProgram program;
  static Future<AvatarSpriteAssets>? _cached;
  static AvatarSpriteAssets? loaded;
  static Future<AvatarSpriteAssets> preload() => _cached ??= _load();
  static Future<AvatarSpriteAssets> _load() async {
    final images = <String, ui.Image>{};
    try {
      for (final name in [
        'body',
        'hair',
        'tops',
        'tops-wave',
        'bottoms',
        'footwear',
        'extras',
      ]) {
        final data = await rootBundle.load(
          'assets/avatar/catalog/$name-v1.png',
        );
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        try {
          images[name] = (await codec.getNextFrame()).image;
        } finally {
          codec.dispose();
        }
      }
      final index = jsonDecode(
        await rootBundle.loadString('assets/avatar/catalog/index-v1.json'),
      ) as Map<String, dynamic>;
      final program = await ui.FragmentProgram.fromAsset(
        'assets/shaders/avatar_layer.frag',
      );
      return loaded = AvatarSpriteAssets(images, index, program);
    } catch (_) {
      for (final image in images.values) {
        image.dispose();
      }
      rethrow;
    }
  }

  static void retry() {
    _cached = null;
  }

  Rect? source(String name, int row, int direction) {
    final values = (index[name] as List)[row][direction] as List?;
    if (values == null) return null;
    return Rect.fromLTWH(
      (values[0] as num).toDouble(),
      (values[1] as num).toDouble(),
      (values[2] as num).toDouble(),
      (values[3] as num).toDouble(),
    );
  }
}

/// Original sprites composed by catalog item, shared by both body bases.
class AvatarSprite extends StatefulWidget {
  const AvatarSprite({
    super.key,
    this.look,
    this.body = AvatarBody.male,
    this.hairStyle = AvatarHairStyle.spiky,
    this.coat = const Color(0xFF9B8DBF),
    this.hair = const Color(0xFF392B29),
    this.skin = const Color(0xFFE2AD84),
    this.pants = const Color(0xFF434752),
    this.shoes = const Color(0xFFFAF5E7),
    this.glasses = false,
    this.wave = false,
    this.direction = 0,
    this.headOnly = false,
  });
  final AvatarLook? look;
  final AvatarBody body;
  final AvatarHairStyle hairStyle;
  final Color coat, hair, skin, pants, shoes;
  final bool glasses, wave, headOnly;
  final int direction;
  @override
  State<AvatarSprite> createState() => _AvatarSpriteState();
}

class _AvatarSpriteState extends State<AvatarSprite> {
  AvatarSpriteAssets? _assets;
  final List<ui.FragmentShader> _shaders = [];
  bool _error = false;
  @override
  void initState() {
    super.initState();
    if (AvatarSpriteAssets.loaded case final assets?) {
      _setAssets(assets);
    } else {
      _load();
    }
  }

  void _setAssets(AvatarSpriteAssets assets) {
    _assets = assets;
    for (var i = 0; i < 14; i++) {
      _shaders.add(assets.program.fragmentShader());
    }
  }

  Future<void> _load() async {
    try {
      final assets = await AvatarSpriteAssets.preload();
      if (!mounted) return;
      setState(() {
        _setAssets(assets);
        _error = false;
      });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    for (final shader in _shaders) {
      shader.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Center(
        child: IconButton(
          tooltip: 'Riprova a caricare il personaggio',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () {
            AvatarSpriteAssets.retry();
            setState(() => _error = false);
            _load();
          },
        ),
      );
    }
    if (_assets == null) {
      return const Center(
        child: SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    final look =
        widget.look ??
        AvatarLook(
          body: widget.body,
          hairStyle: widget.hairStyle,
          extra: widget.glasses ? 1 : 0,
        );
    return Semantics(
      image: true,
      label:
          'Avatar ${look.body == AvatarBody.male ? 'maschile' : 'femminile'}, vista ${(widget.direction % 8) + 1} di 8',
      child: CustomPaint(
        painter: _AvatarPainter(
          assets: _assets!,
          shaders: _shaders,
          look: look,
          direction: widget.direction % 8,
          wave: widget.wave,
          headOnly: widget.headOnly,
          overrides: widget.look == null
              ? [
                  widget.coat,
                  widget.hair,
                  widget.pants,
                  widget.shoes,
                  widget.skin,
                ]
              : null,
        ),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  _AvatarPainter({
    required this.assets,
    required this.shaders,
    required this.look,
    required this.direction,
    required this.wave,
    required this.headOnly,
    this.overrides,
  });
  final AvatarSpriteAssets assets;
  final List<ui.FragmentShader> shaders;
  final AvatarLook look;
  final int direction;
  final bool wave, headOnly;
  final List<Color>? overrides;
  int _shaderIndex = 0;

  @override
  void paint(Canvas canvas, Size size) {
    _shaderIndex = 0;
    // All layers share a 128x256 registration space. Source boxes are metadata,
    // leaving the generated PNGs untouched and preserving transparent cutouts.
    canvas.save();
    if (headOnly) {
      final scale = size.width / 108;
      canvas.scale(scale);
      canvas.translate(-10, -12);
    } else {
      final scale = (size.width / 128).clamp(0.0, size.height / 256);
      canvas.translate(
        (size.width - 128 * scale) / 2,
        (size.height - 256 * scale) / 2,
      );
      canvas.scale(scale);
    }
    final female = look.body == AvatarBody.female;
    final idleRow = female ? 1 : 0;
    final poseRow = idleRow + (wave ? 2 : 0);
    final bodyWidth = female ? .94 : 1.0;
    Color color(int category) =>
        AvatarPalette.colors[category][look.choices[category]];
    void layer(
      String atlas,
      String key,
      int row,
      Rect target, {
      Color? tint,
      bool enabled = false,
      Color reference = const Color(0xFF9B8DBF),
      Alignment alignment = Alignment.center,
    }) {
      var source = assets.source(key, row, direction);
      if (source == null) return;
      if (key == 'body-legs') {
        source = Rect.fromLTWH(
          source.left,
          source.top,
          source.width,
          source.height * .65,
        );
      }
      final image = assets.images[atlas]!;
      final fitted = applyBoxFit(BoxFit.contain, source.size, target.size);
      final dest = alignment.inscribe(fitted.destination, target);
      final shader = shaders[_shaderIndex++];
      final floats = <double>[
        dest.width,
        dest.height,
        image.width.toDouble(),
        image.height.toDouble(),
        source.left,
        source.top,
        source.width,
        source.height,
        (tint ?? Colors.white).r,
        (tint ?? Colors.white).g,
        (tint ?? Colors.white).b,
        reference.r,
        reference.g,
        reference.b,
        enabled ? 1 : 0,
      ];
      for (var i = 0; i < floats.length; i++) {
        shader.setFloat(i, floats[i]);
      }
      shader.setImageSampler(0, image);
      canvas.save();
      canvas.translate(dest.left, dest.top);
      canvas.drawRect(Offset.zero & dest.size, Paint()..shader = shader);
      canvas.restore();
    }

    final skin = overrides?[4] ?? color(5);
    const skinRef = Color(0xFFE2AD84);
    canvas.save();
    canvas.clipRect(const Rect.fromLTWH(0, 0, 128, 233));
    layer(
      'body',
      'body-legs',
      idleRow,
      const Rect.fromLTWH(31, 193, 66, 39),
      tint: skin,
      enabled: true,
      reference: skinRef,
      alignment: Alignment.bottomCenter,
    );
    canvas.restore();
    if (look.accessoryMask & (1 << 6) != 0 && ![2, 3, 4].contains(direction)) {
      layer('extras', 'extras', 6, const Rect.fromLTWH(15, 124, 94, 78));
    }
    if (look.bottomModel != 7) {
      layer(
        'bottoms',
        'bottoms',
        look.bottomModel,
        Rect.fromLTWH(25, 176, 80 * bodyWidth, look.bottomModel == 4 ? 35 : 65),
        tint: overrides?[2] ?? color(2),
        enabled: overrides != null || look.pants != 0,
        reference: const Color(0xFF434752),
        alignment: Alignment.topCenter,
      );
    }
    layer(
      'body',
      'body-head',
      idleRow,
      const Rect.fromLTWH(25, 25, 80, 91),
      tint: skin,
      enabled: true,
      reference: skinRef,
      alignment: Alignment.bottomCenter,
    );
    layer(
      'body',
      'body-hands',
      poseRow,
      const Rect.fromLTWH(13, 173, 103, 24),
      tint: skin,
      enabled: true,
      reference: skinRef,
    );
    if (wave) {
      layer(
        'body',
        'body-raised',
        idleRow,
        Rect.fromLTWH(direction < 4 ? 85 : 14, 90, 25, 29),
        tint: skin,
        enabled: true,
        reference: skinRef,
      );
    }
    if (wave) {
      // Pixel steps connect the skin hand to the raised sleeve in every view.
      final right = direction < 4;
      final armX = right ? 96.0 : 25.0;
      final edge = Paint()
        ..color = const Color(0xFF312B2C)
        ..isAntiAlias = false;
      final fill = Paint()
        ..color = skin
        ..isAntiAlias = false;
      for (var step = 0; step < 3; step++) {
        final x = armX + (right ? step * 2 : -step * 2);
        canvas.drawRect(Rect.fromLTWH(x, 112 + step * 8, 8, 12), edge);
        canvas.drawRect(Rect.fromLTWH(x + 2, 112 + step * 8, 4, 10), fill);
      }
    }
    layer(
      wave ? 'tops-wave' : 'tops',
      wave ? 'tops-wave' : 'tops',
      look.topModel,
      Rect.fromLTWH(17, wave ? 109 : 111, 94 * bodyWidth, wave ? 82 : 78),
      tint: overrides?[0] ?? color(0),
      enabled: overrides != null || look.clothes != 0,
    );
    if (look.bottomModel == 7) {
      layer(
        'bottoms',
        'bottoms',
        7,
        Rect.fromLTWH(25, 124, 80 * bodyWidth, 109),
        tint: overrides?[2] ?? color(2),
        enabled: overrides != null || look.pants != 0,
        reference: const Color(0xFF434752),
      );
    }
    for (var foot = 0; foot < 2; foot++) {
      final tall = look.shoeModel == 4 || look.shoeModel == 5;
      final side = direction == 1 || direction == 5;
      final x = side ? (foot == 0 ? 40.0 : 54.0) : (foot == 0 ? 27.0 : 61.0);
      layer(
        'footwear',
        'footwear',
        look.shoeModel,
        Rect.fromLTWH(
          x,
          tall ? (foot == 0 ? 214 : 221) : (foot == 0 ? 224 : 231),
          side ? 48 : 45,
          tall ? 35 : 27,
        ),
        tint: overrides?[3] ?? color(3),
        enabled: overrides != null || look.shoes != 0,
        reference: const Color(0xFFFAF5E7),
        alignment: Alignment.bottomCenter,
      );
    }
    if (look.hairModel != 3) {
      canvas.save();
      if (look.accessoryMask & 0x18 != 0) {
        canvas.clipRect(const Rect.fromLTWH(0, 51, 128, 205));
      }
      layer(
        'hair',
        'hair',
        look.hairModel,
        Rect.fromLTWH(
          17,
          12,
          96,
          look.hairModel >= 4 && look.hairModel <= 6 ? 117 : 96,
        ),
        tint: overrides?[1] ?? color(1),
        enabled: overrides != null || look.hair != 0,
        reference: const Color(0xFF392B29),
        alignment: Alignment.topCenter,
      );
      canvas.restore();
    }
    for (var i = 0; i < 8; i++) {
      if (look.accessoryMask & (1 << i) == 0) continue;
      if (i == 6 && ![2, 3, 4].contains(direction)) continue;
      if (i < 3 && [2, 3, 4].contains(direction)) continue;
      final target = switch (i) {
        0 || 1 || 2 => const Rect.fromLTWH(30, 77, 65, 26),
        3 || 4 => const Rect.fromLTWH(15, 14, 99, 62),
        5 => const Rect.fromLTWH(16, 25, 100, 87),
        6 => const Rect.fromLTWH(22, 128, 84, 76),
        _ => const Rect.fromLTWH(24, 121, 87, 80),
      };
      layer('extras', 'extras', i, target);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter old) =>
      old.look.toJson().toString() != look.toJson().toString() ||
      old.direction != direction ||
      old.wave != wave ||
      old.headOnly != headOnly ||
      old.overrides.toString() != overrides.toString();
}
