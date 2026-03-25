/// Represents the AI-generated portfolio analysis report
/// Mirrors the data structure returned by POST /portfolio/report/{userId}/generate
class PortfolioReport {
  final DateTime? generatedAt;
  final double portfolioValueVnd;
  final double totalReturnPct;
  final String bestPerformer;
  final double diversificationScore;
  final List<String> alerts;
  final String recommendationSummary;
  final List<TradeRecommendation> tradeRecommendations;
  final List<AssetAllocation> allocation;
  final List<AssetPerformance> performance;
  final Map<String, dynamic>? riskMetrics;
  final List<TradingSignal> tradingSignals;
  final String? explanation;

  const PortfolioReport({
    this.generatedAt,
    this.portfolioValueVnd = 0,
    this.totalReturnPct = 0,
    this.bestPerformer = '',
    this.diversificationScore = 0,
    this.alerts = const [],
    this.recommendationSummary = '',
    this.tradeRecommendations = const [],
    this.allocation = const [],
    this.performance = const [],
    this.riskMetrics,
    this.tradingSignals = const [],
    this.explanation,
  });

  factory PortfolioReport.fromJson(Map<String, dynamic> json) {
    return PortfolioReport(
      generatedAt: json['generated_at'] != null
          ? DateTime.tryParse(json['generated_at'].toString())
          : null,
      portfolioValueVnd: _toDouble(json['portfolio_value_vnd']),
      totalReturnPct: _toDouble(json['total_return_pct']),
      bestPerformer: json['best_performer']?.toString() ?? '',
      diversificationScore: _toDouble(json['diversification_score']),
      alerts: (json['alerts'] as List?)?.map((a) => a.toString()).toList() ?? [],
      recommendationSummary: json['recommendation_summary']?.toString() ?? '',
      tradeRecommendations: (json['trade_recommendations'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(TradeRecommendation.fromJson)
              .toList() ??
          [],
      allocation: (json['allocation'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(AssetAllocation.fromJson)
              .toList() ??
          [],
      performance: (json['performance'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(AssetPerformance.fromJson)
              .toList() ??
          [],
      riskMetrics: json['risk_metrics'] as Map<String, dynamic>?,
      tradingSignals: (json['trading_signals'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(TradingSignal.fromJson)
              .toList() ??
          [],
      explanation: json['explanation']?.toString(),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}

class TradeRecommendation {
  final String asset;
  final String action; // BUY | SELL | HOLD
  final String urgency; // HIGH | NEUTRAL | LOW
  final double conviction;
  final String rationale;
  final String sizeHint;

  const TradeRecommendation({
    required this.asset,
    required this.action,
    this.urgency = 'NEUTRAL',
    this.conviction = 0.5,
    this.rationale = '',
    this.sizeHint = '',
  });

  factory TradeRecommendation.fromJson(Map<String, dynamic> json) {
    return TradeRecommendation(
      asset: json['asset']?.toString() ?? '',
      action: json['action']?.toString() ?? 'HOLD',
      urgency: json['urgency']?.toString() ?? 'NEUTRAL',
      conviction: _toDouble(json['conviction']),
      rationale: json['rationale']?.toString() ?? '',
      sizeHint: json['size_hint']?.toString() ?? '',
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}

class AssetAllocation {
  final String asset;
  final double weight;
  final double valueVnd;
  final double quantity;
  final String unitSymbol;

  const AssetAllocation({
    required this.asset,
    this.weight = 0,
    this.valueVnd = 0,
    this.quantity = 0,
    this.unitSymbol = '',
  });

  factory AssetAllocation.fromJson(Map<String, dynamic> json) {
    return AssetAllocation(
      asset: json['asset']?.toString() ?? '',
      weight: _toDouble(json['weight']),
      valueVnd: _toDouble(json['value_vnd']),
      quantity: _toDouble(json['quantity']),
      unitSymbol: json['unit_symbol']?.toString() ?? '',
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}

class AssetPerformance {
  final String asset;
  final double entryPrice;
  final double currentPrice;
  final double profitLoss;
  final double returnPct;

  const AssetPerformance({
    required this.asset,
    this.entryPrice = 0,
    this.currentPrice = 0,
    this.profitLoss = 0,
    this.returnPct = 0,
  });

  factory AssetPerformance.fromJson(Map<String, dynamic> json) {
    return AssetPerformance(
      asset: json['asset']?.toString() ?? '',
      entryPrice: _toDouble(json['entry_price']),
      currentPrice: _toDouble(json['current_price']),
      profitLoss: _toDouble(json['profit_loss']),
      returnPct: _toDouble(json['return_pct']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}

class TradingSignal {
  final String asset;
  final String signal; // BUY | SELL | HOLD
  final double rsiValue;
  final String explanation;
  final bool expanded;

  const TradingSignal({
    required this.asset,
    this.signal = 'HOLD',
    this.rsiValue = 50,
    this.explanation = '',
    this.expanded = false,
  });

  TradingSignal copyWith({bool? expanded}) {
    return TradingSignal(
      asset: asset,
      signal: signal,
      rsiValue: rsiValue,
      explanation: explanation,
      expanded: expanded ?? this.expanded,
    );
  }

  factory TradingSignal.fromJson(Map<String, dynamic> json) {
    return TradingSignal(
      asset: json['asset']?.toString() ?? '',
      signal: json['signal']?.toString() ?? 'HOLD',
      rsiValue: _toDouble(json['rsi_value'] ?? json['rsi']),
      explanation: json['explanation']?.toString() ?? '',
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}
