import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

String generateSalt([int length = 16]) {
  final rand = Random.secure();
  final values = List<int>.generate(length, (i) => rand.nextInt(256));
  return base64Url.encode(values);
}

String hashPin(String pin, String salt) {
  final bytes = utf8.encode(salt + pin); // concat salt + pin
  final digest = sha256.convert(bytes);
  return digest.toString();
}
