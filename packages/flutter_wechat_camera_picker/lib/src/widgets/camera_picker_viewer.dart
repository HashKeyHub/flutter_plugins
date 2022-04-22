///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/16 22:02
///
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

import '../constants/constants.dart';
import '../internals/enums.dart';
import '../internals/methods.dart';
import '../internals/type_defs.dart';

import 'camera_picker.dart';

class CameraPickerViewer extends StatefulWidget {
  const CameraPickerViewer({
    Key? key,
    required this.pickerState,
    required this.pickerType,
    required this.previewXFile,
    required this.theme,
    this.shouldDeletePreviewFile = false,
    this.shouldAutoPreviewVideo = false,
    this.onEntitySaving,
    this.onError,
  }) : super(key: key);

  /// State of the picker.
  /// 选择器的状态实例
  final CameraPickerState pickerState;

  /// The type of the viewer. (Image | Video)
  /// 预览的类型（图片或视频）
  final CameraPickerViewType pickerType;

  /// The [XFile] of the preview file.
  /// 预览文件的 [XFile] 实例
  final XFile previewXFile;

  /// The [ThemeData] which the picker is using.
  /// 选择器使用的主题
  final ThemeData theme;

  /// {@macro wechat_camera_picker.shouldDeletePreviewFile}
  final bool shouldDeletePreviewFile;

  /// {@macro wechat_camera_picker.shouldAutoPreviewVideo}
  final bool shouldAutoPreviewVideo;

  /// {@macro wechat_camera_picker.EntitySaveCallback}
  final EntitySaveCallback? onEntitySaving;

  /// {@macro wechat_camera_picker.CameraErrorHandler}
  final CameraErrorHandler? onError;

