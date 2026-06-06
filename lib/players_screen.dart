import 'package:flutter/material.dart';
import 'db_helper.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});
  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  List<Map<String, dynamic>> _players = [];
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _level = 'مبتدی';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DbHelper.getPlayers();
    setState(() => _players = data);
  }

  Future<void> _addPlayer() async {
    if (_nameController.text.isEmpty) return;
    await DbHelper.insertPlayer({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'level': _level,
    });
    _nameController.clear();
    _phoneController.clear();
    Navigator.pop(context);
    _load();
  }

  Future<void> _delete(int id) async {
    await DbHelper.deletePlayer(id);
    _load();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('افزودن بازیکن'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'نام'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'تلفن'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _level,
                decoration: const InputDecoration(labelText: 'سطح'),
                items: ['مبتدی', 'متوسط', 'پیشرفته', 'حرفه‌ای']
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) => setStateDialog(() => _level = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: _addPlayer,
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'مبتدی':
        return Colors.green;
      case 'متوسط':
        return Colors.orange;
      case 'پیشرفته':
        return Colors.blue;
      case 'حرفه‌ای':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بازیکنان'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _players.isEmpty
          ? const Center(
              child: Text('هنوز بازیکنی ثبت نشده\nدکمه + را بزنید',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _players.length,
              itemBuilder: (_, i) {
                final p = _players[i];
                final level = p['level'] ?? 'مبتدی';
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _levelColor(level).withOpacity(0.15),
                      child: Text(
                        (p['name'] as String)[0],
                        style: TextStyle(
                            color: _levelColor(level),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(p['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${p['phone']} | $level'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(p['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
