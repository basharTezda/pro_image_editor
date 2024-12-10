import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/models/crop_rotate_editor/transform_factors.dart';
import 'package:pro_image_editor/models/editor_configs/main_editor_configs.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../frosted_glass/frosted_glass_loading_dialog.dart';
import '../grounded/grounded_blur_bar.dart';
import '../grounded/grounded_crop_rotate_bar.dart';
import '../grounded/grounded_design.dart';
import '../grounded/grounded_filter_bar.dart';
import '../grounded/grounded_main_bar.dart';
import '../grounded/grounded_painting_bar.dart';
import '../grounded/grounded_text_bar.dart';
import '../grounded/grounded_text_size_slider.dart';
import '../grounded/grounded_tune_bar.dart';

class ProfileImageEditor extends StatefulWidget {
  final String filePath;
  final Function(String?) onEditingComplete;
  final EditorType? editorType;
  const ProfileImageEditor(
      {required this.filePath,
      required this.onEditingComplete,
      this.editorType = EditorType.profileImage,
      super.key});

  @override
  State<ProfileImageEditor> createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ProfileImageEditor> {
  int? height;
  int? width;
  bool allowResizing = true;
  @override
  void initState() {
    precachImg(widget.filePath);
    switch (widget.editorType) {
      case EditorType.banner:
        width = 480;
        height = 270;
        allowResizing = false;
        break;
      case EditorType.profileImage:
        width = 320;
        height = 320;
        allowResizing = false;
        break;
      default:
        break;
    }
    _editorConfigs = ProImageEditorConfigs(
      designMode: platformDesignMode,
      cropRotateEditorConfigs: CropRotateEditorConfigs(
        initAspectRatio: width != null ? (width! / height!) : 1,
        provideImageInfos: !allowResizing,
        canChangeAspectRatio: allowResizing,
      ),
      imageEditorTheme: const ImageEditorTheme(
        background: Color(0xFF000000),
        bottomBarBackgroundColor: Color(0xFF000000),
        textEditor: TextEditorTheme(
          textFieldMargin: EdgeInsets.only(top: kToolbarHeight),
          bottomBarBackgroundColor: Colors.transparent,
          // bottomBarMainAxisAlignment: !_useMaterialDesign
          //     ? MainAxisAlignment.spaceEvenly
          //     : MainAxisAlignment.start
        ),
        paintingEditor: PaintingEditorTheme(
          background: Color(0xFF000000),
          initialStrokeWidth: 5,
        ),
        cropRotateEditor: CropRotateEditorTheme(
            cropCornerColor: Color(0xFFFFFFFF),
            cropCornerLength: 36,
            cropCornerThickness: 4,
            background: Color(0xFF000000),
            helperLineColor: Color(0x25FFFFFF)),
        filterEditor: FilterEditorTheme(
          filterListSpacing: 7,
          filterListMargin: EdgeInsets.fromLTRB(8, 0, 8, 8),
          background: Color(0xFF000000),
        ),
        blurEditor: BlurEditorTheme(
          background: Color(0xFF000000),
        ),
        // emojiEditor: EmojiEditorTheme(
        //   backgroundColor: Colors.transparent,
        //   textStyle: DefaultEmojiTextStyle.copyWith(
        //     fontFamily:
        //         !kIsWeb ? null : GoogleFonts.notoColorEmoji().fontFamily,
        //     fontSize: _useMaterialDesign ? 48 : 30,
        //   ),
        //   emojiViewConfig: EmojiViewConfig(
        //     gridPadding: EdgeInsets.zero,
        //     horizontalSpacing: 0,
        //     verticalSpacing: 0,
        //     recentsLimit: 40,
        //     backgroundColor: Colors.transparent,
        //     buttonMode: !_useMaterialDesign
        //         ? ButtonMode.CUPERTINO
        //         : ButtonMode.MATERIAL,
        //     loadingIndicator:
        //         const Center(child: CircularProgressIndicator()),
        //     columns: _calculateEmojiColumns(constraints),
        //     emojiSizeMax: !_useMaterialDesign ? 32 : 64,
        //     replaceEmojiOnLimitExceed: false,
        //   ),

        //   bottomActionBarConfig:
        //       const BottomActionBarConfig(enabled: false),
        // ),
      ),
      // mainEditorConfigs: MainEditorConfigs(
      //   // transformSetup: MainEditorTransformSetup(
      //   //   transformConfigs: transformations,
      //   //   imageInfos: imageInfos,
      //   // ),
      // ),

      customWidgets: ImageEditorCustomWidgets(
        loadingDialog: (message, configs) => FrostedGlassLoadingDialog(
          message: message,
          configs: configs,
        ),
        // mainEditor: CustomWidgetsMainEditor(
        //   appBar: (editor, rebuildStream) => null,
        //   bottomBar: (editor, rebuildStream, key) => ReactiveCustomWidget(
        //     key: key,
        //     builder: (context) {
        //       return SizedBox(
        //         width: MediaQuery.of(context).size.width,
        //         height: 75,
        //         child: Column(
        //           children: [
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceAround,
        //               children: <Widget>[
        //                 GestureDetector(
        //                   onTap: editor.openPaintingEditor,
        //                   child: Icon(
        //                     Icons.edit_outlined,
        //                     size: iconSize,
        //                     color: Colors.white,
        //                   ),
        //                 ),
        //                 GestureDetector(
        //                   onTap: editor.openTextEditor,
        //                   child: Icon(
        //                     Icons.text_fields_rounded,
        //                     size: iconSize,
        //                     color: Colors.white,
        //                   ),
        //                 ),
        //                 GestureDetector(
        //                   onTap: editor.openTuneEditor,
        //                   child: Icon(
        //                     Icons.tune,
        //                     size: iconSize,
        //                     color: Colors.white,
        //                   ),
        //                 ),
        //                 GestureDetector(
        //                   onTap: editor.openFilterEditor,
        //                   child: Icon(
        //                     Icons.filter,
        //                     size: iconSize,
        //                     color: Colors.white,
        //                   ),
        //                 ),
        //                 GestureDetector(
        //                   onTap: editor.openBlurEditor,
        //                   child: Icon(
        //                     Icons.lens_blur_sharp,
        //                     size: iconSize,
        //                     color: Colors.white,
        //                   ),
        //                 ),
        //                 GestureDetector(
        //                   onTap: editor.openEmojiEditor,
        //                   child: Icon(
        //                     Icons.sentiment_satisfied_alt_rounded,
        //                     size: iconSize,
        //                     color: Colors.white,
        //                   ),
        //                 ),
        //               ],
        //             ),
        //             // GroundedMainBar(
        //             //   doneText: "Upload",
        //             //   key: editorKey,
        //             //   editor: editor,
        //             //   configs: editor.configs,
        //             //   callbacks: editor.callbacks,
        //             // )
        //             GroundedBottomBar(
        //               configs: editor.configs,
        //               undo: editor.undoAction,
        //               redo: editor.redoAction,
        //               done: editor.doneEditing,
        //               close: editor.closeEditor,
        //               enableRedo: editor.canRedo,
        //               enableUndo: editor.canUndo,
        //               doneText: "Upload",
        //             ),
        //           ],
        //         ),
        //       );
        //     },
        //     stream: rebuildStream,
        //   ),
        // ),
        // paintEditor: CustomWidgetsPaintEditor(
        //   appBar: (paintEditor, rebuildStream) => null,
        //   colorPicker: (paintEditor, rebuildStream, currentColor, setColor) =>
        //       null,
        //   bottomBar: (editorState, rebuildStream) {
        //     return ReactiveCustomWidget(
        //       builder: (context) {
        //         return GroundedPaintingBar(
        //             configs: editorState.configs,
        //             callbacks: editorState.callbacks,
        //             editor: editorState,
        //             i18nColor: 'Color',
        //             showColorPicker: (currentColor) {
        //               Color? newColor;
        //               showDialog(
        //                 context: context,
        //                 builder: (context) => AlertDialog(
        //                   content: SingleChildScrollView(
        //                     child: ColorPicker(
        //                       pickerColor: currentColor,
        //                       onColorChanged: (color) {
        //                         newColor = color;
        //                       },
        //                     ),
        //                   ),
        //                   actions: <Widget>[
        //                     ElevatedButton(
        //                       child: const Text('Got it'),
        //                       onPressed: () {
        //                         if (newColor != null) {
        //                           setState(() =>
        //                               editorState.colorChanged(newColor!));
        //                         }
        //                         Navigator.of(context).pop();
        //                       },
        //                     ),
        //                   ],
        //                 ),
        //               );
        //             });
        //       },
        //       stream: rebuildStream,
        //     );
        //   },
        // ),
        // cropRotateEditor: CustomWidgetsCropRotateEditor(
        //   appBar: (cropRotateEditor, rebuildStream) => null,
        //   bottomBar: (cropRotateEditor, rebuildStream) => ReactiveCustomWidget(
        //     stream: rebuildStream,
        //     builder: (_) => GroundedCropRotateBar(
        //       configs: cropRotateEditor.configs,
        //       callbacks: cropRotateEditor.callbacks,
        //       editor: cropRotateEditor,
        //       selectedRatioColor: imageEditorPrimaryColor,
        //     ),
        //   ),
        // ),
        // textEditor: CustomWidgetsTextEditor(
        //   appBar: (textEditor, rebuildStream) => null,
        //   colorPicker: (textEditor, rebuildStream, currentColor, setColor) =>
        //       null,
        //   bottomBar: (editorState, rebuildStream) {
        //     return ReactiveCustomWidget(
        //       builder: (context) {
        //         return GroundedTextBar(
        //             configs: editorState.configs,
        //             callbacks: editorState.callbacks,
        //             editor: editorState,
        //             i18nColor: 'Color',
        //             showColorPicker: (currentColor) {
        //               Color? newColor;
        //               showDialog(
        //                 context: context,
        //                 builder: (context) => AlertDialog(
        //                   content: SingleChildScrollView(
        //                     child: ColorPicker(
        //                       pickerColor: currentColor,
        //                       onColorChanged: (color) {
        //                         newColor = color;
        //                       },
        //                     ),
        //                   ),
        //                   actions: <Widget>[
        //                     ElevatedButton(
        //                       child: const Text('Got it'),
        //                       onPressed: () {
        //                         if (newColor != null) {
        //                           setState(() =>
        //                               editorState.primaryColor = newColor!);
        //                         }
        //                         Navigator.of(context).pop();
        //                       },
        //                     ),
        //                   ],
        //                 ),
        //               );
        //             });
        //       },
        //       stream: rebuildStream,
        //     );
        //   },
        //   bodyItems: (editorState, rebuildStream) => [
        //     ReactiveCustomWidget(
        //       stream: rebuildStream,
        //       builder: (_) => Padding(
        //         padding: const EdgeInsets.only(top: kToolbarHeight),
        //         child: GroundedTextSizeSlider(textEditor: editorState),
        //       ),
        //     ),
        //   ],
        // ),
        // tuneEditor: CustomWidgetsTuneEditor(
        //   appBar: (editor, rebuildStream) => null,
        //   bottomBar: (editorState, rebuildStream) {
        //     return ReactiveCustomWidget(
        //       builder: (context) {
        //         return GroundedTuneBar(
        //           configs: editorState.configs,
        //           callbacks: editorState.callbacks,
        //           editor: editorState,
        //         );
        //       },
        //       stream: rebuildStream,
        //     );
        //   },
        // ),
        // filterEditor: CustomWidgetsFilterEditor(
        //   slider: (editorState, rebuildStream, value, onChanged, onChangeEnd) =>
        //       ReactiveCustomWidget(
        //     stream: rebuildStream,
        //     builder: (_) => Slider(
        //       onChanged: onChanged,
        //       onChangeEnd: onChangeEnd,
        //       value: value,
        //       activeColor: Colors.blue.shade200,
        //     ),
        //   ),
        //   appBar: (editorState, rebuildStream) => null,
        //   bottomBar: (editorState, rebuildStream) {
        //     return ReactiveCustomWidget(
        //       builder: (context) {
        //         return GroundedFilterBar(
        //           configs: editorState.configs,
        //           callbacks: editorState.callbacks,
        //           editor: editorState,
        //         );
        //       },
        //       stream: rebuildStream,
        //     );
        //   },
        // ),
        // blurEditor: CustomWidgetsBlurEditor(
        //   appBar: (blurEditor, rebuildStream) => null,
        //   bottomBar: (editorState, rebuildStream) {
        //     return ReactiveCustomWidget(
        //       builder: (context) {
        //         return GroundedBlurBar(
        //           configs: editorState.configs,
        //           callbacks: editorState.callbacks,
        //           editor: editorState,
        //         );
        //       },
        //       stream: rebuildStream,
        //     );
        //   },
        // ),
      ),
    );
    super.initState();
  }

  late ProImageEditorConfigs _editorConfigs;
  void _openCropEditor() async {
    await Future.delayed(Duration.zero, () async {
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, secondaryAnimation) => Scaffold(
            backgroundColor: Colors.black,
            body: CropRotateEditor.file(
              File(newPath!),
              initConfigs: CropRotateEditorInitConfigs(
                callbacks: ProImageEditorCallbacks(
                  onCloseEditor: () {},
                ),
                // mainImageSize: Size(width!.toDouble(), height!.toDouble()),
                theme: ThemeData.dark(),
                configs: _editorConfigs,
                onDone: (transformations, fitToScreenFactor, imageInfos) {
                  done = true;
                  cropped = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _openMainEditor(transformations, imageInfos!);
                  });
                },
              ),
            ),
          ),
        ),
      );
    });
    if (!done) {
      Navigator.of(context).pop();
      return;
    }
    contexto = context;
    // setState(() {});
    //
  }

  double iconSize = 18;
  bool done = false;
  bool cropped = false;
  BuildContext? contexto;
  final editorKey = GlobalKey<ProImageEditorState>();
  void _openMainEditor(
    TransformConfigs transformations,
    ImageInfos imageInfos,
  ) async {
    done = false;
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => Scaffold(
          backgroundColor: Colors.black,
          body: ProImageEditor.file(
            File(newPath!),
            configs: _editorConfigs.copyWith(
              imageEditorTheme: const ImageEditorTheme(
                background: Color(0xFF000000),
                bottomBarBackgroundColor: Color(0xFF000000),
                textEditor: TextEditorTheme(
                  textFieldMargin: EdgeInsets.only(top: kToolbarHeight),
                  bottomBarBackgroundColor: Colors.transparent,
                  // bottomBarMainAxisAlignment: !_useMaterialDesign
                  //     ? MainAxisAlignment.spaceEvenly
                  //     : MainAxisAlignment.start
                ),
                paintingEditor: PaintingEditorTheme(
                  background: Color(0xFF000000),
                  initialStrokeWidth: 5,
                ),
                cropRotateEditor: CropRotateEditorTheme(
                    cropCornerColor: Color(0xFFFFFFFF),
                    cropCornerLength: 36,
                    cropCornerThickness: 4,
                    background: Color(0xFF000000),
                    helperLineColor: Color(0x25FFFFFF)),
                filterEditor: FilterEditorTheme(
                  filterListSpacing: 7,
                  filterListMargin: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  background: Color(0xFF000000),
                ),
                blurEditor: BlurEditorTheme(
                  background: Color(0xFF000000),
                ),
                // emojiEditor: EmojiEditorTheme(
                //   backgroundColor: Colors.transparent,
                //   textStyle: DefaultEmojiTextStyle.copyWith(
                //     fontFamily:
                //         !kIsWeb ? null : GoogleFonts.notoColorEmoji().fontFamily,
                //     fontSize: _useMaterialDesign ? 48 : 30,
                //   ),
                //   emojiViewConfig: EmojiViewConfig(
                //     gridPadding: EdgeInsets.zero,
                //     horizontalSpacing: 0,
                //     verticalSpacing: 0,
                //     recentsLimit: 40,
                //     backgroundColor: Colors.transparent,
                //     buttonMode: !_useMaterialDesign
                //         ? ButtonMode.CUPERTINO
                //         : ButtonMode.MATERIAL,
                //     loadingIndicator:
                //         const Center(child: CircularProgressIndicator()),
                //     columns: _calculateEmojiColumns(constraints),
                //     emojiSizeMax: !_useMaterialDesign ? 32 : 64,
                //     replaceEmojiOnLimitExceed: false,
                //   ),

                //   bottomActionBarConfig:
                //       const BottomActionBarConfig(enabled: false),
                // ),
              ),
              mainEditorConfigs: MainEditorConfigs(
                transformSetup: MainEditorTransformSetup(
                  transformConfigs: transformations,
                  imageInfos: imageInfos,
                ),
              ),
              cropRotateEditorConfigs: const CropRotateEditorConfigs(
                enabled: false,
              ),
              customWidgets: ImageEditorCustomWidgets(
                loadingDialog: (message, configs) => FrostedGlassLoadingDialog(
                  message: message,
                  configs: configs,
                ),
                mainEditor: CustomWidgetsMainEditor(
                  appBar: (editor, rebuildStream) => ReactiveCustomAppbar(
                    builder: (context) {
                      return AppBar(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.black,
                        leading: IconButton(
                            onPressed: editor.closeEditor,
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            )),
                        actions: [
                          IconButton(
                              onPressed: editor.doneEditing,
                              icon: const Text(
                                "Save",
                                style: TextStyle(fontWeight: FontWeight.w900),
                              )),
                        ],
                      );
                    },
                    stream: rebuildStream,
                  ),
                  bottomBar: (editor, rebuildStream, key) =>
                      ReactiveCustomWidget(
                    key: key,
                    builder: (context) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 75,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: editor.openPaintingEditor,
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: iconSize,
                                    color: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: editor.openTextEditor,
                                  child: Icon(
                                    Icons.text_fields_rounded,
                                    size: iconSize,
                                    color: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: editor.openTuneEditor,
                                  child: Icon(
                                    Icons.tune,
                                    size: iconSize,
                                    color: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: editor.openFilterEditor,
                                  child: Icon(
                                    Icons.filter,
                                    size: iconSize,
                                    color: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: editor.openBlurEditor,
                                  child: Icon(
                                    Icons.lens_blur_sharp,
                                    size: iconSize,
                                    color: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: editor.openEmojiEditor,
                                  child: Icon(
                                    Icons.sentiment_satisfied_alt_rounded,
                                    size: iconSize,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            // GroundedMainBar(
                            //   doneText: "Upload",
                            //   key: editorKey,
                            //   editor: editor,
                            //   configs: editor.configs,
                            //   callbacks: editor.callbacks,
                            // )
                            GroundedBottomBar(
                              configs: editor.configs,
                              undo: editor.undoAction,
                              redo: editor.redoAction,
                              done: editor.doneEditing,
                              close: editor.closeEditor,
                              enableRedo: editor.canRedo,
                              enableUndo: editor.canUndo,
                              doneText: "Upload",
                            ),
                          ],
                        ),
                      );
                    },
                    stream: rebuildStream,
                  ),
                ),
                // paintEditor: CustomWidgetsPaintEditor(
                //   // appBar: (paintEditor, rebuildStream) => null,
                //   colorPicker:
                //       (paintEditor, rebuildStream, currentColor, setColor) =>
                //           null,
                //   bottomBar: (editorState, rebuildStream) {
                //     return ReactiveCustomWidget(
                //       builder: (context) {
                //         return GroundedPaintingBar(
                //             configs: editorState.configs,
                //             callbacks: editorState.callbacks,
                //             editor: editorState,
                //             i18nColor: 'Color',
                //             showColorPicker: (currentColor) {
                //               Color? newColor;
                //               showDialog(
                //                 context: context,
                //                 builder: (context) => AlertDialog(
                //                   content: SingleChildScrollView(
                //                     child: ColorPicker(
                //                       pickerColor: currentColor,
                //                       onColorChanged: (color) {
                //                         newColor = color;
                //                       },
                //                     ),
                //                   ),
                //                   actions: <Widget>[
                //                     ElevatedButton(
                //                       child: const Text('Got it'),
                //                       onPressed: () {
                //                         if (newColor != null) {
                //                           setState(() => editorState
                //                               .colorChanged(newColor!));
                //                         }
                //                         Navigator.of(context).pop();
                //                       },
                //                     ),
                //                   ],
                //                 ),
                //               );
                //             });
                //       },
                //       stream: rebuildStream,
                //     );
                //   },
                // ),
                // textEditor: CustomWidgetsTextEditor(
                //   appBar: (textEditor, rebuildStream) => null,
                //   colorPicker:
                //       (textEditor, rebuildStream, currentColor, setColor) =>
                //           null,
                //   bottomBar: (editorState, rebuildStream) {
                //     return ReactiveCustomWidget(
                //       builder: (context) {
                //         return GroundedTextBar(
                //             configs: editorState.configs,
                //             callbacks: editorState.callbacks,
                //             editor: editorState,
                //             i18nColor: 'Color',
                //             showColorPicker: (currentColor) {
                //               Color? newColor;
                //               showDialog(
                //                 context: context,
                //                 builder: (context) => AlertDialog(
                //                   content: SingleChildScrollView(
                //                     child: ColorPicker(
                //                       pickerColor: currentColor,
                //                       onColorChanged: (color) {
                //                         newColor = color;
                //                       },
                //                     ),
                //                   ),
                //                   actions: <Widget>[
                //                     ElevatedButton(
                //                       child: const Text('Got it'),
                //                       onPressed: () {
                //                         if (newColor != null) {
                //                           setState(() => editorState
                //                               .primaryColor = newColor!);
                //                         }
                //                         Navigator.of(context).pop();
                //                       },
                //                     ),
                //                   ],
                //                 ),
                //               );
                //             });
                //       },
                //       stream: rebuildStream,
                //     );
                //   },
                //   bodyItems: (editorState, rebuildStream) => [
                //     ReactiveCustomWidget(
                //       stream: rebuildStream,
                //       builder: (_) => Padding(
                //         padding: const EdgeInsets.only(top: kToolbarHeight),
                //         child: GroundedTextSizeSlider(textEditor: editorState),
                //       ),
                //     ),
                //   ],
                // ),
                // tuneEditor: CustomWidgetsTuneEditor(
                //   appBar: (editor, rebuildStream) => null,
                //   bottomBar: (editorState, rebuildStream) {
                //     return ReactiveCustomWidget(
                //       builder: (context) {
                //         return GroundedTuneBar(
                //           configs: editorState.configs,
                //           callbacks: editorState.callbacks,
                //           editor: editorState,
                //         );
                //       },
                //       stream: rebuildStream,
                //     );
                //   },
                // ),
                // filterEditor: CustomWidgetsFilterEditor(
                //   slider: (editorState, rebuildStream, value, onChanged,
                //           onChangeEnd) =>
                //       ReactiveCustomWidget(
                //     stream: rebuildStream,
                //     builder: (_) => Slider(
                //       onChanged: onChanged,
                //       onChangeEnd: onChangeEnd,
                //       value: value,
                //       activeColor: Colors.blue.shade200,
                //     ),
                //   ),
                //   appBar: (editorState, rebuildStream) => null,
                //   bottomBar: (editorState, rebuildStream) {
                //     return ReactiveCustomWidget(
                //       builder: (context) {
                //         return GroundedFilterBar(
                //           configs: editorState.configs,
                //           callbacks: editorState.callbacks,
                //           editor: editorState,
                //         );
                //       },
                //       stream: rebuildStream,
                //     );
                //   },
                // ),
                // blurEditor: CustomWidgetsBlurEditor(
                //   appBar: (blurEditor, rebuildStream) => null,
                //   bottomBar: (editorState, rebuildStream) {
                //     return ReactiveCustomWidget(
                //       builder: (context) {
                //         return GroundedBlurBar(
                //           configs: editorState.configs,
                //           callbacks: editorState.callbacks,
                //           editor: editorState,
                //         );
                //       },
                //       stream: rebuildStream,
                //     );
                //   },
                // ),
              ),
            ),
            callbacks: ProImageEditorCallbacks(
                // onCloseEditor: () => Navigator.of(context).pop(),
                onImageEditingComplete: (Uint8List bytes) async {
              done = true;
              _onEditingDone(bytes);
            }),
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (animation.status != AnimationStatus.forward) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          }

          return child;
        },
      ),
    );
    if (!done) {
      Navigator.of(context).pop();
      return;
    }
  }

  String? newPath;
  precachImg(String path) async {
    var result = await FlutterImageCompress.compressWithList(
      File(path).readAsBytesSync(),
      minHeight: 1920,
      minWidth: 1080,
      quality: Platform.isIOS ? 1 : 20,
    );
    final directory = await getApplicationDocumentsDirectory();
    var file = File('${directory.path}/image_${DateTime.now()}.webp');

    file.writeAsBytesSync(result);
    newPath = file.path;
    setState(() {});
  }

  void _onEditingDone(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    var file = File('${directory.path}/image_${DateTime.now()}.webp');
    // var result = await FlutterImageCompress.compressWithList(
    //   bytes,
    //   minHeight: 1920,
    //   minWidth: 1080,
    //   quality: Platform.isIOS ? 1 : 50,
    // );
    file.writeAsBytesSync(bytes);

    // widget.editorType == EditorType.image
    //     ?
    Navigator.pop(context);
    Navigator.pop(contexto!);
    widget.onEditingComplete.call(file.path);
    // : null;
    //
  }

  @override
  Widget build(BuildContext context) {
    if (newPath != null &&
        widget.editorType != EditorType.image &&
        done == false &&
        cropped == false) {
      _openCropEditor();
    }
    return Scaffold(
      body: Container(
          color: Colors.black,
          child: newPath == null
              ? const Center(
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 0.9,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Compressing...',
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ))
              : null),
    );
  }
}

enum EditorType {
  banner,
  profileImage,
  image,
}
