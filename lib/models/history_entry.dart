// One saved calculation. Plain data only, no logic and no Flutter imports.
class HistoryEntry {
  final String id;
  final String expression; // e.g. "12 + 8"
  final String result; // e.g. "20"
  final DateTime createdAt;

  const HistoryEntry({
    required this.id,
    required this.expression,
    required this.result,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'expression': expression,
        'result': result,
        // stored as milliseconds so it works the same in Firestore and local storage
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory HistoryEntry.fromMap(String id, Map<String, dynamic> map) {
    return HistoryEntry(
      id: id,
      expression: (map['expression'] ?? '') as String,
      result: (map['result'] ?? '') as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] ?? 0) as int,
      ),
    );
  }
}
