import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EchoFi Stopwatch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'EchoFi Stopwatch'),
    );
  }
}

// Stream for gatherting an event every second
Stream<int> secondStream() {
  Duration timerInterval = Duration(seconds: 1);
  StreamController<int>? streamController;
  Timer? timer;
  int seconds = 0;

  void stopTimer() {
    timer!.cancel();
    timer = null;
    streamController!.close();
    seconds = 0;
  }

  void onSecond(_) {
    seconds++;
    streamController!.add(seconds);
  }

  void startTimer() {
    timer = Timer.periodic(timerInterval, onSecond);
  }

  streamController = StreamController<int>(
    onListen: startTimer,
    onCancel: stopTimer,
  );

  return streamController.stream;
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// Utility method that converts seconds into a formatted,
// MM:SS string
String convertSecondsToMMSS(int totalSeconds) {
  var duration = Duration(seconds: totalSeconds);
  var min = duration.inMinutes;
  var sec = totalSeconds % 60;

  var minString = '$min'.padLeft(2, '0');
  var secString = '$sec'.padLeft(2, '0');
  return '$minString:$secString';
}

class _MyHomePageState extends State<MyHomePage> {
  String _timeString = "00:00";
  Stream<int>? timerStream;
  late StreamSubscription<int> timerSubscription;
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
            padding: EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Elapsed Time:',
                ),
                Text(
                  '$_timeString',
                  style: Theme.of(context).textTheme.headline4,
                ),
                new ButtonBar(
                  mainAxisSize: MainAxisSize.min, // this will take space as minimum as posible(to center)
                  children: <Widget>[
                    new ElevatedButton(
                      child: new Text('Start'),
                      onPressed: () {
                        timerStream = secondStream();
                        timerSubscription = timerStream!.listen((int newTick) {
                          setState(() {
                            _timeString = convertSecondsToMMSS(newTick);
                            isActive = true;
                          });
                        });
                      },
                    ),
                    new ElevatedButton(
                      child: new Text('Stop'),
                      onPressed: () {
                        timerStream = null;
                        timerSubscription.cancel();
                        setState(() {
                          _timeString = "00:00";
                          isActive = false;
                        });
                      },
                    ),
                  ],
                ),
                Visibility(
                  visible: isActive,
                  child: new ElevatedButton(child: new Text('Lap'), onPressed: () {
                    timerStream = null;
                  }),
                ),
                Visibility(
                    visible: isActive,
                    child: new ListView(
                      shrinkWrap: true,
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: [
                          ListTile(
                            title: Text('a'),
                          ),
                          ListTile(
                            title: Text('b'),
                          ),
                          ListTile(
                            title: Text('c'),
                          ),
                        ],
                      ).toList(),
                    )
                )
              ],
            ),
        )
      ),
    );
  }
}
