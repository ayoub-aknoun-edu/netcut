import 'dart:convert';

class AppGroup {
  final String id;
  final String name;
  final bool enabled;
  final List<String> packageNames;

  const AppGroup({
    required this.id,
    required this.name,
    required this.enabled,
    required this.packageNames,
  });

  AppGroup copyWith({
    String? id,
    String? name,
    bool? enabled,
    List<String>? packageNames,
  }) {
    return AppGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      packageNames: packageNames ?? this.packageNames,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'enabled': enabled,
    'packageNames': packageNames,
  };

  static AppGroup fromMap(Map<String, dynamic> map) => AppGroup(
    id: map['id'] as String,
    name: map['name'] as String,
    enabled: map['enabled'] as bool? ?? false,
    packageNames: (map['packageNames'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
  );

  static String encodeList(List<AppGroup> groups) =>
      jsonEncode(groups.map((g) => g.toMap()).toList());

  static List<AppGroup> decodeList(String raw) {
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((e) => AppGroup.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    return list;
  }
}
