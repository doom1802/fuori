import 'package:fuori/app/widgets.dart';
import 'package:fuori/features/account/avatar_catalog.dart';
import 'package:fuori/app/avatar_sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuori/app/fuori_theme.dart';
import 'package:fuori/app/screens.dart';
import 'package:fuori/features/account/avatar_look.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await AvatarSpriteAssets.preload();
  });
  test('preferenze vecchie o non valide non rompono il guardaroba', () {
    expect(AvatarLook.fromJson({'version': 99}).choices, [0, 0, 0, 0, 0, 0]);
    final recovered = AvatarLook.fromJson({
      'version': 1,
      'clothes': 3,
      'hair': -1,
      'pants': '2',
      'extra': 25,
      'skin': 2,
    });
    expect(recovered.choices, [3, 0, 0, 0, 0, 2]);
    expect(AvatarLook.fromJson(recovered.toJson()).choices, recovered.choices);
  });

  test('basi e pelata persistono e i look v1 conservano i colori', () {
    const look = AvatarLook(
      body: AvatarBody.female,
      hairStyle: AvatarHairStyle.bald,
      hair: 2,
      skin: 3,
    );
    final restored = AvatarLook.fromJson(look.toJson());
    expect(restored.body, AvatarBody.female);
    expect(restored.hairStyle, AvatarHairStyle.bald);
    expect(restored.choices, look.choices);
    final legacy = AvatarLook.fromJson({'version': 1, 'hair': 2});
    expect(legacy.hair, 2);
    expect(legacy.body, AvatarBody.male);
    expect(legacy.hairStyle, AvatarHairStyle.spiky);
  });

  test(
    'tutti i modelli su entrambe le basi e gli extra combinati persistono',
    () {
      for (final body in AvatarBody.values) {
        for (var top = 0; top < 8; top++) {
          for (var hair = 0; hair < 8; hair++) {
            for (var pants = 0; pants < 8; pants++) {
              for (var shoes = 0; shoes < 8; shoes++) {
                final look = AvatarLook.fromChoices(
                  [1, 2, 3, 1, 0, 2],
                  body: body,
                  models: [top, hair, pants, shoes],
                  accessoryMask: (1 << 1) | (1 << 4) | (1 << 7),
                );
                expect(
                  AvatarLook.fromJson(look.toJson()).toJson(),
                  look.toJson(),
                );
              }
            }
          }
        }
      }
      var mask = AvatarCatalog.toggleAccessory(0, 0);
      mask = AvatarCatalog.toggleAccessory(mask, 3);
      mask = AvatarCatalog.toggleAccessory(mask, 6);
      expect(mask, 1 | 8 | 64);
      mask = AvatarCatalog.toggleAccessory(mask, 1);
      expect(mask, 2 | 8 | 64);
      expect(AvatarCatalog.toggleAccessory(mask, 1), 8 | 64);
      expect(AvatarCatalog.toggleAccessory(mask, 5), 2 | 8 | 32 | 64);
      expect(AvatarCatalog.toggleAccessory(mask, 7), 2 | 8 | 64 | 128);
      expect(
        AvatarLook.fromJson({
          'version': 2,
          'body': 'female',
          'hairStyle': 'bald',
          'extra': 1,
        }).models,
        [0, 3, 0, 0],
      );
    },
  );

  test('ogni asset del catalogo ha gli otto orientamenti indicizzati', () {
    final assets = AvatarSpriteAssets.loaded!;
    for (final name in [
      'tops',
      'tops-wave',
      'bottoms',
      'footwear',
      'hair',
      'extras',
    ]) {
      for (var model = 0; model < 8; model++) {
        for (var direction = 0; direction < 8; direction++) {
          final source = assets.source(name, model, direction);
          if (name == 'hair' && model == 3) {
            expect(source, isNull);
          } else {
            expect(source, isNotNull, reason: '$name $model $direction');
            expect(source!.width, greaterThan(0));
            expect(source.height, greaterThan(0));
          }
        }
      }
    }
  });

  testWidgets(
    'saluto e tutti gli extra compatibili si compongono sulle otto viste',
    (tester) async {
      for (final body in AvatarBody.values) {
        for (var direction = 0; direction < 8; direction++) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: FullBodyAvatar(
                    look: AvatarLook(
                      body: body,
                      topModel: 7,
                      hairModel: 4,
                      bottomModel: 7,
                      shoeModel: 7,
                      accessoryMask: 1 | 8 | 32 | 64 | 128,
                    ),
                    direction: direction,
                    wave: true,
                    width: 126,
                    height: 222,
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets(
    'un salvataggio fallito conserva la bozza e permette di riprovare',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 760);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final attempts = <AvatarLook>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: FuoriTheme.light(),
          home: Scaffold(
            body: ProfileScreen(
              initialLook: const AvatarLook(clothes: 1, skin: 2),
              onSaveAvatar: (look) async {
                attempts.add(look);
                if (attempts.length == 1) throw Exception('offline');
                return look;
              },
            ),
          ),
        ),
      );
      await tester.ensureVisible(find.text('Femminile'));
      await tester.tap(find.text('Femminile'));
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('wardrobe-category-1')));
      await tester.tap(find.byKey(const Key('wardrobe-category-1')));
      await tester.pump();
      await tester.scrollUntilVisible(
        find.byKey(const Key('wardrobe-model-1-3')),
        100,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('profile-page')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.byKey(const Key('wardrobe-model-1-3')));
      await tester.pump();
      expect(find.byKey(const Key('wardrobe-choice-0')), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const Key('wardrobe-category-0')),
        -150,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('profile-page')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.byKey(const Key('wardrobe-category-0')));
      await tester.pump();
      await tester.scrollUntilVisible(
        find.byKey(const Key('avatar-rotate-left')),
        -100,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('profile-page')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('avatar-rotate-left')));
      await tester.pump();
      expect(find.text('Vista 8 di 8'), findsOneWidget);
      await tester.tap(find.byKey(const Key('avatar-rotate-right')));
      await tester.pump();
      expect(find.text('Vista 1 di 8'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('wardrobe-choice-3')),
        150,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('profile-page')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.byKey(const Key('wardrobe-choice-3')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Questo sono io'),
        150,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('profile-page')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Questo sono io'));
      await tester.pumpAndSettle();
      expect(find.textContaining('La bozza è qui'), findsOneWidget);
      expect(find.text('Look salvato'), findsNothing);
      await tester.tap(find.text('Questo sono io'));
      await tester.pumpAndSettle();
      expect(attempts.map((look) => look.choices), [
        [3, 0, 0, 0, 0, 2],
        [3, 0, 0, 0, 0, 2],
      ]);
      expect(
        attempts.every(
          (look) =>
              look.body == AvatarBody.female &&
              look.hairStyle == AvatarHairStyle.bald,
        ),
        isTrue,
      );
      expect(find.text('Look salvato'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
