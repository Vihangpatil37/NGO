# Update Android SDK + Optimize App Size

## Background

Two goals for the `hospital_patient_app` Flutter project:
1. **Raise minimum Android version** from API 21 (Android 5.0) to API 30 (Android 11), targeting API 35 (Android 15).
2. **Optimize the application size** — apply every feasible technique to reduce the release APK.

---

## Current App Size (Baseline)

| Build Artifact | Size |
|---|---|
| Debug APK (fat, all ABIs) | **101.94 MB** *(normal — includes Dart VM, debug symbols, all ABIs)* |
| Release APK — arm64-v8a | **17.66 MB** |
| Release APK — armeabi-v7a | **15.27 MB** |
| Release APK — x86_64 | **19.03 MB** |
| Release AAB (App Bundle) | **49.42 MB** |

### What's Already Optimized ✅

- `isMinifyEnabled = true` — R8 code shrinking
- `isShrinkResources = true` — removes unused Android resources
- `--split-per-abi` — splits APKs by CPU architecture
- No bundled image/font assets in `pubspec.yaml`
- Dart source is tiny (28 `.dart` files, ~131 KB)
- Only 4 direct dependencies: `dio`, `socket_io_client`, `shared_preferences`, `provider`

---

## Proposed Changes

### Part 1: SDK Version Update

#### [MODIFY] [`build.gradle.kts`](file:///d:/Hospital/hospital_patient_app/android/app/build.gradle.kts)

```diff
 android {
     namespace = "com.hospital.hospital_patient_app"
-    compileSdk = flutter.compileSdkVersion
+    compileSdk = 35
     ndkVersion = flutter.ndkVersion
     ...
     defaultConfig {
         applicationId = "com.hospital.hospital_patient_app"
-        minSdk = flutter.minSdkVersion
-        targetSdk = flutter.targetSdkVersion
+        minSdk = 30
+        targetSdk = 35
```

