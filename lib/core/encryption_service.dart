import 'package:encrypt/encrypt.dart' as encrypt;

/// Handles AES-256 Encryption and Decryption for the application.
class EncryptionService {
  // AES-256 requires a 32-byte key. 
  // In a production app, this key should be derived from the user's Master PIN using PBKDF2,
  // or stored securely in the device's Keystore/Keychain.
  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  
  // Initialization Vector (IV) ensures identical plaintexts encrypt to different ciphertexts.
  static final _iv = encrypt.IV.fromUtf8('my16lengthivsecr');
  
  // Create the AES encrypter instance
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));

  /// Encrypts plain text and returns a Base64 encoded string
  static String encryptData(String plainText) {
    if (plainText.isEmpty) return '';
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypts a Base64 encoded string back to plain text
  static String decryptData(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    try {
      final decrypted = _encrypter.decrypt(encrypt.Encrypted.fromBase64(encryptedText), iv: _iv);
      return decrypted;
    } catch (e) {
      return 'Decryption Error';
    }
  }
}