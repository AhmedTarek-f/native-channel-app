enum Status { initial, loading, success, failure }

class StateStatus<T> {
  final Status status;
  final T? data;
  final String? errorMessage;

  const StateStatus._({required this.status, this.data, this.errorMessage});

  const StateStatus.initial() : this._(status: Status.initial);
  const StateStatus.loading() : this._(status: Status.loading);
  const StateStatus.success(T data)
    : this._(status: Status.success, data: data);
  const StateStatus.failure(String error)
    : this._(status: Status.failure, errorMessage: error);

  bool get isInitial => status == Status.initial;
  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isFailure => status == Status.failure;
}
