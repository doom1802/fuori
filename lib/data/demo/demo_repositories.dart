import '../../features/events/event.dart';
import '../../features/events/event_repository.dart';
import '../../features/friends/friend.dart';
import '../../features/friends/friend_repository.dart';

// These rows are visual examples. No account, friendship, or event exists yet.
final class DemoEventRepository implements EventRepository {
  @override
  Future<List<FuoriEvent>> upcomingEvents() async => const [
    FuoriEvent(
      id: 'coguaro-demo',
      title: 'Ci vediamo al Coguaro',
      place: 'Coguaro · Torino',
      dayLabel: 'DOMANI',
      timeLabel: '21:00 – 01:00',
      attendeeCount: 24,
      visibleFriends: ['Vale', 'Fra', 'Leo'],
      isFeatured: true,
    ),
    FuoriEvent(
      id: 'cielo-demo',
      title: 'Sotto lo stesso cielo',
      place: 'Piazza Castello · Torino',
      dayLabel: 'SABATO',
      timeLabel: '20:30 – 00:30',
      attendeeCount: 48,
      visibleFriends: ['Vale', 'Fra'],
    ),
    FuoriEvent(
      id: 'fra-privato-demo',
      title: 'La serata è da Fra',
      place: 'Casa di Fra · Torino',
      dayLabel: 'SABATO',
      timeLabel: '20:30 – 01:00',
      attendeeCount: 12,
      visibleFriends: ['Fra', 'Vale'],
      invitedNames: ['Domi', 'Vale', 'Leo'],
      organizerLabel: 'Fra',
      visibility: EventVisibility.private,
    ),
  ];
}

final class DemoFriendRepository implements FriendRepository {
  @override
  Future<List<FuoriFriend>> friends() async => const [
    FuoriFriend(
      id: 'vale-demo',
      name: 'Vale',
      status: 'Coguaro · domani alle 21:30',
    ),
    FuoriFriend(
      id: 'fra-demo',
      name: 'Fra',
      status: 'Coguaro · domani alle 21:00',
    ),
    FuoriFriend(
      id: 'leo-demo',
      name: 'Leo',
      status: 'Nessun evento in programma',
    ),
  ];
}
