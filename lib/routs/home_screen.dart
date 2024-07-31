import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:weather_app/utalites/add_info.dart';
import 'package:weather_app/utalites/currrent_forcast.dart';
import 'package:weather_app/utalites/hourly_forcast.dart';
import 'package:http/http.dart' as http;
import '../utalites/secrets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double temp = 0;
  String cityName = 'Paris'; // Initial city name
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentForcast();
  }

  Future<Map<String, dynamic>> getCurrentForcast() async {
    try {
      final res = await http.get(
        Uri.parse(
            'http://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$weatherApiKey'),
      );

      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'Some Unexpected error';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'WEATHER APP',
            style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh_outlined, color: Colors.yellow),
            ),
            const SizedBox(
              width: 30,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  fillColor: Color.fromARGB(255, 24, 23, 23),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        cityName = _controller.text;
                        getCurrentForcast(); 
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Container(
          color: Colors.yellow,
          child: FutureBuilder(
            future: getCurrentForcast(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }
              final data = snapshot.data!;
              final currentTem = (data['list'][0]['main']['temp']);
              final currentSky = (data['list'][0]['weather'][0]['main']);
              final currentPressure = (data['list'][0]['main']['pressure']);
              final currentSpeed = (data['list'][0]['wind']['speed']);
              final currentHumidity = (data['list'][0]['main']['humidity']);

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CurrentForcast(
                        icon: (currentSky == 'Clouds' || currentSky == 'Rain'
                            ? Icons.cloud_sharp
                            : Icons.sunny),
                        weather: currentSky,
                        temprature: '$currentTem K ',
                        cityName: cityName, // Pass cityName to CurrentForcast
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'WEATHER FORECAST',
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (int i = 0; i < 39; i++)
                              HourlyForcast(
                                icon: data['list'][i + 1]['weather'][0]['main'] ==
                                            'Cloud' ||
                                        data['list'][i + 1]['weather'][0]['main'] ==
                                            'Rain'
                                    ? Icons.cloud_sharp
                                    : Icons.sunny,
                                temprature: data['list'][i + 1]['main']['temp']
                                    .toString(),
                                time: data['list'][i + 1]['dt_txt'].toString(),
                              ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'ADDITIONAL INFORMATION',
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Row(
                                children: [
                                  AddInfo(
                                    icon: Icons.water_drop,
                                    condition: 'Humidity',
                                    value: currentHumidity.toString(),
                                  ),
                                  AddInfo(
                                    icon: Icons.air_outlined,
                                    condition: 'Wind Speed',
                                    value: currentSpeed.toString(),
                                  ),
                                  AddInfo(
                                    icon: Icons.beach_access_outlined,
                                    condition: 'Pressure',
                                    value: currentPressure.toString(),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
