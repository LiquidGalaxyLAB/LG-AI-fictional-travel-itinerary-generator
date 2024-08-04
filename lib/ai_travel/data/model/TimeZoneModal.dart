class TimeZoneModal {
  final String? timeZone;
  final String? currentLocalTime;

  TimeZoneModal({
    this.timeZone,
    this.currentLocalTime,
  });

  factory TimeZoneModal.fromJson(Map<String, dynamic> json) {
    return TimeZoneModal(
      timeZone: json['timeZone'] as String?,
      currentLocalTime: json['currentLocalTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeZone': timeZone,
      'currentLocalTime': currentLocalTime,
    };
  }
}
