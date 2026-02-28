import 'package:flutter_bloc/flutter_bloc.dart';

/// Holds dark-mode flag; false = light, true = dark.
class ThemeCubit extends Cubit<bool> {
  ThemeCubit([super.initialValue = false]);

  void toggle() => emit(!state);

  void setDark(bool dark) => emit(dark);
}

