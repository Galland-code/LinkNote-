import 'package:flutter/material.dart';

class AppTheme {
  // 颜色
  static final Color primaryColor = Color(0xFFB33856);
  static final Color secondaryColor = Color(0xFF6B8CCC);
  static final Color accentColor = Color(0xFF4CAF50);
  static final Color backgroundColor = Color(0xFFF5F5DC); // 米色网格背景
  static final Color cardColor = Color(0xFFF0F0E0);
  static final Color navBarColor = Color(0xFFC0C9D3);
  static final Color blueCardColor = Color(0xFF6B8CCC);
  static final Color pinkCardColor = Color(0xFFE8A0B0);
  static final Color yellowCardColor = Color(0xFFF5DEB3);
  static final Color greenCardColor = Color(0xFFBED7C1);
  static final Color errorColor = Color(0xFFB44663);


  // 文本样式
  static final TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static final TextStyle subtitleStyle = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static final TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: Colors.black,
  );

  static final TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey[700],
  );

  // 主题数据
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardColor,
        background: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: titleStyle,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Colors.black, width: 2),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      fontFamily: 'PixelFont',
      textTheme: TextTheme(
        displayLarge: titleStyle,
        headlineMedium: subtitleStyle,
        bodyLarge: bodyStyle,
        bodyMedium: bodyStyle,
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBarColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[700],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // 暗色主题（可选）
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.grey[800]!,
        background: Colors.grey[900]!,
      ),
      scaffoldBackgroundColor: Colors.grey[900],
      // 其他暗色主题配置...
    );
  }
}
