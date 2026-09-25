enum EventVisibility { public, private }

class FuoriEvent {
  const FuoriEvent({
    required this.id,
    required this.title,
    required this.place,
    required this.dayLabel,
    required this.timeLabel,
    required this.attendeeCount,
    required this.visibleFriends,
    this.isFeatured = false,
    this.visibility = EventVisibility.public,
    this.invitedNames = const [],
    this.organizerLabel,
  });

  final String id;
  final String title;
  final String place;
  final String dayLabel;
  final String timeLabel;
  final int attendeeCount;
  final List<String> visibleFriends;
  final bool isFeatured;
  final EventVisibility visibility;
  final List<String> invitedNames;
  final String? organizerLabel;
}
