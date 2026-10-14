package com.example.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

// Modern refined typography using clean SansSerif with
// balanced tracking, line heights, and accessibility font scaling support.
val ModernFontFamily = FontFamily.SansSerif

val Typography = Typography(
    // Display styles (Dashboard hero numbers / prominent metrics)
    displayLarge = TextStyle(
        fontFamily = ModernFontFamily,
        fontWeight = FontWeight.Bold,
        fontSize = 30.sp,
        lineHeight = 36.sp,
        letterSpacing = (-0.75).sp,
        color = PrimaryText
    ),
    displayMedium = TextStyle(
        fontFamily = ModernFontFamily,
        fontWeight = FontWeight.Bold,
        fontSize = 26.sp,
        lineHeight = 32.sp,
        letterSpacing = (-0.5).sp,
        color = PrimaryText
    ),
    // Headline styles (Top-level screen titles, modal headers)
    headlineLarge = TextStyle(
        fontFamily = ModernFontFamily,
        fontWeight = FontWeight.Bold,
        fontSize = 22.sp,
        lineHeight = 28.sp,
        letterSpacing = (-0.35).sp,
        color = PrimaryText
    ),
    headlineMedium = TextStyle(
        fontFamily = ModernFontFamily,
        fontWeight = FontWeight.Bold,
        fontSize = 20.sp,
        lineHeight = 26.sp,
        letterSpacing = (-0.25).sp,
        color = PrimaryText
    ),
    headlineSmall = TextStyle(
        fontFamily = ModernFontFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 17.sp,
        lineHeight = 23.sp,
        letterSpacing = (-0.15).sp,
        color = PrimaryText
    ),
    // Title styles (Card titles, section headings, collection names)
    titleLarge = TextStyle(
        fontFamily = ModernFontFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 18.sp,
        lineHeight = 24.sp,
        letterSpacing = (-0.15).sp,
        color = PrimaryText
    ),
    titleMedium = TextStyle(
        fontFamily = ModernFontFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 15.sp,
        lineHeight = 21.sp,
        letterSpacing = (-0.1).sp,
        color = PrimaryText
    ),
    titleSmall = TextStyle(
        fontFamily = ModernFontFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.sp,
        color = PrimaryText
    ),
    // Body styles (Readable content, notes, URLs, descriptions)
    bodyLarge = TextStyle(
        fontFamily = ModernFontFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 15.sp,
        lineHeight = 22.sp,
        letterSpacing = 0.sp,
        color = PrimaryText
    ),
    bodyMedium = TextStyle(
        fontFamily = ModernFontFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 13.sp,
        lineHeight = 19.sp,
        letterSpacing = 0.sp,
        color = SecondaryText
    ),
    bodySmall = TextStyle(
        fontFamily = ModernFontFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 12.sp,
        lineHeight = 17.sp,
        letterSpacing = 0.sp,
        color = MutedText
    ),
    // Label styles (Buttons, filter chips, metadata tags, badges)
    labelLarge = TextStyle(
        fontFamily = ModernFontFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 13.sp,
        lineHeight = 18.sp,
        letterSpacing = 0.1.sp,
        color = PrimaryText
    ),
    labelMedium = TextStyle(
        fontFamily = ModernFontFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 11.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.15.sp,
        color = SecondaryText
    ),
    labelSmall = TextStyle(
        fontFamily = ModernFontFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 10.sp,
        lineHeight = 14.sp,
        letterSpacing = 0.2.sp,
        color = MutedText
    )
)
