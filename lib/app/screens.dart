import 'avatar_palette.dart';
import '../features/account/avatar_catalog.dart';
import '../features/account/avatar_look.dart';

import 'package:flutter/material.dart';

import '../features/events/event.dart';
import '../features/friends/friend.dart';
import 'fuori_theme.dart';
import 'widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.events,
    required this.onEventTap,
    required this.onCreateEvent,
  });

  final List<FuoriEvent> events;
  final ValueChanged<FuoriEvent> onEventTap;
  final VoidCallback onCreateEvent;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _day = 1;

  @override
  Widget build(BuildContext context) {
    final selectedLabel = const ['OGGI', 'DOMANI', 'SABATO'][_day];
    final events = widget.events
        .where((event) => event.dayLabel == selectedLabel)
        .toList();
    final featured = events.isEmpty ? null : events.first;
    return _Page(
      children: [
        const DemoNotice(),
        const Eyebrow('I tuoi amici. La tua città.'),
        const SizedBox(height: 5),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Ci vediamo\n'),
              TextSpan(
                text: 'fuori.',
                style: TextStyle(
                  color: context.accent,
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: MediaQuery.sizeOf(context).width <= 360 ? 42 : 47,
          ),
        ),
        const SizedBox(height: 13),
        Text(
          'Scopri chi sarà vicino a te.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 25),
        _DaySelector(
          selected: _day,
          onSelect: (value) => setState(() => _day = value),
        ),
        const SizedBox(height: 21),
        if (featured != null) ...[
          _FeaturedCard(
            event: featured,
            onTap: () => widget.onEventTap(featured),
          ),
        ] else
          const EmptyMessage(
            'Non ci sono programmi dimostrativi per questo giorno.',
          ),
        const SizedBox(height: 26),
        SectionHeading(
          'Eventi in programma',
          trailing: '${events.length} eventi',
        ),
        const SizedBox(height: 7),
        for (final event in events.where((item) => item.id != featured?.id))
          EventTile(event: event, onTap: () => widget.onEventTap(event)),
        if (events.length <= 1)
          const EmptyMessage('Nessun altro evento in anteprima.'),
        const SizedBox(height: 17),
        FuoriButton(
          label: 'Crea un evento',
          icon: Icons.add_rounded,
          onPressed: widget.onCreateEvent,
        ),
      ],
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.wash,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++)
            Expanded(
              child: Semantics(
                selected: selected == i,
                button: true,
                child: InkWell(
                  onTap: () => onSelect(i),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected == i
                          ? context.surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: selected == i
                          ? const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      const ['Oggi', 'Domani', 'Weekend'][i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
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

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.event, required this.onTap});

  final FuoriEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: context.peach,
    borderRadius: BorderRadius.circular(28),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: const Key('featured-event'),
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 18, 19, 0),
            child: Row(
              children: [
                Icon(Icons.circle, size: 7, color: context.accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${event.visibleFriends.length} amici partecipano',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  event.timeLabel.split(' ').first,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const _FriendsStage(),
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 0, 19, 17),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.id == 'coguaro-demo'
                            ? 'Tutti al Coguaro'
                            : event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${event.visibleFriends.join(', ')} · ${event.dayLabel.toLowerCase()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 9),
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  foregroundColor: context.paper,
                  radius: 22,
                  child: const Icon(Icons.arrow_outward_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _FriendsStage extends StatelessWidget {
  const _FriendsStage();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 213,
    width: double.infinity,
    child: LayoutBuilder(
      builder: (context, constraints) => Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: -245,
            child: Transform.rotate(
              angle: 0.7854,
              child: CustomPaint(
                size: const Size(300, 300),
                painter: _TileFloorPainter(
                  fill: context.isDark
                      ? const Color(0xFF625044)
                      : const Color(0xFFE9CDB8),
                  line: context.isDark
                      ? const Color(0xFF806958)
                      : const Color(0xFFD1B5A4),
                ),
              ),
            ),
          ),
          Positioned(
            left: constraints.maxWidth * 0.11,
            bottom: 5,
            child: const FullBodyAvatar(
              coat: Color(0xFF9B8DBF),
              hair: Color(0xFF8C474A),
            ),
          ),
          const Positioned(
            bottom: 10,
            child: FullBodyAvatar(
              width: 86,
              height: 154,
              coat: Color(0xFFDA8264),
              hair: Color(0xFF40332E),
            ),
          ),
          Positioned(
            right: constraints.maxWidth * 0.11,
            bottom: 4,
            child: const FullBodyAvatar(
              coat: Color(0xFF668FA7),
              hair: Color(0xFF584234),
            ),
          ),
        ],
      ),
    ),
  );
}

class _TileFloorPainter extends CustomPainter {
  const _TileFloorPainter({required this.fill, required this.line});

  final Color fill;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = fill);
    final pen = Paint()
      ..color = line.withValues(alpha: 0.7)
      ..strokeWidth = 1.2;
    for (var offset = 0.0; offset <= size.width; offset += 42) {
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), pen);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), pen);
    }
    final outline = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(Offset.zero & size, outline);
  }

  @override
  bool shouldRepaint(covariant _TileFloorPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.line != line;
}

