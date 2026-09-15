$ErrorActionPreference = 'Stop'

# Helper to run git commands
function Git-Commit {
    param([string]$file, [string]$message, [switch]$delete)
    Write-Host "Committing $file..."
    if ($delete) {
        git rm --quiet "$file"
    } else {
        git add "$file"
    }
    git commit -m "$message" --quiet
}

# 1-6. Deletions
Git-Commit -delete "MD.md" "remove old MD document no longer needed"
Git-Commit -delete "PROJECT_SPEC.md" "clean up old project specification file"
Git-Commit -delete "WhatsApp Image 2026-09-12 at 11.09.39 PM.jpeg" "remove outdated whatsapp image from root"
Git-Commit -delete "analysis_output.json" "delete temporary analysis output json"
Git-Commit -delete "analyze.py" "remove python analysis script"
Git-Commit -delete "walkthrough.md" "clean up walkthrough documentation"

# 7-9. Backend changes
Git-Commit "hospital-api-server/src/modules/patients/patient-auth.controller.ts" "create new controller for handling firebase authentication"
Git-Commit "hospital-api-server/src/modules/patients/patient-auth.routes.ts" "add routes for the new patient firebase authentication endpoints"
Git-Commit "hospital-api-server/src/app.ts" "register patient authentication routes in the main backend app"

# 10-11. Flutter pubspec
Git-Commit "hospital_patient_app/pubspec.yaml" "add firebase auth dependency to pubspec"
Git-Commit "hospital_patient_app/pubspec.lock" "update pubspec lock file for new firebase packages"

# 12. Theme
Git-Commit "hospital_patient_app/lib/core/theme/app_theme.dart" "update app theme with new teal healthcare color palette and design system"

# 13-17. Shared Widgets
Git-Commit "hospital_patient_app/lib/shared/widgets/role_selection_card.dart" "add reusable role selection card widget for the welcome screen"
Git-Commit "hospital_patient_app/lib/shared/widgets/otp_input.dart" "create a new custom otp input widget for phone verification"
Git-Commit "hospital_patient_app/lib/shared/widgets/notification_banner.dart" "add a stylish notification banner widget for the home screen"
Git-Commit "hospital_patient_app/lib/shared/widgets/action_card.dart" "create a reusable action card widget for the patient dashboard"
Git-Commit "hospital_patient_app/lib/shared/widgets/patient_bottom_nav.dart" "build the patient bottom navigation bar widget"

# 18-19. Initial Screens
Git-Commit "hospital_patient_app/lib/features/splash/splash_screen.dart" "redesign the splash screen with the new logo and session routing"
Git-Commit "hospital_patient_app/lib/features/role_selection/role_selection_screen.dart" "create a new screen that lets users choose between patient and doctor roles"

# 20-25. Patient Auth
Git-Commit "hospital_patient_app/lib/core/models/firebase_auth_result.dart" "add a data model to handle results from firebase authentication"
Git-Commit "hospital_patient_app/lib/features/patient_auth/auth_provider.dart" "implement state management and business logic for phone authentication"
Git-Commit "hospital_patient_app/lib/features/patient_auth/phone_login_screen.dart" "design the phone number entry screen for patient login"
Git-Commit "hospital_patient_app/lib/features/patient_auth/otp_verification_screen.dart" "build the otp verification screen with a countdown timer"
Git-Commit "hospital_patient_app/lib/features/patient_auth/patient_profile_screen.dart" "add a profile completion screen for first time patients"
Git-Commit "hospital_patient_app/lib/core/network/api_service.dart" "update the api service to verify firebase tokens and create patient records"

# 26-28. Patient Home & Notifications
Git-Commit "hospital_patient_app/lib/features/patient_home/patient_home_shell.dart" "set up a shell screen with bottom navigation for the patient area"
Git-Commit "hospital_patient_app/lib/features/patient_home/patient_home_screen.dart" "build the new patient dashboard with action grid and notifications"
Git-Commit "hospital_patient_app/lib/features/notifications/notification_inbox_screen.dart" "redesign the notification inbox to match the new visual guidelines"

# 29. Router
Git-Commit "hospital_patient_app/lib/core/navigation/app_router.dart" "update routing configuration to include the newly built screens"

# 30-33. Update Old Screens to New Router
Git-Commit "hospital_patient_app/lib/features/doctor/doctor_availability_screen.dart" "point back buttons in doctor availability to the new role selection screen"
Git-Commit "hospital_patient_app/lib/features/new_case/new_case_screen.dart" "update navigation paths in the new case screen"
Git-Commit "hospital_patient_app/lib/features/old_case/old_case_screen.dart" "update back navigation paths in the old case screen"
Git-Commit "hospital_patient_app/lib/features/token/my_token_screen.dart" "ensure the token screen routes back to the new patient home"

# 34-35. Main & Tests
Git-Commit "hospital_patient_app/lib/main.dart" "update the flutter app entry point to use the new authentication provider and router"
Git-Commit "hospital_patient_app/test/widget_test.dart" "update widget tests to account for the new initial splash route"

# 36-37. Untracked project files
Git-Commit "AROGYAMITRA_FLUTTER_UI_DESIGN_PLAN.md" "save the flutter ui design plan document for future reference"
Git-Commit "ChatGPT Image Sep 14, 2026, 09_37_38 AM.png" "keep the original mockup image used for the ui redesign"

Write-Host "All 37 commits created successfully."
