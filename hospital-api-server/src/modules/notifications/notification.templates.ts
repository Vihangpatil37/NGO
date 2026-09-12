export type NotificationType = 
  | 'REGISTRATION_CONFIRMED'
  | 'TURN_NEAR'
  | 'TOKEN_CALLED'
  | 'HOSPITAL_ANNOUNCEMENT'
  | 'DOCTOR_AVAILABLE'
  | 'DOCTOR_UNAVAILABLE'
  | 'OPD_REMINDER'
  | 'OPD_CLOSED';

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
      en: '📢 Hospital Notice',
      gu: '📢 હોસ્પિટલ સૂચના',
      hi: '📢 अस्पताल सूचना'
    },
    body: {
      en: '{{message}}',
      gu: '{{message}}',
      hi: '{{message}}'
    }
  },
  DOCTOR_AVAILABLE: {
    title: {
      en: 'Doctor Available',
      gu: 'ડૉક્ટર ઉપલબ્ધ છે',
      hi: 'डॉक्टर उपलब्ध हैं'
    },
    body: {
      en: 'The doctor has started seeing patients.',
      gu: 'ડૉક્ટરે દર્દીઓને તપાસવાનું શરૂ કર્યું છે.',
      hi: 'डॉक्टर ने मरीजों को देखना शुरू कर दिया है।'
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
  OPD_REMINDER: {
    title: {
      en: 'OPD Schedule Reminder',
      gu: 'OPD સમય રિમાઇન્ડર',
      hi: 'ओपीडी समय अनुस्मारक'
    },
    body: {
      en: '{{message}}',
      gu: '{{message}}',
      hi: '{{message}}'
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
    title = title.replace(new RegExp(placeholder, 'g'), String(value));
    body = body.replace(new RegExp(placeholder, 'g'), String(value));
  }

  return { title, body };
};
