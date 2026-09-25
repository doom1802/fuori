import 'event.dart';

abstract interface class EventRepository {
  Future<List<FuoriEvent>> upcomingEvents();
}
