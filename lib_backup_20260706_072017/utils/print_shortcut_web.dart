// Web implementation — intercepts Ctrl+P (and Cmd+P on Mac) and
// triggers our custom PDF print instead of the browser's native
// screenshot-style print.
import 'dart:html' show window;
import 'dart:html' as html;

void setupCtrlPShortcut(void Function() onPrint) {
  window.onKeyDown.listen((html.KeyboardEvent e) {
    final key = (e.key ?? '').toLowerCase();
    if ((e.ctrlKey || e.metaKey) && key == 'p') {
      e.preventDefault();
      e.stopPropagation();
      onPrint();
    }
  });
}