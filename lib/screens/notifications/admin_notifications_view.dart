import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminNotificationsView extends StatefulWidget {
  const AdminNotificationsView({super.key});

  @override
  State<AdminNotificationsView> createState() => _AdminNotificationsViewState();
}

class _AdminNotificationsViewState extends State<AdminNotificationsView> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _searchCtrl = TextEditingController(); // name / email / phone

  bool _sendToAll = true;
  final Set<String> _targetUids = {};
  bool _submitting = false;

  Future<void> _send() async {
    final title = _titleCtrl.text.trim();
    final message = _messageCtrl.text.trim();

    if (title.isEmpty || message.isEmpty) {
      _snack('Please fill title and message');
      return;
    }
    if (!_sendToAll && _targetUids.isEmpty) {
      _snack('Pick at least one user or switch to ALL');
      return;
    }

    setState(() => _submitting = true);
    try {
      await _db.collection('Notifications').add({
        'title': title,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'targets': _sendToAll ? ['ALL'] : _targetUids.toList(),
        'readBy': <String>[],
        'archivedBy': <String>[],
        'authorUid': _auth.currentUser?.uid,
      });

      _titleCtrl.clear();
      _messageCtrl.clear();
      _searchCtrl.clear();
      _targetUids.clear();
      _sendToAll = true;
      _snack('Notification sent');
    } catch (e) {
      _snack('Failed: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Add by exact match on phoneNumber, email, name, or displayName.
  Future<void> _addByExactMatch() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;

    Future<bool> _try(String field) async {
      final res = await _db.collection('Users').where(field, isEqualTo: q).limit(20).get();
      if (res.docs.isNotEmpty) {
        for (final d in res.docs) {
          _targetUids.add(d.id);
        }
        return true;
      }
      return false;
    }

    try {
      if (await _try('phoneNumber')) {
        setState(() {});
        _searchCtrl.clear();
        return;
      }
      if (await _try('email')) {
        setState(() {});
        _searchCtrl.clear();
        return;
      }
      if (await _try('name')) {
        setState(() {});
        _searchCtrl.clear();
        return;
      }
      if (await _try('displayName')) {
        setState(() {});
        _searchCtrl.clear();
        return;
      }
      _snack('No exact user match for "$q"');
    } catch (e) {
      _snack('Lookup failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Load up to 500 users for dropdown & client-side filter
    final usersStream = _db.collection('Users').limit(500).snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageCtrl,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Switch(
                  value: _sendToAll,
                  onChanged: (v) => setState(() => _sendToAll = v),
                ),
                const Text('Send to ALL users'),
              ],
            ),

            if (!_sendToAll) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  labelText: 'Type a name, email, or phone',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: 'Add exact match',
                    icon: const Icon(Icons.person_add_alt_1),
                    onPressed: _addByExactMatch,
                  ),
                ),
                onSubmitted: (_) => _addByExactMatch(),
              ),
              const SizedBox(height: 10),

              // DROPDOWN with all users (first 500)
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: usersStream,
                builder: (ctx, snap) {
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Error: ${snap.error}',
                          style: const TextStyle(color: Colors.redAccent)),
                    );
                  }
                  if (!snap.hasData) {
                    return const SizedBox(
                      height: 56,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }

                  final docs = snap.data!.docs;

                  // Optional inline suggestions under the search box (client-side filter)
                  final q = _searchCtrl.text.trim().toLowerCase();
                  final suggestions = q.isEmpty
                      ? const <QueryDocumentSnapshot<Map<String, dynamic>>>[]
                      : docs.where((d) {
                    final data = d.data();
                    final name = (data['name'] ?? data['displayName'] ?? '').toString().toLowerCase();
                    final email = (data['email'] ?? '').toString().toLowerCase();
                    final phone = (data['phoneNumber'] ?? '').toString().toLowerCase();
                    final uid = d.id.toLowerCase();
                    return name.contains(q) || email.contains(q) || phone.contains(q) || uid.contains(q);
                  }).take(8).toList();

                  if (suggestions.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 1,
                          margin: EdgeInsets.zero,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: suggestions.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (ctx, i) {
                              final d = suggestions[i];
                              final data = d.data();
                              final uid = d.id;
                              final name = (data['name'] ?? data['displayName'] ?? '(no name)').toString();
                              final phone = (data['phoneNumber'] ?? '').toString();
                              final email = (data['email'] ?? '').toString();
                              final right = phone.isNotEmpty ? phone : email;
                              final picked = _targetUids.contains(uid);

                              return ListTile(
                                dense: true,
                                title: Text(name),
                                subtitle: Text(right.isEmpty ? uid : right),
                                trailing: Icon(
                                  picked ? Icons.check_circle : Icons.add_circle_outline,
                                  color: picked ? Colors.green : null,
                                ),
                                onTap: () {
                                  if (picked) {
                                    _targetUids.remove(uid);
                                  } else {
                                    _targetUids.add(uid);
                                  }
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        _DropdownAllUsers(docs: docs, onPick: (uid) {
                          _targetUids.add(uid);
                          setState(() {});
                        }),
                      ],
                    );
                  }

                  return _DropdownAllUsers(docs: docs, onPick: (uid) {
                    _targetUids.add(uid);
                    setState(() {});
                  });
                },
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _targetUids
                      .map((uid) => Chip(
                    label: Text(uid, overflow: TextOverflow.ellipsis),
                    onDeleted: () {
                      _targetUids.remove(uid);
                      setState(() {});
                    },
                  ))
                      .toList(),
                ),
              ),
            ],

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _send,
                icon: _submitting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                label: Text(_submitting ? 'Sending...' : 'Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownAllUsers extends StatelessWidget {
  const _DropdownAllUsers({
    required this.docs,
    required this.onPick,
  });

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final items = docs.map((d) {
      final data = d.data();
      final uid = d.id;
      final name = (data['name'] ?? data['displayName'] ?? '(no name)').toString();
      final phone = (data['phoneNumber'] ?? '').toString();
      final email = (data['email'] ?? '').toString();
      final right = phone.isNotEmpty ? phone : email;
      final label = right.isEmpty ? name : '$name  •  $right';
      return DropdownMenuItem<String>(
        value: uid,
        child: Text(label, overflow: TextOverflow.ellipsis),
      );
    }).toList();

    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Pick a user',
      ),
      items: items,
      onChanged: (uid) {
        if (uid != null) onPick(uid);
      },
    );
  }
}
