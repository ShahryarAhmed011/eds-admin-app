class AppStartupDto {
  const AppStartupDto({this.role});

  factory AppStartupDto.fromJson(Map<String, dynamic> json) =>
      AppStartupDto(role: json['role'] as String?);

  /// API role of the stored session, or null when signed out.
  final String? role;

  Map<String, dynamic> toJson() => {'role': role};
}
