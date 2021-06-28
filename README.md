# time_it

A simple application to support timing sport activities.

# Resources

- [stopwatch](images/svg/stopwatch.svg) from
  [here](https://dryicons.com/icon/stopwatch-icon-5725)
- [timer alarm](assets/audio/timer_alarm.mp3) from
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
