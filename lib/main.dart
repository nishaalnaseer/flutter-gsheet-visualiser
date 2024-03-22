import 'package:flutter/material.dart';
import 'package:flutter_gsheet_visualiser/data_entry.dart';
import 'package:flutter_gsheet_visualiser/set_credentials.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fuel Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Fuel Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget body = const DataEntry();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  void newWindow(Widget widget) {
    body = widget;
    scaffoldKey.currentState?.closeDrawer();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
            weight: 2.0,
          ),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        )
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: ListTile(
                title: const Center(
                  child: Text(
                    'Load JSON Credentials',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                onTap: () {
                  newWindow(const SetCredentials());
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: ListTile(
                title: const Center(
                  child: Text(
                    'Data Entry',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                onTap: () {
                  newWindow(const DataEntry());
                },
              ),
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}
