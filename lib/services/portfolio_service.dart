import 'package:my_flutter_app/models/portfolio_report.dart';
import 'package:my_flutter_app/services/api_service.dart';
import 'dart:convert';

class PortfolioService {
  final ApiService _api = ApiService();

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  String _formatDateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  bool _isUuid(String value) => _uuidRegex.hasMatch(value);

  Future<Map<String, double>> _fetchBenchmarks() async {
    double goldSell = 0;
    double silverSell = 0;
    double usdToVnd = 0;

    try {
      final goldRes = await _api.get('/prices/vn-all/gold/1d', authorized: true);
      if (goldRes is List && goldRes.isNotEmpty) {
        final latest = goldRes.last as Map<String, dynamic>;
        final raw = (latest['sellPrice'] ?? latest['sell'] ?? 0) as num;
        goldSell = raw.toDouble();
      }
    } catch (_) {}

    try {
      final silverRes = await _api.get('/prices/vn-all/silver/1w', authorized: true);
      if (silverRes is List && silverRes.isNotEmpty) {
        final latest = silverRes.last as Map<String, dynamic>;
        final raw = (latest['sellPrice'] ?? latest['sell'] ?? 0) as num;
        silverSell = raw.toDouble();
      }
    } catch (_) {}

    try {
      final usdRes = await _api.get('/prices/usd/1w', authorized: true);
      if (usdRes is List && usdRes.isNotEmpty) {
        final latest = usdRes.last as Map<String, dynamic>;
        final raw = (latest['sellPrice'] ?? latest['sell'] ?? 0) as num;
        usdToVnd = raw.toDouble();
      }
    } catch (_) {}

    return {
      'goldSell': goldSell,
      'silverSell': silverSell,
      'usdToVnd': usdToVnd,
    };
  }

  String _tryResolveUserId(String userId) {
    if (_isUuid(userId)) return userId;

    final token = ApiService.accessToken;
    if (token == null || token.isEmpty) return userId;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return userId;

      final normalized = base64Url.normalize(parts[1]);
      final payloadString = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(payloadString) as Map<String, dynamic>;

      final candidates = [
        payload['userId'],
        payload['user_id'],
        payload['id'],
        payload['sub'],
        payload['uid'],
      ];

      for (final c in candidates) {
        final candidate = c?.toString() ?? '';
        if (_isUuid(candidate)) {
          return candidate;
        }
      }
    } catch (_) {
      // Ignore JWT parsing failures and keep original userId.
    }

