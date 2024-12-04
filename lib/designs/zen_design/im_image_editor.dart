import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../frosted_glass/frosted_glass_loading_dialog.dart';
import '../grounded/grounded_blur_bar.dart';
import '../grounded/grounded_crop_rotate_bar.dart';
import '../grounded/grounded_filter_bar.dart';
import '../grounded/grounded_painting_bar.dart';
import '../grounded/grounded_text_bar.dart';
import '../grounded/grounded_text_size_slider.dart';
import '../grounded/grounded_tune_bar.dart';

class ImImageEditor extends StatefulWidget {
  const ImImageEditor(
      {super.key,
      required this.images,
      required this.onDone,
      required this.doneText,required this.textEditingController});

  final List<String> images;
  final Function(List<String>) onDone;
  final String? doneText;
    final TextEditingController textEditingController;
  @override
  State<ImImageEditor> createState() => _WhatsAppExampleState();
}

class _WhatsAppExampleState extends State<ImImageEditor> {
  late ScrollController _bottomBarScrollCtrl;
  late ScrollController _paintingBottomBarScrollCtrl;
  late ScrollController _cropBottomBarScrollCtrl;

  final List<TextStyle> _customTextStyles = [
    GoogleFonts.roboto(),
    GoogleFonts.averiaLibre(),
    GoogleFonts.lato(),
    GoogleFonts.comicNeue(),
    GoogleFonts.actor(),
    GoogleFonts.odorMeanChey(),
    GoogleFonts.nabla(),
  ];

  final _bottomTextStyle = const TextStyle(fontSize: 10.0, color: Colors.white);
  final List<PaintModeBottomBarItem> paintModes = [
    const PaintModeBottomBarItem(
      mode: PaintModeE.freeStyle,
      icon: Icons.edit,
      label: 'Freestyle',
    ),
    const PaintModeBottomBarItem(
      mode: PaintModeE.arrow,
      icon: Icons.arrow_right_alt_outlined,
      label: 'Arrow',
    ),
    const PaintModeBottomBarItem(
      mode: PaintModeE.line,
      icon: Icons.horizontal_rule,
      label: 'Line',
    ),
    const PaintModeBottomBarItem(
      mode: PaintModeE.rect,
      icon: Icons.crop_free,
      label: 'Rectangle',
    ),
    const PaintModeBottomBarItem(
      mode: PaintModeE.circle,
      icon: Icons.lens_outlined,
      label: 'Circle',
    ),
    const PaintModeBottomBarItem(
      mode: PaintModeE.dashLine,
      icon: Icons.power_input,
      label: 'Dash line',
    ),
  ];

  final _layerInteractionButtonRadius = 10.0;
  List<ImageItem> editors = [];
  List<String> localImeges = [];
  @override
  void initState() {
    localImeges = widget.images;

    _bottomBarScrollCtrl = ScrollController();
    _paintingBottomBarScrollCtrl = ScrollController();
    _cropBottomBarScrollCtrl = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _bottomBarScrollCtrl.dispose();
    _paintingBottomBarScrollCtrl.dispose();
    _cropBottomBarScrollCtrl.dispose();
    super.dispose();
  }

  Map<int, String> paths = {};
  int choice = 0;

