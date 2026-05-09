import 'dart:async';

class SessionManager {
  static final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();

  static Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  /// Guard flag to prevent infinite loop:
  /// signOut() → signedOut event → notifySessionExpired() → signOut() → ...
  static bool _isHandlingExpiry = false;

  /// Whether a session expiry is currently being handled
  static bool get isHandlingExpiry => _isHandlingExpiry;

  static void notifySessionExpired() {
    if (_isHandlingExpiry) return; // Prevent re-entrancy
    if (!_sessionExpiredController.isClosed) {
      _isHandlingExpiry = true;
      _sessionExpiredController.add(null);
    }
  }

  /// Reset the handling flag — called after user successfully logs in again
  static void resetExpiryFlag() {
    _isHandlingExpiry = false;
  }

  static void dispose() {
    _sessionExpiredController.close();
  }
}
