import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Movie {
  Movie({
    required this.id,
    required this.name,
    required this.description,
    required this.casts,
    required this.trailerUrl,
    required this.language,
    required this.releaseDate,
    required this.director,
    required this.releaseStatus,
    required this.poster,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final casts = json['casts'];
    return Movie(
      id: _readString(json, const ['id', '_id']) ?? '',
      name: _readString(json, const ['name']) ?? 'Untitled movie',
      description: _readString(json, const ['description']) ?? '',
      casts: casts is List
          ? casts.whereType<Object?>().map((cast) => '$cast').toList()
          : const <String>[],
      trailerUrl: _readString(json, const ['trailerUrl']) ?? '',
      language: _readString(json, const ['language']) ?? 'Unknown',
      releaseDate: DateTime.tryParse(
        _readString(json, const ['releaseDate']) ?? '',
      ),
      director: _readString(json, const ['director']) ?? 'Unknown',
      releaseStatus: _readString(json, const ['releaseStatus']) ?? 'UPCOMING',
      poster: _readString(json, const ['poster']) ?? '',
    );
  }

  final String id;
  final String name;
  final String description;
  final List<String> casts;
  final String trailerUrl;
  final String language;
  final DateTime? releaseDate;
  final String director;
  final String releaseStatus;
  final String poster;

  bool get isNowShowing => releaseStatus.toUpperCase() == 'NOW_SHOWING';

  String get releaseDateLabel {
    if (releaseDate == null) {
      return 'Release date TBA';
    }
    return DateFormat('MMM d, yyyy').format(releaseDate!);
  }

  String get releaseStatusLabel {
    return releaseStatus
        .toLowerCase()
        .split('_')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  Color get primaryColor => _moviePaletteFor(id).$1;
  Color get accentColor => _moviePaletteFor(id).$2;
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

(Color, Color) _moviePaletteFor(String seed) {
  const palettes = <(Color, Color)>[
    (Color(0xFF2A2118), Color(0xFFC44536)),
    (Color(0xFF683B2B), Color(0xFFFFB45E)),
    (Color(0xFF233142), Color(0xFFFFE0B8)),
    (Color(0xFF2F4858), Color(0xFFFFB45E)),
    (Color(0xFF5C4630), Color(0xFFFFF4E6)),
  ];
  final index = seed.isEmpty
      ? 0
      : seed.codeUnits.fold(0, (sum, code) => sum + code) % palettes.length;
  return palettes[index];
}
