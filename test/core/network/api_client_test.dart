import 'dart:convert';
import 'dart:typed_data';

import 'package:cinecatalog/core/error/failure.dart';
import 'package:cinecatalog/core/network/api_client.dart';
import 'package:cinecatalog/core/network/api_config.dart';
import 'package:cinecatalog/core/network/guard_request.dart';
import 'package:cinecatalog/core/network/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

/// Answers requests from [responses] in order (the last one repeats), or
/// throws [error]; remembers every request.
final class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({
    this.responses = const [(200, <String, dynamic>{})],
    this.error,
  });

  final List<(int, Object)> responses;
  final DioExceptionType? error;
  final requests = <RequestOptions>[];

  RequestOptions? get last => requests.lastOrNull;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (error case final type?) {
      throw DioException(requestOptions: options, type: type);
    }
    final (status, body) =
        responses[(requests.length - 1).clamp(0, responses.length - 1)];
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  // ApiClient reads its navigator key for the error toast.
  TestWidgetsFlutterBinding.ensureInitialized();

  const config = ApiConfig(
    environment: AppEnvironment.prod,
    language: 'id-ID',
    region: 'ID',
  );

  late List<SessionEndReason> unauthorized;
  late int maintenance;
  late int available;

  ApiClient build(_StubAdapter adapter, {String token = 'secret'}) {
    unauthorized = [];
    maintenance = 0;
    available = 0;
    return ApiClient(
      config,
      EnvTokenStorage(token),
      navigatorKey: GlobalKey<NavigatorState>(),
      onUnauthorized: unauthorized.add,
      onMaintenance: () => maintenance++,
      onServiceAvailable: () => available++,
      retryBackoff: Duration.zero,
      httpClientAdapter: adapter,
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> get(
    ApiClient client, [
    String path = '/movie/popular',
    Map<String, dynamic>? query,
  ]) => guardRequest(() => client.get(path, query: query, parser: (j) => j));

  test('sends the bearer token, base URL and language', () async {
    final adapter = _StubAdapter(
      responses: [
        (200, {'page': 1}),
      ],
    );

    final result = await get(build(adapter));

    expect(result.getRight().toNullable(), {'page': 1});
    expect(adapter.last!.headers['Authorization'], 'Bearer secret');
    expect(adapter.last!.uri.toString(), startsWith(config.baseUrl));
    expect(adapter.last!.queryParameters['language'], 'id-ID');
  });

  test('a missing token ends the session without a request', () async {
    final adapter = _StubAdapter();

    final result = await get(build(adapter, token: ''));

    expect(result.getLeft().toNullable(), isA<UnauthorizedFailure>());
    expect(adapter.requests, isEmpty);
    expect(unauthorized, [SessionEndReason.missingToken]);
  });

  test('a 401 ends the session as rejected', () async {
    final client = build(_StubAdapter(responses: [(401, {})]));

    final result = await get(client);

    expect(result.getLeft().toNullable(), isA<UnauthorizedFailure>());
    expect(unauthorized, [SessionEndReason.rejected]);
  });

  final cases = <String, (_StubAdapter Function(), Type)>{
    'timeout': (
      () => _StubAdapter(error: DioExceptionType.connectionTimeout),
      NetworkFailure,
    ),
    'no connection': (
      () => _StubAdapter(error: DioExceptionType.connectionError),
      NetworkFailure,
    ),
    '404': (() => _StubAdapter(responses: [(404, {})]), NotFoundFailure),
    '500': (() => _StubAdapter(responses: [(500, {})]), ServerFailure),
  };
  for (final MapEntry(key: name, value: (adapter, type)) in cases.entries) {
    test('$name maps to $type', () async {
      final failure = (await get(build(adapter()))).getLeft().toNullable();
      expect(failure.runtimeType, type);
    });
  }

  test('retries a 429 and returns the later success', () async {
    final adapter = _StubAdapter(
      responses: [
        (429, {}),
        (200, {'page': 1}),
      ],
    );

    final result = await get(build(adapter));

    expect(result.isRight(), isTrue);
    expect(adapter.requests, hasLength(2));
  });

  test('gives up after two retries with RateLimitFailure', () async {
    final adapter = _StubAdapter(responses: [(429, {})]);

    final result = await get(build(adapter));

    expect(result.getLeft().toNullable(), isA<RateLimitFailure>());
    expect(adapter.requests, hasLength(3), reason: '1 call + 2 retries');
  });

  test('503 reports maintenance once, the next success recovery', () async {
    final adapter = _StubAdapter(
      responses: [
        (503, {'status_message': 'Maintenance'}),
        (503, {}),
        (200, {}),
      ],
    );
    final client = build(adapter);

    final first = await get(client);
    await get(client);
    expect(first.getLeft().toNullable()?.message, 'Maintenance');
    expect(maintenance, 1);
    expect(available, 0);

    await get(client);
    expect(available, 1);
  });

  test('adds region to movie lists only', () async {
    final adapter = _StubAdapter();
    final client = build(adapter);

    await get(client, '/movie/now_playing');
    expect(adapter.last!.queryParameters['region'], 'ID');

    await get(client, '/tv/popular');
    expect(adapter.last!.queryParameters.containsKey('region'), isFalse);
  });

  test('keeps English trailers when appending videos', () async {
    final adapter = _StubAdapter();

    await get(build(adapter), '/movie/1', {
      'append_to_response': 'credits,videos',
    });

    expect(
      adapter.last!.queryParameters['include_video_language'],
      'id,en,null',
    );
  });

  test('a body that does not fit the parser becomes ParsingFailure', () async {
    final client = build(
      _StubAdapter(
        responses: [
          (200, {'id': 'nope'}),
        ],
      ),
    );

    final result = await guardRequest(
      () => client.get('/movie/1', parser: (j) => j['id'] as int),
    );

    expect(result.getLeft().toNullable(), isA<ParsingFailure>());
  });
}
