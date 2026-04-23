import 'package:flutter/material.dart';

class Movie {
  const Movie({
    required this.id,
    required this.name,
    required this.description,
    required this.casts,
    required this.trailerUrl,
    required this.language,
    required this.releaseDate,
    required this.director,
    required this.releaseStatus,
    required this.genre,
    required this.runtime,
    required this.rating,
    required this.badge,
    required this.formats,
    required this.showDates,
    required this.showTimes,
    required this.primaryColor,
    required this.accentColor,
  });

  final String id;
  final String name;
  final String description;
  final List<String> casts;
  final String trailerUrl;
  final String language;
  final String releaseDate;
  final String director;
  final String releaseStatus;
  final String genre;
  final String runtime;
  final String rating;
  final String badge;
  final List<String> formats;
  final List<String> showDates;
  final List<String> showTimes;
  final Color primaryColor;
  final Color accentColor;
}

const sampleNowShowingMovies = [
  Movie(
    id: 'midnight-metro',
    name: 'Midnight Metro',
    description:
        'A suspended detective and a runaway projectionist uncover a city-wide conspiracy during the last metro ride of the night.',
    casts: ['Aarav Mehta', 'Mira Sen', 'Kabir Rao'],
    trailerUrl: 'https://example.com/trailers/midnight-metro',
    language: 'English',
    releaseDate: '2026-04-18',
    director: 'Nolan Verma',
    releaseStatus: 'NOW_SHOWING',
    genre: 'Action thriller',
    runtime: '2h 08m',
    rating: '4.8',
    badge: 'IMAX',
    formats: ['2D', 'IMAX', 'Dolby'],
    showDates: ['Today', 'Tomorrow', 'Fri'],
    showTimes: ['10:30 AM', '2:15 PM', '6:45 PM', '10:10 PM'],
    primaryColor: Color(0xFF2A2118),
    accentColor: Color(0xFFC44536),
  ),
  Movie(
    id: 'city-of-stars',
    name: 'City of Stars',
    description:
        'Two artists chase one final performance across Mumbai as fame, friendship, and love collide under festival lights.',
    casts: ['Rhea Kapoor', 'Dev Malik', 'Sana Ali'],
    trailerUrl: 'https://example.com/trailers/city-of-stars',
    language: 'Hindi',
    releaseDate: '2026-04-12',
    director: 'Ira Menon',
    releaseStatus: 'NOW_SHOWING',
    genre: 'Romance drama',
    runtime: '1h 54m',
    rating: '4.6',
    badge: 'Dolby',
    formats: ['2D', 'Dolby'],
    showDates: ['Today', 'Tomorrow', 'Sat'],
    showTimes: ['11:00 AM', '4:30 PM', '8:00 PM'],
    primaryColor: Color(0xFF683B2B),
    accentColor: Color(0xFFFFB45E),
  ),
  Movie(
    id: 'orbit-nine',
    name: 'Orbit Nine',
    description:
        'A rescue crew crosses a collapsing orbital colony to bring home the scientist who can save Earth from blackout.',
    casts: ['Zoya Khan', 'Neil Dsouza', 'Tara Bose'],
    trailerUrl: 'https://example.com/trailers/orbit-nine',
    language: 'English',
    releaseDate: '2026-04-10',
    director: 'Kabir Anand',
    releaseStatus: 'NOW_SHOWING',
    genre: 'Sci-fi adventure',
    runtime: '2h 21m',
    rating: '4.9',
    badge: '3D',
    formats: ['3D', 'IMAX'],
    showDates: ['Today', 'Tomorrow', 'Sun'],
    showTimes: ['9:45 AM', '1:20 PM', '7:35 PM'],
    primaryColor: Color(0xFF233142),
    accentColor: Color(0xFFFFE0B8),
  ),
];

const sampleComingSoonMovies = [
  Movie(
    id: 'last-balcony',
    name: 'The Last Balcony',
    description:
        'A reclusive theatre owner receives clues from an empty balcony seat that reopen a decades-old mystery.',
    casts: ['Pranav Shah', 'Leela Nair', 'Om Patil'],
    trailerUrl: 'https://example.com/trailers/last-balcony',
    language: 'English',
    releaseDate: '2026-04-30',
    director: 'Meera Dutt',
    releaseStatus: 'UPCOMING',
    genre: 'Mystery',
    runtime: 'Releasing Fri',
    rating: '92%',
    badge: 'Pre-book',
    formats: ['2D'],
    showDates: ['Fri', 'Sat', 'Sun'],
    showTimes: ['5:00 PM', '9:00 PM'],
    primaryColor: Color(0xFF5C4630),
    accentColor: Color(0xFFFFF4E6),
  ),
  Movie(
    id: 'laugh-track-live',
    name: 'Laugh Track Live',
    description:
        'A touring comedian accidentally livestreams the one set that could either end his career or make him a star.',
    casts: ['Nikhil Das', 'Avni Roy', 'Farah Khan'],
    trailerUrl: 'https://example.com/trailers/laugh-track-live',
    language: 'Hindi',
    releaseDate: '2026-05-02',
    director: 'Sameer Kulkarni',
    releaseStatus: 'UPCOMING',
    genre: 'Comedy',
    runtime: 'Releasing May 02',
    rating: '88%',
    badge: 'Alert me',
    formats: ['2D', 'Dolby'],
    showDates: ['May 02', 'May 03', 'May 04'],
    showTimes: ['12:15 PM', '6:10 PM'],
    primaryColor: Color(0xFF2F4858),
    accentColor: Color(0xFFFFB45E),
  ),
];
