import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'utils.dart';
import '../lib/flutter_login.dart';
import '../lib/src/widgets/animated_text.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Default email validator throws error if not match email regex',
      (WidgetTester tester) async {
    await tester.pumpWidget(defaultFlutterLogin());

    // wait for loading animation to finish
    await tester.pumpAndSettle();

    // empty email
    await tester.enterText(findNameTextField(), '');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    // TODO: put error messages into variables
    expect(nameTextFieldWidget(tester).decoration.errorText, 'Invalid email!');

    // missing '@'
    await tester.enterText(findNameTextField(), 'neargmail.com');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).decoration.errorText, 'Invalid email!');

    // missing the part before '@'
    await tester.enterText(findNameTextField(), '@gmail.com');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).decoration.errorText, 'Invalid email!');

    // missing the part after '@'
    await tester.enterText(findNameTextField(), 'near@.com');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).decoration.errorText, 'Invalid email!');

    // missing domain extension (.com, .org...)
    await tester.enterText(findNameTextField(), 'near@gmail');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).decoration.errorText, 'Invalid email!');

    // valid email based on default validator
    await tester.enterText(findNameTextField(), 'near@gmail.com');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).decoration.errorText, null);
  });

  testWidgets(
      'Default password validator throws error if password is less than 3 characters',
      (WidgetTester tester) async {
    await tester.pumpWidget(defaultFlutterLogin());

    // wait for loading animation to finish
    await tester.pumpAndSettle();

    // empty
    await tester.enterText(findPasswordTextField(), '');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(passwordTextFieldWidget(tester).decoration.errorText,
        'Password is too short!');

    // too short
    await tester.enterText(findPasswordTextField(), '12');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(passwordTextFieldWidget(tester).decoration.errorText,
        'Password is too short!');

    // valid password based on default validator
    await tester.enterText(findPasswordTextField(), '123');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(passwordTextFieldWidget(tester).decoration.errorText, null);

    // valid password based on default validator
    await tester.enterText(
        findPasswordTextField(), 'aslfjsldfjlsjflsfjslfklsdjflsdjf');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(passwordTextFieldWidget(tester).decoration.errorText, null);
  });

  testWidgets('Confirm password field throws error if not match with password',
      (WidgetTester tester) async {
    await tester.pumpWidget(defaultFlutterLogin());

    // wait for loading animation to finish
    await tester.pumpAndSettle();

    // click register button to expand confirm password TextField (hidden when login)
    clickSwitchAuthButton();
    await tester.pumpAndSettle();

    // not match
    await tester.enterText(findPasswordTextField(), 'abcde');
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), 'abcdE');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(passwordTextFieldWidget(tester).decoration.errorText, null);
    expect(confirmPasswordTextFieldWidget(tester).decoration.errorText,
        LoginMessages.defaultConfirmPasswordError);

    // match
    await tester.enterText(findPasswordTextField(), 'abcdE');
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), 'abcdE');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(passwordTextFieldWidget(tester).decoration.errorText, null);
    expect(confirmPasswordTextFieldWidget(tester).decoration.errorText, null);
  });

  testWidgets('Custom emailValidator should show error when return a string',
      (WidgetTester tester) async {
    final flutterLogin = widget(FlutterLogin(
      onSignup: (data) => null,
      onLogin: (data) => null,
      onRecoverPassword: (data) => null,
      emailValidator: (value) => value.endsWith('.com') ? null : 'Invalid!',
    ));
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    // invalid value
    await tester.enterText(findNameTextField(), 'abc.org');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).decoration.errorText, 'Invalid!');

    // valid value
    await tester.enterText(findNameTextField(), 'abc.com');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).decoration.errorText, null);
  });

  testWidgets('Custom passwordValidator should show error when return a string',
      (WidgetTester tester) async {
    final flutterLogin = widget(FlutterLogin(
      onSignup: (data) => null,
      onLogin: (data) => null,
      onRecoverPassword: (data) => null,
      passwordValidator: (value) => value.length == 5 ? null : 'Invalid!',
    ));
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    // invalid value
    await tester.enterText(findPasswordTextField(), '123456');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(passwordTextFieldWidget(tester).decoration.errorText, 'Invalid!');

    // valid value
    await tester.enterText(findPasswordTextField(), '12345');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(passwordTextFieldWidget(tester).decoration.errorText, null);
  });

  testWidgets("Password recovery should show success message if email is valid",
      (WidgetTester tester) async {
    const users = ['near@gmail.com', 'hunter69@gmail.com'];
    final flutterLogin = widget(FlutterLogin(
      onSignup: (data) => null,
      onLogin: (data) => null,
      onRecoverPassword: (data) =>
          users.contains(data) ? null : Future.value('User not exists'),
      emailValidator: (value) => null,
    ));
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    // Go to forgot password page
    clickForgotPasswordButton();
    await tester.pumpAndSettle();

    // invalid name
    await tester.enterText(findNameTextField(), 'not.exists@gmail.com');
    await tester.pumpAndSettle();
    clickSubmitButton();
    tester.binding.scheduleWarmUpFrame(); // wait for flushbar to show up

    expect(find.text('User not exists'), findsOneWidget);

    // valid name
    await tester.enterText(findNameTextField(), 'near@gmail.com');
    await tester.pumpAndSettle();
    clickSubmitButton();
    tester.binding.scheduleWarmUpFrame(); // wait for flushbar to show up

    expect(
        find.text(LoginMessages.defaultRecoverPasswordSuccess), findsOneWidget);
    waitForFlushbarToClose(tester);
  });

  testWidgets('Custom login messages should display correct texts',
      (WidgetTester tester) async {
    const recoverIntro = "Don't feel bad. Happens all the time.";
    const recoverDescription =
        'Lorem Ipsum is simply dummy text of the printing and typesetting industry';
    const recoverSuccess = 'Password rescued successfully';
    final flutterLogin = widget(FlutterLogin(
      onSignup: (data) => null,
      onLogin: (data) => null,
      onRecoverPassword: (data) => null,
      messages: LoginMessages(
        usernameHint: 'Username',
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
    ));
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    var nameTextField = nameTextFieldWidget(tester);
    expect(nameTextField.decoration.labelText, 'Username');
    expect(find.text('Username'), findsOneWidget);

    final passwordTextField = passwordTextFieldWidget(tester);
    expect(passwordTextField.decoration.labelText, 'Pass');
    expect(find.text('Pass'), findsOneWidget);

    final confirmPasswordTextField = confirmPasswordTextFieldWidget(tester);
    expect(confirmPasswordTextField.decoration.labelText, 'Confirm');
    expect(find.text('Confirm'), findsOneWidget);

    var submitButton = submitButtonWidget();
    expect(submitButton.text, 'LOG IN');
    expect(find.text('LOG IN'), findsOneWidget);

    final forgotPasswordButton = forgotPasswordButtonWidget();
    expect((forgotPasswordButton.child as Text).data, 'Forgot huh?');
    expect(find.text('Forgot huh?'), findsOneWidget);

    final switchAuthButton = switchAuthButtonWidget();
    expect((switchAuthButton.child as AnimatedText).text, 'REGISTER');
    expect(find.text('REGISTER'), findsOneWidget);

    // enter passwords to display not matching error
    clickSwitchAuthButton();
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), 'abcde');
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), 'abcdE');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    expect(confirmPasswordTextFieldWidget(tester).decoration.errorText,
        'Not match!');

    // Go to forgot password page
    clickForgotPasswordButton();
    await tester.pumpAndSettle();

    nameTextField = nameTextFieldWidget(tester);
    expect(nameTextField.decoration.labelText, 'Username');
    expect(find.text('Username'), findsOneWidget);

    submitButton = submitButtonWidget();
    expect(submitButton.text, 'HELP ME');
    expect(find.text('HELP ME'), findsOneWidget);

    final goBackButton = goBackButtonWidget();
    expect((goBackButton.child as Text).data, 'GO BACK');
    expect(find.text('GO BACK'), findsOneWidget);

    final recoverIntroText = recoverIntroTextWidget();
    expect(recoverIntroText.data, recoverIntro);
    expect(find.text(recoverIntro), findsOneWidget);

    final recoverDescriptionText = recoverDescriptionTextWidget();
    expect(recoverDescriptionText.data, recoverDescription);
    expect(find.text(recoverDescription), findsOneWidget);

    // trigger recover password success message
    await tester.pumpAndSettle();
    await tester.enterText(findNameTextField(), 'near@gmail.com');
    await tester.pumpAndSettle();
    clickSubmitButton();

    // For flushbar, pumpAndSettle() does not work. Use this instead
    // https://stackoverflow.com/a/57758137/9449426
    tester.binding.scheduleWarmUpFrame();

    expect(find.text(recoverSuccess), findsOneWidget);
    waitForFlushbarToClose(tester);
  });

  testWidgets('showDebugButtons = false should not show debug buttons',
      (WidgetTester tester) async {
    var flutterLogin = widget(FlutterLogin(
      onSignup: (data) => null,
      onLogin: (data) => null,
      onRecoverPassword: (data) => null,
      showDebugButtons: true,
    ));
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    expect(findDebugToolbar(), findsOneWidget);

    flutterLogin = widget(FlutterLogin(
      onSignup: (data) => null,
      onLogin: (data) => null,
      onRecoverPassword: (data) => null,
      showDebugButtons: false,
    ));
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    expect(findDebugToolbar(), findsNothing);
  });

  testWidgets('Leave logo parameter empty should not display login logo image',
      (WidgetTester tester) async {
    var flutterLogin = widget(FlutterLogin(
      onSignup: (data) => null,
      onLogin: (data) => null,
      onRecoverPassword: (data) => null,
    ));
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    expect(findLogoImage(), findsNothing);

    flutterLogin = widget(FlutterLogin(
      onSignup: (data) => null,
      onLogin: (data) => null,
      onRecoverPassword: (data) => null,
      logo: 'assets/images/ecorp.png',
    ));
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    expect(findLogoImage(), findsOneWidget);
  });

  testWidgets('Leave title parameter empty should not display login title',
      (WidgetTester tester) async {
    var flutterLogin = widget(FlutterLogin(
      onSignup: (data) => null,
      onLogin: (data) => null,
      onRecoverPassword: (data) => null,
      title: '',
    ));
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    expect(findTitle(), findsNothing);

    flutterLogin = widget(FlutterLogin(
      onSignup: (data) => null,
      onLogin: (data) => null,
      onRecoverPassword: (data) => null,
      title: null,
    ));
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    expect(findTitle(), findsNothing);

    flutterLogin = widget(FlutterLogin(
      onSignup: (data) => null,
      onLogin: (data) => null,
      onRecoverPassword: (data) => null,
      title: 'My Login',
    ));
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    expect(findTitle(), findsOneWidget);
  });

  testWidgets(
      'Login callbacks should be called in order: validating cb > onLogin > onSubmitAnimationCompleted. If one callback fails, the subsequent callbacks will not be invoked',
      (WidgetTester tester) async {
    final flutterLogin = widget(FlutterLogin(
      onSignup: (data) => null,
      onLogin: mockCallback.onLogin,
      onRecoverPassword: (data) => null,
      emailValidator: mockCallback.emailValidator,
      passwordValidator: mockCallback.passwordValidator,
      onSubmitAnimationCompleted: mockCallback.onSubmitAnimationCompleted,
    ));
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    final users = stubCallback(mockCallback);
    final user = users[0];
    final invalidUser = users[1];

    // fail at validating
    await tester.enterText(findNameTextField(), 'invalid-name');
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), user.password);
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyInOrder([
      mockCallback.emailValidator('invalid-name'),
      mockCallback.passwordValidator(user.password),
    ]);
    verifyNever(mockCallback.onLogin(any));
    verifyNever(mockCallback.onSubmitAnimationCompleted());

    clearInteractions(mockCallback);

    // fail at onLogin
    await tester.enterText(findNameTextField(), invalidUser.name);
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), invalidUser.password);
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyInOrder([
      mockCallback.emailValidator(invalidUser.name),
      mockCallback.passwordValidator(invalidUser.password),
      mockCallback.onLogin(any),
    ]);
    verifyNever(mockCallback.onSubmitAnimationCompleted());

    clearInteractions(mockCallback);

    // pass
    await tester.enterText(findNameTextField(), user.name);
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), user.password);
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyInOrder([
      mockCallback.emailValidator(user.name),
      mockCallback.passwordValidator(user.password),
      mockCallback.onLogin(any),
      mockCallback.onSubmitAnimationCompleted(),
    ]);

    addTearDown(() => reset(mockCallback));
  });

  testWidgets(
      'Signup callbacks should be called in order: validating cb > onSignup > onSubmitAnimationCompleted. If one callback fails, the subsequent callbacks will not be invoked',
      (WidgetTester tester) async {
    final flutterLogin = widget(FlutterLogin(
      onLogin: (data) => null,
      onSignup: mockCallback.onSignup,
      onRecoverPassword: (data) => null,
      emailValidator: mockCallback.emailValidator,
      passwordValidator: mockCallback.passwordValidator,
      onSubmitAnimationCompleted: mockCallback.onSubmitAnimationCompleted,
    ));
    await tester.pumpWidget(flutterLogin);
    await tester.pumpAndSettle(loadingAnimationDuration);

    final users = stubCallback(mockCallback);
    final user = users[0];
    final invalidUser = users[1];

    clickSwitchAuthButton();
    await tester.pumpAndSettle();

    // fail at validating - confirm password not match
    await tester.enterText(findNameTextField(), user.name);
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), user.password);
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), 'not-match');
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyNever(mockCallback.emailValidator(invalidUser.name));
    verifyNever(mockCallback.passwordValidator(invalidUser.password));
    verifyNever(mockCallback.onSignup(any));
    verifyNever(mockCallback.onSubmitAnimationCompleted());

    clearInteractions(mockCallback);

    // fail at validating
    await tester.enterText(findNameTextField(), 'invalid-name');
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), user.password);
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), user.password);
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyInOrder([
      mockCallback.emailValidator('invalid-name'),
      mockCallback.passwordValidator(user.password),
    ]);
    verifyNever(mockCallback.onSignup(any));
    verifyNever(mockCallback.onSubmitAnimationCompleted());

    clearInteractions(mockCallback);

    // fail at onSignup
    await tester.enterText(findNameTextField(), invalidUser.name);
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), invalidUser.password);
    await tester.pumpAndSettle();
    await tester.enterText(
        findConfirmPasswordTextField(), invalidUser.password);
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyInOrder([
      mockCallback.emailValidator(invalidUser.name),
      mockCallback.passwordValidator(invalidUser.password),
      mockCallback.onSignup(any),
    ]);
    verifyNever(mockCallback.onSubmitAnimationCompleted());

    clearInteractions(mockCallback);

    // pass
    await tester.enterText(findNameTextField(), user.name);
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), user.password);
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), user.password);
    await tester.pumpAndSettle();
    clickSubmitButton();
    await tester.pumpAndSettle();

    verifyInOrder([
      mockCallback.emailValidator(user.name),
      mockCallback.passwordValidator(user.password),
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

    await tester.enterText(findNameTextField(), 'near@gmail.com');
    await tester.pumpAndSettle();
    await tester.enterText(findPasswordTextField(), '12345');
    await tester.pumpAndSettle();
    await tester.enterText(findConfirmPasswordTextField(), 'abcde');
    await tester.pumpAndSettle();

    clickForgotPasswordButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).controller.text, 'near@gmail.com');

    clickGoBackButton();
    await tester.pumpAndSettle();

    expect(nameTextFieldWidget(tester).controller.text, 'near@gmail.com');
    expect(passwordTextFieldWidget(tester).controller.text, '12345');
    expect(confirmPasswordTextFieldWidget(tester).controller.text, 'abcde');
  });

  // TODO:
  // https://github.com/NearHuscarl/flutter_login/issues/20
  testWidgets('Hide Logo completely if device height is less than ????',
      (WidgetTester tester) async {
    await binding.setSurfaceSize(Size(480, 800));

    await tester.pumpWidget(defaultFlutterLogin());
    await tester.pumpAndSettle(loadingAnimationDuration);
    expect(true, true);

    // resets the screen to its orinal size after the test end
    addTearDown(() => binding.setSurfaceSize(null));
  });

  // TODO: wait for flutter to add support for testing in web environment on Windows 10
  // https://github.com/flutter/flutter/issues/44583
  // https://github.com/NearHuscarl/flutter_login/issues/7
  testWidgets('AnimatedText should be centered in mobile and web consistently',
      (WidgetTester tester) async {
    await tester.pumpWidget(defaultFlutterLogin());
    await tester.pumpAndSettle(loadingAnimationDuration);

    final text = find.byType(AnimatedText).first;
    print(tester.getTopLeft(text));
    print(tester.getCenter(text));
    print(tester.getBottomRight(text));

    expect(true, true);
  });
}
