import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_ml/screens/event_detail.dart';
import 'package:google_ml/services/data.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:pdfx/pdfx.dart';

import 'package:path_provider/path_provider.dart';

class MLScreen extends StatefulWidget {
  final VoidCallback callBack;

  const MLScreen({
    required this.callBack,
  });

  @override
  State<MLScreen> createState() => _MLScreenState();
}

class _MLScreenState extends State<MLScreen> {
  File? _image;
  CroppedFile? _croppedFile;
  Rect? rect;

  String? address;
  String? date;
  String _recognizedText = "";
  String? title;
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose image source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickAndCropImageFromSource(ImageSource.gallery);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text('Local file system'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickAndCropImageFromFileSystem();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndCropImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);
    print(pickedFile);
    if (pickedFile != null) {
      _proceedTicket(pickedFile);
    }
  }

  Future<void> _pickAndCropImageFromFileSystem() async {
    File? _selectedFile;
    PdfDocument? _document;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      _selectedFile = File(result.files.single.path!);
      final bytes = await _selectedFile!.readAsBytes();
      _document = await PdfDocument.openData(bytes);
      final page = await _document.getPage(1);
      final pageImage = await page.render(
        // rendered image width resolution, required
        width: page.width * 2,
        // rendered image height resolution, required
        height: page.height * 2,

        // Rendered image compression format, also can be PNG, WEBP*
        // Optional, default: PdfPageImageFormat.PNG
        // Web not supported
        format: PdfPageImageFormat.jpeg,

        // Image background fill color for JPEG
        // Optional, default '#ffffff'
        // Web not supported
        backgroundColor: '#ffffff',

        // Crop rect in image for render
        // Optional, default null
        // Web not supported
      );
      print(pageImage);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/page_1.jpg');
      final imageBytes = await pageImage!.bytes;
      await file.writeAsBytes(imageBytes);
      print('Rendered image saved to: ${file.path}');
      _proceedTicket(file);
    }
  }

  Future<void> _proceedTicket(pickedFile) async {
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await _analyzeImage();
      address = await getAddress(_recognizedText);
      await getCode();
      date = await getDate(_recognizedText);
      DateTime dateTime;
      print(date);
      try {
        DateFormat format = DateFormat('MM/dd/yyyy hh:mm');
        dateTime = format.parse(date!);
        print(dateTime);
        dateTime = date != null ? DateTime.parse(date!) : DateTime.now();
        print(dateTime);
      } catch (e) {
        dateTime = DateTime.now();
        print(e);
      }

      CroppedFile? croppedFile = await ImageCropper()
          .cropImage(sourcePath: pickedFile.path, uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        rect != null
            ? IOSUiSettings(
                title: 'Ist das der Code?',
                rectX: rect!.left - 5,
                rectY: rect!.top - 5,
                rectWidth: rect!.width + 10,
                rectHeight: rect!.height + 10)
            : IOSUiSettings(
                title: 'Schneide den Code aus',
              ),
        WebUiSettings(
          context: context,
        ),
      ]);
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
        final appDir = await getApplicationDocumentsDirectory();

        final event = Event.create(
            title ?? '', dateTime.toIso8601String(), address ?? 'New Place');
        print(event.id);
        final savedFile =
            await File(croppedFile.path).copy('${appDir.path}/${event.id}.jpg');
        print(savedFile.path);
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EventDetails(
                    event: event,
                    appDir: appDir,
                    newEvent: true,
                  )),
        );
        widget.callBack();
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) {
      return;
    }

    final inputImage = InputImage.fromFile(_image!);
    final RecognizedText recognizedText =
        await _textRecognizer.processImage(inputImage);

    var blocks = [];
    var index = 0;
    var sum = 0.0;
    print(recognizedText.text);
    title = recognizedText.blocks.first.text;
    recognizedText.blocks.forEach((element) {
      blocks.add({
        'text': element.text,
        'size': element.boundingBox.height,
        'index': index
      });
      sum += element.boundingBox.height;
      index++;
    });

    //blocks order by size
    blocks.sort((a, b) => b['size'].compareTo(a['size']));

    //sum up all height

    print(sum / index);

    _recognizedText = recognizedText.text;
  }

  Future<void> getCode() async {
    if (_image == null) {
      return;
    }

    final inputImage = InputImage.fromFile(_image!);
    final ImageLabelerOptions options =
        ImageLabelerOptions(confidenceThreshold: 0.5);
    final imageLabeler = ImageLabeler(options: options);

    final List<BarcodeFormat> formats = [BarcodeFormat.all].toList();
    final barcodeScanner = BarcodeScanner(formats: formats);
    final List<Barcode> barcodes =
        await barcodeScanner.processImage(inputImage);
    print(barcodes.length);

    if (barcodes.isNotEmpty) rect = (barcodes[0].boundingBox);

    print(rect);
    barcodeScanner.close();
  }

  Future<String?> getAddress(String inputText) async {
    final entityExtractor =
        EntityExtractor(language: EntityExtractorLanguage.german);

    final List<EntityAnnotation> annotations =
        await entityExtractor.annotateText(inputText);

    try {
      address = annotations
          .firstWhere((element) => element.entities
              .any((entity) => entity.type == EntityType.address))
          .text;
      return address;
    } catch (e) {
      print('koi Adresse');
    }

    annotations.forEach((annotation) {
      annotation.entities.forEach((entity) {
        //print(entity.type);
        print(entity.type == EntityType.address);
      });
    });
    setState(() {
      address;
    });

    entityExtractor.close();
  }

  Future<String?> getDate(String inputText) async {
    final entityExtractor =
        EntityExtractor(language: EntityExtractorLanguage.german);

    final List<EntityAnnotation> annotations =
        await entityExtractor.annotateText(inputText);

    try {
      date = annotations
          .firstWhere((element) => element.entities
              .any((entity) => entity.type == EntityType.dateTime))
          .text;
      return date;
    } catch (e) {
      print('koi Datum');
    }

    setState(() {
      date;
    });

    entityExtractor.close();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _pickImage,
      tooltip: 'Add Event',
      child: Icon(Icons.add),
    );
  }
}
