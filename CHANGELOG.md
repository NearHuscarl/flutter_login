## 3.1.0
Features:
* Add children parameter to FlutterLogin which takes a list of widgets that can be added in the
background of the Login view. For example: a custom banner or a custom logo.
* Improved footer style

Bugs fixed:
* The signup confirmation page is now also shown when additionalSignupData is not provided or loginAfterSignUp is disabled. 
* Back button of confirmSignUp page now returns Login or AdditionalSignUpData page depending on whether additionalSignupData has been provided or not.


## 3.0.0
First stable release of 3.0.0.
Please see the changelog entries of the beta versions for all changes.
New features include:
* Additional signup fields!
* Confirmation card for password recovery.
* Confirmation card for user registration.

This release also fixes:
* White space visible when animation is complete
* Several other animation improvements

## 3.0.0-beta.2
Besides the existing loginProvider icons, you can now also add a LoginButton as provider widget.
Please check out [flutter_signin_button](https://pub.dev/packages/flutter_signin_button) for supported buttons.

BREAKING CHANGES:
* Provider has been updated to 6.0.1.
* Instead of hideSignUpButton, you can now set onSignup parameter to null (or just leave it out) in
order to hide the signup button.
  
Fixed several other small bugs like color not being applied correctly to all widgets.

## 3.0.0-beta.1
You can now add more signup-fields! Please keep in mind that this is a beta release and may still
contain bugs.

Other features:
* You can now use an ImageProvider instead of only an AssetImage. [#216](https://github.com/NearHuscarl/flutter_login/pull/216)

## 2.2.1
Bug fixes
* Fixes issue with switch auth button not calculating correct color. [#210](https://github.com/NearHuscarl/flutter_login/pull/210)

## 2.2.0
Features
* Added possibility to disable custom page transformer. [#202](https://github.com/NearHuscarl/flutter_login/pull/202)
* Added possibility to automatically navigate back to login page after successful recovery. [#207](https://github.com/NearHuscarl/flutter_login/pull/207)

Bug fixes
* Fixed primary color not applying to input decoration. ([@SalahAdDin](https://github.com/SalahAdDin) in [#201](https://github.com/NearHuscarl/flutter_login/pull/201))
* Fixed forgot password button not coloring. [#203](https://github.com/NearHuscarl/flutter_login/pull/203)
* Fixed black text when night mode is enabled and no other theme is provided. [#206](https://github.com/NearHuscarl/flutter_login/pull/206)
* Fixed routing issue in example app. [#204](https://github.com/NearHuscarl/flutter_login/pull/204)

## 2.1.0
Features
* Added possibility to change switch authentication button color. [#195](https://github.com/NearHuscarl/flutter_login/pull/195)
* Added possibility to change logo size. [#193](https://github.com/NearHuscarl/flutter_login/pull/193)
* Added labels to LoginProviders. [#192](https://github.com/NearHuscarl/flutter_login/pull/192)
* Added a bar with title/description above providers. Can be disabled using hideProvidersTitle. See [#181](https://github.com/NearHuscarl/flutter_login/pull/181)

Bug fixes
* Fixed animation padding not filling screen. [#194](https://github.com/NearHuscarl/flutter_login/pull/194)

## 2.0.0
Stable release of null-safety

Changed
* emailValidator is now userValidator

Features
* Add bottom padding to LoginTheme

Also fixed numerous other bugs.

## 2.0.0-nullsafety.0
Migrated to null-safety

## 1.1.0
Features (30/03/2021)
* Possibility to hide the sign-up and forgot password button [#115](https://github.com/NearHuscarl/flutter_login/pull/115)
* Possibility to provide flushbar title [#117](https://github.com/NearHuscarl/flutter_login/pull/117)
* Support for auto-fill hints [#125](https://github.com/NearHuscarl/flutter_login/pull/125)
* Possibility to navigate back to login after sign-up [#126](https://github.com/NearHuscarl/flutter_login/pull/126)
* Support for external login providers [#127](https://github.com/NearHuscarl/flutter_login/pull/127)
* Footer for copyright notice [#129](https://github.com/NearHuscarl/flutter_login/pull/129)
* Add custom padding to sign-up and login provider buttons [#135](https://github.com/NearHuscarl/flutter_login/pull/135)
* Possibility to only show logo without title

Bug fixes
* Add safe area to header
* Scaffold is now transparent so background images are now supported
* Fix logo size
* Disable auto-correct for text field

## 1.0.15
Bug fixes (16/03/2021)
* Fixed animationController methods should not be used after calling dispose [#114](https://github.com/NearHuscarl/flutter_login/pull/114)
* Upgrade to AndroidX [#111](https://github.com/NearHuscarl/flutter_login/pull/111)
* Upgrade Android example to embedding V2 [#110](https://github.com/NearHuscarl/flutter_login/pull/110)
* Fixed initialRoute function [#110](https://github.com/NearHuscarl/flutter_login/pull/110)
* Added pedantic for code analysis [#110](https://github.com/NearHuscarl/flutter_login/pull/110)
* Migrated discontinued flushbar to another_flushbar [#110](https://github.com/NearHuscarl/flutter_login/pull/110)
* Updated all deprecated widgets to current widgets [#110](https://github.com/NearHuscarl/flutter_login/pull/110)
* Fixed widget_test [#110](https://github.com/NearHuscarl/flutter_login/pull/110)

## 1.0.14
Fix signup textfield not selectable in signup mode (26/01/2020)
* [#34](https://github.com/NearHuscarl/flutter_login/issues/34)

## 1.0.13+1
Update dependency (23/01/2020)
* Update Provider dependency [#35](https://github.com/NearHuscarl/flutter_login/issues/35)

## 1.0.13 
Minor improvements and Bug fix(es) (23/01/2020)
* Share email input between login and recovery cards ([@doc-rj-celltrak](https://github.com/doc-rj-celltrak) in [#13](https://github.com/NearHuscarl/flutter_login/pull/13))
* Fix render overflow exceptions [#20](https://github.com/NearHuscarl/flutter_login/issues/20)

## 1.0.11
Misc bug fixes (17/01/2020)
- Attempt to fix text not centered in the web build
- Fix exception on submit when onSubmitAnimationCompleted is empty
- Fix: test failed due to framework error

## 1.0.10+1
Fix example's logo hero animation (11/12/2019)

## 1.0.10
Extend configurations & bug fixes (09/12/2019)
* Add `pageColorLight` and `pageColorDark` to customize screen background color gradients ([@doc-rj-celltrak](https://github.com/doc-rj-celltrak) in [#12](https://github.com/NearHuscarl/flutter_login/pull/12))
* Add configurable intro to recovery card ([@doc-rj-celltrak](https://github.com/doc-rj-celltrak) in [#9](https://github.com/NearHuscarl/flutter_login/pull/9))
* Fix empty/null title still takes empty space (should be collapse) ([@doc-rj-celltrak](https://github.com/doc-rj-celltrak) in [#10](https://github.com/NearHuscarl/flutter_login/pull/10))
* Fix hardcode button width ([@doc-rj-celltrak](https://github.com/doc-rj-celltrak) in [#17](https://github.com/NearHuscarl/flutter_login/pull/17))
* Fix crashing when applying `primaryColor` ([@doc-rj-celltrak](https://github.com/doc-rj-celltrak) in [#11](https://github.com/NearHuscarl/flutter_login/pull/11))

## 1.0.4
Add option to disable debug buttons (11/10/2019)

## 1.0.3
* Fix app crashing when omitting `logoPath` parameter

## 1.0.2
Add license

## 1.0.1
Fix Document
* Fix image not loading on pub.dev README
* Reduce font size in description column

## 1.0.0
Initial release