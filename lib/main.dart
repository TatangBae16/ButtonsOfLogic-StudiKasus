import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buttons of Logic',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF050B18),
      ),
      home: const LogicButtonsPage(),
    );
  }
}

class LogicButtonsPage extends StatefulWidget {
  const LogicButtonsPage({super.key});

  @override
  State<LogicButtonsPage> createState() => _LogicButtonsPageState();
}

class _LogicButtonsPageState extends State<LogicButtonsPage>
    with SingleTickerProviderStateMixin {
  int _count = 0;
  List<int> _history = [];
  int _zeroStrike = 0;
  bool _isLocked = false;

  AnimationController? _shakeController;

  String get _parity => _count % 2 == 0 ? "GENAP" : "GANJIL";

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _updateCount(int change) {
    if (_isLocked) return;

    HapticFeedback.lightImpact();

    setState(() {
      int newValue = _count + change;

      _history.insert(0, newValue);
      if (_history.length > 5) _history.removeLast();

      if (newValue == 0) {
        _zeroStrike++;
        if (_zeroStrike >= 3) {
          _isLocked = true;
          _shakeController?.forward(from: 0);
          _showLockedDialog();
        }
      } else {
        _zeroStrike = 0;
      }

      _count = newValue;
    });
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _count = 0;
      _history.clear();
      _zeroStrike = 0;
      _isLocked = false;
    });
  }

  void _showLockedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0E162E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("⚠ SYSTEM LOCK"),
        content: const Text(
          "ZERO VALUE DETECTED\n3x SEQUENTIALLY\n\nINPUT DISABLED",
          style: TextStyle(letterSpacing: 1.3),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ACKNOWLEDGE"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _shakeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LOGIC CORE SYSTEM"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ================= DISPLAY =================
            AnimatedBuilder(
              animation: _shakeController ?? const AlwaysStoppedAnimation(0),
              builder: (context, child) {
                final offset = _isLocked && _shakeController != null
                    ? 8 * (0.5 - _shakeController!.value)
                    : 0.0;

                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: _glassDisplay(),
            ),


            const SizedBox(height: 30),

            // ================= BUTTONS =================
            Row(
              children: [
                Expanded(
                  child: _futuristicButton(
                    text: "DECREMENT",
                    color: Colors.redAccent,
                    onTap: _isLocked ? null : () => _updateCount(-1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _futuristicButton(
                    text: "INCREMENT",
                    color: Colors.greenAccent,
                    onTap: _isLocked ? null : () => _updateCount(1),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.cyanAccent),
                  foregroundColor: Colors.cyanAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("RESET SYSTEM"),
              ),
            ),

            const SizedBox(height: 25),
            const Divider(color: Colors.white24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "HISTORY LOG",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  letterSpacing: 2,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (_, i) {
                  final val = _history[i];
                  return Card(
                    color: const Color(0xFF0E162E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.cyanAccent,
                        child: Text(
                          "${i + 1}",
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      title: Text("VALUE: $val"),
                      subtitle: Text(val % 2 == 0 ? "GENAP" : "GANJIL"),
                      trailing: Icon(
                        val == 0 ? Icons.warning : Icons.memory,
                        color:
                        val == 0 ? Colors.orangeAccent : Colors.cyanAccent,
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= COMPONENTS =================

  Widget _glassDisplay() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF00E5FF),
                Color(0xFF3D5AFE),
                Color(0xFF651FFF),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.8),
                blurRadius: 40,
                spreadRadius: 2,
              )
            ],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: Text(
                  '$_count',
                  key: ValueKey(_count),
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _parity,
                style: const TextStyle(
                  color: Colors.black87,
                  letterSpacing: 4,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _futuristicButton({
    required String text,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(text),
    );
  }
}
