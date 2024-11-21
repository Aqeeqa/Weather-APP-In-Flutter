import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SettingsScreen.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String apiKey = '111706c01420a45b8bb3afdbc1e0a660';
  String cityName = 'Fetching...';
  String weatherDescription = 'Loading...';
  double temperature = 0.0;
  double feelsLike = 0.0;
  int humidity = 0;
  double windSpeed = 0.0;
  bool isFahrenheit = false;
  bool isLoading = false;
  String errorMessage = '';
  String selectedBackground = 'assets/clear_sky.jpg';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    fetchWeatherData();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFahrenheit = prefs.getBool('isFahrenheit') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFahrenheit', isFahrenheit);
  }

  Future<void> fetchWeatherData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      Position position = await _determinePosition();
      String apiUrl =
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid=$apiKey';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          cityName = data['name'];
          weatherDescription = data['weather'][0]['description'];
          double tempCelsius = (data['main']['temp'] as num).toDouble();
          double feelsLikeCelsius = (data['main']['feels_like'] as num).toDouble();

          temperature = isFahrenheit ? _convertToFahrenheit(tempCelsius) : tempCelsius;
          feelsLike = isFahrenheit ? _convertToFahrenheit(feelsLikeCelsius) : feelsLikeCelsius;
          humidity = data['main']['humidity'];
          windSpeed = (data['wind']['speed'] as num).toDouble();
          selectedBackground = _getBackgroundImage(weatherDescription);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: ${e.toString()}';
        isLoading = false;
      });
      // Show an AlertDialog for major errors
      if (e.toString().contains('Failed to fetch weather data') || e.toString().contains('Network')) {
        _showErrorDialog('Error: ${e.toString()}');
      } else {
        // For minor issues, show a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  double _convertToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  String _getBackgroundImage(String weather) {
    if (weather.contains('rain')) {
      return 'assets/rainy_background.jpg';
    } else if (weather.contains('clear')) {
      return 'assets/clear_sky.jpg';
    } else {
      return 'assets/cloudy_background.jpg';
    }
  }

  void _openSettingsScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(isFahrenheit: isFahrenheit),
      ),
    );

    if (result != null && result.containsKey('isFahrenheit')) {
      setState(() {
        isFahrenheit = result['isFahrenheit'];
      });
      _saveSettings();
      fetchWeatherData();
    }
  }

  // Function to show the error dialog
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      )
          : Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(selectedBackground),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  cityName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  weatherDescription.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${temperature.toStringAsFixed(1)}°${isFahrenheit ? 'F' : 'C'}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Feels like ${feelsLike.toStringAsFixed(1)}°${isFahrenheit ? 'F' : 'C'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    WeatherDetail(
                      label: 'Humidity',
                      value: '$humidity%',
                      icon: Icons.water_drop,
                    ),
                    WeatherDetail(
                      label: 'Wind Speed',
                      value: '${windSpeed.toStringAsFixed(1)} m/s',
                      icon: Icons.wind_power,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _openSettingsScreen,
                  child: const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Refresh Button
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              onPressed: fetchWeatherData,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherDetail extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const WeatherDetail({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }
}
