# ArogyaMitra Flutter — Patient Onboarding & Notification UI Design Plan

## 1. Purpose

This document is the implementation blueprint for redesigning the first part of the ArogyaMitra Flutter application around the approved UI flow shown in the reference design.

The primary goal is to make the application immediately understandable:

1. Show the ArogyaMitra splash screen.
2. Ask the user whether they are a **Patient** or **Doctor**.
3. Keep the existing Doctor authentication/profile flow unchanged because doctors are already registered by the admin.
4. Introduce the new Patient phone-number + OTP flow.
5. Collect the minimum patient profile information on first login.
6. Take the patient into the existing application/home experience.
7. Add a visible notification area and a persistent language selector.
8. Keep the visual system consistent across the entire Flutter app.

---

# 2. Approved Screen Flow

## Overall navigation

```text
Splash
   ↓
User Type Selection
   ├── Patient
   │     ↓
   │   Patient Phone Login
   │     ↓
   │   OTP Verification
   │     ↓
   │   First-time Patient Profile
   │     ↓
   │   Patient Home
   │
   └── Doctor
         ↓
      Existing Doctor Login
         ↓
      Existing Doctor OTP / Authentication
         ↓
      Existing Doctor Profile / Dashboard
```

### Important Doctor rule

The Doctor flow is **not being redesigned in this task**.

Doctors are already registered/managed by the admin. The new Patient onboarding flow must not accidentally change or duplicate the existing Doctor registration/authentication behavior.

---

# 3. Design Direction

The reference design establishes the visual language that should be carried into Flutter.

## Design principles

- Clean
- Minimal
- Healthcare-oriented
- Trustworthy
- Friendly for users with limited technical experience
- Large touch targets
- Strong visual hierarchy
- Very little unnecessary text
- Consistent spacing
- Soft rounded cards
- Teal/green as the primary healthcare identity
- Light backgrounds with subtle tinted surfaces
- Clear icons instead of dense text
- Avoid technical terminology in user-facing UI

## UX priority

The application should feel usable by a patient who may:

- Have limited smartphone experience.
- Be an elderly patient.
- Be using the application for the first time.
- Prefer Gujarati or Hindi.
- Not understand technical authentication terminology.

Therefore:

> Every screen should answer one question clearly and provide one obvious next action.

---

# 4. Screen-by-Screen Specification

# Screen 1 — Splash Screen

## Purpose

Introduce the ArogyaMitra application while the Flutter app initializes.

## Layout

- Full-screen light background.
- ArogyaMitra logo centered vertically.
- Application name below logo.
- Tagline:
  - `Healthcare`
  - `Closer to You`
- Soft decorative healthcare/wave illustration toward the bottom.
- Small footer message:
  - `A Healthier Tomorrow, Together`

## Behavior

The splash screen should remain visible only while required startup initialization occurs.

Initialization can include:

- Local session check.
- Firebase initialization.
- Notification service initialization.
- Existing app configuration initialization.

After initialization:

```text
Existing valid patient session → Patient Home
Existing valid doctor session  → Doctor Dashboard
No valid session               → User Type Selection
```

Do not make the splash screen unnecessarily long.

## Flutter implementation

Recommended:

- `SplashScreen`
- `SafeArea`
- `Column`
- `Expanded`
- `Image/Asset`
- `Text`
- subtle background decoration

Avoid complex animation unless it already exists in the application.

---

# Screen 2 — User Type Selection

## Purpose

This is the **first important user decision**.

The user must choose:

- `I am a Patient`
- `I am a Doctor`

## Header

```text
Welcome to
ArogyaMitra

Please tell us who you are
```

## Patient card

Primary visual emphasis.

```text
[Patient Icon]

I am a Patient

Book appointments, view
updates and more                         >
```

Selecting the card:

```text
Patient → Patient Phone Login
```

## Doctor card

```text
[Doctor Icon]

I am a Doctor

Manage your schedule
and patients                              >
```

