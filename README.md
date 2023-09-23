# time_it

A simple application to support timing sport activities.

# Resources

- [stopwatch](images/svg/stopwatch.svg) from
  [here](https://dryicons.com/icon/stopwatch-icon-5725)
- [interval_completed](assets/audio/interval_completed.mp3) from
  [here](https://www.zedge.net/ringtone/fdbdbd2e-46ae-35ef-adaa-f343ef3204c7)
- [workout_completed](assets/audio/workout_completed.mp3) from
  [here](https://www.zedge.net/ringtone/99a9a13c-2881-32ff-aa8b-84302fb3532c)

# Building

This application uses Firebase so it requires its configuration files to build,
which are **NOT** checked in. Anybody who wants to build this app needs to:
- Fork this repo.
- Ideally, replace the `com.szczyp.time_it` (Android) and `com.szczyp.timeIt`
  (iOS) strings in the whole repository (just a few places) with their own
  package/bundle ids. At the very least:
  - (Android) Update the `applicationId` [here](android/app/build.gradle).
  - (iOS) Update the `PRODUCT_BUNDLE_IDENTIFIER`
    [here](ios/Runner.xcodeproj/project.pbxproj) (3 places, one for each build
    configuration).
- Register their own Firebase project and provide its configuration file(s) for
  the platform they want to build for: `google-services.json` for Android and/or
  `GoogleService-Info.plist` for iOS - just follow Firebase docs.
- For the GitHub workflow [here](.github/workflows/main.yml), to build the APK a
  GitHub repository secret named `DUMMY_GOOGLE_SERVICES_JSON` needs to be
  created with the contents of the Firebase config file to use. Not all fields
  found in the real file are necessary, but it is easiest to just copy the
  contents.

Alternatively, remove Firebase integration in code. Note that it will limit the
functionality of this application. If you do this, also edit the workflow file
mentioned above by removing the step creating the dummy Firebase config file.

# Used Firebase features

- Crashlytics.

# Test coverage

There is nothing to be proud of, but there do exist a few tests. Running them
with
```shell
flutter test --coverage
```
will create a coverage report in `coverage/lcov.info`. Running
```shell
genhtml coverage/lcov.info -o coverage/html
```
will generate an HTML report.

To get the `genhtml` tool you need to install LCOV, e.g. macOS with Homebrew:
```shell
brew install lcov
```

# Upgrading checklist

1. Upgrade Flutter, if available and desired.
   1. Update `pubspec.yaml` to specify the same versions as defined unser `sdks` in `pubspec.lock`, for example:
      ```yaml
      environment:
        sdk: '>=3.1.1 <4.0.0'
        flutter: '>=3.13.3'
      ```
    1. Update [ci.yaml](.github/workflows/ci.yaml) to use the Flutter version as the `flutter` dependency. In the above
       example, it is `3.13.3`.
1. `flutter create --platforms android,ios .` and evaluate changes.
1. Possibly upgrade Android tools (Kotlin, Gradle, AGP, ...).
1. Possibly update Android `minSdkVersion` [here](android/app/build.gradle).
1. Possibly upgrade iOS tools (CocoaPods, ...).
1. Possibly update iOS `IPHONEOS_DEPLOYMENT_TARGET`
   [here](ios/Runner.xcodeproj/project.pbxproj) and `platform` [here](ios/Podfile).
1. Upgrade dependencies (`flutter pub upgrade`), observe specific notes in `pubspec.yaml`, if any.
1. Update dependency versions in `pubspec.yaml` to correspond to `pubspec.lock`.
1. Update [lints](analysis_options.yaml) (see notes in the file).
1. Build and test Android.
1. Build and test iOS (this often results in file changes as well).
