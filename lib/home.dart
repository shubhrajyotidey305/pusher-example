import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _earnings = 0;
  final List _history = [];
  final messageTextController = TextEditingController();
  late String? messageText;
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  Future<void> _initPusher() async {
    try {
      await pusher.init(
          apiKey: "APIKEY",
          cluster: "CLUSTER",
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

  void onTriggerEventPressed(String _money) async {
    await pusher.trigger(PusherEvent(
      channelName: "presence-my_channel1",
      eventName: "my-event",
      data: {
        "rupee": _money,
        "time": DateTime.now().toString().substring(0, 16),
        "sender": "Ajay"
      },
    ));
  }

  @override
  void initState() {
    super.initState();
    _initPusher();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Send Money'),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: [
                              const Text('Rs:'),
                              Expanded(
                                child: TextField(
                                  controller: messageTextController,
                                  onChanged: (value) {
                                    //Do something with the user input.
                                    messageText = value;
                                  },
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 20.0),
                                    hintText: 'Type your amount...',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  //Implement send functionality.
                                  messageTextController.clear();
                                  // function
                                  onTriggerEventPressed(messageText!);
                                  if (kDebugMode) {
                                    print(messageText);
                                  }
                                  messageText = null;
                                },
                                child: const Text(
                                  'Send',
                                  style: TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
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
      ),
    );
  }
}
