class Weather {
  final String cityName;
  final double temperature; // Temperature in Celsius
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int visibility; // Visibility in meters
  final int pressure; // Pressure in hPa

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.pressure,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'], // The temperature is in Kelvin
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'],
      visibility: json['visibility'], // Visibility in meters
      pressure: json['main']['pressure'], // Pressure in hPa
    );
  }
}
