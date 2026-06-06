import 'package:flutter/material.dart';
import 'db_helper.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});
  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<Map<String, dynamic>> _matches = [];
  final _player1Controller = TextEditingController();
  final _player2Controller = TextEditingController();
  final _scoreController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DbHelper.getMatches();
    setState(() => _matches = data);
  }

  Future<void> _addMatch() async {
    if (_player1Controller.text.isEmpty || _player2Controller.text.isEmpty)
      return;
    await DbHelper.insertMatch({
      'player1': _player1Controller.text,
      'player2': _player2Controller.text,
      'score': _scoreController.text,
      'date': _dateController.text,
    });
    _player1Controller.clear();
    _player2Controller.clear();
    _scoreController.clear();
    _dateController.clear();
    Navigator.pop(context);
    _load();
  }

  Future<void> _delete(int id) async {
    await DbHelper.deleteMatch(id);
    _load();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ثبت مسابقه'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _player1Controller,
              decoration: const InputDecoration(labelText: 'بازیکن اول'),
            ),
            TextField(
              controller: _player2Controller,
              decoration: const InputDecoration(labelText: 'بازیکن دوم'),
            ),
            TextField(
              controller: _scoreController,
              decoration: const InputDecoration(labelText: 'نتیجه (مثال: 6-4)'),
            ),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'تاریخ'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: _addMatch,
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مسابقات'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _matches.isEmpty
          ? const Center(
              child: Text('هنوز مسابقه‌ای ثبت نشده\nدکمه + را بزنید',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _matches.length,
              itemBuilder: (_, i) {
                final m = _matches[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFFDE7),
                      child: Icon(Icons.emoji_events, color: Colors.amber),
                    ),
                    title: Text('${m['player1']} vs ${m['player2']}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('نتیجه: ${m['score']} | ${m['date']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(m['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
