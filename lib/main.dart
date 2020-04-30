import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hungry Face',
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.amber,
      ),
      home: MyHomePage(title: 'Hungry Face'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  var _recognitions;
  double _confidence = 0.0;
  String _label;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery,maxHeight: 256,maxWidth: 256);
    if(image == null){
      return;
    }
    setState(() {
      _image = image;
    });
    await analyzeTFLite();
  }

  Future analyzeTFLite() async {
    String res = await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels_food.txt",
        numThreads: 1);
    print('Model Loaded: $res');
    var recognitions = await Tflite.runModelOnImage(path: _image.path);
    setState(() {
      _recognitions = recognitions;
    });
    print('Recognition Result: ${_recognitions}');
    setState(() {
      _confidence = _recognitions[0]['confidence'];
      _label = _recognitions[0]['label'];
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              height: 130,
              child: Image.asset(
                _confidence < 0.41
                    ? "assets/images/sad.gif"
                    : "assets/images/happy.gif",
                fit: BoxFit.cover,
              ),
            ),
            Text("I am hungry!!"),
            _confidence > 0.41
                ? Text("I like to eat this food.")
                : _label == null ? Text("Please give me a food") : Text("I don't think this is a food"),
            _image == null
                ? Text('No image selected.')
                : Container(
                    padding: EdgeInsets.all(15),
                    width: double.infinity,
                    height: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      child: Image.file(
                        _image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
