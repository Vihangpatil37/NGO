import { NotificationType } from './notification.types';

interface TemplateDef {
  en: string;
  gu: string;
  hi: string;
}

const TEMPLATES: Record<NotificationType, { title: TemplateDef; body: TemplateDef }> = {
  REGISTRATION_CONFIRMED: {
    title: {
      en: '✅ Registration Confirmed',
      gu: '✅ નોંધણી સફળ',
      hi: '✅ पंजीकरण सफल'
    },
    body: {
      en: 'Your Token # is {{tokenNumber}}.',
      gu: 'તમારો ટોકન નંબર {{tokenNumber}} છે.',
      hi: 'आपका टोकन नंबर {{tokenNumber}} है।'
    }
  },
  TURN_NEAR: {
    title: {
      en: '⏳ Your Turn Is Near',
      gu: '⏳ તમારો વારો નજીક છે',
      hi: '⏳ आपकी बारी करीब है'
    },
    body: {
      en: 'Please proceed near the doctor room.',
      gu: 'કૃપા કરીને ડૉક્ટરના રૂમ પાસે જાઓ.',
      hi: 'कृपया डॉक्टर के कमरे के पास जाएं।'
    }
  },
  TOKEN_CALLED: {
    title: {
      en: '🚨 Your Turn',
      gu: '🚨 તમારો વારો આવ્યો છે',
      hi: '🚨 आपकी बारी आ गई है'
    },
    body: {
      en: 'Please enter {{room}} now.',
      gu: 'કૃપા કરીને હવે {{room}} માં જાઓ.',
      hi: 'कृपया अब {{room}} में प्रवेश करें।'
    }
  },
  HOSPITAL_ANNOUNCEMENT: {
    title: {
      en: '📢 {{title}}',
      gu: '📢 {{title}}',
      hi: '📢 {{title}}'
    },
    body: {
      en: '{{message}}',
      gu: '{{message}}',
      hi: '{{message}}'
    }
  },
  DOCTOR_UNAVAILABLE: {
    title: {
      en: '🩺 Doctor Unavailable',
      gu: '🩺 ડૉક્ટર ઉપલબ્ધ નથી',
      hi: '🩺 डॉक्टर उपलब्ध नहीं हैं'
    },
    body: {
      en: 'The doctor is temporarily unavailable. Please wait.',
      gu: 'ડૉક્ટર અસ્થાયી રૂપે ઉપલબ્ધ નથી. કૃપા કરીને રાહ જુઓ.',
      hi: 'डॉक्टर अस्थायी रूप से उपलब्ध नहीं हैं। कृपया प्रतीक्षा करें।'
    }
  },
  OPD_CLOSED: {
    title: {
      en: '🏥 OPD Closed',
      gu: '🏥 OPD બંધ',
      hi: '🏥 OPD बंद'
    },
    body: {
      en: 'Registration is closed for today.',
      gu: 'આજ માટે નોંધણી બંધ છે.',
      hi: 'आज के लिए पंजीकरण बंद है।'
    }
  }
};

export const renderNotificationTemplate = (
  type: NotificationType,
  locale: string = 'en',
  variables: Record<string, any> = {}
): { title: string; body: string } => {
  const template = TEMPLATES[type];
  if (!template) {
    return { title: 'Notification', body: '' };
  }

  const l = ['en', 'gu', 'hi'].includes(locale) ? locale as 'en' | 'gu' | 'hi' : 'en';

  let title = template.title[l] || template.title['en'];
  let body = template.body[l] || template.body['en'];

  for (const [key, value] of Object.entries(variables)) {
    const placeholder = `{{${key}}}`;
    title = title.replaceAll(placeholder, String(value));
    body = body.replaceAll(placeholder, String(value));
  }

  return { title, body };
};
