import 'package:get_it/get_it.dart';
import 'package:ncs_app/src/screens/bacground/audio_handler.dart';

GetIt getIt = GetIt.instance;

Future<void> initServiceLocator() async {
  getIt.registerSingleton<AudioServiceHandler>(await initeAudioService());
}