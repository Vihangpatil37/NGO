import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi')
  ];

  /// No description provided for @hospitalName.
  ///
  /// In en, this message translates to:
  /// **'ArogyaMitra'**
  String get hospitalName;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeTitle;

  /// No description provided for @whatWouldYouLikeToDo.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get whatWouldYouLikeToDo;

  /// No description provided for @newCase.
  ///
  /// In en, this message translates to:
  /// **'New Case'**
  String get newCase;

  /// No description provided for @newCaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I am visiting for the first time'**
  String get newCaseSubtitle;

  /// No description provided for @oldCase.
  ///
  /// In en, this message translates to:
  /// **'Old Case'**
  String get oldCase;

  /// No description provided for @oldCaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I have visited before'**
  String get oldCaseSubtitle;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @enterDetails.
  ///
  /// In en, this message translates to:
  /// **'Please enter your details'**
  String get enterDetails;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumber;

  /// No description provided for @mobileNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your 10-digit mobile number'**
  String get mobileNumberHint;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the patient\'s name'**
  String get fullNameHint;

  /// No description provided for @villageName.
  ///
  /// In en, this message translates to:
  /// **'Village name'**
  String get villageName;

  /// No description provided for @villageNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your village name'**
  String get villageNameHint;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @ageHint.
  ///
  /// In en, this message translates to:
  /// **'Enter age in years'**
  String get ageHint;

  /// No description provided for @caseId.
  ///
  /// In en, this message translates to:
  /// **'Case ID'**
  String get caseId;

  /// No description provided for @caseIdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. U-00001'**
  String get caseIdHint;

  /// No description provided for @registerAndGetToken.
  ///
  /// In en, this message translates to:
  /// **'REGISTER & GET TOKEN'**
  String get registerAndGetToken;

  /// No description provided for @continueAndGetToken.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE & GET TOKEN'**
  String get continueAndGetToken;

  /// No description provided for @tokenConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Token Confirmed'**
  String get tokenConfirmed;

  /// No description provided for @yourTokenNumber.
  ///
  /// In en, this message translates to:
  /// **'Your Token Number'**
  String get yourTokenNumber;

  /// No description provided for @pleaseWaitForTurn.
  ///
  /// In en, this message translates to:
  /// **'Please wait for your turn.'**
  String get pleaseWaitForTurn;

  /// No description provided for @viewMyToken.
  ///
  /// In en, this message translates to:
  /// **'VIEW MY TOKEN'**
  String get viewMyToken;

  /// No description provided for @myToken.
  ///
  /// In en, this message translates to:
  /// **'My Token'**
  String get myToken;

  /// No description provided for @currentlyServing.
  ///
  /// In en, this message translates to:
  /// **'Currently serving'**
  String get currentlyServing;

  /// No description provided for @peopleBeforeYou.
  ///
  /// In en, this message translates to:
  /// **'People before you'**
  String get peopleBeforeYou;

  /// No description provided for @statusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Please Wait'**
  String get statusWaiting;

  /// No description provided for @statusWaitingSub.
  ///
  /// In en, this message translates to:
  /// **'We will notify you when your turn approaches.'**
  String get statusWaitingSub;

  /// No description provided for @statusAlmostTurn.
  ///
  /// In en, this message translates to:
  /// **'Your turn is near'**
  String get statusAlmostTurn;

  /// No description provided for @statusAlmostTurnSub.
  ///
  /// In en, this message translates to:
  /// **'1-2 people before you. Please get ready.'**
  String get statusAlmostTurnSub;

  /// No description provided for @statusYourTurn.
  ///
  /// In en, this message translates to:
  /// **'YOUR TURN'**
  String get statusYourTurn;

  /// No description provided for @statusYourTurnSub.
  ///
  /// In en, this message translates to:
  /// **'Please proceed to the doctor\'s room.'**
  String get statusYourTurnSub;

  /// No description provided for @statusSkipped.
  ///
  /// In en, this message translates to:
  /// **'You missed your turn'**
  String get statusSkipped;

  /// No description provided for @statusSkippedSub.
  ///
  /// In en, this message translates to:
  /// **'Your token was skipped. Please contact the reception.'**
  String get statusSkippedSub;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Consultation Completed'**
  String get statusCompleted;

  /// No description provided for @statusCompletedSub.
  ///
  /// In en, this message translates to:
  /// **'Thank you for visiting. We wish you good health.'**
  String get statusCompletedSub;

  /// No description provided for @caseNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this case.'**
  String get caseNotFound;

  /// No description provided for @caseNotFoundSub.
  ///
  /// In en, this message translates to:
  /// **'Please check your mobile number, full name, and Case ID.'**
  String get caseNotFoundSub;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'TRY AGAIN'**
  String get tryAgain;

  /// No description provided for @contactHospital.
  ///
  /// In en, this message translates to:
  /// **'CONTACT HOSPITAL'**
  String get contactHospital;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @hospitalHelpline.
  ///
  /// In en, this message translates to:
  /// **'Hospital Helpline'**
  String get hospitalHelpline;

  /// No description provided for @hospitalAddress.
  ///
  /// In en, this message translates to:
  /// **'Hospital Address'**
  String get hospitalAddress;

  /// No description provided for @helpDesc.
  ///
  /// In en, this message translates to:
  /// **'If you need any assistance, please approach the hospital help desk.'**
  String get helpDesc;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your language'**
  String get selectLanguage;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueAction;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @newCaseFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We need this information to prepare your hospital token.'**
  String get newCaseFormSubtitle;

  /// No description provided for @oldCaseFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered phone and Case ID from your previous hospital visit slip.'**
  String get oldCaseFormSubtitle;

  /// No description provided for @validationMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit mobile number'**
  String get validationMobile;

  /// No description provided for @validationFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the patient\'s full name'**
  String get validationFullName;

  /// No description provided for @validationVillage.
  ///
  /// In en, this message translates to:
  /// **'Please enter your village name'**
  String get validationVillage;

  /// No description provided for @validationAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid age between 0 and 130'**
  String get validationAge;

  /// No description provided for @validationCaseId.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Case ID'**
  String get validationCaseId;

  /// No description provided for @loadingConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to hospital live queue...'**
  String get loadingConnecting;

  /// No description provided for @liveUpdatesActive.
  ///
  /// In en, this message translates to:
  /// **'Live updates active • No refresh needed'**
  String get liveUpdatesActive;

  /// No description provided for @clearTokenPrompt.
  ///
  /// In en, this message translates to:
  /// **'Done for today? Clear my token'**
  String get clearTokenPrompt;

  /// No description provided for @exitQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Hospital Queue?'**
  String get exitQueueTitle;

  /// No description provided for @exitQueueMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to clear this token and return to the home screen? You can check in again using your Case ID.'**
  String get exitQueueMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @errorLoadToken.
  ///
  /// In en, this message translates to:
  /// **'Unable to load token details.'**
  String get errorLoadToken;

  /// No description provided for @patientLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patientLabel;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @faqTokenQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is a Token Number?'**
  String get faqTokenQuestion;

  /// No description provided for @faqTokenAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your token number represents your position in the OPD queue. When the hospital calls your token number, it is your turn to visit the doctor.'**
  String get faqTokenAnswer;

  /// No description provided for @faqMissedQuestion.
  ///
  /// In en, this message translates to:
  /// **'What if I miss my turn?'**
  String get faqMissedQuestion;

  /// No description provided for @faqMissedAnswer.
  ///
  /// In en, this message translates to:
  /// **'If you miss your turn, please approach the hospital help desk or reception counter. The staff will assist in calling you during the next available slot.'**
  String get faqMissedAnswer;

  /// No description provided for @faqAppOpenQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do I need to keep the app open?'**
  String get faqAppOpenQuestion;

  /// No description provided for @faqAppOpenAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your token remains active even if you close the app. When you open the app again, it will automatically show your current token number and queue progress.'**
  String get faqAppOpenAnswer;

  /// No description provided for @faqCaseIdQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is a Case ID (e.g. U-00001)?'**
  String get faqCaseIdQuestion;

  /// No description provided for @faqCaseIdAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your Case ID is your permanent hospital registration number. Keep it safe for your follow-up visits so you do not need to register again.'**
  String get faqCaseIdAnswer;

  /// Formatted case ID and patient name display
  ///
  /// In en, this message translates to:
  /// **'Case ID: {caseNumber} • {patientName}'**
  String caseIdDisplay(String caseNumber, String patientName);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
