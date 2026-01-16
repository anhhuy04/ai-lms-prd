import 'package:ai_mls/core/utils/validation_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Registration Integration Tests', () {
    test('Test name capitalization for registration', () {
      // Test various name formats
      expect(ValidationUtils.capitalizeName('nguyen van a'), 'Nguyen Van A');
      expect(ValidationUtils.capitalizeName('tRan Thi b'), 'Tran Thi B');
      expect(ValidationUtils.capitalizeName('le van c'), 'Le Van C');
      expect(ValidationUtils.capitalizeName('NGUYEN VAN D'), 'Nguyen Van D');
    });

    test('Test phone number validation', () {
      // Valid phone numbers
      expect(ValidationUtils.isValidPhoneNumber('0123456789'), true);
      expect(ValidationUtils.isValidPhoneNumber('0987654321'), true);
      expect(ValidationUtils.isValidPhoneNumber('01234567890'), true);

      // Invalid phone numbers
      expect(ValidationUtils.isValidPhoneNumber('123456789'), false); // too short
      expect(ValidationUtils.isValidPhoneNumber('012345678901'), false); // too long
      expect(ValidationUtils.isValidPhoneNumber('012345678a'), false); // contains letters
      expect(ValidationUtils.isValidPhoneNumber(''), false); // empty
    });

    test('Test email validation', () {
      // Valid emails
      expect(ValidationUtils.isValidEmail('test@example.com'), true);
      expect(ValidationUtils.isValidEmail('user.name@domain.co.uk'), true);

      // Invalid emails
      expect(ValidationUtils.isValidEmail('test@example'), false);
      expect(ValidationUtils.isValidEmail('test@'), false);
      expect(ValidationUtils.isValidEmail('test'), false);
      expect(ValidationUtils.isValidEmail(''), false);
    });

    test('Test password validation', () {
      // Valid passwords
      expect(ValidationUtils.isValidPassword('password123'), true);
      expect(ValidationUtils.isValidPassword('123456'), true);

      // Invalid passwords
      expect(ValidationUtils.isValidPassword('pass'), false);
      expect(ValidationUtils.isValidPassword('12345'), false);
      expect(ValidationUtils.isValidPassword(''), false);
    });
  });
}