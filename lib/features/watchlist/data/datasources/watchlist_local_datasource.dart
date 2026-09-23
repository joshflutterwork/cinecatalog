import 'dart:convert';

import 'package:cinecatalog/core/network/guard_request.dart';
import 'package:cinecatalog/features/watchlist/data/models/watchlist_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The watchlist as one JSON array in [SharedPreferences], which persists to
/// disk (NSUserDefaults / Android shared prefs): it survives closing and
/// restarting the app, and only goes away on uninstall or "clear data".
///
/// Throws [FormatException] for a corrupt value and
/// [WatchlistWriteException] when a write is refused; the repository turns
/// both into `StorageFailure`.
abstract interface class WatchlistLocalDataSource {
  List<WatchlistItemModel> read();

  Future<void> write(List<WatchlistItemModel> items);
}

final class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  const WatchlistLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  /// Versioned so a future format change can migrate instead of crash.
  static const _key = 'watchlist.v1';

  @override
  List<WatchlistItemModel> read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Watchlist is not a JSON array');
    }
    return [
      for (final item in decoded)
        parseJson<WatchlistItemModel>(item, WatchlistItemModel.fromJson),
    ];
  }

  @override
  Future<void> write(List<WatchlistItemModel> items) async {
    final saved = await _prefs.setString(
      _key,
      jsonEncode([for (final item in items) item.toJson()]),
    );
    if (!saved) throw const WatchlistWriteException();
  }
}

/// [SharedPreferences] reported that it could not persist the watchlist.
final class WatchlistWriteException implements Exception {
  const WatchlistWriteException();

  @override
  String toString() => 'WatchlistWriteException: the write was refused';
}
