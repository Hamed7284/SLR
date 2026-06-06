import 'tournament_screen.dart';
import 'package:flutter/material.dart';
import 'players_screen.dart';
import 'courts_screen.dart';
import 'bookings_screen.dart'; // Ensure BookingsScreen is a valid import
import 'matches_screen.dart';
import 'finance_screen.dart';
import 'reports_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SLR Academy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('آکادمی تنیس SLR'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('خوش آمدید',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 4),
                Text('آکادمی تنیس SLR',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('بخش‌ها',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _MenuButton(
            icon: Icons.people,
            label: 'بازیکنان',
            color: Colors.green,
            screen: const PlayersScreen(),
          ),
          _MenuButton(
            icon: Icons.sports_tennis,
            label: 'زمین‌ها',
            color: Colors.blue,
            screen: const CourtsScreen(),
          ),
          _MenuButton(
            icon: Icons.calendar_today,
            label: 'رزروها',
            color: Colors.orange,
            screen:
                const BookingsScreen(), // Ensure BookingsScreen is defined correctly
          ),
          _MenuButton(
            icon: Icons.emoji_events,
            label: 'مسابقات',
            color: Colors.amber,
            screen: const MatchesScreen(),
          ),
          _MenuButton(
            icon: Icons.emoji_events,
            label: 'تورنومنت',
            color: Colors.purple,
            screen: const TournamentScreen(),
          ),
          _MenuButton(
            icon: Icons.attach_money,
            label: 'مالی',
            color: Colors.teal,
            screen: const FinanceScreen(),
          ),
          _MenuButton(
            icon: Icons.bar_chart,
            label: 'گزارش‌ها',
            color: Colors.red,
            screen: const ReportsScreen(),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Widget screen;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color
              .withOpacity(0.15), // Use .withValues() if exact precision needed
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        ),
      ),
    );
  }
}

