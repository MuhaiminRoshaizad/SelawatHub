import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ms'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'SelawatHub'**
  String get appTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageMalay.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Melayu'**
  String get languageMalay;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languagePickerTitle;

  /// No description provided for @languagePickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get languagePickerSubtitle;

  /// No description provided for @languageCurrent.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageCurrent;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @commonCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get commonCopied;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonError;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get commonGetStarted;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get commonViewAll;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get commonSeeAll;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get commonJoin;

  /// No description provided for @commonLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get commonLeave;

  /// No description provided for @commonSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get commonSettings;

  /// No description provided for @tabTasbih.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get tabTasbih;

  /// No description provided for @tabGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get tabGroup;

  /// No description provided for @tabStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get tabStats;

  /// No description provided for @tabDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get tabDaily;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SelawatHub'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your daily dhikr, build streaks, and stay connected with your community.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Count together, grow together'**
  String get welcomeTagline;

  /// No description provided for @welcomeSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get welcomeSignIn;

  /// No description provided for @welcomeCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get welcomeCreateAccount;

  /// No description provided for @welcomeContinueGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get welcomeContinueGuest;

  /// No description provided for @welcomeGuestNote.
  ///
  /// In en, this message translates to:
  /// **'Guest data is stored locally only'**
  String get welcomeGuestNote;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Count Your Selawat'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Track your daily selawat and zikir\nwith a beautiful tasbih counter'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'See your streaks, heatmaps, and\ndetailed statistics over time'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Grow Together'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Join groups, count together, and\nmotivate each other'**
  String get onboardingSubtitle3;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get loginCreateTitle;

  /// No description provided for @loginSubtitleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Continue your selawat journey'**
  String get loginSubtitleSignIn;

  /// No description provided for @loginSubtitleSignUp.
  ///
  /// In en, this message translates to:
  /// **'Start your selawat journey'**
  String get loginSubtitleSignUp;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordHint;

  /// No description provided for @loginNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get loginNameLabel;

  /// No description provided for @loginNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get loginNameHint;

  /// No description provided for @loginConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get loginConfirmPasswordLabel;

  /// No description provided for @loginConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get loginConfirmPasswordHint;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginSubmitSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSubmitSignIn;

  /// No description provided for @loginSubmitSignUp.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get loginSubmitSignUp;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccount;

  /// No description provided for @loginHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get loginHaveAccount;

  /// No description provided for @loginSignUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get loginSignUpLink;

  /// No description provided for @loginSignInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignInLink;

  /// No description provided for @loginAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the '**
  String get loginAgreementPrefix;

  /// No description provided for @loginAgreementAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get loginAgreementAnd;

  /// No description provided for @loginAgreementSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get loginAgreementSuffix;

  /// No description provided for @loginAgreementTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get loginAgreementTerms;

  /// No description provided for @loginAgreementPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get loginAgreementPrivacy;

  /// No description provided for @loginErrorFillFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get loginErrorFillFields;

  /// No description provided for @loginErrorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get loginErrorNameRequired;

  /// No description provided for @loginErrorPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get loginErrorPasswordLength;

  /// No description provided for @loginErrorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get loginErrorPasswordMismatch;

  /// No description provided for @loginErrorAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms of Service and Privacy Policy'**
  String get loginErrorAgreeTerms;

  /// No description provided for @loginErrorEmailExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Try signing in instead.'**
  String get loginErrorEmailExists;

  /// No description provided for @loginCheckEmailVerify.
  ///
  /// In en, this message translates to:
  /// **'Check your email to verify your account'**
  String get loginCheckEmailVerify;

  /// No description provided for @loginGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get loginGenericError;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password.'**
  String get forgotPasswordBody;

  /// No description provided for @forgotPasswordEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get forgotPasswordEmailHint;

  /// No description provided for @forgotPasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get forgotPasswordSubmit;

  /// No description provided for @forgotPasswordEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get forgotPasswordEmailRequired;

  /// No description provided for @forgotPasswordSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent! Check your email'**
  String get forgotPasswordSent;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password for your account'**
  String get resetPasswordSubtitle;

  /// No description provided for @resetPasswordNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get resetPasswordNewLabel;

  /// No description provided for @resetPasswordNewHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get resetPasswordNewHint;

  /// No description provided for @resetPasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get resetPasswordConfirmLabel;

  /// No description provided for @resetPasswordConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get resetPasswordConfirmHint;

  /// No description provided for @resetPasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get resetPasswordSubmit;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get resetPasswordSuccess;

  /// No description provided for @resetPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get resetPasswordEmpty;

  /// No description provided for @resetPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get resetPasswordTooShort;

  /// No description provided for @resetPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get resetPasswordMismatch;

  /// No description provided for @resetPasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update password'**
  String get resetPasswordFailed;

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Info'**
  String get profileSectionAccountInfo;

  /// No description provided for @profileSectionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSectionSettings;

  /// No description provided for @profileSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSectionSupport;

  /// No description provided for @profileSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profileSectionPreferences;

  /// No description provided for @profileSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileSectionAbout;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profileChangePassword;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get profileSignIn;

  /// No description provided for @profileTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get profileTheme;

  /// No description provided for @profileHapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get profileHapticFeedback;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileHelpAndFaq.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get profileHelpAndFaq;

  /// No description provided for @profileAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About SelawatHub'**
  String get profileAboutApp;

  /// No description provided for @profilePrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacyPolicy;

  /// No description provided for @profileTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get profileTermsOfService;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// No description provided for @profileMemberSinceLabel.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get profileMemberSinceLabel;

  /// No description provided for @profileMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String profileMemberSince(String date);

  /// No description provided for @profileGuestBadge.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuestBadge;

  /// No description provided for @profileGuestUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync across devices'**
  String get profileGuestUpgrade;

  /// No description provided for @profileSetYourName.
  ///
  /// In en, this message translates to:
  /// **'Set your name'**
  String get profileSetYourName;

  /// No description provided for @profileBioPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tap the pencil to add a bio'**
  String get profileBioPlaceholder;

  /// No description provided for @profileTotalDhikr.
  ///
  /// In en, this message translates to:
  /// **'Total Dhikr'**
  String get profileTotalDhikr;

  /// No description provided for @profileDayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get profileDayStreak;

  /// No description provided for @profileDaysActive.
  ///
  /// In en, this message translates to:
  /// **'Days Active'**
  String get profileDaysActive;

  /// No description provided for @profileSignOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profileSignOutConfirmTitle;

  /// No description provided for @profileSignOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of your account?'**
  String get profileSignOutConfirmBody;

  /// No description provided for @profileSignOutAction.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOutAction;

  /// No description provided for @profileSignOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign out'**
  String get profileSignOutFailed;

  /// No description provided for @profileSignOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get profileSignOutSuccess;

  /// No description provided for @profileVersion.
  ///
  /// In en, this message translates to:
  /// **'SelawatHub v{version}'**
  String profileVersion(String version);

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get changePasswordCurrentLabel;

  /// No description provided for @changePasswordNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get changePasswordNewLabel;

  /// No description provided for @changePasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get changePasswordConfirmLabel;

  /// No description provided for @changePasswordForgotLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot your current password?'**
  String get changePasswordForgotLink;

  /// No description provided for @changePasswordSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get changePasswordSending;

  /// No description provided for @changePasswordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent to {email}'**
  String changePasswordResetSent(String email);

  /// No description provided for @changePasswordEmailMissing.
  ///
  /// In en, this message translates to:
  /// **'Could not find your email'**
  String get changePasswordEmailMissing;

  /// No description provided for @changePasswordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email'**
  String get changePasswordResetFailed;

  /// No description provided for @changePasswordCurrentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get changePasswordCurrentRequired;

  /// No description provided for @changePasswordCurrentIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get changePasswordCurrentIncorrect;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get changePasswordSuccess;

  /// No description provided for @changePasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get changePasswordFailed;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get editProfileSave;

  /// No description provided for @editProfileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get editProfileCancel;

  /// No description provided for @editProfileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get editProfileNameLabel;

  /// No description provided for @editProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get editProfileNameHint;

  /// No description provided for @editProfileBioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get editProfileBioLabel;

  /// No description provided for @editProfileBioHint.
  ///
  /// In en, this message translates to:
  /// **'Write something about yourself...'**
  String get editProfileBioHint;

  /// No description provided for @editProfileEditPhoto.
  ///
  /// In en, this message translates to:
  /// **'Edit photo'**
  String get editProfileEditPhoto;

  /// No description provided for @editProfileTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get editProfileTakePhoto;

  /// No description provided for @editProfileChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get editProfileChooseGallery;

  /// No description provided for @editProfileRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get editProfileRemovePhoto;

  /// No description provided for @editProfilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Photo updated'**
  String get editProfilePhotoUpdated;

  /// No description provided for @editProfilePhotoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Photo removed'**
  String get editProfilePhotoRemoved;

  /// No description provided for @editProfilePhotoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload photo'**
  String get editProfilePhotoUploadFailed;

  /// No description provided for @editProfilePhotoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image must be under 2 MB'**
  String get editProfilePhotoTooLarge;

  /// No description provided for @editProfilePhotoBadType.
  ///
  /// In en, this message translates to:
  /// **'Only JPG, PNG, or WebP allowed'**
  String get editProfilePhotoBadType;

  /// No description provided for @editProfileNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get editProfileNameEmpty;

  /// No description provided for @editProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get editProfileSaved;

  /// No description provided for @editProfileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile'**
  String get editProfileSaveFailed;

  /// No description provided for @editProfileDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get editProfileDiscardTitle;

  /// No description provided for @editProfileDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes that will be lost.'**
  String get editProfileDiscardBody;

  /// No description provided for @editProfileKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep Editing'**
  String get editProfileKeepEditing;

  /// No description provided for @editProfileDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get editProfileDiscard;

  /// No description provided for @counterTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get counterTitle;

  /// No description provided for @counterTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get counterTodayLabel;

  /// No description provided for @counterTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get counterTotalLabel;

  /// No description provided for @counterTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get counterTargetLabel;

  /// No description provided for @counterReachedTarget.
  ///
  /// In en, this message translates to:
  /// **'Target reached · MashaAllah'**
  String get counterReachedTarget;

  /// No description provided for @counterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset count'**
  String get counterReset;

  /// No description provided for @counterResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset to zero?'**
  String get counterResetConfirmTitle;

  /// No description provided for @counterResetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Today\'s count for this dhikr will be cleared.'**
  String get counterResetConfirmBody;

  /// No description provided for @counterChangeDhikr.
  ///
  /// In en, this message translates to:
  /// **'Change dhikr'**
  String get counterChangeDhikr;

  /// No description provided for @counterAddManual.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get counterAddManual;

  /// No description provided for @counterSettings.
  ///
  /// In en, this message translates to:
  /// **'Counter settings'**
  String get counterSettings;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statsTodayDhikr.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Dhikr'**
  String get statsTodayDhikr;

  /// No description provided for @statsWeeklyTotal.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get statsWeeklyTotal;

  /// No description provided for @statsMonthlyTotal.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get statsMonthlyTotal;

  /// No description provided for @statsAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get statsAllTime;

  /// No description provided for @statsCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get statsCurrentStreak;

  /// No description provided for @statsLongestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get statsLongestStreak;

  /// No description provided for @statsTopDhikr.
  ///
  /// In en, this message translates to:
  /// **'Top dhikr'**
  String get statsTopDhikr;

  /// No description provided for @statsRangeWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get statsRangeWeek;

  /// No description provided for @statsRangeMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get statsRangeMonth;

  /// No description provided for @statsRangeYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get statsRangeYear;

  /// No description provided for @statsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No dhikr yet · Start counting on the Tasbih tab'**
  String get statsEmpty;

  /// No description provided for @statsGoToTasbih.
  ///
  /// In en, this message translates to:
  /// **'Open Tasbih'**
  String get statsGoToTasbih;

  /// No description provided for @groupTitle.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupTitle;

  /// No description provided for @groupCreate.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get groupCreate;

  /// No description provided for @groupJoin.
  ///
  /// In en, this message translates to:
  /// **'Join group'**
  String get groupJoin;

  /// No description provided for @groupMembers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {1 member} other {{count} members}}'**
  String groupMembers(int count);

  /// No description provided for @groupLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get groupLeaderboard;

  /// No description provided for @groupInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get groupInviteCode;

  /// No description provided for @groupCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get groupCopyCode;

  /// No description provided for @groupNoGroupsTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re not in any group yet'**
  String get groupNoGroupsTitle;

  /// No description provided for @groupNoGroupsBody.
  ///
  /// In en, this message translates to:
  /// **'Create one with friends or family, or join with an invite code.'**
  String get groupNoGroupsBody;

  /// No description provided for @hadithTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get hadithTitle;

  /// No description provided for @hadithDailyHadith.
  ///
  /// In en, this message translates to:
  /// **'Hadith of the day'**
  String get hadithDailyHadith;

  /// No description provided for @hadithDailyDua.
  ///
  /// In en, this message translates to:
  /// **'Dua of the day'**
  String get hadithDailyDua;

  /// No description provided for @hadithMorningAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Morning adhkar'**
  String get hadithMorningAdhkar;

  /// No description provided for @hadithEveningAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Evening adhkar'**
  String get hadithEveningAdhkar;

  /// No description provided for @hadithEnglishOnlyBadge.
  ///
  /// In en, this message translates to:
  /// **'Content available in English only'**
  String get hadithEnglishOnlyBadge;

  /// No description provided for @hadithReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get hadithReadMore;

  /// No description provided for @hadithLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load content. Pull to refresh.'**
  String get hadithLoadFailed;

  /// No description provided for @settingsTickSound.
  ///
  /// In en, this message translates to:
  /// **'Tick Sound'**
  String get settingsTickSound;

  /// No description provided for @settingsTickSoundOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsTickSoundOff;

  /// No description provided for @settingsTickSoundClick.
  ///
  /// In en, this message translates to:
  /// **'Click'**
  String get settingsTickSoundClick;

  /// No description provided for @settingsTickSoundWood.
  ///
  /// In en, this message translates to:
  /// **'Wood'**
  String get settingsTickSoundWood;

  /// No description provided for @settingsTickSoundSoft.
  ///
  /// In en, this message translates to:
  /// **'Soft tap'**
  String get settingsTickSoundSoft;

  /// No description provided for @settingsHapticHint.
  ///
  /// In en, this message translates to:
  /// **'If your phone\'s vibration is off, turn on Tick Sound for audio feedback.'**
  String get settingsHapticHint;

  /// No description provided for @guestNotice.
  ///
  /// In en, this message translates to:
  /// **'Guest mode · sign in to sync your data'**
  String get guestNotice;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'v{version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'SelawatHub is your companion for daily selawat and zikir. Count your dhikr with a beautiful digital tasbih, track your streaks and progress over time, set personal daily goals, and grow together with your community through group features. Available in English and Bahasa Melayu.'**
  String get aboutDescription;

  /// No description provided for @aboutFeature1.
  ///
  /// In en, this message translates to:
  /// **'Digital tasbih with multiple dhikr types'**
  String get aboutFeature1;

  /// No description provided for @aboutFeature2.
  ///
  /// In en, this message translates to:
  /// **'Manual count entry & custom dhikr'**
  String get aboutFeature2;

  /// No description provided for @aboutFeature3.
  ///
  /// In en, this message translates to:
  /// **'Personal statistics & streak tracking'**
  String get aboutFeature3;

  /// No description provided for @aboutFeature4.
  ///
  /// In en, this message translates to:
  /// **'Configurable daily goals'**
  String get aboutFeature4;

  /// No description provided for @aboutFeature5.
  ///
  /// In en, this message translates to:
  /// **'Group dhikr with leaderboards'**
  String get aboutFeature5;

  /// No description provided for @aboutFeature6.
  ///
  /// In en, this message translates to:
  /// **'Daily hadith collection'**
  String get aboutFeature6;

  /// No description provided for @aboutFeature7.
  ///
  /// In en, this message translates to:
  /// **'Guest mode — no account required'**
  String get aboutFeature7;

  /// No description provided for @aboutMadeBy.
  ///
  /// In en, this message translates to:
  /// **'Made by MuhaiminRoshaizad'**
  String get aboutMadeBy;

  /// No description provided for @faqSectionTasbih.
  ///
  /// In en, this message translates to:
  /// **'Tasbih & Counter'**
  String get faqSectionTasbih;

  /// No description provided for @faqSectionManual.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry & Corrections'**
  String get faqSectionManual;

  /// No description provided for @faqSectionStats.
  ///
  /// In en, this message translates to:
  /// **'Stats & Goals'**
  String get faqSectionStats;

  /// No description provided for @faqSectionGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get faqSectionGroups;

  /// No description provided for @faqSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account & Security'**
  String get faqSectionAccount;

  /// No description provided for @faqSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data & Preferences'**
  String get faqSectionData;

  /// No description provided for @faqQ_tasbih_count_q.
  ///
  /// In en, this message translates to:
  /// **'How do I count selawat or zikir?'**
  String get faqQ_tasbih_count_q;

  /// No description provided for @faqQ_tasbih_count_a.
  ///
  /// In en, this message translates to:
  /// **'Go to the Tasbih tab and tap the counter area to count. You can switch between different selawat and zikir types by tapping the dhikr name at the top. There are three counter styles available — Digital, Bead, and Minimal — which you can switch in the counter settings.'**
  String get faqQ_tasbih_count_a;

  /// No description provided for @faqQ_tasbih_change_q.
  ///
  /// In en, this message translates to:
  /// **'How do I change the dhikr type?'**
  String get faqQ_tasbih_change_q;

  /// No description provided for @faqQ_tasbih_change_a.
  ///
  /// In en, this message translates to:
  /// **'On the Tasbih tab, tap the dhikr name displayed at the top of the counter. A selector sheet will appear where you can choose from various selawat and zikir types.'**
  String get faqQ_tasbih_change_a;

  /// No description provided for @faqQ_tasbih_target_q.
  ///
  /// In en, this message translates to:
  /// **'Can I set a target count for my dhikr?'**
  String get faqQ_tasbih_target_q;

  /// No description provided for @faqQ_tasbih_target_a.
  ///
  /// In en, this message translates to:
  /// **'Yes! Go to the counter settings (⋮ menu on the Tasbih tab) and set your desired target count. The counter will track your progress toward that target. The target must be a whole number greater than zero.'**
  String get faqQ_tasbih_target_a;

  /// No description provided for @faqQ_tasbih_haptic_q.
  ///
  /// In en, this message translates to:
  /// **'The vibration/haptic is not working on my phone.'**
  String get faqQ_tasbih_haptic_q;

  /// No description provided for @faqQ_tasbih_haptic_a.
  ///
  /// In en, this message translates to:
  /// **'Some phones disable vibration system-wide (e.g. \"Vibration & haptics\" toggle in your phone\'s Sound settings). The app cannot override that — but you can enable Tick Sound as an alternative.\n\nGo to Counter settings (⋮ menu → Counter settings) and turn on Tick Sound. Choose from three styles: Click, Wood, or Soft tap. The sound plays through the media channel and works even when your phone\'s vibration is off.\n\nOn iOS, Tick Sound respects the ringer/silent switch — so it stays silent in the mosque when your phone is on silent.'**
  String get faqQ_tasbih_haptic_a;

  /// No description provided for @faqQ_tasbih_more_q.
  ///
  /// In en, this message translates to:
  /// **'What is the ⋮ button at the top of the counter?'**
  String get faqQ_tasbih_more_q;

  /// No description provided for @faqQ_tasbih_more_a.
  ///
  /// In en, this message translates to:
  /// **'The ⋮ (more) button opens an action menu with three options:\n\n• Add manual count — log dhikr you completed on a physical tasbih\n• Edit today\'s log — fix a mistake in any of today\'s counts\n• Counter settings — bead style, haptics, target counts, and the daily goal\n\nLong-press the ⋮ to jump straight to today\'s log.'**
  String get faqQ_tasbih_more_a;

  /// No description provided for @faqQ_manual_physical_q.
  ///
  /// In en, this message translates to:
  /// **'I use a physical tasbih. Can I still log my counts?'**
  String get faqQ_manual_physical_q;

  /// No description provided for @faqQ_manual_physical_a.
  ///
  /// In en, this message translates to:
  /// **'Yes. Open the ⋮ menu on the Tasbih tab and choose \"Add manual count\". Pick the dhikr, enter how many you completed, and tap Save. The amount is added to today\'s total — exactly as if you had tapped the counter that many times.\n\nYou can use this multiple times a day. Each save is added on top of what is already counted.'**
  String get faqQ_manual_physical_a;

  /// No description provided for @faqQ_manual_custom_q.
  ///
  /// In en, this message translates to:
  /// **'My selawat / zikir is not in the built-in list. Can I add my own?'**
  String get faqQ_manual_custom_q;

  /// No description provided for @faqQ_manual_custom_a.
  ///
  /// In en, this message translates to:
  /// **'Yes — but only if you are signed in. In the manual count sheet, tap \"Add custom\" and enter the name of your selawat or zikir, then choose whether it is a selawat or zikir. Your custom entry is saved to your account and shows up alongside the built-in list every time you open the manual count sheet.\n\nGuest users cannot create custom dhikr because the data needs to be saved to your account.'**
  String get faqQ_manual_custom_a;

  /// No description provided for @faqQ_manual_fix_q.
  ///
  /// In en, this message translates to:
  /// **'I entered the wrong number. How do I fix it?'**
  String get faqQ_manual_fix_q;

  /// No description provided for @faqQ_manual_fix_a.
  ///
  /// In en, this message translates to:
  /// **'There are three ways to correct a manual count:\n\n• Undo (immediate) — right after you save a manual count, a toast appears at the top with an UNDO button. Tap it within 6 seconds to reverse the change.\n• Subtract mode — open the manual count sheet again, switch the toggle to \"Subtract\", and enter the amount you want to remove. The total is clamped at 0 so you can\'t go negative.\n• Edit today\'s log — open the ⋮ menu and pick \"Edit today\'s log\". Tap any row to set its exact total for today. This is the easiest fix if you missed the undo toast.\n\nThe stats page also has an \"Edit today\'s log\" shortcut card under the streak.'**
  String get faqQ_manual_fix_a;

  /// No description provided for @faqQ_manual_diff_q.
  ///
  /// In en, this message translates to:
  /// **'How is \"Add manual count\" different from tapping the counter?'**
  String get faqQ_manual_diff_q;

  /// No description provided for @faqQ_manual_diff_a.
  ///
  /// In en, this message translates to:
  /// **'They are functionally the same — both add to your today\'s total for the chosen dhikr. The counter tap is a 1-by-1 increment for use during live dhikr. Manual count is for batches you completed away from the app (on a physical tasbih, in your head, etc.) and lets you choose any positive number in one go.'**
  String get faqQ_manual_diff_a;

  /// No description provided for @faqQ_stats_goal_q.
  ///
  /// In en, this message translates to:
  /// **'How do I set or change my daily goal?'**
  String get faqQ_stats_goal_q;

  /// No description provided for @faqQ_stats_goal_a.
  ///
  /// In en, this message translates to:
  /// **'Go to the Stats tab and tap the progress bar or the edit icon next to your daily goal. You can set any goal greater than zero. This goal is used to track your daily progress and streak.'**
  String get faqQ_stats_goal_a;

  /// No description provided for @faqQ_stats_streak_q.
  ///
  /// In en, this message translates to:
  /// **'How are streaks calculated?'**
  String get faqQ_stats_streak_q;

  /// No description provided for @faqQ_stats_streak_a.
  ///
  /// In en, this message translates to:
  /// **'A streak counts consecutive days where you meet your daily goal.\n\nThe streak fire works like this: if you had a 12-day streak and today is day 13, the fire shows as off (dim) until you hit your goal for today. Once you reach the goal, the fire turns on and your streak becomes 13.\n\nThis means the streak number only increases after you earn it — not just by opening the app. Missing a day resets the streak to zero.'**
  String get faqQ_stats_streak_a;

  /// No description provided for @faqQ_groups_join_q.
  ///
  /// In en, this message translates to:
  /// **'How do I join a group?'**
  String get faqQ_groups_join_q;

  /// No description provided for @faqQ_groups_join_a.
  ///
  /// In en, this message translates to:
  /// **'Go to the Group tab and enter the invite code shared by your group leader. Tap \"Join Group\" to join. You can only be in one group at a time.'**
  String get faqQ_groups_join_a;

  /// No description provided for @faqQ_groups_create_q.
  ///
  /// In en, this message translates to:
  /// **'How do I create a group?'**
  String get faqQ_groups_create_q;

  /// No description provided for @faqQ_groups_create_a.
  ///
  /// In en, this message translates to:
  /// **'Go to the Group tab and tap \"Create New Group\". Enter a group name and optional description. You\'ll become the group admin and receive an invite code to share with others.'**
  String get faqQ_groups_create_a;

  /// No description provided for @faqQ_groups_admin_q.
  ///
  /// In en, this message translates to:
  /// **'What can a group admin do?'**
  String get faqQ_groups_admin_q;

  /// No description provided for @faqQ_groups_admin_a.
  ///
  /// In en, this message translates to:
  /// **'The group leader can edit the group name, description, and daily goal. They can also promote members to co-leader, demote co-leaders to member, and remove members from the group.'**
  String get faqQ_groups_admin_a;

  /// No description provided for @faqQ_account_guest_q.
  ///
  /// In en, this message translates to:
  /// **'Can I use the app without an account?'**
  String get faqQ_account_guest_q;

  /// No description provided for @faqQ_account_guest_a.
  ///
  /// In en, this message translates to:
  /// **'Yes! You can use SelawatHub as a guest. Guest users can count dhikr and view statistics stored locally on their device. However, group features and cloud sync require a registered account. Guest data may be lost if the app is uninstalled.'**
  String get faqQ_account_guest_a;

  /// No description provided for @faqQ_account_changepw_q.
  ///
  /// In en, this message translates to:
  /// **'How do I change my password?'**
  String get faqQ_account_changepw_q;

  /// No description provided for @faqQ_account_changepw_a.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Change Password. You\'ll need to verify your current password first, then enter and confirm your new password (minimum 6 characters). If you\'ve forgotten your current password, tap \"Forgot your current password?\" to receive a reset link via email.'**
  String get faqQ_account_changepw_a;

  /// No description provided for @faqQ_account_forgotpw_q.
  ///
  /// In en, this message translates to:
  /// **'I forgot my password. How do I reset it?'**
  String get faqQ_account_forgotpw_q;

  /// No description provided for @faqQ_account_forgotpw_a.
  ///
  /// In en, this message translates to:
  /// **'On the sign-in page, tap \"Forgot password?\" and enter your email address. You\'ll receive an email with a link to reset your password. If you\'re already logged in, you can also trigger a reset from Profile > Change Password.'**
  String get faqQ_account_forgotpw_a;

  /// No description provided for @faqQ_data_cloud_q.
  ///
  /// In en, this message translates to:
  /// **'Is my data saved to the cloud?'**
  String get faqQ_data_cloud_q;

  /// No description provided for @faqQ_data_cloud_a.
  ///
  /// In en, this message translates to:
  /// **'If you have an account, your dhikr counts, profile, and group data are synced to the cloud. Preferences like theme, haptic feedback, tick sound, daily goal, and language are stored locally on your device. Guest data is stored locally only.'**
  String get faqQ_data_cloud_a;

  /// No description provided for @faqQ_data_picture_q.
  ///
  /// In en, this message translates to:
  /// **'How do I change my profile picture?'**
  String get faqQ_data_picture_q;

  /// No description provided for @faqQ_data_picture_a.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Edit Profile and tap the camera icon or your current photo. You can upload a new image from your device. To remove your photo, tap the remove option in the photo picker.'**
  String get faqQ_data_picture_a;

  /// No description provided for @faqQ_data_theme_q.
  ///
  /// In en, this message translates to:
  /// **'How do I switch between dark and light mode?'**
  String get faqQ_data_theme_q;

  /// No description provided for @faqQ_data_theme_a.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile and toggle the theme switch in the Preferences section. Your theme preference is saved locally and persists across sessions.'**
  String get faqQ_data_theme_a;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @legalLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String legalLastUpdated(String date);

  /// No description provided for @privacyIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get privacyIntroTitle;

  /// No description provided for @privacyIntroBody.
  ///
  /// In en, this message translates to:
  /// **'SelawatHub (\"we\", \"our\", or \"us\") is a mobile application developed by an individual developer based in Malaysia, designed to help Muslims count selawat and zikir, track their devotional progress, and participate in group dhikr activities. We are committed to protecting your privacy and handling your personal data transparently.\n\nThis Privacy Policy explains what information we collect, how we use it, and your rights regarding your data. It is prepared in line with the Malaysian Personal Data Protection Act 2010, as amended by the Personal Data Protection (Amendment) Act 2024.'**
  String get privacyIntroBody;

  /// No description provided for @privacy1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get privacy1Title;

  /// No description provided for @privacy1Body.
  ///
  /// In en, this message translates to:
  /// **'Account Information\nWhen you create an account, we collect your email address and a display name you choose. Your password is securely hashed and stored by our authentication provider (Supabase) — we never have access to your plaintext password.\n\nProfile Information\nYou may optionally provide a bio and upload a profile picture. Profile pictures are stored in secure cloud storage and are visible to members of groups you join.\n\nUsage Data\nWe collect data about your selawat and zikir counts, including the type of dhikr, count totals, and timestamps. This data is used to generate your personal statistics, streaks, and progress tracking. Counts may originate either from tapping the in-app counter or from manual entries you make (for dhikr completed using a physical tasbih).\n\nUser-Generated Content\nIf you create custom selawat or zikir entries, the names you provide are stored against your account. These names are visible only to you and are never shown to other users or group members.\n\nGroup Data\nIf you create or join a group, we store group membership information, your role within the group, and your dhikr contributions that are shared with other group members.\n\nGuest Usage\nIf you use SelawatHub as a guest without creating an account, your dhikr counts and preferences are stored locally on your device only. No personal data is transmitted to our servers in guest mode. Note that custom dhikr creation is not available in guest mode.\n\nSensitive Personal Data\nWe do not collect sensitive personal data as defined under the Personal Data Protection Act 2010 (such as physical or mental health, political opinions, religious beliefs beyond what is inherent in your use of the app, or biometric data).'**
  String get privacy1Body;

  /// No description provided for @privacy2Title.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Your Information'**
  String get privacy2Title;

  /// No description provided for @privacy2Body.
  ///
  /// In en, this message translates to:
  /// **'We use the information we collect to:\n\n• Provide core app functionality — counting selawat/zikir, tracking progress, and displaying statistics\n• Enable group features — allowing you to join groups, share progress, and view group leaderboards\n• Authenticate your identity and secure your account\n• Send password reset emails when requested\n• Store and display your profile information to other group members\n• Calculate streaks, daily goals, and weekly/monthly/yearly statistics\n• Improve the app experience based on usage patterns'**
  String get privacy2Body;

  /// No description provided for @privacy3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Data Storage & Security'**
  String get privacy3Title;

  /// No description provided for @privacy3Body.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored on Supabase, a secure cloud platform with industry-standard security practices including:\n\n• Encrypted data transmission (HTTPS/TLS)\n• Row Level Security (RLS) policies ensuring users can only access their own data\n• Secure password hashing using bcrypt\n• Profile pictures stored in access-controlled cloud storage\n\nLocal data (guest mode counts, app preferences such as theme selection, haptic feedback settings, daily goals, and language preference) is stored on your device using SharedPreferences and is not transmitted to our servers.'**
  String get privacy3Body;

  /// No description provided for @privacy4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Data Sharing & International Transfers'**
  String get privacy4Title;

  /// No description provided for @privacy4Body.
  ///
  /// In en, this message translates to:
  /// **'We do not sell, trade, or rent your personal information to third parties. Your data may be shared in the following limited circumstances:\n\n• Group Members — Your display name, profile picture, and dhikr counts are visible to members of groups you join\n• Service Providers — We use Supabase for authentication, database, and storage services. Supabase processes data on our behalf under strict data processing agreements\n• Legal Requirements — We may disclose information if required by law or to protect our rights and safety\n\nInternational Transfers\nSupabase may store and process data in jurisdictions outside Malaysia. Such transfers are made only to jurisdictions providing a level of data protection equivalent to that required by the Malaysian Personal Data Protection Act 2010 (as amended), and are subject to Supabase\'s contractual security and privacy commitments.'**
  String get privacy4Body;

  /// No description provided for @privacy5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Your Rights'**
  String get privacy5Title;

  /// No description provided for @privacy5Body.
  ///
  /// In en, this message translates to:
  /// **'Under the Personal Data Protection Act 2010 (as amended by the Personal Data Protection (Amendment) Act 2024), you have the right to:\n\n• Access — View your personal data through the app\'s profile and statistics pages, or request a copy by contacting us\n• Correction — Edit your display name, bio, profile picture, and dhikr counts at any time. You may also request correction of any other inaccurate data by contacting us\n• Deletion — Request deletion of your account and associated data by contacting us\n• Withdrawal of Consent — Withdraw your consent to data processing at any time by deleting your account; note that doing so will end your ability to use account-bound features\n• Data Portability — Request a copy of your personal data (account, counts, custom dhikr, group membership) in a structured, commonly used electronic format, and request that we transmit it directly to another data controller where technically feasible\n• Password — Change your password or request a password reset at any time\n• Lodge a Complaint — You may lodge a complaint with the Personal Data Protection Department of Malaysia (Jabatan Perlindungan Data Peribadi, JPDP) if you believe your rights have been infringed'**
  String get privacy5Body;

  /// No description provided for @privacy6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Data Breach Notification'**
  String get privacy6Title;

  /// No description provided for @privacy6Body.
  ///
  /// In en, this message translates to:
  /// **'In the event of a personal data breach that is likely to result in significant harm to you, we will notify both the Personal Data Protection Commissioner and affected users without undue delay and, where feasible, within seventy-two (72) hours of becoming aware of the breach, in accordance with the Personal Data Protection (Amendment) Act 2024.'**
  String get privacy6Body;

  /// No description provided for @privacy7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Data Retention'**
  String get privacy7Title;

  /// No description provided for @privacy7Body.
  ///
  /// In en, this message translates to:
  /// **'We retain your personal data for as long as your account is active. If you delete your account, your personal data is removed within a reasonable period, except where we are required to retain certain records to comply with applicable law or to resolve disputes. Local guest-mode data persists on your device until you uninstall the app or clear app storage.'**
  String get privacy7Body;

  /// No description provided for @privacy8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Children\'s Privacy'**
  String get privacy8Title;

  /// No description provided for @privacy8Body.
  ///
  /// In en, this message translates to:
  /// **'SelawatHub does not knowingly collect personal information from children under the age of 13. If you believe a child has provided us with personal data, please contact us so we can take appropriate action.'**
  String get privacy8Body;

  /// No description provided for @privacy9Title.
  ///
  /// In en, this message translates to:
  /// **'9. Changes to This Policy'**
  String get privacy9Title;

  /// No description provided for @privacy9Body.
  ///
  /// In en, this message translates to:
  /// **'We may update this Privacy Policy from time to time. Changes will be reflected in the \"Last updated\" date at the top of this page. Continued use of the app after changes constitutes acceptance of the updated policy.'**
  String get privacy9Body;

  /// No description provided for @privacy10Title.
  ///
  /// In en, this message translates to:
  /// **'10. Contact Us'**
  String get privacy10Title;

  /// No description provided for @privacy10Body.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about this Privacy Policy or wish to exercise your data rights under the Personal Data Protection Act 2010 (as amended), please contact us at:\n\nEmail: aminmuhaimin192@gmail.com\n\nSelawatHub is operated by an individual developer in Malaysia. No Data Protection Officer has been appointed because the processing volume falls below the thresholds set out in the Personal Data Protection (Amendment) Act 2024. The developer acts as the data controller for the purposes of this Policy.'**
  String get privacy10Body;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsTitle;

  /// No description provided for @termsIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get termsIntroTitle;

  /// No description provided for @termsIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SelawatHub. By downloading, installing, or using this application, you agree to be bound by these Terms of Service (\"Terms\"). If you do not agree to these Terms, please do not use the app.'**
  String get termsIntroBody;

  /// No description provided for @terms1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Description of Service'**
  String get terms1Title;

  /// No description provided for @terms1Body.
  ///
  /// In en, this message translates to:
  /// **'SelawatHub is a mobile application that provides:\n\n• A digital tasbih (counter) for selawat and zikir with customisable dhikr types and target counts\n• Manual count entry for dhikr completed using a physical tasbih, including add and subtract modes\n• User-defined custom selawat and zikir entries (registered users only)\n• Correction tools — undo, subtract, and \"Edit today\'s log\" — to fix mistaken entries\n• Personal statistics tracking including daily, weekly, monthly, and yearly progress with streaks and configurable daily goals\n• Group features allowing users to create or join groups, share dhikr progress, and view collective statistics\n• A curated collection of daily hadith\n• Profile management with customisable display name, bio, and profile picture\n• Guest mode for using basic features without an account'**
  String get terms1Body;

  /// No description provided for @terms2Title.
  ///
  /// In en, this message translates to:
  /// **'2. User Accounts'**
  String get terms2Title;

  /// No description provided for @terms2Body.
  ///
  /// In en, this message translates to:
  /// **'Account Creation\nYou may create an account using your email address and a password of at least 6 characters. You must provide a display name during registration. You are responsible for maintaining the confidentiality of your login credentials.\n\nGuest Mode\nYou may use SelawatHub without creating an account. Guest users can access the counter and view statistics stored locally on their device. Guest data is not synced to the cloud and may be lost if the app is uninstalled.\n\nAccount Security\nYou are responsible for all activity that occurs under your account. If you suspect unauthorised access, change your password immediately through the app\'s profile settings or use the password reset feature.'**
  String get terms2Body;

  /// No description provided for @terms3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Acceptable Use'**
  String get terms3Title;

  /// No description provided for @terms3Body.
  ///
  /// In en, this message translates to:
  /// **'You agree to use SelawatHub only for its intended purpose of facilitating Islamic devotional practices. You must not:\n\n• Use the app for any unlawful or prohibited purpose\n• Upload inappropriate, offensive, or non-Islamic content as your profile picture, bio, or custom dhikr names\n• Attempt to interfere with the app\'s functionality, security, or infrastructure\n• Create multiple accounts for the purpose of manipulating group statistics or leaderboards\n• Submit false or inflated dhikr counts to manipulate leaderboards or streaks\n• Share group invite codes publicly without the group administrator\'s consent\n• Harass, intimidate, or harm other users through group interactions\n• Attempt to access other users\' data or accounts'**
  String get terms3Body;

  /// No description provided for @terms4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Groups'**
  String get terms4Title;

  /// No description provided for @terms4Body.
  ///
  /// In en, this message translates to:
  /// **'Group Creation & Management\nAny registered user may create a group. The group creator becomes the group admin with the ability to manage members, update group settings, set daily goals, and remove members.\n\nMembership\nUsers may join a group using an invite code. Each user may belong to one group at a time. Your dhikr counts contributed while in a group are visible to all group members.\n\nLeaving or Removal\nYou may leave a group at any time. Group admins may remove members at their discretion. If a group admin leaves, administrative privileges are transferred to another member.'**
  String get terms4Body;

  /// No description provided for @terms5Title.
  ///
  /// In en, this message translates to:
  /// **'5. User Content'**
  String get terms5Title;

  /// No description provided for @terms5Body.
  ///
  /// In en, this message translates to:
  /// **'You retain ownership of content you provide (display name, bio, profile picture, custom dhikr names, and dhikr counts you log). By submitting content, you grant SelawatHub a non-exclusive, royalty-free licence to store, process, and display that content within the app for the sole purpose of providing the service (e.g., showing your profile picture to group members or rendering your custom dhikr in your own list).\n\nCustom Dhikr\nCustom selawat and zikir names you create are visible only to you and are not displayed to other users or group members. You are responsible for ensuring that any name you save is accurate, respectful, and does not violate the Acceptable Use rules in Section 3.\n\nManual Counts\nYou are solely responsible for the accuracy of counts you enter manually. You may correct mistaken entries at any time using the in-app undo, subtract, or \"Edit today\'s log\" tools.\n\nWe reserve the right to remove content that violates these Terms or is deemed inappropriate.'**
  String get terms5Body;

  /// No description provided for @terms6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Intellectual Property'**
  String get terms6Title;

  /// No description provided for @terms6Body.
  ///
  /// In en, this message translates to:
  /// **'The SelawatHub app, including its design, code, graphics, and content (excluding user-generated content), is the intellectual property of SelawatHub and is protected by applicable copyright and intellectual property laws. You may not copy, modify, distribute, or reverse-engineer any part of the app.'**
  String get terms6Body;

  /// No description provided for @terms7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Disclaimer of Warranties'**
  String get terms7Title;

  /// No description provided for @terms7Body.
  ///
  /// In en, this message translates to:
  /// **'SelawatHub is provided \"as is\" and \"as available\" without warranties of any kind, whether express or implied. We do not guarantee that:\n\n• The app will be available at all times without interruption\n• The app will be free from errors or defects\n• Data will never be lost (please note guest data is stored locally and may be lost upon app uninstallation)\n• The statistical calculations will be perfectly accurate'**
  String get terms7Body;

  /// No description provided for @terms8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Limitation of Liability'**
  String get terms8Title;

  /// No description provided for @terms8Body.
  ///
  /// In en, this message translates to:
  /// **'To the maximum extent permitted by law, SelawatHub and its developers shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of or inability to use the app. This includes but is not limited to loss of data, loss of streaks, or interruption of service.'**
  String get terms8Body;

  /// No description provided for @terms9Title.
  ///
  /// In en, this message translates to:
  /// **'9. Termination'**
  String get terms9Title;

  /// No description provided for @terms9Body.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to suspend or terminate your account if you violate these Terms. You may delete your account at any time by contacting us. Upon termination, your right to use the app ceases and your data may be deleted in accordance with our Privacy Policy.'**
  String get terms9Body;

  /// No description provided for @terms10Title.
  ///
  /// In en, this message translates to:
  /// **'10. Changes to Terms'**
  String get terms10Title;

  /// No description provided for @terms10Body.
  ///
  /// In en, this message translates to:
  /// **'We may update these Terms from time to time. Changes will be reflected in the \"Last updated\" date at the top. Your continued use of the app after modifications constitutes acceptance of the revised Terms.'**
  String get terms10Body;

  /// No description provided for @terms11Title.
  ///
  /// In en, this message translates to:
  /// **'11. Governing Law'**
  String get terms11Title;

  /// No description provided for @terms11Body.
  ///
  /// In en, this message translates to:
  /// **'These Terms shall be governed by and construed in accordance with the laws of Malaysia, including the Personal Data Protection Act 2010 (as amended by the Personal Data Protection (Amendment) Act 2024) and the Consumer Protection Act 1999. Any disputes arising from these Terms shall be subject to the exclusive jurisdiction of the courts of Malaysia.'**
  String get terms11Body;

  /// No description provided for @terms12Title.
  ///
  /// In en, this message translates to:
  /// **'12. Contact Us'**
  String get terms12Title;

  /// No description provided for @terms12Body.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about these Terms of Service, please contact us at:\n\nEmail: aminmuhaimin192@gmail.com'**
  String get terms12Body;

  /// No description provided for @counterHapticHint.
  ///
  /// In en, this message translates to:
  /// **'Haptics not buzzing? Check your phone\'s vibration settings — or enable Tick Sound below.'**
  String get counterHapticHint;

  /// No description provided for @counterSettingsAction.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get counterSettingsAction;

  /// No description provided for @counterCantSubtractBelowZero.
  ///
  /// In en, this message translates to:
  /// **'Can\'t subtract below 0'**
  String get counterCantSubtractBelowZero;

  /// No description provided for @counterFailedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save. Please try again.'**
  String get counterFailedToSave;

  /// No description provided for @counterFailedToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Failed to update. Please try again.'**
  String get counterFailedToUpdate;

  /// No description provided for @counterManualToastAdded.
  ///
  /// In en, this message translates to:
  /// **'Added {amount} · {name} · Today: {total}'**
  String counterManualToastAdded(int amount, String name, int total);

  /// No description provided for @counterManualToastRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed {amount} · {name} · Today: {total}'**
  String counterManualToastRemoved(int amount, String name, int total);

  /// No description provided for @counterUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get counterUndo;

  /// No description provided for @counterUpdatedToast.
  ///
  /// In en, this message translates to:
  /// **'Updated · {name} · {prev} → {next}'**
  String counterUpdatedToast(String name, int prev, int next);

  /// No description provided for @counterResetSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Session?'**
  String get counterResetSessionTitle;

  /// No description provided for @counterResetSessionContent.
  ///
  /// In en, this message translates to:
  /// **'This will clear your current session count.'**
  String get counterResetSessionContent;

  /// No description provided for @counterResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get counterResetConfirm;

  /// No description provided for @counterResetToast.
  ///
  /// In en, this message translates to:
  /// **'Counter reset · {name}'**
  String counterResetToast(String name);

  /// No description provided for @counterRounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get counterRounds;

  /// No description provided for @counterTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get counterTotal;

  /// No description provided for @counterResetLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get counterResetLabel;

  /// No description provided for @counterOfTarget.
  ///
  /// In en, this message translates to:
  /// **'of {target}'**
  String counterOfTarget(int target);

  /// No description provided for @counterMenuManual.
  ///
  /// In en, this message translates to:
  /// **'Add manual count'**
  String get counterMenuManual;

  /// No description provided for @counterMenuManualSub.
  ///
  /// In en, this message translates to:
  /// **'Log counts from a physical tasbih'**
  String get counterMenuManualSub;

  /// No description provided for @counterMenuTodayLog.
  ///
  /// In en, this message translates to:
  /// **'Edit today\'s log'**
  String get counterMenuTodayLog;

  /// No description provided for @counterMenuTodayLogSub.
  ///
  /// In en, this message translates to:
  /// **'Fix a wrong number from earlier today'**
  String get counterMenuTodayLogSub;

  /// No description provided for @counterMenuSettings.
  ///
  /// In en, this message translates to:
  /// **'Counter settings'**
  String get counterMenuSettings;

  /// No description provided for @counterMenuSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'Bead style, haptics, and daily goal'**
  String get counterMenuSettingsSub;

  /// No description provided for @todayLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s log'**
  String get todayLogTitle;

  /// No description provided for @todayLogTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a row to set the exact count'**
  String get todayLogTapHint;

  /// No description provided for @todayLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing counted today yet.'**
  String get todayLogEmpty;

  /// No description provided for @todayLogEditCount.
  ///
  /// In en, this message translates to:
  /// **'Edit count'**
  String get todayLogEditCount;

  /// No description provided for @dhikrSelectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Dhikr'**
  String get dhikrSelectorTitle;

  /// No description provided for @dhikrTabSelawat.
  ///
  /// In en, this message translates to:
  /// **'Selawat'**
  String get dhikrTabSelawat;

  /// No description provided for @dhikrTabZikir.
  ///
  /// In en, this message translates to:
  /// **'Zikir'**
  String get dhikrTabZikir;

  /// No description provided for @manualSaveCustomFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save custom {category}. Try again.'**
  String manualSaveCustomFailed(String category);

  /// No description provided for @manualAddedCustomToast.
  ///
  /// In en, this message translates to:
  /// **'Added \"{name}\" to your {category} list'**
  String manualAddedCustomToast(String name, String category);

  /// No description provided for @manualSubtractTitle.
  ///
  /// In en, this message translates to:
  /// **'Subtract manually'**
  String get manualSubtractTitle;

  /// No description provided for @manualAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get manualAddTitle;

  /// No description provided for @manualSubtractCta.
  ///
  /// In en, this message translates to:
  /// **'Subtract {amount}'**
  String manualSubtractCta(int amount);

  /// No description provided for @manualAddCta.
  ///
  /// In en, this message translates to:
  /// **'Add {amount}'**
  String manualAddCta(int amount);

  /// No description provided for @manualEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get manualEnterAmount;

  /// No description provided for @manualWhatReciting.
  ///
  /// In en, this message translates to:
  /// **'What are you reciting?'**
  String get manualWhatReciting;

  /// No description provided for @manualAddYourOwn.
  ///
  /// In en, this message translates to:
  /// **'Add your own Selawat/Zikir'**
  String get manualAddYourOwn;

  /// No description provided for @manualSaveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & continue'**
  String get manualSaveAndContinue;

  /// No description provided for @manualNameHintExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Selawat Munjiyat'**
  String get manualNameHintExample;

  /// No description provided for @manualSegmentSubtract.
  ///
  /// In en, this message translates to:
  /// **'Subtract'**
  String get manualSegmentSubtract;

  /// No description provided for @manualSegmentAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get manualSegmentAdd;

  /// No description provided for @manualCategorySelawat.
  ///
  /// In en, this message translates to:
  /// **'Selawat'**
  String get manualCategorySelawat;

  /// No description provided for @manualCategoryZikir.
  ///
  /// In en, this message translates to:
  /// **'Zikir'**
  String get manualCategoryZikir;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasbih Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsHapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get settingsHapticFeedback;

  /// No description provided for @settingsIntensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get settingsIntensity;

  /// No description provided for @settingsIntensityLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsIntensityLight;

  /// No description provided for @settingsIntensityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get settingsIntensityMedium;

  /// No description provided for @settingsIntensityHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get settingsIntensityHeavy;

  /// No description provided for @settingsHapticHelp.
  ///
  /// In en, this message translates to:
  /// **'May not be available on all devices'**
  String get settingsHapticHelp;

  /// No description provided for @settingsTickSoundHelp.
  ///
  /// In en, this message translates to:
  /// **'Plays a soft click on every tap. Useful when your phone\'s vibration is off.'**
  String get settingsTickSoundHelp;

  /// No description provided for @settingsCounterStyle.
  ///
  /// In en, this message translates to:
  /// **'Counter Style'**
  String get settingsCounterStyle;

  /// No description provided for @settingsCounterStyleBead.
  ///
  /// In en, this message translates to:
  /// **'Bead'**
  String get settingsCounterStyleBead;

  /// No description provided for @settingsCounterStyleDigital.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get settingsCounterStyleDigital;

  /// No description provided for @settingsCounterStyleMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get settingsCounterStyleMinimal;

  /// No description provided for @settingsColorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color Theme'**
  String get settingsColorTheme;

  /// No description provided for @settingsColorEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get settingsColorEmerald;

  /// No description provided for @settingsColorGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get settingsColorGold;

  /// No description provided for @settingsColorOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get settingsColorOcean;

  /// No description provided for @settingsColorRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get settingsColorRose;

  /// No description provided for @settingsColorLavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get settingsColorLavender;

  /// No description provided for @settingsColorIvory.
  ///
  /// In en, this message translates to:
  /// **'Ivory'**
  String get settingsColorIvory;

  /// No description provided for @settingsTargetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Targets'**
  String get settingsTargetsTitle;

  /// No description provided for @settingsTargetsSub.
  ///
  /// In en, this message translates to:
  /// **'Customize the target count for each dhikr'**
  String get settingsTargetsSub;

  /// No description provided for @settingsTargetCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Target count'**
  String get settingsTargetCountLabel;

  /// No description provided for @settingsTargetSetToast.
  ///
  /// In en, this message translates to:
  /// **'{name} target set to {value}'**
  String settingsTargetSetToast(String name, int value);

  /// No description provided for @settingsTargetInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number greater than 0'**
  String get settingsTargetInvalid;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get commonOr;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonSomethingWentWrong;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get commonThisWeek;

  /// No description provided for @commonThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get commonThisMonth;

  /// No description provided for @refreshPullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get refreshPullToRefresh;

  /// No description provided for @refreshReleaseToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Release to refresh'**
  String get refreshReleaseToRefresh;

  /// No description provided for @refreshRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing…'**
  String get refreshRefreshing;

  /// No description provided for @statsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your selawat & zikir journey'**
  String get statsSubtitle;

  /// No description provided for @statsDailyGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get statsDailyGoalTitle;

  /// No description provided for @statsDailyGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Set your daily recitation target.'**
  String get statsDailyGoalHint;

  /// No description provided for @statsDailyGoalExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. 100'**
  String get statsDailyGoalExample;

  /// No description provided for @statsDailyGoalSuffix.
  ///
  /// In en, this message translates to:
  /// **'counts'**
  String get statsDailyGoalSuffix;

  /// No description provided for @statsDailyGoalInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number greater than 0'**
  String get statsDailyGoalInvalid;

  /// No description provided for @statsEditTodayLog.
  ///
  /// In en, this message translates to:
  /// **'Edit today\'s log'**
  String get statsEditTodayLog;

  /// No description provided for @statsMadeAMistake.
  ///
  /// In en, this message translates to:
  /// **'Made a mistake?'**
  String get statsMadeAMistake;

  /// No description provided for @statsBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get statsBestStreak;

  /// No description provided for @statsDaysActive.
  ///
  /// In en, this message translates to:
  /// **'Days Active'**
  String get statsDaysActive;

  /// No description provided for @statsCategoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Category Breakdown'**
  String get statsCategoryBreakdown;

  /// No description provided for @statsNoActivityOnDay.
  ///
  /// In en, this message translates to:
  /// **'No activity on this day'**
  String get statsNoActivityOnDay;

  /// No description provided for @statsHeatmapActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get statsHeatmapActivity;

  /// No description provided for @statsHeatmapTapDeselect.
  ///
  /// In en, this message translates to:
  /// **'Tap again to deselect'**
  String get statsHeatmapTapDeselect;

  /// No description provided for @statsHeatmapTapFilter.
  ///
  /// In en, this message translates to:
  /// **'Tap a day to filter stats below'**
  String get statsHeatmapTapFilter;

  /// No description provided for @statsHeatmapLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get statsHeatmapLess;

  /// No description provided for @statsHeatmapMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get statsHeatmapMore;

  /// No description provided for @statsTopMostRecited.
  ///
  /// In en, this message translates to:
  /// **'Most Recited'**
  String get statsTopMostRecited;

  /// No description provided for @statsTopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your top selawat & zikir'**
  String get statsTopSubtitle;

  /// No description provided for @statsStreakNoStreak.
  ///
  /// In en, this message translates to:
  /// **'No Streak'**
  String get statsStreakNoStreak;

  /// No description provided for @statsStreakStartGoal.
  ///
  /// In en, this message translates to:
  /// **'Hit {goal} today to start your streak'**
  String statsStreakStartGoal(String goal);

  /// No description provided for @statsStreakStartReciting.
  ///
  /// In en, this message translates to:
  /// **'Start reciting today!'**
  String get statsStreakStartReciting;

  /// No description provided for @statsStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{days} Day Streak'**
  String statsStreakDays(int days);

  /// No description provided for @statsStreakKeepGoal.
  ///
  /// In en, this message translates to:
  /// **'Hit {goal} today to keep it alive'**
  String statsStreakKeepGoal(String goal);

  /// No description provided for @statsStreakKeepRecite.
  ///
  /// In en, this message translates to:
  /// **'Recite today to keep it alive'**
  String get statsStreakKeepRecite;

  /// No description provided for @statsStreakKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep it going!'**
  String get statsStreakKeepGoing;

  /// No description provided for @statsStreakOnFire.
  ///
  /// In en, this message translates to:
  /// **'You\'re on fire!'**
  String get statsStreakOnFire;

  /// No description provided for @statsStreakLegendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary status!'**
  String get statsStreakLegendary;

  /// No description provided for @statsWeeklyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No weekly data yet'**
  String get statsWeeklyEmpty;

  /// No description provided for @statsYearlySummary.
  ///
  /// In en, this message translates to:
  /// **'Yearly Summary'**
  String get statsYearlySummary;

  /// No description provided for @groupSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to create or join a group\nand track dhikr together.'**
  String get groupSignInPrompt;

  /// No description provided for @groupDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get groupDescription;

  /// No description provided for @groupNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get groupNoDescription;

  /// No description provided for @groupMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String groupMembersCount(int count);

  /// No description provided for @groupCreatedOn.
  ///
  /// In en, this message translates to:
  /// **'Created {date}'**
  String groupCreatedOn(String date);

  /// No description provided for @groupTotalToday.
  ///
  /// In en, this message translates to:
  /// **'GROUP TOTAL TODAY'**
  String get groupTotalToday;

  /// No description provided for @groupSelawatLabel.
  ///
  /// In en, this message translates to:
  /// **'selawat'**
  String get groupSelawatLabel;

  /// No description provided for @groupMembersHeader.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get groupMembersHeader;

  /// No description provided for @groupMyGroup.
  ///
  /// In en, this message translates to:
  /// **'My Group'**
  String get groupMyGroup;

  /// No description provided for @groupSettingsEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit Group Name'**
  String get groupSettingsEditName;

  /// No description provided for @groupSettingsEditNameHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a name that represents your group.'**
  String get groupSettingsEditNameHint;

  /// No description provided for @groupSettingsNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get groupSettingsNamePlaceholder;

  /// No description provided for @groupSettingsNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Group name updated'**
  String get groupSettingsNameUpdated;

  /// No description provided for @groupSettingsNameFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update name'**
  String get groupSettingsNameFailed;

  /// No description provided for @groupSettingsEditDesc.
  ///
  /// In en, this message translates to:
  /// **'Edit Description'**
  String get groupSettingsEditDesc;

  /// No description provided for @groupSettingsDescHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what your group is about.'**
  String get groupSettingsDescHint;

  /// No description provided for @groupSettingsDescPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter group description'**
  String get groupSettingsDescPlaceholder;

  /// No description provided for @groupSettingsDescUpdated.
  ///
  /// In en, this message translates to:
  /// **'Description updated'**
  String get groupSettingsDescUpdated;

  /// No description provided for @groupSettingsDescFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update description'**
  String get groupSettingsDescFailed;

  /// No description provided for @groupSettingsSetGoal.
  ///
  /// In en, this message translates to:
  /// **'Set Daily Goal'**
  String get groupSettingsSetGoal;

  /// No description provided for @groupSettingsGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Set a daily selawat target for your group.'**
  String get groupSettingsGoalHint;

  /// No description provided for @groupSettingsGoalExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. 10000'**
  String get groupSettingsGoalExample;

  /// No description provided for @groupSettingsGoalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Group daily goal set to {value}'**
  String groupSettingsGoalUpdated(int value);

  /// No description provided for @groupSettingsGoalFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update goal'**
  String get groupSettingsGoalFailed;

  /// No description provided for @groupSettingsMuteNotifications.
  ///
  /// In en, this message translates to:
  /// **'Mute Notifications'**
  String get groupSettingsMuteNotifications;

  /// No description provided for @groupSettingsManageRoles.
  ///
  /// In en, this message translates to:
  /// **'Manage Roles'**
  String get groupSettingsManageRoles;

  /// No description provided for @groupSettingsTransferLeadership.
  ///
  /// In en, this message translates to:
  /// **'Transfer Leadership'**
  String get groupSettingsTransferLeadership;

  /// No description provided for @transferConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer leadership?'**
  String get transferConfirmTitle;

  /// No description provided for @transferConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Leadership will be transferred to {name}. You will become a co-leader.'**
  String transferConfirmBody(String name);

  /// No description provided for @transferConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferConfirmCta;

  /// No description provided for @transferSuccess.
  ///
  /// In en, this message translates to:
  /// **'Leadership transferred to {name}'**
  String transferSuccess(String name);

  /// No description provided for @transferIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose a member to become the new group leader.'**
  String get transferIntro;

  /// No description provided for @transferSelectMember.
  ///
  /// In en, this message translates to:
  /// **'Select a member'**
  String get transferSelectMember;

  /// No description provided for @transferToName.
  ///
  /// In en, this message translates to:
  /// **'Transfer to {name}'**
  String transferToName(String name);

  /// No description provided for @manageRolesIntro.
  ///
  /// In en, this message translates to:
  /// **'Tap a member to toggle between co-leader and member.'**
  String get manageRolesIntro;

  /// No description provided for @manageRolesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Roles updated'**
  String get manageRolesUpdated;

  /// No description provided for @manageRolesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update roles'**
  String get manageRolesFailed;

  /// No description provided for @removeMemberConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Remove 1 member?} other{Remove {count} members?}}'**
  String removeMemberConfirmTitle(int count);

  /// No description provided for @removeMemberConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The following will be removed:\n{names}'**
  String removeMemberConfirmBody(String names);

  /// No description provided for @removeMemberFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove members'**
  String get removeMemberFailed;

  /// No description provided for @removeMemberSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member removed} other{{count} members removed}}'**
  String removeMemberSuccess(int count);

  /// No description provided for @removeMemberIntro.
  ///
  /// In en, this message translates to:
  /// **'Select members to remove from the group.'**
  String get removeMemberIntro;

  /// No description provided for @removeMemberSelectCta.
  ///
  /// In en, this message translates to:
  /// **'Select members'**
  String get removeMemberSelectCta;

  /// No description provided for @noGroupEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter an invite code'**
  String get noGroupEnterCode;

  /// No description provided for @noGroupInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid invite code'**
  String get noGroupInvalidCode;

  /// No description provided for @noGroupJoinedTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve joined the group!'**
  String get noGroupJoinedTitle;

  /// No description provided for @noGroupWelcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to {name}'**
  String noGroupWelcomeTo(String name);

  /// No description provided for @noGroupCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Group'**
  String get noGroupCreateTitle;

  /// No description provided for @noGroupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get noGroupNameHint;

  /// No description provided for @noGroupDescHint.
  ///
  /// In en, this message translates to:
  /// **'Add a description (optional)'**
  String get noGroupDescHint;

  /// No description provided for @noGroupNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a group name'**
  String get noGroupNameRequired;

  /// No description provided for @noGroupCreated.
  ///
  /// In en, this message translates to:
  /// **'Group created'**
  String get noGroupCreated;

  /// No description provided for @noGroupCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create group'**
  String get noGroupCreateFailed;

  /// No description provided for @noGroupJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a Group'**
  String get noGroupJoinTitle;

  /// No description provided for @noGroupJoinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Count selawat together with\nyour family, friends, or community'**
  String get noGroupJoinSubtitle;

  /// No description provided for @noGroupCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'ENTER CODE'**
  String get noGroupCodePlaceholder;

  /// No description provided for @noGroupJoinCta.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get noGroupJoinCta;

  /// No description provided for @noGroupJoinFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to join group'**
  String get noGroupJoinFailed;

  /// No description provided for @hadithDailyAdkar.
  ///
  /// In en, this message translates to:
  /// **'Daily Dhikr'**
  String get hadithDailyAdkar;

  /// No description provided for @hadithDailyAdkarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Morning & evening remembrance'**
  String get hadithDailyAdkarSubtitle;

  /// No description provided for @hadithDailyAdkarDesc.
  ///
  /// In en, this message translates to:
  /// **'Morning & evening remembrance (أذكار) to be recited daily as part of a Muslim\'s spiritual routine.'**
  String get hadithDailyAdkarDesc;

  /// No description provided for @hadithPostSalaah.
  ///
  /// In en, this message translates to:
  /// **'Post-Salaah'**
  String get hadithPostSalaah;

  /// No description provided for @hadithPostSalaahName.
  ///
  /// In en, this message translates to:
  /// **'Post-Salaah Zikr'**
  String get hadithPostSalaahName;

  /// No description provided for @hadithPostSalaahSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remembrance after prayer'**
  String get hadithPostSalaahSubtitle;

  /// No description provided for @hadithPostSalaahDesc.
  ///
  /// In en, this message translates to:
  /// **'Remembrance and supplications to be recited after the five daily prayers.'**
  String get hadithPostSalaahDesc;

  /// No description provided for @hadithDoaCollection.
  ///
  /// In en, this message translates to:
  /// **'Doa Collection'**
  String get hadithDoaCollection;

  /// No description provided for @hadithDoaCollectionName.
  ///
  /// In en, this message translates to:
  /// **'Useful Duas Collection'**
  String get hadithDoaCollectionName;

  /// No description provided for @hadithDoaCollectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse supplications by category'**
  String get hadithDoaCollectionSubtitle;

  /// No description provided for @hadithDoaCollectionDesc.
  ///
  /// In en, this message translates to:
  /// **'102 supplications sourced from the Quran & Sunnah, categorized by topic for easy reference.'**
  String get hadithDoaCollectionDesc;

  /// No description provided for @hadithFortyNawawi.
  ///
  /// In en, this message translates to:
  /// **'Forty Nawawi Hadiths'**
  String get hadithFortyNawawi;

  /// No description provided for @hadithFortyNawawiDesc.
  ///
  /// In en, this message translates to:
  /// **'40 authentic hadiths compiled by Imam An-Nawawi, covering the foundations of Islamic law, worship, and conduct.'**
  String get hadithFortyNawawiDesc;

  /// No description provided for @hadithFortyNawawiUsed.
  ///
  /// In en, this message translates to:
  /// **'Daily Hadith section'**
  String get hadithFortyNawawiUsed;

  /// No description provided for @hadithDoaUsed.
  ///
  /// In en, this message translates to:
  /// **'Daily Doa & Doa Collection sections'**
  String get hadithDoaUsed;

  /// No description provided for @hadithAdkarUsed.
  ///
  /// In en, this message translates to:
  /// **'Daily Dhikr section'**
  String get hadithAdkarUsed;

  /// No description provided for @hadithPostSalaahUsed.
  ///
  /// In en, this message translates to:
  /// **'Post-Salaah section'**
  String get hadithPostSalaahUsed;

  /// No description provided for @sourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sources & Credits'**
  String get sourcesTitle;

  /// No description provided for @sourcesApiName.
  ///
  /// In en, this message translates to:
  /// **'Naikiyah Dua Data API'**
  String get sourcesApiName;

  /// No description provided for @sourcesDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'All content is sourced from open Islamic API databases. We do not claim ownership of any religious content.'**
  String get sourcesDisclaimer;

  /// No description provided for @doaCategoryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 doa} other{{count} doa}}'**
  String doaCategoryCount(int count);

  /// No description provided for @hadithErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load'**
  String get hadithErrorTitle;

  /// No description provided for @hadithErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again'**
  String get hadithErrorBody;

  /// No description provided for @statsTotalSelawat.
  ///
  /// In en, this message translates to:
  /// **'Total Selawat'**
  String get statsTotalSelawat;

  /// No description provided for @statsTotalZikir.
  ///
  /// In en, this message translates to:
  /// **'Total Zikir'**
  String get statsTotalZikir;

  /// No description provided for @statsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Activity Yet'**
  String get statsEmptyTitle;

  /// No description provided for @statsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Start counting selawat and zikir\nto see your statistics here'**
  String get statsEmptyBody;

  /// No description provided for @statsEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Go to Tasbih'**
  String get statsEmptyCta;

  /// No description provided for @statsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update. Please try again.'**
  String get statsUpdateFailed;

  /// No description provided for @statsUpdatedToast.
  ///
  /// In en, this message translates to:
  /// **'Updated · {name} · {prev} → {next}'**
  String statsUpdatedToast(String name, int prev, int next);

  /// No description provided for @statsDailyGoalSetToast.
  ///
  /// In en, this message translates to:
  /// **'Daily goal set to {value}'**
  String statsDailyGoalSetToast(int value);

  /// No description provided for @sourcesUsedForLabel.
  ///
  /// In en, this message translates to:
  /// **'Used for: {section}'**
  String sourcesUsedForLabel(String section);

  /// No description provided for @statsTopOnDate.
  ///
  /// In en, this message translates to:
  /// **'On {date}'**
  String statsTopOnDate(String date);

  /// No description provided for @groupCreatedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String groupCreatedOnLabel(String date);

  /// No description provided for @hadithDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get hadithDailyTitle;

  /// No description provided for @hadithDailySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your spiritual companion'**
  String get hadithDailySubtitle;

  /// No description provided for @hadithSourceInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Source Info'**
  String get hadithSourceInfoTitle;

  /// No description provided for @hadithSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get hadithSourceLabel;

  /// No description provided for @hadithDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get hadithDescriptionLabel;

  /// No description provided for @hadithDoaShortDesc.
  ///
  /// In en, this message translates to:
  /// **'102 supplications from Quran & Sunnah, categorized by topic.'**
  String get hadithDoaShortDesc;

  /// No description provided for @groupInviteCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied!'**
  String get groupInviteCopied;

  /// No description provided for @groupGroupFallback.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupGroupFallback;

  /// No description provided for @groupUnknownMember.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get groupUnknownMember;

  /// No description provided for @groupDailyGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get groupDailyGoalLabel;

  /// No description provided for @groupNoneValue.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get groupNoneValue;

  /// No description provided for @groupShareInviteText.
  ///
  /// In en, this message translates to:
  /// **'Join my group on SelawatHub! Use invite code: {code}'**
  String groupShareInviteText(String code);

  /// No description provided for @groupSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Settings'**
  String get groupSettingsTitle;

  /// No description provided for @groupSettingsSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get groupSettingsSectionGeneral;

  /// No description provided for @groupSettingsSectionInvite.
  ///
  /// In en, this message translates to:
  /// **'INVITE'**
  String get groupSettingsSectionInvite;

  /// No description provided for @groupSettingsSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get groupSettingsSectionNotifications;

  /// No description provided for @groupSettingsSectionRoles.
  ///
  /// In en, this message translates to:
  /// **'ROLES & PERMISSIONS'**
  String get groupSettingsSectionRoles;

  /// No description provided for @groupSettingsSectionManage.
  ///
  /// In en, this message translates to:
  /// **'MANAGE'**
  String get groupSettingsSectionManage;

  /// No description provided for @groupSettingsCopyInvite.
  ///
  /// In en, this message translates to:
  /// **'Copy Invite Code'**
  String get groupSettingsCopyInvite;

  /// No description provided for @groupSettingsShareInvite.
  ///
  /// In en, this message translates to:
  /// **'Share Invite Link'**
  String get groupSettingsShareInvite;

  /// No description provided for @groupSettingsRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get groupSettingsRemoveMember;

  /// No description provided for @groupSettingsLeaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get groupSettingsLeaveGroup;

  /// No description provided for @groupSettingsDeleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get groupSettingsDeleteGroup;

  /// No description provided for @groupRoleLeader.
  ///
  /// In en, this message translates to:
  /// **'Leader'**
  String get groupRoleLeader;

  /// No description provided for @groupRoleCoLeader.
  ///
  /// In en, this message translates to:
  /// **'Co-leader'**
  String get groupRoleCoLeader;

  /// No description provided for @groupRoleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get groupRoleMember;

  /// No description provided for @groupRoleLeaderDesc.
  ///
  /// In en, this message translates to:
  /// **'Full group control. Edit name, manage roles, remove any member, transfer leadership, delete group.'**
  String get groupRoleLeaderDesc;

  /// No description provided for @groupRoleCoLeaderDesc.
  ///
  /// In en, this message translates to:
  /// **'Can remove regular members and manage invites. Auto-promoted to leader if leader leaves.'**
  String get groupRoleCoLeaderDesc;

  /// No description provided for @groupRoleMemberDesc.
  ///
  /// In en, this message translates to:
  /// **'Can participate in group selawat counting and view group progress.'**
  String get groupRoleMemberDesc;

  /// No description provided for @groupNoCoLeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'No co-leader assigned'**
  String get groupNoCoLeaderTitle;

  /// No description provided for @groupNoCoLeaderBody.
  ///
  /// In en, this message translates to:
  /// **'You must promote a member to co-leader or transfer leadership before leaving the group.'**
  String get groupNoCoLeaderBody;

  /// No description provided for @groupLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave group?'**
  String get groupLeaveTitle;

  /// No description provided for @groupLeaveLeaderBody.
  ///
  /// In en, this message translates to:
  /// **'Leadership will be automatically transferred to the next co-leader or oldest member.'**
  String get groupLeaveLeaderBody;

  /// No description provided for @groupLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'You will no longer see this group\'s progress or contribute to the count.'**
  String get groupLeaveBody;

  /// No description provided for @groupLeaveCta.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get groupLeaveCta;

  /// No description provided for @groupLeaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to leave group'**
  String get groupLeaveFailed;

  /// No description provided for @groupLeaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'You left the group'**
  String get groupLeaveSuccess;

  /// No description provided for @groupDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete group?'**
  String get groupDeleteTitle;

  /// No description provided for @groupDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the group for all members. This action cannot be undone.'**
  String get groupDeleteBody;

  /// No description provided for @groupDeleteCta.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get groupDeleteCta;

  /// No description provided for @groupDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete group'**
  String get groupDeleteFailed;

  /// No description provided for @groupDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Group deleted'**
  String get groupDeleteSuccess;

  /// No description provided for @groupRemoveMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get groupRemoveMemberTitle;

  /// No description provided for @groupRemoveCta.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get groupRemoveCta;

  /// No description provided for @groupTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer Leadership'**
  String get groupTransferTitle;

  /// No description provided for @groupTransferFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to transfer leadership'**
  String get groupTransferFailed;

  /// No description provided for @groupManageRolesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Roles'**
  String get groupManageRolesTitle;

  /// No description provided for @groupSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get groupSaveChanges;

  /// No description provided for @groupYearlyTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {value} selawat'**
  String groupYearlyTotal(String value);

  /// No description provided for @groupSettingsBan.
  ///
  /// In en, this message translates to:
  /// **'Ban from Group'**
  String get groupSettingsBan;

  /// No description provided for @removeMemberCtaCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Remove 1 member} other{Remove {count} members}}'**
  String removeMemberCtaCount(int count);

  /// No description provided for @statsBestStreakValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String statsBestStreakValue(int count);

  /// No description provided for @groupNeedCoLeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'No co-leader assigned'**
  String get groupNeedCoLeaderTitle;

  /// No description provided for @groupNeedCoLeaderBody.
  ///
  /// In en, this message translates to:
  /// **'You must promote a member to co-leader or transfer leadership before leaving the group.'**
  String get groupNeedCoLeaderBody;

  /// No description provided for @groupSettingsDescNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get groupSettingsDescNone;

  /// No description provided for @groupMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get groupMembersTitle;

  /// No description provided for @groupDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get groupDailyGoal;

  /// No description provided for @faqQ_data_language_q.
  ///
  /// In en, this message translates to:
  /// **'How do I change the app language?'**
  String get faqQ_data_language_q;

  /// No description provided for @faqQ_data_language_a.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Language and choose English or Bahasa Melayu. You can also change the language from the onboarding or sign-in screens by tapping the language icon. Your language preference is saved locally and stays the same every time you open the app.'**
  String get faqQ_data_language_a;

  /// No description provided for @aboutFeature8.
  ///
  /// In en, this message translates to:
  /// **'English & Bahasa Melayu support'**
  String get aboutFeature8;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ms'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'ms':
      return AppL10nMs();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
