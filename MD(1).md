# NGO Hospital Registration System — Implementation Plan

## 1. Objective

The goal is to simplify the hospital application by removing the **Live Queue** and **Token Generation** functionality and making the system focused on patient registration.

The new flow will:

- Keep **New Case** and **Old Case** selection in the Patient App.
- Store the selected case type with every registration.
- Remove token generation completely.
- Remove live queue functionality completely.
- Change the Admin App registration area into two sections:
  - **New Case**
  - **Old Case**
- Show registrations in the admin section according to the option selected by the patient.

The system will continue to manage patient, doctor, registration, and administrative information, but it will no longer manage real-time patient queues or token numbers.

---

# 2. Current Problem

The current application contains queue-oriented functionality where registration can lead to:

1. Registration
2. Token generation
3. Queue placement
4. Live queue management
5. Calling/skipping/completing patients

This introduces unnecessary complexity for the intended workflow.

The required workflow is simpler:

```text
Patient
   |
   v
Select Case Type
   |
   +------------------+
   |                  |
   v                  v
New Case            Old Case
   |                  |
   +--------+---------+
            |
            v
      Submit Registration
            |
            v
    Registration Stored
            |
            v
      Admin Application
            |
       +----+----+
       |         |
       v         v
    New Case   Old Case
```

---

# 3. Target Architecture

After implementation, the system should be structured around registration rather than queue management.

```text
PATIENT APP
│
├── New Case
│   └── Registration
│
└── Old Case
    └── Registration
            |
            v
        BACKEND API
            |
            v
        DATABASE
            |
            v
        ADMIN APP
        │
        ├── Dashboard
        ├── Registrations
        │   ├── New Case
        │   └── Old Case
        ├── Patients
        ├── Doctors
        └── Reports
```

The following concepts should no longer be part of the active registration workflow:

```text
Queue Token
Live Queue
Queue Position
Current Token
Next Token
Call Patient
Skip Patient
Complete Token
Token Generation
```

---

# 4. Patient App Changes

## 4.1 Initial Case Selection

Keep the existing case selection concept.

```text
Start Registration
       |
       v
+-------------------+
|                   |
|    New Case       |
|    Old Case       |
|                   |
+-------------------+
```

The user's selection must determine the `caseType` sent to the backend.

Allowed values:

```text
new
old
```

No other value should be accepted.

---

# 5. New Case Flow

The New Case flow should collect the information required to create a new patient/case registration.

Typical flow:

```text
New Case
   |
   v
Enter Phone Number
   |
   v
Enter Name
   |
   v
Enter Village
   |
   v
Enter Age
   |
   v
Other Required Details
   |
   v
Submit
   |
   v
Backend Registration API
   |
   v
Save Registration
   |
   v
Registration Successful
```

## Important

The New Case flow must **not**:

- Generate a token.
- Create a queue token.
- Calculate queue position.
- Redirect to a live queue screen.
- Call a queue endpoint.

The result should simply be a successful registration.

Example response:

```json
{
  "success": true,
  "message": "Registration successful",
  "registrationId": "..."
}
```

---

# 6. Old Case Flow

The Old Case flow should continue to identify an existing patient/case.

Typical flow:

```text
Old Case
   |
   v
Enter Phone Number
   |
   v
Enter Name
   |
   v
Enter Case ID
   |
   v
Other Required Details
   |
   v
Submit
   |
   v
Backend Registration API
   |
   v
Save Registration
   |
   v
Registration Successful
```

The Old Case flow must also **not** create a queue token.

---

# 7. Registration Data Model

The most important database change is adding a `caseType` field to the **Registration** model.

Recommended structure:

```ts
caseType: "new" | "old"
```

Example New Case registration:

```json
{
  "patientId": "PATIENT_ID",
  "caseType": "new",
  "registrationDate": "2026-09-15T09:30:00.000Z",
  "status": "registered"
}
```

Example Old Case registration:

```json
{
  "patientId": "PATIENT_ID",
  "caseType": "old",
  "registrationDate": "2026-09-15T09:45:00.000Z",
  "status": "registered"
}
```

## 7.1 Source of Truth

The registration's `caseType` must be the **source of truth** for the Admin App.

Do not determine the registration type later by looking at:

- Current patient profile.
- Whether a patient already exists.
- Case ID presence alone.
- Number of previous registrations.

