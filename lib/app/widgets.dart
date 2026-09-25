import 'package:flutter/material.dart';

import 'fuori_theme.dart';

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
  );
}

class DemoNotice extends StatelessWidget {
  const DemoNotice({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 18,
    width: double.infinity,
    child: Row(
      children: [
        Icon(Icons.info_outline_rounded, size: 14, color: context.accent),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Anteprima · dati dimostrativi',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontSize: 11),
          ),
        ),
      ],
    ),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontSize: 19),
        ),
      ),
      if (trailing != null)
        Text(trailing!, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class FuoriButton extends StatelessWidget {
  const FuoriButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.secondary = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool secondary;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.arrow_forward_rounded, size: 19),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: secondary ? context.wash : context.accent,
        foregroundColor: secondary
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onPrimary,
        disabledBackgroundColor: secondary
            ? context.wash
            : context.accent.withValues(alpha: 0.45),
        disabledForegroundColor: secondary
            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)
            : Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class EmptyMessage extends StatelessWidget {
  const EmptyMessage(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 22),
    child: Text(message, style: Theme.of(context).textTheme.bodySmall),
  );
}

// Original vector placeholder until distributable avatar assets are selected.
class AvatarPlaceholder extends StatelessWidget {
  const AvatarPlaceholder({
    super.key,
    this.size = 48,
    this.coat = const Color(0xFF9B8DBF),
  });

  final double size;
  final Color coat;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _AvatarPainter(coat)),
  );
}

/// Full-body original illustration used in place of the reference sprites.
class FullBodyAvatar extends StatelessWidget {
  const FullBodyAvatar({
    super.key,
    this.width = 82,
    this.height = 145,
    this.coat = const Color(0xFF9B8DBF),
    this.hair = const Color(0xFF392B29),
    this.skin = const Color(0xFFE2AD84),
    this.pants = const Color(0xFF434752),
    this.shoes = const Color(0xFF272C32),
    this.glasses = false,
    this.wave = false,
  });

  final double width;
  final double height;
  final Color coat;
  final Color hair;
  final Color skin;
  final Color pants;
  final Color shoes;
  final bool glasses;
  final bool wave;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: CustomPaint(
      painter: _FullBodyAvatarPainter(
        coat: coat,
        hair: hair,
        skin: skin,
        pants: pants,
        shoes: shoes,
        glasses: glasses,
        wave: wave,
      ),
    ),
  );
}

class _FullBodyAvatarPainter extends CustomPainter {
  const _FullBodyAvatarPainter({
    required this.coat,
    required this.hair,
    required this.skin,
    required this.pants,
    required this.shoes,
    required this.glasses,
    required this.wave,
  });

