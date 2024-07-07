import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../providers/weather_provider.dart';
import '../models/weather.dart';

const List<Color> _kDefaultRainbowColors = [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

class WeatherDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final Weather? weather = weatherProvider.weather;
    final String? error = weatherProvider.error;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: IconThemeData(color: Colors.white), // Make back button white
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _refreshWeather(context),
            tooltip: 'Refresh',
          ),
        ],
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (error != null) {
                return _buildErrorState(context, error);
              }

              if (weather == null) {
                return _buildLoadingState(constraints);
              }

              return _buildWeatherDetails(context, weather, constraints.maxWidth);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Error: $error', style: TextStyle(color: Colors.white)),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _refreshWeather(context),
          child: Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth * 0.2, // Example: 20% of screen width
      height: constraints.maxWidth * 0.2, // Example: 20% of screen width
      child: LoadingIndicator(
        indicatorType: Indicator.lineScale, // Match HomeScreen indicator type
        colors: _kDefaultRainbowColors, // Match HomeScreen colors
        strokeWidth: 2.2, // Match HomeScreen stroke width
      ),
    );
  }

  Widget _buildWeatherDetails(BuildContext context, Weather weather, double maxWidth) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_pin, color: Colors.red, size: 34),
              SizedBox(width: 8),
              Text(
                weather.cityName,
                style: TextStyle(
                  fontSize: maxWidth > 600 ? 42 : 32, // Adjust font size based on screen width
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(height: 16),
          Image.network(
            'http://openweathermap.org/img/wn/${weather.icon}.png',
            width: maxWidth > 600 ? 200 : 100, // Adjust image width based on screen width
            height: maxWidth > 600 ? 200 : 100, // Adjust image height based on screen width
          ),
          SizedBox(height: 16),
          Text(
            '${(weather.temperature - 273.15).toStringAsFixed(1)} °C', // Convert from Kelvin to Celsius
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            weather.description,
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoBox('Humidity', '${weather.humidity}%', Icons.water_drop),
              _buildInfoBox('Wind Speed', '${weather.windSpeed.toStringAsFixed(1)} m/s', Icons.air),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoBox('Visibility', '${weather.visibility / 1000} km', Icons.visibility),
              _buildInfoBox('Pressure', '${weather.pressure} hPa', Icons.compress),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.symmetric(horizontal: 4.0), // Margin between columns
        decoration: BoxDecoration(
          color: Colors.blueGrey[800],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis, // Handle long titles
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshWeather(BuildContext context) async {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);

    if (weatherProvider.weather != null) {
      final cityName = weatherProvider.weather!.cityName;

      try {
        // Show a loading indicator or message while refreshing
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Refreshing weather data...')),
        );

        await weatherProvider.fetchWeather(cityName);

        // Remove the loading indicator or message
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Weather data refreshed!')),
        );
      } catch (error) {
        // Remove the loading indicator or message
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh weather data')),
        );
      }
    }
  }
}
