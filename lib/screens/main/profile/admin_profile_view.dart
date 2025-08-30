import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart'; // uses your bgColor, secondaryColor, primaryColor

class AdminProfileView extends StatelessWidget {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    final docStream = FirebaseFirestore.instance
        .collection('adminUsers') // your collection
        .doc(user.uid)            // docID = uid
        .snapshots();

    return Scaffold(
      backgroundColor: bgColor,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorState(onRetry: () {});
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const _EmptyState();
          }

          final data = snap.data!.data()!;
          final name = (data['fullName'] ?? 'Admin') as String;
          final role = (data['role'] ?? 'admin') as String;
          final email = (data['email'] ?? '-') as String;
          final phone = (data['phone'] ?? '-') as String;
          final nic = (data['nic'] ?? '-') as String;
          final isActive = (data['isActive'] ?? true) as bool;
          final createdAtTs = data['createdAt'];
          final createdAt = createdAtTs is Timestamp ? createdAtTs.toDate() : null;

          return _ProfileScaffold(
            name: name,
            role: role,
            email: email,
            phone: phone,
            nic: nic,
            isActive: isActive,
            createdAt: createdAt,
            onEdit: () {
              final uid = FirebaseAuth.instance.currentUser!.uid;
              _showEditProfileDialog(
                context,
                uid: uid,
                fullName: name,
                phone: phone,
                nic: nic,
              );
            },
            onChangePassword: () async {
              if (email.isNotEmpty && email.contains('@')) {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                _toast(context, 'Password reset email sent');
              } else {
                _toast(context, 'No email associated with this account');
              }
            },
            onLogout: () async {
              await FirebaseAuth.instance.signOut();
              // TODO: Navigate to login screen
            },
          );
        },
      ),
    );
  }
}

// ================== UI ===================

class _ProfileScaffold extends StatelessWidget {
  final String name, role, email, phone, nic;
  final bool isActive;
  final DateTime? createdAt;
  final VoidCallback onEdit, onChangePassword, onLogout;

  const _ProfileScaffold({
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.nic,
    required this.isActive,
    required this.createdAt,
    required this.onEdit,
    required this.onChangePassword,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > 920;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 220,
          backgroundColor: secondaryColor,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    secondaryColor.withOpacity(0.95),
                    secondaryColor.withOpacity(0.6),
                    primaryColor.withOpacity(0.35),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -40,
                    left: -30,
                    child: _GlowCircle(color: primaryColor.withOpacity(0.25)),
                  ),
                  Positioned(
                    bottom: -60,
                    right: -40,
                    child: _GlowCircle(color: Colors.white24),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _Avatar(statusOn: isActive),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _Chip(role),
                                    const SizedBox(width: 8),
                                    _Chip(
                                      isActive ? 'Active' : 'Suspended',
                                      bg: isActive
                                          ? Colors.greenAccent.withOpacity(.18)
                                          : Colors.redAccent.withOpacity(.18),
                                      fg: isActive
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Wrap(
                            spacing: 10,
                            children: [
                              _ActionBtn(
                                icon: Icons.edit_rounded,
                                label: 'Edit',
                                onTap: onEdit,
                              ),
                              _ActionBtn(
                                icon: Icons.lock_reset_rounded,
                                label: 'Change Password',
                                onTap: onChangePassword,
                              ),
                              _ActionBtn(
                                icon: Icons.logout_rounded,
                                label: 'Logout',
                                onTap: onLogout,
                                danger: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverToBoxAdapter(
            child: isWide
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _InfoCard(email: email, phone: phone, nic: nic)),
                const SizedBox(width: 24),
                SizedBox(
                  width: 360,
                  child: _MetaCard(createdAt: createdAt, role: role, isActive: isActive),
                ),
              ],
            )
                : Column(
              children: [
                _InfoCard(email: email, phone: phone, nic: nic),
                const SizedBox(height: 24),
                _MetaCard(createdAt: createdAt, role: role, isActive: isActive),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String email, phone, nic;
  const _InfoCard({required this.email, required this.phone, required this.nic});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(title: 'Contact'),
          const SizedBox(height: 12),
          _FieldRow(icon: Icons.alternate_email_rounded, label: 'Email', value: email),
          const SizedBox(height: 10),
          _FieldRow(icon: Icons.phone_rounded, label: 'Phone', value: phone),
          const SizedBox(height: 10),
          _FieldRow(icon: Icons.badge_rounded, label: 'NIC', value: nic),
        ],
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  final DateTime? createdAt;
  final String role;
  final bool isActive;
  const _MetaCard({this.createdAt, required this.role, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final created = createdAt != null
        ? '${createdAt!.year}-${createdAt!.month.toString().padLeft(2, '0')}-${createdAt!.day.toString().padLeft(2, '0')}'
        : '-';

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(title: 'Account'),
          const SizedBox(height: 12),
          _KV(label: 'Created', value: created),
          const SizedBox(height: 10),
          _KV(label: 'Role', value: role),
          const SizedBox(height: 10),
          _KV(
            label: 'Status',
            value: isActive ? 'Active' : 'Suspended',
            valueColor: isActive ? Colors.greenAccent : Colors.redAccent,
          ),
        ],
      ),
    );
  }
}

// ======= atoms =======

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 24, offset: Offset(0, 14)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String title;
  const _CardTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
    );
  }
}

class _KV extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _KV({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(color: valueColor ?? Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _FieldRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _ActionBtn({required this.icon, required this.label, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: (danger ? Colors.redAccent : primaryColor).withOpacity(.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: (danger ? Colors.redAccent : primaryColor).withOpacity(.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: danger ? Colors.redAccent : Colors.white),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final bool statusOn;
  const _Avatar({required this.statusOn});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [primaryColor.withOpacity(.25), Colors.white12],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white24, width: 1),
            image: const DecorationImage(
              image: AssetImage('assets/images/profile_pic.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: statusOn ? Colors.greenAccent : Colors.redAccent,
              shape: BoxShape.circle,
              border: Border.all(color: secondaryColor, width: 2),
            ),
          ),
        )
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Chip(this.text, {this.bg = const Color(0x33FFFFFF), this.fg = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(.4)),
      ),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  const _GlowCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 10)],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.redAccent),
        const SizedBox(height: 8),
        const Text('Failed to load profile', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Admin profile not found', style: TextStyle(color: Colors.white70)),
    );
  }
}

// ======= helpers =======

void _toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

Future<void> _showEditProfileDialog(
    BuildContext context, {
      required String uid,
      required String fullName,
      required String phone,
      required String nic,
    }) async {
  final nameC = TextEditingController(text: fullName);
  final phoneC = TextEditingController(text: phone);
  final nicC = TextEditingController(text: nic);
  final formKey = GlobalKey<FormState>();

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: secondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
      content: Form(
        key: formKey,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameC,
                validator: _req,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneC,
                validator: _req,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nicC,
                validator: _req,
                decoration: const InputDecoration(labelText: 'NIC'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (!(formKey.currentState?.validate() ?? false)) return;
            await FirebaseFirestore.instance
                .collection('adminUsers')
                .doc(uid)
                .update({
              'fullName': nameC.text.trim(),
              'phone': phoneC.text.trim(),
              'nic': nicC.text.trim(),
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated')),
            );
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );

  nameC.dispose();
  phoneC.dispose();
  nicC.dispose();
}
