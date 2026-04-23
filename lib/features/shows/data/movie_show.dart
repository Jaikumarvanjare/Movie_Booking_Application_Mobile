class MovieShow {
  const MovieShow({
    required this.id,
    required this.theatreId,
    required this.movieId,
    required this.dateLabel,
    required this.timeLabel,
    required this.noOfSeats,
    required this.price,
    required this.format,
  });

  final String id;
  final String theatreId;
  final String movieId;
  final String dateLabel;
  final String timeLabel;
  final int noOfSeats;
  final double price;
  final String format;
}

const sampleShows = [
  MovieShow(
    id: 'show-midnight-nova-1030',
    theatreId: 'nova-cinemas',
    movieId: 'midnight-metro',
    dateLabel: 'Today',
    timeLabel: '10:30 AM',
    noOfSeats: 72,
    price: 240,
    format: 'IMAX',
  ),
  MovieShow(
    id: 'show-midnight-nova-1845',
    theatreId: 'nova-cinemas',
    movieId: 'midnight-metro',
    dateLabel: 'Today',
    timeLabel: '6:45 PM',
    noOfSeats: 36,
    price: 320,
    format: 'Dolby',
  ),
  MovieShow(
    id: 'show-midnight-royal-2100',
    theatreId: 'royal-talkies',
    movieId: 'midnight-metro',
    dateLabel: 'Tomorrow',
    timeLabel: '9:00 PM',
    noOfSeats: 54,
    price: 180,
    format: '2D',
  ),
  MovieShow(
    id: 'show-stars-nova-1630',
    theatreId: 'nova-cinemas',
    movieId: 'city-of-stars',
    dateLabel: 'Today',
    timeLabel: '4:30 PM',
    noOfSeats: 64,
    price: 220,
    format: 'Dolby',
  ),
  MovieShow(
    id: 'show-stars-skyline-2000',
    theatreId: 'skyline-multiplex',
    movieId: 'city-of-stars',
    dateLabel: 'Today',
    timeLabel: '8:00 PM',
    noOfSeats: 49,
    price: 260,
    format: '2D',
  ),
  MovieShow(
    id: 'show-orbit-nova-1320',
    theatreId: 'nova-cinemas',
    movieId: 'orbit-nine',
    dateLabel: 'Today',
    timeLabel: '1:20 PM',
    noOfSeats: 41,
    price: 340,
    format: 'IMAX',
  ),
  MovieShow(
    id: 'show-orbit-skyline-1935',
    theatreId: 'skyline-multiplex',
    movieId: 'orbit-nine',
    dateLabel: 'Tomorrow',
    timeLabel: '7:35 PM',
    noOfSeats: 28,
    price: 300,
    format: '3D',
  ),
];

List<MovieShow> sampleShowsFor({
  required String theatreId,
  required String movieId,
}) {
  return sampleShows
      .where((show) => show.theatreId == theatreId && show.movieId == movieId)
      .toList(growable: false);
}
