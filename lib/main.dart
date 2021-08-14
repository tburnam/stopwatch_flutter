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
  final List<String> laps = <String>[];
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (laps.isNotEmpty) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 200), curve: Curves.easeOut);
    }
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
                          laps.clear();
                        });
                      },
                    ),
                  ],
                ),
                Visibility(
                  visible: isActive,
                  child: new ElevatedButton(child: new Text('Lap'), onPressed: () {
                    timerStream = null;
                    setState(() {
                      laps.add(_timeString);
                    });
                  }),
                ),
                Visibility(
                    visible: isActive,
                    child: Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(8),
                            controller: _scrollController,
                            itemCount: laps.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(width: 0.1, color: Colors.grey),
                                  )
                                ),
                                margin: EdgeInsets.all(2),
                                child: Center(
                                    child: Text('Lap ${index + 1}: ${laps[index]}',
                                      style: TextStyle(fontSize: 18),
                                    )
                                ),
                              );
                            }
                        )
                    )
                )
              ],
            ),
        )
      ),
    );
  }
}
