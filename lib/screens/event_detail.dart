import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml/screens/full_screen_ticket.dart';
import 'package:google_ml/services/data.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventDetails extends StatefulWidget {
  final Event event;
  final Directory appDir;
  final bool newEvent;

  EventDetails(
      {required this.event, required this.appDir, this.newEvent = false});

  @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _dateController;
  DateTime _selectedDate = DateTime.now();
  final formatter = DateFormat('dd.MM.yyyy');
  late String _title;
  late String _date;
  late String _place;

  @override
  void initState() {
    super.initState();
    _title = widget.event.title;
    _date = widget.event.date;
    _place = widget.event.place;
    //appDir = await getApplicationDocumentsDirectory();

    // _dateController = TextEditingController(text: widget.event.date);
  }

  Future<void> _editEvent() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getStringList('events') ?? [];
    final events =
        eventsJson.map((json) => Event.fromJson(jsonDecode(json))).toList();
    print(eventsJson);

    // Find the index of the event to update in the list
    final index = events.indexWhere((event) => event.id == widget.event.id);
    print(index);

    if (index != -1) {
      // If the event is found in the list
      // Update the event at that index with the new values
      events[index] = Event(
        id: widget.event.id,
        title: _title,
        date: _date,
        place: _place,
      );

      // Save the updated list of events back to shared preferences
      final updatedEventsJson =
          events.map((event) => jsonEncode(event.toJson())).toList();
      print(updatedEventsJson.first);
      await prefs.setStringList('events', updatedEventsJson);
    }
  }

  Future<void> _addEvent() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getStringList('events') ?? [];
    final Event newEvent = Event(
      id: widget.event.id,
      title: _title,
      date: _date,
      place: _place,
    );

    eventsJson.add(jsonEncode(newEvent.toJson()));

    await prefs.setStringList('events', eventsJson);
  }

  Future<void> _selectDate() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(DateTime.now().toString()),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selected != null && selected != widget.event.date) {
      setState(() {
        _selectedDate = selected;
        print(_selectedDate);

        _date = formatter.format(_selectedDate);
        print(_date);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when user taps outside of the TextFormField
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Event Details'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(
                            imagePath:
                                '${widget.appDir.path}/${widget.event.id}.jpg',
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'imageHero',
                      child: Image.file(
                        File('${widget.appDir.path}/${widget.event.id}.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () {
                      // Handle next button action here
                      FocusScope.of(context).nextFocus();
                    },
                    maxLines: 3,
                    initialValue: _title,
                    decoration: InputDecoration(labelText: 'Titel'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    onChanged: (value) => _title = value!,
                  ),
                  Stack(
                    children: [
                      TextFormField(
                        onTap: () => print(_date),
                        maxLines: 3,
                        textInputAction: TextInputAction.next,
                        initialValue: _date,
                        decoration: InputDecoration(labelText: 'Datum'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                        onChanged: (value) => _date = value!,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.calendar_month_outlined),
                          onPressed: () {
                            _selectDate();
                          },
                        ),
                      ),
                    ],
                  ),

                  /* GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Date',
                        ),
                      ),
                    ),
                  ),*/
                  TextFormField(
                    maxLines: 3,
                    initialValue: _place,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(labelText: 'Ort'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a place';
                      }
                      return null;
                    },
                    onChanged: (value) => _place = value!,
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.newEvent ? _addEvent() : _editEvent();
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Speichern'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
