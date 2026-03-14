import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/services/api_service.dart';

class AnalyticsState {
  final bool isLoading;
  final String? error;
  final Map<String, double> allocation;

  AnalyticsState({
    required this.isLoading,
    this.error,
    required this.allocation,
  });

  factory AnalyticsState.initial() {
    return AnalyticsState(
      isLoading: false,
      allocation: {},
    );
  }

  AnalyticsState copyWith({
    bool? isLoading,
    String? error,
    Map<String, double>? allocation,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      allocation: allocation ?? this.allocation,
    );
  }
}

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final ApiService _api = ApiService();

  AnalyticsCubit() : super(AnalyticsState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await _api.get('/analytics/allocation', authorized: true);
      if (response is Map<String, dynamic>) {
        final Map<String, double> allocation = {};
        response.forEach((key, value) {
          allocation[key] = (value as num).toDouble();
        });
        emit(state.copyWith(isLoading: false, allocation: allocation));
      } else {
        emit(state.copyWith(isLoading: false, error: 'Failed to load allocation data'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