Selecting the card:

```text
Doctor → Existing Doctor Flow
```

## Design

The two cards should be visually distinct but belong to the same component family.

Patient:

- Soft green/teal tinted surface.

Doctor:

- Soft blue tinted surface.

Both:

- Rounded corners.
- Large icon.
- Title.
- Short description.
- Right-facing chevron.
- Entire card is tappable.

## UX rule

Do not use tiny radio buttons.

The entire card should behave as the selection control.

---

# 5. Screen 3 — Patient Phone Login

## Purpose

Start patient authentication using the patient's mobile number.

## Header

Back button.

## Main content

Icon:

```text
Phone
```

Title:

```text
Patient Login
```

Subtitle:

```text
Enter your mobile number to continue
```

## Phone field

Use:

```text
+91 | Mobile number
```

The country code should be visually separated from the editable number.

## Primary button

```text
Send OTP
```

## Supporting text

```text
We'll send a 6-digit code to verify your number
```

## Validation

The UI must provide friendly validation:

- Empty number:
  - `Please enter your mobile number.`
- Invalid number:
  - `Please enter a valid mobile number.`
- Network error:
  - `Unable to send OTP. Please check your connection and try again.`
- OTP service error:
  - Do not expose backend/Firebase exception text directly.

## Loading state

When OTP is being sent:

```text
[Loading indicator] Sending OTP...
```

Disable the button during the request to prevent duplicate OTP requests.

---

# 6. Screen 4 — Patient OTP Verification

## Purpose

Verify the patient's mobile number.

## Header

Back button.

## Main content

Icon:

```text
Message / Verification
```

Title:

```text
Enter OTP
```

Subtitle:

```text
We've sent a 6-digit code to
+91 XXXXX XXXXX
```

The displayed phone number should be partially masked when appropriate.

## OTP input

Six individual visual boxes:

```text
[ ] [ ] [ ] [ ] [ ] [ ]
```

Behavior:

- Auto-focus first box.
- Automatically move to next box.
- Support paste of a 6-digit OTP.
- Support backspace correctly.
- Numeric keyboard.
- Automatically submit when all six digits are entered if appropriate.
- Show clear error if OTP is invalid.

## Resend

Example:

```text
Resend OTP in 00:30
```

After the timer:

```text
Resend OTP
```

## Error

Never show:

```text
Invalid input: expected object, received undefined
```

Instead show:

```text
The OTP could not be verified. Please try again.
```

or:

```text
Something went wrong. Please request a new OTP.
```

## Authentication behavior

The Flutter client should not implement its own OTP cryptography or OTP generation.

Recommended architecture:

```text
Flutter
  ↓
Firebase Phone Authentication
  ↓
Firebase ID Token
  ↓
Backend verification
  ↓
Patient identity/session
```

The backend should remain responsible for creating/returning the application's authenticated patient session after successful identity verification.

---

# 7. Screen 5 — First-Time Patient Profile

## Purpose

Collect the minimum information required when a patient signs in for the first time.

## Header

Back button.

## Title

```text
Complete Your Profile
```

Subtitle:

```text
Please confirm your details
```

## Fields

### Full Name

```text
Full Name
```

### Age

```text
Age
```

Use a numeric input.

### Village Name

```text
Village Name
```

This field is explicitly required in the approved design.

## Primary button

```text
Continue
```

## Validation

Full Name:

```text
Please enter your full name.
```

Age:

```text
Please enter a valid age.
```

Village:

```text
Please enter your village name.
```

Do not expose raw API validation errors.

## Design rule

Keep this page short.

Do not add:

- Address
- Gender
- Medical history
- Unnecessary profile fields

unless they are required elsewhere by the existing application/business flow.

The approved design only specifies:

1. Full Name
2. Age
3. Village Name

---

# 8. Returning Patient Behavior

The profile page should be a **first-time-only** experience.

After successful first-time profile completion:

```text
Patient
  ↓
Authenticated
  ↓
Profile completed
  ↓
Patient Home
```

