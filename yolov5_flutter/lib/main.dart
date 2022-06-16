import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yolov5_flutter/detect_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:juxtapose/juxtapose.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:loader_overlay/loader_overlay.dart';
import 'package:photo_view/photo_view.dart';

final List<String> imgList = [
  'https://github.com/dnth/flutter_microalgae/blob/main/sample_images/IMG_20191212_151351.jpg?raw=true',
  'https://github.com/dnth/flutter_microalgae/blob/main/sample_images/IMG_20191212_151438.jpg?raw=true',
  'https://github.com/dnth/flutter_microalgae/blob/main/sample_images/IMG_20191212_151559.jpg?raw=true',
  'https://github.com/dnth/flutter_microalgae/blob/main/sample_images/IMG_20191212_151844.jpg?raw=true',
  'https://github.com/dnth/flutter_microalgae/blob/main/sample_images/IMG_20191212_153614.jpg?raw=true',
];

// Reading bytes from a network image
Future<Uint8List> readNetworkImage(String imageUrl) async {
  final ByteData data =
      await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
  final Uint8List bytes = data.buffer.asUint8List();
  return bytes;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MicroSense',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MicroSense'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  Uint8List? imgBytesInput;
  Uint8List? imgBytesInference;
  bool isClassifying = false;
  String _microalgaeCount = "";

  Future<File> cropImage(XFile pickedFile) async {
    // Crop image here
    final File? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      cropStyle: CropStyle.rectangle,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        // CropAspectRatioPreset.ratio3x2,
        // CropAspectRatioPreset.original,
        // CropAspectRatioPreset.ratio4x3,
        // CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: const IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    );

    return croppedFile!;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> imageSliders = imgList
        .map((item) => Container(
              child: Container(
                margin: const EdgeInsets.all(5.0),
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        GestureDetector(
                            onTap: () async {
                              context.loaderOverlay.show();

                              String imgUrl = imgList[imgList.indexOf(item)];

                              if (kIsWeb) {
                                // readNetworkImageWeb(imgUrl);
                                // final bytes = await readNetworkImageWeb(imgUrl);
                                // setState(() {
                                //   imgBytes = bytes;
                                //   _microalgaeCount = 0;
                                // });
                              } else {
                                final bytes = await readNetworkImage(imgUrl);
                                setState(() {
                                  imgBytesInput = bytes;
                                  imgBytesInference = imgBytesInput;
                                  _microalgaeCount = "";
                                });
                              }
                              context.loaderOverlay.hide();

                              print("Tapped on image ${imgList.indexOf(item)}");
                            },
                            child: CachedNetworkImage(
                              imageUrl: item,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            )),
                        // child: Image.network(item, fit: BoxFit.cover)),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Text(
                              'Sample ${imgList.indexOf(item)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ))
        .toList();

    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.menu),
          title: Text(widget.title),
          // actions: [
          //   IconButton(
          //       onPressed: () async {
          //         try {
          //           await writeToFile(imgBytesInference!); // <= returns File
          //         } catch (e) {
          //           // catch errors here
          //           print(e);
          //         }
          //       },
          //       icon: const Icon(Icons.download))
          // ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  !kIsWeb ? const Text("Sample Images") : Container(),
                  !kIsWeb
                      ? CarouselSlider(
                          options: CarouselOptions(
                            // height: 400,
                            autoPlay: true,
                            aspectRatio: 2.5,
                            viewportFraction: 0.45,
                            enlargeCenterPage: true,
                            enlargeStrategy: CenterPageEnlargeStrategy.height,
                          ),
                          items: imageSliders,
                        )
                      : Container(),
                  const SizedBox(
                    height: 10,
                  ),
                  imgBytesInput == null
                      ? Container()
                      : const Text("Sample Prediction"),
                  imgBytesInput == null
                      ? const Text(
                          'Select a sample image above or upload your own image by pressing the shutter icon',
                          textAlign: TextAlign.center,
                        )
                      : SizedBox(
                          height: 300,
                          child: PhotoView.customChild(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Juxtapose(
                                showArrows: true,
                                foregroundWidget: Image.memory(imgBytesInput!),
                                backgroundWidget: Image.memory(
                                    imgBytesInference ?? imgBytesInput!),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  imgBytesInput == null
                      ? Container()
                      : Text("Microalgae Count: $_microalgaeCount",
                          style: Theme.of(context).textTheme.headline6),
                  const SizedBox(height: 20),
                  RoundedLoadingButton(
                    color: Theme.of(context).primaryColor,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: const Text('Count!',
                        style: TextStyle(color: Colors.white)),
                    controller: _btnController,
                    onPressed: isClassifying || (imgBytesInput == null)
                        ? null // null value disables the button
                        : () async {
                            setState(() {
                              isClassifying = true;
                            });

                            String base64Image = "data:image/png;base64," +
                                base64Encode(imgBytesInput!);

                            final result = await detectImage(base64Image);

                            _btnController.reset();

                            setState(() {
                              _microalgaeCount = result['count'].toString();

                              imgBytesInference = base64Decode(result['image']);

                              isClassifying = false;
                            });
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.lightBlueAccent,
          onPressed: () async {
            if (kIsWeb) {
              // running on the web!
              print("Operating on web");

              final pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.gallery);

              final img = await pickedFile!.readAsBytes();

              setState(() {
                // imageURIWeb = pickedFile!.path;
                imgBytesInput = img;
              });
            } else {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                      height: 120,
                      child: ListView(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera),
                            title: const Text("Camera"),
                            onTap: () async {
                              final XFile? pickedFile = await ImagePicker()
                                  .pickImage(source: ImageSource.camera);

                              if (pickedFile != null) {
                                // Clear result of previous inference as soon as new image is selected
                                setState(() {
                                  _microalgaeCount = "";
                                });

                                File croppedFile = await cropImage(pickedFile);
                                final imgFile = File(croppedFile.path);

                                setState(() {
                                  imgBytesInput = imgFile.readAsBytesSync();
                                  imgBytesInference = imgBytesInput;
                                });
                                Navigator.pop(context);
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.image),
                            title: const Text("Gallery"),
                            onTap: () async {
                              final XFile? pickedFile = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);

                              if (pickedFile != null) {
                                // Clear result of previous inference as soon as new image is selected
                                setState(() {
                                  _microalgaeCount = "";
                                });

                                File croppedFile = await cropImage(pickedFile);
                                final imgFile = File(croppedFile.path);

                                setState(() {
                                  imgBytesInput = imgFile.readAsBytesSync();
                                  imgBytesInference = imgBytesInput;
                                });
                                Navigator.pop(context);
                              }
                            },
                          )
                        ],
                      ));
                },
              );
            }
          },
          child: const Icon(Icons.camera),
        ),
      ),
    );
  }
}
