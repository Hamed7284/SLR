import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});
  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  List<Map<String, dynamic>> _transactions = [];
  String _periodFilter = 'همه';
  String _typeFilter = 'همه';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('finance_v2');
    if (data != null) {
      setState(() {
        _transactions = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('finance_v2', jsonEncode(_transactions));
  }

  // ── فیلتر زمانی ──
  List<Map<String, dynamic>> get _filtered {
    final now = DateTime.now();
    var list = _transactions.where((t) {
      final date = DateTime.tryParse(t['date'] ?? '') ?? DateTime(2000);
      if (_periodFilter == 'امروز') {
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      } else if (_periodFilter == 'این ماه') {
        return date.year == now.year && date.month == now.month;
      } else if (_periodFilter == 'امسال') {
        return date.year == now.year;
      }
      return true;
    }).toList();

    if (_typeFilter != 'همه') {
      list = list.where((t) => t['type'] == _typeFilter).toList();
    }
    return list;
  }

  int _sum(String type, List<Map<String, dynamic>> list) => list
      .where((t) => t['type'] == type)
      .fold(0, (s, t) => s + (int.tryParse(t['amount'].toString()) ?? 0));

  Color _typeColor(String type) {
    switch (type) {
      case 'درآمد':
        return const Color(0xFF2E7D32);
      case 'خرج':
        return const Color(0xFFC62828);
      case 'بدهی':
        return const Color(0xFFE65100);
      case 'بستانکاری':
        return const Color(0xFF1565C0);
      default:
        return Colors.grey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'درآمد':
        return Icons.trending_up;
      case 'خرج':
        return Icons.trending_down;
      case 'بدهی':
        return Icons.warning_amber_rounded;
      case 'بستانکاری':
        return Icons.account_balance_wallet;
      default:
        return Icons.attach_money;
    }
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final personCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String type = 'درآمد';
    String category = 'عمومی';

    final categories = {
      'درآمد': ['شهریه', 'رزرو زمین', 'فروش تجهیزات', 'عمومی'],
      'خرج': ['حقوق', 'نگهداری', 'تجهیزات', 'آب و برق', 'عمومی'],
      'بدهی': ['بازیکن', 'تامین‌کننده', 'عمومی'],
      'بستانکاری': ['بازیکن', 'شریک', 'عمومی'],
    };

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('تراکنش جدید'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // نوع
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: InputDecoration(
                    labelText: 'نوع تراکنش',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(_typeIcon(type), color: _typeColor(type)),
                  ),
                  items: ['درآمد', 'خرج', 'بدهی', 'بستانکاری']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setD(() {
                    type = v!;
                    category = categories[type]![0];
                  }),
                ),
                const SizedBox(height: 8),
                // دسته‌بندی
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'دسته‌بندی',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: (categories[type] ?? ['عمومی'])
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setD(() => category = v!),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'عنوان',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(
                    labelText: 'مبلغ (تومان)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.payments),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: personCtrl,
                  decoration: const InputDecoration(
                    labelText: 'نام شخص (اختیاری)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'توضیحات',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (titleCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;
                _transactions.add({
                  'type': type,
                  'category': category,
                  'title': titleCtrl.text,
                  'amount': amountCtrl.text,
                  'person': personCtrl.text,
                  'note': noteCtrl.text,
                  'date': DateTime.now().toIso8601String(),
                  'paid': false,
                });
                await _save();
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePaid(int index) async {
    setState(() {
      _transactions[index]['paid'] = !(_transactions[index]['paid'] ?? false);
    });
    await _save();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    setState(() => _transactions.remove(item));
    await _save();
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  // گروه‌بندی بر اساس تاریخ
  Map<String, List<Map<String, dynamic>>> _groupByDate(
      List<Map<String, dynamic>> list) {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final t in list.reversed) {
      final key = _formatDate(t['date'] ?? '');
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final income = _sum('درآمد', filtered);
    final expense = _sum('خرج', filtered);
    final debt = _sum('بدهی', filtered);
    final credit = _sum('بستانکاری', filtered);
    final balance = income - expense;
    final grouped = _groupByDate(filtered);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابداری'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // ── خلاصه مالی ──
          Container(
            color: const Color(0xFF1B5E20),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // فیلتر زمانی
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['همه', 'امروز', 'این ماه', 'امسال']
                        .map((p) => GestureDetector(
                              onTap: () => setState(() => _periodFilter = p),
                              child: Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _periodFilter == p
                                      ? Colors.white
                                      : Colors.white24,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(p,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _periodFilter == p
                                            ? const Color(0xFF1B5E20)
                                            : Colors.white)),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 10),
                // کارت‌های آمار
                Row(
                  children: [
                    Expanded(
                        child: _StatBox(
                            label: 'درآمد',
                            value: income,
                            color: Colors.greenAccent)),
                    const SizedBox(width: 6),
                    Expanded(
                        child: _StatBox(
                            label: 'خرج',
                            value: expense,
                            color: Colors.redAccent)),
                    const SizedBox(width: 6),
                    Expanded(
                        child: _StatBox(
                            label: 'بدهی',
                            value: debt,
                            color: Colors.orangeAccent)),
                    const SizedBox(width: 6),
                    Expanded(
                        child: _StatBox(
                            label: 'بستانکاری',
                            value: credit,
                            color: Colors.lightBlueAccent)),
                  ],
                ),
                const SizedBox(height: 8),
                // مانده
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text('مانده خالص',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 11)),
                      Text(
                        '${balance < 0 ? '-' : '+'}${balance.abs()} تومان',
                        style: TextStyle(
                          color: balance >= 0
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── فیلتر نوع ──
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: ['همه', 'درآمد', 'خرج', 'بدهی', 'بستانکاری']
                    .map((t) => GestureDetector(
                          onTap: () => setState(() => _typeFilter = t),
                          child: Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: _typeFilter == t
                                  ? (t == 'همه'
                                      ? const Color(0xFF1B5E20)
                                      : _typeColor(t))
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(t,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _typeFilter == t
                                        ? Colors.white
                                        : Colors.grey.shade700)),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),

          // ── لیست تراکنش‌ها ──
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('تراکنشی ثبت نشده',
                        style: TextStyle(color: Colors.grey, fontSize: 16)))
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: grouped.entries.map((entry) {
                      final dayIncome = _sum('درآمد', entry.value);
                      final dayExpense = _sum('خرج', entry.value);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // هدر روز
                          Container(
                            margin: const EdgeInsets.only(bottom: 8, top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                Text(
                                  'درآمد: $dayIncome | خرج: $dayExpense',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          // تراکنش‌های آن روز
                          ...entry.value.map((t) {
                            final isPaid = t['paid'] ?? false;
                            final isDebtOrCredit =
                                t['type'] == 'بدهی' || t['type'] == 'بستانکاری';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    // آیکون
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: _typeColor(t['type'])
                                          .withOpacity(0.12),
                                      child: Icon(_typeIcon(t['type']),
                                          color: _typeColor(t['type']),
                                          size: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    // اطلاعات
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  t['title'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    decoration:
                                                        isPaid && isDebtOrCredit
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : null,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _typeColor(t['type'])
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  t['category'] ?? t['type'],
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: _typeColor(
                                                          t['type'])),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${t['amount']} تومان'
                                            '${(t['person'] ?? '').isNotEmpty ? '  •  ${t['person']}' : ''}',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: _typeColor(t['type']),
                                                fontWeight: FontWeight.w600),
                                          ),
                                          if ((t['note'] ?? '').isNotEmpty)
                                            Text(t['note'],
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey)),
                                          if (isDebtOrCredit)
                                            GestureDetector(
                                              onTap: () => _togglePaid(
                                                  _transactions.indexOf(t)),
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    top: 4),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: isPaid
                                                      ? Colors.green
                                                          .withOpacity(0.1)
                                                      : Colors.orange
                                                          .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  isPaid
                                                      ? '✅ تسویه شده — کلیک برای لغو'
                                                      : '⏳ تسویه نشده — کلیک برای تسویه',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: isPaid
                                                          ? Colors.green
                                                          : Colors.orange),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    // حذف
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red, size: 20),
                                      onPressed: () => _delete(t),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 4),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 2),
          Text('$value',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          const Text('تومان',
              style: TextStyle(color: Colors.white54, fontSize: 9)),
        ],
      ),
    );
  }
}
