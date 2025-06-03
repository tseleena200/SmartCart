import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _updateAccountStatus(String userId, String status) {
    FirebaseFirestore.instance.collection('Users').doc(userId).update({
      'accountStatus': status,
    });
  }

  void _deleteUser(String userId) {
    FirebaseFirestore.instance.collection('Users').doc(userId).delete();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    final query = _searchQuery.toLowerCase();
    return (data['name'] ?? '').toLowerCase().contains(query) ||
        (data['email'] ?? '').toLowerCase().contains(query) ||
        (data['phoneNumber'] ?? '').toLowerCase().contains(query);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text("Registered Users"),
          backgroundColor: secondaryColor,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: "Search by name, email or phone...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: secondaryColor.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Users').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text("No users found.",
                              style: TextStyle(color: Colors.white70)));
                    }

                    final users = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return _matchesSearch(data);
                    }).toList();

                    if (users.isEmpty) {
                      return const Center(
                          child: Text("No matching users.",
                              style: TextStyle(color: Colors.white70)));
                    }

                    return ListView.separated(
                      separatorBuilder: (context, index) =>
                      const Divider(color: Colors.white24),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final userId = user.id;
                        final data = user.data() as Map<String, dynamic>;

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: secondaryColor.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Name: ${data['name'] ?? 'N/A'}",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text("Email: ${data['email'] ?? 'N/A'}",
                                            style: const TextStyle(color: Colors.white70)),
                                        Text("Phone: ${data['phoneNumber'] ?? 'N/A'}",
                                            style: const TextStyle(color: Colors.white70)),
                                        Text("DOB: ${data['dob'] ?? 'N/A'}",
                                            style: const TextStyle(color: Colors.white70)),
                                        Text("Preferred Branch: ${data['preferredBranch'] ?? 'N/A'}",
                                            style: const TextStyle(color: Colors.white70)),
                                        Text("Receive Promos: ${data['receivePromos'] == true ? 'Yes' : 'No'}",
                                            style: const TextStyle(color: Colors.white70)),
                                        Text("Account Status: ${data.containsKey('accountStatus') ? data['accountStatus'] : 'Not set'}",
                                            style: const TextStyle(color: Colors.white70)),
                                        Text("User Role: ${data['userRole'] ?? 'N/A'}",
                                            style: const TextStyle(color: Colors.white70)),
                                        const SizedBox(height: 6),
                                        Text(
                                          "Last Active: ${data.containsKey('lastActiveAt') ? (data['lastActiveAt'] as Timestamp).toDate().toLocal().toString() : 'N/A'}",
                                          style: const TextStyle(
                                              color: Colors.white38, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'suspend') {
                                        _updateAccountStatus(userId, 'Suspended');
                                      } else if (value == 'activate') {
                                        _updateAccountStatus(userId, 'Active');
                                      } else if (value == 'delete') {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Confirm Deletion"),
                                            content: const Text("Are you sure you want to delete this user? This action cannot be undone."),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _deleteUser(userId);
                                                },
                                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                          value: 'suspend', child: Text('Suspend')),
                                      const PopupMenuItem(
                                          value: 'activate', child: Text('Activate')),
                                      const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete',
                                              style: TextStyle(color: Colors.red))),
                                    ],
                                    icon: const Icon(Icons.more_vert, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
