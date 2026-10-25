import '../services/api_service.dart';
import '../services/sync_policy.dart';
import '../l10n/l10n_ext.dart';

/// Turns any thrown error into a sentence a person can act on.
///
/// Raw exception text (`ApiException [AUTH_FAILED] (401): ...`) never reaches
/// the UI. [fallback] is used when nothing more specific is known.
String friendlyError(Object error, {String? fallback}) {
  fallback ??= AppL10n.current.somethingWentWrongPleaseTry;
  if (error is ApiException) {
    switch (error.code) {
      case 'AUTH_FAILED':
        return AppL10n.current.incorrectEmailOrPassword;
      case 'TOKEN_EXPIRED_OR_INVALID':
      case 'TOKEN_REVOKED':
      case 'UNAUTHORIZED':
        return AppL10n.current.yourSessionHasExpiredPlease;
      case 'NOT_FOUND':
        return AppL10n.current.thatItemNoLongerExists;
      case 'CONFLICT':
        return AppL10n.current.thisWasChangedSomewhereElse;
    }
    final status = error.statusCode;
    if (status == 429) return AppL10n.current.tooManyAttemptsPleaseWait;
    if (status >= 500) return AppL10n.current.theServerIsBusyRight;
    if (status == 401 || status == 403) {
      return AppL10n.current.yourSessionHasExpiredPlease;
    }
    // Backend messages for 4xx are written for users (validation, duplicates).
    final message = error.message.trim();
    if (status >= 400 && message.isNotEmpty && message.length <= 140) return message;
    return fallback;
  }
  if (isNetworkError(error)) {
    return AppL10n.current.canTReachTheServer;
  }
  return fallback;
}
