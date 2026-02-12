// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Drop Merge';

  @override
  String get subtitle => 'Block Merge Puzzle';

  @override
  String get start => '시작하기';

  @override
  String get leaderboard => '리더보드';

  @override
  String get settings => '설정';

  @override
  String get bgm => '배경음악';

  @override
  String get bgmDesc => '게임 배경음악';

  @override
  String get sfx => '효과음';

  @override
  String get sfxDesc => '병합 및 드롭 효과음';

  @override
  String get vibration => '진동';

  @override
  String get vibrationDesc => '병합 및 드롭 시 햅틱 피드백';

  @override
  String get ghostBlock => '고스트 블록';

  @override
  String get ghostBlockDesc => '블록 착지 위치 미리보기';

  @override
  String get nickname => '닉네임';

  @override
  String get nicknameNotSet => '미설정';

  @override
  String get reviewTutorial => '튜토리얼 다시보기';

  @override
  String get restorePurchases => '구매 복원';

  @override
  String get restoringPurchases => '구매 복원 중...';

  @override
  String get setNickname => '닉네임 설정';

  @override
  String get nicknameHint => '2~10자 닉네임';

  @override
  String get nicknameMinError => '최소 2자 이상 입력하세요';

  @override
  String get nicknameMaxError => '최대 10자까지 가능합니다';

  @override
  String get cancel => '취소';

  @override
  String get save => '저장';

  @override
  String get confirm => '확인';

  @override
  String get removeAds => '광고 제거';

  @override
  String get purchased => '구매 완료';

  @override
  String get removeAdsDesc => '영구적으로 모든 광고를 제거합니다';

  @override
  String removeAdsConfirm(String price) {
    return '$price로 모든 광고를 영구적으로 제거하시겠습니까?';
  }

  @override
  String get removeAdsConfirmDefault => '모든 광고를 영구적으로 제거하시겠습니까?';

  @override
  String get purchase => '구매';

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
  String get scoreSubmitFailed => '점수 제출에 실패했습니다';

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
  String get resume => '계속하기';

  @override
  String get quit => '나가기';

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
  String get skip => '건너뛰기';

  @override
  String get tutorialIntroTitle => '블록을 떨어뜨려\n같은 숫자를 합쳐라!';

  @override
  String get tutorialIntroDesc =>
      '위에서 내려오는 블록을 배치하고\n같은 숫자 타일이 만나면 자동으로 병합됩니다.';

  @override
  String get tutorialControls => '조작법';

  @override
  String get swipeLeftRight => '좌/우 스와이프';

  @override
  String get moveBlock => '블록 이동';

  @override
  String get tap => '탭';

  @override
  String get rotateBlock => '블록 회전';

  @override
  String get swipeDownFast => '빠른 아래 스와이프';

  @override
  String get hardDrop => '즉시 낙하';

  @override
  String get swipeDown => '아래 스와이프';

  @override
  String get softDrop => '빠르게 내리기';

  @override
  String get tutorialChainTitle => '체인 병합';

  @override
  String get tutorialChainDesc => '연쇄 병합이 일어나면\n점수가 폭발적으로 증가합니다!';

  @override
  String get tutorialChainExample => 'CHAIN x3  x7  x15 !';

  @override
  String get tutorialGoTitle => '최고 점수에\n도전하세요!';

  @override
  String get tutorialGoDesc => '블록이 꼭대기까지 쌓이면 게임 오버.\n전략적으로 배치하고 체인을 노려보세요!';

  @override
  String get loadFailed => '불러오기 실패';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get noRecords => '아직 기록이 없습니다';

  @override
  String leaderboardEntry(int merges, int chain) {
    return 'Merges: $merges | Chain: x$chain';
  }

  @override
  String get enterNickname => '닉네임 입력';

  @override
  String get nicknameDialogHint => '리더보드에 표시될 이름 (2~10자)';

  @override
  String get continueGame => '이어하기';

  @override
  String get keepGoing => '계속하기';

  @override
  String get quitConfirmTitle => '게임 종료';

  @override
  String get quitConfirmMessage => '현재까지의 진행사항이 사라집니다.';

  @override
  String get timeAttack => '타임어택';

  @override
  String get timeUp => '시간 종료!';

  @override
  String get classic => '클래식';
}
