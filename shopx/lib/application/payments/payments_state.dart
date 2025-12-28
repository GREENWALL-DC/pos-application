import 'package:equatable/equatable.dart';

class PaymentsState extends Equatable {
  final bool isLoading;
  final String? error;

  const PaymentsState({
    this.isLoading = false,
    this.error,
  });

  PaymentsState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return PaymentsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, error];
}