On future login:

```text
Phone
  ↓
OTP
  ↓
Existing Patient
  ↓
Patient Home
```

Do not ask the same patient to fill the profile again unless the backend explicitly reports that the profile is incomplete.

---

# 9. Screen 9 — Patient Home

## Purpose

Provide the main patient experience and expose hospital notifications clearly.

## Header

```text
[ArogyaMitra]                         [Profile]
```

## Notification banner

The home screen should support a prominent hospital notice.

Example:

```text
Hospital Closed Today                 2h ago
The hospital will remain closed
today due to maintenance.             >
```

This is useful for important N04 hospital announcements.

## Main action grid

Recommended cards:

```text
┌──────────────────┬──────────────────┐
│ Book Appointment  │ My Appointments  │
├──────────────────┼──────────────────┤
│ View Doctors      │ Notifications    │
└──────────────────┴──────────────────┘
```

## Health records

Full-width card:

```text
My Health Records
```

Only show functionality that already exists in the application.

Do not invent backend capabilities merely to match the mockup.

---

# 10. Patient Bottom Navigation

The approved design contains:

```text
Home
Appointments
Notifications
Profile
```

## Navigation behavior

### Home

Patient dashboard.

### Appointments

Existing appointment experience.

### Notifications

Notification inbox.

### Profile

Patient profile/settings.

The selected tab must have a clear visual state.

Use a consistent icon + label combination.

---

# 11. Language Selector

The language selector must appear in the footer area of:

- Patient Home
- Notification List

The reference design shows:

```text
🌐 English  ˅
```

## Supported languages

The existing notification system supports:

- English
- Gujarati
- Hindi

The Flutter UI should use the same language set.

## Selector behavior

Tap:

```text
English ˅
```

Open a simple bottom sheet/menu:

```text
English
ગુજરાતી
हिन्दी
```

After selection:

- Update the UI language.
- Persist the preference locally.
- Use the selected language for notification content where supported.
- Restore the selected language on app restart.

## Important

Do not create separate hard-coded strings for every screen.

Use Flutter localization:

```text
AppLocalizations
ARB files
```

or the localization mechanism already used by the project.

---

# 12. Screen 10 — Notification List

## Purpose

Give patients a dedicated inbox for hospital notifications.

## Header

```text
<    Notifications
```

## Notification card

Each card should contain:

- Notification icon/type
- Title
- Short message
- Relative time
- Optional chevron

Example:

```text
[Announcement]   Hospital Closed Today       2h ago
                  The hospital will remain
                  closed today due to
                  maintenance.                  >
```

## Example notification types

The existing notification architecture includes different notification types.

The UI should render them through a shared notification-card component rather than creating separate page layouts.

## Read/unread state

Recommended:

Unread:

- Slightly stronger background.
- Bold title.
- Optional unread indicator.

Read:

- Normal background.
- Normal title weight.

Do not make unread state depend only on color.

---

# 13. Notification Architecture — Flutter UI

The patient notification flow should be:

```text
Admin
  ↓
Create hospital announcement
  ↓
Backend
  ↓
Notification created
  ↓
Patient notification inbox
  ↓
Socket.IO real-time update
  +
FCM push notification
```

The Flutter application should support both:

### Foreground

Receive Socket.IO / notification event and update the notification list.

### Background

Receive FCM push notification.

### App opened from notification

Navigate to:

```text
Notifications
```

or to a relevant detail screen if notification deep-linking is implemented.

---

# 14. Notification State Management

Use a single source of truth for notifications.

Recommended state:

```text
NotificationState
├── loading
├── notifications
├── unreadCount
├── error
└── lastUpdated
```

Avoid having:

- One notification list on Home.
- Another list on Notification screen.
- A third independent unread counter.

Instead:

```text
Notification Repository
        ↓
Notification State
   ↙         ↘
Home       Notification Screen
```

This prevents inconsistent notification counts and stale UI.

---