All other Android config files audited — no changes needed ([`AndroidManifest.xml`](file:///d:/Hospital/hospital_patient_app/android/app/src/main/AndroidManifest.xml), [`settings.gradle.kts`](file:///d:/Hospital/hospital_patient_app/android/settings.gradle.kts), [`gradle.properties`](file:///d:/Hospital/hospital_patient_app/android/gradle.properties)).

---

### Part 2: Size Optimizations

#### Optimization 1 — Dart Obfuscation + Split Debug Info

**Estimated savings: ~1–2 MB** (removes readable Dart symbol names from the AOT snapshot)

The `--obfuscate` flag replaces all Dart identifiers with short random names. The `--split-debug-info` flag strips Dart debug symbols out of the binary and saves them to a separate folder (needed for stack trace symbolization later).

**How**: Change the release build command from:
```bash
flutter build apk --release --split-per-abi
```
to:
```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/debug-info
```

> [!IMPORTANT]
> After enabling obfuscation, `Object.runtimeType`, `StackTrace.toString()`, and `Enum.toString()` will return obfuscated (unreadable) names at runtime. This should not affect your app since it doesn't rely on runtime type names for display or logic. The debug symbols saved in `build/debug-info/` can be used with `flutter symbolize` to decode crash stack traces later.

---

#### Optimization 2 — Tree-Shake Material Icons

**Estimated savings: ~0.5–1 MB** (removes unused icon glyphs from `MaterialIcons-Regular.otf`)

Flutter's `--tree-shake-icons` flag is enabled by default in release builds since Flutter 1.22+. Let me verify it's not accidentally disabled. We'll ensure it's explicitly passed.

**How**: Add `--tree-shake-icons` to the build command (already default, but making it explicit):
```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/debug-info --tree-shake-icons
```

---

#### Optimization 3 — Tighten ProGuard Rules

**Estimated savings: ~0.1–0.3 MB**

The current [`proguard-rules.pro`](file:///d:/Hospital/hospital_patient_app/android/app/proguard-rules.pro) uses broad `-keep` rules that prevent R8 from shrinking some classes. Since this is a pure Flutter app (no Java/Kotlin reflection on these classes from your side), we can tighten it.

#### [MODIFY] [`proguard-rules.pro`](file:///d:/Hospital/hospital_patient_app/android/app/proguard-rules.pro)

```diff
 # Flutter Wrapper / Engine
--keep class io.flutter.app.** { *; }
--keep class io.flutter.plugin.**  { *; }
--keep class io.flutter.util.**  { *; }
--keep class io.flutter.view.**  { *; }
--keep class io.flutter.** { *; }
--keep class io.flutter.plugins.** { *; }
 -dontwarn io.flutter.embedding.**
+-keep class io.flutter.app.** { *; }
+-keep class io.flutter.plugin.** { *; }
+-keep class io.flutter.util.** { *; }
+-keep class io.flutter.view.** { *; }
+-keep class io.flutter.embedding.** { *; }
+-keep class io.flutter.plugins.** { *; }

 # Dio / OkHttp
 -dontwarn okhttp3.**
 -dontwarn okio.**
 -dontwarn javax.annotation.**
--keep class okhttp3.** { *; }
--keep interface okhttp3.** { *; }
+-keepclassmembers class okhttp3.** { *; }
+-keepclassmembers interface okhttp3.** { *; }

 # Socket.IO
 -dontwarn io.socket.**
--keep class io.socket.** { *; }
--keep class io.socket.client.** { *; }
--keep class io.socket.engineio.client.** { *; }
--keep class org.json.** { *; }
+-keep class io.socket.client.** { *; }
+-keep class io.socket.engineio.client.** { *; }
+-dontwarn org.json.**
```

Key changes:
- Removed the redundant broad `io.flutter.**` keep (the specific sub-packages already cover it).
- Added `io.flutter.embedding.**` as a keep instead of just suppressing warnings.
- Tightened OkHttp rules from `keep` → `keepclassmembers` (R8 can now rename/remove unused OkHttp classes).
- Removed the overly broad `io.socket.**` keep (only `client` and `engineio.client` are needed).
- `org.json.**` is part of the Android framework and doesn't need a `keep` — just suppress warnings.

---

#### Optimization 4 — Remove Legacy `drawable-v21`

**Estimated savings: negligible (~0.5 KB)** but it's dead code cleanup.

Since `minSdk` will be 30, the `drawable-v21` qualified resource folder (which targets API 21+) is redundant — the base `drawable/` folder is always used on API 30+.

#### [DELETE] [`drawable-v21/`](file:///d:/Hospital/hospital_patient_app/android/app/src/main/res/drawable-v21)

---

#### Optimization 5 — Use App Bundle (AAB) for Distribution

**Impact: Users download ~15–18 MB instead of ~50 MB**

This isn't a code change but a distribution strategy:

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```

Google Play generates per-device optimized APKs from the AAB, delivering only the needed ABI, screen density, and language resources. If you distribute via sideloading, the `--split-per-abi` APKs are already optimal.

---

## Optimization Summary

| # | Optimization | Change Type | Est. Savings | Risk |
|---|---|---|---|---|
| 1 | Dart obfuscation + split debug info | Build flags | **~1–2 MB** | Low — only affects stack trace readability |
| 2 | Tree-shake Material Icons | Build flag (verify) | **~0.5–1 MB** | None |
| 3 | Tighten ProGuard rules | File edit | **~0.1–0.3 MB** | Low — test release build for crashes |
| 4 | Remove `drawable-v21` | Delete folder | **~0.5 KB** | None |
| 5 | Use AAB for distribution | Distribution change | **~30 MB for end users** | None |

**Total estimated per-ABI APK size after optimizations: ~14.5–16 MB** (down from 17.66 MB for arm64)

> [!NOTE]
> The Flutter engine (`libflutter.so`) is ~9–10 MB and is an irreducible fixed cost. A "Hello World" Flutter app is ~8–10 MB. Your app at ~15–16 MB after these optimizations means only ~5–6 MB is your code + dependencies, which is already very lean.

---

## Verification Plan

### Step 1 — Build with all optimizations and compare sizes
```bash
cd d:\Hospital\hospital_patient_app
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/debug-info --tree-shake-icons
```

Compare output APK sizes against the baseline table above.

### Step 2 — Smoke test on device/emulator
Install the arm64 APK on an Android 11+ device and verify:
- App launches without crashes
- All screens render correctly
- API calls and Socket.IO connections work
- Localization switching (EN/HI/GU) works

### Step 3 — Optional size analysis
For a detailed size breakdown, run:
```bash
flutter build apk --release --analyze-size --target-platform=android-arm64
```
This generates a visual size report showing exactly what contributes to the binary.
