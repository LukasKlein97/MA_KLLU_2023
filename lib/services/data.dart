import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class EventStorage {
  static const String _key = 'event_key';

  Future<void> saveEvent(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    final eventJson = jsonEncode(event.toJson());
    await prefs.setString(_key, eventJson);
  }

  Future<Event?> loadEvent() async {
    final prefs = await SharedPreferences.getInstance();
    final eventJson = prefs.getString(_key);
    if (eventJson == null) {
      return null;
    } else {
      final eventMap = jsonDecode(eventJson);
      return Event.fromJson(eventMap);
    }
  }
}

class Event {
  final String id;
  final String title;
  final String date;
  final String place;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.place,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      date: json['date'],
      place: json['place'],
    );
  }

  factory Event.create(String title, String date, String place) {
    final uuid = Uuid();
    final id = uuid.v4();
    return Event(
      id: id,
      title: title,
      date: date,
      place: place,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'place': place,
    };
  }
}
