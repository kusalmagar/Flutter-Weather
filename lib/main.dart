import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:weather_project/API.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Weather(),
    );
  }
}

class Weather extends StatefulWidget {
  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  // void _getCurrentlocation() async {
  //   final position = await Geolocator()
  //       .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   print(position.latitude);
  // }

  Map parsedWeather;
  List weatherData;
  double temperature;
  String api_key = API_KEY;

  Future fetchWeatherData() async {
    final position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position.latitude);
    var url =
        'http://api.openweathermap.org/data/2.5/find?lat=${position.latitude}&lon=${position.longitude}&cnt=10&appid=$api_key';
    http.Response response = await http.get(url);
    parsedWeather = jsonDecode(response.body);
    setState(() {
      weatherData = parsedWeather['list'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather.com'),
        backgroundColor: Colors.lightBlue,
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => Focus.of(context).unfocus(),
          child: Column(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.lightBlue, Colors.white],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                width: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // _buildGetWeatherButton(),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 25.0),
                        width: double.infinity,
                        child: RaisedButton(
                          elevation: 5.0,
                          onPressed: fetchWeatherData,
                          padding: EdgeInsets.all(15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          color: Colors.white,
                          // hoverElevation: 10.0,
                          splashColor: Colors.green,
                          child: Text(
                            'Get Weather',
                            style: TextStyle(
                              color: Colors.blue,
                              letterSpacing: 2.0,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 450,
                        // color: Colors.white70,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white70,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              offset: Offset(0, 10),
                              blurRadius: 10.0,
                            )
                          ],
                        ),
                        child: ListView.builder(
                          itemCount: parsedWeather['list'] == null
                              ? 0
                              : parsedWeather['list'].length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "${parsedWeather["list"][index]["name"]}",
                                      style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                          color: Colors.black),
                                    ),
                                    Text(
                                      "${parsedWeather["list"][index]["main"]['temp'] - 273.15}ºC",
                                      style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                          color: Colors.black),
                                    ),
                                    Text(
                                      "${parsedWeather["list"][index]["wind"]['speed'] * (36 / 10)}km/hr",
                                      style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                          color: Colors.black),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
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
    );
  }
}
