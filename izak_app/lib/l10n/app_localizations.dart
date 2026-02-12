import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

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
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge Chain Blast'**
  String get appTitle;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'Block Merge Puzzle'**
  String get subtitle;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get start;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'LEADERBOARD'**
  String get leaderboard;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @bgm.
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get bgm;

  /// No description provided for @bgmDesc.
  ///
  /// In en, this message translates to:
  /// **'Game background music'**
  String get bgmDesc;

  /// No description provided for @sfx.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get sfx;

  /// No description provided for @sfxDesc.
  ///
  /// In en, this message translates to:
  /// **'Merge and drop sound effects'**
  String get sfxDesc;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrationDesc.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback on merge and drop'**
  String get vibrationDesc;

  /// No description provided for @ghostBlock.
  ///
  /// In en, this message translates to:
  /// **'Ghost Block'**
  String get ghostBlock;

  /// No description provided for @ghostBlockDesc.
  ///
  /// In en, this message translates to:
  /// **'Preview block landing position'**
  String get ghostBlockDesc;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @nicknameNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get nicknameNotSet;

  /// No description provided for @reviewTutorial.
  ///
  /// In en, this message translates to:
  /// **'Review Tutorial'**
  String get reviewTutorial;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @restoringPurchases.
  ///
  /// In en, this message translates to:
  /// **'Restoring purchases...'**
  String get restoringPurchases;

  /// No description provided for @setNickname.
  ///
  /// In en, this message translates to:
  /// **'Set Nickname'**
  String get setNickname;

  /// No description provided for @nicknameHint.
  ///
  /// In en, this message translates to:
  /// **'A-Z, 0-9, _ only (2-10 chars)'**
  String get nicknameHint;

  /// No description provided for @nicknameMinError.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 2 characters'**
  String get nicknameMinError;

  /// No description provided for @nicknameMaxError.
  ///
  /// In en, this message translates to:
  /// **'Maximum 10 characters'**
  String get nicknameMaxError;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get confirm;

  /// No description provided for @removeAds.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get removeAds;

  /// No description provided for @purchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchased;

  /// No description provided for @removeAdsDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove all ads'**
  String get removeAdsDesc;

  /// No description provided for @removeAdsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove all ads permanently for {price}?'**
  String removeAdsConfirm(String price);

  /// No description provided for @removeAdsConfirmDefault.
  ///
  /// In en, this message translates to:
  /// **'Remove all ads permanently?'**
  String get removeAdsConfirmDefault;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'GAME OVER'**
  String get gameOver;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'SCORE'**
  String get scoreLabel;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'LV.{level}'**
  String levelLabel(int level);

  /// No description provided for @scoreValue.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String scoreValue(int score);

  /// No description provided for @merges.
  ///
  /// In en, this message translates to:
  /// **'Merges'**
  String get merges;

  /// No description provided for @maxChain.
  ///
  /// In en, this message translates to:
  /// **'Max Chain'**
  String get maxChain;

  /// No description provided for @scoreSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit score'**
  String get scoreSubmitFailed;

  /// No description provided for @scoreSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Score submitted!'**
  String get scoreSubmitted;

  /// No description provided for @submitScore.
  ///
  /// In en, this message translates to:
  /// **'Submit Score'**
  String get submitScore;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get home;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'RANK'**
  String get rank;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get paused;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get resume;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @youWin.
  ///
  /// In en, this message translates to:
  /// **'YOU WIN!'**
  String get youWin;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// No description provided for @newBest.
  ///
  /// In en, this message translates to:
  /// **'NEW BEST!'**
  String get newBest;

  /// No description provided for @merge.
  ///
  /// In en, this message translates to:
  /// **'MERGE!'**
  String get merge;

  /// No description provided for @chainX2.
  ///
  /// In en, this message translates to:
  /// **'CHAIN x2!'**
  String get chainX2;

  /// No description provided for @chainX3.
  ///
  /// In en, this message translates to:
  /// **'CHAIN x3!'**
  String get chainX3;

  /// No description provided for @megaChain.
  ///
  /// In en, this message translates to:
  /// **'MEGA x{count}!'**
  String megaChain(int count);

  /// No description provided for @superChain.
  ///
  /// In en, this message translates to:
  /// **'SUPER x{count}!'**
  String superChain(int count);

  /// No description provided for @amazingChain.
  ///
  /// In en, this message translates to:
  /// **'AMAZING x{count}!'**
  String amazingChain(int count);

  /// No description provided for @spectacularChain.
  ///
  /// In en, this message translates to:
  /// **'SPECTACULAR x{count}!'**
  String spectacularChain(int count);

  /// No description provided for @legendaryChain.
  ///
  /// In en, this message translates to:
  /// **'LEGENDARY x{count}!'**
  String legendaryChain(int count);

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @tutorialIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Drop blocks and\nmerge same numbers!'**
  String get tutorialIntroTitle;

  /// No description provided for @tutorialIntroDesc.
  ///
  /// In en, this message translates to:
  /// **'Place falling blocks. Same-number tiles merge automatically.'**
  String get tutorialIntroDesc;

  /// No description provided for @tutorialControls.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get tutorialControls;

  /// No description provided for @swipeLeftRight.
  ///
  /// In en, this message translates to:
  /// **'Swipe Left/Right'**
  String get swipeLeftRight;

  /// No description provided for @moveBlock.
  ///
  /// In en, this message translates to:
  /// **'Move Block'**
  String get moveBlock;

  /// No description provided for @tap.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get tap;

  /// No description provided for @rotateBlock.
  ///
  /// In en, this message translates to:
  /// **'Rotate Block'**
  String get rotateBlock;

  /// No description provided for @swipeDownFast.
  ///
  /// In en, this message translates to:
  /// **'Fast Swipe Down'**
  String get swipeDownFast;

  /// No description provided for @hardDrop.
  ///
  /// In en, this message translates to:
  /// **'Hard Drop'**
  String get hardDrop;

  /// No description provided for @swipeDown.
  ///
  /// In en, this message translates to:
  /// **'Swipe Down'**
  String get swipeDown;

  /// No description provided for @softDrop.
  ///
  /// In en, this message translates to:
  /// **'Soft Drop'**
  String get softDrop;

  /// No description provided for @tutorialChainTitle.
  ///
  /// In en, this message translates to:
  /// **'Chain Merge'**
  String get tutorialChainTitle;

  /// No description provided for @tutorialChainDesc.
  ///
  /// In en, this message translates to:
  /// **'Chain merges give explosive score bonuses!'**
  String get tutorialChainDesc;

  /// No description provided for @tutorialChainExample.
  ///
  /// In en, this message translates to:
  /// **'CHAIN x3  x7  x15 !'**
  String get tutorialChainExample;

  /// No description provided for @tutorialGoTitle.
  ///
  /// In en, this message translates to:
  /// **'Go for the\nhighest score!'**
  String get tutorialGoTitle;

  /// No description provided for @tutorialGoDesc.
  ///
  /// In en, this message translates to:
  /// **'Game over when blocks reach the top.\nPlace strategically and aim for chains!'**
  String get tutorialGoDesc;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get loadFailed;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get noRecords;

  /// No description provided for @leaderboardEntry.
  ///
  /// In en, this message translates to:
  /// **'Merges: {merges} | Chain: x{chain}'**
  String leaderboardEntry(int merges, int chain);

  /// No description provided for @enterNickname.
  ///
  /// In en, this message translates to:
  /// **'Enter Nickname'**
  String get enterNickname;

  /// No description provided for @nicknameDialogHint.
  ///
  /// In en, this message translates to:
  /// **'A-Z, 0-9, _ only (2-10 chars)'**
  String get nicknameDialogHint;

  /// No description provided for @watchAdContinue.
  ///
  /// In en, this message translates to:
  /// **'WATCH AD'**
  String get watchAdContinue;

  /// No description provided for @continueGame.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueGame;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'KEEP GOING'**
  String get keepGoing;

  /// No description provided for @quitConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Quit Game?'**
  String get quitConfirmTitle;

  /// No description provided for @quitConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Your current progress will be lost.'**
  String get quitConfirmMessage;

  /// No description provided for @timeAttack.
  ///
  /// In en, this message translates to:
  /// **'TIME ATTACK'**
  String get timeAttack;

  /// No description provided for @timeUp.
  ///
  /// In en, this message translates to:
  /// **'TIME\'S UP!'**
  String get timeUp;

  /// No description provided for @classic.
  ///
  /// In en, this message translates to:
  /// **'CLASSIC'**
  String get classic;
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
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
