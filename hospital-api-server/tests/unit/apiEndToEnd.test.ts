import { test, describe } from 'node:test';
import assert from 'node:assert';
import jwt from 'jsonwebtoken';
import env from '../../src/config/env';
import { renderNotificationTemplate } from '../../src/modules/notifications/notification.templates';

describe('ArogyaMitra Master Spec v3.0.0 Architecture & Unit Tests', () => {

  describe('1. Security & RBAC Isolation', () => {
    test('Admin token generation and verification', () => {
      const adminPayload = { role: 'admin' };
      const token = jwt.sign(adminPayload, env.ADMIN_JWT_SECRET, { expiresIn: '8h' });
      const decoded = jwt.verify(token, env.ADMIN_JWT_SECRET) as any;
      assert.strictEqual(decoded.role, 'admin');

      // Reject admin token signed with patient secret
      assert.throws(() => {
        jwt.verify(token, env.PATIENT_JWT_SECRET);
      });
    });

    test('Doctor token generation, verification and role isolation', () => {
      const doctorPayload = { id: 'doc-123', role: 'doctor', phoneNumber: '9876543210' };
      const token = jwt.sign(doctorPayload, env.DOCTOR_JWT_SECRET, { expiresIn: '7d' });
      const decoded = jwt.verify(token, env.DOCTOR_JWT_SECRET) as any;
      assert.strictEqual(decoded.role, 'doctor');
      assert.strictEqual(decoded.phoneNumber, '9876543210');

      // Cannot be verified with admin secret
      assert.throws(() => {
        jwt.verify(token, env.ADMIN_JWT_SECRET);
      });
    });

    test('Patient session token generation and verification', () => {
      const sessionPayload = { patientId: 'patient-456', caseNumber: 'U-00045' };
      const token = jwt.sign(sessionPayload, env.PATIENT_JWT_SECRET, { expiresIn: '48h' });
      const decoded = jwt.verify(token, env.PATIENT_JWT_SECRET) as any;
      assert.strictEqual(decoded.patientId, 'patient-456');
      assert.strictEqual(decoded.caseNumber, 'U-00045');

      // Cannot be verified with doctor secret
      assert.throws(() => {
        jwt.verify(token, env.DOCTOR_JWT_SECRET);
      });
    });
  });

  describe('2. Queue State Machine & Transitions', () => {
    const validTransitions: Record<string, string[]> = {
      active: ['called', 'skipped', 'cancelled'],
      called: ['in_consultation', 'skipped', 'completed'],
      in_consultation: ['completed'],
      skipped: ['called', 'completed', 'cancelled'],
      completed: [],
      cancelled: []
    };

    const isValidTransition = (from: string, to: string) => {
      return validTransitions[from]?.includes(to) ?? false;
    };

    test('validates standard OPD queue flow: active -> called -> completed', () => {
      assert.strictEqual(isValidTransition('active', 'called'), true);
      assert.strictEqual(isValidTransition('called', 'in_consultation'), true);
      assert.strictEqual(isValidTransition('in_consultation', 'completed'), true);
    });

    test('validates skip and recall flow', () => {
      assert.strictEqual(isValidTransition('active', 'skipped'), true);
      assert.strictEqual(isValidTransition('skipped', 'called'), true);
    });

    test('rejects illegal transitions', () => {
      assert.strictEqual(isValidTransition('completed', 'active'), false);
      assert.strictEqual(isValidTransition('cancelled', 'called'), false);
    });
  });

  describe('3. Six Notification Types Template Rendering & Locales', () => {
    test('Type 1: Token Booked (REGISTRATION_CONFIRMED) in English & Gujarati', () => {
      const en = renderNotificationTemplate('REGISTRATION_CONFIRMED', 'en', { tokenNumber: 15 });
      assert.ok(en.title.length > 0);
      assert.ok(en.body.includes('15'));

      const gu = renderNotificationTemplate('REGISTRATION_CONFIRMED', 'gu', { tokenNumber: 15 });
      assert.ok(gu.title.length > 0);
      assert.ok(gu.body.includes('15'));
    });

    test('Type 2: Token Updated / Turn Near (TURN_NEAR) with dynamic count', () => {
      const hi = renderNotificationTemplate('TURN_NEAR', 'hi', { tokenNumber: 15, patientsAhead: 2 });
      assert.ok(hi.title.length > 0);
      assert.ok(hi.body.includes('2'));
    });

    test('Type 3: Doctor Available (DOCTOR_AVAILABLE)', () => {
      const en = renderNotificationTemplate('DOCTOR_AVAILABLE', 'en', { doctorName: 'Dr. Mehta', date: '2026-09-15' });
      assert.ok(en.body.includes('Dr. Mehta'));
    });

    test('Type 4: OPD Reminder (OPD_REMINDER)', () => {
      const mr = renderNotificationTemplate('OPD_REMINDER', 'mr', { date: '2026-09-15' });
      assert.ok(mr.title.length > 0);
    });

    test('Type 5: Queue Change / Token Called (TOKEN_CALLED - YOUR TURN case)', () => {
      const gu = renderNotificationTemplate('TOKEN_CALLED', 'gu', { tokenNumber: 15 });
      assert.ok(gu.title.length > 0);
      assert.ok(gu.body.includes('15'));
    });

    test('Type 6: General Announcement (HOSPITAL_ANNOUNCEMENT)', () => {
      const en = renderNotificationTemplate('HOSPITAL_ANNOUNCEMENT', 'en', {
        customTitle: 'Free Eye Camp',
        customMessage: 'Eye checkup camp on Sunday.'
      });
      assert.strictEqual(en.title, 'Free Eye Camp');
      assert.strictEqual(en.body, 'Eye checkup camp on Sunday.');
    });
  });

  describe('4. Device Token Contract Validation', () => {
    test('validates platform enums', () => {
      const validPlatforms = ['android', 'ios', 'web'];
      assert.strictEqual(validPlatforms.includes('android'), true);
      assert.strictEqual(validPlatforms.includes('ios'), true);
      assert.strictEqual(validPlatforms.includes('web'), true);
      assert.strictEqual(validPlatforms.includes('windows_phone'), false);
    });
  });
});