# 15. Reusable Flutter Components

The design should not be implemented as one giant widget.

Create reusable components.

## Core

```text
AppScaffold
AppButton
AppTextField
AppIconButton
AppCard
AppHeader
```

## Authentication

```text
RoleSelectionCard
PhoneNumberField
OtpInput
AuthLoadingView
AuthErrorMessage
```

## Patient

```text
PatientProfileForm
PatientActionCard
NotificationBanner
NotificationCard
LanguageSelector
```

## Navigation

```text
PatientBottomNavigation
```

## Design system

```text
AppColors
AppTypography
AppSpacing
AppRadius
AppShadows
```

---

# 16. Design System

## Primary color

Use the existing ArogyaMitra teal/green identity.

Suggested semantic tokens:

```text
primary
primaryContainer
secondary
surface
surfaceVariant
background
error
success
warning
textPrimary
textSecondary
border
```

Do not scatter raw color values across widgets.

Instead:

```dart
AppColors.primary
AppColors.surface
AppColors.textPrimary
```

## Typography

Use a highly readable sans-serif font.

Hierarchy:

```text
Screen title
Section title
Card title
Body
Supporting text
Caption
```

The title should be clearly larger and heavier than supporting text.

## Spacing

Create a consistent spacing scale.

Example:

```text
4
8
12
16
20
24
32
```

Use the same spacing system throughout the app.

## Corner radius

Use rounded cards consistently.

Suggested tokens:

```text
small
medium
large
pill
```

Avoid mixing many unrelated corner radii.

---

# 17. Responsive Design

The design must work on different Android screen sizes.

Do not hard-code the mockup's pixel dimensions.

Use:

- `SafeArea`
- `Expanded`
- `Flexible`
- `LayoutBuilder`
- responsive padding
- `MediaQuery` only where necessary

Avoid:

```dart
Container(width: 350)
```

when a responsive alternative is possible.

The primary content should remain usable on:

- Small phones
- Normal phones
- Large phones

---

# 18. Accessibility

Because this is a healthcare application, accessibility should be treated as a core requirement.

## Touch targets

Buttons and interactive cards should have sufficiently large touch areas.

## Text

Do not use extremely small text.

## Color

Do not communicate state using color alone.

For example:

Unread notification:

```text
Bold title + indicator
```

not only:

```text
Different color
```

## Screen readers

Important controls should have meaningful semantic labels.

Examples:

```text
I am a Patient
I am a Doctor
Send OTP
Verify OTP
Notifications
Select language
```

---

# 19. Error Handling UX

Raw technical errors must never reach the patient.

Bad:

```text
Invalid input: expected object, received undefined
```

Bad:

```text
AxiosError
SocketException
FirebaseAuthException...
```

Good:

```text
Something went wrong. Please try again.
```

Network-specific:

```text
Please check your internet connection and try again.
```

OTP-specific:

```text
The OTP is incorrect. Please check the code and try again.
```

Server-specific:

```text
We couldn't complete your request right now. Please try again later.
```

Log technical details internally for debugging, but show human-readable messages in the UI.

---

# 20. Authentication State Machine

The Flutter application should explicitly model authentication state.

```text
Unknown
  ↓
Checking Session
  ├── Patient Session → Patient Home
  ├── Doctor Session  → Doctor Dashboard
  └── No Session      → Role Selection
```

Patient:

```text
Role Selected
  ↓
Enter Phone
  ↓
OTP Sent
  ↓
OTP Verified
  ↓
Patient Exists?
  ├── YES → Home
  └── NO / Profile Incomplete
          ↓
       Profile Form
          ↓
       Home
```

This is preferable to scattering authentication checks across multiple pages.

---

# 21. Suggested Flutter Project Structure

Adapt this structure to the project's existing architecture rather than creating duplicate folders.