class PlansScreen extends StatefulWidget {
  const PlansScreen({
    super.key,
    required this.events,
    required this.responses,
    required this.onEventTap,
    required this.onCreateEvent,
  });

  final List<FuoriEvent> events;
  final Map<String, int> responses;
  final ValueChanged<FuoriEvent> onEventTap;
  final VoidCallback onCreateEvent;

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

enum _EventFilter { all, attending, maybe }

class _PlansScreenState extends State<PlansScreen> {
  _EventFilter _filter = _EventFilter.all;

  List<FuoriEvent> _eventsForDay(String day, List<FuoriEvent> events) {
    final entries = events.where((event) => event.dayLabel == day).toList();
    entries.sort((a, b) => a.timeLabel.compareTo(b.timeLabel));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    const days = ['OGGI', 'DOMANI', 'SABATO'];
    final visibleEvents = widget.events
        .where(
          (event) => switch (_filter) {
            _EventFilter.all => true,
            _EventFilter.attending => widget.responses[event.id] == 1,
            _EventFilter.maybe => widget.responses[event.id] == 2,
          },
        )
        .toList();
    final entriesByDay = {
      for (final day in days) day: _eventsForDay(day, visibleEvents),
    };
    return _Page(
      key: const Key('events-page'),
      children: [
        const DemoNotice(),
        const SizedBox(height: 23),
        const Eyebrow('La tua settimana'),
        const SizedBox(height: 7),
        Text(
          'Cose belle\nin programma.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 10),
        Text(
          'Eventi pubblici e inviti privati, tutti nello stesso posto.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 22),
        Container(
          height: 46,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: context.wash,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              for (final (filter, label, key) in [
                (_EventFilter.all, 'Tutti', 'events-filter-all'),
                (
                  _EventFilter.attending,
                  'Parteciperò',
                  'events-filter-attending',
                ),
                (_EventFilter.maybe, 'Forse', 'events-filter-maybe'),
              ])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: TextButton(
                      key: Key(key),
                      onPressed: () => setState(() => _filter = filter),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context)
                            .colorScheme
                            .onSurface,
                        backgroundColor: _filter == filter
                            ? context.surface
                            : null,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionHeading(
          _filter == _EventFilter.all ? 'La settimana' : 'I tuoi eventi',
          trailing: 'Torino',
        ),
        const SizedBox(height: 10),
        if (visibleEvents.isEmpty)
          EmptyMessage(switch (_filter) {
            _EventFilter.all => 'Nessun evento in anteprima.',
            _EventFilter.attending => 'Nessun evento a cui parteciperai. Apri un evento e scegli “Ci sarò”.',
            _EventFilter.maybe => 'Nessun evento in forse. Apri un evento e scegli “Ti faccio sapere”.',
          }),
        for (final day in days) ...[
          if (entriesByDay[day]!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 5),
              child: Text(
                day,
                style: TextStyle(
                  color: context.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            for (final event in entriesByDay[day]!)
              EventTile(event: event, onTap: () => widget.onEventTap(event)),
          ],
        ],
        const SizedBox(height: 24),
        FuoriButton(
          label: 'Crea un evento',
          icon: Icons.add_rounded,
          onPressed: widget.onCreateEvent,
        ),
      ],
    );
  }
}

class EventTile extends StatelessWidget {
  const EventTile({super.key, required this.event, required this.onTap});

  final FuoriEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _EventPoster(event: event),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.visibility == EventVisibility.public
                        ? 'EVENTO PUBBLICO · ${event.timeLabel.split(' ').first}'
                        : 'EVENTO SU INVITO · ${event.timeLabel.split(' ').first}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: context.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.place,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    ),
  );
}

class _EventPoster extends StatelessWidget {
  const _EventPoster({required this.event});

  final FuoriEvent event;

  @override
  Widget build(BuildContext context) => Container(
    width: 76,
    height: 86,
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: event.isFeatured
          ? const Color(0xFF2F4A49)
          : const Color(0xFF232557),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TORINO / EVENTO',
          style: TextStyle(
            fontSize: 6,
            height: 1,
            color: Color(0xFFF5DBB2),
            letterSpacing: 0.4,
          ),
        ),
        const Spacer(),
        Text(
          event.title.toUpperCase(),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFFF5DBB2),
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
      ],
    ),
  );
}

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({
    super.key,
    required this.friends,
    required this.onInvite,
  });

