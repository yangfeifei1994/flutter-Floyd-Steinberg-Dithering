import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import 'ditherer_util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_floyd_steinberg_dithering',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'flutter_floyd_steinberg_dithering'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() => _counter++);
  }

  Future<Widget> _loadDithererImage(String imagePath,{List<Color> colors = const [Colors.black, Colors.white, Colors.red]}) async {
    final ByteData data = await rootBundle.load(imagePath);
    final Uint8List bytes = data.buffer.asUint8List();
    final img.Image image = img.decodeImage(bytes)!;
    final img.Image processedImage = DithererUtil.dither(image, colors);
    final List<int> processedBytes = img.encodePng(processedImage);
    final Uint8List processedUint8List = Uint8List.fromList(processedBytes);
    return Image.memory(processedUint8List);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              const Text('You have pushed the button this many times:'),
              Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
              const Center(child: Image(image: AssetImage('assets/images/1.jpeg'))),
              const SizedBox(width: 10),
              Center(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 100, minWidth: 100),
                  child: FutureBuilder(
                      future: _loadDithererImage("assets/images/1.jpeg"),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return snapshot.data as Widget;
                        } else {
                          return const CircularProgressIndicator();
                        }
                      }),
                ),
              ),
              const SizedBox(width: 10),
              const Center(child: Image(image: AssetImage('assets/images/2.jpeg'))),
              const SizedBox(width: 10),
              Center(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 100, minWidth: 100),
                  child: FutureBuilder(
                      future: _loadDithererImage("assets/images/2.jpeg", colors: [Colors.black, Colors.white, Colors.red, Colors.green, Colors.blue]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return snapshot.data as Widget;
                        } else {
                          return const CircularProgressIndicator();
                        }
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
