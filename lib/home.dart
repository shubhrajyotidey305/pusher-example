import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _earnings = 0;
  final List _history = [];
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  Future<void> _initPusher() async {
    try {
      await pusher.init(
          apiKey: "f58727cd2576ee281b14",
          cluster: "mt1",
          onConnectionStateChange: onConnectionStateChange);
      await pusher.subscribe(
          channelName: 'my_channel',
          onEvent: (event) {
            if (mounted) {
              final data = jsonDecode(event.data);
              setState(() {
                _earnings += int.parse(data['rupee']);
              });
              _history.add({
                "rupee": int.parse(data['rupee']),
                "sender": data['sender'],
                "time": data['time']
              });
            }
            if (kDebugMode) {
              print("Event Received: ${event.data}");
            }
          });
      await pusher.connect();
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    if (kDebugMode) {
      print("Connection: $currentState");
    }
  }

  @override
  void initState() {
    super.initState();
    _initPusher();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 35.0,
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Text(
                    'My Name',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('My Wallet'),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: [
                              const Text('Rs:'),
                              const SizedBox(
                                height: 5.0,
                                width: 10.0,
                              ),
                              Text(
                                _earnings.toString(),
                                style: const TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20.0),
              child: const Text('Past Transactions'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Rs: ${_history[index]['rupee']}'),
                    subtitle: Text('Sender: ${_history[index]['sender']}'),
                    trailing: Text(_history[index]['time']),
                  );
                },
              ),
              flex: 2,
            )
          ],
        ),
      ),
    );
  }
}