  final List<FuoriFriend> friends;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) => _Page(
    children: [
      const DemoNotice(),
      const SizedBox(height: 23),
      const Eyebrow('Le tue persone'),
      const SizedBox(height: 7),
      Text(
        'Ci si trova\ntra amici.',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 22),
      Container(
        padding: const EdgeInsets.all(23),
        decoration: BoxDecoration(
          color: context.lilac,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Un link.\nUn amico in più.',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 9),
            Text(
              'Aggiungi chi conosci, con un invito o un QR.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 17),
            FuoriButton(
              label: 'Aggiungi un amico',
              icon: Icons.person_add_alt_1_rounded,
              secondary: true,
              onPressed: onInvite,
            ),
          ],
        ),
      ),
      const SizedBox(height: 23),
      SectionHeading('La tua cerchia', trailing: '${friends.length} amici'),
      const SizedBox(height: 6),
      if (friends.isEmpty) const EmptyMessage('Nessun amico in anteprima.'),
      for (var i = 0; i < friends.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              AvatarPortrait(
                size: 48,
                coat: const [
                  Color(0xFF9B8DBF),
                  Color(0xFFDA8264),
                  Color(0xFF668FA7),
                ][i % 3],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friends[i].name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      friends[i].status,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.displayName,
    this.onAccountSettings,
    this.initialLook = const AvatarLook(),
    this.onSaveAvatar,
  });

  final String? displayName;
  final VoidCallback? onAccountSettings;
  final AvatarLook initialLook;
  final Future<AvatarLook> Function(AvatarLook)? onSaveAvatar;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _labels = [
    'Vestiti',
    'Capelli',
    'Pantaloni',
    'Scarpe',
    'Extra',
    'Pelle',
  ];
  static const _palettes = AvatarPalette.colors;
  late List<int> _choices = widget.initialLook.choices;
  late AvatarBody _body = widget.initialLook.body;
  late List<int> _models = widget.initialLook.models;
  late int _accessoryMask = widget.initialLook.accessoryMask;
  int _category = 0;
  bool _wave = false;
  int _direction = 0;
  bool _saved = false;
  bool _saving = false;
  String? _saveError;

  Future<void> _saveLook() async {
    if (_saving) return;
    final look = AvatarLook.fromChoices(
      _choices,
      body: _body,
      models: _models,
      accessoryMask: _accessoryMask,
    );
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      final saved = await widget.onSaveAvatar?.call(look) ?? look;
      if (!mounted) return;
      setState(() {
        _choices = saved.choices;
        _body = saved.body;
        _models = saved.models;
        _accessoryMask = saved.accessoryMask;
        _saved = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _saveError =
              'Non siamo riusciti a salvare il look. La bozza è qui: riprova.';
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Page(
      key: const Key('profile-page'),
      children: [
        const DemoNotice(),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(widget.displayName ?? 'Domi'),
                  const SizedBox(height: 3),
                  Text(
                    'Il tuo altro io.',
                    style: Theme.of(context).textTheme.headlineLarge
                        ?.copyWith(fontSize: 32),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: widget.onAccountSettings,
              tooltip: widget.onAccountSettings == null
                  ? 'Impostazioni disponibili più avanti'
                  : 'Modifica account',
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 298,
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.lilac,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 17,
                left: 18,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(
                      'Il look di oggi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -205,
                child: Transform.rotate(
                  angle: 0.7854,
                  child: CustomPaint(
                    size: const Size(270, 270),
                    painter: _TileFloorPainter(
                      fill: context.isDark
                          ? const Color(0xFF514459)
                          : const Color(0xFFD6CDDF),
                      line: context.isDark
                          ? const Color(0xFF6C5D77)
                          : const Color(0xFFB9ACC7),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 14,
                child: FullBodyAvatar(
                  body: _body,
                  look: AvatarLook.fromChoices(
                    _choices,
                    body: _body,
                    models: _models,
                    accessoryMask: _accessoryMask,
                  ),
                  width: 126,
                  height: 222,
                  coat: _palettes[0][_choices[0]],
                  hair: _palettes[1][_choices[1]],
                  pants: _palettes[2][_choices[2]],
                  shoes: _palettes[3][_choices[3]],
                  glasses: _choices[4] == 1,
                  skin: _palettes[5][_choices[5]],
                  wave: _wave,
                  direction: _direction,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              key: const Key('avatar-rotate-left'),
              onPressed: () =>
                  setState(() => _direction = (_direction + 7) % 8),
              tooltip: 'Ruota a sinistra',
              icon: const Icon(Icons.rotate_left_rounded),
            ),
            Text(
              'Vista ${_direction + 1} di 8',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            IconButton(
              key: const Key('avatar-rotate-right'),
              onPressed: () =>
                  setState(() => _direction = (_direction + 1) % 8),
              tooltip: 'Ruota a destra',
              icon: const Icon(Icons.rotate_right_rounded),
            ),
            TextButton(
              onPressed: () => setState(() {
                _wave = !_wave;
              }),
              child: Text(_wave ? 'Ferma' : 'Saluta'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Base avatar', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<AvatarBody>(
          segments: const [
            ButtonSegment(value: AvatarBody.male, label: Text('Maschile')),
            ButtonSegment(value: AvatarBody.female, label: Text('Femminile')),
          ],
          selected: {_body},
          onSelectionChanged: _saving
              ? null
              : (value) => setState(() {
                  _body = value.single;
                  _saved = false;
                  _saveError = null;
                }),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.9,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
          ),
          itemCount: _labels.length,
          itemBuilder: (context, index) => InkWell(
            key: Key('wardrobe-category-$index'),
            onTap: () => setState(() => _category = index),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _category == index
                        ? Theme.of(context).colorScheme.onSurface
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                _labels[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: _category == index
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        if (_category != 4 && (_category != 1 || _models[1] != 3))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _category == 5
                  ? 'Tonalità della pelle'
                  : 'Colore · prima scelta: originale',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        if (_category != 4 && (_category != 1 || _models[1] != 3))
          Row(
            children: [
              for (var i = 0; i < _palettes[_category].length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i == _palettes[_category].length - 1 ? 0 : 8,
                    ),
                    child: Semantics(
                      selected: _choices[_category] == i,
                      label: i == 0 && _category != 5
                          ? 'Colore originale'
                          : '${_labels[_category]} colore ${i + 1}',
                      button: true,
                      child: InkWell(
                        key: Key('wardrobe-choice-$i'),
                        onTap: _saving
                            ? null
                            : () => setState(() {
                                _choices[_category] = i;
                                _saved = false;
                                _saveError = null;
                              }),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 75,
                          decoration: BoxDecoration(
                            color: context.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _choices[_category] == i
                                  ? Theme.of(context).colorScheme.onSurface
                                  : context.line,
                              width: _choices[_category] == i ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: _category == 4
                                ? Icon(
                                    i == 0
                                        ? Icons.close_rounded
                                        : Icons.remove_red_eye_outlined,
                                    size: 25,
                                  )
                                : i == 0 && _category != 5
                                ? const Icon(Icons.palette_outlined)
                                : CircleAvatar(
                                    backgroundColor: _palettes[_category][i],
                                    radius: 15,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        if (_category < 5) ...[
          const SizedBox(height: 12),
          if (_category == 4)
            Text(
              'Abbina occhiali, cappello, cuffie e borse.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              final selected = _category == 4
                  ? (_accessoryMask & (1 << index)) != 0
                  : _models[_category] == index;
              final previewModels = List<int>.of(_models);
              if (_category < 4) previewModels[_category] = index;
              final preview = AvatarLook.fromChoices(
                _choices,
                body: _body,
                models: previewModels,
                accessoryMask: _category == 4 ? (1 << index) : _accessoryMask,
              );
              return Semantics(
                selected: selected,
                button: true,
                child: InkWell(
                  key: Key('wardrobe-model-$_category-$index'),
                  onTap: _saving
                      ? null
                      : () => setState(() {
                          if (_category == 4) {
                            _accessoryMask = AvatarCatalog.toggleAccessory(
                              _accessoryMask,
                              index,
                            );
                          } else {
                            _models[_category] = index;
                          }
                          _saved = false;
                          _saveError = null;
                        }),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.onSurface
                            : context.line,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      children: [
                        Expanded(
                          child: FullBodyAvatar(
                            width: 48,
                            height: 72,
                            look: preview,
                          ),
                        ),
                        Text(
                          AvatarCatalog.categories[_category][index],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 10, height: 1.1),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 16),
        FuoriButton(
          label: _saving
              ? 'Salvataggio…'
              : _saved
              ? widget.onSaveAvatar == null
                    ? 'Look salvato in anteprima'
                    : 'Look salvato'
              : 'Questo sono io',
          icon: Icons.check_rounded,
          onPressed: _saving ? null : _saveLook,
        ),
        const SizedBox(height: 9),
        Text(
          _saveError ??
              (widget.onSaveAvatar == null
                  ? 'Il look resta in questa sessione di anteprima.'
                  : 'Conferma il look per salvarlo nel tuo profilo.'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({
    super.key,
    required this.event,
    required this.onBack,
    required this.response,
    required this.onResponseChanged,
  });

  final FuoriEvent event;
  final VoidCallback onBack;

  /// 0 = unanswered, 1 = participating, 2 = maybe (local preview only).
  final int response;
  final ValueChanged<int> onResponseChanged;

  @override
  Widget build(BuildContext context) => _Page(
    key: const Key('event-detail-page'),
    children: [
      const DemoNotice(),
      const SizedBox(height: 14),
      Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: 'Torna indietro',
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Il programma',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
      const SizedBox(height: 15),
      Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.peach,
          borderRadius: BorderRadius.circular(26),
        ),
        child: const _FriendsStage(),
      ),
      const SizedBox(height: 18),
      _Chip(
        label: event.visibility == EventVisibility.public
            ? 'Evento pubblico'
            : 'Evento su invito',
        icon: event.visibility == EventVisibility.public
            ? Icons.public_rounded
            : Icons.lock_outline_rounded,
      ),
      const SizedBox(height: 9),
      Text(
        event.title,
        style: Theme.of(context).textTheme.headlineLarge
            ?.copyWith(fontSize: 31),
      ),
      const SizedBox(height: 14),
      _InfoRow(
        icon: Icons.calendar_month_outlined,
        title: event.dayLabel,
        subtitle: event.timeLabel,
      ),
      _InfoRow(
        icon: Icons.location_on_outlined,
        title: event.place,
        subtitle: 'Torino e dintorni',
      ),
      Divider(height: 31, color: context.line),
      SectionHeading(
        '${event.attendeeCount + (response == 1 ? 1 : 0)} partecipanti',
        trailing: '${event.visibleFriends.length} tuoi amici',
      ),
      const SizedBox(height: 8),
      for (final name in event.visibleFriends)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const AvatarPortrait(size: 43),
              const SizedBox(width: 11),
              Text(name, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      if (event.visibility == EventVisibility.private) ...[
        const SizedBox(height: 16),
        SectionHeading(
          'Gli altri invitati',
          trailing: '${event.invitedNames.length} nomi',
        ),
        const SizedBox(height: 5),
        for (final name in event.invitedNames)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(name, style: Theme.of(context).textTheme.titleMedium),
          ),
      ],
      const SizedBox(height: 12),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 16,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              event.visibility == EventVisibility.private
                  ? 'Gli invitati vedono chi altro è stato invitato. Questo è solo un esempio locale.'
                  : 'Gli altri vedono solo il totale. I nomi sono visibili agli amici secondo le impostazioni di privacy.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      FuoriButton(
        label: response == 1 ? 'Ci sei! Annulla partecipazione' : 'Ci sarò',
        icon: response == 1 ? Icons.check_rounded : Icons.add_rounded,
        onPressed: () => onResponseChanged(response == 1 ? 0 : 1),
      ),
      const SizedBox(height: 10),
      FuoriButton(
        label: response == 2 ? 'Forse · annulla risposta' : 'Ti faccio sapere',
        icon: Icons.schedule_rounded,
        secondary: true,
        onPressed: () => onResponseChanged(response == 2 ? 0 : 2),
      ),
    ],
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 11),
    child: Row(
      children: [
        Icon(
          icon,
          size: 21,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontSize: 14),
              ),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.wash,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Page extends StatelessWidget {
  const _Page({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.fromLTRB(
      MediaQuery.sizeOf(context).width <= 360 ? 18 : 24,
      8,
      MediaQuery.sizeOf(context).width <= 360 ? 18 : 24,
      24,
    ),
    children: children,
  );
}
