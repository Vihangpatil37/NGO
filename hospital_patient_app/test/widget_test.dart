import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hospital_patient_app/main.dart';
import 'package:hospital_patient_app/core/constants/app_constants.dart';
import 'package:hospital_patient_app/core/storage/session_storage.dart';
import 'package:hospital_patient_app/core/localization/locale_provider.dart';
import 'package:hospital_patient_app/features/token/token_provider.dart';

void main() {
  testWidgets('HospitalPatientApp renders welcome screen and hospital branding', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.keyLanguageCode: 'en',
    });
    final storage = await SessionStorage.getInstance();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider(storage)),
          ChangeNotifierProvider(create: (_) => TokenProvider()),
        ],
        child: const HospitalPatientApp(
          initialRoute: '/',
          initialTokenId: null,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify hospital name brand is rendered
    expect(find.text(AppConstants.hospitalName), findsOneWidget);

    // Verify Welcome text and choices
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('What would you like to do?'), findsOneWidget);
    expect(find.text('New Case'), findsOneWidget);
    expect(find.text('Old Case'), findsOneWidget);
  });
}
