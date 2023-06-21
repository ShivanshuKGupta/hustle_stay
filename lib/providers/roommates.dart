import 'package:flutter_riverpod/flutter_riverpod.dart';

class _roomMatesProviderNotifier extends StateNotifier<int> {
  _roomMatesProviderNotifier() : super(0);
  void updateValue(int value) {
    state = value;
  }
}

final roomMatesProvider =
    StateNotifierProvider<_roomMatesProviderNotifier, int>(
        (ref) => _roomMatesProviderNotifier());
