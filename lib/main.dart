import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:human_directios/human_directions.dart';
import 'dart:async';

void main() async {
  await dotenv.load(fileName: 'assets/.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Human Directions v0',
      home: DirectionsScreen(),
    );
  }
}

class DirectionsScreen extends StatefulWidget {
  const DirectionsScreen({super.key});
  @override
  State<DirectionsScreen> createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends State<DirectionsScreen> {
  int _counter = 0;
  late Timer _timer;
  late HumanDirections directions;
  String openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? 'NO SUCH KEY';
  String googleDirectionsApiKey =
      dotenv.env['GOOGLE_DIRECTIOS_API_KEY'] ?? 'NO SUCH KEY';
  String origin =
      'Tlatelolco 708, Sta Maria del Granjeno, 37520 León de los Aldama, Gto.';
  String destination =
      'Postres Alejandro, Juan Jose Torres Landa 2801, Azteca, 37520 León de los Aldama, Gto.';
  @override
  void initState() {
    super.initState();
    _fetchDirections();
  }

  void _fetchDirections() async {
    directions = HumanDirections(
        openAiApiKey: openAiApiKey,
        googleDirectionsApiKey: googleDirectionsApiKey);
    directions.fetchHumanDirections(origin, destination);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // Actualiza el contador cada vez que el timer se ejecuta
        _counter++;
        if (directions.fetchResultFlag == 0 && directions.fetchHumanDirectionsFlag == 0) {
          timer.cancel(); // Detiene el timer
        }
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    int stepsCounter = 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Human Direction v0'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
          child: Column(
            children: [
              Text('Origen: $origin'),
              Text('Destino: $destination'),
              Text(directions.requestResult),
              Text((directions.resolvedDistance.text ?? '0')),
              Text(directions.resolvedTime.text ?? '0'),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 300,
                width: 390,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...?directions.steps?.map(
                        (e) {
                          /*if (kDebugMode) {
                            print(
                                '$stepsCounter - De: ${e.startLocation.toString()} Hacia: ${e.endLocation.toString()}, Instrucciones: ${e.instructions},Distancia:${e.distance?.text}  ,Duración Estimada:${e.duration?.text}  , Maniobra: ${e.maneuver} ');
                          }*/
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: 15,
                                  child: Container(
                                      alignment: Alignment.topLeft,
                                      child:
                                          Text((stepsCounter++).toString()))),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text('De: ${e.startLocation.toString()}'),
                                    Text('Hacia: ${e.endLocation.toString()}'),
                                    Text('Distamcia: ${e.distance?.text}'),
                                    Text(
                                        'Duración Estimada: ${e.duration?.text} '),
                                    Text('Instrucciones: ${e.instructions}'),
                                    if (e.maneuver != null)
                                      Text('Maniobra: ${e.maneuver}'),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('Human Directions:'),
              SizedBox(
                height: 200,
                width: 390,
                child: SingleChildScrollView(
                  child: Text(
                    (directions.updateFetchHumanDirections ?? 'Error on gpt prompt'),
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
