import 'package:fuori/app/avatar_sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuori/app/fuori_app.dart';
import 'package:fuori/features/friends/demo_invite_link.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await AvatarSpriteAssets.preload();
  });
  test('il link invito demo accetta solo origine e percorso locali', () {
    final app = Uri.parse('https://example.test/app/');
    final link = DemoInviteLink.create(app, 'Vale');
    expect(DemoInviteLink.inviter(app, link), 'Vale');
    expect(
      DemoInviteLink.inviter(
        app,
        Uri.parse('https://other.test/app/?invite=fuori-demo&from=Vale'),
      ),
      isNull,
    );
  });

  for (final width in [320.0, 420.0]) {
    testWidgets('QR Show e Scan sono usabili a $width px', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 760);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(FuoriApp(dependencies: FuoriDependencies.demo()));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Aggiungi un amico'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('invite-screen')), findsOneWidget);
      expect(find.byKey(const Key('invite-qr')), findsOneWidget);
      expect(find.byKey(const Key('invite-share')), findsOneWidget);
      await tester.drag(
        find.byKey(const Key('invite-pages')),
        const Offset(280, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('Apri la fotocamera'), findsOneWidget);
      await tester.tap(find.byKey(const Key('invite-mode-1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('invite-qr')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('gli eventi si filtrano in base alla risposta', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(FuoriApp(dependencies: FuoriDependencies.demo()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('events-filter-attending')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Nessun evento a cui parteciperai'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('events-filter-all')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sotto lo stesso cielo'));
    await tester.pumpAndSettle();
    final detailScroll = find
        .descendant(
          of: find.byKey(const Key('event-detail-page')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Ti faccio sapere'),
      180,
      scrollable: detailScroll,
    );
    await tester.tap(find.text('Ti faccio sapere'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byTooltip('Torna indietro'),
      -350,
      scrollable: detailScroll,
    );
    await tester.tap(find.byTooltip('Torna indietro'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('events-filter-maybe')));
    await tester.pumpAndSettle();
    expect(find.text('Sotto lo stesso cielo'), findsOneWidget);
    expect(find.text('Ci vediamo al Coguaro'), findsNothing);
    await tester.tap(find.text('Sotto lo stesso cielo'));
    await tester.pumpAndSettle();
    final attendingScroll = find
        .descendant(
          of: find.byKey(const Key('event-detail-page')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Ci sarò'),
      180,
      scrollable: attendingScroll,
    );
    await tester.tap(find.text('Ci sarò'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byTooltip('Torna indietro'),
      -350,
      scrollable: attendingScroll,
    );
    await tester.tap(find.byTooltip('Torna indietro'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('events-filter-attending')));
    await tester.pumpAndSettle();
    expect(find.text('Sotto lo stesso cielo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('eventi pubblici e privati sono distinti e ordinati per ora', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(FuoriApp(dependencies: FuoriDependencies.demo()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-1')));
    await tester.pumpAndSettle();

    expect(find.text('PIANO DI VALE'), findsNothing);
    expect(find.text('EVENTO PUBBLICO · 21:00'), findsOneWidget);
    expect(find.text('CI VEDIAMO AL COGUARO'), findsOneWidget);
    expect(find.text('EVENTO SU INVITO · 20:30'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Sotto lo stesso cielo')).dy,
      lessThan(tester.getTopLeft(find.text('La serata è da Fra')).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'l’invitato vede gli altri invitati e può rispondere in anteprima',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(420, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(FuoriApp(dependencies: FuoriDependencies.demo()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('nav-1')));
      await tester.pumpAndSettle();
      final eventsScroll = find
          .descendant(
            of: find.byKey(const Key('events-page')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('La serata è da Fra'),
        180,
        scrollable: eventsScroll,
      );
      await tester.drag(eventsScroll, const Offset(0, -120));
      await tester.pumpAndSettle();
      await tester.tap(find.text('La serata è da Fra'));
      await tester.pumpAndSettle();
      final detailScroll = find
          .descendant(
            of: find.byKey(const Key('event-detail-page')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('Gli altri invitati'),
        180,
        scrollable: detailScroll,
      );
      expect(find.text('Gli altri invitati'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Ci sarò'),
        180,
        scrollable: detailScroll,
      );
      await tester.tap(find.text('Ci sarò'));
      await tester.pumpAndSettle();
      expect(find.text('Ci sei! Annulla partecipazione'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('si può creare un evento privato dimostrativo', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(FuoriApp(dependencies: FuoriDependencies.demo()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-1')));
    await tester.pumpAndSettle();
    final eventsScroll = find
        .descendant(
          of: find.byKey(const Key('events-page')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Crea un evento'),
      250,
      scrollable: eventsScroll,
    );
    await tester.drag(eventsScroll, const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crea un evento'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('create-event-screen')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('event-title-field')),
      'Una sera insieme',
    );
    await tester.enterText(
      find.byKey(const Key('event-place-field')),
      'Torino',
    );
    final createScroll = find
        .descendant(
          of: find.byKey(const Key('create-event-screen')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Crea evento demo'),
      180,
      scrollable: createScroll,
    );
    await tester.drag(
      find.byKey(const Key('create-event-screen')),
      const Offset(0, -240),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crea evento demo'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('event-detail-page')), findsOneWidget);
    expect(find.text('Una sera insieme'), findsWidgets);
    expect(find.text('Evento su invito'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('il guardaroba mantiene la bozza cambiando sezione', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 760);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(FuoriApp(dependencies: FuoriDependencies.demo()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-3')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('wardrobe-category-1')),
      120,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('profile-page')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byKey(const Key('wardrobe-category-1')));
    await tester.pumpAndSettle();
    final profileScroll = find
        .descendant(
          of: find.byKey(const Key('profile-page')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.byKey(const Key('wardrobe-choice-1')),
      180,
      scrollable: profileScroll,
    );
    await tester.tap(find.byKey(const Key('wardrobe-choice-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-3')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('wardrobe-category-1')),
      -150,
      scrollable: profileScroll,
    );
    expect(find.byKey(const Key('wardrobe-category-1')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('wardrobe-choice-1')),
      180,
      scrollable: profileScroll,
    );
    final choice = find
        .ancestor(
          of: find.byKey(const Key('wardrobe-choice-1')),
          matching: find.byType(Semantics),
        )
        .first;
    expect(tester.widget<Semantics>(choice).properties.selected, isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 420.0, 1280.0]) {
    testWidgets(
      'le quattro sezioni e il dettaglio sono leggibili a $width px',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 760);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          FuoriApp(dependencies: FuoriDependencies.demo()),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('featured-event')), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byKey(const Key('featured-event')));
        await tester.pumpAndSettle();
        final detailScroll = find
            .descendant(
              of: find.byKey(const Key('event-detail-page')),
              matching: find.byType(Scrollable),
            )
            .first;
        await tester.scrollUntilVisible(
          find.text('24 partecipanti'),
          180,
          scrollable: detailScroll,
        );
        expect(find.text('24 partecipanti'), findsOneWidget);
        expect(tester.takeException(), isNull);

        for (final (index, text) in [
          (1, 'Cose belle\nin programma.'),
          (2, 'Ci si trova\ntra amici.'),
          (3, 'Il tuo altro io.'),
        ]) {
          await tester.tap(find.byKey(Key('nav-$index')));
          await tester.pumpAndSettle();
          expect(find.text(text), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      },
    );
  }
}
