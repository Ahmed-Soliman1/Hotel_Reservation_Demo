import 'package:flutter/material.dart';

/// Modern luxury hotel booking app theme with glass-morphism and gradients
class AppTheme {
  // ============ COLOR PALETTE ============
  static const Color primaryDeep = Color(0xFF1a1f3a); // Deep navy
  static const Color primaryGradientStart = Color(0xFF0f47af); // Rich blue
  static const Color primaryGradientEnd = Color(0xFF6a0572); // Deep purple
  
  static const Color accentGold = Color(0xFFd4af37); // Luxury gold
  static const Color accentCyan = Color(0xFF00d9ff); // Cyber cyan
  static const Color accentMagenta = Color(0xFFff006e); // Hot magenta
  
  static const Color surfaceLight = Color(0xFff8f9fa); // Almost white
  static const Color surfaceDark = Color(0xFF0d1117); // Deep dark
  static const Color surfaceCard = Color(0xFF161b22); // Card dark
  
  static const Color textPrimary = Color(0xFFffffff); // White
  static const Color textSecondary = Color(0xFFb0b8c0); // Light gray
  static const Color textMuted = Color(0xFF6e7681); // Muted gray
  
  static const Color successGreen = Color(0xFF10b981); // Emerald
  static const Color warningOrange = Color(0xFFf59e0b); // Amber
  static const Color errorRed = Color(0xFFef4444); // Red
  static const Color infoBlue = Color(0xFF3b82f6); // Blue

  // ============ GRADIENTS ============
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGradientStart, primaryGradientEnd],
  );

  static const LinearGradient luxuryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1a1f3a), Color(0xFF0f47af), Color(0xFF6a0572)],
    stops: [0.0, 0.5, 1.0],
  );

  static LinearGradient cyberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      accentCyan.withOpacity(0.2),
      accentMagenta.withOpacity(0.2),
    ],
  );

  // ============ THEME DATA ============
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: accentCyan,
    scaffoldBackgroundColor: primaryDeep,
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryDeep,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: accentCyan.withOpacity(0.1),
          width: 1,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceCard.withOpacity(0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: accentCyan.withOpacity(0.3),
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: accentCyan.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: accentCyan,
          width: 2,
        ),
      ),
      labelStyle: const TextStyle(
        color: textSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: textMuted.withOpacity(0.7),
        fontSize: 14,
      ),
      prefixIconColor: MaterialStateColor.resolveWith(
        (states) => states.contains(MaterialState.focused)
            ? accentCyan
            : textSecondary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentCyan,
        foregroundColor: primaryDeep,
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentCyan,
        side: const BorderSide(color: accentCyan, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentCyan,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Text Themes
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: textPrimary,
        letterSpacing: -1.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.15,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMuted,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 1.25,
      ),
    ),
  );

  // ============ CUSTOM COLORS ============
  static const Map<String, Color> statusColors = {
    'available': successGreen,
    'booked': errorRed,
    'maintenance': warningOrange,
    'pending': infoBlue,
  };
}

// ============ CUSTOM DECORATIONS ============
class GlassMorphismDecoration {
  static BoxDecoration glass({
    double opacity = 0.1,
    double blur = 10,
    bool hasBorder = true,
  }) {
    return BoxDecoration(
      color: AppTheme.accentCyan.withOpacity(opacity),
      borderRadius: BorderRadius.circular(20),
      border: hasBorder
          ? Border.all(
              color: AppTheme.accentCyan.withOpacity(0.2),
              width: 1.5,
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: AppTheme.accentCyan.withOpacity(0.1),
          blurRadius: blur,
          spreadRadius: 2,
        ),
      ],
    );
  }

  static BoxDecoration card() {
    return BoxDecoration(
      color: AppTheme.surfaceCard,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppTheme.accentCyan.withOpacity(0.15),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration gradientCard() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.accentCyan.withOpacity(0.1),
          AppTheme.accentMagenta.withOpacity(0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppTheme.accentCyan.withOpacity(0.2),
        width: 1.5,
      ),
    );
  }
}

// ============ SPACING & SIZING ============
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
}

// ============ BORDER RADIUS ============
class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double full = 9999;

  static final BorderRadius smRadius = BorderRadius.circular(sm);
  static final BorderRadius mdRadius = BorderRadius.circular(md);
  static final BorderRadius lgRadius = BorderRadius.circular(lg);
  static final BorderRadius xlRadius = BorderRadius.circular(xl);
  static final BorderRadius xxlRadius = BorderRadius.circular(xxl);
}

// ============ SHADOW SYSTEM ============
class AppShadows {
  static final List<BoxShadow> sm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> md = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> lg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 12,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> xl = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 16,
      offset: const Offset(0, 12),
    ),
  ];

  static final List<BoxShadow> glow = [
    BoxShadow(
      color: AppTheme.accentCyan.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 0),
    ),
  ];
}
