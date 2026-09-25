import 'friend.dart';

abstract interface class FriendRepository {
  Future<List<FuoriFriend>> friends();
}
