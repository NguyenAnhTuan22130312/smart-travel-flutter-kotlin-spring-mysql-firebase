import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('vi'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @smsNotifications.
  ///
  /// In en, this message translates to:
  /// **'SMS Notifications'**
  String get smsNotifications;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeletedSuccess;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get changePasswordSuccess;

  /// No description provided for @updateSettingsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings updated successfully'**
  String get updateSettingsSuccess;

  /// No description provided for @updateProfileSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get updateProfileSuccess;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search destinations, tours...'**
  String get searchHint;

  /// No description provided for @aiAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Travel Assistant'**
  String get aiAssistantTitle;

  /// No description provided for @aiAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let AI suggest suitable tours for you'**
  String get aiAssistantSubtitle;

  /// No description provided for @noDestinations.
  ///
  /// In en, this message translates to:
  /// **'No destinations for this category'**
  String get noDestinations;

  /// No description provided for @travelDestinations.
  ///
  /// In en, this message translates to:
  /// **'Travel Destinations'**
  String get travelDestinations;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @noFeaturedDestinations.
  ///
  /// In en, this message translates to:
  /// **'No featured destinations'**
  String get noFeaturedDestinations;

  /// No description provided for @featuredDestinations.
  ///
  /// In en, this message translates to:
  /// **'Featured Destinations'**
  String get featuredDestinations;

  /// No description provided for @errorLoadFeatured.
  ///
  /// In en, this message translates to:
  /// **'Failed to load featured destinations'**
  String get errorLoadFeatured;

  /// No description provided for @noPopularProvinces.
  ///
  /// In en, this message translates to:
  /// **'No popular provinces'**
  String get noPopularProvinces;

  /// No description provided for @popularProvinces.
  ///
  /// In en, this message translates to:
  /// **'Popular Provinces'**
  String get popularProvinces;

  /// No description provided for @errorLoadProvinces.
  ///
  /// In en, this message translates to:
  /// **'Failed to load popular provinces'**
  String get errorLoadProvinces;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @memberBenefits.
  ///
  /// In en, this message translates to:
  /// **'Member Benefits'**
  String get memberBenefits;

  /// No description provided for @samtraVip.
  ///
  /// In en, this message translates to:
  /// **'SamtraVIP'**
  String get samtraVip;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @helpAndInfo.
  ///
  /// In en, this message translates to:
  /// **'Help & Info'**
  String get helpAndInfo;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @accountManagement.
  ///
  /// In en, this message translates to:
  /// **'Account Management'**
  String get accountManagement;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteAccount;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile information'**
  String get errorLoadProfile;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navBooking.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBooking;

  /// No description provided for @navAiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get navAiChat;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get fullNameHint;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter full name'**
  String get fullNameRequired;

  /// No description provided for @fullNameLength.
  ///
  /// In en, this message translates to:
  /// **'Full name must be 2–100 characters'**
  String get fullNameLength;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get phoneHint;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 10 digits'**
  String get phoneInvalid;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @dobLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dobLabel;

  /// No description provided for @dobPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select date of birth'**
  String get dobPlaceholder;

  /// No description provided for @bioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioLabel;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'Write a few lines about yourself'**
  String get bioHint;

  /// No description provided for @bioMax.
  ///
  /// In en, this message translates to:
  /// **'Bio up to 1000 characters'**
  String get bioMax;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter address'**
  String get addressHint;

  /// No description provided for @addressMax.
  ///
  /// In en, this message translates to:
  /// **'Address up to 100 characters'**
  String get addressMax;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @cityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get cityHint;

  /// No description provided for @cityMax.
  ///
  /// In en, this message translates to:
  /// **'City up to 50 characters'**
  String get cityMax;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @countryHint.
  ///
  /// In en, this message translates to:
  /// **'Enter country'**
  String get countryHint;

  /// No description provided for @countryMax.
  ///
  /// In en, this message translates to:
  /// **'Country up to 50 characters'**
  String get countryMax;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @userLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Member Levels'**
  String get userLevelTitle;

  /// No description provided for @levelBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Level Benefits'**
  String get levelBenefitsTitle;

  /// No description provided for @levelDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get levelDiamond;

  /// No description provided for @levelGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get levelGold;

  /// No description provided for @levelSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get levelSilver;

  /// No description provided for @levelBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get levelBronze;

  /// No description provided for @benefitDiscount15.
  ///
  /// In en, this message translates to:
  /// **'15% off all bookings'**
  String get benefitDiscount15;

  /// No description provided for @benefitPrioritySupport247.
  ///
  /// In en, this message translates to:
  /// **'Priority support 24/7'**
  String get benefitPrioritySupport247;

  /// No description provided for @benefitFreeRoomUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Free room upgrade'**
  String get benefitFreeRoomUpgrade;

  /// No description provided for @benefitLateCheckoutFree.
  ///
  /// In en, this message translates to:
  /// **'Free late check-out'**
  String get benefitLateCheckoutFree;

  /// No description provided for @benefitTriplePoints.
  ///
  /// In en, this message translates to:
  /// **'Triple points'**
  String get benefitTriplePoints;

  /// No description provided for @benefitDiscount10.
  ///
  /// In en, this message translates to:
  /// **'10% off all bookings'**
  String get benefitDiscount10;

  /// No description provided for @benefitPrioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get benefitPrioritySupport;

  /// No description provided for @benefitDoublePoints.
  ///
  /// In en, this message translates to:
  /// **'Double points'**
  String get benefitDoublePoints;

  /// No description provided for @benefitEarlyCheckinFree.
  ///
  /// In en, this message translates to:
  /// **'Free early check-in'**
  String get benefitEarlyCheckinFree;

  /// No description provided for @benefitDiscount5.
  ///
  /// In en, this message translates to:
  /// **'5% off all bookings'**
  String get benefitDiscount5;

  /// No description provided for @benefitOnePointFiveTimes.
  ///
  /// In en, this message translates to:
  /// **'1.5× points'**
  String get benefitOnePointFiveTimes;

  /// No description provided for @benefitSeasonalOffers.
  ///
  /// In en, this message translates to:
  /// **'Seasonal special offers'**
  String get benefitSeasonalOffers;

  /// No description provided for @benefitEarnPointsEachBooking.
  ///
  /// In en, this message translates to:
  /// **'Earn points for each booking'**
  String get benefitEarnPointsEachBooking;

  /// No description provided for @benefitReceiveSpecialDeals.
  ///
  /// In en, this message translates to:
  /// **'Receive special deals'**
  String get benefitReceiveSpecialDeals;

  /// No description provided for @benefitPromoUpdates.
  ///
  /// In en, this message translates to:
  /// **'Promotions updates'**
  String get benefitPromoUpdates;

  /// No description provided for @requirementDiamond.
  ///
  /// In en, this message translates to:
  /// **'7000+ XP'**
  String get requirementDiamond;

  /// No description provided for @requirementGold.
  ///
  /// In en, this message translates to:
  /// **'3000 - 6999 XP'**
  String get requirementGold;

  /// No description provided for @requirementSilver.
  ///
  /// In en, this message translates to:
  /// **'1000 - 2999 XP'**
  String get requirementSilver;

  /// No description provided for @requirementBronze.
  ///
  /// In en, this message translates to:
  /// **'0 - 999 XP'**
  String get requirementBronze;

  /// No description provided for @earnXpTitle.
  ///
  /// In en, this message translates to:
  /// **'How to earn XP'**
  String get earnXpTitle;

  /// No description provided for @earnXpBookingHotel.
  ///
  /// In en, this message translates to:
  /// **'Book a hotel: +100 XP'**
  String get earnXpBookingHotel;

  /// No description provided for @earnXpWriteReview.
  ///
  /// In en, this message translates to:
  /// **'Write a review: +50 XP'**
  String get earnXpWriteReview;

  /// No description provided for @earnXpCompleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete profile: +30 XP'**
  String get earnXpCompleteProfile;

  /// No description provided for @earnXpReferFriends.
  ///
  /// In en, this message translates to:
  /// **'Refer friends: +80 XP'**
  String get earnXpReferFriends;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'WARNING: This action cannot be undone!\n\nAll your data including personal information, booking history, reviews and benefits will be permanently deleted.\n\nAre you sure you want to continue?'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountButton;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @passwordInfo.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordInfo;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordLabel;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter current password'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @passwordAtLeast8.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordAtLeast8;

  /// No description provided for @newPasswordDifferent.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from current password'**
  String get newPasswordDifferent;

  /// No description provided for @pleaseConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm new password'**
  String get pleaseConfirmNewPassword;

  /// No description provided for @confirmNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Confirmation password does not match'**
  String get confirmNotMatch;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordButton;

  /// No description provided for @changingPassword.
  ///
  /// In en, this message translates to:
  /// **'Changing password...'**
  String get changingPassword;

  /// No description provided for @myInvoices.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myInvoices;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @noInvoices.
  ///
  /// In en, this message translates to:
  /// **'You have no bookings yet'**
  String get noInvoices;

  /// No description provided for @errorLoadLevel.
  ///
  /// In en, this message translates to:
  /// **'Failed to load level information'**
  String get errorLoadLevel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
