import 'package:flutter/material.dart';
import 'db_helper.dart';

class CourtsScreen extends StatefulWidget {
  const CourtsScreen({super.key});
  @override
  State<CourtsScreen> createState() => _CourtsScreenState();
}

class _CourtsScreenState extends State<CourtsScreen> {
  List<Map<String, dynamic>> _courts = [];
  final _nameController = TextEditingController();
  final _rateController = TextEditingController();
  String _surface = 'سخت';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DbHelper.getCourts();
    setState(() => _courts = data);
  }

  Future<void> _addCourt() async {
    if (_nameController.text.isEmpty) return;
    await DbHelper.insertCourt({
      'name': _nameController.text,
      'rate': _rateController.text,
      'surface': _surface,
    });
    _nameController.clear();
    _rateController.clear();
    Navigator.pop(context);
    _load();
  }

  Future<void> _delete(int id) async {
    await DbHelper.deleteCourt(id);
    _load();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('افزودن زمین'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'نام زمین'),
              ),
              TextField(
                controller: _rateController,
                decoration:
                    const InputDecoration(labelText: 'نرخ ساعتی (تومان)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _surface,
                decoration: const InputDecoration(labelText: 'نوع سطح'),
                items: ['سخت', 'خاک رس', 'چمن', 'فرش']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setStateDialog(() => _surface = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: _addCourt,
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زمین‌ها'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _courts.isEmpty
          ? const Center(
              child: Text('هنوز زمینی ثبت نشده\nدکمه + را بزنید',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _courts.length,
              itemBuilder: (_, i) {
                final c = _courts[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE3F2FD),
                      child: Icon(Icons.sports_tennis, color: Colors.blue),
                    ),
                    title: Text(c['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${c['surface']} | ${c['rate']} تومان'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(c['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
