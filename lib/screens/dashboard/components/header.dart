import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text("Admin-Dashboard", style: Theme.of(context).textTheme.titleLarge),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        const Expanded(child: SearchField()),
        const ProfileCard(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class ProfileCard extends StatelessWidget {
  const ProfileCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return _shell(context, "Not signed in");

    // Read admin profile where docID == uid
    final stream = FirebaseFirestore.instance
        .collection('adminUsers')
        .doc(user.uid)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        String label = "Admin";
        if (snap.connectionState == ConnectionState.waiting) {
          label = "Loading…";
        } else if (snap.hasError) {
          label = "Error";
        } else if (snap.hasData && snap.data!.exists) {
          final data = snap.data!.data()!;
          final name = (data['fullName'] ?? 'Admin').toString();
          final role = (data['role'] ?? '').toString().trim();
          label = role.isEmpty ? name : "$name — $role";
        } else {
          label = "Admin Profile Missing";
        }
        return _shell(context, label);
      },
    );
  }

  Widget _shell(BuildContext context, String label) {
    return Container(
      margin: const EdgeInsets.only(left: defaultPadding),
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Image.asset("assets/images/profile_pic.png", height: 38),
          if (!Responsive.isMobile(context))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Text(label, style: const TextStyle(color: Colors.white)),
            ),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Focus-safe search field (prevents Flutter Web pointer assertion)

class SearchField extends StatefulWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  void _submit() {
    if (!_focusNode.hasFocus) _focusNode.requestFocus();
    // TODO: run search with _controller.text
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: secondaryColor,
        filled: true,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: IconButton(
          onPressed: _submit,
          icon: SvgPicture.asset("assets/icons/Search.svg"),
        ),
      ),
    );
  }
}
