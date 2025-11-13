import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:get/get.dart';

import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_strings.dart';


class VlcVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const VlcVideoPlayer({super.key, required this.videoUrl});

  @override
  State<VlcVideoPlayer> createState() => _VlcVideoPlayerState();
}

class _VlcVideoPlayerState extends State<VlcVideoPlayer> {
  VlcPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VlcPlayerController.network(
      widget.videoUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(AppStrings.videoPlayer),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          leading: IconButton(onPressed: (){
            Get.back();
          }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        ),
        body: Center(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _controller != null
                ? VlcPlayer(
                    controller: _controller!,
                    aspectRatio: 16 / 9,
                    placeholder: const Center(child: CircularProgressIndicator()),
                  )
                : SizedBox(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.stop();
    _controller?.dispose();
    super.dispose();
  }
}