  final Color coat;
  final Color hair;
  final Color skin;
  final Color pants;
  final Color shoes;
  final bool glasses;
  final bool wave;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 82, size.height / 145);
    final outline = Paint()
      ..color = const Color(0xFF312B2C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final skinPaint = Paint()..color = skin;
    final coatPaint = Paint()..color = coat;
    final hairPaint = Paint()..color = hair;
    final trousers = Paint()..color = pants;
    final shoePaint = Paint()..color = shoes;

    // Legs and shoes sit behind the jacket.
    for (final x in [23.0, 45.0]) {
      final leg = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 102, 15, 30),
        const Radius.circular(3),
      );
      canvas.drawRRect(leg, trousers);
      canvas.drawRRect(leg, outline);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 3, 128, 22, 9),
          const Radius.circular(4),
        ),
        shoePaint,
      );
    }

    final leftArm = RRect.fromRectAndRadius(
      const Rect.fromLTWH(7, 65, 16, 48),
      const Radius.circular(7),
    );
    final rightArm = RRect.fromRectAndRadius(
      wave
          ? const Rect.fromLTWH(61, 32, 16, 43)
          : const Rect.fromLTWH(59, 65, 16, 48),
      const Radius.circular(7),
    );
    canvas.drawRRect(leftArm, coatPaint);
    canvas.drawRRect(rightArm, coatPaint);
    canvas.drawRRect(leftArm, outline);
    canvas.drawRRect(rightArm, outline);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(9, 108, 13, 13),
        const Radius.circular(6),
      ),
      skinPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        wave
            ? const Rect.fromLTWH(62, 22, 13, 13)
            : const Rect.fromLTWH(60, 108, 13, 13),
        const Radius.circular(6),
      ),
      skinPaint,
    );

    final jacket = RRect.fromRectAndRadius(
      const Rect.fromLTWH(17, 59, 48, 51),
      const Radius.circular(11),
    );
    canvas.drawRRect(jacket, coatPaint);
    canvas.drawRRect(jacket, outline);
    final seam = Paint()
      ..color = const Color(0x55312B2C)
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(41, 64), const Offset(41, 107), seam);
    canvas.drawCircle(
      const Offset(43, 83),
      1.2,
      Paint()..color = const Color(0xFF312B2C),
    );

    final neck = RRect.fromRectAndRadius(
      const Rect.fromLTWH(35, 52, 13, 14),
      const Radius.circular(5),
    );
    canvas.drawRRect(neck, skinPaint);
    final face = RRect.fromRectAndRadius(
      const Rect.fromLTWH(21, 19, 40, 42),
      const Radius.circular(15),
    );
    canvas.drawRRect(face, skinPaint);
    canvas.drawRRect(face, outline);
    final hairCap = RRect.fromRectAndRadius(
      const Rect.fromLTWH(19, 14, 44, 19),
      const Radius.circular(10),
    );
    canvas.drawRRect(hairCap, hairPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(19, 24, 9, 22),
        const Radius.circular(4),
      ),
      hairPaint,
    );
    final eyePaint = Paint()..color = const Color(0xFF282429);
    canvas.drawCircle(const Offset(36, 42), 1.8, eyePaint);
    canvas.drawCircle(const Offset(50, 42), 1.8, eyePaint);
    if (glasses) {
      final frames = Paint()
        ..color = const Color(0xFF312B2C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(29, 35, 13, 13),
          const Radius.circular(4),
        ),
        frames,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(44, 35, 13, 13),
          const Radius.circular(4),
        ),
        frames,
      );
      canvas.drawLine(const Offset(42, 40), const Offset(44, 40), frames);
    }
    final mouth = Paint()
      ..color = const Color(0xFF8A5545)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawArc(const Rect.fromLTWH(38, 47, 9, 5), 0.1, 2.7, false, mouth);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FullBodyAvatarPainter oldDelegate) =>
      oldDelegate.coat != coat ||
      oldDelegate.hair != hair ||
      oldDelegate.skin != skin ||
      oldDelegate.pants != pants ||
      oldDelegate.shoes != shoes ||
      oldDelegate.glasses != glasses ||
      oldDelegate.wave != wave;
}

class _AvatarPainter extends CustomPainter {
  _AvatarPainter(this.coat);

  final Color coat;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 48;
    final background = Paint()..color = const Color(0xFFE8E3F5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(14 * s)),
      background,
    );
    final shirt = Paint()..color = coat;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(6 * s, 31 * s, 36 * s, 25 * s),
        Radius.circular(13 * s),
      ),
      shirt,
    );
    final skin = Paint()..color = const Color(0xFFE2AD84);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(12 * s, 9 * s, 24 * s, 29 * s),
        Radius.circular(10 * s),
      ),
      skin,
    );
    final hair = Paint()..color = const Color(0xFF392B29);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(11 * s, 7 * s, 26 * s, 10 * s),
        Radius.circular(6 * s),
      ),
      hair,
    );
    final eye = Paint()..color = const Color(0xFF282429);
    canvas.drawCircle(Offset(20 * s, 24 * s), 1.4 * s, eye);
    canvas.drawCircle(Offset(29 * s, 24 * s), 1.4 * s, eye);
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) =>
      oldDelegate.coat != coat;
}
