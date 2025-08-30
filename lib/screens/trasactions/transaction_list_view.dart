import 'dart:convert';
import 'dart:html' as html; // for web CSV download

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../constants.dart'; // ✅ your theme colors
import 'transaction_model.dart';

class TransactionListView extends StatefulWidget {
  const TransactionListView({super.key});

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView>
    with TickerProviderStateMixin {
  String searchQuery = '';
  DateTime? startDate;
  DateTime? endDate;

  late final TabController _tab = TabController(length: 2, vsync: this);

  // 🔄 Group transactions by userName
  Map<String, List<TransactionModel>> groupByUser(
      List<TransactionModel> transactions) {
    final grouped = <String, List<TransactionModel>>{};
    for (var tx in transactions) {
      grouped.putIfAbsent(tx.userName, () => []);
      grouped[tx.userName]!.add(tx);
    }
    return grouped;
  }

  // 🔄 Group revenue by day
  Map<DateTime, double> revenueByDay(List<TransactionModel> txs) {
    final map = <DateTime, double>{};
    for (final tx in txs) {
      final d =
      DateTime(tx.timestamp.year, tx.timestamp.month, tx.timestamp.day);
      map[d] = (map[d] ?? 0) + tx.totalAmount;
    }
    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: map[k]!};
  }

  // 🧾 Export selected user's transactions to CSV
  void exportUserToCSV(
      String userName, List<TransactionModel> userTransactions) {
    final csv = StringBuffer();
    csv.writeln('User,Amount,Payment Method,Date,Product Count');
    for (var tx in userTransactions) {
      final line =
          '${tx.userName},\$${tx.totalAmount.toStringAsFixed(2)},${tx.paymentMethod},${tx.timestamp.toIso8601String()},${tx.items.length}';
      csv.writeln(line);
    }
    _downloadCsv(csv.toString(), '$userName-transactions.csv');
  }

  // 🧾 Export CURRENTLY FILTERED transactions to CSV
  void exportFilteredToCSV(List<TransactionModel> filtered) {
    final csv = StringBuffer();
    csv.writeln('User,Amount,Payment Method,Date,Product Count,DocID');
    for (var tx in filtered) {
      csv.writeln(
          '${tx.userName},\$${tx.totalAmount.toStringAsFixed(2)},${tx.paymentMethod},${tx.timestamp.toIso8601String()},${tx.items.length},${tx.id}');
    }
    _downloadCsv(csv.toString(), 'transactions_filtered.csv');
  }

