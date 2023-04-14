import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_login/src/constants.dart';
import 'package:flutter_login/src/widgets/animated_text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'utils.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void setScreenSize(Size size) {
    binding.window.physicalSizeTestValue = size;
    binding.window.devicePixelRatioTestValue = 1.0;
  }

  void clearScreenSize() {
    binding.window.clearPhysicalSizeTestValue();
  }

  testWidgets('Default email validator throws error if not match email regex',
      (WidgetTester tester) async {
    await tester.pumpWidget(defaultFlutterLogin());

    // wait for loading animation to finish
    await tester.pumpAndSettle();

    // empty email
    await simulateOpenSoftKeyboard(tester, defaultFlutterLogin());
    await tester.enterText(findNameTextField(), '');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    // TODO: put error messages into variables
    expect(nameTextFieldWidget(tester).decoration!.errorText, 'Invalid email!');

    // missing '@'
    await simulateOpenSoftKeyboard(tester, defaultFlutterLogin());
    await tester.enterText(findNameTextField(), 'neargmail.com');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).decoration!.errorText, 'Invalid email!');

    // missing the part before '@'
    await simulateOpenSoftKeyboard(tester, defaultFlutterLogin());
    await tester.enterText(findNameTextField(), '@gmail.com');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).decoration!.errorText, 'Invalid email!');

    // missing the part after '@'
    await simulateOpenSoftKeyboard(tester, defaultFlutterLogin());
    await tester.enterText(findNameTextField(), 'near@.com');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).decoration!.errorText, 'Invalid email!');

    // missing domain extension (.com, .org...)
    await simulateOpenSoftKeyboard(tester, defaultFlutterLogin());
    await tester.enterText(findNameTextField(), 'near@gmail');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).decoration!.errorText, 'Invalid email!');

    // valid email based on default validator
    await simulateOpenSoftKeyboard(tester, defaultFlutterLogin());
    await tester.enterText(findNameTextField(), 'near@gmail.com');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).decoration!.errorText, null);
  });

  testWidgets(
      'Default password validator throws error if password is less than 3 characters',
      (WidgetTester tester) async {
    await tester.pumpWidget(defaultFlutterLogin());

    // wait for loading animation to finish
    await tester.pumpAndSettle();

    // empty
    await simulateOpenSoftKeyboard(tester, defaultFlutterLogin());
    await tester.enterText(findPasswordTextField(), '');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(
      passwordTextFieldWidget(tester).decoration!.errorText,
      'Password is too short!',
    );

    // too short
    await simulateOpenSoftKeyboard(tester, defaultFlutterLogin());
    await tester.enterText(findPasswordTextField(), '12');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(
      passwordTextFieldWidget(tester).decoration!.errorText,
      'Password is too short!',
    );

    // valid password based on default validator
    await simulateOpenSoftKeyboard(tester, defaultFlutterLogin());
    await tester.enterText(findPasswordTextField(), '123');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(passwordTextFieldWidget(tester).decoration!.errorText, null);

    // valid password based on default validator
    await simulateOpenSoftKeyboard(tester, defaultFlutterLogin());
    await tester.enterText(
      findPasswordTextField(),
      'aslfjsldfjlsjflsfjslfklsdjflsdjf',
    );
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(passwordTextFieldWidget(tester).decoration!.errorText, null);
  });

  testWidgets('Confirm password field throws error if not match with password',
      (WidgetTester tester) async {
    await tester.pumpWidget(defaultFlutterLogin());

    // wait for loading animation to finish
    await tester.pumpAndSettle();

    // click register button to expand confirm password TextField (hidden when login)
    clickSwitchAuthButton();
    await tester.pumpAndSettle();
    expect(isSignup(tester), true);

    // not match
    await simulateOpenSoftKeyboard(tester, defaultFlutterLogin());
    await tester.enterText(findPasswordTextField(), 'abcde');
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), 'abcdE');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(passwordTextFieldWidget(tester).decoration!.errorText, null);
    expect(
      confirmPasswordTextFieldWidget(tester).decoration!.errorText,
      LoginMessages.defaultConfirmPasswordError,
    );

    // match
    await simulateOpenSoftKeyboard(tester, defaultFlutterLogin());
    await tester.enterText(findPasswordTextField(), 'abcdE');
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), 'abcdE');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(passwordTextFieldWidget(tester).decoration!.errorText, null);
    expect(confirmPasswordTextFieldWidget(tester).decoration!.errorText, null);
  });

  testWidgets('Custom userValidator should show error when return a string',
      (WidgetTester tester) async {
    Widget loginBuilder() => widget(
          FlutterLogin(
            onSignup: (data) => null,
            onLogin: (data) => null,
            onRecoverPassword: (data) => null,
            userValidator: (value, authMode) =>
                value!.endsWith('.com') ? null : 'Invalid!',
          ),
        );
    await tester.pumpWidget(loginBuilder());
    await tester.pumpAndSettle(loadingAnimationDuration);

    // invalid value
    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), 'abc.org');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).decoration!.errorText, 'Invalid!');

    // valid value
    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), 'abc.com');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).decoration!.errorText, null);
  });

  testWidgets('Custom passwordValidator should show error when return a string',
      (WidgetTester tester) async {
    Widget loginBuilder() => widget(
          FlutterLogin(
            onSignup: (data) => null,
            onLogin: (data) => null,
            onRecoverPassword: (data) => null,
            passwordValidator: (value, authMode) =>
                value!.length == 5 ? null : 'Invalid!',
          ),
        );
    await tester.pumpWidget(loginBuilder());
    await tester.pumpAndSettle(loadingAnimationDuration);

    // invalid value
    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findPasswordTextField(), '123456');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(passwordTextFieldWidget(tester).decoration!.errorText, 'Invalid!');

    // valid value
    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findPasswordTextField(), '12345');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(passwordTextFieldWidget(tester).decoration!.errorText, null);
  });

  // TODO: Wait for fix for Flutter 3
  // https://github.com/cmdrootaccess/another-flushbar/issues/58
  // testWidgets('Password recovery should show success message if email is valid',
  //     (WidgetTester tester) async {
  //   const users = ['near@gmail.com', 'hunter69@gmail.com'];
  //   loginBuilder() => widget(FlutterLogin(
  //         onSignup: (data) => null,
  //         onLogin: (data) => null,
  //         onRecoverPassword: (data) =>
  //             users.contains(data) ? null : Future.value('User not exists'),
  //         userValidator: (value) => null,
  //       ));
  //   await tester.pumpWidget(loginBuilder());
  //   await tester.pumpAndSettle(loadingAnimationDuration);
  //
  //   // Go to forgot password page
  //   clickForgotPasswordButton();
  //   await tester.pumpAndSettle();
  //
  //   // invalid name
  //   await simulateOpenSoftKeyboard(tester, loginBuilder());
  //   await tester.enterText(findNameTextField(), 'not.exists@gmail.com');
  //   await tester.pumpAndSettle();
  //   clickSubmitButton();
  //   await tester.pump(); // First pump is to active the animation
  //   await tester.pump(
  //       const Duration(seconds: 4)); // second pump is to open the flushbar
  //
  //   expect(find.text('User not exists'), findsOneWidget);
  //
  //   // valid name
  //   await simulateOpenSoftKeyboard(tester, loginBuilder());
  //   await tester.enterText(findNameTextField(), 'near@gmail.com');
  //   await tester.pumpAndSettle();
  //   clickSubmitButton();
  //   await tester.pump(); // First pump is to active the animation
  //   await tester.pump(
  //       const Duration(seconds: 4)); // second pump is to open the flushbar
  //
  //   expect(
  //       find.text(LoginMessages.defaultRecoverPasswordSuccess), findsOneWidget);
  //   waitForFlushbarToClose(tester);
  // });

  testWidgets('Custom login messages should display correct texts',
      (WidgetTester tester) async {
    const recoverIntro = "Don't feel bad. Happens all the time.";
    const recoverDescription =
        'Lorem Ipsum is simply dummy text of the printing and typesetting industry';
    const recoverSuccess = 'Password rescued successfully';
    Widget loginBuilder() => widget(
          FlutterLogin(
            onSignup: (data) => null,
            onLogin: (data) => null,
            onRecoverPassword: (data) => null,
            messages: LoginMessages(
              userHint: 'User',
              passwordHint: 'Pass',
              confirmPasswordHint: 'Confirm',
              loginButton: 'LOG IN',
              signupButton: 'REGISTER',
              forgotPasswordButton: 'Forgot huh?',
              recoverPasswordButton: 'HELP ME',
              goBackButton: 'GO BACK',
              confirmPasswordError: 'Not match!',
              recoverPasswordIntro: recoverIntro,
              recoverPasswordDescription: recoverDescription,
              recoverPasswordSuccess: recoverSuccess,
            ),
          ),
        );
    await tester.pumpWidget(loginBuilder());
    await tester.pumpAndSettle(loadingAnimationDuration);

    var nameTextField = nameTextFieldWidget(tester);
    expect(nameTextField.decoration!.labelText, 'User');
    expect(find.text('User'), findsOneWidget);

    final passwordTextField = passwordTextFieldWidget(tester);
    expect(passwordTextField.decoration!.labelText, 'Pass');
    expect(find.text('Pass'), findsOneWidget);

    final confirmPasswordTextField = confirmPasswordTextFieldWidget(tester);
    expect(confirmPasswordTextField.decoration!.labelText, 'Confirm');
    expect(find.text('Confirm'), findsOneWidget);

    var submitButton = submitButtonWidget();
    expect(submitButton.text, 'LOG IN');
    expect(find.text('LOG IN'), findsOneWidget);

    final forgotPasswordButton = forgotPasswordButtonWidget();
    expect((forgotPasswordButton.child as Text?)?.data, 'Forgot huh?');
    expect(find.text('Forgot huh?'), findsOneWidget);

    final switchAuthButton = switchAuthButtonWidget();
    expect((switchAuthButton.child as AnimatedText?)?.text, 'REGISTER');
    expect(find.text('REGISTER'), findsOneWidget);

    // enter passwords to display not matching error
    clickSwitchAuthButton();
    await tester.pumpAndSettle();
    expect(isSignup(tester), true);

    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findPasswordTextField(), 'abcde');
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), 'abcdE');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(
      confirmPasswordTextFieldWidget(tester).decoration!.errorText,
      'Not match!',
    );

    // Go to forgot password page
    clickForgotPasswordButton();
    await tester.pumpAndSettle();

    nameTextField = nameTextFieldWidget(tester);
    expect(nameTextField.decoration!.labelText, 'User');
    expect(find.text('User'), findsOneWidget);

    submitButton = submitButtonWidget();
    expect(submitButton.text, 'HELP ME');
    expect(find.text('HELP ME'), findsOneWidget);

    final goBackButton = goBackButtonWidget();
    expect((goBackButton.child as Text?)?.data, 'GO BACK');
    expect(find.text('GO BACK'), findsOneWidget);

    final recoverIntroText = recoverIntroTextWidget();
    expect(recoverIntroText.data, recoverIntro);
    expect(find.text(recoverIntro), findsOneWidget);

    final recoverDescriptionText = recoverDescriptionTextWidget();
    expect(recoverDescriptionText.data, recoverDescription);
    expect(find.text(recoverDescription), findsOneWidget);

    // trigger recover password success message
    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), 'near@gmail.com');
    await tester.pumpAndSettle();

    // TODO: Wait for fix for Flutter 3
    // https://github.com/cmdrootaccess/another-flushbar/issues/58
    // clickSubmitButton();
    //
    // await tester.pump(); // First pump is to active the animation
    // await tester.pump(
    //     const Duration(seconds: 4)); // second pump is to open the flushbar
    //
    // expect(find.text(recoverSuccess), findsOneWidget);
    // waitForFlushbarToClose(tester);
  });

  testWidgets('showDebugButtons = false should not show debug buttons',
      (WidgetTester tester) async {
    var flutterLogin = widget(
      FlutterLogin(
        onSignup: (data) => null,
        onLogin: (data) => null,
        onRecoverPassword: (data) => null,
        showDebugButtons: true,
      ),
    );
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    expect(findDebugToolbar(), findsOneWidget);

    flutterLogin = widget(
      FlutterLogin(
        onSignup: (data) => null,
        onLogin: (data) => null,
        onRecoverPassword: (data) => null,
      ),
    );
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    expect(findDebugToolbar(), findsNothing);
  });

  testWidgets('Leave logo parameter empty should not display login logo image',
      (WidgetTester tester) async {
    // default device height is 600. Logo is hidden in all cases because there is no space to display
    setScreenSize(const Size(786, 1024));

    var flutterLogin = widget(
      FlutterLogin(
        onSignup: (data) => null,
        onLogin: (data) => null,
        onRecoverPassword: (data) => null,
      ),
    );
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    expect(findLogoImage(), findsNothing);

    flutterLogin = widget(
      FlutterLogin(
        onSignup: (data) => null,
        onLogin: (data) => null,
        onRecoverPassword: (data) => null,
        logo: const AssetImage('assets/images/ecorp.png'),
      ),
    );
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    expect(findLogoImage(), findsOneWidget);

    // resets the screen to its orinal size after the test end
    addTearDown(() => clearScreenSize());
  });

  testWidgets('Leave title parameter empty should not display login title',
      (WidgetTester tester) async {
    var flutterLogin = widget(
      FlutterLogin(
        onSignup: (data) => null,
        onLogin: (data) => null,
        onRecoverPassword: (data) => null,
        title: '',
      ),
    );
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    expect(findTitle(), findsNothing);

    flutterLogin = widget(
      FlutterLogin(
        onSignup: (data) => null,
        onLogin: (data) => null,
        onRecoverPassword: (data) => null,
      ),
    );
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    expect(findTitle(), findsNothing);

    flutterLogin = widget(
      FlutterLogin(
        onSignup: (data) => null,
        onLogin: (data) => null,
        onRecoverPassword: (data) => null,
        title: 'My Login',
      ),
    );
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    expect(findTitle(), findsOneWidget);
  });

  testWidgets(
      'Login callbacks should be called in order: validating cb > onLogin > onSubmitAnimationCompleted. If one callback fails, the subsequent callbacks will not be invoked',
      (WidgetTester tester) async {
    Widget loginBuilder() => widget(
          FlutterLogin(
            onSignup: (data) => null,
            onLogin: mockCallback.onLogin,
            onRecoverPassword: (data) => null,
            userValidator: mockCallback.userValidator,
            passwordValidator: mockCallback.passwordValidator,
            onSubmitAnimationCompleted: mockCallback.onSubmitAnimationCompleted,
          ),
        );
    await tester.pumpWidget(loginBuilder());
    await tester.pumpAndSettle(loadingAnimationDuration);

    final users = loginStubCallback(mockCallback);
    final user = users[0];
    final invalidUser = users[1];

    // fail at validating
    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), 'invalid-name');
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), user.password);
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyInOrder([
      mockCallback.userValidator('invalid-name', AuthMode.login),
      mockCallback.passwordValidator(user.password, AuthMode.login),
    ]);
    verifyNever(mockCallback.onLogin(any));
    verifyNever(mockCallback.onSubmitAnimationCompleted());

    clearInteractions(mockCallback);

    // fail at onLogin
    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), invalidUser.name);
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), invalidUser.password);
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyInOrder([
      mockCallback.userValidator(invalidUser.name, AuthMode.login),
      mockCallback.passwordValidator(invalidUser.password, AuthMode.login),
      mockCallback.onLogin(any),
    ]);
    verifyNever(mockCallback.onSubmitAnimationCompleted());

    clearInteractions(mockCallback);

    // pass
    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), user.name);
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), user.password);
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyInOrder([
      mockCallback.userValidator(user.name, AuthMode.login),
      mockCallback.passwordValidator(user.password, AuthMode.login),
      mockCallback.onLogin(any),
      mockCallback.onSubmitAnimationCompleted(),
    ]);

    addTearDown(() => reset(mockCallback));
  });

  testWidgets(
      'Signup callbacks should be called in order: validating cb > onSignup > onSubmitAnimationCompleted. If one callback fails, the subsequent callbacks will not be invoked',
      (WidgetTester tester) async {
    Widget loginBuilder() => widget(
          FlutterLogin(
            onLogin: (data) => null,
            onSignup: mockCallback.onSignup,
            onRecoverPassword: (data) => null,
            userValidator: mockCallback.userValidator,
            passwordValidator: mockCallback.passwordValidator,
            onSubmitAnimationCompleted: mockCallback.onSubmitAnimationCompleted,
          ),
        );
    await tester.pumpWidget(loginBuilder());
    await tester.pumpAndSettle(loadingAnimationDuration);

    final users = signupStubCallback(mockCallback);
    final user = users[0];
    final invalidUser = users[1];

    clickSwitchAuthButton();
    await tester.pumpAndSettle();
    expect(isSignup(tester), true);

    // fail at validating - confirm password not match
    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), user.name!);
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), user.password!);
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), 'not-match');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyNever(mockCallback.userValidator(invalidUser.name, AuthMode.signup));
    verifyNever(mockCallback.passwordValidator(invalidUser.password, AuthMode.signup));
    verifyNever(mockCallback.onSignup(any));
    verifyNever(mockCallback.onSubmitAnimationCompleted());

    clearInteractions(mockCallback);

    // fail at validating
    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), 'invalid-name');
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), user.password!);
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), user.password!);
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyInOrder([
      mockCallback.userValidator('invalid-name', AuthMode.signup),
      mockCallback.passwordValidator(user.password, AuthMode.signup),
    ]);
    verifyNever(mockCallback.onSignup(any));
    verifyNever(mockCallback.onSubmitAnimationCompleted());

    clearInteractions(mockCallback);

    // fail at onSignup
    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), invalidUser.name!);
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), invalidUser.password!);
    await tester.pumpAndSettle();
    await tester.enterText(
      findConfirmPasswordTextField(),
      invalidUser.password!,
    );
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyInOrder([
      mockCallback.userValidator(invalidUser.name, AuthMode.signup),
      mockCallback.passwordValidator(invalidUser.password, AuthMode.signup),
      mockCallback.onSignup(any),
    ]);
    verifyNever(mockCallback.onSubmitAnimationCompleted());

    clearInteractions(mockCallback);

    // pass
    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), user.name!);
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), user.password!);
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), user.password!);
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyInOrder([
      mockCallback.userValidator(user.name, AuthMode.signup),
      mockCallback.passwordValidator(user.password, AuthMode.signup),
      mockCallback.onSignup(any),
      mockCallback.onSubmitAnimationCompleted(),
    ]);

    addTearDown(() => reset(mockCallback));
  });

  testWidgets(
      'Signup callbacks with additionalForm should be called in order: validating cb > onSignup > onSubmitAnimationCompleted. If one callback fails, the subsequent callbacks will not be invoked',
      (WidgetTester tester) async {
    Widget loginBuilder() => widget(
          FlutterLogin(
            onLogin: (data) => null,
            onSignup: mockCallback.onSignup,
            onRecoverPassword: (data) => null,
            userValidator: mockCallback.userValidator,
            passwordValidator: mockCallback.passwordValidator,
            onSubmitAnimationCompleted: mockCallback.onSubmitAnimationCompleted,
            additionalSignupFields: <UserFormField>[
              UserFormField(
                keyName: 'Name',
                fieldValidator: (s) => mockCallback.userValidator(s, AuthMode.signup),
              ),
              UserFormField(
                keyName: 'Surname',
                fieldValidator: (s) => mockCallback.userValidator(s, AuthMode.signup),
              ),
            ],
          ),
        );
    await tester.pumpWidget(loginBuilder());
    await tester.pumpAndSettle(loadingAnimationDuration);

    final users = signupStubCallback(mockCallback);
    final user = users[0];
    final invalidUser = users[1];

    clickSwitchAuthButton();
    await tester.pumpAndSettle();
    expect(isSignup(tester), true);

    // fail at validating - confirm password not match
    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), user.name!);
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), user.password!);
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), 'not-match');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyNever(mockCallback.userValidator(invalidUser.name, AuthMode.signup));
    verifyNever(mockCallback.passwordValidator(invalidUser.password, AuthMode.signup));
    verifyNever(mockCallback.onSignup(any));
    verifyNever(mockCallback.onSubmitAnimationCompleted());

    clearInteractions(mockCallback);

    // fail at validating
    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), 'invalid-name');
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), user.password!);
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), user.password!);
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyInOrder([
      mockCallback.userValidator('invalid-name', AuthMode.signup),
      mockCallback.passwordValidator(user.password, AuthMode.signup),
    ]);
    verifyNever(mockCallback.onSignup(any));
    verifyNever(mockCallback.onSubmitAnimationCompleted());

    clearInteractions(mockCallback);

    // fail at onSignup
    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), invalidUser.name!);
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), invalidUser.password!);
    await tester.pumpAndSettle();
    await tester.enterText(
      findConfirmPasswordTextField(),
      invalidUser.password!,
    );
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyInOrder([
      mockCallback.userValidator(invalidUser.name, AuthMode.signup),
      mockCallback.passwordValidator(invalidUser.password, AuthMode.signup),
    ]);
    verifyNever(mockCallback.onSignup(any));
    verifyNever(mockCallback.onSubmitAnimationCompleted());

    clearInteractions(mockCallback);

    // now we should be in the additional signup field card
    expect(
      find.text('Please fill in this form to complete the signup'),
      findsOneWidget,
    );
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Surname'), findsOneWidget);

    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNthField(0), 'foo');
    await tester.pumpAndSettle();
    await tester.enterText(findNthField(1), 'bar');
    await tester.pumpAndSettle();

    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyInOrder([
      mockCallback.userValidator('foo', AuthMode.signup),
      mockCallback.userValidator('bar', AuthMode.signup),
      mockCallback.onSignup(any),
      mockCallback.onSubmitAnimationCompleted(),
    ]);

    addTearDown(() => reset(mockCallback));
  });

  testWidgets(
      'Name, pass and confirm pass fields should remember their content when switching between login/signup and recover password',
      (WidgetTester tester) async {
    await tester.pumpWidget(defaultFlutterLogin());
    await tester.pumpAndSettle(loadingAnimationDuration);

    clickSwitchAuthButton();
    await tester.pumpAndSettle();
    expect(isSignup(tester), true);

    await simulateOpenSoftKeyboard(tester, defaultFlutterLogin());
    await tester.enterText(findNameTextField(), 'near@gmail.com');
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), '12345');
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), 'abcde');
    await tester.pumpAndSettle();

    clickForgotPasswordButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).controller!.text, 'near@gmail.com');

    clickGoBackButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).controller!.text, 'near@gmail.com');
    expect(passwordTextFieldWidget(tester).controller!.text, '12345');
    expect(confirmPasswordTextFieldWidget(tester).controller!.text, 'abcde');
  });

  // https://github.com/NearHuscarl/flutter_login/issues/20
  testWidgets(
      'Logo should be hidden if its height is less than kMinLogoHeight. Logo height should be never larger than kMaxLogoHeight',
      (WidgetTester tester) async {
    final flutterLogin = widget(
      FlutterLogin(
        onSignup: (data) => null,
        onLogin: (data) => null,
        onRecoverPassword: (data) => null,
        logo: const AssetImage('assets/images/ecorp.png'),
        title: 'Yang2020',
      ),
    );

    const veryLargeHeight = 2000.0;
    const enoughHeight = 680.0;
    const verySmallHeight = 500.0;

    setScreenSize(const Size(480, veryLargeHeight));
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);
    expect(logoWidget(tester).height, kMaxLogoHeight);

    setScreenSize(const Size(480, enoughHeight));
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);
    expect(
      logoWidget(tester).height,
      inInclusiveRange(kMinLogoHeight, kMaxLogoHeight),
    );

    setScreenSize(const Size(480, verySmallHeight));
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);
    expect(findLogoImage(), findsNothing);

    // resets the screen to its orinal size after the test end
    addTearDown(() => clearScreenSize());
  });

  // TODO: wait for flutter to add support for testing in web environment on Windows 10
  // https://github.com/flutter/flutter/issues/44583
  // https://github.com/NearHuscarl/flutter_login/issues/7
  testWidgets('AnimatedText should be centered in mobile and web consistently',
      (WidgetTester tester) async {
    await tester.pumpWidget(defaultFlutterLogin());
    await tester.pumpAndSettle(loadingAnimationDuration);

    final text = find.byType(AnimatedText).first;
    debugPrint(tester.getTopLeft(text).toString());
    debugPrint(tester.getCenter(text).toString());
    debugPrint(tester.getBottomRight(text).toString());

    expect(true, true);
  });

  testWidgets(
      'hideSignUpButton & hideForgotPasswordButton should hide SignUp and forgot password button',
      (WidgetTester tester) async {
    Widget loginBuilder() => widget(
          FlutterLogin(
            onLogin: (data) => null,
            onRecoverPassword: (data) => null,
            passwordValidator: (value, authMode) =>
                value!.length == 5 ? null : 'Invalid!',
            hideForgotPasswordButton: true,
            messages: LoginMessages(
              signupButton: 'REGISTER',
              forgotPasswordButton: 'Forgot huh?',
            ),
          ),
        );
    await tester.pumpWidget(loginBuilder());
    await tester.pumpAndSettle(loadingAnimationDuration);
    expect(find.text('REGISTER'), findsNothing);
    expect(find.text('Forgot huh?'), findsNothing);
  });

  testWidgets('providers Title should be shown when there are providers',
      (WidgetTester tester) async {
    Widget loginBuilder() => widget(
          FlutterLogin(
            onSignup: (data) => null,
            onLogin: (data) => null,
            onRecoverPassword: (data) => null,
            passwordValidator: (value, authMode) =>
                value!.length == 5 ? null : 'Invalid!',
            loginProviders: [
              LoginProvider(
                icon: Icons.ac_unit,
                callback: () {
                  return null;
                },
              )
            ],
            messages: LoginMessages(
              signupButton: 'REGISTER',
              forgotPasswordButton: 'Forgot huh?',
            ),
          ),
        );
    await tester.pumpWidget(loginBuilder());
    await tester.pumpAndSettle(loadingAnimationDuration);
    expect(find.text('or login with'), findsOneWidget);
  });

  testWidgets('providers Title should not be shown when there are no providers',
      (WidgetTester tester) async {
    Widget loginBuilder() => widget(
          FlutterLogin(
            onSignup: (data) => null,
            onLogin: (data) => null,
            onRecoverPassword: (data) => null,
            passwordValidator: (value, authMode) =>
                value!.length == 5 ? null : 'Invalid!',
            messages: LoginMessages(
              signupButton: 'REGISTER',
              forgotPasswordButton: 'Forgot huh?',
            ),
          ),
        );
    await tester.pumpWidget(loginBuilder());
    await tester.pumpAndSettle(loadingAnimationDuration);
    expect(find.text('or login with'), findsNothing);
  });
  testWidgets('hideProvidersTitle should hide providers title',
      (WidgetTester tester) async {
    Widget loginBuilder() => widget(
          FlutterLogin(
            onSignup: (data) => null,
            onLogin: (data) => null,
            onRecoverPassword: (data) => null,
            passwordValidator: (value, authMode) =>
                value!.length == 5 ? null : 'Invalid!',
            hideProvidersTitle: true,
            loginProviders: [
              LoginProvider(
                icon: Icons.ac_unit,
                callback: () {
                  return null;
                },
              )
            ],
            messages: LoginMessages(
              signupButton: 'REGISTER',
              forgotPasswordButton: 'Forgot huh?',
            ),
          ),
        );
    await tester.pumpWidget(loginBuilder());
    await tester.pumpAndSettle(loadingAnimationDuration);
    expect(find.text('or login with'), findsNothing);
  });

  // TODO: Wait for fix for Flutter 3
  // https://github.com/cmdrootaccess/another-flushbar/issues/58
  // testWidgets(
  //     'Change flushbar title by setting flushbarTitleError & flushbarTitleSuccess.',
  //     (WidgetTester tester) async {
  //   const users = ['near@gmail.com', 'hunter69@gmail.com'];
  //   loginBuilder() => widget(FlutterLogin(
  //         onSignup: (data) => null,
  //         onLogin: (data) => users.contains(data.name)
  //             ? null
  //             : Future.value('User not exists'),
  //         onRecoverPassword: (data) =>
  //             users.contains(data) ? null : Future.value('User not exists'),
  //         passwordValidator: (value) => null,
  //         messages: LoginMessages(
  //           flushbarTitleError: 'Oh no!',
  //           flushbarTitleSuccess: 'That went well!',
  //         ),
  //       ));
  //   await tester.pumpWidget(loginBuilder());
  //   await tester.pumpAndSettle(loadingAnimationDuration);
  //   await tester.pumpAndSettle();
  //
  //   // Test error flushbar by entering unknown name
  //   await simulateOpenSoftKeyboard(tester, loginBuilder());
  //   await tester.enterText(findNameTextField(), 'not.exists@gmail.com');
  //   await tester.pumpAndSettle();
  //   await tester.enterText(findPasswordTextField(), 'not.exists@gmail.com');
  //   await tester.pumpAndSettle();
  //   clickSubmitButton();
  //
  //   // Because of multiple animations, in order to get to the flushbar we need
  //   // to pump the animations three times.
  //   await tester.pump();
  //   await tester.pump(const Duration(seconds: 4));
  //   await tester.pump(const Duration(seconds: 4));
  //
  //   expect(find.text('Oh no!'), findsOneWidget);
  //
  //   // Test success flushbar by going to the password recovery page and
  //   // successfully request password change.
  //   clickForgotPasswordButton();
  //   await tester.pumpAndSettle();
  //
  //   await simulateOpenSoftKeyboard(tester, loginBuilder());
  //   await tester.enterText(findNameTextField(), 'near@gmail.com');
  //   await tester.pumpAndSettle();
  //   clickSubmitButton();
  //
  //   // Because of multiple animations, in order to get to the flushbar we need
  //   // to pump the animations two times.
  //   await tester.pump();
  //   await tester.pump(const Duration(seconds: 4));
  //
  //   expect(find.text('That went well!'), findsOneWidget);
  //   waitForFlushbarToClose(tester);
  // });

  testWidgets('Redirect to login page after sign up.',
      (WidgetTester tester) async {
    Widget loginBuilder() => widget(
          FlutterLogin(
            loginAfterSignUp: false,
            onSignup: (data) => null,
            onLogin: (data) => null,
            onRecoverPassword: (data) => null,
            passwordValidator: (value, authMode) => null,
          ),
        );
    await tester.pumpWidget(loginBuilder());
    await tester.pumpAndSettle(loadingAnimationDuration);

    clickSwitchAuthButton();
    await tester.pumpAndSettle();
    expect(isSignup(tester), true);

    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), 'near@gmail.com');
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), '12345678');
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), '12345678');
    await tester.pumpAndSettle();

    clickSubmitButton();
    await tester.pumpAndSettle();
    expect(isSignup(tester), false);
  });

  testWidgets(
      'Redirect to signup card if there are additional signup fields, test that filled in fields are passed correctly to the callback',
      (WidgetTester tester) async {
    var signupFields = {};
    Widget loginBuilder() => widget(
          FlutterLogin(
            loginAfterSignUp: false,
            onSignup: (data) {
              signupFields = data.additionalSignupData!;
              return null;
            },
            onLogin: (data) => null,
            onRecoverPassword: (data) => null,
            passwordValidator: (value, authMode) => null,
            additionalSignupFields: const [
              UserFormField(keyName: 'Name'),
              UserFormField(keyName: 'Surname'),
            ],
          ),
        );
    await tester.pumpWidget(loginBuilder());
    await tester.pumpAndSettle(loadingAnimationDuration);

    clickSwitchAuthButton();
    await tester.pumpAndSettle();
    expect(isSignup(tester), true);

    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), 'near@gmail.com');
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), '12345678');
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), '12345678');
    await tester.pumpAndSettle();

    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(
      find.text('Please fill in this form to complete the signup'),
      findsOneWidget,
    );
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Surname'), findsOneWidget);

    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNthField(0), 'foo');
    await tester.pumpAndSettle();
    await tester.enterText(findNthField(1), 'bar');
    await tester.pumpAndSettle();

    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(signupFields['Name'], 'foo');
    expect(signupFields['Surname'], 'bar');
  });

  testWidgets(
      'Redirect to login page after sign up with additional fields when loginAfterSignup is false',
      (WidgetTester tester) async {
    Widget loginBuilder() => widget(
          FlutterLogin(
            loginAfterSignUp: false,
            onSignup: (data) => null,
            onLogin: (data) => null,
            onRecoverPassword: (data) => null,
            passwordValidator: (value, authMode) => null,
            additionalSignupFields: const [
              UserFormField(keyName: 'Name'),
              UserFormField(keyName: 'Surname'),
            ],
          ),
        );

    await tester.pumpWidget(loginBuilder());
    await tester.pumpAndSettle(loadingAnimationDuration);

    clickSwitchAuthButton();
    await tester.pumpAndSettle();
    expect(isSignup(tester), true);

    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), 'near@gmail.com');
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), '12345678');
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), '12345678');
    await tester.pumpAndSettle();

    clickSubmitButton();
    await tester.pumpAndSettle();

    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNthField(0), 'foo');
    await tester.pumpAndSettle();
    await tester.enterText(findNthField(1), 'bar');
    await tester.pumpAndSettle();

    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(isSignup(tester), false);
  });

  testWidgets('Redirect to login page after sign up with additional fields',
      (WidgetTester tester) async {
    var onSubmitAnimationCompletedExecuted = false;
    Widget loginBuilder() => widget(
          FlutterLogin(
            onSignup: (data) => null,
            onLogin: (data) => null,
            onRecoverPassword: (data) => null,
            passwordValidator: (value, authMode) => null,
            additionalSignupFields: const [
              UserFormField(keyName: 'Name'),
              UserFormField(keyName: 'Surname'),
            ],
            onSubmitAnimationCompleted: () =>
                onSubmitAnimationCompletedExecuted = true,
          ),
        );

    await tester.pumpWidget(loginBuilder());
    await tester.pumpAndSettle(loadingAnimationDuration);

    clickSwitchAuthButton();
    await tester.pumpAndSettle();
    expect(isSignup(tester), true);

    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNameTextField(), 'near@gmail.com');
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), '12345678');
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), '12345678');
    await tester.pumpAndSettle();

    clickSubmitButton();
    await tester.pumpAndSettle();

    await simulateOpenSoftKeyboard(tester, loginBuilder());
    await tester.enterText(findNthField(0), 'foo');
    await tester.pumpAndSettle();
    await tester.enterText(findNthField(1), 'bar');
    await tester.pumpAndSettle();

    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(onSubmitAnimationCompletedExecuted, true);
  });

  testWidgets('Check if footer text is visible.', (WidgetTester tester) async {
    Widget loginBuilder() => widget(
          FlutterLogin(
            onSignup: (data) => null,
            onLogin: (data) => null,
            onRecoverPassword: (data) => null,
            passwordValidator: (value, authMode) => null,
            footer: 'Copyright flutter_login',
          ),
        );
    await tester.pumpWidget(loginBuilder());
    await tester.pumpAndSettle(loadingAnimationDuration);

    expect(find.text('Copyright flutter_login'), findsOneWidget);
  });
}
