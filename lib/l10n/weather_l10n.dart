import '../data/remote/weather_api_exception.dart';
import '../models/city.dart';
import '../models/current_weather.dart';
import '../models/skycon_catalog.dart';
import 'app_localizations.dart';

/// Localized presentation helpers for the language-neutral weather models.
extension WeatherLocalizations on AppLocalizations {
  /// Display name for [city]. China Weather area names are Chinese and are not
  /// translated.
  String cityName(CityLocation city) => city.name;

  String skyconLabel(String skycon) => skyconFor(skycon).label(this);

  /// Keypoint text from the API when present, otherwise the sky condition.
  String currentSummary(CurrentWeather weather) {
    final keypoint = weather.apiSummary?.trim();
    if (keypoint != null && keypoint.isNotEmpty) return keypoint;
    return skyconLabel(weather.skycon);
  }

  String windLabel(num speedKmh) {
    if (speedKmh < 6) return windCalm;
    if (speedKmh < 20) return windBreezy;
    if (speedKmh < 39) return windWindy;
    return windStrong;
  }

  String rainLabel(double intensity, int probability) {
    if (intensity > 0) return rainRaining;
    if (probability >= 60) return rainLikely;
    if (probability >= 30) return rainPossible;
    return rainDry;
  }

  String comfortLabel(String? desc) => _apiText(desc) ?? comfortMild;

  String uvLabel(String? desc) => _apiText(desc) ?? uvLow;

  /// Weekday name from an ISO-8601 date string such as `2026-10-14T00:00+02:00`.
  String weekdayName(String isoDate) {
    final datePart = isoDate.length >= 10 ? isoDate.substring(0, 10) : isoDate;
    final date = DateTime.tryParse(datePart);
    if (date == null) return '';
    return switch (date.weekday) {
      DateTime.monday => weekdayMonday,
      DateTime.tuesday => weekdayTuesday,
      DateTime.wednesday => weekdayWednesday,
      DateTime.thursday => weekdayThursday,
      DateTime.friday => weekdayFriday,
      DateTime.saturday => weekdaySaturday,
      _ => weekdaySunday,
    };
  }

  String weeklyForecastSummary(String dominantSkycon) =>
      weeklySummary(skyconLabel(dominantSkycon));

  String hourlyForecastSummary(String dominantSkycon) =>
      hourlySummary(skyconLabel(dominantSkycon));

  /// Hour-of-day label from an ISO-8601 timestamp such as
  /// `2026-10-14T15:00+02:00`, using a 24-hour clock when [use24Hour] is true
  /// and am/pm otherwise. The hour is read straight from the string so the
  /// timestamp's own offset is preserved rather than converted to the device's
  /// time zone.
  String hourLabel(String isoDateTime, {required bool use24Hour}) {
    if (isoDateTime.length < 13) return '';
    final hour = int.tryParse(isoDateTime.substring(11, 13));
    if (hour == null) return '';
    if (use24Hour) return hour24(hour);
    if (hour == 0) return hourAm(12);
    if (hour < 12) return hourAm(hour);
    if (hour == 12) return hourPm(12);
    return hourPm(hour - 12);
  }

  String weatherError(WeatherApiException error) => switch (error.kind) {
    WeatherErrorKind.unreachable => errorUnreachable,
    WeatherErrorKind.badStatus => errorBadStatus(error.statusCode ?? 0),
    WeatherErrorKind.invalidData => errorInvalidData,
    WeatherErrorKind.noData => errorNoData,
    WeatherErrorKind.serviceError => error.detail ?? errorService,
  };

  /// Display text for any thrown error: localized for [WeatherApiException],
  /// otherwise the error's own string.
  String weatherErrorText(Object error) =>
      error is WeatherApiException ? weatherError(error) : '$error';

  String? _apiText(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return null;
    return text.toLowerCase();
  }
}
