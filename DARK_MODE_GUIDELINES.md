# Dark Mode Development Guidelines

## Overview
This document provides guidelines for ensuring all screens and widgets in the Smart Travel app properly support both light and dark modes.

## Core Principles

### 1. Never Use Hardcoded Colors
❌ **WRONG**:
```dart
Container(
  color: Colors.white,
  child: Text(
    'Hello',
    style: TextStyle(color: Colors.black),
  ),
)
```

✅ **CORRECT**:
```dart
Container(
  color: Theme.of(context).cardColor,
  child: Text(
    'Hello',
    style: TextStyle(
      color: Theme.of(context).textTheme.bodyLarge?.color,
    ),
  ),
)
```

### 2. Use Theme-Aware Colors

The app uses the following color scheme:

**Light Mode:**
- Background: Default Material light background  
- Cards/Surface: White (`#FFFFFF`)
- Text: Dark gray/black (automatic from Material3)

**Dark Mode (IntelliJ Darcula-inspired):**
- Background: `#1E1E1E` (very dark gray)
- Cards/Surface: `#2B2B2B` (slightly lighter for elevation)
- Text: Light gray/white (automatic from Material3)

### 3. Theme Properties Reference

| Use Case | Property to Use |
|----------|----------------|
| Screen background | `Theme.of(context).scaffoldBackgroundColor` |
| Card/Container | `Theme.of(context).cardColor` |
| Surface | `Theme.of(context).colorScheme.surface` |
| Body text | `Theme.of(context).textTheme.bodyMedium?.color` |
| Title text | `Theme.of(context).textTheme.titleLarge?.color` |
| Subtitle text | `Theme.of(context).textTheme.bodySmall?.color` |
| Primary color | `Theme.of(context).colorScheme.primary` or `AppColors.primary` |
| Icons | `Theme.of(context).iconTheme.color` |

## Common Patterns

### Pattern 1: Basic Scaffold
```dart
Scaffold(
  backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Usually omitted (default)
  appBar: AppBar(
    title: Text('My Screen'),
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),
  body: YourContent(),
)
```

### Pattern 2: Cards and Containers
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(
          Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05
        ),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: YourContent(),
)
```

### Pattern 3: Text Styling
```dart
Text(
  'Primary Text',
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).textTheme.bodyLarge?.color,
  ),
)

Text(
  'Secondary Text',
  style: TextStyle(
    fontSize: 14,
    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
  ),
)
```

### Pattern 4: Conditional Dark Mode Styling
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;

Container(
  color: isDark ? Colors.grey[800] : Colors.grey[200],
  // or
  decoration: BoxDecoration(
    color: Theme.of(context).cardColor,
    border: isDark ? Border.all(color: Colors.grey[700]!) : null,
  ),
)
```

### Pattern 5: Icons
```dart
Icon(
  Icons.home,
  color: isSelected 
    ? AppColors.primary 
    : Theme.of(context).iconTheme.color,
)
```

## Common Mistakes to Avoid

### ❌ Mistake 1: Hardcoded White Backgrounds
```dart
Container(color: Colors.white) // Will be white in dark mode!
```
**Fix**: Use `Theme.of(context).cardColor`

### ❌ Mistake 2: Hardcoded Gray Text
```dart
Text('Hello', style: TextStyle(color: Colors.grey[600]))
```
**Fix**: Use `Theme.of(context).textTheme.bodyMedium?.color`

### ❌ Mistake 3: Fixed Opacity Without Theme Check
```dart
Colors.black.withOpacity(0.1) // Too dark in dark mode
```
**Fix**: Check theme brightness:
```dart
Colors.black.withOpacity(isDark ? 0.3 : 0.1)
```

### ❌ Mistake 4: Using `const` with Theme Colors
```dart
const Container(
  color: Theme.of(context).cardColor, // Won't compile!
)
```
**Fix**: Remove `const` keyword when using theme properties

## Testing Checklist

Before committing code, verify:

- [ ] Toggle dark mode in Settings → verify your screen adapts correctly
- [ ] No white boxes or containers in dark mode
- [ ] All text is readable (good contrast)
- [ ] Icons and indicators are visible
- [ ] Shadows/elevations are appropriate (stronger in dark mode)
- [ ] Navigation elements (AppBar, BottomNav) match theme
- [ ] No hardcoded `Colors.white`, `Colors.black`, or `Colors.grey[...]`

## Examples from Codebase

### Good Example: level_progress_widget.dart
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;

Container(
  decoration: BoxDecoration(
    color: Theme.of(context).cardColor, // ✅ Theme-aware
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), // ✅ Conditional opacity
      ),
    ],
  ),
  child: Text(
    'Level',
    style: TextStyle(
      color: Theme.of(context).textTheme.bodyMedium?.color, // ✅ Theme text color
    ),
  ),
)
```

### Good Example: bottom_navigation.dart
```dart
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).cardColor, // ✅ Theme-aware
    border: isDark ? Border(...) : null, // ✅ Conditional styling
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08), // ✅ Adaptive
      ),
    ],
  ),
)
```

## Quick Reference Command

When creating a new widget, ask yourself:
1. Am I using any hardcoded `Colors.*`? → Use `Theme.of(context)` instead
2. Do shadows/borders need different opacity? → Check `isDark`
3. Is text readable in both modes? → Use theme text styles
4. Does it look good in both modes? → Test by toggling Settings

## Support

If you encounter dark mode issues:
1. Check this guide for the correct pattern
2. Look at `level_progress_widget.dart` or `bottom_navigation.dart` as reference
3. Test with dark mode ON before committing
4. Never use hardcoded white/black/gray colors!

---

**Last Updated**: Initial version (2025-11-21)  
**Maintainer**: Development Team
