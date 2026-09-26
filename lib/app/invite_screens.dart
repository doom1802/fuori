import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../features/friends/demo_invite_link.dart';
import 'fuori_theme.dart';
import 'widgets.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key, required this.onBack, required this.onInvite});

  final VoidCallback onBack;
  final ValueChanged<String> onInvite;

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  late final PageController _pages = PageController(initialPage: 1);
  int _page = 1;
  bool _scanning = false;
  bool _handled = false;
  String? _scanMessage;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _showPage(int index) => _pages.animateToPage(
    index,
    duration: const Duration(milliseconds: 230),
    curve: Curves.easeOutCubic,
  );

  Future<void> _shareLink(BuildContext buttonContext, String link) async {
    final box = buttonContext.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    try {
      await SharePlus.instance.share(
        ShareParams(text: link, sharePositionOrigin: origin),
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: link));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Condivisione non disponibile: link copiato.'),
          ),
        );
      }
    }
  }

  void _handleCode(String? value) {
    if (_handled || value == null) return;
    final candidate = Uri.tryParse(value);
    final name = candidate == null
        ? null
        : DemoInviteLink.inviter(Uri.base, candidate);
    if (name == null) {
      setState(
        () => _scanMessage = 'Questo QR non contiene un invito Fuori valido.',
      );
      return;
    }
    _handled = true;
    setState(() => _scanning = false);
    widget.onInvite(name);
  }

  @override
  Widget build(BuildContext context) {
    final link = DemoInviteLink.create(Uri.base, 'Domi').toString();
    return Column(
      key: const Key('invite-screen'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 18, 0),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Chiudi QR',
                onPressed: widget.onBack,
                icon: const Icon(Icons.close_rounded),
              ),
              const Expanded(
                child: Text(
                  'Aggiungi un amico',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Builder(
                builder: (buttonContext) => TextButton.icon(
                  key: const Key('invite-share'),
                  onPressed: () => _shareLink(buttonContext, link),
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: const Text('Condividi'),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: DemoNotice(),
        ),
        Expanded(
          child: PageView(
            key: const Key('invite-pages'),
            controller: _pages,
            onPageChanged: (index) => setState(() {
              _page = index;
              if (index != 0) _scanning = false;
            }),
            children: [
              _InviteMode(
                eyebrow: 'SCAN',
                title: 'Inquadra un QR.',
                subtitle:
                    'Scansiona il codice di un amico per chiedere l’amicizia.',
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox(
                        height: 230,
                        width: double.infinity,
                        child: _scanning && _page == 0
                            ? MobileScanner(
                                onDetect: (capture) {
                                  if (capture.barcodes.isNotEmpty) {
                                    _handleCode(
                                      capture.barcodes.first.rawValue,
                                    );
                                  }
                                },
                                errorBuilder: (context, error) => Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Text(
                                      'Fotocamera non disponibile. Controlla i permessi del browser.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              )
                            : ColoredBox(
                                color: context.wash,
                                child: const Center(
                                  child: Icon(
                                    Icons.qr_code_scanner_rounded,
                                    size: 64,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      _scanMessage ?? 'Centra il QR nel riquadro.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FuoriButton(
                      label: _scanning
                          ? 'Chiudi la fotocamera'
                          : 'Apri la fotocamera',
                      icon: _scanning
                          ? Icons.close_rounded
                          : Icons.camera_alt_outlined,
                      onPressed: () => setState(() {
                        _scanning = !_scanning;
                        _handled = false;
                        _scanMessage = null;
                      }),
                    ),
                  ],
                ),
              ),
              _InviteMode(
                eyebrow: 'SHOW',
                title: 'Mostra il tuo QR.',
                subtitle: 'Un amico può inquadrarlo per aggiungerti.',
                child: Column(
                  children: [
                    Container(
                      key: const Key('invite-qr'),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: QrImageView(
                        data: link,
                        version: QrVersions.auto,
                        size: 206,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      'Domi',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Il tuo invito personale · anteprima',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Row(
            children: [
              for (final (index, label, icon) in [
                (0, 'Scan', Icons.qr_code_scanner_rounded),
                (1, 'Show', Icons.qr_code_rounded),
              ])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: FilledButton.icon(
                      key: Key('invite-mode-$index'),
                      onPressed: () => _showPage(index),
                      icon: Icon(icon, size: 19),
                      label: Text(label),
                      style: FilledButton.styleFrom(
                        backgroundColor: _page == index
                            ? context.accent
                            : context.wash,
                        foregroundColor: _page == index
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        minimumSize: const Size(0, 50),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Text(
            'Scorri a destra o sinistra per cambiare modalità. QR e link funzionano solo in questa anteprima.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _InviteMode extends StatelessWidget {
  const _InviteMode({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(eyebrow),
        const SizedBox(height: 7),
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 7),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 27),
        Center(child: child),
      ],
    ),
  );
}

class InviteRequestScreen extends StatefulWidget {
  const InviteRequestScreen({
    super.key,
    required this.inviter,
    required this.onBack,
  });

  final String inviter;
  final VoidCallback onBack;

  @override
  State<InviteRequestScreen> createState() => _InviteRequestScreenState();
}

class _InviteRequestScreenState extends State<InviteRequestScreen> {
  bool _requested = false;

  @override
  Widget build(BuildContext context) => ListView(
    key: const Key('invite-request-screen'),
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
    children: [
      const DemoNotice(),
      const SizedBox(height: 13),
      _BackRow(label: 'Invito personale', onBack: widget.onBack),
      const SizedBox(height: 30),
      Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: context.lilac,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            const AvatarPortrait(size: 75),
            const SizedBox(height: 14),
            const Eyebrow('Ti ha invitato'),
            const SizedBox(height: 5),
            Text(
              widget.inviter,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            const Text('Una nuova persona nella tua cerchia.'),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'I vostri programmi restano privati finché la richiesta non viene accettata.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 18),
      FuoriButton(
        label: _requested
            ? 'Richiesta demo inviata · annulla'
            : 'Chiedi l’amicizia',
        icon: _requested
            ? Icons.schedule_rounded
            : Icons.person_add_alt_1_rounded,
        onPressed: () => setState(() => _requested = !_requested),
      ),
      const SizedBox(height: 10),
      Text(
        'Questa richiesta è solo una simulazione locale.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}

class _BackRow extends StatelessWidget {
  const _BackRow({required this.label, required this.onBack});

  final String label;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        onPressed: onBack,
        tooltip: 'Torna indietro',
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      Expanded(
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      const SizedBox(width: 48),
    ],
  );
}
