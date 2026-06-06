import 'package:flutter/material.dart';
import 'db_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _players = 0;
  int _courts = 0;
  int _bookings = 0;
  int _matches = 0;
  int _totalIncome = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final players = await DbHelper.getPlayers();
    final courts = await DbHelper.getCourts();
    final bookings = await DbHelper.getBookings();
    final matches = await DbHelper.getMatches();
    final payments = await DbHelper.getPayments();
    final income = payments.fold<int>(
        0, (sum, p) => sum + (int.tryParse(p['amount'] ?? '0') ?? 0));
    setState(() {
      _players = players.length;
      _courts = courts.length;
      _bookings = bookings.length;
      _matches = matches.length;
      _totalIncome = income;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('گزارش‌ها'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('خلاصه آمار',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _StatCard(
                      label: 'بازیکنان',
                      value: '$_players',
                      color: Colors.green,
                      icon: Icons.people)),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatCard(
                      label: 'زمین‌ها',
                      value: '$_courts',
                      color: Colors.blue,
                      icon: Icons.sports_tennis)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _StatCard(
                      label: 'رزروها',
                      value: '$_bookings',
                      color: Colors.orange,
                      icon: Icons.calendar_today)),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatCard(
                      label: 'مسابقات',
                      value: '$_matches',
                      color: Colors.amber,
                      icon: Icons.emoji_events)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('جمع کل درآمد',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
                Text('$_totalIncome تومان',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
