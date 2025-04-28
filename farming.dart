import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farming Helper',
      theme: ThemeData(primarySwatch: Colors.green),
      home: RecommendationScreen(),
    );
  }
}

class RecommendationScreen extends StatefulWidget {
  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final _formKey = GlobalKey<FormState>();
  double nitrogen = 0, phosphorous = 0, potassium = 0;
  double ph = 7, rainfall = 100;
  String recommendation = '';

  Future<void> _predictCrop() async {
    final interpreter = await Interpreter.fromAsset('assets/crop_model.tflite');
    var input = [nitrogen, phosphorous, potassium, ph, rainfall];
    var output = List.filled(1, 0).reshape([1, 1]);
    
    interpreter.run(input, output);
    setState(() {
      recommendation = _decodeCrop(output[0][0]);
    });
  }

  String _decodeCrop(int index) {
    final crops = ['Rice', 'Wheat', 'Maize', 'Soybean', 'Cotton'];
    return crops[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crop Recommender')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nitrogen (kg/ha)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => nitrogen = double.tryParse(v) ?? 0,
              ),
              // Add similar fields for P, K, ph, rainfall
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _predictCrop,
                child: Text('Get Recommendation'),
              ),
              SizedBox(height: 20),
              Text('Recommended Crop: $recommendation', 
                   style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}