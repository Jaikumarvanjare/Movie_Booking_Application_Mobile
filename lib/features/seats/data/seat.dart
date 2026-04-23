class Seat {
  const Seat({
    required this.rowNumber,
    required this.seatNumber,
    required this.isBooked,
  });

  final int rowNumber;
  final int seatNumber;
  final bool isBooked;

  String get id => '$rowNumber-$seatNumber';
  String get label => '${String.fromCharCode(64 + rowNumber)}$seatNumber';
}

List<Seat> sampleSeatsForShow(String showId) {
  final bookedSeats = _sampleBookedSeatIds[showId] ?? const <String>{};

  return [
    for (var row = 1; row <= 5; row++)
      for (var number = 1; number <= 8; number++)
        Seat(
          rowNumber: row,
          seatNumber: number,
          isBooked: bookedSeats.contains('$row-$number'),
        ),
  ];
}

const _sampleBookedSeatIds = {
  'show-midnight-nova-1030': {'1-3', '1-4', '2-7', '3-2', '4-5'},
  'show-midnight-nova-1845': {'1-1', '2-2', '2-3', '5-8'},
  'show-midnight-royal-2100': {'3-3', '3-4', '4-1'},
  'show-stars-nova-1630': {'1-6', '2-6', '3-6'},
  'show-stars-skyline-2000': {'2-1', '2-2', '4-4'},
  'show-orbit-nova-1320': {'1-8', '2-8', '5-1', '5-2'},
  'show-orbit-skyline-1935': {'3-7', '3-8', '4-7', '4-8'},
};
