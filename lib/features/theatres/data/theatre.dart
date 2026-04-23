class Theatre {
  const Theatre({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.pincode,
    required this.address,
    required this.movieIds,
    required this.formats,
    required this.distance,
  });

  final String id;
  final String name;
  final String description;
  final String city;
  final int pincode;
  final String address;
  final List<String> movieIds;
  final List<String> formats;
  final String distance;
}

const sampleTheatres = [
  Theatre(
    id: 'nova-cinemas',
    name: 'Nova Cinemas',
    description: 'Premium recliners, quick snacks, and Dolby screens.',
    city: 'Pune',
    pincode: 411001,
    address: 'MG Road, Camp, Pune',
    movieIds: ['midnight-metro', 'city-of-stars', 'orbit-nine'],
    formats: ['2D', 'IMAX', 'Dolby'],
    distance: '2.4 km',
  ),
  Theatre(
    id: 'royal-talkies',
    name: 'Royal Talkies',
    description: 'Classic single-screen charm with modern projection.',
    city: 'Pune',
    pincode: 411030,
    address: 'Tilak Road, Sadashiv Peth, Pune',
    movieIds: ['midnight-metro', 'last-balcony'],
    formats: ['2D'],
    distance: '4.1 km',
  ),
  Theatre(
    id: 'skyline-multiplex',
    name: 'Skyline Multiplex',
    description: 'Late night shows, 3D screens, and family lounge seating.',
    city: 'Pune',
    pincode: 411045,
    address: 'Baner High Street, Pune',
    movieIds: ['orbit-nine', 'laugh-track-live', 'city-of-stars'],
    formats: ['2D', '3D', 'Dolby'],
    distance: '6.8 km',
  ),
];

List<Theatre> sampleTheatresForMovie(String movieId) {
  return sampleTheatres
      .where((theatre) => theatre.movieIds.contains(movieId))
      .toList(growable: false);
}
