import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:weather_project/API.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final lat = position.latitude;
    final long = position.longitude;
    print(lat);
    print(long);
    var url =
        'http://api.openweathermap.org/data/2.5/find?lat=${lat}&lon=${long}&cnt=10&appid=$apiKey';
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
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("Server Error"),
              content: new Text("Connection to server failed"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Widget _buildGetWeatherButton() {
    return Container(
      margin: EdgeInsets.only(
        top: 10.0,
        bottom: 10,
      ),
      // width: 200,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: fetchWeatherData,
        // padding: EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: Colors.white,
        splashColor: Colors.green,
        child: Text(
          'Get Weather',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 15.0,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherList() {
    return Container(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount:
            parsedWeather['list'] == null ? 0 : parsedWeather['list'].length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "${parsedWeather["list"][index]["name"]}",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        // letterSpacing: 2,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "${parsedWeather["list"][index]["main"]['temp'] - 273.15}ºC",
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "${parsedWeather["list"][index]["wind"]['speed'] * (36 / 10)}km/hr",
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                    ),
                  ],
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
            // ),
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Today's Weather",
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                // color: Colors.white,
                                fontWeight: FontWeight.w400),
                          ),
                          _buildGetWeatherButton(),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: _buildWeatherList(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
