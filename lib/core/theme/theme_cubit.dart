import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<bool> {
  ThemeCubit([super.initialValue = false]); // false = light, true = dark

  void toggle() => emit(!state);

  void setDark(bool dark) => emit(dark);
}

