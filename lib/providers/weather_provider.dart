import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  Weather? _weather;
  String? _lastSearchedCity;
  String? _error;
  DateTime? _lastFetchTime; // Track the last fetch time
  bool _isFetching = false; // To manage concurrent fetch requests

  Weather? get weather => _weather;
  String? get lastSearchedCity => _lastSearchedCity;
  String? get error => _error;

  final WeatherService _weatherService = WeatherService();

  Future<void> fetchWeather(String city) async {
    if (_isFetching) return; // Prevent concurrent fetch requests
    _isFetching = true;

    if (_lastSearchedCity == city && _weather != null && _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 10) {
      // If the last fetch was recent and the city hasn't changed, use cached data
      _isFetching = false;
      notifyListeners();
      return;
    }

    _error = null;
    _weather = null; // Reset weather to show loading indicator
    notifyListeners();

    try {
      final startTime = DateTime.now(); // Track the start time

      Weather fetchedWeather = await _weatherService.fetchWeather(city);

      final elapsedTime = DateTime.now().difference(startTime).inMilliseconds;
      final minimumLoadingTime = 2000; // Minimum time for the loading indicator
      final remainingTime = minimumLoadingTime - elapsedTime;

      if (remainingTime > 0) {
        await Future.delayed(Duration(milliseconds: remainingTime));
      }

      _weather = fetchedWeather;
      _lastSearchedCity = city;
      _lastFetchTime = DateTime.now(); // Update the last fetch time
    } catch (e) {
      _weather = null;
      _error = "An unexpected error occurred. Please try again later."; // Simplified error handling
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }
}
