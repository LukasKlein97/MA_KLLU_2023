import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2735738452823796/1172726657';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2735738452823796/9737612384';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get bannerBigAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2735738452823796/8919871656';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2735738452823796/1204516245';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get bannerAdUnitIdTest {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/1033173712";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/4411468910";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/5224354917";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/1712485313";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
