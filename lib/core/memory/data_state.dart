import 'package:dartz/dartz.dart' as st;

import '../state/state.dart';

class DataState<T> {
  final State<st.Either<String, T>> state;
  final bool isFromCache;
  final bool hasConnection;

  const DataState({
    required this.state,
    this.isFromCache = false,
    this.hasConnection = true,
  });

  DataState<T> copyWith({
    State<st.Either<String, T>>? state,
    bool? isFromCache,
    bool? hasConnection,
    DateTime? lastUpdated,
    String? source,
  }) =>
      DataState<T>(
        state: state ?? this.state,
        isFromCache: isFromCache ?? this.isFromCache,
        hasConnection: hasConnection ?? this.hasConnection,
      );
}