  /// Static method to push with the navigator.
  /// 跳转至选择预览的静态方法
  static Future<AssetEntity?> pushToViewer(
    BuildContext context, {
    required CameraPickerState pickerState,
    required CameraPickerViewType pickerType,
    required XFile previewXFile,
    required ThemeData theme,
    bool shouldDeletePreviewFile = false,
    bool shouldAutoPreviewVideo = false,
    EntitySaveCallback? onEntitySaving,
    CameraErrorHandler? onError,
  }) {
    return Navigator.of(context).push<AssetEntity?>(
      PageRouteBuilder<AssetEntity?>(
        pageBuilder: (_, __, ___) => CameraPickerViewer(
          pickerState: pickerState,
          pickerType: pickerType,
          previewXFile: previewXFile,
          theme: theme,
          shouldDeletePreviewFile: shouldDeletePreviewFile,
          shouldAutoPreviewVideo: shouldAutoPreviewVideo,
          onEntitySaving: onEntitySaving,
          onError: onError,
        ),
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  _CameraPickerViewerState createState() => _CameraPickerViewerState();
}

class _CameraPickerViewerState extends State<CameraPickerViewer> {
  /// Controller for the video player.
  /// 视频播放的控制器
  late final VideoPlayerController videoController =
      VideoPlayerController.file(previewFile);

  /// Whether the controller has initialized.
  /// 控制器是否已初始化
  late bool hasLoaded = pickerType == CameraPickerViewType.image;

  /// Whether there's any error when initialize the video controller.
  /// 初始化视频控制器时是否发生错误
  bool hasErrorWhenInitializing = false;

  /// Whether the player is playing.
  /// 播放器是否在播放
  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

  /// Whether the controller is playing.
  /// 播放控制器是否在播放
  bool get isControllerPlaying => videoController.value.isPlaying;

  CameraPickerState get pickerState => widget.pickerState;

  CameraPickerViewType get pickerType => widget.pickerType;

  XFile get previewXFile => widget.previewXFile;

  /// Construct an [File] instance through [previewXFile].
  /// 通过 [previewXFile] 构建 [File] 实例。
  File? _previewFile;
  File get previewFile {
    if(_previewFile == null) return File(previewXFile.path);
    return _previewFile!;
  }
  set previewFile(File file){
    _previewFile = file;
  }
  ThemeData get theme => widget.theme;

  bool get shouldDeletePreviewFile => widget.shouldDeletePreviewFile;

  bool get shouldAutoPreviewVideo => widget.shouldAutoPreviewVideo;

  @override
  void initState() {
    super.initState();
    if (pickerType == CameraPickerViewType.video) {
      initializeVideoPlayerController();
    }
  }

  @override
  void dispose() {
    /// Remove listener from the controller and dispose it when widget dispose.
    /// 部件销毁时移除控制器的监听并销毁控制器。
    videoController.removeListener(videoPlayerListener);
    videoController.pause();
    videoController.dispose();
    super.dispose();
  }

  /// Get media url from the asset, then initialize the controller and add with
  /// a listener.
  /// 从资源获取媒体url后初始化，并添加监听。
  Future<void> initializeVideoPlayerController() async {
    try {
      await videoController.initialize();
      videoController.addListener(videoPlayerListener);
      hasLoaded = true;
      if (shouldAutoPreviewVideo) {
        videoController.play();
      }
    } catch (e) {
      hasErrorWhenInitializing = true;
      realDebugPrint('Error when initializing video controller: $e');
      handleErrorWithHandler(e, widget.onError);
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Listener for the video player.
  /// 播放器的监听方法
  void videoPlayerListener() {
    if (isControllerPlaying != isPlaying.value) {
      isPlaying.value = isControllerPlaying;
    }
  }

  /// Callback for the play button.
  /// 播放按钮的回调
  ///
  /// Normally it only switches play state for the player. If the video reaches
  /// the end, then click the button will make the video replay.
  /// 一般来说按钮只切换播放暂停。当视频播放结束时，点击按钮将从头开始播放。
  Future<void> playButtonCallback() async {
    if (isPlaying.value) {
      videoController.pause();
    } else {
      if (videoController.value.duration == videoController.value.position) {
        videoController
          ..seekTo(Duration.zero)
          ..play();
      } else {
        videoController.play();
      }
    }
  }

  /// When users confirm to use the taken file, create the [AssetEntity].
  /// While the entity might returned null, there's no side effects if popping `null`
  /// because the parent picker will ignore it.
  Future<void> createAssetEntityAndPop(File file) async {
    if (widget.onEntitySaving != null) {
      await widget.onEntitySaving!(
        context: context,
        viewType: pickerType,
        file: file,
      );
      return;
    }
    AssetEntity? entity;
    try {
      final PermissionState _ps = await PhotoManager.requestPermissionExtend();
      if (_ps == PermissionState.authorized || _ps == PermissionState.limited) {
        switch (pickerType) {
          case CameraPickerViewType.image:
            final Uint8List data = await file.readAsBytes();
            entity = await PhotoManager.editor.saveImage(
              data,
              title: path.basename(file.path),
            );
            break;
          case CameraPickerViewType.video:
            entity = await PhotoManager.editor.saveVideo(
              file,
              title: path.basename(file.path),
            );
            break;
        }
        if (shouldDeletePreviewFile && file.existsSync()) {
          file.delete();
        }
        return;
      }
      handleErrorWithHandler(
        StateError(
          'Permission is not fully granted to save the captured file.',
        ),
        widget.onError,
      );
    } catch (e) {
      realDebugPrint('Saving entity failed: $e');
      handleErrorWithHandler(e, widget.onError);
    } finally {
      Navigator.of(context).pop(entity);
    }
  }

  /// The back button for the preview section.
  /// 预览区的返回按钮
  Widget previewBackButton(BuildContext context) {
    return Semantics(
      sortKey: const OrdinalSortKey(0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: IconButton(
          onPressed: () {
            if (previewFile.existsSync()) {
              previewFile.delete();
            }
            Navigator.of(context).pop();
          },
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tight(const Size.square(28)),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          iconSize: 18,
          icon: Container(
            padding: const EdgeInsets.all(5),
            child: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).canvasColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget previewWidget(BuildContext context) {
    final Widget _builder;
    if (pickerType == CameraPickerViewType.video) {
      _builder = Stack(
        children: <Widget>[
          Center(
            child: AspectRatio(
              aspectRatio: videoController.value.aspectRatio,
              child: VideoPlayer(videoController),
            ),
          ),
          playControlButton,
        ],
      );
    } else {
      _builder = Image.file(previewFile);
    }
    return MergeSemantics(
      child: Semantics(
        label: Constants.textDelegate.sActionPreviewHint,
        image: true,
        onTapHint: Constants.textDelegate.sActionPreviewHint,
        sortKey: const OrdinalSortKey(1),
        child: _builder,
      ),
    );
  }

  /// The confirm button for the preview section.
  /// 预览区的确认按钮
  Widget get previewConfirmButton {
    return  MaterialButton(
      minWidth: 20.0,
      height: 44.0,
      padding: const EdgeInsets.symmetric(horizontal: 52.0),
      color: const Color(0xfffa8232),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        Constants.textDelegate.confirm,
        style: TextStyle(
          color: theme.textTheme.bodyText1?.color,
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
        ),
      ),
      onPressed: ()=>createAssetEntityAndPop(previewFile),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// The confirm button for the preview section.
  /// 裁剪按钮
  Widget get cropperButton {
    return MaterialButton(
      minWidth: 20.0,
      height: 44.0,
      padding: const EdgeInsets.symmetric(horizontal: 52.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        Constants.textDelegate.cropper,
        style: const TextStyle(
          color: Color(0xfffa8232),
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
        ),
      ),
      onPressed: ()=>imageCropper(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
  /// A play control button the video playing process.
  /// 控制视频播放的按钮
  Widget get playControlButton {
    return ValueListenableBuilder<bool>(
      valueListenable: isPlaying,
      builder: (_, bool value, Widget? child) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: value ? playButtonCallback : null,
        child: Center(
          child: AnimatedOpacity(
            duration: kThemeAnimationDuration,
            opacity: value ? 0.0 : 1.0,
            child: GestureDetector(
              onTap: playButtonCallback,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  boxShadow: <BoxShadow>[BoxShadow(color: Colors.black12)],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  value ? Icons.pause_circle_outline : Icons.play_circle_filled,
                  size: 70.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Actions section for the viewer. Including 'back' and 'confirm' button.
  /// 预览的操作区。包括"返回"和"确定"按钮。
  Widget viewerActions(BuildContext context) {

    return  Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
      Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top -5),child:
      Semantics(
        sortKey: const OrdinalSortKey(0),
        child: Row(
          children: <Widget>[
            previewBackButton(context),
            const Spacer(),
          ],
        ),
      ),),
        Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom -10),
          child:Semantics(
          sortKey: const OrdinalSortKey(2),
          child: Container(
            padding:const EdgeInsets.only(left: 15,right: 15),
            child: Row(
              children: <Widget>[
                if (pickerType == CameraPickerViewType.image) cropperButton else const SizedBox(),
                const Spacer(),
                previewConfirmButton,
              ],
            ),
          ),
        ),
        ),

      ],
    );
  }
  Future<void> imageCropper() async{

    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: previewFile.path ,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings:const IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
    );

    if(croppedFile != null){
      setState(() {
        previewFile = croppedFile;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (hasErrorWhenInitializing) {
      return Center(
        child: Text(
          Constants.textDelegate.loadFailed,
          style: const TextStyle(inherit: false),
        ),
      );
    }
    if (!hasLoaded) {
      return const SizedBox.shrink();
    }
    return Material(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: previewWidget(context)),
          viewerActions(context),
        ],
      ),
    );
  }
}
