import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> _stream() {
    // NOTE: arrayContainsAny + orderBy('createdAt') may require a composite index.
    return _db
        .collection('Notifications')
        .where('targets', arrayContainsAny: [uid, 'ALL'])
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _markAsRead(String id) async {
    await _db.collection('Notifications').doc(id).update({
      'readBy': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> _archive(String id) async {
    await _db.collection('Notifications').doc(id).update({
      'archivedBy': FieldValue.arrayUnion([uid]),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification archived')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _stream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const _EmptyState();
          }

          final docs = snap.data!.docs.where((d) {
            final data = d.data();
            final archivedBy = List<String>.from(data['archivedBy'] ?? const []);
            return !archivedBy.contains(uid);
          }).toList();

          if (docs.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final doc = docs[i];
                final data = doc.data();
                final title = data['title'] as String? ?? 'Notification';
                final message = data['message'] as String? ?? '';
                final ts = (data['createdAt'] as Timestamp?)?.toDate();
                final readBy = List<String>.from(data['readBy'] ?? const []);
                final isRead = readBy.contains(uid);

                return Dismissible(
                  key: ValueKey(doc.id),
                  direction: DismissDirection.endToStart,
                  background: _SwipeArchive(),
                  confirmDismiss: (_) async {
                    await _archive(doc.id);
                    return true;
                  },
                  child: InkWell(
                    onTap: () => _markAsRead(doc.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isRead ? const Color(0xFFE5E7EB) : const Color(0xFFB0C4FF),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isRead ? const Color(0xFFF0F3FF) : const Color(0xFFEEF4FF),
                              border: Border.all(
                                color: isRead ? const Color(0xFFE5E7EB) : const Color(0xFF94A3FF),
                              ),
                            ),
                            child: Icon(
                              isRead ? Icons.notifications_none : Icons.notifications_active,
                              size: 20,
                              color: isRead ? Colors.grey : const Color(0xFF3B5BDB),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    if (ts != null)
                                      Text(
                                        _friendlyTime(ts),
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  message,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: Colors.black87,
                                    fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (!isRead)
                                      TextButton.icon(
                                        onPressed: () => _markAsRead(doc.id),
                                        icon: const Icon(Icons.done_all, size: 18),
                                        label: const Text('Mark as read'),
                                      ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () => _archive(doc.id),
                                      icon: const Icon(Icons.archive_outlined, size: 18),
                                      label: const Text('Archive'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _friendlyTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    // fallback date
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
  }
}

class _SwipeArchive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.shade400,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.archive_rounded, color: Colors.white),
          SizedBox(width: 6),
          Text('Archive', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No notifications yet',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}