The exact option selected during that registration should be stored.

---

# 8. Database Rules

The backend should enforce:

```text
caseType = "new"
OR
caseType = "old"
```

Invalid examples:

```text
caseType = "New Case"
caseType = "Old Case"
caseType = "NEW"
caseType = null
caseType = "unknown"
```

For new registrations, `caseType` should be required.

If older records do not contain the field, they should be handled separately during migration.

---

# 9. Backend Registration API

The Patient App should send the selected case type.

## New Case request

```json
{
  "caseType": "new",
  "phone": "...",
  "name": "...",
  "village": "...",
  "age": 20
}
```

## Old Case request

```json
{
  "caseType": "old",
  "phone": "...",
  "name": "...",
  "caseId": "..."
}
```

The backend should:

1. Validate the request.
2. Validate `caseType`.
3. Find or create the required patient record.
4. Create the registration.
5. Save the selected `caseType`.
6. Return registration success.
7. Never create a token.
8. Never create a queue record.
9. Never calculate queue position.

---

# 10. Remove Queue/Token Logic From Backend

Audit the backend and identify every queue/token dependency.

The following functionality should be removed or disabled from the active system:

```text
QueueToken model
Token generation service
Token number allocation
Queue position calculation
Waiting queue calculation
Live queue endpoints
Current patient queue endpoints
Call-next-patient endpoint
Skip-patient endpoint
Complete-token endpoint
Queue status transitions
Token-related registration logic
```

## Important

Do not blindly delete shared utilities.

First identify whether any queue code is used by:

- Registration
- Patient APIs
- Doctor APIs
- Admin APIs
- Reports
- Notifications

Remove only the functionality that is no longer required.

---

# 11. QueueToken Model

If the system no longer has any requirement for tokens, the `QueueToken` model should be removed from the active application.

Before deleting it:

1. Search the entire backend for model imports.
2. Search for collection references.
3. Search for service/controller usage.
4. Search for route usage.
5. Search for scheduled jobs.
6. Search for frontend API usage.

Only after all references are removed should the model be deleted.

---

# 12. Admin App — Registration Section

The Admin App should no longer present one combined registration list.

Replace it with two logical sections:

```text
Registrations

+----------------+----------------+
|   New Case     |    Old Case    |
+----------------+----------------+
```

The two sections should use the stored `caseType`.

---

# 13. New Case Admin Section

The New Case section should query/filter registrations where:

```ts
registration.caseType === "new"
```

Possible columns:

| Column | Description |
|---|---|
| Registration ID | Registration identifier |
| Patient Name | Patient name |
| Phone | Registered phone number |
| Village | Patient village |
| Age | Patient age |
| Registration Date | Date/time of registration |
| Status | Registration status |

The exact columns should match the existing project data model.

There should be:

- No token number.
- No queue position.
- No call button.
- No skip button.
- No complete-token button.

---

# 14. Old Case Admin Section

The Old Case section should query/filter registrations where:

```ts
registration.caseType === "old"
```

Possible columns:

| Column | Description |
|---|---|
| Registration ID | Registration identifier |
| Patient Name | Patient name |
| Phone | Registered phone |
| Case ID | Existing case identifier |
| Village | Patient village |
| Registration Date | Date/time |
| Status | Registration status |

Again, fields should be aligned with the actual project schema.

---

# 15. Filtering Strategy

There are two possible implementation approaches.

## Option A — Backend Filtering

Preferred for large datasets.

Example:

```text
GET /registrations?caseType=new
GET /registrations?caseType=old
```

Advantages:

- Less data transferred.
- Easier pagination.
- Better scalability.
- Cleaner separation.

## Option B — Frontend Filtering

Fetch all registrations and split them in the UI:

```ts
const newCases = registrations.filter(
  registration => registration.caseType === "new"
);

const oldCases = registrations.filter(
  registration => registration.caseType === "old"
);
```

This is acceptable for small datasets, but backend filtering is preferable as the registration volume grows.

---

# 16. Recommended Admin API

Recommended endpoints:

```text
GET /registrations
GET /registrations?caseType=new
GET /registrations?caseType=old
GET /registrations/:id
```

The backend should validate the filter:

```text
caseType ∈ ["new", "old"]
```

