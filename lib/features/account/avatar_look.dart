import 'avatar_catalog.dart';

enum AvatarBody { male, female }

enum AvatarHairStyle { spiky, bald }

/// Versioned wardrobe selections, independent of the Flutter renderer.
class AvatarLook {
  const AvatarLook({
    this.body = AvatarBody.male,
    AvatarHairStyle hairStyle = AvatarHairStyle.spiky,
    int? hairModel,
    this.topModel = 0,
    this.bottomModel = 0,
    this.shoeModel = 0,
    int? accessoryMask,
    this.clothes = 0,
    this.hair = 0,
    this.pants = 0,
    this.shoes = 0,
    this.extra = 0,
    this.skin = 0,
  }) : hairModel = hairModel ?? (hairStyle == AvatarHairStyle.bald ? 3 : 0),
       accessoryMask = accessoryMask ?? (extra == 1 ? 1 : 0);

  static const choiceCounts = [4, 4, 4, 4, 2, 4];
  static const _keys = ['clothes', 'hair', 'pants', 'shoes', 'extra', 'skin'];

  final AvatarBody body;
  final int topModel, hairModel, bottomModel, shoeModel, accessoryMask;
  AvatarHairStyle get hairStyle =>
      hairModel == 3 ? AvatarHairStyle.bald : AvatarHairStyle.spiky;
  List<int> get models => [topModel, hairModel, bottomModel, shoeModel];
  final int clothes;
  final int hair;
  final int pants;
  final int shoes;
  final int extra;
  final int skin;

  List<int> get choices => [clothes, hair, pants, shoes, extra, skin];

  factory AvatarLook.fromChoices(
    List<int> values, {
    AvatarBody body = AvatarBody.male,
    AvatarHairStyle hairStyle = AvatarHairStyle.spiky,
    List<int>? models,
    int? accessoryMask,
  }) {
    if (values.length != choiceCounts.length ||
        List.generate(
          values.length,
          (i) => i,
        ).any((i) => values[i] < 0 || values[i] >= choiceCounts[i])) {
      throw const FormatException('Selezioni del guardaroba non valide.');
    }
    if (models != null &&
        (models.length != 4 || models.any((v) => v < 0 || v > 7))) {
      throw const FormatException('Modelli avatar non validi.');
    }
    return AvatarLook(
      topModel: models?[0] ?? 0,
      hairModel: models?[1],
      bottomModel: models?[2] ?? 0,
      shoeModel: models?[3] ?? 0,
      accessoryMask: accessoryMask == null
          ? null
          : AvatarCatalog.normalizeAccessories(accessoryMask),
      body: body,
      hairStyle: hairStyle,
      clothes: values[0],
      hair: values[1],
      pants: values[2],
      shoes: values[3],
      extra: values[4],
      skin: values[5],
    );
  }

  factory AvatarLook.fromJson(Object? value) {
    if (value is! Map || ![1, 2, 3].contains(value['version'])) {
      return const AvatarLook();
    }
    return AvatarLook.fromChoices(
      [
        for (var i = 0; i < _keys.length; i++)
          if (value[_keys[i]] is int &&
              (value[_keys[i]] as int) >= 0 &&
              (value[_keys[i]] as int) < choiceCounts[i])
            value[_keys[i]] as int
          else
            0,
      ],
      models: value['version'] == 3
          ? [
              for (final key in [
                'topModel',
                'hairModel',
                'bottomModel',
                'shoeModel',
              ])
                value[key] is int &&
                        (value[key] as int) >= 0 &&
                        (value[key] as int) < 8
                    ? value[key] as int
                    : 0,
            ]
          : null,
      accessoryMask: value['version'] == 3 && value['accessoryMask'] is int
          ? value['accessoryMask'] as int
          : null,
      body: value['version'] != 1 && value['body'] == 'female'
          ? AvatarBody.female
          : AvatarBody.male,
      hairStyle: value['version'] != 1 && value['hairStyle'] == 'bald'
          ? AvatarHairStyle.bald
          : AvatarHairStyle.spiky,
    );
  }

  Map<String, Object> toJson() => {
    'version': 3,
    'topModel': topModel,
    'hairModel': hairModel,
    'bottomModel': bottomModel,
    'shoeModel': shoeModel,
    'accessoryMask': accessoryMask,
    'body': body.name,
    'hairStyle': hairStyle.name,
    for (var i = 0; i < _keys.length; i++) _keys[i]: choices[i],
  };
}
