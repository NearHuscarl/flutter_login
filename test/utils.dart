import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_login/src/constants.dart';
import 'package:flutter_login/src/widgets/animated_button.dart';

// TODO: get this value from fluter_login package
const loadingAnimationDuration = Duration(seconds: 1);

class LoginCallback {
  Future<String>? onLogin(LoginData? data) => null;
  Future<String>? onSignup(LoginData? data) => null;
  Future<String>? onRecoverPassword(String? data) => null;
  String? emailValidator(String? value) => null;
  String? passwordValidator(String? value) => null;
  void onSubmitAnimationCompleted() {}
}

class MockCallback extends Mock implements LoginCallback {}

final mockCallback = MockCallback();

List<LoginData> stubCallback(MockCallback mockCallback) {
  reset(mockCallback);

  final user = LoginData(name: 'near@gmail.com', password: '12345');
  final invalidUser = LoginData(name: 'not.exists@gmail.com', password: '');

  when(mockCallback.emailValidator(user.name)).thenReturn(null);
  when(mockCallback.emailValidator('invalid-name')).thenReturn('Invalid!');

  when(mockCallback.passwordValidator(user.password)).thenReturn(null);
  when(mockCallback.passwordValidator('invalid-name')).thenReturn('Invalid!');

  when(mockCallback.onLogin(user)).thenAnswer((_) => null);
  when(mockCallback.onLogin(invalidUser))
      .thenAnswer((_) => Future.value('Invalid!'));

  when(mockCallback.onSignup(user)).thenAnswer((_) => null);
  when(mockCallback.onSignup(invalidUser))
      .thenAnswer((_) => Future.value('Invalid!'));

  return [user, invalidUser];
}

Widget defaultFlutterLogin() {
  return MaterialApp(
    home: FlutterLogin(
      onSignup: (data) => null,
      onLogin: (data) => null,
      onRecoverPassword: (data) => null,
    ),
  );
}

Widget widget(Widget widget) {
  return MaterialApp(
    home: widget,
  );
}

Future<void> simulateOpenSoftKeyboard(
  WidgetTester tester,
  Widget widget,
) async {
  // Open soft keyboard on small devices will rebuild the whole screen
  // tester.enterText() seems to only insert text in [EditableText] without
  // opening/closing the actual soft keyboard, hidding the side effects in
  // the real environment
  await tester.pumpWidget(widget);
}

bool? isSignup(WidgetTester tester) {
  return confirmPasswordTextFieldWidget(tester).enabled;
}

Finder findLogoImage() {
  return find.byType(Image);
}

Finder findTitle() {
  return find.byKey(kTitleKey);
}

Finder findNameTextField() {
  return find.byType(TextFormField).at(0);
}

Finder findPasswordTextField() {
  return find.byType(TextFormField).at(1);
}

Finder findConfirmPasswordTextField() {
  return find.byType(TextFormField).at(2);
}

Finder findForgotPasswordButton() {
  return find.byType(MaterialButton).at(0);
}

Finder findSwitchAuthButton() {
  return find.byType(MaterialButton).at(1);
}

Finder findDebugToolbar() {
  return find.byKey(kDebugToolbarKey);
}

Image logoWidget(WidgetTester tester) {
  return tester.widget<Image>(findLogoImage());
}

TextField nameTextFieldWidget(WidgetTester tester) {
  return tester.widgetList<TextField>(find.byType(TextField)).elementAt(0);
}

TextField passwordTextFieldWidget(WidgetTester tester) {
  return tester.widgetList<TextField>(find.byType(TextField)).elementAt(1);
}

TextField confirmPasswordTextFieldWidget(WidgetTester tester) {
  return tester.widgetList<TextField>(find.byType(TextField)).elementAt(2);
}

AnimatedButton submitButtonWidget() {
  return find.byType(AnimatedButton).evaluate().first.widget as AnimatedButton;
}

TextButton forgotPasswordButtonWidget() {
  return find.byType(TextButton).evaluate().first.widget as TextButton;
}

MaterialButton switchAuthButtonWidget() {
  return find.byType(MaterialButton).evaluate().last.widget as MaterialButton;
}

MaterialButton goBackButtonWidget() {
  return find.byType(MaterialButton).evaluate().last.widget as MaterialButton;
}

Text recoverIntroTextWidget() {
  return find.byKey(kRecoverPasswordIntroKey).evaluate().single.widget as Text;
}

Text recoverDescriptionTextWidget() {
  return find.byKey(kRecoverPasswordDescriptionKey).evaluate().single.widget
      as Text;
}

// tester.tap() not working for some reasons. Workaround:
// https://github.com/flutter/flutter/issues/31066#issuecomment-530507319
void clickSubmitButton() => submitButtonWidget().onPressed!();
void clickForgotPasswordButton() => forgotPasswordButtonWidget().onPressed!();
void clickGoBackButton() => goBackButtonWidget().onPressed!();
void clickSwitchAuthButton() => switchAuthButtonWidget().onPressed!();

/// this prevents this error:
/// A Timer is still pending even after the widget tree was disposed.
/// the flushbar in my code is displayed for 4 seconds. So we wait for it to
/// go away.
/// https://stackoverflow.com/a/57930945/9449426
void waitForFlushbarToClose(WidgetTester tester) async =>
    await tester.pumpAndSettle(const Duration(seconds: 4));