Possible response:

```json
{
  "success": true,
  "data": [
    {
      "id": "...",
      "patientName": "...",
      "caseType": "new",
      "registrationDate": "..."
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 120
  }
}
```

---

# 17. Admin Dashboard Changes

Remove queue-specific dashboard widgets.

Remove or replace items such as:

```text
Live Queue
Current Token
Next Token
Waiting Patients
Called Patients
Skipped Patients
Completed Tokens
Queue Position
```

Replace them with registration-focused information.

Example:

```text
Today's Registrations     182
New Cases                  47
Old Cases                 135
```

Other useful registration metrics may include:

```text
Today's Total Registrations
New Case Registrations
Old Case Registrations
Registrations by Village
Registrations by Date
```

---

# 18. Admin Navigation Changes

Remove:

```text
Live Queue
```

A possible navigation structure:

```text
Dashboard
Registrations
Patients
Doctors
Reports
Settings
```

Keep only features that still have a real purpose.

---

# 19. Patient App UI Changes

Remove screens that exist only to show:

```text
Token Number
Queue Position
Patients Ahead
Live Queue
Current Token
Estimated Waiting Time
```

After successful registration, show:

```text
Registration Successful

Your registration has been recorded successfully.

Registration ID: XXXXX

Please proceed according to hospital instructions.
```

The exact success screen can follow the existing project design.

---

# 20. Patient App Routing Changes

Audit routes such as:

```text
/token
/queue
/live-queue
/queue-status
/token-status
```

Any route that is only used for queue/token functionality should be removed.

Also inspect:

- Navigation stacks.
- Deep links.
- Redirect logic.
- Post-registration navigation.
- State management.
- Providers.
- API clients.

The registration success route should become the final destination after registration.

---

# 21. State Management Changes

Search the Patient App for state variables such as:

```text
token
tokenNumber
queuePosition
queueStatus
waitingCount
patientsAhead
currentToken
```

Remove them where they are exclusively related to queue functionality.

The registration state should instead contain relevant information such as:

```text
registrationId
caseType
registrationStatus
```

---

# 22. API Client Changes

Remove API methods related to:

```text
generateToken()
getQueue()
getLiveQueue()
getCurrentToken()
callPatient()
skipPatient()
completePatient()
```

Keep:

```text
createRegistration()
getRegistration()
getRegistrations()
```

Add `caseType` to the registration request.

---

# 23. Doctor App Impact

The Doctor App should be checked carefully.

The system should determine whether doctors still need:

- Registered patient list.
- Appointment/registration information.
- Patient details.
- Medical workflow.

If Doctor App currently depends on queue tokens for patient selection, replace that dependency with a registration-based patient list.

Do not remove doctor functionality merely because queue functionality is being removed.

---

# 24. Existing Data Migration

Older registrations may not have `caseType`.

This must be handled intentionally.

Recommended temporary model:

```text
New Case
Old Case
Legacy / Unknown
```

For historical records:

```text
caseType = "legacy"
```

or keep `caseType` null during migration and expose them through a separate legacy filter.

Do not automatically classify existing records unless the old data contains a reliable field that proves whether a record was New Case or Old Case.

After migration, all new registrations must contain:

```text
new
OR
old
```

---

# 25. Migration Strategy

Recommended sequence:

```text
Step 1
Add caseType to Registration model

Step 2
Deploy backend that accepts caseType

Step 3
Keep old records compatible

Step 4
Update Patient App to send caseType

Step 5
Update Admin App to separate registrations

Step 6
Verify new registrations

Step 7
Migrate historical records if required

Step 8
Remove queue/token functionality

Step 9
Deploy final version
```

This reduces the risk of breaking the application during transition.

---

# 26. Validation Rules

## New Case

Required information should be validated before submission.

Example:

```text
Phone → required
Name → required
Village → required
Age → required
caseType → "new"
```

## Old Case

Example:

```text
Phone → required
Name → required
Case ID → required
caseType → "old"
```

The exact required fields should follow the existing project requirements.

---

# 27. Duplicate/Repeated Registration Handling

The system should define what happens when the same patient registers multiple times.

A patient may legitimately register multiple times on different dates.

Therefore:

```text
Patient
   |
   +---- Registration 1 → new
   |
   +---- Registration 2 → old
   |
   +---- Registration 3 → old
```

