import 'package:get_it/get_it.dart';
import 'package:ncs_app/src/screens/bacground/audio_handler.dart';

GetIt getIt = GetIt.instance;

Future<void> initServiceLocator() async {
  AudioServiceHandler? audioServiceHandler = await initeAudioService();
  if (audioServiceHandler != null) {
    getIt.registerSingleton<AudioServiceHandler>(audioServiceHandler);
  } else {
    // エラーハンドリングやログ出力などの適切な処理を行う
    print("Error: Failed to initialize AudioServiceHandler");
  }
}