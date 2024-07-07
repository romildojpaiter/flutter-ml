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
      _interpreter = await Interpreter.fromAsset('assets/dog_cat_model.tflite');
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
    var output = List.filled(2, 0.0).reshape([1, 2]);
    //print(output);

    // Execute o modelo
    _interpreter!.run(input, output);
    // print(output);
    // Processar a saída
    double maxIndex = output[0].reduce((double curr, double next) {
      // print("$curr and $next");
      // print(curr > next);
      return curr > next ? 0.0 : 1.0;
    });
    // print(maxIndex);
    String predictedLabel = _labels![maxIndex.toInt()];

    print('Resultado: $predictedLabel');

    setState(() {
      _loading = false;
      _output = predictedLabel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        title: const Text(
          "Cat or Dog",
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Teachable Machine",
              style: TextStyle(color: Color(0xFFEEDA28), fontSize: 15),
            ),
            const SizedBox(
              height: 6,
            ),
            const Text(
              "Detect Dogs and Cats",
              style: TextStyle(
                color: Color(0xFFE99600),
                fontWeight: FontWeight.w500,
                fontSize: 28,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: _loading
                  ? Container(
                      width: 150,
                      child: Column(
                        children: [
                          Image.asset('assets/cat.png'),
                          SizedBox(
                            height: 50,
                          )
                        ],
                      ),
                    )
                  : Container(
                      child: Column(
                        children: [
                          Container(
                            height: 250,
                            child: Image.file(_image!),
                          ),
                          _output != null
                              ? Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    _output!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
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
                      width: MediaQuery.of(context).size.width - 200,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 17,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFE99600),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text("Take a photo"),
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  GestureDetector(
                    onTap: pickerGalleryImage,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 200,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 17,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFE99600),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text("Camera Roll"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
