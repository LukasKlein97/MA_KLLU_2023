import 'package:flutter/material.dart';
import 'package:google_ml/screens/event_detail.dart';
import 'package:google_ml/screens/ml_screen.dart';
import 'package:google_ml/services/data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class EventListWidget extends StatefulWidget {
  const EventListWidget({Key? key}) : super(key: key);

  @override
  _EventListWidgetState createState() => _EventListWidgetState();
}

class _EventListWidgetState extends State<EventListWidget> {
  List<Event> _events = [];
  final formatter = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getStringList('events');
    if (eventsJson != null) {
      setState(() {
        _events = eventsJson.map((e) => Event.fromJson(jsonDecode(e))).toList();
      });
    }
  }

  Future<void> _clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _deleteEvent(Event event) async {
    setState(() {
      _events.remove(event);
    });

    final prefs = await SharedPreferences.getInstance();
    final eventsJson = _events.map((event) => jsonEncode(event)).toList();
    await prefs.setStringList('events', eventsJson);
  }

  Future<void> _navigateToEditEventScreen(event) async {
    final appDir = await getApplicationDocumentsDirectory();
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EventDetails(event: event, appDir: appDir)),
    );
    // After returning from the AddEventScreen, reload the events
    await _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Events'),
        ),
        body: Column(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return Dismissible(
                  key: Key(event.id.toString()),
                  onDismissed: (direction) => _deleteEvent(event),
                  child: ListTile(
                    onTap: () => _navigateToEditEventScreen(event),
                    title: Text(event.title),
                    trailing: Text(
                        '${formatter.format(DateTime.parse(event.date))} '),
                    subtitle: Text('${event.place}'),
                  ),
                  background: Container(
                    color: Colors.red,
                    child: Icon(Icons.delete, color: Colors.white),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 16),
                  ),
                );
              },
            ),
          ),
          /* ElevatedButton(
            onPressed: _clearSharedPreferences,
            child: Text('Clear Shared Preferences'),
          ),*/
        ]),
        floatingActionButton: MLScreen(callBack: () async {
          await _loadEvents();
        }));
  }
}
