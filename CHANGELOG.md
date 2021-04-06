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