  // 🧾 Export ENTIRE collection (ignores filters) to CSV
  Future<void> exportAllToCSV() async {
    final snap = await FirebaseFirestore.instance
        .collection('Transactions')
        .orderBy('timestamp', descending: false)
        .get();

    final csv = StringBuffer();
    csv.writeln('User,Amount,Payment Method,Date,Product Count,DocID');
    for (final doc in snap.docs) {
      final tx = TransactionModel.fromMap(doc.id, doc.data());
      csv.writeln(
          '${tx.userName},\$${tx.totalAmount.toStringAsFixed(2)},${tx.paymentMethod},${tx.timestamp.toIso8601String()},${tx.items.length},${tx.id}');
    }
    _downloadCsv(csv.toString(), 'transactions_all.csv');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All transactions exported')),
      );
    }
  }

  void _downloadCsv(String content, String filename) {
    final blob = html.Blob([content], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  // 🔍 Filter logic
  bool matchesFilters(TransactionModel tx) {
    final matchesSearch =
    tx.userName.toLowerCase().contains(searchQuery.toLowerCase());
    final matchesDate =
        (startDate == null || !tx.timestamp.isBefore(startDate!)) &&
            (endDate == null ||
                tx.timestamp.isBefore(endDate!.add(const Duration(days: 1))));
    return matchesSearch && matchesDate;
  }

  // 🗑️ A) Delete a single transaction
  Future<void> deleteSingle(TransactionModel tx) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    ) ??
        false;

    if (!ok) return;

    await FirebaseFirestore.instance
        .collection('Transactions')
        .doc(tx.id)
        .delete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted')),
      );
    }
  }

  // 🧹 B) Delete all transactions for a user
  Future<void> deleteAllForUser(
      String userName, List<TransactionModel> userTransactions) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete all for $userName?'),
        content: const Text(
            'All transactions for this user will be permanently removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete All')),
        ],
      ),
    ) ??
        false;

    if (!ok) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final tx in userTransactions) {
      final ref =
      FirebaseFirestore.instance.collection('Transactions').doc(tx.id);
      batch.delete(ref);
    }
    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted all transactions for $userName')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor, // ✅ theme
      appBar: AppBar(
        title: const Text('All Transactions'),
        backgroundColor: secondaryColor, // ✅ theme
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'List'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Transactions')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTx = snapshot.data!.docs
              .map((doc) =>
              TransactionModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          final filtered = allTx.where(matchesFilters).toList();
          final groupedData = groupByUser(filtered);

          return TabBarView(
            controller: _tab,
            children: [
              // ----- TAB 1: LIST -----
              Column(
                children: [
                  // top controls
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (val) => setState(() => searchQuery = val),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search by user name...',
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: secondaryColor, // ✅ theme
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2024),
                              lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() {
                                startDate = picked.start;
                                endDate = picked.end;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor), // ✅ theme
                          child: const Text("Select Date Range"),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: filtered.isEmpty
                              ? null
                              : () => exportFilteredToCSV(filtered),
                          icon: const Icon(Icons.download),
                          label: const Text('Export Filtered CSV'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: exportAllToCSV,
                          icon: const Icon(Icons.save_alt),
                          label: const Text('Export ALL CSV'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                      child: Text("No transactions available.",
                          style: TextStyle(color: Colors.white)),
                    )
                        : ListView(
                      padding: const EdgeInsets.all(16),
                      children: groupedData.entries.map((entry) {
                        final userName = entry.key;
                        final userTransactions = entry.value;

                        return Card(
                          color: secondaryColor, // ✅ theme
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ExpansionTile(
                            collapsedIconColor: Colors.white70,
                            iconColor: Colors.white,
                            title: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => exportUserToCSV(
                                          userName, userTransactions),
                                      icon: const Icon(Icons.download,
                                          color: Colors.white),
                                      tooltip: 'Export CSV',
                                    ),
                                    IconButton(
                                      onPressed: () => deleteAllForUser(
                                          userName, userTransactions),
                                      icon: const Icon(Icons.delete_sweep,
                                          color: Colors.redAccent),
                                      tooltip: 'Delete all for user',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            children: userTransactions.map((tx) {
                              return ListTile(
                                title: Text(
                                  '\$${tx.totalAmount.toStringAsFixed(2)} - ${tx.paymentMethod}',
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .format(tx.timestamp),
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                    const SizedBox(height: 6),
                                    if (tx.items.isNotEmpty)
                                      ...tx.items.map((item) {
                                        return Text(
                                          "- ${item['productName'] ?? item['RFIDCode'] ?? 'Unnamed'}",
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 13),
                                        );
                                      }).toList(),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  tooltip: 'Delete transaction',
                                  onPressed: () => deleteSingle(tx),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              // ----- TAB 2: ANALYTICS (no pie) -----
              _AnalyticsTab(
                filtered: filtered,
                revenueByDay: revenueByDay(filtered),
                topUsers: groupByUser(filtered).map((u, list) =>
                    MapEntry(u,
                        list.fold<double>(0, (s, tx) => s + tx.totalAmount))),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ====== ANALYTICS TAB (Pie removed) ======
class _AnalyticsTab extends StatelessWidget {
  final List<TransactionModel> filtered;
  final Map<DateTime, double> revenueByDay;
  final Map<String, double> topUsers;

  const _AnalyticsTab({
    required this.filtered,
    required this.revenueByDay,
    required this.topUsers,
  });

  String _fmtMoney(num v) {
    if (v.abs() >= 1000000000) return '\$${(v / 1e9).toStringAsFixed(1)}B';
    if (v.abs() >= 1000000) return '\$${(v / 1e6).toStringAsFixed(1)}M';
    if (v.abs() >= 1000) return '\$${(v / 1e3).toStringAsFixed(1)}K';
    return '\$${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MM-dd');

    // line data (revenue over time)
    final dates = revenueByDay.keys.toList()..sort();
    final spots = <FlSpot>[
      for (int i = 0; i < dates.length; i++)
        FlSpot(i.toDouble(), revenueByDay[dates[i]]!)
    ];

    // bar data (top users)
    final users = topUsers.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top8 = users.take(8).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _card(
            context,
            title: 'Revenue Over Time',
            child: SizedBox(
              height: 260,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      dotData: const FlDotData(show: false),
                      color: primaryColor, // ✅ theme
                      spots: spots,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _card(
            context,
            title: 'Top Users by Spend',
            child: SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        getTitlesWidget: (v, _) => Text(
                          _fmtMoney(v),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i >= 0 && i < top8.length) {
                            final name = top8[i].key;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                name.length > 7
                                    ? '${name.substring(0, 7)}…'
                                    : name,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: [
                    for (int i = 0; i < top8.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: top8[i].value,
                            color: primaryColor, // ✅ theme
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context,
      {required String title, required Widget child}) {
    return Card(
      color: secondaryColor, // ✅ theme
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
