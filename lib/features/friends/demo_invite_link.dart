/// Local preview link. It has no authentication or authority on the server.
final class DemoInviteLink {
  static Uri create(Uri appUri, String name) => appUri.replace(
    queryParameters: {'invite': 'fuori-demo', 'from': name},
    fragment: '',
  );

  static String? inviter(Uri appUri, Uri candidate) {
    if (candidate.scheme != appUri.scheme ||
        candidate.host != appUri.host ||
        candidate.port != appUri.port ||
        candidate.path != appUri.path ||
        candidate.queryParameters['invite'] != 'fuori-demo') {
      return null;
    }
    final name = candidate.queryParameters['from']?.trim() ?? '';
    return name.isEmpty
        ? 'Un amico'
        : (name.length > 30 ? name.substring(0, 30) : name);
  }
}
