// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Merge Chain Blast';

  @override
  String get subtitle => 'Block Merge Puzzle';

  @override
  String get start => 'スタート';

  @override
  String get leaderboard => 'ランキング';

  @override
  String get settings => '設定';

  @override
  String get bgm => 'BGM';

  @override
  String get bgmDesc => 'ゲームBGM';

  @override
  String get sfx => '効果音';

  @override
  String get sfxDesc => 'マージ・ドロップ効果音';

  @override
  String get vibration => '振動';

  @override
  String get vibrationDesc => 'マージ・ドロップ時の触覚フィードバック';

  @override
  String get ghostBlock => 'ゴーストブロック';

  @override
  String get ghostBlockDesc => 'ブロックの着地位置をプレビュー';

  @override
  String get nickname => 'ニックネーム';

  @override
  String get nicknameNotSet => '未設定';

  @override
  String get reviewTutorial => 'チュートリアルを見直す';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get restoringPurchases => '購入を復元中...';

  @override
  String get setNickname => 'ニックネーム設定';

  @override
  String get nicknameHint => 'A-Z, 0-9, _ のみ（2〜10文字）';

  @override
  String get nicknameMinError => '2文字以上入力してください';

  @override
  String get nicknameMaxError => '最大10文字までです';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get confirm => 'OK';

  @override
  String get removeAds => '広告を削除';

  @override
  String get purchased => '購入済み';

  @override
  String get removeAdsDesc => 'すべての広告を永久に削除します';

  @override
  String removeAdsConfirm(String price) {
    return '$priceですべての広告を永久に削除しますか？';
  }

  @override
  String get removeAdsConfirmDefault => 'すべての広告を永久に削除しますか？';

  @override
  String get purchase => '購入';

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
    return 'スコア: $score';
  }

  @override
  String get merges => 'マージ数';

  @override
  String get maxChain => '最大チェイン';

  @override
  String get scoreSubmitFailed => 'スコアの送信に失敗しました';

  @override
  String get scoreSubmitted => 'スコアを送信しました！';

  @override
  String get submitScore => 'スコアを送信';

  @override
  String get home => 'HOME';

  @override
  String get rank => 'RANK';

  @override
  String get retry => 'RETRY';

  @override
  String get paused => 'PAUSED';

  @override
  String get resume => '続ける';

  @override
  String get quit => 'やめる';

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
  String get skip => 'スキップ';

  @override
  String get tutorialIntroTitle => 'ブロックを落として\n同じ数字を合体させよう！';

  @override
  String get tutorialIntroDesc => '落ちてくるブロックを配置しよう。同じ数字のタイルが隣り合うと自動でマージされます。';

  @override
  String get tutorialControls => '操作方法';

  @override
  String get swipeLeftRight => '左右スワイプ';

  @override
  String get moveBlock => 'ブロック移動';

  @override
  String get tap => 'タップ';

  @override
  String get rotateBlock => 'ブロック回転';

  @override
  String get swipeDownFast => '素早く下スワイプ';

  @override
  String get hardDrop => '即落下';

  @override
  String get swipeDown => '下スワイプ';

  @override
  String get softDrop => '高速落下';

  @override
  String get tutorialChainTitle => 'チェインマージ';

  @override
  String get tutorialChainDesc => '連鎖マージでスコアが爆発的にアップ！';

  @override
  String get tutorialChainExample => 'CHAIN x3  x7  x15 !';

  @override
  String get tutorialGoTitle => '最高スコアを\n目指そう！';

  @override
  String get tutorialGoDesc => 'ブロックが頂上に達するとゲームオーバー。\n戦略的に配置してチェインを狙おう！';

  @override
  String get loadFailed => '読み込みに失敗しました';

  @override
  String get tryAgain => '再試行';

  @override
  String get noRecords => 'まだ記録がありません';

  @override
  String leaderboardEntry(int merges, int chain) {
    return 'マージ: $merges | チェイン: x$chain';
  }

  @override
  String get enterNickname => 'ニックネームを入力';

  @override
  String get nicknameDialogHint => 'A-Z, 0-9, _ のみ（2〜10文字）';

  @override
  String get watchAdContinue => '広告を見る';

  @override
  String get continueGame => 'コンティニュー';

  @override
  String get keepGoing => '続ける';

  @override
  String get quitConfirmTitle => 'ゲームをやめますか？';

  @override
  String get quitConfirmMessage => '現在の進行状況は失われます。';

  @override
  String get timeAttack => 'タイムアタック';

  @override
  String get timeUp => 'タイムアップ！';

  @override
  String get classic => 'クラシック';

  @override
  String get myBest => '自己ベスト';

  @override
  String get noRecord => '記録なし';

  @override
  String get periodDaily => '今日';

  @override
  String get periodWeekly => '週間';

  @override
  String get periodMonthly => '月間';

  @override
  String get periodYearly => '年間';

  @override
  String get periodAll => '全期間';

  @override
  String get pauseNotAllowed => 'タイムアタックでは\n一時停止できません！';

  @override
  String get timeAttackTutorialTitle => 'タイムアタック';

  @override
  String get timeAttackTutorialRule1 => '3分間で最高スコアを\n目指しましょう！';

  @override
  String get timeAttackTutorialRule2 => '一時停止はできません。\n集中しましょう！';

  @override
  String get timeAttackTutorialRule3 => 'バックグラウンドでも\nタイマーは止まりません。';

  @override
  String get timeAttackTutorialGo => 'GO!';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get language => '言語';

  @override
  String get languageDesc => 'アプリの表示言語を変更';

  @override
  String get playTime => 'Time';
}
