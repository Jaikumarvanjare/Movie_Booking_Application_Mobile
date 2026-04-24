class Theatre {
  const Theatre({
    required this.id,
    required this.name,
    required this.city,
    required this.pincode,
    this.description,
    this.address,
  });

  factory Theatre.fromJson(Map<String, dynamic> json) {
    final pincodeValue = json['pincode'];
    return Theatre(
      id: _readString(json, const ['id', '_id']) ?? '',
      name: _readString(json, const ['name']) ?? 'Unnamed theatre',
      city: _readString(json, const ['city']) ?? 'Unknown city',
      pincode: pincodeValue is int
          ? pincodeValue
          : int.tryParse('$pincodeValue') ?? 0,
      description: _readString(json, const ['description']),
      address: _readString(json, const ['address']),
    );
  }

  final String id;
  final String name;
  final String city;
  final int pincode;
  final String? description;
  final String? address;
}

String? _readString(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
  }
  return null;
}
