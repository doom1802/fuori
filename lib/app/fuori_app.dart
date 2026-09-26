import 'package:flutter/material.dart';

import '../data/demo/demo_repositories.dart';
import '../features/account/account_repository.dart';
import '../features/events/event.dart';
import '../features/events/event_repository.dart';
import '../features/friends/friend.dart';
import '../features/friends/friend_repository.dart';
import '../features/friends/demo_invite_link.dart';
import 'fuori_theme.dart';
import 'account_gate.dart';
import 'create_event_screen.dart';
import 'invite_screens.dart';
import 'screens.dart';

class FuoriDependencies {
  const FuoriDependencies({required this.events, required this.friends});

  factory FuoriDependencies.demo() => FuoriDependencies(
    events: DemoEventRepository(),
    friends: DemoFriendRepository(),
  );

  final EventRepository events;
  final FriendRepository friends;
}

class FuoriApp extends StatelessWidget {
  const FuoriApp({
    super.key,
    required this.dependencies,
    this.accountDependencies,
  });

  final FuoriDependencies dependencies;
  final AccountDependencies? accountDependencies;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Fuori',
    debugShowCheckedModeBanner: false,
    theme: FuoriTheme.light(),
    darkTheme: FuoriTheme.dark(),
    themeMode: ThemeMode.system,
    home: accountDependencies == null
        ? _AppFrame(dependencies: dependencies)
        : AccountGate(
            dependencies: accountDependencies!,
            homeBuilder: (profile, openAccountSettings) => _AppFrame(
              dependencies: dependencies,
              profile: profile,
              onAccountSettings: openAccountSettings,
            ),
          ),
  );
}

class _PreviewData {
  const _PreviewData(this.events, this.friends);

  final List<FuoriEvent> events;
  final List<FuoriFriend> friends;
}

class _AppFrame extends StatefulWidget {
  const _AppFrame({
    required this.dependencies,
    this.profile,
    this.onAccountSettings,
  });

  final FuoriDependencies dependencies;
  final AccountProfile? profile;
  final VoidCallback? onAccountSettings;

  @override
  State<_AppFrame> createState() => _AppFrameState();
}

class _AppFrameState extends State<_AppFrame> {
  late Future<_PreviewData> _data;
  int _tab = 0;
  FuoriEvent? _selectedEvent;
  bool _showInvite = false;
  bool _showCreateEvent = false;
  String? _incomingInviter;
  final Map<String, int> _demoResponses = {};
  final List<FuoriEvent> _createdEvents = [];

  @override
  void initState() {
    super.initState();
    _data = _load();
    _incomingInviter = DemoInviteLink.inviter(Uri.base, Uri.base);
  }

  Future<_PreviewData> _load() async {
    final (events, friends) = await (
      widget.dependencies.events.upcomingEvents(),
      widget.dependencies.friends.friends(),
    ).wait;
    return _PreviewData(events, friends);
  }

  void _selectTab(int tab) => setState(() {
    _tab = tab;
    _selectedEvent = null;
    _showInvite = false;
    _showCreateEvent = false;
    _incomingInviter = null;
  });

  void _openEvent(FuoriEvent event) => setState(() => _selectedEvent = event);

  void _openInvite() => setState(() {
    _selectedEvent = null;
    _incomingInviter = null;
    _showInvite = true;
  });

  void _openCreateEvent() => setState(() {
    _selectedEvent = null;
    _showInvite = false;
    _showCreateEvent = true;
  });

