class AsyncState<T> {
  final T? data;
  final bool isLoading;
  final String? error;

  const AsyncState._({this.data, this.isLoading = false, this.error});

  const AsyncState.idle() : this._();
  const AsyncState.loading() : this._(isLoading: true);
  const AsyncState.success(T data) : this._(data: data);
  const AsyncState.failure(String error) : this._(error: error);

  bool get hasData => data != null;
  bool get hasError => error != null;
}
