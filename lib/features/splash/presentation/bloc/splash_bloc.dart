import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_startup.dart';
import '../../domain/usecase/initialize_app.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc({required this._initializeApp}) : super(const SplashInitial()) {
    on<SplashStarted>(_onStarted);
  }

  final InitializeApp _initializeApp;

  Future<void> _onStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());
    try {
      final startup = await _initializeApp();
      emit(SplashLoaded(startup));
    } catch (e) {
      emit(SplashFailure(e.toString()));
    }
  }
}