  void _createEvent(FuoriEvent event) => setState(() {
    _createdEvents.insert(0, event);
    _showCreateEvent = false;
    _selectedEvent = event;
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final desktop = constraints.maxWidth > 440;
      final availableHeight = constraints.maxHeight - (desktop ? 16 : 0);
      final height = availableHeight > 820 ? 820.0 : availableHeight;
      return ColoredBox(
        color: context.isDark
            ? const Color(0xFF151519)
            : const Color(0xFFF0EFEB),
        child: Padding(
          padding: EdgeInsets.only(top: desktop ? 16 : 0),
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: constraints.maxWidth > 420 ? 420 : constraints.maxWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.paper,
                  borderRadius: BorderRadius.circular(desktop ? 32 : 0),
                  border: desktop ? Border.all(color: context.line) : null,
                  boxShadow: desktop
                      ? const [
                          BoxShadow(
                            color: Color(0x1A202126),
                            blurRadius: 48,
                            offset: Offset(0, 12),
                          ),
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(desktop ? 32 : 0),
                  child: Scaffold(
                    body: SafeArea(
                      child: Column(
                        children: [
                          if (!_showInvite) _Header(onInvite: _openInvite),
                          Expanded(
                            child: FutureBuilder<_PreviewData>(
                              future: _data,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Non riusciamo a caricare i programmi.',
                                          ),
                                          const SizedBox(height: 12),
                                          TextButton(
                                            onPressed: () =>
                                                setState(() => _data = _load()),
                                            child: const Text('Riprova'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final data = snapshot.requireData;
                                final allEvents = [
                                  ..._createdEvents,
                                  ...data.events,
                                ];
                                return Stack(
                                  children: [
                                    IndexedStack(
                                      index: _tab,
                                      children: [
                                        HomeScreen(
                                          events: allEvents,
                                          onEventTap: _openEvent,
                                          onCreateEvent: _openCreateEvent,
                                        ),
                                        PlansScreen(
                                          events: allEvents,
                                          responses: _demoResponses,
                                          onEventTap: _openEvent,
                                          onCreateEvent: _openCreateEvent,
                                        ),
                                        FriendsScreen(
                                          friends: data.friends,
                                          onInvite: _openInvite,
                                        ),
                                        ProfileScreen(
                                          displayName:
                                              widget.profile?.displayName,
                                          onAccountSettings:
                                              widget.onAccountSettings,
                                        ),
                                      ],
                                    ),
                                    if (_selectedEvent != null)
                                      Positioned.fill(
                                        child: ColoredBox(
                                          color: context.paper,
                                          child: EventDetailScreen(
                                            event: _selectedEvent!,
                                            response:
                                                _demoResponses[_selectedEvent!
                                                    .id] ??
                                                0,
                                            onResponseChanged: (value) => setState(
                                              () =>
                                                  _demoResponses[_selectedEvent!
                                                          .id] =
                                                      value,
                                            ),
                                            onBack: () => setState(
                                              () => _selectedEvent = null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (_showInvite)
                                      Positioned.fill(
                                        child: ColoredBox(
                                          color: context.paper,
                                          child: InviteScreen(
                                            onBack: () => setState(
                                              () => _showInvite = false,
                                            ),
                                            onInvite: (name) => setState(() {
                                              _showInvite = false;
                                              _incomingInviter = name;
                                            }),
                                          ),
                                        ),
                                      ),
                                    if (_showCreateEvent)
                                      Positioned.fill(
                                        child: ColoredBox(
                                          color: context.paper,
                                          child: CreateEventScreen(
                                            onBack: () => setState(
                                              () => _showCreateEvent = false,
                                            ),
                                            onCreate: _createEvent,
                                          ),
                                        ),
                                      ),
                                    if (_incomingInviter != null)
                                      Positioned.fill(
                                        child: ColoredBox(
                                          color: context.paper,
                                          child: InviteRequestScreen(
                                            inviter: _incomingInviter!,
                                            onBack: () => setState(
                                              () => _incomingInviter = null,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                          if (!_showInvite)
                            _BottomNav(selected: _tab, onSelect: _selectTab),
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
    },
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.onInvite});

  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      MediaQuery.sizeOf(context).width <= 360 ? 18 : 24,
      26,
      MediaQuery.sizeOf(context).width <= 360 ? 12 : 20,
      8,
    ),
    child: Row(
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'fuori'),
              TextSpan(
                text: '.',
                style: TextStyle(color: context.accent),
              ),
            ],
          ),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: MediaQuery.sizeOf(context).width <= 360 ? 25 : 28,
            letterSpacing: -2,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.location_on_outlined,
          size: 15,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 3),
        Text(
          'Torino',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
        ),
        const SizedBox(width: 5),
        IconButton.filledTonal(
          onPressed: onInvite,
          tooltip: 'Aggiungi un amico',
          icon: const Icon(Icons.qr_code_scanner_rounded, size: 21),
          style: IconButton.styleFrom(
            backgroundColor: context.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            minimumSize: const Size(40, 40),
            maximumSize: const Size(40, 40),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    ),
  );
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const destinations = [
      (Icons.home_outlined, 'In giro'),
      (Icons.calendar_month_outlined, 'Eventi'),
      (Icons.people_outline_rounded, 'Amici'),
      (Icons.checkroom_outlined, 'Il mio io'),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.line)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 10),
        child: Row(
          children: [
            for (var i = 0; i < destinations.length; i++)
              Expanded(
                child: Semantics(
                  selected: selected == i,
                  button: true,
                  child: InkWell(
                    key: Key('nav-$i'),
                    onTap: () => onSelect(i),
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 58,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            destinations[i].$1,
                            size: 23,
                            color: selected == i
                                ? context.accent
                                : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            destinations[i].$2,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: selected == i
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected == i
                                  ? context.accent
                                  : Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                            ),
                          ),
                        ],
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
