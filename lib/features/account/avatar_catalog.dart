/// Stable catalog order matches the approved preview codes.
abstract final class AvatarCatalog {
  static const tops = [
    'V1 · Felpa',
    'V2 · T-shirt',
    'V3 · Bomber',
    'V4 · Denim',
    'V5 · Maglione a righe',
    'V6 · Camicia aperta',
    'V7 · Giacca sportiva',
    'V8 · Cardigan',
  ];
  static const hair = [
    'H1 · Spettinati',
    'H2 · Corti sfumati',
    'H3 · Ricci',
    'H4 · Pelata',
    'H5 · Lunghi mossi',
    'H6 · Coda alta',
    'H7 · Treccine',
    'H8 · Rasati',
  ];
  static const bottoms = [
    'P1 · Pantaloni scuri',
    'P2 · Jeans',
    'P3 · Cargo',
    'P4 · Joggers',
    'P5 · Shorts',
    'P6 · Pantaloni larghi',
    'P7 · Gonna midi',
    'P8 · Salopette',
  ];
  static const shoes = [
    'S1 · Sneakers',
    'S2 · Sneakers alte',
    'S3 · Skate',
    'S4 · Running',
    'S5 · Anfibi',
    'S6 · Chelsea boots',
    'S7 · Mocassini',
    'S8 · Sandali',
  ];
  static const extras = [
    'E1 · Occhiali rettangolari',
    'E2 · Occhiali tondi',
    'E3 · Occhiali da sole',
    'E4 · Cappellino',
    'E5 · Berretto',
    'E6 · Cuffie',
    'E7 · Zainetto',
    'E8 · Tracolla',
  ];
  static const categories = [tops, hair, bottoms, shoes, extras];
  static const accessoryGroups = [0x07, 0x38, 0xC0];
  static int normalizeAccessories(int value) {
    var result = 0;
    for (final group in accessoryGroups) {
      final selected = value & group;
      if (selected != 0) result |= selected & -selected;
    }
    return result;
  }

  static int toggleAccessory(int mask, int index) {
    if (index < 0 || index >= extras.length) {
      throw RangeError.index(index, extras);
    }
    final bit = 1 << index;
    if (mask & bit != 0) return mask & ~bit;
    final group = accessoryGroups.firstWhere((group) => group & bit != 0);
    return (mask & ~group) | bit;
  }
}
