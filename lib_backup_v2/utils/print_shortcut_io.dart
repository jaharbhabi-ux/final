// Stub for non-web platforms — no Ctrl+P shortcut handling.
// On mobile/desktop, use the on-screen Print button instead.
void setupCtrlPShortcut(void Function() onPrint) {
  // No-op on non-web platforms.
}