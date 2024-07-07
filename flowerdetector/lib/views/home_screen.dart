import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker picker = ImagePicker();
  File? _image;
  Interpreter? _interpreter;
  bool _loading = false;
  List<String>? _labels;
  String? _output;

  @override
  void initState() {
    super.initState();
    _loading = true;
    _loadModel();
    _loadLabels();
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  pickerImage() async {
    var image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });
    _classifyImage(_image!);
  }

  pickerGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });
    _classifyImage(_image!);
  }

  Future<void> _loadModel() async {
    try {
      // Carrega o modelo a partir dos assets
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      print('Modelo carregado com sucesso.');
    } catch (e) {
      print('Falha ao carregar o modelo: $e');
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      setState(() {
        _labels = labelsData.split('\n');
      });
    } catch (e) {
      print('Falha ao carregar as labels: $e');
    }
  }

  Future<void> _classifyImage(File imageFile) async {
    if (_interpreter == null) return;

    setState(() {
      _loading = true;
    });

    // // Exemplo de dados de entrada. Ajuste conforme o seu modelo.
    // var input = List.filled(1 * 224 * 224 * 3, 0.0).reshape([1, 224, 224, 3]);
    // // Preencha `input` com os dados reais
    // var output = List.filled(1 * 1001, 0.0).reshape([1, 1001]);
    // // Execute o modelo
    // _interpreter!.run(input, output);
    // // Processar a saída
    // print('Resultado: ${output[0][0]}');

    // Carregar e processar a imagem
    var image = img.decodeImage(imageFile.readAsBytesSync())!;
    image = img.copyResize(image, width: 224, height: 224);

    // Converta a imagem para a forma necessária pelo modelo
    var input = List.filled(1 * 224 * 224 * 3, 0.0).reshape([1, 224, 224, 3]);
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        var pixel = image.getPixel(x, y);
        input[0][y][x][0] = pixel.r / 255.0; // Red
        input[0][y][x][1] = pixel.g / 255.0; // Green
        input[0][y][x][2] = pixel.b / 255.0; // Blue
      }
    }

    //var output = List.filled(1 * 1001, 0.0).reshape([1, 1001]);
    // // Execute o modelo
    // _interpreter!.run(input, output);
    // // Processar a saída
    // print('Resultado: ${output[0][0]}');

    //var output = List.filled(1 * 2, 0.0); // .reshape([0, 1]);
    var output = List.filled(5, 0.0).reshape([1, 5]);
    //print(output);

    // Execute o modelo
    _interpreter!.run(input, output);
    print(output);
    // Processar a saída
    // double maxIndex = output[0].reduce((double curr, double next) {
    //   print("$curr and $next");
    //   // print(curr > next);
    //   return curr > next ? curr : next;
    // });

    int maxIndex = output[0].indexOf(output[0].reduce((double curr, double next) => curr > next ? curr : next));

    print(maxIndex);
    String predictedLabel = _labels![maxIndex];
    // String predictedLabel = _labels![maxIndex.toInt()];

    print('Resultado: $predictedLabel');

    setState(() {
      _loading = false;
      _output = predictedLabel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
            stops: [0.0004, 1],
            colors: [
              Color(0xFFa8e063),
              Color(0xFF56ab2f),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Detect Flowers",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
                Text(
                  "Custom TensorFlow CNN",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.5,
                        ),
                        spreadRadius: 5,
                        blurRadius: 7,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        child: Center(
                          child: _loading
                              ? Container(
                                  width: 300,
                                  child: Column(
                                    children: [
                                      Image.asset('assets/flower.png'),
                                      SizedBox(
                                        height: 40,
                                      )
                                    ],
                                  ),
                                )
                              : Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 300,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.file(_image!),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      _output != null
                                          ? Text(
                                              "Prediction is ${_output}",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                              ),
                                            )
                                          : Container(),
                                      SizedBox(
                                        height: 30,
                                      )
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: pickerImage,
                              child: Container(
                                width: MediaQuery.of(context).size.width - 180,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 17, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Color(0xFF56ab2f),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Take a photo",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            GestureDetector(
                              onTap: pickerGalleryImage,
                              child: Container(
                                width: MediaQuery.of(context).size.width - 180,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 17, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Color(0xFF56ab2f),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Camera Roll",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
