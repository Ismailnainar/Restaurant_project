import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class TimerPage extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late Timer _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? startTimeString = prefs.getString('start_time');
    int? elapsedSeconds = prefs.getInt('elapsed_seconds');

    if (startTimeString != null && elapsedSeconds != null) {
      _startTime = DateTime.parse(startTimeString);
      _elapsedSeconds = elapsedSeconds;
      _isRunning = true;
      _startTimer();
    }
  }

  void _startTimer() {
    if (_isRunning) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedSeconds++;
          _savePreferences();
        });
      });
    }
  }

  void _start() async {
    _startTime = DateTime.now();
    _isRunning = true;
    _elapsedSeconds = 0;
    await _savePreferences();
    _startTimer();
  }

  void _stop() async {
    if (_isRunning) {
      _timer.cancel();
      _isRunning = false;
      _startTime = null;
      await _clearPreferences();
      setState(() {});
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('start_time', _startTime?.toIso8601String() ?? '');
    await prefs.setInt('elapsed_seconds', _elapsedSeconds);
  }

  Future<void> _clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('start_time');
    await prefs.remove('elapsed_seconds');
  }

  String _formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Persistent Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Elapsed Time:',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              _formatDuration(_elapsedSeconds),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _isRunning ? null : _start,
                  child: Text('Start'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isRunning ? _stop : null,
                  child: Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
