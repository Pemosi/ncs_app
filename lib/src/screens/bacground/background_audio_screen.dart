// //バックグラウンド再生を実装している部分
// import 'package:flutter/material.dart';
// import 'package:ncs_app/src/screens/bacground/background_audio_screen_state.dart';
// import 'package:provider/provider.dart';

// class BackgroundAudioScreen extends StatelessWidget {
//   const BackgroundAudioScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => BackgroundAudioScreenState()..init(),
//       child: const _BackgroundPlayScreen(),
//     );
//   }
// }

// class _BackgroundPlayScreen extends StatelessWidget {
//   const _BackgroundPlayScreen();

//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//       title: const Text('Background Audio Sample'),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             colors: [
//               Colors.orange[600]!,
//               Colors.orange[400]!,
//               Colors.orange[200]!,
//             ],
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               const Spacer(),
//               Selector(
//                 selector:
//                     (BuildContext ctx, BackgroundAudioScreenState controller) =>
//                         controller.progressBarState,
//                 builder: (BuildContext ctx, ProgressBarState state, _) =>
//                     ProgressBar(
//                   progress: state.current,
//                   buffered: state.buffered,
//                   total: state.total,
//                   onSeek: (Duration position) =>
//                       context.read<BackgroundAudioScreenState>().seek(position),
//                 ),
//               ),
//               Selector(
//                 selector:
//                     (BuildContext ctx, BackgroundAudioScreenState controller) =>
//                         controller.audioState,
//                 builder: (BuildContext ctx, AudioState state, _) {
//                   switch (state) {
//                     case AudioState.loading:
//                       return const Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: SizedBox(
//                           height: 32,
//                           width: 32,
//                           child: CircularProgressIndicator(),
//                         ),
//                       );
//                     case AudioState.ready:
//                     case AudioState.paused:
//                       return IconButton(
//                         onPressed: () =>
//                             context.read<BackgroundAudioScreenState>().play(),
//                         icon: const Icon(Icons.play_arrow),
//                         iconSize: 32.0,
//                       );
//                     case AudioState.playing:
//                       return IconButton(
//                         onPressed: () =>
//                             context.read<BackgroundAudioScreenState>().pause(),
//                         icon: const Icon(Icons.pause),
//                         iconSize: 32.0,
//                       );
//                     default:
//                       return const SizedBox(height: 32, width: 32);
//                   }
//                 },
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }