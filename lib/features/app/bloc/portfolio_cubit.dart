import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/models/portfolio_report.dart';
import 'package:my_flutter_app/services/portfolio_service.dart';
import 'package:my_flutter_app/services/notification_service.dart';

class PortfolioState {
  final bool isLoading;
  final String? error;
  final double totalWealth;
  final double totalProfitLoss;
  final double totalProfitLossPercentage;
  final List<dynamic> holdings;
  // AI Analysis state
  final PortfolioReport? report;
  final bool isAnalyzing;
  final String? analyzeError;
  final bool reportLoaded;

  PortfolioState({
    required this.isLoading,
    this.error,
    required this.totalWealth,
    required this.totalProfitLoss,
    required this.totalProfitLossPercentage,
    required this.holdings,
    this.report,
    this.isAnalyzing = false,
    this.analyzeError,
    this.reportLoaded = false,
  });

  factory PortfolioState.initial() {
    return PortfolioState(
      isLoading: false,
      totalWealth: 0,
      totalProfitLoss: 0,
      totalProfitLossPercentage: 0,
      holdings: [],
    );
  }

  PortfolioState copyWith({
    bool? isLoading,
    String? error,
    double? totalWealth,
    double? totalProfitLoss,
    double? totalProfitLossPercentage,
    List<dynamic>? holdings,
    PortfolioReport? report,
    bool? isAnalyzing,
    String? analyzeError,
    bool? reportLoaded,
    bool clearError = false,
    bool clearAnalyzeError = false,
    bool clearReport = false,
  }) {
    return PortfolioState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      totalWealth: totalWealth ?? this.totalWealth,
      totalProfitLoss: totalProfitLoss ?? this.totalProfitLoss,
      totalProfitLossPercentage: totalProfitLossPercentage ?? this.totalProfitLossPercentage,
      holdings: holdings ?? this.holdings,
      report: clearReport ? null : (report ?? this.report),
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      analyzeError: clearAnalyzeError ? null : (analyzeError ?? this.analyzeError),
      reportLoaded: reportLoaded ?? this.reportLoaded,
    );
  }
}

class PortfolioCubit extends Cubit<PortfolioState> {
  final PortfolioService _service = PortfolioService();

  PortfolioCubit() : super(PortfolioState.initial());

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  List<Map<String, dynamic>> _normalizeHoldings(dynamic rawHoldings) {
    if (rawHoldings is! List) return const [];

    return rawHoldings
        .whereType<Map>()
        .map((item) {
          final map = item.cast<String, dynamic>();
          final avgCost = _toDouble(
            map['avgCost'] ?? map['averageCost'] ?? map['avgEntryPrice'] ?? map['entryPrice'],
          );

          return {
            ...map,
            'assetName': map['assetName'] ?? map['asset'] ?? map['name'] ?? 'Asset',
            'unitSymbol': map['unitSymbol'] ?? map['unit'] ?? '',
            'currencyCode': map['currencyCode'] ?? map['currency'] ?? 'VND',
            'entryPrice': avgCost,
            'marketValue': _toDouble(map['marketValue'] ?? map['currentValue']),
            'profitLoss': _toDouble(map['profitLoss'] ?? map['pnl']),
            'profitLossPercentage':
                _toDouble(map['profitLossPercentage'] ?? map['pnlPercentage']),
          };
        })
        .toList();
  }

  Future<void> load({String? userId}) async {
    final oldProfitLoss = state.totalProfitLoss;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final data = await _service.getPortfolioSummary(userId: userId);
      if (data.isNotEmpty) {
        final holdings = _normalizeHoldings(data['holdings']);
        final newProfitLoss = _toDouble(data['totalProfitLoss']);
        final totalWealth = _toDouble(data['totalWealth']);
        final totalProfitLossPct = _toDouble(data['totalProfitLossPercentage']);

        emit(state.copyWith(
          isLoading: false,
          totalWealth: totalWealth,
          totalProfitLoss: newProfitLoss,
          totalProfitLossPercentage: totalProfitLossPct,
          holdings: holdings,
        ));

        if (newProfitLoss != oldProfitLoss && oldProfitLoss != 0) {
          final diff = newProfitLoss - oldProfitLoss;
          final direction = diff > 0 ? 'tăng' : 'giảm';
          final absDiff = diff.abs().toStringAsFixed(2);

          NotificationService.showQuickNotification(
            'Biến động tài sản',
            'Tổng lợi nhuận của bạn vừa $direction \$${absDiff}!',
          );
        }
      } else {
        emit(state.copyWith(isLoading: false, error: 'No data found'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Loads the last cached AI report — GET /portfolio/report/{userId}
  Future<void> loadReport({required String userId}) async {
    if (state.reportLoaded) return;
    try {
      final report = await _service.fetchLatestReport(userId: userId);
      emit(state.copyWith(report: report, reportLoaded: true));
    } catch (_) {
      emit(state.copyWith(reportLoaded: true));
    }
  }

  /// Triggers AI generation — POST /portfolio/report/{userId}/generate
  Future<void> generateAnalysis({required String userId}) async {
    emit(state.copyWith(isAnalyzing: true, clearAnalyzeError: true));
    try {
      final report = await _service.generateAIAnalysis(userId: userId);
      emit(state.copyWith(isAnalyzing: false, report: report, reportLoaded: true));
    } catch (e) {
      final msg = e.toString();
      final isNoPortfolio = msg.contains('404') || msg.contains('No portfolio');
      emit(state.copyWith(
        isAnalyzing: false,
        analyzeError: isNoPortfolio ? 'no_portfolio' : 'generic',
      ));
    }
  }

  Future<bool> addAsset({
    required String userId,
    required String assetName,
    required double quantity,
    required String unitSymbol,
    required double entryPrice,
    required String currencyCode,
    DateTime? transactionDate,
  }) async {
    final success = await _service.addAsset(
      userId: userId,
      assetName: assetName,
      quantity: quantity,
      unitSymbol: unitSymbol,
      entryPrice: entryPrice,
      currencyCode: currencyCode,
      transactionDate: transactionDate,
    );
    if (success) await load(userId: userId);
    return success;
  }

  Future<bool> updateAsset({
    required String userId,
    String? assetName,
    double? quantity,
    String? unitSymbol,
    double? entryPrice,
    String? currencyCode,
    DateTime? transactionDate,
  }) async {
    final success = await _service.updateAsset(
      userId: userId,
      assetName: assetName,
      quantity: quantity,
      unitSymbol: unitSymbol,
      entryPrice: entryPrice,
      currencyCode: currencyCode,
      transactionDate: transactionDate,
    );
    if (success) await load(userId: userId);
    return success;
  }

  Future<bool> deleteAsset({required String userId, required String assetName}) async {
    final success = await _service.deleteAsset(userId: userId, assetName: assetName);
    if (success) await load(userId: userId);
    return success;
  }
}
