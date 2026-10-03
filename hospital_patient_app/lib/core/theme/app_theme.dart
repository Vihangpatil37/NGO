import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary brand palette - Warm Healthcare Teal & Ocean Blue
  static const Color primary = Color(0xFF0F7B6C);
  static const Color primaryLight = Color(0xFFE0F2F1);
  static const Color primaryDark = Color(0xFF004D40);

  static const Color accent = Color(0xFF1565C0);
  static const Color accentLight = Color(0xFFE3F2FD);

  // Dark mode primaries
  static const Color darkPrimary = Color(0xFF26A69A);
  static const Color darkPrimaryLight = Color(0xFF004D40);
  static const Color darkAccent = Color(0xFF42A5F5);

  // Queue status states (Light)
  static const Color waiting = Color(0xFF2E7D32);
  static const Color waitingBg = Color(0xFFE8F5E9);
  static const Color almostTurn = Color(0xFFE65100);
  static const Color almostTurnBg = Color(0xFFFFF3E0);
  static const Color yourTurn = Color(0xFFC62828);
  static const Color yourTurnBg = Color(0xFFFFEBEE);
  static const Color completed = Color(0xFF1565C0);
  static const Color completedBg = Color(0xFFE3F2FD);
  static const Color skipped = Color(0xFFD32F2F);
  static const Color skippedBg = Color(0xFFFFEBEE);

  // Queue status states (Dark)
  static const Color darkWaiting = Color(0xFF66BB6A);
  static const Color darkWaitingBg = Color(0xFF132E16);
  static const Color darkAlmostTurn = Color(0xFFFFA726);
  static const Color darkAlmostTurnBg = Color(0xFF332008);
  static const Color darkYourTurn = Color(0xFFEF5350);
  static const Color darkYourTurnBg = Color(0xFF381414);
  static const Color darkCompleted = Color(0xFF64B5F6);
  static const Color darkCompletedBg = Color(0xFF0F2642);
  static const Color darkSkipped = Color(0xFFE57373);
  static const Color darkSkippedBg = Color(0xFF331414);

  // Neutrals - Light Mode
  static const Color background = Color(0xFFF6F8FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF151E28);
  static const Color textSecondary = Color(0xFF5F6E7D);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEDF2F7);

  // Neutrals - Dark Mode
  static const Color darkBackground = Color(0xFF0F141C);
  static const Color darkSurface = Color(0xFF18202A);
  static const Color darkSurfaceCard = Color(0xFF1F2937);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF2B3747);
  static const Color darkDivider = Color(0xFF232D3B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F7B6C), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF0A554A), Color(0xFF0F4A80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFF0F7B6C), Color(0xFF26A69A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradientLight = LinearGradient(
    colors: [Colors.white, Color(0xFFF9FBFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    colors: [Color(0xFF1F2937), Color(0xFF17202B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Context Helpers
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color cardBackground(BuildContext context) =>
      isDark(context) ? darkSurfaceCard : surface;

  static Color getSurface(BuildContext context) =>
      isDark(context) ? darkSurface : surface;

  static Color getBackground(BuildContext context) =>
      isDark(context) ? darkBackground : background;

  static Color getBorder(BuildContext context) =>
      isDark(context) ? darkBorder : border;

  static Color getTextPrimary(BuildContext context) =>
      isDark(context) ? darkTextPrimary : textPrimary;

  static Color getTextSecondary(BuildContext context) =>
      isDark(context) ? darkTextSecondary : textSecondary;

  static LinearGradient getHeaderGradient(BuildContext context) =>
      isDark(context) ? darkPrimaryGradient : primaryGradient;

  static LinearGradient getCardGradient(BuildContext context) =>
      isDark(context) ? cardGradientDark : cardGradientLight;

  static List<BoxShadow> softShadow(BuildContext context) {
    if (isDark(context)) {
      return [
        BoxShadow(
          color: Colors.black.withAlpha(80),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return [
      BoxShadow(
        color: const Color(0xFF0F7B6C).withAlpha(15),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.black.withAlpha(8),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];
  }
}

class AppDecorations {
  static BoxDecoration glassCard(BuildContext context, {double radius = 20, Color? borderColor}) {
    final isDark = AppColors.isDark(context);
    return BoxDecoration(
      color: isDark ? AppColors.darkSurfaceCard.withAlpha(220) : Colors.white.withAlpha(240),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? (isDark ? AppColors.darkBorder : AppColors.border),
        width: 1.2,
      ),
      boxShadow: AppColors.softShadow(context),
    );
  }

  static BoxDecoration gradientHeader(BuildContext context, {double borderRadius = 28}) {
    return BoxDecoration(
      gradient: AppColors.getHeaderGradient(context),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      ),
      boxShadow: [
        BoxShadow(
          color: (AppColors.isDark(context) ? Colors.black : const Color(0xFF0F7B6C)).withAlpha(40),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    final interText = GoogleFonts.interTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: interText.copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 56,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: -1.5,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.textPrimary,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.45,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.yourTurn, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.yourTurn, width: 2.0),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textSecondary.withAlpha(160),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;
    final interText = GoogleFonts.interTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkPrimary,
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: Colors.black,
        secondary: AppColors.darkAccent,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: interText.copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 56,
          fontWeight: FontWeight.w900,
          color: AppColors.darkTextPrimary,
          letterSpacing: -1.5,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.darkTextPrimary,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.darkTextSecondary,
          height: 1.45,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary, size: 24),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.darkTextPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkYourTurn, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkYourTurn, width: 2.0),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextSecondary,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.darkPrimary,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.darkTextSecondary.withAlpha(160),
        ),
      ),
    );
  }
}
