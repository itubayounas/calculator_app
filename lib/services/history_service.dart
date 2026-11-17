import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_entry.dart';
import '../utils/exceptions.dart';

class HistoryLoadResult {
  final List<HistoryEntry> entries;
  final bool fromCache; // true when Firestore could not be reached

  const HistoryLoadResult(this.entries, {required this.fromCache});
}

// History lives in two places: local storage (always written first)
// and Firestore at users/{uid}/history.
class HistoryService {
  final FirebaseFirestore _db;
  static const Duration _timeout = Duration(seconds: 6);

  HistoryService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _db.collection('users').doc(uid).collection('history');

  String _localKey(String uid) => 'history_$uid';

  // ---------- Local storage ----------

  Future<List<HistoryEntry>> _readLocal(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey(uid));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final entries = list
          .map((item) => HistoryEntry.fromMap(
                item['id'] as String,
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries;
    } catch (_) {
      return []; // corrupted data, start clean instead of crashing
    }
  }

  Future<void> _writeLocal(String uid, List<HistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final list = entries.map((e) => {'id': e.id, ...e.toMap()}).toList();
    await prefs.setString(_localKey(uid), jsonEncode(list));
  }

  // ---------- Public API ----------

  // Saves locally first, then tries the cloud.
  // Throws HistorySyncException if only the cloud part failed.
  Future<void> add(String uid, String expression, String result) async {
    final entry = HistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      expression: expression,
      result: result,
      createdAt: DateTime.now(),
    );

    final local = await _readLocal(uid);
    local.insert(0, entry);
    await _writeLocal(uid, local);

    try {
      await _collection(uid).doc(entry.id).set(entry.toMap()).timeout(_timeout);
    } catch (_) {
      throw const HistorySyncException();
    }
  }

  // Never throws: falls back to the local copy if the cloud is unreachable.
  Future<HistoryLoadResult> load(String uid) async {
    final local = await _readLocal(uid);
    try {
      final snapshot = await _collection(uid)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(_timeout);

      final cloud =
          snapshot.docs.map((d) => HistoryEntry.fromMap(d.id, d.data())).toList();
      final cloudIds = cloud.map((e) => e.id).toSet();

      // entries saved while offline: push them up now
      final unsynced = local.where((e) => !cloudIds.contains(e.id)).toList();
      for (final entry in unsynced) {
        try {
          await _collection(uid).doc(entry.id).set(entry.toMap()).timeout(_timeout);
        } catch (_) {
          // will try again next time
        }
      }

      final merged = [...cloud, ...unsynced]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      await _writeLocal(uid, merged);
      return HistoryLoadResult(merged, fromCache: false);
    } catch (_) {
      return HistoryLoadResult(local, fromCache: true);
    }
  }

  Future<void> delete(String uid, String id) async {
    final local = await _readLocal(uid);
    local.removeWhere((e) => e.id == id);
    await _writeLocal(uid, local);

    try {
      await _collection(uid).doc(id).delete().timeout(_timeout);
    } catch (_) {
      throw const HistorySyncException(
          'Deleted on this device, but could not sync to the cloud');
    }
  }

  Future<void> clearAll(String uid) async {
    await _writeLocal(uid, []);

    try {
      final snapshot = await _collection(uid).get().timeout(_timeout);
      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit().timeout(_timeout);
    } catch (_) {
      throw const HistorySyncException(
          'Cleared on this device, but could not sync to the cloud');
    }
  }
}
