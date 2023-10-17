class Currency {
  final String code;
  final String symbol;

  Currency({
    required this.code,
    required this.symbol,
  });
}

final List<Currency> currencies = [
  Currency(code: 'USD', symbol: '\$'),
  Currency(code: 'EUR', symbol: '€'),
  Currency(code: 'GBP', symbol: '£'),
  // Add more currencies as needed
];

class UserAccountBalance {
  final double usdBalance;
  final double eurBalance;
  final double gbpBalance;

  UserAccountBalance({
    required this.usdBalance,
    required this.eurBalance,
    required this.gbpBalance,
  });
}
