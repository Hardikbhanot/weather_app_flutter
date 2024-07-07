import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../providers/weather_provider.dart';
import '../services/city_preferences.dart';
import 'weather_details_screen.dart';

const List<Color> _kDefaultRainbowColors = [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  bool _isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    _loadLastSearchedCity();
  }

  void _loadLastSearchedCity() async {
    String? lastCity = await CityPreferences.getLastCity();
    if (lastCity != null) {
      _cityController.text = lastCity;
    }
  }

  void _searchWeather() async {
    if (_cityController.text.isNotEmpty) {
      setState(() {
        _isLoading = true; // Start loading
      });

      try {
        await Provider.of<WeatherProvider>(context, listen: false)
            .fetchWeather(_cityController.text);
        
        // Save the last searched city
        await CityPreferences.saveLastCity(_cityController.text);
        
        setState(() {
          _isLoading = false; // Stop loading
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WeatherDetailsScreen()),
        );
      } catch (error) {
        setState(() {
          _isLoading = false; // Stop loading
        });
        _showError('Failed to load weather data');
      }
    } else {
      _showError('Please enter a city name');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather App',
          style: TextStyle(color: Colors.white), // White text color
        ),
        backgroundColor: Colors.grey[900], // Darken the app bar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF44b09e),
              Color(0xFFe0d2c7),
            ],
            stops: [0.0, 0.74],
          ),
        ),
        child: Center(
          child: _isLoading
              ? Container(
                  width: 100,
                  height: 100,
                  child: LoadingIndicator(
                    indicatorType: Indicator.lineScale,
                    colors: _kDefaultRainbowColors,
                    strokeWidth: 2.2,
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      return _buildTabletLayout();
                    } else {
                      return _buildMobileLayout();
                    }
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch, // Align widgets to start
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 8), // Add space at the top
            _buildWeatherImage(),
            SizedBox(height: 32), // Space between image and text field
            _buildCityTextField(),
            SizedBox(height: 16),
            _buildSearchButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Container(
          // width: 400,
          child: SingleChildScrollView(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.start, // Align widgets to start
              children: [
                // SizedBox(height: 16), // Add space at the top
                _buildWeatherImage(),
                SizedBox(height: 32), // Space between image and text field
                _buildCityTextField(),
                SizedBox(height: 16),
                _buildSearchButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherImage() {
    return Center(
      child: Image.asset(
        'assets/image/home.png', 
        height: 200, // Increased size for better visibility
        fit: BoxFit.cover, // Ensure the image covers the specified height proportionally
      ),
    );
  }

  Widget _buildCityTextField() {
  return TextField(
    controller: _cityController,
    style: TextStyle(color: Colors.white), // Default text color
    decoration: InputDecoration(
      labelText: 'City Name',
      labelStyle: TextStyle(color: Colors.black),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black), // Border color when not focused
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black), // Border color when focused
      ),
      fillColor: Color.fromARGB(255, 87, 82, 82), // Dark background for the text field
      filled: true,
    ),
  );
}


  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: _searchWeather,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[800], // Dark button background
        foregroundColor: Colors.white, // White text color
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: TextStyle(fontSize: 18),
      ),
      child: Text('Search'),
    );
  }
}

