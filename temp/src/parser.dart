import 'context.dart';
import 'validator.dart';

extension DsvParse<T> on DsvValidator<T> {
  /// Parse the given [value] using the [DsvValidator] and return the result.
  ///
  /// If your validators include asynchronous validators, use `parse.async()`
  /// instead.
  DsvParser<T> get parse => _Parser(this);
}

abstract interface class DsvParser<T> {
  /// Synchronously parse the given [value] using the [DsvValidator] and return
  /// the result.
  T call(Object? value);

  /// Asynchronously parse the given [value] using the [DsvValidator] and
  /// return the result.
  Future<T> async(Object? value);
}

class _Parser<T> implements DsvParser<T> {
  final DsvValidator<T> validator;

  const _Parser(this.validator);

  @override
  Future<T> async(Object? value) {
    final context = _Context(isAsynchronous: true);
    final result = validator.handle(context, value);

    return Future.value(result);
  }

  @override
  T call(Object? value) {
    return validator.handle(_Context(isAsynchronous: false), value);
  }
}

class _Context implements DsvContext {
  /// Create a new context.
  const _Context({
    required this.isAsynchronous,
    this.parent,
    this.path,
  });

  @override
  final bool isAsynchronous;

  @override
  final DsvContext? parent;

  @override
  final String? path;

  @override
  DsvContext nest(String path) => _Context(
        isAsynchronous: isAsynchronous,
        parent: this,
        path: path,
      );
}