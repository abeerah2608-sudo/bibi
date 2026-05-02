import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_card_data.dart';

// EVENTS
abstract class FavoritesEvent {}

class ToggleFavoriteEvent extends FavoritesEvent {
  final VideoCardData video;
  ToggleFavoriteEvent(this.video);
}
class FavoriteItem {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String videoUrl;

  FavoriteItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.videoUrl,
  });
}
class LoadFavoritesEvent extends FavoritesEvent {}

// STATE
class FavoritesState {
  final Set<String> favoriteIds;

  FavoritesState({required this.favoriteIds});

  FavoritesState copyWith({Set<String>? favoriteIds}) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }
}

// BLOC
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  static const _key = "favorites";
  static const _userIdKey = 'user_id';
  static const _fallbackUserId = 'guest_user';

  final FirebaseFirestore _firestore;

  FavoritesBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(FavoritesState(favoriteIds: {})) {
    on<LoadFavoritesEvent>(_load);
    on<ToggleFavoriteEvent>(_toggle);

    add(LoadFavoritesEvent()); // load on start
  }

  Future<void> _load(
      LoadFavoritesEvent event, Emitter<FavoritesState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final localList = prefs.getStringList(_key) ?? [];
    debugPrint(
      '⭐ Favorites load: local cache has ${localList.length} ids: $localList',
    );

    try {
      final userId = await _resolveUserId(prefs);
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favourites')
          .get(const GetOptions(source: Source.server));

      debugPrint('🔍 Favorites load: found ${snapshot.docs.length} docs in Firestore favourites subcollection');
      for (final doc in snapshot.docs) {
        debugPrint('  - Doc ID: ${doc.id} | data: ${doc.data()}');
      }

      final remoteIds = snapshot.docs.map((doc) => doc.id).toSet();

      if (remoteIds.isNotEmpty) {
        await prefs.setStringList(_key, remoteIds.toList());
        debugPrint(
          '✅ Favorites source=Firebase subcollection | ids=${remoteIds.length} | cached locally | remoteIds=$remoteIds',
        );
        emit(FavoritesState(favoriteIds: remoteIds));
        return;
      }
      debugPrint('ℹ️ Favorites Firestore subcollection empty for userId=$userId, falling back to local cache');
    } catch (e) {
      debugPrint('⚠️ Favorites source=Local fallback | reason=Firestore read failed | error=$e');
    }

    debugPrint('✅ Favorites source=Local cache | ids=${localList.length} | localList=$localList');
    emit(FavoritesState(favoriteIds: localList.toSet()));
  }

  Future<void> _toggle(
      ToggleFavoriteEvent event, Emitter<FavoritesState> emit) async {
    final prefs = await SharedPreferences.getInstance();

    final current = Set<String>.from(state.favoriteIds);
    final videoId = _favoriteKey(event.video);
    final titleKey = event.video.titleKey ?? event.video.title;
    final wasFavorite = current.contains(videoId);

    debugPrint('⭐ Favorites toggle START:');
    debugPrint('  - video.title=${event.video.title}');
    debugPrint('  - video.titleKey=${event.video.titleKey}');
    debugPrint('  - video.favoriteId=${event.video.favoriteId}');
    debugPrint('  - computed videoId=$videoId');
    debugPrint('  - titleKey=$titleKey');
    debugPrint('  - wasFavorite=$wasFavorite');
    debugPrint('  - current state before toggle: $current');

    if (wasFavorite) {
      current.remove(videoId);
    } else {
      current.add(videoId);
    }

    await prefs.setStringList(_key, current.toList());
    debugPrint(
      '⭐ Favorites toggle: key=$videoId | nowFavorite=${current.contains(videoId)} | localCount=${current.length} | state=$current',
    );

    try {
      final userId = await _resolveUserId(prefs);
      if (userId == _fallbackUserId) {
        debugPrint(
          '⚠️ Favorites sync skipped: no Firebase Auth user available. Enable Anonymous Auth or sign in before writing favorites.',
        );
        emit(state.copyWith(favoriteIds: current));
        return;
      }

      final favouriteDoc = _firestore.collection('users').doc(userId).collection('favourites').doc(videoId);

      if (wasFavorite) {
        await favouriteDoc.delete();
        debugPrint('  ✓ Favorite deleted: users/$userId/favourites/$videoId');
      } else {
        await favouriteDoc.set({
          'date_added': FieldValue.serverTimestamp(),
          'title_key': titleKey,
        }, SetOptions(merge: true));
        debugPrint('  ✓ Favorite added: users/$userId/favourites/$videoId with title_key=$titleKey');
      }

      debugPrint(
        '✅ Favorites sync: Firestore write success for userId=$userId | total=${current.length}',
      );
    } catch (e, stacktrace) {
      debugPrint(
        '⚠️ Favorites sync: Firestore write failed, error=$e\nStacktrace: $stacktrace',
      );
      debugPrint('⚠️ Error type: ${e.runtimeType}');
      if (e is FirebaseException) {
        debugPrint('⚠️ Firebase error code: ${e.code}');
        debugPrint('⚠️ Firebase error message: ${e.message}');
      }
    }

    emit(state.copyWith(favoriteIds: current));
  }

  String _favoriteKey(VideoCardData video) {
    return video.favoriteId ?? video.titleKey ?? video.title;
  }

  Future<String> _resolveUserId(SharedPreferences prefs) async {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null && authUser.uid.trim().isNotEmpty) {
      debugPrint('ℹ️ Favorites userId from Firebase Auth: ${authUser.uid}');
      return authUser.uid;
    }

    try {
      final signedIn = await FirebaseAuth.instance.signInAnonymously();
      final anonymousUserId = signedIn.user?.uid;
      if (anonymousUserId != null && anonymousUserId.trim().isNotEmpty) {
        debugPrint('ℹ️ Favorites userId from anonymous auth: $anonymousUserId');
        await prefs.setString(_userIdKey, anonymousUserId);
        return anonymousUserId;
      }
    } catch (e) {
      debugPrint('⚠️ Favorites anonymous sign-in failed: $e');
      debugPrint(
        '⚠️ If this keeps happening, enable Anonymous Authentication in Firebase Console > Authentication > Sign-in method.',
      );
    }

    final fromPrefs = prefs.getString(_userIdKey);
    if (fromPrefs != null && fromPrefs.trim().isNotEmpty) {
      debugPrint('ℹ️ Favorites userId from SharedPreferences: $fromPrefs');
      return fromPrefs.trim();
    }

    debugPrint('⚠️ Favorites userId not found; using fallback=$_fallbackUserId only for local cache');
    await prefs.setString(_userIdKey, _fallbackUserId);
    return _fallbackUserId;
  }
}