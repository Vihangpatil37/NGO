# ArogyaMitra — Project Improvement Plan

## Scope

This document contains the improvements currently planned for the ArogyaMitra / NextGen Hospital OPD Queue, Patient Registration, and Doctor Management Platform.

### Explicitly deferred for now

The following two items are intentionally **out of the current scope**:

1. Patient authentication changes.
2. Replacement of the hard-coded staff PIN.

Do not include those two items in the current implementation work unless they are explicitly brought back into scope later.

---

# 1. Priority 1 — Current Functional Issues

## 1.1 Fix Socket.IO room mismatch

### Problem

The backend and mobile client do not consistently use the same patient/token room semantics.

### Required improvement

Standardize Socket.IO room naming and joining across the entire project:

- `admin`
- `patient:<id>`
- `token:<id>`

Ensure that:

- backend room creation,
- Flutter `join:patient` payloads,
- notification dispatch,
- token status events,
- queue updates

all use the same contract.

### Files / areas to review

- `hospital-api-server/src/infrastructure/socket/socketServer.ts`
- `hospital-api-server/src/infrastructure/socket/notifier.ts`
- `hospital-api-server/src/infrastructure/socket/events.ts`
- `hospital-api-server/src/modules/notifications/notification.service.ts`
- `hospital_patient_app/lib/core/socket/patient_socket_service.dart`
- `hospital_patient_app/lib/core/services/global_notification_service.dart`

---

## 1.2 Fix missing Socket.IO events

### Problem

Some socket event names are declared but are not actually emitted or are handled inconsistently.

Known areas include:

- `token:position-update`
- `queue:paused`
- token status events that bypass the central event constants.

### Required improvement

Create one canonical socket event contract and ensure every event is:

1. Declared.
2. Emitted by the backend through the canonical notifier/event constants.
3. Consumed by the correct frontend/mobile listeners.
4. Tested.

---

## 1.3 Fix notification route ordering

### Problem

`PATCH /:id/read` can shadow `PATCH /read-all`.

### Required improvement

Register the specific route before the parameterized route.

Correct ordering:

```text
PATCH /read-all
PATCH /:id/read
```

---

## 1.4 Synchronize notification types

### Problem

Notification types are not perfectly aligned between:

- TypeScript notification types,
- Mongoose notification enum,
- notification templates,
- tests.

### Required improvement

Maintain one canonical notification type set.

Whenever a notification type is added or removed, update all required locations together:

```text
notification.types.ts
notification.templates.ts
notification.model.ts
tests
```

---

## 1.5 Fix doctor session restoration

### Problem

The mobile application contains doctor session restoration logic, but the session is not reliably revalidated on startup.

### Required improvement

On application startup:

1. Load stored doctor session.
2. Validate the session/JWT.
3. Confirm the doctor is still valid/active.
4. Clear invalid or stale state.
5. Route the user appropriately.

Review `DoctorProvider.restoreSession` and startup routing.

---

## 1.6 Fix mobile socket/refetch loops

### Problem

Socket events can trigger token refetches and local notifications repeatedly, creating unnecessary requests and potentially duplicated alerts.

### Required improvement

Review:

```text
Socket event
    ↓
fetchStatus()
    ↓
notifyListeners()
    ↓
notification / socket side effects
```

Make the realtime flow event-driven and avoid unnecessary repeated network requests or notifications.

---

## 1.7 Fix notification inbox refresh behavior

### Problem

Some inbox refresh/clear actions do not actually perform the expected server refresh.

### Required improvement

Ensure:

- Refresh = fetch latest notifications from backend.
- Mark as read = synchronize with backend.
- Clear = perform the intended local/server state update.
- Loading/error states are visible.
- Pagination remains consistent.

---

## 1.8 Fix admin/backend response mismatches

### Problem

Some admin UI code expects different field locations for registration data.

Examples include:

```text
patientId.*
```

versus:

```text
reg.caseNumber
reg.caseType
```

### Required improvement

Define a canonical registration DTO/response shape and make:

- backend response,
- `lib/api.ts`,
- `RegistrationsList`,
- patient details,
- TypeScript types

follow the same contract.

---

# 2. Priority 2 — Backend / API Improvements

## 2.1 Add Zod validation to currently unvalidated routes

### Areas to cover

- Doctor creation
- Doctor update
- Doctor PIN reset
- Language update
- Device registration
- Device refresh
- Device deactivation
- Notification mutation endpoints
- Any other JSON-body endpoint currently reading `req.body` directly

### Required improvement

Every JSON-body mutation should use:

```text
validate(schema)
```

before reaching controller logic.

---

## 2.2 Fix unsafe raw-regex inputs