    return userId;
  }

  Future<String> _resolveUserId(String userId) async {
    final fromToken = _tryResolveUserId(userId);
    if (_isUuid(fromToken)) return fromToken;

    try {
      final me = await _api.get('/me', authorized: true);
      if (me is Map<String, dynamic>) {
        final candidates = [
          me['id'],
          me['userId'],
          me['user_id'],
          me['sub'],
          me['uid'],
        ];
        for (final c in candidates) {
          final candidate = c?.toString() ?? '';
          if (_isUuid(candidate)) {
            return candidate;
          }
        }
      }
    } catch (_) {
      // Ignore and fallback.
    }

    return fromToken;
  }

  Future<Map<String, dynamic>> getPortfolioSummary({String? userId}) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        final resolvedUserId = await _resolveUserId(userId);
        final benchmark = await _fetchBenchmarks();
        final goldSell = benchmark['goldSell'] ?? 0;
        final silverSell = benchmark['silverSell'] ?? 0;
        final usdToVnd = benchmark['usdToVnd'] ?? 0;
        final response = await _api.get('/portfolio/$resolvedUserId', authorized: true);
        if (response is List) {
          final holdings = response
              .whereType<Map<String, dynamic>>()
              .map((item) {
                final assetName = (item['asset'] ?? 'Asset').toString();
                final quantity = (item['quantity'] as num?)?.toDouble() ?? 0;
                final entryPrice = (item['entryPrice'] as num?)?.toDouble() ?? 0;
                final currency = (item['currency'] ?? 'VND').toString().toUpperCase();
                final isGold = assetName.toLowerCase().contains('gold');
                final currentPerUnitVnd = isGold ? goldSell : silverSell;

                double currentPerUnit = currentPerUnitVnd;
                if (currency == 'USD' && usdToVnd > 0) {
                  currentPerUnit = currentPerUnitVnd / usdToVnd;
                }

                final marketValue = quantity * (currentPerUnit > 0 ? currentPerUnit : entryPrice);
                final costValue = quantity * entryPrice;
                final profitLoss = marketValue - costValue;
                final profitLossPercentage = costValue > 0 ? (profitLoss / costValue) * 100 : 0;

                return {
                  'assetName': assetName,
                  'quantity': quantity,
                  'unitSymbol': item['unit'] ?? '',
                  'entryPrice': entryPrice,
                  'currencyCode': currency,
                  'marketValue': marketValue,
                  'profitLoss': profitLoss,
                  'profitLossPercentage': profitLossPercentage,
                };
              })
              .toList();

          double totalWealth = 0;
          double totalProfitLoss = 0;
          for (final h in holdings) {
            totalWealth += (h['marketValue'] as num?)?.toDouble() ?? 0;
            totalProfitLoss += (h['profitLoss'] as num?)?.toDouble() ?? 0;
          }

          return {
            'totalWealth': totalWealth,
            'totalProfitLoss': totalProfitLoss,
            'totalProfitLossPercentage': totalWealth > 0 ? (totalProfitLoss / totalWealth) * 100 : 0,
            'holdings': holdings,
          };
        }
      }
    } catch (e) {
      print('❌ Error getting portfolio: $e');
    }
    return {};
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
    final resolvedUserId = await _resolveUserId(userId);
    try {
      final Map<String, dynamic> body = {
        'userId': resolvedUserId,
        'asset': assetName,
        'quantity': quantity,
        'unit': unitSymbol,
        'entryPrice': entryPrice,
        'currency': currencyCode,
      };
      await _api.post('/portfolio', body, authorized: true);
      return true;
    } catch (e) {
      // Fallback for old payload contract
      try {
        final Map<String, dynamic> body = {
          'assetName': assetName,
          'quantity': quantity,
          'unitSymbol': unitSymbol,
          'entryPrice': entryPrice,
          'currencyCode': currencyCode,
          if (transactionDate != null) 'transactionDate': _formatDateOnly(transactionDate),
        };
        await _api.put('/portfolio/$resolvedUserId', body, authorized: true);
        return true;
      } catch (fallbackError) {
        print('❌ Error adding asset: $fallbackError');
        return false;
      }
    }
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
    final resolvedUserId = await _resolveUserId(userId);
    try {
      final Map<String, dynamic> body = {
        'userId': resolvedUserId,
        if (assetName != null) 'asset': assetName,
        if (quantity != null) 'quantity': quantity,
        if (unitSymbol != null) 'unit': unitSymbol,
        if (entryPrice != null) 'entryPrice': entryPrice,
        if (currencyCode != null) 'currency': currencyCode,
      };
      await _api.post('/portfolio', body, authorized: true);
      return true;
    } catch (e) {
      // Fallback for old payload contract
      try {
        final Map<String, dynamic> body = {
          if (assetName != null) 'assetName': assetName,
          if (quantity != null) 'quantity': quantity,
          if (unitSymbol != null) 'unitSymbol': unitSymbol,
          if (entryPrice != null) 'entryPrice': entryPrice,
          if (currencyCode != null) 'currencyCode': currencyCode,
          if (transactionDate != null) 'transactionDate': _formatDateOnly(transactionDate),
        };
        await _api.put('/portfolio/$resolvedUserId', body, authorized: true);
        return true;
      } catch (fallbackError) {
        print('❌ Error updating asset: $fallbackError');
        return false;
      }
    }
  }

  Future<bool> deleteAsset({required String userId, required String assetName}) async {
    final resolvedUserId = await _resolveUserId(userId);
    try {
      final encodedAsset = Uri.encodeComponent(assetName);
      await _api.delete('/portfolio/$resolvedUserId/$encodedAsset', authorized: true);
      return true;
    } catch (e) {
      // Fallback old route
      try {
        await _api.delete('/portfolio/$resolvedUserId', authorized: true);
        return true;
      } catch (fallbackError) {
        print('❌ Error deleting asset: $fallbackError');
        return false;
      }
    }
  }

  // Legacy methods kept for compatibility in older call sites.
  Future<bool> updateAssetLegacy({
    required int id,
    String? assetName,
    double? quantity,
    String? unitSymbol,
    double? entryPrice,
    String? currencyCode,
    DateTime? transactionDate,
  }) async {
    try {
      final Map<String, dynamic> body = {
        if (assetName != null) 'assetName': assetName,
        if (quantity != null) 'quantity': quantity,
        if (unitSymbol != null) 'unitSymbol': unitSymbol,
        if (entryPrice != null) 'entryPrice': entryPrice,
        if (currencyCode != null) 'currencyCode': currencyCode,
        if (transactionDate != null)
          'transactionDate': _formatDateOnly(transactionDate),
      };
      await _api.put('/portfolio/$id', body, authorized: true);
      return true;
    } catch (e) {
      print('❌ Error updating asset (legacy): $e');
      return false;
    }
  }

  Future<bool> deleteAssetLegacy(int id) async {
    try {
      await _api.delete('/portfolio/$id', authorized: true);
      return true;
    } catch (e) {
      print('❌ Error adding asset: $e');
      return false;
    }
  }

  /// GET /portfolio/report/{userId} — fetch the last AI-generated report
  Future<PortfolioReport?> fetchLatestReport({required String userId}) async {
    final resolvedUserId = await _resolveUserId(userId);
    try {
      final response = await _api.get('/portfolio/report/$resolvedUserId', authorized: true);
      if (response is Map<String, dynamic>) {
        return PortfolioReport.fromJson(response);
      }
      return null;
    } catch (e) {
      if (e.toString().contains('404')) return null;
      rethrow;
    }
  }

  /// POST /portfolio/report/{userId}/generate — trigger AI analysis
  Future<PortfolioReport> generateAIAnalysis({required String userId}) async {
    final resolvedUserId = await _resolveUserId(userId);
    final response = await _api.post(
      '/portfolio/report/$resolvedUserId/generate',
      {}, // empty body, matches FE
      authorized: true,
    );
    if (response is Map<String, dynamic>) {
      return PortfolioReport.fromJson(response);
    }
    throw Exception('Invalid response from AI analysis endpoint.');
  }
}

