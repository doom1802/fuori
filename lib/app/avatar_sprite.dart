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
    for (var i = 0; i < 18; i++) {
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
    final bodyWidth = female ? .94 : 1.0;
    final rear = const [2, 3, 4].contains(direction);
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
    // Hair has a rear silhouette and a foreground fringe. A wig's generated
    // opening is not a reliable face mask: register both passes to the same
    // crown, and protect the facial plane in the foreground pass.
    void hairLayer() {
      if (look.hairModel == 3) return;
      canvas.save();
      if (look.accessoryMask & 0x18 != 0) {
        canvas.clipRect(const Rect.fromLTWH(0, 51, 128, 205));
      }
      layer(
        'hair',
        'hair',
        look.hairModel,
        look.hairModel == 7
            ? const Rect.fromLTWH(23, 25, 84, 90)
            : Rect.fromLTWH(
                13,
                18,
                104,
                look.hairModel >= 4 && look.hairModel <= 6 ? 117 : 96,
              ),
        tint: overrides?[1] ?? color(1),
        enabled: overrides != null || look.hair != 0,
        reference: const Color(0xFF392B29),
        alignment: Alignment.topCenter,
      );
      canvas.restore();
    }

    hairLayer();
    canvas.save();
    canvas.clipRect(const Rect.fromLTWH(0, 0, 128, 233));
    if (look.bottomModel == 4 || look.bottomModel == 6) {
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
    }
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
    final topAtlas = wave ? 'tops-wave' : 'tops';
    final topTarget = Rect.fromLTWH(
      64 - 47 * bodyWidth,
      wave ? 109 : 111,
      94 * bodyWidth,
      wave ? 82 : 78,
    );
    final topSource = assets.source(topAtlas, look.topModel, direction)!;
    final topBounds = Alignment.topCenter.inscribe(
      applyBoxFit(BoxFit.contain, topSource.size, topTarget.size).destination,
      topTarget,
    );
    void forearm(double x, double top, double bottom) {
      if (bottom <= top) return;
      canvas.drawRect(
        Rect.fromLTRB(x - 4, top, x + 4, bottom),
        Paint()
          ..color = const Color(0xFF312B2C)
          ..isAntiAlias = false,
      );
      canvas.drawRect(
        Rect.fromLTRB(x - 2, top, x + 2, bottom),
        Paint()
          ..color = skin
          ..isAntiAlias = false,
      );
    }

    // Hands follow the sleeve bounds, including narrower profile views.
    for (final left in [true, false]) {
      if (wave && left != (direction < 4)) continue;
      final sideView = direction == 1 || direction == 5;
      final fraction = left ? (sideView ? .28 : .1) : (sideView ? .72 : .9);
      final x = topBounds.left + topBounds.width * fraction;
      final y = topBounds.bottom - 5;
      if (look.topModel == 1) {
        forearm(x, topBounds.top + topBounds.height * .66, y + 4);
      }
      layer(
        'body',
        left ? 'body-hand-left' : 'body-hand-right',
        idleRow,
        Rect.fromLTWH(x - 7, y, 14, 20),
        tint: skin,
        enabled: true,
        reference: skinRef,
        alignment: Alignment.topCenter,
      );
    }
    if (wave) {
      final x = direction < 4 ? topBounds.right - 7 : topBounds.left + 7;
      forearm(x, 109, topBounds.top + 24);
      layer(
        'body',
        'body-raised',
        idleRow,
        Rect.fromLTWH(x - 9, 90, 18, 26),
        tint: skin,
        enabled: true,
        reference: skinRef,
        alignment: Alignment.bottomCenter,
      );
    }
    layer(
      topAtlas,
      topAtlas,
      look.topModel,
      topTarget,
      tint: overrides?[0] ?? color(0),
      enabled: overrides != null || look.clothes != 0,
      alignment: Alignment.topCenter,
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
      if (!rear) {
        final face = Path();
        if (direction == 7) {
          face.moveTo(37, 62);
          face.lineTo(94, 62);
          face.lineTo(98, 96);
          face.lineTo(83, 112);
          face.lineTo(48, 112);
          face.lineTo(33, 96);
        } else {
          final left = direction == 5 || direction == 6;
          // Mirrored three-quarter planes keep eyes, cheek and jaw intact.
          double x(double value) => left ? 130 - value : value;
          face.moveTo(x(54), 60);
          face.lineTo(x(99), 60);
          face.lineTo(x(103), 88);
          face.lineTo(x(91), 109);
          face.lineTo(x(68), 113);
          face.lineTo(x(53), 96);
        }
        face.close();
        canvas.clipPath(
          Path.combine(
            PathOperation.difference,
            Path()..addRect(const Rect.fromLTWH(0, 0, 128, 256)),
            face,
          ),
          doAntiAlias: false,
        );
      }
      hairLayer();
      canvas.restore();
    }
    for (var i = 0; i < 8; i++) {
      if (look.accessoryMask & (1 << i) == 0) continue;
      if (i == 6 && ![2, 3, 4].contains(direction)) continue;
      if (i < 3 && [2, 3, 4].contains(direction)) continue;
      final target = switch (i) {
        0 || 1 || 2 => switch (direction) {
          7 => const Rect.fromLTWH(36, 58, 58, 23),
          1 => const Rect.fromLTWH(72, 58, 32, 23),
          5 => const Rect.fromLTWH(26, 58, 32, 23),
          6 => const Rect.fromLTWH(28, 58, 49, 23),
          _ => const Rect.fromLTWH(53, 58, 49, 23),
        },
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
