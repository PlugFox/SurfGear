import 'package:flutter/material.dart';
import 'package:todos/ui/screens/todo_list_screen/todo_list_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'TODOs',
        theme: ThemeData(primaryColor: Colors.blue),
        darkTheme: ThemeData.dark(),
        home: TodoListScreen(),
      );
}
