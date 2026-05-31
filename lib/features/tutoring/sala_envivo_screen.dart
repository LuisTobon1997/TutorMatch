import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

class SalaEnvivoScreen extends StatelessWidget {
  final String liveID;
  final bool isHost;
  final String userId;
  final String userName;

  const SalaEnvivoScreen({
    super.key,
    required this.liveID,
    required this.isHost,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final int appID = 1096027892;
    final String appSign =
        "af2a044f41fd89cce55b76020dcb266de52d3d34a6a8135773aae2ee725ae70d";

    return SafeArea(
      child: ZegoUIKitPrebuiltVideoConference(
        appID: appID,
        appSign: appSign,
        userID: userId,
        userName: userName,
        conferenceID: liveID,
        config: ZegoUIKitPrebuiltVideoConferenceConfig()
          ..turnOnCameraWhenJoining = isHost
          ..turnOnMicrophoneWhenJoining = isHost
          ..bottomMenuBarConfig.buttons = [
            ZegoMenuBarButtonName.toggleCameraButton,
            ZegoMenuBarButtonName.toggleMicrophoneButton,
            ZegoMenuBarButtonName.switchCameraButton,
            ZegoMenuBarButtonName.leaveButton,
            ZegoMenuBarButtonName.chatButton,
          ],
      ),
    );
  }
}
