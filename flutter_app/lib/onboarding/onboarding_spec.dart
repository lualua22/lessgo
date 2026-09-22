import '../theme/app_theme.dart';

/// Onboarding shares the application palette.
abstract final class OnboardingColors {
  static const blue = AppColors.blue;
  static const deepBlue = AppColors.deepBlue;
  static const mint = AppColors.mint;
  static const yellow = AppColors.yellow;
  static const navy = AppColors.navy;
  static const gray = AppColors.gray;
  static const background = AppColors.white;
}

abstract final class OnboardingSpec {
  static const title = '스크롤은 줄이고\n하루는 더 가볍게';
  static const subtitle = '친구와 함께 목표를 정하고,\n스마트폰 시간을 건강하게 줄여보세요.';
  static const button = '시작하기';
  static const skip = 'Skip';
  static const image = 'assets/onboarding/lessgo-3d-phone.png';
  static const font = 'LessGoOnboarding';
  static const imageWidth = 335.0;
  static const buttonWidth = 178.0;
  static const buttonHeight = 52.0;
  static const floatCycle = Duration(milliseconds: 4200);
}
