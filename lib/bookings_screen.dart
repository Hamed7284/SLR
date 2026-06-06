import 'package:flutter/material.dart';
import 'db_helper.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});
  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<Map<String, dynamic>> _bookings = [];
  final _playerController = TextEditingController();
  final _courtController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DbHelper.getBookings();
    setState(() => _bookings = data);
  }

  Future<void> _addBooking() async {
    if (_playerController.text.isEmpty || _courtController.text.isEmpty) return;
    await DbHelper.insertBooking({
      'player': _playerController.text,
      'court': _courtController.text,
      'date': _dateController.text,
      'time': _timeController.text,
    });
    _playerController.clear();
    _courtController.clear();
    _dateController.clear();
    _timeController.clear();
    Navigator.pop(context);
    _load();
  }

  Future<void> _delete(int id) async {
    await DbHelper.deleteBooking(id);
    _load();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('افزودن رزرو'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _playerController,
              decoration: const InputDecoration(labelText: 'نام بازیکن'),
            ),
            TextField(
              controller: _courtController,
              decoration: const InputDecoration(labelText: 'نام زمین'),
            ),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'تاریخ'),
            ),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'ساعت'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: _addBooking,
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
        title: const Text('رزروها'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _bookings.isEmpty
          ? const Center(
              child: Text('هنوز رزروی ثبت نشده\nدکمه + را بزنید',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _bookings.length,
              itemBuilder: (_, i) {
                final b = _bookings[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFF3E0),
                      child: Icon(Icons.calendar_today, color: Colors.orange),
                    ),
                    title: Text('${b['player']} — ${b['court']}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${b['date']} ساعت ${b['time']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(b['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
