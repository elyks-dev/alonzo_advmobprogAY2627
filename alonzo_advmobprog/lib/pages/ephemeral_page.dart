import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';


class EphemeralPage extends StatefulWidget {
  final ValueListenable<bool>? resetNotifier;

  const EphemeralPage({super.key, this.resetNotifier});

  @override
  State<EphemeralPage> createState() => _EphemeralPageState();
}

class _EphemeralPageState extends State<EphemeralPage> {
  static const _counterKey = 'ephemeral_counter';
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadCounter();
    if (widget.resetNotifier != null) {
      widget.resetNotifier!.addListener(_handleResetSignal);
    }
  }

  void _handleResetSignal() {
    // When parent toggles the notifier we reset the ephemeral counter.
    _resetCounter();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt(_counterKey) ?? 0;
    });
  }

  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey, _counter);
  }

  /// Increments the counter.
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    _saveCounter();
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
    _saveCounter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ephemeral State"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: _resetCounter,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "You have pushed the button this many times:",
            ),
            const SizedBox(height: 10),
            Text(
              "$_counter",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: "Increment",
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.resetNotifier != null) {
      widget.resetNotifier!.removeListener(_handleResetSignal);
    }
    super.dispose();
  }
}
