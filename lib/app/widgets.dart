import 'package:flutter/material.dart';

import 'fuori_theme.dart';
import 'avatar_sprite.dart';
import '../features/account/avatar_look.dart';

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

class AvatarPortrait extends StatelessWidget {
  const AvatarPortrait({
    super.key,
    this.size = 48,
    this.coat = const Color(0xFF9B8DBF),
  });
  final double size;
  final Color coat;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: context.lilac,
      borderRadius: BorderRadius.circular(14),
    ),
    clipBehavior: Clip.antiAlias,
    child: AvatarSprite(coat: coat, headOnly: true),
  );
}

class FullBodyAvatar extends StatelessWidget {
  const FullBodyAvatar({
    super.key,
    this.body = AvatarBody.male,
    this.hairStyle = AvatarHairStyle.spiky,
    this.look,
    this.width = 82,
    this.height = 145,
    this.coat = const Color(0xFF9B8DBF),
    this.hair = const Color(0xFF392B29),
    this.skin = const Color(0xFFE2AD84),
    this.pants = const Color(0xFF434752),
    this.shoes = const Color(0xFFFAF5E7),
    this.glasses = false,
    this.wave = false,
    this.direction = 0,
  });
  final AvatarBody body;
  final AvatarHairStyle hairStyle;
  final AvatarLook? look;
  final double width, height;
  final Color coat, hair, skin, pants, shoes;
  final bool glasses, wave;
  final int direction;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: AvatarSprite(
      look: look,
      body: body,
      hairStyle: hairStyle,
      coat: coat,
      hair: hair,
      skin: skin,
      pants: pants,
      shoes: shoes,
      glasses: glasses,
      wave: wave,
      direction: direction,
    ),
  );
}
