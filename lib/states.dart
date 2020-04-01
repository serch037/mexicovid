import 'package:flutter/material.dart';

class ListStatesState extends State<ListStates> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25.0),
      child: Text('Estados', style: TextStyle(fontSize: 36)),
    );
  }
}

class ListStates extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ListStatesState();
  }

}