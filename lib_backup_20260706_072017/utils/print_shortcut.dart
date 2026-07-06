// Conditional export — picks the web impl on Flutter Web, stub elsewhere.
export 'print_shortcut_io.dart'
    if (dart.library.html) 'print_shortcut_web.dart';