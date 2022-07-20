import 'package:wanderbar/weather_apikey.dart';
import 'package:weather/weather.dart';

class WeatherPreset {
  final String iconPath;
  final String description;

  WeatherPreset(this.description, this.iconPath);
}

class WeatherHelper {
  static final path = "assets/icons/weather/";
  static final Map<String, WeatherPreset> weather = {
    "WIND1": WeatherPreset("Windy", "${path}003-windy.svg"),
    "RAIN": WeatherPreset("Rain", "${path}004-rainy.svg"),
    "RAIN1": WeatherPreset("Heavy Rain", "${path}005-rainy.svg"),
    "RAIN2": WeatherPreset("Even heavier Rain", "${path}006-rainy.svg"),
    "THUNDER": WeatherPreset("Thunder", "${path}007-storm.svg"),
    "STORM": WeatherPreset("Storm", "${path}008-storm.svg"),
    "STORM1": WeatherPreset("Thunder-Storm", "${path}013-storm.svg"),
    "STORM2": WeatherPreset("Sun and Storm", "${path}014-storm.svg"),
    "SNOW": WeatherPreset("Snowing", "${path}009-snow.svg"),
    "SNOW2": WeatherPreset("Sleet and Snowing", "${path}010-sleet.svg"),
    "CLEAR": WeatherPreset("Clear sky", "${path}001-sun.svg"),
    "SUN": WeatherPreset("Sun and clouds", "${path}011-cloud.svg"),
    "SUN2": WeatherPreset("Sunny", "${path}015-sun.svg"),
    "SUN3": WeatherPreset("Few Clouds", "${path}016-sun.svg"),
    "CLOUD": WeatherPreset("Cloudy", "${path}012-cloudy.svg"),
    "COLD": WeatherPreset("Cold", "${path}029-snowflake.svg"),
    "EXTREM1": WeatherPreset("Extrem Hot", "${path}028-hot.svg"),
    "EXTREM2": WeatherPreset("Extrem Cold", "${path}027-cold.svg"),
    "EXTREM3": WeatherPreset("UV Intense", "${path}030-uv index.svg"),
    "MIST": WeatherPreset("Mist/Fog", "${path}024-humidity.svg"),
    "TORNADO": WeatherPreset("Severe Wind", "${path}tornado.svg"),
  };

  static final Map<int, String> openWeatherApiMapping = {
    200: "THUNDER",
    201: "STORM1",
    202: "STORM",
    210: "STORM",
    211: "THUNDER",
    212: "STORM1",
    221: "STORM1",
    230: "STORM2",
    231: "STORM2",
    232: "STORM1",
    300: "RAIN",
    301: "RAIN",
    302: "RAIN",
    310: "RAIN",
    311: "RAIN",
    312: "RAIN",
    313: "RAIN",
    314: "RAIN",
    321: "RAIN",
    500: "RAIN",
    501: "RAIN1",
    502: "RAIN2",
    503: "RAIN2",
    504: "RAIN2",
    511: "SNOW2",
    520: "RAIN",
    521: "RAIN",
    522: "RAIN1",
    531: "RAIN1",
    600: "SNOW",
    601: "SNOW",
    602: "SNOW",
    611: "SNOW2",
    612: "SNOW2",
    613: "SNOW2",
    614: "SNOW2",
    615: "SNOW2",
    616: "SNOW2",
    620: "SNOW2",
    621: "SNOW2",
    622: "SNOW",
    701: "MIST",
    711: "MIST",
    721: "MIST",
    731: "MIST",
    741: "MIST",
    751: "MIST",
    761: "MIST",
    762: "MIST",
    771: "MIST",
    781: "TORNADO",
    800: "CLEAR",
    801: "SUN3",
    802: "SUN",
    803: "CLOUD",
    804: "CLOUD"
  };

  WeatherFactory wf =
      new WeatherFactory(weather_key, language: Language.ENGLISH);

  WeatherPreset getEntry(String key) {
    if (weather.containsKey(key)) {
      return weather[key];
    }
    return null;
  }

  List getAllWeatherStates() {
    return weather.keys.toList();
  }

  Future<Weather> getWeather(lat, lon) {
    return wf.currentWeatherByLocation(lat, lon);
  }

  WeatherPreset getWeatherInfoFromCode(int code) {
    if (openWeatherApiMapping.containsKey(code)) {
      final codeMapping = openWeatherApiMapping[code];
      return weather[codeMapping];
    }
    throw Error();
  }

  String getWeatherCode(int code) {
    if (openWeatherApiMapping.containsKey(code)) {
      final codeMapping = openWeatherApiMapping[code];
      return codeMapping;
    }
    throw Error();
  }
}
