import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/error/network_exception.dart';
import 'package:cinecatalog/core/network/failure_mapper.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

/// Runs a datasource call and turns every way it can fail into a [Failure].
///
/// Repository implementations wrap each call in this, so nothing above the
/// data layer ever sees a [DioException] or a JSON cast error.
Future<Either<Failure, T>> guardRequest<T>(Future<T> Function() request) async {
  try {
    return Right(await request());
  } on DioException catch (e) {
    return Left(failureFromDio(e));
  } on NetworkException catch (e) {
    return Left(failureFromNetwork(e));
  } on FormatException catch (e) {
    return Left(ParsingFailure(e.message));
  }
}

/// Parses a JSON body, reporting any shape mismatch as a [FormatException]
/// so [guardRequest] maps it to [ParsingFailure].
T parseJson<T>(Object? data, T Function(Map<String, dynamic> json) parse) {
  if (data is! Map<String, dynamic>) {
    throw FormatException('Expected a JSON object, got ${data.runtimeType}');
  }
  try {
    return parse(data);
    // A wrong type anywhere in the payload surfaces as a TypeError from the
    // casts in `fromJson`; this is the one place that turns it into data.
    // ignore: avoid_catching_errors
  } on TypeError catch (e) {
    throw FormatException('Unexpected TMDB payload: $e');
  }
}