Each registration should preserve its own `caseType`.

Do not overwrite the historical registration's type when the patient's overall record changes.

---

# 28. Case Type vs Patient Type

Important distinction:

```text
Patient Type
```

is a property of the patient/profile.

Whereas:

```text
Registration Case Type
```

is a property of a particular registration event.

The Admin App should use:

```text
Registration.caseType
```

for the New/Old Case sections.

This prevents historical registrations from being incorrectly reclassified.

---

# 29. Search and Filters

The Admin App should support registration-focused filters.

Recommended:

```text
Case Type
Date
Village
Patient Name
Phone
Case ID
Registration ID
```

Case Type should be represented as:

```text
New Case
Old Case
```

not arbitrary text entered by an administrator.

---

# 30. Reports

Remove queue-specific reports.

Examples of reports that should be removed:

```text
Average Queue Waiting Time
Token Completion Time
Queue Length
Patients Called
Patients Skipped
```

Replace with registration reports where needed:

```text
Daily Registrations
New vs Old Cases
Registrations by Village
Registrations by Date
```

---

# 31. Security and Validation

Backend validation must not rely only on frontend controls.

The backend must validate:

```text
caseType
patient information
registration payload
authorization for admin endpoints
```

The frontend should never be trusted to define a valid case type.

Allowed:

```text
new
old
```

Rejected:

```text
token
queue
unknown
anything else
```

---

# 32. Error Handling

The Patient App should display a useful error if registration fails.

Example:

```text
Registration Failed

We could not complete your registration.
Please check your details and try again.
```

The backend should return meaningful HTTP status codes.

Example:

```text
400 → Invalid registration data
401 → Unauthorized
404 → Required patient/case not found
409 → Registration conflict
500 → Server error
```

Exact status codes should follow the existing backend conventions.

---

# 33. Logging and Audit

Keep registration-related audit logging where useful.

Example:

```text
Registration Created
Registration Updated
Admin Viewed Registration
```

Remove audit events that exist exclusively for queue/token actions if those actions no longer exist.

---

# 34. Testing Plan

## Patient App Tests

### New Case

```text
Open app
→ Select New Case
→ Fill details
→ Submit
→ Registration succeeds
→ caseType = new
→ No token created
→ No queue screen opened
```

### Old Case

```text
Open app
→ Select Old Case
→ Fill details
→ Submit
→ Registration succeeds
→ caseType = old
→ No token created
→ No queue screen opened
```

---

# 35. Backend Tests

Test:

```text
Create New Case registration
Create Old Case registration
Reject invalid caseType
Reject missing caseType
Verify caseType persistence
Verify no QueueToken creation
Verify no queue side effects
```

Example:

```text
POST /registrations
caseType = new
→ 201/200
→ registration.caseType = new
```

And:

```text
POST /registrations
caseType = invalid
→ 400
```

---

# 36. Admin App Tests

Verify:

```text
New Case section shows only caseType = new
Old Case section shows only caseType = old
```

Also verify:

```text
A New Case registration never appears under Old Case
An Old Case registration never appears under New Case
```

Test pagination and filtering if implemented.

---

# 37. Regression Testing

After queue/token removal, verify that these still work:

```text
Patient registration
Patient search
Patient details
Doctor management
Doctor login
Admin login
Dashboard
Registration history
Reports
Authentication
Database connection
```

Any functionality that does not depend on queue management should remain unchanged.

---

# 38. Codebase Search Checklist

Before finalizing, search the entire repository for queue/token-related keywords.

Recommended searches:

```text
queue
Queue
token
Token
queueToken
QueueToken
tokenNumber
queuePosition
liveQueue
currentToken
nextToken
callPatient
skipPatient
completePatient
waitingPatients
patientsAhead
```

Also search route names and API paths.

Every remaining occurrence should be classified as:

```text
Required
Deprecated
Comment/documentation
Dead code
```

Do not leave active queue/token references accidentally connected to registration.

---

# 39. Files/Areas to Inspect

The exact filenames depend on the project structure, but the implementation should cover:

