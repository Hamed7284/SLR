import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});
  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  final List<Map<String, dynamic>> _tournaments = [];

  void _createTournament() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateTournamentScreen()),
    ).then((tournament) {
      if (tournament != null) {
        setState(() => _tournaments.add(tournament));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تورنومنت‌ها'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTournament,
        backgroundColor: const Color(0xFF1B5E20),
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('تورنومنت جدید', style: TextStyle(color: Colors.white)),
      ),
      body: _tournaments.isEmpty
          ? const Center(
              child: Text('هنوز تورنومنتی ساخته نشده\nدکمه + را بزنید',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _tournaments.length,
              itemBuilder: (_, i) {
                final t = _tournaments[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFF9C4),
                      child: Icon(Icons.emoji_events, color: Colors.amber),
                    ),
                    title: Text(t['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${t['players'].length} بازیکن | سطح: ${t['level']}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              TournamentDetailScreen(tournament: t)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ─────────────────────────────────────────────
// صفحه ساخت تورنومنت
// ─────────────────────────────────────────────
class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});
  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _nameController = TextEditingController();
  final _playerNameController = TextEditingController();
  String _level = 'متوسط';
  final List<String> _players = [];

  String _shamsiToday() {
    final now = Jalali.now();
    return '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
  }

  void _addPlayer() {
    if (_playerNameController.text.isEmpty) return;
    setState(() => _players.add(_playerNameController.text));
    _playerNameController.clear();
  }

  void _removePlayer(int i) => setState(() => _players.removeAt(i));

  void _startTournament() {
    if (_nameController.text.isEmpty || _players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('حداقل ۲ بازیکن و نام تورنومنت لازم است')));
      return;
    }
    final shuffled = List<String>.from(_players)..shuffle();
    final matches = _buildBracket(shuffled);
    Navigator.pop(context, {
      'name': _nameController.text,
      'level': _level,
      'date': _shamsiToday(),
      'players': _players,
      'matches': matches,
      'results': <int, String>{},
    });
  }

  List<List<String>> _buildBracket(List<String> players) {
    final matches = <List<String>>[];
    for (int i = 0; i + 1 < players.length; i += 2) {
      matches.add([players[i], players[i + 1]]);
    }
    if (players.length % 2 != 0) {
      matches.add([players.last, 'بای (استراحت)']);
    }
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تورنومنت جدید'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // نام تورنومنت
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'نام تورنومنت',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.emoji_events),
            ),
          ),
          const SizedBox(height: 12),
          // سطح
          DropdownButtonFormField<String>(
            value: _level,
            decoration: const InputDecoration(
              labelText: 'سطح بازیکنان',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.bar_chart),
            ),
            items: ['مبتدی', 'متوسط', 'پیشرفته', 'حرفه‌ای']
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged: (v) => setState(() => _level = v!),
          ),
          const SizedBox(height: 16),
          // اضافه کردن بازیکن
          const Text('بازیکنان',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('می‌توانید بازیکنان جدید (غیر عضو باشگاه) هم اضافه کنید',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _playerNameController,
                  decoration: const InputDecoration(
                    labelText: 'نام بازیکن',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_add),
                  ),
                  onSubmitted: (_) => _addPlayer(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addPlayer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                child: const Text('افزودن'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // لیست بازیکنان
          if (_players.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text('هنوز بازیکنی اضافه نشده',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...List.generate(
              _players.length,
              (i) => Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1B5E20).withOpacity(0.1),
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            color: Color(0xFF1B5E20),
                            fontWeight: FontWeight.bold)),
                  ),
                  title: Text(_players[i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removePlayer(i),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          // دکمه قرعه‌کشی
          ElevatedButton.icon(
            onPressed: _players.length >= 2 ? _startTournament : null,
            icon: const Icon(Icons.shuffle),
            label: Text('قرعه‌کشی و شروع تورنومنت (${_players.length} بازیکن)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// صفحه جزئیات تورنومنت + ثبت نتایج
// ─────────────────────────────────────────────
class TournamentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> tournament;
  const TournamentDetailScreen({super.key, required this.tournament});
  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  late Map<String, dynamic> _t;

  @override
  void initState() {
    super.initState();
    _t = Map<String, dynamic>.from(widget.tournament);
    _t['results'] = Map<int, String>.from(_t['results'] ?? {});
  }

  void _setWinner(int matchIndex, String winner) {
    setState(() => _t['results'][matchIndex] = winner);
  }

  String? _getWinner(int i) => _t['results'][i];

  bool get _allDone {
    final matches = _t['matches'] as List;
    return matches.asMap().entries.every(
        (e) => e.value[1] == 'بای (استراحت)' || _t['results'][e.key] != null);
  }

  @override
  Widget build(BuildContext context) {
    final matches = _t['matches'] as List<List<String>>;

    return Scaffold(
      appBar: AppBar(
        title: Text(_t['name']),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // اطلاعات تورنومنت
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoChip(label: 'سطح', value: _t['level']),
                _InfoChip(
                    label: 'بازیکنان',
                    value: '${(_t['players'] as List).length} نفر'),
                _InfoChip(label: 'تاریخ', value: _t['date']),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('جدول مسابقات',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          // مسابقات
          ...matches.asMap().entries.map((entry) {
            final i = entry.key;
            final match = entry.value;
            final p1 = match[0];
            final p2 = match[1];
            final winner = _getWinner(i);
            final isBye = p2 == 'بای (استراحت)';

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: winner != null
                      ? const Color(0xFF1B5E20)
                      : Colors.grey.shade300,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text('مسابقه ${i + 1}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    if (isBye)
                      Text('$p1 — استراحت دارد',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20)))
                    else
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _setWinner(i, p1),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: winner == p1
                                      ? const Color(0xFF1B5E20)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(p1,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: winner == p1
                                                ? Colors.white
                                                : Colors.black)),
                                    if (winner == p1)
                                      const Text('🏆 برنده',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('VS',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _setWinner(i, p2),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: winner == p2
                                      ? const Color(0xFF1B5E20)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(p2,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: winner == p2
                                                ? Colors.white
                                                : Colors.black)),
                                    if (winner == p2)
                                      const Text('🏆 برنده',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          // نتایج نهایی
          if (_allDone) ...[
            const Divider(),
            const Text('🏆 نتایج نهایی',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1B5E20))),
            const SizedBox(height: 8),
            ...(_t['results'] as Map<int, String>).entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF1B5E20), size: 18),
                      const SizedBox(width: 6),
                      Text('مسابقه ${e.key + 1}: ',
                          style: const TextStyle(color: Colors.grey)),
                      Text(e.value,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text(' برنده شد'),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label, value;
  const _InfoChip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      );
}
