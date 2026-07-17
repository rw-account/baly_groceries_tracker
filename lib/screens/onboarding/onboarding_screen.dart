import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

// ============================================================
// Steam-Inspired Dark Theme Colors
// ============================================================
const Color _kPrimaryBlue = Color(0xFF66C0F4);
const Color _kBgColor = Color(0xFF171A21);
const Color _kSurfaceColor = Color(0xFF1E293B);
const Color _kCardColor = Color(0xFF22394F);
const Color _kTextPrimary = Color(0xFFC7D5E0);
const Color _kTextSecondary = Color(0xFF94A3B8);
const Color _kBorderColor = Color(0xFF3D5A73);

/// Builds a luxurious, glowing icon container that matches
/// the Steam dark theme aesthetic.
///
/// - Rounded corners (BorderRadius.circular(24))
/// - Subtle dark-blue gradient (Card -> Surface)
/// - Glowing BoxShadow using the Primary Blue
/// - Thin border (0xFF3D5A73)
/// - Centered Material Icon (size 40, Primary Blue)
Widget _buildLuxuryIcon(IconData icon) {
  return Container(
    width: 130,
    height: 130,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _kCardColor,
          _kSurfaceColor,
        ],
      ),
      border: Border.all(
        color: _kBorderColor,
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: _kPrimaryBlue.withValues(alpha: 0.25),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Icon(
      icon,
      size: 40.0,
      color: _kPrimaryBlue,
    ),
  );
}

/// Builds the shared [PageDecoration] used across all onboarding pages.
PageDecoration _buildPageDecoration() {
  return const PageDecoration(
    pageColor: _kBgColor,
    titleTextStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: _kTextPrimary,
    ),
    bodyTextStyle: TextStyle(
      fontSize: 16,
      height: 1.5,
      color: _kTextSecondary,
    ),
    imagePadding: EdgeInsets.only(bottom: 40),
    contentMargin: EdgeInsets.symmetric(horizontal: 16),
  );
}

/// Onboarding screen with a Steam-inspired dark theme.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  /// Builds the list of onboarding pages.
  List<PageViewModel> _buildPages() {
    return [
      PageViewModel(
        title: "وداعاً لحيرة النواقص",
        body:
            "توقف عن التخمين اليومي: 'هل يكفي الدقيق؟ متى ينتهي السكر؟'. "
            "انقل عناء التذكر بالكامل إلى تطبيقك، ووفر طاقتك الذهنية لما هو أهم.",
        image: _buildLuxuryIcon(Icons.lightbulb_outline),
        decoration: _buildPageDecoration(),
      ),
      PageViewModel(
        title: "تنبيه ذكي.. وقت الحاجة فقط",
        body:
            "عند اقتراب النفاد، إشعار استباقي واحد يمنحك رؤية كاملة للمستقبل. "
            "اعرف ما يوشك على الانتهاء، واقضِ على أزمات النقص المفاجئ تماماً.",
        image: _buildLuxuryIcon(Icons.notifications_none),
        decoration: _buildPageDecoration(),
      ),
      PageViewModel(
        title: "قائمة مشترياتك بضغطة واحدة",
        body:
            "بنقرة زر، تتحول المواد الناقصة تلقائياً إلى قائمة شراء منظمة. "
            "تدخل السوق وأنت تعرف احتياجاتك بدقة، دون هدر للوقت أو الميزانية.",
        image: _buildLuxuryIcon(Icons.shopping_bag_outlined),
        decoration: _buildPageDecoration(),
      ),
      PageViewModel(
        title: "أمان كامل.. وبيانات مضمونة",
        body:
            "لا إنترنت ولا حسابات. معلومات منزلك محفوظة داخل هاتفك فقط لضمان خصوصيتك، "
            "مع توفر ميزة (النسخ الاحتياطي) لحفظ بياناتك ونقلها متى أردت.",
        image: _buildLuxuryIcon(Icons.shield_outlined),
        decoration: _buildPageDecoration(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _kBgColor,
        body: SafeArea(
          child: IntroductionScreen(
            globalBackgroundColor: _kBgColor,
            pages: _buildPages(),
            showSkipButton: true,
            showBackButton: false,
            skip: const Text(
              "تخطي",
              style: TextStyle(color: _kTextSecondary),
            ),
            next: const Icon(
              Icons.arrow_forward,
              color: _kPrimaryBlue,
            ),
            done: const Text(
              "ابدأ الآن",
              style: TextStyle(
                color: _kPrimaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            onDone: () {
              debugPrint("OnboardingScreen: user pressed 'ابدأ الآن' (Done)");
            },
            onSkip: () {
              debugPrint("OnboardingScreen: user pressed 'تخطي' (Skip)");
            },
            dotsDecorator: DotsDecorator(
              activeColor: _kPrimaryBlue,
              color: _kTextSecondary.withValues(alpha: 0.3),
              size: const Size.square(8.0),
              activeSize: const Size(22.0, 8.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            controlsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            controlsMargin: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }
}