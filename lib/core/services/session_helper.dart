import 'dart:async';

class SessionManager {
  static final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();

  static Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  static void notifySessionExpired() {
    if (!_sessionExpiredController.isClosed) {
      _sessionExpiredController.add(null);
    }
  }

  static void dispose() {
    _sessionExpiredController.close();
  }
}