  BoxConstraints? constraint;
  @override
  Widget build(BuildContext context) {
    editors.clear();
    for (int i = 0; i < localImeges.length; i++) {
      if (paths[i] == null) {
        _preCache(i);
      }
      var key = GlobalKey<ProImageEditorState>();
      ImageItem item = ImageItem(
          paths[i] ?? localImeges[i],
          i,
          Visibility(
            visible: choice == i,
            child: LayoutBuilder(builder: (context, constraints) {
              return edittor(paths[i] ?? localImeges[i], constraints, i, key);
            }),
          ),
          key);
      editors.add(item);
    }

    return Stack(
      children: [
        for (ImageItem i in editors) i.editor,
        Positioned(
            top: 50,
            child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                )))
      ],
    );
  }

  ProImageEditor edittor(String path, BoxConstraints constraints, int index,
      GlobalKey<ProImageEditorState> key) {
    return ProImageEditor.file(
      File(path),
      key: key,
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (byt) => _onEditingDone(byt),
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
        customWidgets: ImageEditorCustomWidgets(
          loadingDialog: (message, configs) => FrostedGlassLoadingDialog(
            message: message,
            configs: configs,
          ),
          mainEditor: CustomWidgetsMainEditor(
            appBar: (editor, rebuildStream) => null,
            bottomBar: (editor, rebuildStream, key) => ReactiveCustomWidget(
              key: key,
              builder: (context) {
                return _bottomNavigationBar(editor, key, constraints, index);
              },
              stream: rebuildStream,
            ),
          ),
          paintEditor: CustomWidgetsPaintEditor(
            appBar: (paintEditor, rebuildStream) => null,
            colorPicker: (paintEditor, rebuildStream, currentColor, setColor) =>
                null,
            bottomBar: (editorState, rebuildStream) {
              return ReactiveCustomWidget(
                builder: (context) {
                  return GroundedPaintingBar(
                      configs: editorState.configs,
                      callbacks: editorState.callbacks,
                      editor: editorState,
                      i18nColor: 'Color',
                      showColorPicker: (currentColor) {
                        Color? newColor;
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: currentColor,
                                onColorChanged: (color) {
                                  newColor = color;
                                },
                              ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('Got it'),
                                onPressed: () {
                                  if (newColor != null) {
                                    setState(() =>
                                        editorState.colorChanged(newColor!));
                                  }
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      });
                },
                stream: rebuildStream,
              );
            },
          ),
          textEditor: CustomWidgetsTextEditor(
            appBar: (textEditor, rebuildStream) => null,
            colorPicker: (textEditor, rebuildStream, currentColor, setColor) =>
                null,
            bottomBar: (editorState, rebuildStream) {
              return ReactiveCustomWidget(
                builder: (context) {
                  return GroundedTextBar(
                      configs: editorState.configs,
                      callbacks: editorState.callbacks,
                      editor: editorState,
                      i18nColor: 'Color',
                      showColorPicker: (currentColor) {
                        Color? newColor;
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: currentColor,
                                onColorChanged: (color) {
                                  newColor = color;
                                },
                              ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('Got it'),
                                onPressed: () {
                                  if (newColor != null) {
                                    setState(() =>
                                        editorState.primaryColor = newColor!);
                                  }
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      });
                },
                stream: rebuildStream,
              );
            },
            bodyItems: (editorState, rebuildStream) => [
              ReactiveCustomWidget(
                stream: rebuildStream,
                builder: (_) => Padding(
                  padding: const EdgeInsets.only(top: kToolbarHeight),
                  child: GroundedTextSizeSlider(textEditor: editorState),
                ),
              ),
            ],
          ),
          cropRotateEditor: CustomWidgetsCropRotateEditor(
            appBar: (cropRotateEditor, rebuildStream) => null,
            bottomBar: (cropRotateEditor, rebuildStream) =>
                ReactiveCustomWidget(
              stream: rebuildStream,
              builder: (_) => GroundedCropRotateBar(
                configs: cropRotateEditor.configs,
                callbacks: cropRotateEditor.callbacks,
                editor: cropRotateEditor,
                selectedRatioColor: imageEditorPrimaryColor,
              ),
            ),
          ),
          tuneEditor: CustomWidgetsTuneEditor(
            appBar: (editor, rebuildStream) => null,
            bottomBar: (editorState, rebuildStream) {
              return ReactiveCustomWidget(
                builder: (context) {
                  return GroundedTuneBar(
                    configs: editorState.configs,
                    callbacks: editorState.callbacks,
                    editor: editorState,
                  );
                },
                stream: rebuildStream,
              );
            },
          ),
          filterEditor: CustomWidgetsFilterEditor(
            slider:
                (editorState, rebuildStream, value, onChanged, onChangeEnd) =>
                    ReactiveCustomWidget(
              stream: rebuildStream,
              builder: (_) => Slider(
                onChanged: onChanged,
                onChangeEnd: onChangeEnd,
                value: value,
                activeColor: Colors.blue.shade200,
              ),
            ),
            appBar: (editorState, rebuildStream) => null,
            bottomBar: (editorState, rebuildStream) {
              return ReactiveCustomWidget(
                builder: (context) {
                  return GroundedFilterBar(
                    configs: editorState.configs,
                    callbacks: editorState.callbacks,
                    editor: editorState,
                  );
                },
                stream: rebuildStream,
              );
            },
          ),
          blurEditor: CustomWidgetsBlurEditor(
            appBar: (blurEditor, rebuildStream) => null,
            bottomBar: (editorState, rebuildStream) {
              return ReactiveCustomWidget(
                builder: (context) {
                  return GroundedBlurBar(
                    configs: editorState.configs,
                    callbacks: editorState.callbacks,
                    editor: editorState,
                  );
                },
                stream: rebuildStream,
              );
            },
          ),
        ),
      ),
    );
  }

  Color color = Colors.red;
  double iconSize = 15;
  Widget _bottomNavigationBar(ProImageEditorState editor, Key key,
      BoxConstraints constraints, int index) {
    return Scrollbar(
      key: key,
      controller: _bottomBarScrollCtrl,
      scrollbarOrientation: ScrollbarOrientation.top,
      thickness: isDesktop ? null : 0,
      child: BottomAppBar(
        notchMargin: 1,
        height:
            kBottomNavigationBarHeight + (localImeges.length > 1 ? 100 : 50),
        color: Colors.black,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (localImeges.length > 1)
              SingleChildScrollView(
                controller: _bottomBarScrollCtrl,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: min(constraints.maxWidth, 500),
                    maxWidth: 500,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (var i in editors)
                        GestureDetector(
                          onTap: () async {
                            await _preCache(i.index);
                            setState(() {
                              choice = i.index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                        color: i.index == choice
                                            ? Colors.white
                                            : null,
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: SizedBox.fromSize(
                                        size: const Size.fromRadius(32),
                                        child: Image(
                                            fit: BoxFit.cover,
                                            image: FileImage(File(i.path))),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                          onTap: () {},
                                          child: const Icon(
                                            Icons.cancel,
                                            color: Colors.white,
                                            size: 10,
                                          )))
                                ],
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            SingleChildScrollView(
              controller: _bottomBarScrollCtrl,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: min(constraints.maxWidth, 500),
                  maxWidth: 500,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Row(
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
                        onTap: editor.openCropRotateEditor,
                        child: Icon(
                          Icons.crop_rotate_rounded,
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
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  const Icon(CupertinoIcons.photo),
                  Expanded(
                    // width: 313,
                    // color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: TextFormField(
                        controller: widget.textEditingController,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: true,
                        minLines: 1,
                        maxLines: 10,
                        cursorHeight: 16.0,
                        cursorWidth: 2.0,
                        style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                        onChanged: (text) {},
                        decoration: InputDecoration(
                          suffixIcon: const Icon(
                            Icons.sentiment_satisfied_alt_rounded,
                            color: Colors.white,
                          ),
                          hintText: 'Send message',
                          hintStyle: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          contentPadding: const EdgeInsets.only(
                            top: 0,
                            bottom: 0,
                            left: 12.0,
                            right: 38.0,
                          ),
                          constraints: const BoxConstraints(),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.1),
                          labelStyle: const TextStyle(color: Colors.black),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.amber,
                            child: IconButton(
                              iconSize: 20,
                              onPressed: () async {
                                List<String> list = [];
                                for (ImageItem i in editors) {
                                  String? path = paths[i.index];

                                  final directory =
                                      await getApplicationDocumentsDirectory();
                                  var file = File(
                                      '${directory.path}/image_${DateTime.now()}.webp');
                                  var img = i.key.currentState != null
                                      ? await i.key.currentState!
                                          .captureEditorImage()
                                      : File(i.path).readAsBytesSync();
                                  var result = await FlutterImageCompress
                                      .compressWithList(
                                    img,
                                    minHeight: 1920,
                                    minWidth: 1080,
                                    quality: Platform.isIOS ? 1 : 50,
                                  );
                                  file.writeAsBytesSync(result);
                                  path = file.path;

                                  list.add(path);
                                }
                                widget.onDone.call(list);
                                Navigator.pop(context);
                                print("object");
                              },
                              icon: const Icon(Icons.send),
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onEditingDone(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();

    var file = File('${directory.path}/image_${DateTime.now()}.webp');
    var result = await FlutterImageCompress.compressWithList(
      bytes,
      minHeight: 1920,
      minWidth: 1080,
      quality: Platform.isIOS ? 1 : 50,
    );
    file.writeAsBytesSync(result);

    widget.onDone.call([]);
    Navigator.pop(context);
  }

  Future<void> _preCache(int i) async {
    final directory = await getApplicationDocumentsDirectory();
    var file = File('${directory.path}/image_${DateTime.now()}.webp');
    Uint8List img;
    if (editors[choice].key.currentState != null) {
      img = await editors[choice].key.currentState!.captureEditorImage();
    } else {
      img = File(editors[choice].path).readAsBytesSync();
    }
    file.writeAsBytesSync(img);
    paths[editors[choice].index] = file.path;
  }
}

class ImageItem {
  ImageItem(
    this.path,
    this.index,
    this.editor,
    this.key,
  );
  final String path;
  final int index;
  final Widget editor;
  final GlobalKey<ProImageEditorState> key;
}
