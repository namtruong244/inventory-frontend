import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_service.dart';

/// What to do with a queued change after a replay attempt failed.
enum SyncFailure {
  /// Server unreachable or temporarily failing: keep the op and stop here.
  retry,

  /// Session no longer valid: keep the queue, stop and send the user to sign in.
  auth,

  /// The server answered with a business error (bad input, gone, conflict): give up on this op.
  reject,

  /// The op itself is broken (parse/cast error): count attempts, then park it.
  poison,
}

/// Replays an op this many times before a poison op is parked as failed.
const maxPoisonAttempts = 3;

SyncFailure classifySyncError(Object e) {
  if (e is ApiException) {
    final s = e.statusCode;
    if (e.code == 'INVALID_JSON_RESPONSE') return SyncFailure.retry;
    if (s == 401) return SyncFailure.auth;
    if (s >= 500 || s == 408 || s == 429) return SyncFailure.retry;
    return SyncFailure.reject;
  }
  if (e is SocketException ||
      e is TimeoutException ||
      e is http.ClientException ||
      e is HandshakeException) {
    return SyncFailure.retry;
  }
  return SyncFailure.poison;
}

/// True when [e] means the server could not be reached or answered unusably.
bool isNetworkError(Object e) => classifySyncError(e) == SyncFailure.retry;
