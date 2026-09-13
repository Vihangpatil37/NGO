// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get hospitalName => 'ArogyaMitra';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get whatWouldYouLikeToDo => 'What would you like to do?';

  @override
  String get newCase => 'New Case';

  @override
  String get newCaseSubtitle => 'I am visiting for the first time';

  @override
  String get oldCase => 'Old Case';

  @override
  String get oldCaseSubtitle => 'I have visited before';

  @override
  String get back => 'Back';

  @override
  String get enterDetails => 'Please enter your details';

  @override
  String get mobileNumber => 'Mobile number';

  @override
  String get mobileNumberHint => 'Enter your 10-digit mobile number';

  @override
  String get fullName => 'Full name';

  @override
  String get fullNameHint => 'Enter the patient\'s name';

  @override
  String get villageName => 'Village name';

  @override
  String get villageNameHint => 'Enter your village name';

  @override
  String get age => 'Age';

  @override
  String get ageHint => 'Enter age in years';

  @override
  String get caseId => 'Case ID';

  @override
  String get caseIdHint => 'e.g. U-00001';

  @override
  String get registerAndGetToken => 'REGISTER & GET TOKEN';

  @override
  String get continueAndGetToken => 'CONTINUE & GET TOKEN';

  @override
  String get tokenConfirmed => 'Token Confirmed';

  @override
  String get yourTokenNumber => 'Your Token Number';

  @override
  String get pleaseWaitForTurn => 'Please wait for your turn.';

  @override
  String get viewMyToken => 'VIEW MY TOKEN';

  @override
  String get myToken => 'My Token';

  @override
  String get currentlyServing => 'Currently serving';

  @override
  String get peopleBeforeYou => 'People before you';

  @override
  String get statusWaiting => 'Please Wait';

  @override
  String get statusWaitingSub =>
      'We will notify you when your turn approaches.';

  @override
  String get statusAlmostTurn => 'Your turn is near';

  @override
  String get statusAlmostTurnSub => '1-2 people before you. Please get ready.';

  @override
  String get statusYourTurn => 'YOUR TURN';

  @override
  String get statusYourTurnSub => 'Please proceed to the doctor\'s room.';

  @override
  String get statusSkipped => 'You missed your turn';

  @override
  String get statusSkippedSub =>
      'Your token was skipped. Please contact the reception.';

  @override
  String get statusCompleted => 'Consultation Completed';

  @override
  String get statusCompletedSub =>
      'Thank you for visiting. We wish you good health.';

  @override
  String get caseNotFound => 'We couldn\'t find this case.';

  @override
  String get caseNotFoundSub =>
      'Please check your mobile number, full name, and Case ID.';

  @override
  String get tryAgain => 'TRY AGAIN';

  @override
  String get contactHospital => 'CONTACT HOSPITAL';

  @override
  String get help => 'Help';

  @override
  String get hospitalHelpline => 'Hospital Helpline';

  @override
  String get hospitalAddress => 'Hospital Address';

  @override
  String get helpDesc =>
      'If you need any assistance, please approach the hospital help desk.';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get selectLanguage => 'Select your language';

  @override
  String get continueAction => 'CONTINUE';

  @override
  String get close => 'Close';

  @override
  String get newCaseFormSubtitle =>
      'We need this information to prepare your hospital token.';

  @override
  String get oldCaseFormSubtitle =>
      'Enter your registered phone and Case ID from your previous hospital visit slip.';

  @override
  String get validationMobile => 'Please enter a valid 10-digit mobile number';

  @override
  String get validationFullName => 'Please enter the patient\'s full name';

  @override
  String get validationVillage => 'Please enter your village name';

  @override
  String get validationAge => 'Please enter a valid age between 0 and 130';

  @override
  String get validationCaseId => 'Please enter your Case ID';

  @override
  String get loadingConnecting => 'Connecting to hospital live queue...';

  @override
  String get liveUpdatesActive => 'Live updates active • No refresh needed';

  @override
  String get clearTokenPrompt => 'Done for today? Clear my token';

  @override
  String get exitQueueTitle => 'Exit Hospital Queue?';

  @override
  String get exitQueueMessage =>
      'Do you want to clear this token and return to the home screen? You can check in again using your Case ID.';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get errorLoadToken => 'Unable to load token details.';

  @override
  String get patientLabel => 'Patient';

  @override
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get faqTokenQuestion => 'What is a Token Number?';

  @override
  String get faqTokenAnswer =>
      'Your token number represents your position in the OPD queue. When the hospital calls your token number, it is your turn to visit the doctor.';

  @override
  String get faqMissedQuestion => 'What if I miss my turn?';

  @override
  String get faqMissedAnswer =>
      'If you miss your turn, please approach the hospital help desk or reception counter. The staff will assist in calling you during the next available slot.';

  @override
  String get faqAppOpenQuestion => 'Do I need to keep the app open?';

  @override
  String get faqAppOpenAnswer =>
      'Your token remains active even if you close the app. When you open the app again, it will automatically show your current token number and queue progress.';

  @override
  String get faqCaseIdQuestion => 'What is a Case ID (e.g. U-00001)?';

  @override
  String get faqCaseIdAnswer =>
      'Your Case ID is your permanent hospital registration number. Keep it safe for your follow-up visits so you do not need to register again.';

  @override
  String caseIdDisplay(String caseNumber, String patientName) {
    return 'Case ID: $caseNumber • $patientName';
  }

  @override
  String get notifRegistrationTitle => '✅ Registration Confirmed';

  @override
  String notifRegistrationBody(Object tokenNumber) {
    return 'Your OPD Token is #$tokenNumber. Please keep this token with you.';
  }

  @override
  String get notifTurnNearTitle => '⏳ YOUR TURN IS NEAR';

  @override
  String notifTurnNearBody(Object ahead, Object tokenNumber) {
    return 'Token #$tokenNumber: Only $ahead patient(s) ahead. Please be ready near the OPD room.';
  }

  @override
  String get notifYourTurnTitle => '🚨 YOUR TURN';

  @override
  String notifYourTurnBody(Object tokenNumber) {
    return 'Token #$tokenNumber has been called. Please proceed to the doctor\'s room immediately.';
  }
}
