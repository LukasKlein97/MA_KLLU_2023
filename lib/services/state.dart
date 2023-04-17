import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class State with ChangeNotifier {
  List<Object> _objects = [];
  //FirestoreService _firestoreService;

  State(this._objects);

  List<Object> get incomes => _objects;
}
