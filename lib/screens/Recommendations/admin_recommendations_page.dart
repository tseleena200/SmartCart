// lib/pages/admin_recommendations_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../Services/api_service.dart';

class AdminRecommendationsPage extends StatefulWidget {
  const AdminRecommendationsPage({super.key});

  @override
  State<AdminRecommendationsPage> createState() => _AdminRecommendationsPageState();
}

class _AdminRecommendationsPageState extends State<AdminRecommendationsPage> {
  // Point this to your FastAPI host
  static const String baseUrl = 'http://127.0.0.1:8000';
  final _api = const ApiService(baseUrl);

  final TextEditingController _userIdCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();

  bool _busy = false;
  String _log = '';
  Map<String, dynamic>? _userDoc; // structured data for pretty panel

  // table data
  List<Map<String, dynamic>> _rows = [];
  List<Map<String, dynamic>> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _rows;
    return _rows.where((r) {
      final id = (r['id'] ?? '').toString().toLowerCase();
      final name = (r['name'] ?? '').toString().toLowerCase();
      final cats = (r['top_categories'] ?? '').toString().toLowerCase();
      return id.contains(q) || name.contains(q) || cats.contains(q);
    }).toList();
  }

  // ===== AUTO REFRESH =====
  Timer? _autoTimer;
  bool _autoRefreshEnabled = true;
  Duration _autoRefreshEvery = const Duration(seconds: 30);

  void _startAuto() {
    _autoTimer?.cancel();
    if (!_autoRefreshEnabled) return;
    _autoTimer = Timer.periodic(_autoRefreshEvery, (t) async {
      if (!mounted) return;
      if (_busy) return;            // no overlapping calls
      if (_userDoc != null) return; // don’t clobber the pretty panel
      await _loadTable();
    });
  }

  void _stopAuto() {
    _autoTimer?.cancel();
    _autoTimer = null;
  }
  // ========================

  @override
  void initState() {
    super.initState();
    _userIdCtrl.addListener(() => setState(() {}));
    _searchCtrl.addListener(() => setState(() {}));
    _loadTable().then((_) => _startAuto()); // first load, then start timer
  }

  @override
  void dispose() {
    _stopAuto();
    _userIdCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _dividerColor(BuildContext c) =>
      Theme.of(c).colorScheme.onSurface.withOpacity(0.10);

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------- Page ops (now calling the Facade) ----------
  Future<void> _checkHealth() async {
    setState(() => _busy = true);
    try {
      final j = await _api.checkHealth();
      setState(() {
        _userDoc = null; // health = raw only
        _log = j.toString();
      });
      _toast('Health OK');
    } catch (e) {
      setState(() {
        _userDoc = null;
        _log = 'Error: $e';
      });
      _toast('Failed: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _loadTable() async {
    setState(() => _busy = true);
    try {
      _rows = await _api.listRecs(limit: 200);
      setState(() {}); // rebuild
    } catch (e) {
      _toast('Failed: $e');
      setState(() => _log = 'Error: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _viewUser(String userId) async {
    setState(() => _busy = true);
    try {
      final j = await _api.getUserRec(userId);
      setState(() {
        _userDoc = j;   // show pretty panel
        _log = '';      // 🔑 hide raw while pretty is open
      });
      _toast('Loaded');
    } catch (e) {
      setState(() {
        _userDoc = null;
        _log = 'Error: $e';
      });
      _toast('Failed: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _refreshUser(String userId) async {
    setState(() => _busy = true);
    try {
      await _api.refreshUser(userId);
      await _loadTable();
      _toast('Done');
    } catch (e) {
      _toast('Failed: $e');
      setState(() => _log = 'Error: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _deleteUser(String userId) async {
    setState(() => _busy = true);
    try {
      await _api.deleteUser(userId);
      await _loadTable();
      _toast('Deleted');
    } catch (e) {
      _toast('Failed: $e');
      setState(() => _log = 'Error: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  static String _short(String? s, {int max = 80}) {
    final t = (s ?? '').replaceAll('\n', ' ');
    if (t.length <= max) return t;
    return '${t.substring(0, max)}…';
  }

  // ---------- Pretty Response Panel helpers ----------
  Widget _kv(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(fontWeight: bold ? FontWeight.w600 : FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _splitCsv(String? s) {
    final raw = (s ?? '').trim();
    if (raw.isEmpty) return [];
    return raw
        .split(RegExp(r',\s+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Widget _chips(String label, String? csv) {
    final items = _splitCsv(csv);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 6),
          items.isEmpty
              ? Text('—', style: TextStyle(color: Theme.of(context).hintColor))
              : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (e) => Chip(
                label: Text(_short(e, max: 40)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }

  // Row builder with zebra stripes and button actions
  DataRow _buildRow(Map<String, dynamic> r, int index) {
    final id = (r['id'] ?? '').toString();
    final name = (r['name'] ?? '').toString();
    final cold = (r['cold_start'] ?? false) == true;
    final cats = (r['top_categories'] ?? '').toString();
    final ymal = (r['you_may_also_like'] ?? '').toString();
    final buy = (r['buy_again'] ?? '').toString();
    final ts = (r['timestamp'] ?? '').toString();

    final rowShade = index.isEven ? Colors.white.withOpacity(0.02) : Colors.transparent;

    return DataRow(
      color: MaterialStatePropertyAll(rowShade),
      cells: [
        DataCell(Text(name.isEmpty ? '(No name)' : name)),
        DataCell(Text(_short(id, max: 22))),
        DataCell(Text(cold ? 'Yes' : 'No')),
        DataCell(Text(_short(cats))),
        DataCell(Text(_short(ymal))),
        DataCell(Text(_short(buy))),
        DataCell(Text(_short(ts, max: 24))),
        DataCell(
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('View'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(72, 34),
                ),
                onPressed: () => _viewUser(id),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(92, 34),
                ),
                onPressed: () => _refreshUser(id),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(84, 34),
                  backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.15),
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => _deleteUser(id),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _userIdCtrl.text.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Recommendations')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Column(
          children: [
            if (_busy) const LinearProgressIndicator(minHeight: 2),

            // Top actions
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.tonal(
                    onPressed: _checkHealth,
                    child: const Text('Check Health'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      setState(() => _busy = true);
                      try {
                        await _api.refreshAll();
                        await _loadTable();
                        _toast('Recommendations Updated');
                      } catch (e) {
                        _toast('Failed: $e');
                        setState(() => _log = 'Error: $e');
                      } finally {
                        setState(() => _busy = false);
                      }
                    },
                    child: const Text('Refresh ALL users'),
                  ),
                  FilledButton.tonal(
                    onPressed: _loadTable,
                    child: const Text('Reload table'),
                  ),

                  // ==== AUTO REFRESH TOGGLE + INTERVAL ====
                  const SizedBox(width: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: _autoRefreshEnabled,
                        onChanged: (v) {
                          setState(() => _autoRefreshEnabled = v);
                          v ? _startAuto() : _stopAuto();
                        },
                      ),
                      const Text('Auto refresh'),
                      const SizedBox(width: 12),
                      DropdownButton<Duration>(
                        value: _autoRefreshEvery,
                        items: const [
                          Duration(seconds: 15),
                          Duration(seconds: 30),
                          Duration(minutes: 1),
                          Duration(minutes: 5),
                        ].map((d) {
                          final label = d.inSeconds < 60 ? '${d.inSeconds}s' : '${d.inMinutes}m';
                          return DropdownMenuItem(value: d, child: Text(label));
                        }).toList(),
                        onChanged: (d) {
                          if (d == null) return;
                          setState(() => _autoRefreshEvery = d);
                          if (_autoRefreshEnabled) _startAuto();
                        },
                      ),
                    ],
                  ),
                  // =======================================
                ],
              ),
            ),

            // Search + manual user id row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search by name, user id, or category…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 340,
                    child: TextField(
                      controller: _userIdCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'User ID (manual)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: uid.isEmpty ? null : () => _refreshUser(uid),
                    child: const Text('Refresh user'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: uid.isEmpty ? null : () => _viewUser(uid),
                    child: const Text('View user rec'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: uid.isEmpty ? null : () => _deleteUser(uid),
                    child: const Text('Delete user rec'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Table
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 1100),
                      child: SingleChildScrollView(
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _dividerColor(context), width: 1),
                            ),
                            child: DataTableTheme(
                              data: DataTableThemeData(
                                headingRowColor: MaterialStatePropertyAll(
                                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.35),
                                ),
                                headingTextStyle: Theme.of(context).textTheme.labelLarge,
                                dividerThickness: 1.0,
                                dataRowMinHeight: 44,
                                dataRowMaxHeight: 64,
                              ),
                              child: DataTable(
                                headingRowHeight: 44,
                                columns: const [
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('User ID')),
                                  DataColumn(label: Text('Cold')),
                                  DataColumn(label: Text('Top categories')),
                                  DataColumn(label: Text('You may also like')),
                                  DataColumn(label: Text('Buy again')),
                                  DataColumn(label: Text('Timestamp')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: List<DataRow>.generate(
                                  _filtered.length,
                                      (i) => _buildRow(_filtered[i], i),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Response area (pretty OR raw — never both)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Response', style: Theme.of(context).textTheme.titleMedium),
                      if (_userDoc != null)
                        IconButton(
                          tooltip: 'Close',
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() {
                            _userDoc = null; // hide pretty
                            _log = '';       // keep area clean
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.25),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _userDoc != null
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _kv('Name', (_userDoc!['name'] ?? '').toString(), bold: true),
                          _kv('User ID', (_userDoc!['user_id'] ?? _userDoc!['id'] ?? '').toString()),
                          _kv('Cold start', ((_userDoc!['cold_start'] ?? false) ? 'Yes' : 'No')),
                          _kv('Timestamp', (_userDoc!['timestamp'] ?? '').toString()),
                          const Divider(height: 24),
                          _kv('Top categories', (_userDoc!['top_categories'] ?? '').toString()),
                          _chips('You may also like', (_userDoc!['you_may_also_like'] ?? '').toString()),
                          _chips('Buy again', (_userDoc!['buy_again'] ?? '').toString()),
                          _chips('Because you liked', (_userDoc!['because_you_liked'] ?? '').toString()),
                        ],
                      )
                          : (_log.isNotEmpty
                          ? SelectableText(
                        _log,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 13.5),
                      )
                          : const Text('—')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
