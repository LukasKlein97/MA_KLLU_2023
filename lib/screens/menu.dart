import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'dart:math';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:google_ml/ml.dart';

import 'package:provider/provider.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  late TabController _controller;
  int index = 0;
  TextEditingController _textController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  DateTime? _selecedDate;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _controller = TabController(length: 2, vsync: this);
    _controller.index = index;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: index,
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: TabBar(
              controller: _controller,
              tabs: const [
                Tab(
                  icon: Icon(
                    Icons.edit_note,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.legend_toggle,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: <Widget>[
                TabBarView(
                  controller: _controller,
                  children: <Widget>[
                    Column(
                      children: [
                        Text('Hello'),
                        Card(
                          child: ListTile(
                            title: Text('Hello'),
                            subtitle: Text('Hello'),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                            onPressed: () {}, child: Text('Sign Out')),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Navigator push to MyWidget()
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyWidget()),
              );
            },
            child: const Icon(Icons.add),
            backgroundColor: Colors.blue,
          )),
    );
  }
}