```text
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   └── app_theme.dart
│   │
│   ├── localization/
│   │   └── ...
│   │
│   ├── routing/
│   │   └── app_router.dart
│   │
│   └── widgets/
│       ├── app_button.dart
│       ├── app_card.dart
│       └── app_text_field.dart
│
├── features/
│   ├── splash/
│   ├── role_selection/
│   ├── patient_auth/
│   │   ├── phone_login/
│   │   ├── otp_verification/
│   │   └── patient_profile/
│   │
│   ├── patient_home/
│   ├── notifications/
│   └── patient_profile/
│
└── existing_doctor/
```

If the project already follows another architecture, preserve the existing convention instead of restructuring the entire project unnecessarily.

---

# 22. Routing Plan

Recommended logical routes:

```text
/splash
/role-selection

/patient/login
/patient/otp
/patient/profile
/patient/home
/patient/notifications

/doctor/*
```

The exact route naming can be adapted to the current router.

## Routing rules

### Unauthenticated

```text
Splash → Role Selection
```

### Patient authenticated

```text
Splash → Patient Home
```

### Patient authenticated but profile incomplete

```text
Splash → Patient Profile
```

### Doctor authenticated

```text
Splash → Existing Doctor Dashboard
```

Do not allow users to manually navigate into authenticated screens without the appropriate session state.

---

# 23. Implementation Sequence

Implement in the following order.

## Phase 1 — Inspect existing Flutter app

Before modifying code:

- Inspect existing screens.
- Inspect routing.
- Inspect Provider/state management.
- Inspect API service.
- Inspect authentication/session storage.
- Inspect notification service.
- Inspect Firebase initialization.
- Inspect Socket.IO integration.
- Inspect current Doctor flow.
- Identify reusable components.

Do not replace working Doctor functionality just to introduce the new Patient flow.

---

## Phase 2 — Establish design system

Create or consolidate:

```text
Colors
Typography
Spacing
Radius
Button styles
Input styles
Card styles
```

Apply the design system to the new screens first.

---

## Phase 3 — Build entry flow

Implement:

```text
Splash
↓
Role Selection
```

Verify:

- Patient selection works.
- Doctor selection still enters existing flow.

---

## Phase 4 — Build Patient authentication UI

Implement:

```text
Patient Login
↓
OTP Verification
```

Add:

- phone validation
- loading states
- OTP timer
- resend
- friendly errors

---

## Phase 5 — Connect authentication backend

Implement the agreed authentication flow:

```text
Phone
↓
Firebase Phone Auth
↓
Firebase ID Token
↓
Backend verification
↓
Patient session
```

Do not duplicate OTP generation/verification logic inside Flutter.

---

## Phase 6 — Build first-time profile

Implement:

```text
Full Name
Age
Village Name
↓
Continue
```

Connect it to the existing Patient model/API.

---

## Phase 7 — Patient Home

Integrate:

- Existing patient functionality.
- Notification banner.
- Action cards.
- Bottom navigation.
- Language selector.

Do not create fake functionality merely for visual matching.

---

## Phase 8 — Notification inbox

Implement:

- Notification repository.
- Notification state.
- Notification list.
- Read/unread state.
- Unread count.
- Real-time update.
- FCM handling.
- Navigation from push notification.

---

## Phase 9 — Localization

Add:

```text
English
Gujarati
Hindi
```

Translate:

- Authentication screens.
- Patient profile.
- Home.
- Notification labels.
- Error messages.
- Bottom navigation.
- Language selector.

Notification content itself should follow the backend's supported multilingual notification system.

---

## Phase 10 — UX polish

Perform a visual pass for:

- spacing
- alignment
- typography
- icon consistency
- button heights
- card radius
- loading states
- keyboard behavior
- error states
- empty states
- small screens

---

# 24. Testing Checklist

## Splash

- [ ] App opens without crash.
- [ ] Existing session is detected.
- [ ] Correct destination is selected.

## Role selection

- [ ] Patient card opens Patient Login.
- [ ] Doctor card opens existing Doctor flow.
- [ ] Cards are fully tappable.

## Patient login

