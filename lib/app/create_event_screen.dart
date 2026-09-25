import 'package:flutter/material.dart';

import '../features/events/event.dart';
import 'widgets.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({
    super.key,
    required this.onBack,
    required this.onCreate,
  });

  final VoidCallback onBack;
  final ValueChanged<FuoriEvent> onCreate;

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _place = TextEditingController();
  String _day = 'SABATO';
  String _time = '20:30';
  EventVisibility _visibility = EventVisibility.private;

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onCreate(
      FuoriEvent(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        title: _title.text.trim(),
        place: _place.text.trim(),
        dayLabel: _day,
        timeLabel: '$_time – 01:00',
        attendeeCount: 0,
        visibleFriends: const [],
        organizerLabel: 'Tu',
        visibility: _visibility,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListView(
    key: const Key('create-event-screen'),
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
    children: [
      const DemoNotice(),
      const SizedBox(height: 13),
      Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            tooltip: 'Torna indietro',
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Organizzi tu',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
      const SizedBox(height: 25),
      const Eyebrow('Un nuovo evento'),
      const SizedBox(height: 6),
      Text(
        'Le belle serate\niniziano così.',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 8),
      Text(
        'Dai un nome alla serata e scegli chi può vederla.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 25),
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const Key('event-title-field'),
              controller: _title,
              maxLength: 70,
              decoration: const InputDecoration(
                labelText: 'Nome dell’evento',
                hintText: 'Es. Una serata da me',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Inserisci un nome.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('event-place-field'),
              controller: _place,
              maxLength: 90,
              decoration: const InputDecoration(
                labelText: 'Luogo',
                hintText: 'Es. Torino, casa mia',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Inserisci un luogo.'
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _day,
                    decoration: const InputDecoration(labelText: 'Giorno'),
                    items: const [
                      DropdownMenuItem(value: 'OGGI', child: Text('Oggi')),
                      DropdownMenuItem(value: 'DOMANI', child: Text('Domani')),
                      DropdownMenuItem(value: 'SABATO', child: Text('Sabato')),
                    ],
                    onChanged: (value) => setState(() => _day = value ?? _day),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _time,
                    decoration: const InputDecoration(labelText: 'Dalle'),
                    items: const [
                      DropdownMenuItem(value: '18:30', child: Text('18:30')),
                      DropdownMenuItem(value: '20:30', child: Text('20:30')),
                      DropdownMenuItem(value: '21:00', child: Text('21:00')),
                      DropdownMenuItem(value: '22:00', child: Text('22:00')),
                    ],
                    onChanged: (value) =>
                        setState(() => _time = value ?? _time),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 19),
            Text(
              'Chi può partecipare?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<EventVisibility>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: EventVisibility.public,
                  label: Text('Pubblico'),
                  icon: Icon(Icons.public_rounded),
                ),
                ButtonSegment(
                  value: EventVisibility.private,
                  label: Text('Su invito'),
                  icon: Icon(Icons.lock_outline_rounded),
                ),
              ],
              selected: {_visibility},
              onSelectionChanged: (value) =>
                  setState(() => _visibility = value.first),
            ),
            const SizedBox(height: 11),
            Text(
              _visibility == EventVisibility.private
                  ? 'Solo le persone invitate vedranno l’evento. Gli inviti reali arriveranno con l’account.'
                  : 'L’evento sarà pubblico. Questa anteprima resta solo su questo dispositivo.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FuoriButton(
              label: 'Crea evento demo',
              icon: Icons.arrow_forward_rounded,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    ],
  );
}