### Problem

User-controlled values are used to construct regular expressions.

### Required improvement

Do not construct raw `RegExp` objects directly from untrusted input.

Prefer:

- exact matching,
- escaped regex input,
- validated search patterns,
- database-safe query operators.

Review:

- patient case lookup,
- old-case registration,
- patient search,
- other search endpoints using user input.

---

## 2.3 Remove duplicate API routes

Known duplicate/alias areas include:

- duplicate doctor endpoints,
- duplicate broadcast endpoints,
- duplicate device registration endpoints,
- patient router mounted under multiple paths.

### Required improvement

Choose one canonical route for each operation.

Keep legacy aliases only when there is an explicit compatibility requirement.

---

## 2.4 Prevent orphaned QueueToken records

### Problem

Registration deletion can leave related queue/token records behind.

### Required improvement

Define a clear deletion strategy:

- preferably soft deletion, or
- explicit controlled cleanup/cascade.

Verify behavior for:

- Registration,
- QueueToken,
- Patient history,
- queue queries,
- notification references.

---

## 2.5 Standardize API responses

### Required improvement

Use the project response helpers consistently:

```json
{
  "success": true,
  "message": "...",
  "data": {}
}
```

and:

```json
{
  "success": false,
  "error": {
    "code": "...",
    "message": "..."
  }
}
```

Avoid introducing new raw response shapes unless explicitly required by a client contract.

---

## 2.6 Replace remaining `console.*` usage

### Required improvement

Use the existing Pino logger instead of direct `console.*` calls inside backend runtime logic.

---

## 2.7 Review registration consistency

### Problem

Registration involves multiple related writes:

```text
Patient
Registration
QueueToken
Counter
Notification
```

### Required improvement

Review failure scenarios to ensure that a partially completed registration cannot leave inconsistent state.

Evaluate whether MongoDB transactions are appropriate for the multi-document workflow.

---

# 3. Priority 3 — Admin Dashboard Improvements

## 3.1 Centralize API requests

### Problem

Some components use inline `fetch()` instead of the shared API client.

### Required improvement

Route all API communication through:

```text
hospital-admin-app/lib/api.ts
```

This ensures consistent:

- base URL handling,
- authorization headers,
- 401 handling,
- parsing,
- error behavior.

---

## 3.2 Standardize 401 handling

### Required improvement

Every protected admin API operation should consistently:

1. Detect 401.
2. Clear the stored admin token.
3. Return the application to the login state.
4. Prevent stale authenticated UI from remaining active.

---

## 3.3 Debounce admin search

### Problem

Search requests can be issued on every keystroke.

### Required improvement

Add a small debounce window, approximately 300–500 ms, for:

- patient search,
- registration search.

This reduces unnecessary API and database load.

---

## 3.4 Remove duplicate registrations UI

### Problem

There is a canonical registration component and a separate registrations page with overlapping functionality.

### Required improvement

Keep one canonical implementation.

Remove or redirect the duplicate implementation once compatibility has been verified.

---

## 3.5 Improve Socket lifecycle management

### Problem

The queue socket can disconnect/reconnect when switching dashboard tabs.

### Required improvement

Evaluate keeping the queue socket connection alive for the dashboard session and controlling listeners independently from view mounting.

---

## 3.6 Clean unused frontend state and logic

Review and remove:

- unused state,
- unused imports,
- unused props,
- duplicated status/banner components,
- dead UI branches.

---

# 4. Priority 4 — Flutter / Mobile Improvements

## 4.1 Reduce unnecessary `notifyListeners()` calls

### Problem

Some provider methods notify more than once during a single logical operation.

### Required improvement

Batch state updates and call `notifyListeners()` only when the exposed state actually changes.

---

## 4.2 Remove duplicated registration dialogs

### Problem

New-case and old-case flows contain duplicated error/dialog handling.

### Required improvement

Create a shared reusable error/duplicate-token dialog or helper.

---

## 4.3 Unify status banner behavior

### Problem

The project contains multiple implementations of similar status-banner concepts.

### Required improvement

Use one shared `StatusBanner` implementation wherever the UX is equivalent.

---

## 4.4 Improve notification navigation and state restoration

Verify:

- notification tap handling,
- background notification handling,
- cold-start navigation,
- inbox navigation,
- token-screen restoration,
- notification-to-screen routing.

---

## 4.5 Improve mobile session lifecycle

Review stored session handling to ensure:

- stale state is cleared,
- invalid sessions do not produce broken navigation,
- startup routing remains deterministic,
- patient and doctor sessions do not conflict.

---

## 4.6 Fix Android production configuration

Before production release:

- use a proper release keystore,
- remove debug-key release signing,
- remove development-only cleartext HTTP configuration,
- verify release Firebase configuration,
- verify min/target/compile SDK compatibility.

---

# 5. Priority 5 — Testing Improvements

## 5.1 Add backend integration tests

Current tests should be expanded beyond pure/spec tests.

Cover:

- HTTP routes,
- middleware,
- controllers,
- services,
- authentication behavior that remains in scope,
- MongoDB integration.

---

## 5.2 Add queue concurrency tests

Test simultaneous registrations to verify:

- no duplicate token numbers,
- correct atomic counter behavior,
- window isolation,
- duplicate active registration handling,
- skipped/completed handling,
- re-registration behavior.

---

## 5.3 Add Socket.IO integration tests

Test:

- admin room joins,
- patient room joins,
- token rooms,
- token called,
- token skipped,
- token completed,
- queue updates,
- notification events,
- connection/reconnection behavior.

---

## 5.4 Add notification integration tests

Cover all notification types:

```text
N01
N02
N03
N04
N05
N06
```

Test:

- eventKey idempotency,
- locale selection,
- template interpolation,
- inbox persistence,
- Socket.IO delivery,
- FCM success/failure behavior.

---

## 5.5 Align failing/stale test expectations

Review existing tests that do not match the current implementation.

Tests should reflect the actual agreed contract rather than outdated template or behavior assumptions.

---

# 6. Priority 6 — Cleanup

## 6.1 Remove unused dependencies

Review and remove unused/redundant packages:

```text
node-cron
xlsx
nodemon
```

Only remove them after confirming there is no intended future runtime/build usage.

---

## 6.2 Remove dead backend code

Review:

- unused `patientAuth`,
- unused staff schemas,
- unused socket constants,
- unused imports,
- unused virtuals,
- unused constants,
- unused models/imports.

---

## 6.3 Remove duplicate device/broadcast/patient implementations

Consolidate overlapping endpoints and implementation paths.

---

# 7. Priority 7 — Documentation Improvements

## 7.1 Correct MD2.md

Update MD2 so it matches actual implementation.

Specifically correct:

- incorrect API base paths,
- incorrect statement that patient token endpoints require JWT,
- over-strong security claims,
- "production-ready" wording,
- QueueToken relationship wording,
- SessionStorage security wording.

---

## 7.2 Keep MD.md as the implementation source of truth

`MD.md` should remain the detailed technical reference.

It should continue distinguishing:

```text
Current Implementation
```

from:

```text
Recommended Improvements
```

Do not document proposed behavior as if it already exists.

---

## 7.3 Fix README drift

Review README references to:

- missing `start.bat`,
- missing `.env.example`,
- outdated architecture,
- outdated dependencies,
- features that are not currently implemented.

---

## 7.4 Add `.env.example`

Create a safe environment template containing:

- variable names,
- example/non-secret values,
- comments explaining each setting.

Never place real secrets in the example file.

---

# 8. Recommended Implementation Order

Use this order to avoid breaking tightly coupled features:

```text
1. Socket.IO room/event fixes
        ↓
2. Notification route/type fixes
        ↓
3. API validation improvements
        ↓
4. Doctor session lifecycle fixes
        ↓
5. Admin API centralization + search improvements
        ↓
6. Flutter state/notification cleanup
        ↓
7. Registration consistency review
        ↓
8. Integration + concurrency + realtime tests
        ↓
9. Dead-code/dependency cleanup
        ↓
10. Documentation synchronization
```

---

# 9. Definition of Done

An improvement should not be considered complete merely because the code compiles.

For each change verify:

- [ ] Backend behavior works.
- [ ] Admin behavior works.
- [ ] Mobile behavior works where applicable.
- [ ] Socket events/rooms still match.
- [ ] Notification behavior still works.
- [ ] Existing API contracts are preserved or intentionally versioned.
- [ ] Relevant tests are added/updated.
- [ ] No new dead code or duplicate implementation is introduced.
- [ ] `MD.md` remains accurate.
- [ ] Documentation does not describe future behavior as current behavior.

---

# 10. Final Scope Summary

### Included in current improvement scope

- Socket.IO consistency
- Realtime events
- Notification consistency
- Doctor session lifecycle
- Notification inbox behavior
- API validation
- Regex/input safety
- Duplicate route cleanup
- Registration consistency
- Admin API/client cleanup
- Admin search performance
- Flutter state/notification cleanup
- Android production configuration
- Integration and concurrency testing
- Dead-code/dependency cleanup
- Documentation correction

### Explicitly deferred

- Patient authentication redesign
- Hard-coded staff PIN replacement

These two deferred items should remain untouched until they are explicitly brought back into scope.
