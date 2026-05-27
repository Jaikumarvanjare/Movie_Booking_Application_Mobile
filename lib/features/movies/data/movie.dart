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

  bool get isNowShowing => normalizedReleaseStatus == 'RELEASED';
  bool get isUpcoming => normalizedReleaseStatus == 'UPCOMING';

  String get normalizedReleaseStatus {
    final normalized = releaseStatus.trim().toUpperCase().replaceAll(' ', '_');
    if (normalized == 'NOW_SHOWING' ||
        normalized == 'NOWSHOWING' ||
        normalized == 'ACTIVE') {
      return 'RELEASED';
    }
    return normalized;
  }

  String get releaseDateLabel {
    if (releaseDate == null) {
      return 'Release date TBA';
    }
    return DateFormat('MMM d, yyyy').format(releaseDate!);
  }

  String get releaseStatusLabel {
    return normalizedReleaseStatus
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
    (Color(0xFFE2E8F0), Color(0xFFE11D48)),
    (Color(0xFF683B2B), Color(0xFFFFB45E)),
    (Color(0xFF233142), Color(0xFF020617)),
    (Color(0xFF2F4858), Color(0xFFFFB45E)),
    (Color(0xFF94A3B8), Color(0xFF0F172A)),
  ];
  final index = seed.isEmpty
      ? 0
      : seed.codeUnits.fold(0, (sum, code) => sum + code) % palettes.length;
  return palettes[index];
}
