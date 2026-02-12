// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Merge Chain Blast';

  @override
  String get subtitle => 'Block Merge Puzzle';

  @override
  String get start => 'START';

  @override
  String get leaderboard => 'LEADERBOARD';

  @override
  String get settings => 'Settings';

  @override
  String get bgm => 'Background Music';

  @override
  String get bgmDesc => 'Game background music';

  @override
  String get sfx => 'Sound Effects';

  @override
  String get sfxDesc => 'Merge and drop sound effects';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationDesc => 'Haptic feedback on merge and drop';

  @override
  String get ghostBlock => 'Ghost Block';

  @override
  String get ghostBlockDesc => 'Preview block landing position';

  @override
  String get nickname => 'Nickname';

  @override
  String get nicknameNotSet => 'Not set';

  @override
  String get reviewTutorial => 'Review Tutorial';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get restoringPurchases => 'Restoring purchases...';

  @override
  String get setNickname => 'Set Nickname';

  @override
  String get nicknameHint => 'A-Z, 0-9, _ only (2-10 chars)';

  @override
  String get nicknameMinError => 'Enter at least 2 characters';

  @override
  String get nicknameMaxError => 'Maximum 10 characters';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'OK';

  @override
  String get removeAds => 'Remove Ads';

  @override
  String get purchased => 'Purchased';

  @override
  String get removeAdsDesc => 'Permanently remove all ads';

  @override
  String removeAdsConfirm(String price) {
    return 'Remove all ads permanently for $price?';
  }

  @override
  String get removeAdsConfirmDefault => 'Remove all ads permanently?';

  @override
  String get purchase => 'Purchase';

  @override
  String get gameOver => 'GAME OVER';

  @override
  String get scoreLabel => 'SCORE';

  @override
  String levelLabel(int level) {
    return 'LV.$level';
  }

  @override
  String scoreValue(int score) {
    return 'Score: $score';
  }

  @override
  String get merges => 'Merges';

  @override
  String get maxChain => 'Max Chain';

  @override
  String get scoreSubmitFailed => 'Failed to submit score';

  @override
  String get scoreSubmitted => 'Score submitted!';

  @override
  String get submitScore => 'Submit Score';

  @override
  String get home => 'HOME';

  @override
  String get rank => 'RANK';

  @override
  String get retry => 'RETRY';

  @override
  String get paused => 'PAUSED';

  @override
  String get resume => 'Continue';

  @override
  String get quit => 'Quit';

  @override
  String get youWin => 'YOU WIN!';

  @override
  String get next => 'NEXT';

  @override
  String get newBest => 'NEW BEST!';

  @override
  String get merge => 'MERGE!';

  @override
  String get chainX2 => 'CHAIN x2!';

  @override
  String get chainX3 => 'CHAIN x3!';

  @override
  String megaChain(int count) {
    return 'MEGA x$count!';
  }

  @override
  String superChain(int count) {
    return 'SUPER x$count!';
  }

  @override
  String amazingChain(int count) {
    return 'AMAZING x$count!';
  }

  @override
  String spectacularChain(int count) {
    return 'SPECTACULAR x$count!';
  }

  @override
  String legendaryChain(int count) {
    return 'LEGENDARY x$count!';
  }

  @override
  String get skip => 'Skip';

  @override
  String get tutorialIntroTitle => 'Drop blocks and\nmerge same numbers!';

  @override
  String get tutorialIntroDesc =>
      'Place falling blocks. Same-number tiles merge automatically.';

  @override
  String get tutorialControls => 'Controls';

  @override
  String get swipeLeftRight => 'Swipe Left/Right';

  @override
  String get moveBlock => 'Move Block';

  @override
  String get tap => 'Tap';

  @override
  String get rotateBlock => 'Rotate Block';

  @override
  String get swipeDownFast => 'Fast Swipe Down';

  @override
  String get hardDrop => 'Hard Drop';

  @override
  String get swipeDown => 'Swipe Down';

  @override
  String get softDrop => 'Soft Drop';

  @override
  String get tutorialChainTitle => 'Chain Merge';

  @override
  String get tutorialChainDesc => 'Chain merges give explosive score bonuses!';

  @override
  String get tutorialChainExample => 'CHAIN x3  x7  x15 !';

  @override
  String get tutorialGoTitle => 'Go for the\nhighest score!';

  @override
  String get tutorialGoDesc =>
      'Game over when blocks reach the top.\nPlace strategically and aim for chains!';

  @override
  String get loadFailed => 'Failed to load';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noRecords => 'No records yet';

  @override
  String leaderboardEntry(int merges, int chain) {
    return 'Merges: $merges | Chain: x$chain';
  }

  @override
  String get enterNickname => 'Enter Nickname';

  @override
  String get nicknameDialogHint => 'A-Z, 0-9, _ only (2-10 chars)';

  @override
  String get watchAdContinue => 'WATCH AD';

  @override
  String get continueGame => 'CONTINUE';

  @override
  String get keepGoing => 'KEEP GOING';

  @override
  String get quitConfirmTitle => 'Quit Game?';

  @override
  String get quitConfirmMessage => 'Your current progress will be lost.';

  @override
  String get timeAttack => 'TIME ATTACK';

  @override
  String get timeUp => 'TIME\'S UP!';

  @override
  String get classic => 'CLASSIC';
}
