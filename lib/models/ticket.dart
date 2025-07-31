class Ticket {
  String date;
  String ticketNumber;
  String contractor;
  String locations;
  String loads;
  double hours;
  double rate;

  Ticket({
    required this.date,
    required this.ticketNumber,
    required this.contractor,
    required this.locations,
    required this.loads,
    required this.hours,
    required this.rate,
  });

  double get total => hours * rate;
}
