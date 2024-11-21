import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool isFahrenheit;

  const SettingsScreen({Key? key, required this.isFahrenheit}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool isFahrenheit;

  @override
  void initState() {
    super.initState();
    isFahrenheit = widget.isFahrenheit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(
          fontSize: 22,
          color: Colors.white60,
          fontWeight: FontWeight.bold,
        ),),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Display temperature in Fahrenheit',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis, // Add this to handle very long text.
                      ),
                    ),
                    Switch(
                      value: isFahrenheit,
                      onChanged: (value) {
                        setState(() {
                          isFahrenheit = value;
                        });
                      },
                      activeColor: isFahrenheit ? Colors.blueGrey : Colors.red, // Change the switch color when it's active
                      inactiveThumbColor: Colors.grey, // Change the thumb color when inactive
                      inactiveTrackColor: Colors.grey[300], // Change the track color when inactive
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, {'isFahrenheit': isFahrenheit});
                },
                child: const Text(
                  'Save Settings',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
