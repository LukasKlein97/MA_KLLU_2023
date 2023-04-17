import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  File? _image;
  File? _imageCode;
  String? address;
  String? date;
  String _recognizedText = "";
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
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
    blocks.forEach((element) async {
      print(element['text']);

      print(element['size']);
      print(element['index']);
    });

    //sum up all height

    print(sum / index);

    setState(() {
      _recognizedText = recognizedText.text;
    });
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

    for (Barcode barcode in barcodes) {
      final BarcodeType type = barcode.type;
      print(barcode.displayValue);
      print(barcode.type);
      print(barcode.value);
      print(barcode.boundingBox);
      print(barcode.cornerPoints);
    }

    barcodeScanner.close();
  }

  void getAddress(String inputText) async {
    final entityExtractor =
        EntityExtractor(language: EntityExtractorLanguage.german);

    final List<EntityAnnotation> annotations =
        await entityExtractor.annotateText(inputText);

    print(annotations);
    try {
      address = annotations
          .firstWhere((element) => element.entities
              .any((entity) => entity.type == EntityType.address))
          .text;
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

  void getDate(String inputText) async {
    final entityExtractor =
        EntityExtractor(language: EntityExtractorLanguage.german);

    final List<EntityAnnotation> annotations =
        await entityExtractor.annotateText(inputText);

    print(annotations);
    try {
      date = annotations
          .firstWhere((element) => element.entities
              .any((entity) => entity.type == EntityType.dateTime))
          .text;
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ML Kit Text Recognition'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (_image != null) Image.file(_image!),
              if (_image != null)
                ClipPath(
                  clipper: ImageClipper(),
                  child: Image.file(
                    _image!,
                    width: 800, // Adjust according to your image's size
                    height: 600, // Adjust according to your image's size
                    fit: BoxFit.cover,
                  ),
                ),
              ElevatedButton(
                onPressed: () => getAddress(_recognizedText),
                child: Text('Adresse'),
              ),
              ElevatedButton(
                onPressed: () => getDate(_recognizedText),
                child: Text('Datum'),
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              ElevatedButton(
                onPressed: _analyzeImage,
                child: Text('Analyze Image'),
              ),
              ElevatedButton(
                onPressed: getCode,
                child: Text('Code Info'),
              ),
              Text('Adresse: $address'),
              Text('DateTime: $date'),
              Container(
                height: 40,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(497.0, 217.0);
    path.lineTo(558.0, 217.0);
    path.lineTo(558.0, 276.0);
    path.lineTo(497.0, 276.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
