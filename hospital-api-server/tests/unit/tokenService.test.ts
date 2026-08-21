import { test, describe } from 'node:test';
import assert from 'node:assert';

describe('Case ID & Token Formatting Logic', () => {
  test('formats sequential case numbers as U-00000', () => {
    const formatCaseNumber = (seq: number) => `U-${String(seq).padStart(5, '0')}`;

    assert.strictEqual(formatCaseNumber(1), 'U-00001');
    assert.strictEqual(formatCaseNumber(27), 'U-00027');
    assert.strictEqual(formatCaseNumber(999), 'U-00999');
    assert.strictEqual(formatCaseNumber(10000), 'U-10000');
  });

  test('validates 10-digit Indian phone numbers', () => {
    const isValidPhone = (phone: string) => /^\d{10}$/.test(phone.trim());

    assert.strictEqual(isValidPhone('9876543210'), true);
    assert.strictEqual(isValidPhone('12345'), false);
    assert.strictEqual(isValidPhone('abcdefghij'), false);
    assert.strictEqual(isValidPhone(' 9876543210 '), true);
  });

  test('queue status mapping matches patient-facing principles', () => {
    const getPatientFacingStatus = (peopleBefore: number) => {
      if (peopleBefore === 0) return 'YOUR_TURN';
      if (peopleBefore <= 2) return 'ALMOST_TURN';
      return 'WAITING';
    };

    assert.strictEqual(getPatientFacingStatus(5), 'WAITING');
    assert.strictEqual(getPatientFacingStatus(2), 'ALMOST_TURN');
    assert.strictEqual(getPatientFacingStatus(1), 'ALMOST_TURN');
    assert.strictEqual(getPatientFacingStatus(0), 'YOUR_TURN');
  });
});
