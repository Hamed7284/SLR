import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DbHelper {
  static Future<List<Map<String, dynamic>>> _getList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  static Future<void> _saveList(
      String key, List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(list));
  }

  // ─── PLAYERS ───
  static Future<List<Map<String, dynamic>>> getPlayers() => _getList('players');

  static Future<void> insertPlayer(Map<String, String> p) async {
    final list = await getPlayers();
    list.add({...p, 'id': DateTime.now().millisecondsSinceEpoch});
    await _saveList('players', list);
  }

  static Future<void> deletePlayer(int id) async {
    final list = await getPlayers();
    list.removeWhere((p) => p['id'] == id);
    await _saveList('players', list);
  }

  // ─── COURTS ───
  static Future<List<Map<String, dynamic>>> getCourts() => _getList('courts');

  static Future<void> insertCourt(Map<String, String> c) async {
    final list = await getCourts();
    list.add({...c, 'id': DateTime.now().millisecondsSinceEpoch});
    await _saveList('courts', list);
  }

  static Future<void> deleteCourt(int id) async {
    final list = await getCourts();
    list.removeWhere((c) => c['id'] == id);
    await _saveList('courts', list);
  }

  // ─── BOOKINGS ───
  static Future<List<Map<String, dynamic>>> getBookings() =>
      _getList('bookings');

  static Future<void> insertBooking(Map<String, String> b) async {
    final list = await getBookings();
    list.add({...b, 'id': DateTime.now().millisecondsSinceEpoch});
    await _saveList('bookings', list);
  }

  static Future<void> deleteBooking(int id) async {
    final list = await getBookings();
    list.removeWhere((b) => b['id'] == id);
    await _saveList('bookings', list);
  }

  // ─── MATCHES ───
  static Future<List<Map<String, dynamic>>> getMatches() => _getList('matches');

  static Future<void> insertMatch(Map<String, String> m) async {
    final list = await getMatches();
    list.add({...m, 'id': DateTime.now().millisecondsSinceEpoch});
    await _saveList('matches', list);
  }

  static Future<void> deleteMatch(int id) async {
    final list = await getMatches();
    list.removeWhere((m) => m['id'] == id);
    await _saveList('matches', list);
  }

  // ─── PAYMENTS ───
  static Future<List<Map<String, dynamic>>> getPayments() =>
      _getList('payments');

  static Future<void> insertPayment(Map<String, String> p) async {
    final list = await getPayments();
    list.add({...p, 'id': DateTime.now().millisecondsSinceEpoch});
    await _saveList('payments', list);
  }

  static Future<void> deletePayment(int id) async {
    final list = await getPayments();
    list.removeWhere((p) => p['id'] == id);
    await _saveList('payments', list);
  }
}
