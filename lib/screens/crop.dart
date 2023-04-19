import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:pdfx/pdfx.dart';

class PickAndCropImage extends StatefulWidget {
  @override
  _PickAndCropImageState createState() => _PickAndCropImageState();
}

class _PickAndCropImageState extends State<PickAndCropImage> {
  File? _imageFile;
  CroppedFile? _croppedFile;
  File? _selectedFile;
  PdfDocument? _document;
  PdfPageImage? _pageImage;

  Future<void> _pickAndCropImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      _selectedFile = File(result.files.single.path!);
      final bytes = await _selectedFile!.readAsBytes();
      _document = await PdfDocument.openData(bytes);
      final page = await _document!.getPage(1);
      final pageImage = await page.render(
        // rendered image width resolution, required
        width: page.width,
        // rendered image height resolution, required
        height: page.height,

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
      setState(() {
        _pageImage = pageImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickAndCropImage,
              child: Text('Load PDF'),
            ),
            SizedBox(height: 20),
            if (_document != null)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await _pickAndCropImage();
                    },
                    child: Text('Render Page 1'),
                  ),
                  SizedBox(height: 20),
                  if (_pageImage != null)
                    Container(
                      width: _pageImage!.width!.toDouble(),
                      height: _pageImage!.height!.toDouble(),
                      child: Image(
                        image: MemoryImage(_pageImage!.bytes),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
