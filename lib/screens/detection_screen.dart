
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hand_landmarker/hand_landmarker.dart';
import 'package:tflite_v2/tflite_v2.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  HandLandmarkerPlugin? _plugin;
  CameraController? _controller;
  List<Hand> _hands = [];
  bool _isInitialized = false;
  bool _isDetecting = false; // For hand landmarker
  bool _isClassifying = false; // For TFLite model (our 1s delay)

  final FlutterTts _flutterTts = FlutterTts();
  String _currentPrediction = "No detection";
  double _currentConfidence = 0.0;
  List<String> _lastDetectedSigns = [];

  final Color panelBackgroundColor = const Color(0xFF1E1E1E); // Dark background
  final Color accentColor = Colors.lightGreenAccent; // Prediction highlight
  final Color textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      try {
        debugPrint("1. Initializing...");
        final cameras = await availableCameras();
        final camera = cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );

        debugPrint("3. Initializing CameraController...");
        _controller = CameraController(
          camera,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _controller!.initialize();
        debugPrint("4. CameraController initialized.");

        debugPrint("5. Creating HandLandmarkerPlugin...");
        _plugin = HandLandmarkerPlugin.create(
          numHands: 2,
          minHandDetectionConfidence: 0.7,
          delegate: HandLandmarkerDelegate.GPU,
        );
        debugPrint("6. HandLandmarkerPlugin created.");

        debugPrint("7. Loading TFLite model...");
        await _loadModel();
        debugPrint("8. TFLite model loaded.");

        debugPrint("9. Initializing TTS...");
        await _initTts();
        debugPrint("10. TTS initialized.");

        debugPrint("11. Starting image stream...");
        if (_controller != null && _controller!.value.isInitialized) {
          await _controller!.startImageStream(_processCameraImage);
          debugPrint("12. Image stream started.");
        }

        if (mounted) {
          setState(() => _isInitialized = true);
          debugPrint("✅ 13. Initialization complete. Setting state.");
        }
      } catch (e) {
        debugPrint("❌❌❌ FATAL ERROR DURING INITIALIZATION ❌❌❌");
        debugPrint(e.toString());
      }
    }
  }

  Future<void> _loadModel() async {
    String? res = await Tflite.loadModel(
      model: "assets/hand_sign_model.tflite",
      labels: "assets/label.txt",
    );
    debugPrint("Model loaded: $res");
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String result) async {
    // We add checks here to prevent speaking "No detection" or "No hand"
    if (result.isNotEmpty && result != "No detection" && result != "No hand") {
      await _flutterTts.speak(result);
    }
  }

  @override
  void dispose() {
    debugPrint("DetectionScreen disposing...");
    _controller?.stopImageStream();
    _controller?.dispose();
    _plugin?.dispose();
    Tflite.close();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting || !_isInitialized || _plugin == null || _controller == null || !_controller!.value.isInitialized) return;
    _isDetecting = true;

    try {
      final hands = _plugin!.detect(
        image,
        _controller!.description.sensorOrientation,
      );

      if (mounted) setState(() => _hands = hands);

      if (hands.isNotEmpty && !_isClassifying) {
        _isClassifying = true;
        await _runClassification(hands.first);
      }
    } catch (e) {
      debugPrint('Landmarker detection error: $e');
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> _runClassification(Hand hand) async {
    try {
      if (hand.landmarks.length < 21) {
        setState(() {
          _currentPrediction = "No hand";
          _currentConfidence = 0.0;
        });
        return;
      }

      final inputData = <double>[];
      for (final lm in hand.landmarks) {
        inputData.add(lm.x);
        inputData.add(lm.y);
        inputData.add(lm.z);
      }

      final float32List = Float32List.fromList(inputData);
      final inputBytes = float32List.buffer.asUint8List();

      var recognitions = await Tflite.runModelOnBinary(
        binary: inputBytes,
        numResults: 5,
        threshold: 0.5,
      );

      String newPrediction = "No detection";
      double newConfidence = 0.0;

      // Store the prediction *before* the state update
      String oldPrediction = _currentPrediction;

      if (recognitions != null && recognitions.isNotEmpty) {
        final topResult = recognitions.first;
        String rawLabel = topResult["label"].toString();
        newPrediction = rawLabel.split(" ").last;
        newConfidence = topResult["confidence"] * 100;

        debugPrint("--- Hand Detected: $newPrediction (conf: ${newConfidence.toStringAsFixed(1)}%) ---");

        if (_lastDetectedSigns.isEmpty || _lastDetectedSigns.first != newPrediction) {
          _lastDetectedSigns.insert(0, newPrediction);
          if (_lastDetectedSigns.length > 5) {
            _lastDetectedSigns.removeLast();
          }
        }
      }

      if (mounted) {
        setState(() {
          _currentPrediction = newPrediction;
          _currentConfidence = newConfidence;
        });

        if (newPrediction != "No detection" && newPrediction != "No hand" && newPrediction != oldPrediction) {
          await _speak(newPrediction);
        }
      }
    } catch (e) {
      debugPrint('TFLite classification error: $e');
    } finally {
      if (mounted) {
        _isClassifying = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
        backgroundColor: Colors.black,
      );
    }

    final cameraPreview = CameraPreview(_controller!);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 7,
              child: Container(
                color: Colors.black87,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt, color: textColor),
                          SizedBox(width: 8),
                          Text("Webcam Feed", style: TextStyle(color: textColor, fontSize: 18)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              cameraPreview,
                              CustomPaint(
                                painter: HandLandmarkPainter(
                                  _hands,
                                  cameraLensDirection: _controller!.description.lensDirection,
                                  cameraOrientation: _controller!.description.sensorOrientation,
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    _currentPrediction,
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(2.0, 2.0),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(150, 0, 0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                color: panelBackgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 13),
                      child: Row(
                        children: [
                          Icon(Icons.bar_chart, color: textColor),
                          SizedBox(width: 8),
                          Text("Prediction Panel", style: TextStyle(color: textColor, fontSize: 17)),
                        ],
                      ),
                    ),
                    Divider(color: Colors.grey.shade800, height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Current Prediction:", style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14)),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: accentColor, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 6,
                                    backgroundColor: accentColor,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    _currentPrediction,
                                    style: TextStyle(color: accentColor, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),

                            Text("Confidence:", style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14)),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: _currentConfidence / 100,
                              backgroundColor: Colors.grey.shade700,
                              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "${_currentConfidence.toStringAsFixed(1)}%",
                                style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HandLandmarkPainter (No changes) ---
class HandLandmarkPainter extends CustomPainter {
  final List<Hand> hands;
  final CameraLensDirection cameraLensDirection;
  final int cameraOrientation;

  HandLandmarkPainter(
      this.hands, {
        required this.cameraLensDirection,
        required this.cameraOrientation,
      });

  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (final hand in hands) {
      final points = hand.landmarks.map((lm) {
        double x = lm.x;
        double y = lm.y;

        switch (cameraOrientation) {
          case 90:
            final temp = x;
            x = 1 - y;
            y = temp;
            break;
          case 270:
            final temp = x;
            x = y;
            y = 1 - temp;
            break;
          case 180:
            x = 1 - x;
            y = 1 - y;
            break;
          default:
            break;
        }

        if (cameraLensDirection == CameraLensDirection.front) {
          x = 1 - x;
        }

        return Offset(size.width * x, size.height * y);
      }).toList();

      _drawHandConnections(canvas, points, linePaint);
      for (final p in points) {
        canvas.drawCircle(p, 3, pointPaint);
      }
    }
  }

  void _drawHandConnections(Canvas canvas, List<Offset> pts, Paint paint) {
    const palm = [0, 1, 2, 5, 9, 13, 17, 0];
    const thumb = [1, 2, 3, 4];
    const index = [5, 6, 7, 8];
    const middle = [9, 10, 11, 12];
    const ring = [13, 14, 15, 16];
    const pinky = [17, 18, 19, 20];

    void connect(List<int> idx) {
      for (int i = 0; i < idx.length - 1; i++) {
      canvas.drawLine(pts[idx[i]], pts[idx[i + 1]], paint);
      }
    }

    connect(palm);
    connect(thumb);
    connect(index);
    connect(middle);
    connect(ring);
    connect(pinky);
  }

  @override
  bool shouldRepaint(covariant HandLandmarkPainter oldDelegate) =>
      oldDelegate.hands != hands;
}