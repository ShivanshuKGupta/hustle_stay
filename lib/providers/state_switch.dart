import 'package:flutter_riverpod/flutter_riverpod.dart';

class _StateSwitch extends StateNotifier<bool> {
  _StateSwitch() : super(false);

  /// If watch listeners do not react to changes automatically,
  /// then use this function to notify all watch listeners
  void changeState() {
    state = !state;
  }
}

/// Use it to create a state switch and the use it in widgets
/// These switches can be toggled to rebuild the widget they were used in
StateNotifierProvider<_StateSwitch, bool> createSwitch() {
  return StateNotifierProvider<_StateSwitch, bool>((ref) => _StateSwitch());
}

void toggleSwitch(
    WidgetRef ref, StateNotifierProvider<_StateSwitch, bool> stateSwitch) {
  ref.read(stateSwitch.notifier).changeState();
}
