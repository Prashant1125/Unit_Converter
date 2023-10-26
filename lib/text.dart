import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pkconverter/services/admob/ad_manager.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  double? _userInput;
  String? _convertedMeasure;
  String? errorMessage;
  String? _startValue;
  var result = 0.0;
  var fromUnits = [
    'Meters',
    'Kilometer',
    'Grams',
    'Kilograms (kg)',
    'Feet',
    'Miles',
    'Pounds (lbs)',
    'ounces'
  ];

  final Map<String, int> measuresMap = {
    'Meters': 0,
    'Kilometer': 1,
    'Grams': 2,
    'Kilograms (kg)': 3,
    'Feet': 4,
    'Miles': 5,
    'Pounds (lbs)': 6,
    'ounces': 7
  };

  dynamic formulas = {
    '0': [1, 0.001, 0, 0, 3.280, 0.0006213, 0],
    '1': [1000, 1, 0, 0, 3280.84, 0, 6213, 0, 0],
    '2': [0, 0, 1, 0.0001, 0, 0, 0.00220, 0.03],
    '3': [0, 0, 1000, 1, 0, 0, 2.2046, 35.274],
    '4': [0.0348, 0.00030, 0, 0, 1, 0.000189],
    '5': [1609.34, 1.60934, 0, 05280, 1, 0, 0],
    '6': [0, 0, 453.592, 0.4535, 0, 0, 1, 16],
    '7': [0, 0, 28.3495, 0.02834, 3.28084, 0, 0.1]
  };

  void converter(double value, String from, String to) {
    int? nFrom = measuresMap[from];
    int? nTo = measuresMap[to];
    var multiplier = formulas[nFrom.toString()][nTo];
    result = value * multiplier;

    if (result == 0) {
      errorMessage = 'Cannot Performed This Conversion';
    } else {
      errorMessage = '${result.toString()} \n$_convertedMeasure';
    }
    setState(() {
      errorMessage = errorMessage;
    });
  }

  BannerAd? _bannerAd;
  bool _isLoaded = false;
  InterstitialAd? _interstitialAd;

  createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdManager.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            print('InterstitialAd loaded: ${ad.adUnitId}');
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  /// Loads a banner ad.
  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void initState() {
    super.initState();
    _userInput = 0;
    loadAd();
    createInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: SizedBox(
          width: _bannerAd?.size.width.toDouble(),
          height: _bannerAd?.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
      appBar: AppBar(
        toolbarHeight: 80,
        toolbarOpacity: 0.6,
        centerTitle: true,
        title: const Text(
          'Unit Converter',
          style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontFamily: 'times new roman',
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Enter Any Number',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onChanged: (text) {
                    var input = double.tryParse(text);
                    if (input != null) {
                      setState(() {
                        _userInput = input;
                      });
                    }
                  },
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Select Conversion',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadiusDirectional.circular(50),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        hint: const Text(
                          'Choose Unit',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: "times new roman",
                              fontWeight: FontWeight.w800),
                        ),
                        dropdownColor: Colors.blue,
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: "times new roman",
                            fontWeight: FontWeight.w800),
                        items: fromUnits.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _startValue = value;
                          });
                        },
                        value: _startValue,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    "->",
                    style: TextStyle(
                        fontFamily: "bold",
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadiusDirectional.circular(50),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        hint: const Text(
                          'Choose Unit',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: "times new roman",
                              fontWeight: FontWeight.w800),
                        ),
                        dropdownColor: Colors.blue,
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: "times new roman",
                            fontWeight: FontWeight.w800),
                        items: fromUnits.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _convertedMeasure = value;
                          });
                        },
                        value: _convertedMeasure,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: TextButton(
                  onPressed: () {
                    if (_startValue!.isEmpty ||
                        _convertedMeasure!.isEmpty ||
                        _userInput == 0) {
                    } else {
                      converter(_userInput!, _startValue!, _convertedMeasure!);
                      if (_interstitialAd != null) _interstitialAd!.show();
                    }
                  },
                  child: Container(
                    alignment: AlignmentDirectional.center,
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 89, 100, 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Convert',
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontFamily: "times new roman",
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Result",
                style: TextStyle(fontSize: 20, fontFamily: 'times new roman'),
              ),
              Card(
                elevation: 5,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  width: 300,
                  height: 150,
                  child: Center(
                    child: FittedBox(
                      child: Text(
                        errorMessage ?? '0',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 25,
                            fontFamily: "times new roman",
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
