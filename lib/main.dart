import 'dart:convert';
import 'package:flutter/material.dart';
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
  Map parsedWeather;
  List weatherData;
  double temperature;
  bool isLoading = true;
  String apiKey = API_KEY;

  Future fetchWeatherData() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final latitude = position.latitude;
    final longitude = position.longitude;
    print(latitude);
    print(longitude);
    var url =
        'http://api.openweathermap.org/data/2.5/find?lat=$latitude&lon=$longitude&cnt=10&appid=$apiKey';
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      parsedWeather = jsonDecode(response.body);
      setState(() {
        weatherData = parsedWeather['list'];
        isLoading = false;
      });
      print(weatherData);
    } else {
      print('Something went wrong \nrespone Code : ${response.statusCode} ');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Widget _buildGetWeatherButton() {
    return Container(
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
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherList() {
    return Container(
      height: 650,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount:
            parsedWeather['list'] == null ? 0 : parsedWeather['list'].length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${parsedWeather["list"][index]["name"]}",
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 2,
                        color: Colors.black),
                  ),
                  Text(
                    "${parsedWeather["list"][index]["main"]['temp'] - 273.15}ºC",
                    style: TextStyle(
                        fontSize: 22.0,
                        // fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.black),
                  ),
                  Text(
                    "${parsedWeather["list"][index]["wind"]['speed'] * (36 / 10)}km/hr",
                    style: TextStyle(
                      fontSize: 22.0,
                      // fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.black,
                    ),
                  ),
                  Image.network(
                    "http://openweathermap.org/img/w/"
                                "${parsedWeather["list"][index]["weather"][0]['icon']}"
                            .toString() +
                        '.png',
                    // height: 30.0,
                    // width: 30.0,
                    // color: Colors.black,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Pokhara'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Stack(
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
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
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
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _buildGetWeatherButton(),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                // alignment: Alignment.centerLeft,
                                child: Text(
                                  "Today's Weather",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              _buildWeatherList(),
                              SizedBox(
                                height: 40,
                              )
                            ],
                          ),
                        )
                        // _buildGetWeatherButton(),
                        // _buildWeatherList(),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