```text
Backend
├── Models
├── Schemas
├── Controllers
├── Services
├── Routes
├── Middleware
├── Validation
└── Utilities

Patient App
├── Screens
├── Navigation
├── Services/API
├── Models
├── State Management
└── Registration Flow

Admin App
├── Registration Page
├── Dashboard
├── Navigation
├── API Services
├── Components
└── Filters/Tables

Doctor App
├── Patient/registration dependencies
├── Queue dependencies
└── Navigation
```

---

# 40. Recommended Implementation Order

Use the following order to reduce risk:

```text
1. Inspect the complete project structure.

2. Identify all queue/token dependencies.

3. Add Registration.caseType.

4. Update backend registration validation.

5. Update registration API to accept caseType.

6. Update Patient App New Case flow.

7. Update Patient App Old Case flow.

8. Remove token generation from registration.

9. Remove patient queue/token screens and navigation.

10. Update Admin registration APIs.

11. Create New Case admin section.

12. Create Old Case admin section.

13. Remove Live Queue from Admin navigation.

14. Remove queue-specific dashboard widgets.

15. Remove queue/token backend services and routes.

16. Clean unused models, components, services, and imports.

17. Handle legacy registrations.

18. Run backend tests.

19. Run Patient App tests.

20. Run Admin App tests.

21. Perform full regression testing.

22. Build all applications.

23. Verify production API integration.

24. Deploy.
```

---

# 41. Acceptance Criteria

The implementation is complete only when all of the following are true.

## Patient App

- [ ] User can select New Case.
- [ ] User can select Old Case.
- [ ] New Case registration sends `caseType = "new"`.
- [ ] Old Case registration sends `caseType = "old"`.
- [ ] Registration succeeds without generating a token.
- [ ] No live queue screen is shown.
- [ ] No queue position is shown.
- [ ] No token number is shown.

## Backend

- [ ] Registration stores `caseType`.
- [ ] Only `new` and `old` are accepted.
- [ ] No queue token is created during registration.
- [ ] Queue generation logic is removed from active registration flow.
- [ ] Queue endpoints are removed or disabled.
- [ ] Unused queue/token services are removed.

## Admin App

- [ ] Live Queue navigation is removed.
- [ ] Registration page has New Case section.
- [ ] Registration page has Old Case section.
- [ ] New Case section shows only `caseType = "new"`.
- [ ] Old Case section shows only `caseType = "old"`.
- [ ] Token number is not displayed.
- [ ] Queue position is not displayed.
- [ ] Call/Skip/Complete queue actions are removed.

## Data

- [ ] Historical registrations are handled safely.
- [ ] New registrations always contain `caseType`.
- [ ] Historical registration type is not accidentally overwritten.

---

# 42. Final Expected User Experience

### Patient

```text
Open App
   ↓
New Case / Old Case
   ↓
Enter Information
   ↓
Submit
   ↓
Registration Successful
```

### Admin

```text
Open Admin App
   ↓
Registrations
   ↓
+-------------------+
| New Case | Old Case |
+-------------------+
```

### No Queue

```text
NO TOKEN
NO LIVE QUEUE
NO WAITING POSITION
NO CALL
NO SKIP
NO COMPLETE TOKEN
```

The application becomes a clean **hospital registration and patient-management system** rather than a token/queue-management system.

---

# 43. Final Design Principle

The key rule for the implementation is:

> **Every registration must store the case type selected by the patient, and the Admin App must use that stored registration-level case type to separate New Case and Old Case registrations.**

This makes the system deterministic, preserves historical accuracy, and avoids relying on inferred patient state.

---

# 44. Deliverable Checklist

The final implementation should produce:

```text
[ ] Updated database registration schema
[ ] Updated backend registration API
[ ] Updated Patient App New Case flow
[ ] Updated Patient App Old Case flow
[ ] Removed token generation
[ ] Removed live queue
[ ] Updated Admin registration page
[ ] New Case admin section
[ ] Old Case admin section
[ ] Updated dashboard
[ ] Removed unused queue/token code
[ ] Legacy data strategy
[ ] Automated/manual tests
[ ] Successful application builds
[ ] Final regression verification
```

---

## End Result

The final system should be:

```text
Patient chooses:
        |
        +---- New Case
        |
        +---- Old Case
                |
                v
        Registration Created
                |
                v
       caseType is stored
                |
                v
          Admin App
          /        \
         /          \
   New Case       Old Case
```

There is **no token generation and no live queue system** anywhere in the new registration workflow.
