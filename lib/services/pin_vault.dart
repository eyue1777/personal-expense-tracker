import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinVault {
  static const _storage = FlutterSecureStorage();
  static const _kPin = 'user_pin';

  Future<void> savePin(String pin) async {
    await _storage.write(key: _kPin, value: pin);
  }

  Future<String?> getPin() async {
    return await _storage.read(key: _kPin);
  }

  Future<bool> hasPin() async {
    String? pin = await getPin();
    return pin != null;
  }

  // FIXED: Added clearPin
  Future<void> clearPin() async {
    await _storage.delete(key: _kPin);
  }
}
