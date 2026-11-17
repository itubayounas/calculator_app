import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_user.dart';
import '../models/history_entry.dart';
import '../services/history_service.dart';
import '../utils/exceptions.dart';
import '../utils/ui_helpers.dart';

class HistoryScreen extends StatefulWidget {
  final AppUser user;
  final HistoryService historyService;

  const HistoryScreen({
    super.key,
    required this.user,
    required this.historyService,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> _entries = [];
  bool _loading = true;
  bool _fromCache = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget.historyService.load(widget.user.uid);
    if (!mounted) return;
    setState(() {
      _entries = result.entries;
      _fromCache = result.fromCache;
      _loading = false;
    });
  }

  Future<void> _deleteEntry(HistoryEntry entry) async {
    setState(() => _entries.removeWhere((e) => e.id == entry.id));
    try {
      await widget.historyService.delete(widget.user.uid, entry.id);
    } on HistorySyncException catch (e) {
      if (mounted) showNotice(context, e.message);
    }
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text('This will delete every saved calculation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _entries = []);
    try {
      await widget.historyService.clearAll(widget.user.uid);
    } on HistorySyncException catch (e) {
      if (mounted) showNotice(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              tooltip: 'Clear all',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _confirmClearAll,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_fromCache)
            Container(
              width: double.infinity,
              color: colors.secondaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Offline: showing the copy saved on this device.',
                style: TextStyle(color: colors.onSecondaryContainer),
              ),
            ),
          Expanded(child: _buildBody(colors)),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme colors) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_entries.isEmpty) {
      return Center(
        child: Text(
          'No calculations yet',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16),
        ),
      );
    }

    final dateFormat = DateFormat('d MMM, h:mm a');

    return ListView.separated(
      itemCount: _entries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return Dismissible(
          key: ValueKey(entry.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: colors.errorContainer,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: Icon(Icons.delete_outline, color: colors.onErrorContainer),
          ),
          onDismissed: (_) => _deleteEntry(entry),
          child: ListTile(
            title: Text(
              entry.result,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${entry.expression}  •  ${dateFormat.format(entry.createdAt)}',
            ),
            // tap = send the value back to the calculator
            onTap: () => Navigator.of(context).pop(entry.result),
          ),
        );
      },
    );
  }
}
