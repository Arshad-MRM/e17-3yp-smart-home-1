import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';

class SmartPlug extends StatefulWidget {
  final String homeId;
  final String roomId;
  final String deviceid;
  final String port;

  const SmartPlug({
    Key? key,
    required this.homeId,
    required this.roomId,
    required this.deviceid,
    required this.port,
  }) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  _SmartPlugState createState() =>
      _SmartPlugState(homeId, roomId, deviceid, port);
}

class _SmartPlugState extends State<SmartPlug> {
  String homeId;
  String roomId;
  String deviceid;
  String port;
  _SmartPlugState(this.homeId, this.roomId, this.deviceid, this.port);

  String _plugName = 'Plug';
  String _roomName = 'Bed Room';
  bool _switchIsIsOn = false;
  bool _scheduleIsOn = false;
  String? userid;
  String? tokensend;
  String? _power = '0';

  var intValue = 5;
  var temp = 0;

  TimeOfDay _time = TimeOfDay(hour: 13, minute: 00);
  TimeOfDay _endTime = TimeOfDay(hour: 13, minute: 15);

  @override
  initState() {
    // print("port");
    // print(port);
    // print("deviceid");
    // print(deviceid);
    super.initState();
    getData();
  }

  //initial page
  Widget page = Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: const <Widget>[
          CircularProgressIndicator(),
        ],
      ));

  //Rooms List
  List data = [];

  //send Data
  void sendData() async {
    try {
      print("1\n");
      print("Smartplug Send Data");
      print(port);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      userid = prefs.getString('userid');
      tokensend = token.toString();

      //print
      print(_switchIsIsOn);
      print(port);
      print(deviceid);

      final response = await http.post(
          Uri.parse('http://$publicIP:$PORT/api/devices/turnOn'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            "Authorization": "Bearer $token"
          },
          body: jsonEncode(
            {
              'state': _switchIsIsOn.toString(),
              'port': port,
              'deviceid': deviceid
            },
          ));

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> resp = json.decode(response.body);

        setState(() {});
      } else if (response.statusCode == 403) {
        Fluttertoast.showToast(
            msg: "Requested time out. Please log in again.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 16.0,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      } else {
        Fluttertoast.showToast(
            msg: "Requested time out. Please log in again.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 16.0,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    } on Exception catch (e) {
      print("exep");
      print(e);
    } catch (e) {
      print(e);
    }
  }

//get data
  void getData() async {
    try {
      print("1\n");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      userid = prefs.getString('userid');
      print(token);
      tokensend = token.toString();

      final response = await http.post(
          Uri.parse('http://$publicIP:$PORT/api/devices/status'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            "Authorization": "Bearer $token"
          },
          body: jsonEncode(
            {
              'deviceid': deviceid,
            },
          ));

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> resp = json.decode(response.body);

        _switchIsIsOn = resp["device"]["status"] == 0 ? false : true;

        setState(() {});
      } else if (response.statusCode == 403) {
        Fluttertoast.showToast(
            msg: "Requested time out. Please log in again.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 16.0,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      } else {
        Fluttertoast.showToast(
            msg: "Requested time out. Please log in again.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 16.0,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    } on Exception catch (e) {
      print("exep");
      print(e);
    } catch (e) {
      print(e);
    }
  }

//schedule
  void sheduleData() async {
    try {
      print("shedule\n");
      print(_time.format(context));

      DateTime startTime = DateFormat.jm().parse(_time.format(context));
      DateTime endTime = DateFormat.jm().parse(_endTime.format(context));
      print(startTime);
      print(endTime);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      userid = prefs.getString('userid');
      //print(token);
      tokensend = token.toString();

      final response = await http.post(
          Uri.parse('http://$publicIP:$PORT/api/devices/schedule'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            "Authorization": "Bearer $token"
          },
          body: jsonEncode(
            {
              'port': port,
              'deviceid': deviceid,
              'StartTime': startTime.toString(),
              'EndTime': endTime.toString(),
              'schedulestate': _scheduleIsOn.toString(),
              'd_t': 2,
            },
          ));

      print(deviceid);
      print(_time);
      print(_scheduleIsOn.toString());
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> resp = json.decode(response.body);

        print(data);

        setState(() {});
      } else if (response.statusCode == 403) {
        Fluttertoast.showToast(
            msg: "Requested time out. Please log in again.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 16.0,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      } else {
        Fluttertoast.showToast(
            msg: "Requested time out. Please log in again.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 16.0,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    } on Exception catch (e) {
      print("exep");
      print(e);
    } catch (e) {
      print(e);
    }
  }

  void _selectTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _time,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (newTime != null) {
      setState(() {
        _time = newTime;
      });
    }
  }

  void _selectEndTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _endTime,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (newTime != null) {
      setState(() {
        _endTime = newTime;
      });
    }
  }

//power
  void powerConsume() {
    if (_switchIsIsOn) {
      temp = Random().nextInt(40);
      intValue = temp;
      setState(() {
        _power = intValue.toString();
      });
    } else {
      intValue = 0;
      _power = intValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            '$_roomName',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFF6F35A5),
            child: Container(
              padding: EdgeInsets.only(top: 0, left: 20),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Container(
                padding: EdgeInsets.only(top: 30, left: 20),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Text(
                  '$_plugName',
                  style: const TextStyle(
                    fontFamily: 'Circular Std',
                    fontSize: 30,
                    color: Color(0xffffffff),
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(
                height: 80,
              ),
              Expanded(
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(30),
                  child: SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: <Widget>[
                          //icon
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.power_settings_new,
                              color: _switchIsIsOn
                                  ? Colors.yellow.shade600
                                  : Colors.black,
                              size: 60,
                            ),
                          ),
                          //turn light on
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                // Toggle light when tapped.
                                _switchIsIsOn = !_switchIsIsOn;
                                sendData();
                              });
                            },
                            child: Container(
                              color: _switchIsIsOn
                                  ? Colors.yellow.shade600
                                  : Colors.black12,
                              padding: const EdgeInsets.all(8),
                              // Change button text when light changes state.
                              child: Text(_switchIsIsOn
                                  ? 'TURN SWITCH OFF'
                                  : 'TURN SWITCH ON'),
                            ),
                          ),

                          const Divider(
                            color: Colors.black,
                            height: 25,
                          ),

                          Container(
                            //padding: EdgeInsets.fromLTRB(38, 5, 38, 20),
                            child: const Text(
                              'Schedule',
                              style: TextStyle(
                                fontFamily: 'Circular Std',
                                fontSize: 25,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                // Toggle light when tapped.
                                _scheduleIsOn = !_scheduleIsOn;
                              });
                            },
                            child: Container(
                              color: _scheduleIsOn
                                  ? Colors.green.shade300
                                  : Colors.black12,
                              padding: const EdgeInsets.all(8),
                              margin: EdgeInsets.symmetric(vertical: 10),
                              // Change button text when light changes state.
                              child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(_scheduleIsOn ? 'ON' : 'OFF')),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFFF1E6FF), // background
                              onPrimary: Colors.black, // foreground
                            ),
                            onPressed: _selectTime,
                            child: const Text('SELECT START TIME'),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Schedule Starts : ${_time.format(context)}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 18),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFFF1E6FF), // background
                              onPrimary: Colors.black, // foreground
                            ),
                            onPressed: _selectEndTime,
                            child: Text('SELECT END TIME'),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Schedule Ends: ${_endTime.format(context)}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Divider(
                            color: Colors.black,
                            height: 25,
                          ),
                          Container(
                            //margin: EdgeInsets.only(right: 100),
                            child: Text(
                              'Energy Consuming',
                              style: TextStyle(
                                fontFamily: 'Circular Std',
                                fontSize: 25,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Container(
                              child: Row(
                            children: [
                              // SocalIcon(
                              //   iconSrc: "assets/icons/google-plus.svg",
                              //   press: () {},
                              // ),
                              Container(
                                margin: EdgeInsets.fromLTRB(
                                    MediaQuery.of(context).size.width / 3.6,
                                    0,
                                    0,
                                    0),
                                child: SvgPicture.asset(
                                  "assets/icons/Green_Power_Button_clip_art.svg",
                                  height: 60,
                                  width: 60,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    powerConsume();
                                    // Toggle light when tapped.
                                    //_scheduleIsOn = !_scheduleIsOn;
                                  });
                                },
                                child: Container(
                                  child: Center(
                                    child: Text(
                                      _power! + ' W',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 35,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                          Text(
                            'Today',
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
