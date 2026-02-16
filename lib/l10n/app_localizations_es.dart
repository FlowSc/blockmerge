// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Merge Chain Blast';

  @override
  String get subtitle => 'Block Merge Puzzle';

  @override
  String get start => 'JUGAR';

  @override
  String get leaderboard => 'CLASIFICACIÓN';

  @override
  String get settings => 'Ajustes';

  @override
  String get bgm => 'Música de fondo';

  @override
  String get bgmDesc => 'Música de fondo del juego';

  @override
  String get sfx => 'Efectos de sonido';

  @override
  String get sfxDesc => 'Efectos de sonido de fusión y caída';

  @override
  String get vibration => 'Vibración';

  @override
  String get vibrationDesc => 'Vibración al fusionar y soltar bloques';

  @override
  String get ghostBlock => 'Bloque fantasma';

  @override
  String get ghostBlockDesc => 'Vista previa de la posición de aterrizaje';

  @override
  String get nickname => 'Apodo';

  @override
  String get nicknameNotSet => 'Sin definir';

  @override
  String get reviewTutorial => 'Repetir tutorial';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get restoringPurchases => 'Restaurando compras...';

  @override
  String get setNickname => 'Establecer apodo';

  @override
  String get nicknameHint => 'Solo A-Z, 0-9, _ (2-10 caracteres)';

  @override
  String get nicknameMinError => 'Introduce al menos 2 caracteres';

  @override
  String get nicknameMaxError => 'Máximo 10 caracteres';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get confirm => 'OK';

  @override
  String get removeAds => 'Eliminar anuncios';

  @override
  String get purchased => 'Comprado';

  @override
  String get removeAdsDesc => 'Eliminar todos los anuncios permanentemente';

  @override
  String removeAdsConfirm(String price) {
    return '¿Eliminar todos los anuncios permanentemente por $price?';
  }

  @override
  String get removeAdsConfirmDefault =>
      '¿Eliminar todos los anuncios permanentemente?';

  @override
  String get purchase => 'Comprar';

  @override
  String get gameOver => 'FIN DEL JUEGO';

  @override
  String get scoreLabel => 'PUNTOS';

  @override
  String levelLabel(int level) {
    return 'NV.$level';
  }

  @override
  String scoreValue(int score) {
    return 'Puntos: $score';
  }

  @override
  String get merges => 'Fusiones';

  @override
  String get maxChain => 'Cadena máx.';

  @override
  String get scoreSubmitFailed => 'Error al enviar la puntuación';

  @override
  String get scoreSubmitted => '¡Puntuación enviada!';

  @override
  String get submitScore => 'Enviar puntuación';

  @override
  String get home => 'INICIO';

  @override
  String get rank => 'RANGO';

  @override
  String get retry => 'REINTENTAR';

  @override
  String get paused => 'PAUSADO';

  @override
  String get resume => 'Continuar';

  @override
  String get quit => 'Salir';

  @override
  String get youWin => '¡GANASTE!';

  @override
  String get next => 'SIGUIENTE';

  @override
  String get newBest => '¡NUEVO RÉCORD!';

  @override
  String get merge => '¡FUSIÓN!';

  @override
  String get chainX2 => '¡CADENA x2!';

  @override
  String get chainX3 => '¡CADENA x3!';

  @override
  String megaChain(int count) {
    return '¡MEGA x$count!';
  }

  @override
  String superChain(int count) {
    return '¡SUPER x$count!';
  }

  @override
  String amazingChain(int count) {
    return '¡INCREÍBLE x$count!';
  }

  @override
  String spectacularChain(int count) {
    return '¡ESPECTACULAR x$count!';
  }

  @override
  String legendaryChain(int count) {
    return '¡LEGENDARIO x$count!';
  }

  @override
  String get skip => 'Omitir';

  @override
  String get tutorialIntroTitle =>
      '¡Suelta bloques y\nfusiona números iguales!';

  @override
  String get tutorialIntroDesc =>
      'Coloca los bloques que caen. Los números iguales se fusionan automáticamente.';

  @override
  String get tutorialControls => 'Controles';

  @override
  String get swipeLeftRight => 'Deslizar izquierda/derecha';

  @override
  String get moveBlock => 'Mover bloque';

  @override
  String get tap => 'Tocar';

  @override
  String get rotateBlock => 'Rotar bloque';

  @override
  String get swipeDownFast => 'Deslizar rápido hacia abajo';

  @override
  String get hardDrop => 'Caída instantánea';

  @override
  String get swipeDown => 'Deslizar hacia abajo';

  @override
  String get softDrop => 'Caída suave';

  @override
  String get tutorialChainTitle => 'Fusión en cadena';

  @override
  String get tutorialChainDesc =>
      '¡Las fusiones en cadena dan bonificaciones explosivas!';

  @override
  String get tutorialChainExample => 'CADENA x3  x7  x15 !';

  @override
  String get tutorialGoTitle => '¡Consigue la\npuntuación más alta!';

  @override
  String get tutorialGoDesc =>
      'El juego termina cuando los bloques llegan arriba.\n¡Coloca estratégicamente y busca cadenas!';

  @override
  String get loadFailed => 'Error al cargar';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get noRecords => 'Aún no hay registros';

  @override
  String leaderboardEntry(int merges, int chain) {
    return 'Fusiones: $merges | Cadena: x$chain';
  }

  @override
  String get enterNickname => 'Introducir apodo';

  @override
  String get nicknameDialogHint => 'Solo A-Z, 0-9, _ (2-10 caracteres)';

  @override
  String get watchAdContinue => 'VER ANUNCIO';

  @override
  String get continueGame => 'CONTINUAR';

  @override
  String get keepGoing => 'SEGUIR JUGANDO';

  @override
  String get quitConfirmTitle => '¿Salir del juego?';

  @override
  String get quitConfirmMessage => 'Se perderá tu progreso actual.';

  @override
  String get timeAttack => 'CONTRARRELOJ';

  @override
  String get timeUp => '¡TIEMPO AGOTADO!';

  @override
  String get classic => 'CLÁSICO';

  @override
  String get myBest => 'MI MEJOR';

  @override
  String get noRecord => 'Sin registro aún';

  @override
  String get periodDaily => 'HOY';

  @override
  String get periodWeekly => 'SEMANA';

  @override
  String get periodMonthly => 'MES';

  @override
  String get periodYearly => 'AÑO';

  @override
  String get periodAll => 'TODO';

  @override
  String get pauseNotAllowed =>
      '¡La pausa no está disponible\nen Contrarreloj!';

  @override
  String get timeAttackTutorialTitle => 'CONTRARRELOJ';

  @override
  String get timeAttackTutorialRule1 =>
      '¡3 minutos para conseguir\nla mayor puntuación posible!';

  @override
  String get timeAttackTutorialRule2 =>
      'La pausa está desactivada.\n¡Concéntrate!';

  @override
  String get timeAttackTutorialRule3 =>
      'El temporizador sigue corriendo\nincluso en segundo plano.';

  @override
  String get timeAttackTutorialGo => '¡YA!';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get language => 'Idioma';

  @override
  String get languageDesc => 'Cambiar el idioma de la aplicación';

  @override
  String get playTime => 'Time';
}