- [ ] Invalid number rejected.
- [ ] Valid number sends OTP.
- [ ] Loading state works.
- [ ] Duplicate requests are prevented.
- [ ] Friendly error displayed.

## OTP

- [ ] Six digits supported.
- [ ] Auto-focus works.
- [ ] Paste works.
- [ ] Backspace works.
- [ ] Invalid OTP handled.
- [ ] Resend timer works.
- [ ] Resend works after timer.

## Patient profile

- [ ] Full name validated.
- [ ] Age validated.
- [ ] Village validated.
- [ ] Data saved successfully.
- [ ] Returning patient does not see profile unnecessarily.

## Home

- [ ] Notification banner renders.
- [ ] Action cards work.
- [ ] Bottom navigation works.
- [ ] Language selector works.

## Notifications

- [ ] Notifications load.
- [ ] Empty state works.
- [ ] Unread count works.
- [ ] Read/unread state works.
- [ ] Real-time notifications appear.
- [ ] FCM notifications work.
- [ ] Opening a notification navigates correctly.

## Localization

- [ ] English works.
- [ ] Gujarati works.
- [ ] Hindi works.
- [ ] Language persists after restart.
- [ ] No untranslated technical strings are visible.

## Doctor

- [ ] Existing Doctor Login still works.
- [ ] Existing Doctor OTP/authentication still works.
- [ ] Existing admin-registered Doctor behavior is unchanged.

---

# 25. Design Acceptance Criteria

The implementation is considered successful when:

### Visual

- The new Flutter screens clearly match the approved reference design.
- ArogyaMitra branding is consistent.
- Cards, buttons, fields, icons, spacing and typography form one coherent design system.
- The UI does not look like a collection of unrelated screens.

### UX

- A first-time patient can understand the flow without instructions.
- Patient and Doctor flows are clearly separated.
- OTP interaction is simple.
- First-time profile completion is short.
- Important hospital announcements are easy to find.

### Technical

- Existing Doctor functionality remains intact.
- Patient authentication is integrated rather than mocked.
- Notification state has a single source of truth.
- FCM and Socket.IO are handled without duplicate UI updates.
- Language preference persists.
- Raw technical errors are never displayed to patients.

### Responsive

- UI works across common Android phone sizes.
- No important control is hidden behind the keyboard.
- No overflow occurs on small screens.

---

# 26. Final Approved UX

The final patient experience should feel like:

```text
Open App
   ↓
ArogyaMitra
   ↓
"Are you a Patient or Doctor?"
   ↓
"I am a Patient"
   ↓
Enter Mobile Number
   ↓
Send OTP
   ↓
Enter 6-digit OTP
   ↓
First Login?
   ├── Yes → Full Name + Age + Village Name
   │             ↓
   │          Patient Home
   │
   └── No ─────→ Patient Home
                    ↓
          ┌─────────┴─────────┐
          ↓                   ↓
       Hospital            Notifications
       Announcement         Inbox
          ↓                   ↓
          └──── Language ─────┘
             English / Gujarati / Hindi
```

---

# 27. Important Scope Boundaries

This design task does **not** include:

- Redesigning Doctor authentication.
- Creating a separate Doctor registration process.
- Adding arbitrary patient profile fields.
- Replacing the existing appointment system.
- Inventing new backend functionality.
- Rebuilding the entire Flutter architecture without first inspecting the existing implementation.
- Displaying raw backend/Firebase errors.
- Implementing custom OTP generation.

The new work should integrate with the existing ArogyaMitra application rather than create a parallel application architecture.

---

# 28. Recommended Development Principle

Before writing the new Flutter UI, inspect the current implementation and map each proposed screen to existing:

- models
- providers
- services
- routes
- APIs
- Firebase configuration
- Socket.IO handlers
- notification models
- local storage

Then implement the design incrementally.

The reference image defines the **visual and UX target**.

The existing application defines the **functional behavior that must be preserved**.

Both should be respected during implementation.
