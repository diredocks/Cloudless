/// A trimmed-down but structurally faithful Caiyun v2.6 `/weather` response.
const sampleWeatherResponse = '''
{
  "status": "ok",
  "api_version": "v2.6",
  "api_status": "active",
  "lang": "en_US",
  "unit": "metric",
  "timezone": "Europe/Madrid",
  "location": [36.7213, -4.4214],
  "result": {
    "realtime": {
      "status": "ok",
      "temperature": 24.48,
      "apparent_temperature": 23.2,
      "skycon": "CLEAR_DAY",
      "wind": {"speed": 17.28, "direction": 132.13},
      "precipitation": {
        "local": {"status": "ok", "datasource": "radar", "intensity": 0.0}
      },
      "life_index": {
        "ultraviolet": {"index": 5, "desc": "Moderate"},
        "comfort": {"index": 5, "desc": "Pleasant"}
      }
    },
    "hourly": {
      "description": "Partly cloudy",
      "precipitation": [
        {"datetime": "2026-10-14T15:00+02:00", "value": 0.0, "probability": 10}
      ]
    },
    "daily": {
      "temperature": [
        {"date": "2026-10-14T00:00+02:00", "max": 24.68, "min": 17.96, "avg": 23.09},
        {"date": "2026-10-15T00:00+02:00", "max": 24.47, "min": 17.02, "avg": 20.83},
        {"date": "2026-10-16T00:00+02:00", "max": 24.17, "min": 17.81, "avg": 20.92},
        {"date": "2026-10-17T00:00+02:00", "max": 23.55, "min": 16.40, "avg": 20.10},
        {"date": "2026-10-18T00:00+02:00", "max": 22.90, "min": 15.80, "avg": 19.60},
        {"date": "2026-10-19T00:00+02:00", "max": 23.10, "min": 16.10, "avg": 19.90},
        {"date": "2026-10-20T00:00+02:00", "max": 23.80, "min": 16.90, "avg": 20.40}
      ],
      "skycon": [
        {"date": "2026-10-14T00:00+02:00", "value": "CLEAR_DAY"},
        {"date": "2026-10-15T00:00+02:00", "value": "CLEAR_DAY"},
        {"date": "2026-10-16T00:00+02:00", "value": "PARTLY_CLOUDY_DAY"},
        {"date": "2026-10-17T00:00+02:00", "value": "CLEAR_DAY"},
        {"date": "2026-10-18T00:00+02:00", "value": "CLEAR_DAY"},
        {"date": "2026-10-19T00:00+02:00", "value": "CLEAR_DAY"},
        {"date": "2026-10-20T00:00+02:00", "value": "CLOUDY"}
      ],
      "precipitation": [
        {"date": "2026-10-14T00:00+02:00", "max": 0.0, "min": 0.0, "avg": 0.0, "probability": 10}
      ]
    },
    "primary": 0,
    "forecast_keypoint": "Over the next two hours, no rain is expected"
  }
}
''';
