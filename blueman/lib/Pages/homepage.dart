import 'package:flutter/material.dart';
import 'dart:async';
//import 'package:quickalert/quickalert.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

List<BluetoothDevice> hidden = List<BluetoothDevice>.empty(growable: true);
void handlelongpress(BluetoothDevice test, context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return (AlertDialog.adaptive(
          contentPadding: const EdgeInsets.all(0),
          alignment: Alignment.bottomCenter,
          backgroundColor: const Color.fromARGB(183, 0, 0, 0),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Padding(padding: EdgeInsets.all(0)),
              TextButton(
                onPressed: () {
                  hidden.add(test);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Hide Device..",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () {
                  FlutterBluetoothSerial.instance
                      .removeDeviceBondWithAddress(test.address);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Forget abourit",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ));
      });
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  BluetoothState isEnabled = BluetoothState.UNKNOWN;
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  List<BluetoothDevice> bonded = List<BluetoothDevice>.empty(growable: true);
  bool isDiscovering = false;
  bool on = false;

  @override
  void initState() {
    super.initState();
    FlutterBluetoothSerial.instance.state.then((vals) {
      isEnabled = vals;
    });
    FlutterBluetoothSerial.instance.getBondedDevices().then((value) {
      for (int v = 0; v < hidden.length; v++) {
        if (value.contains(hidden[v])) {
          value.remove(hidden[v]);
        }
      }
      setState(() {
        bonded = value;
        if (isEnabled == BluetoothState.STATE_ON) {
          on = true;
        }
        if (isEnabled == BluetoothState.STATE_OFF) {
          on = false;
        }
      });
    });
    if (isDiscovering) {
      startDiscovery();
    }
  }

  void restartDiscovery() {
    setState(() {
      results.clear();
      isDiscovering = true;
    });
    startDiscovery();
  }

  void startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((event) {
      setState(() {
        final existingIndex = results.indexWhere(
            (element) => element.device.address == event.device.address);
        if (existingIndex > 0) {
          results[existingIndex] = event;
        } else {
          results.add(event);
        }
      });
    });
    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
    if (results.isEmpty) {}
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();

    super.dispose();
  }

  void bluestate() {
    if (isEnabled == BluetoothState.STATE_ON) {
      FlutterBluetoothSerial.instance.requestDisable();
      on = false;
    }
    if (isEnabled == BluetoothState.STATE_OFF) {
      FlutterBluetoothSerial.instance.requestEnable();
      on = true;
    }
    Navigator.pop(context);
    setState(() {
      on;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 1, 51, 92),
        appBar: AppBar(
          title: const Text(
            "Blue man",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
          ),
          backgroundColor: Colors.blue,
        ),
        drawer: SafeArea(
            child: Drawer(
          shape: Border.all(style: BorderStyle.solid),
          backgroundColor: Colors.lightBlueAccent,
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(20)),
              const DrawerHeader(
                  child: Icon(
                Icons.account_circle_sharp,
                size: 76,
              )),
              const ListTile(
                shape: Border(
                    bottom: BorderSide(color: Color.fromARGB(24, 0, 0, 0))),
                leading: Icon(
                  Icons.settings,
                  size: 23,
                  color: Color.fromARGB(255, 5, 2, 2),
                ),
                title: Text("S E T T I N G S"),
              ),
              ListTile(
                shape: const Border(
                    bottom: BorderSide(color: Color.fromARGB(24, 0, 0, 0))),
                leading: on
                    ? const Icon(
                        Icons.bluetooth_connected_sharp,
                        color: Colors.black,
                      )
                    : const Icon(
                        Icons.bluetooth_disabled_sharp,
                        color: Colors.black,
                      ),
                title: on
                    ? const Text("Turn bluetooth off ")
                    : const Text("Turn bluetooth on  "),
                onTap: () => bluestate(),
              ),
              const ListTile(
                shape: Border(
                    bottom: BorderSide(color: Color.fromARGB(24, 0, 0, 0))),
                leading: Icon(
                  Icons.autorenew_sharp,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                title: Text("Set preferences"),
              )
            ],
          ),
        )),
        body: on
            ? ListView(
                scrollDirection: Axis.vertical,
                children: [
                  Title(
                      color: Colors.white,
                      child: const Text(
                        textAlign: TextAlign.center,
                        "Your Devices",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      )),
                  ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: bonded.length,
                      itemBuilder: (BuildContext context, int index) {
                        final device = bonded[index];
                        final name = device.name;
                        return ListTile(
                          shape: const Border(
                              bottom: BorderSide(color: Colors.black)),
                          leading: Text(
                            name.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          title: Text(
                            device.isConnected ? "Connected" : "Disconected",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          trailing: const Text(
                            "ok",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          onLongPress: () {
                            handlelongpress(device, context);

                            setState(() {});
                          },
                        );
                      }),
                  ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: results.length,
                      itemBuilder: (BuildContext context, int index) {
                        final BluetoothDiscoveryResult reslt = results[index];
                        final device = reslt.device;
                        final address = device.address;
                        return (ListTile(
                          leading: Text(
                            device.name.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          onLongPress: () async {
                            try {
                              bool bond = false;
                              if (device.isBonded) {
                                await FlutterBluetoothSerial.instance
                                    .removeDeviceBondWithAddress(address);
                              } else {
                                bond = (await FlutterBluetoothSerial.instance
                                    .bondDeviceAtAddress(address))!;
                              }
                              setState(() {
                                results[results.indexOf(reslt)] =
                                    BluetoothDiscoveryResult(
                                        device: BluetoothDevice(
                                            address: address,
                                            bondState: bond
                                                ? BluetoothBondState.bonded
                                                : BluetoothBondState.none,
                                            name: device.name,
                                            type: device.type),
                                        rssi: reslt.rssi);
                              });
                            } catch (ex) {
                              print("Error occured");
                            }
                          },
                        ));
                      }),
                  FloatingActionButton(
                    onPressed: () => restartDiscovery(),
                    child: const Icon(
                      Icons.add,
                      size: 43,
                      color: Colors.white,
                    ),
                  )
                ],
              )
            : Container(
                color: Colors.deepOrange,
                child: Column(
                  children: [
                    IconButton(
                        onPressed: () =>
                            FlutterBluetoothSerial.instance.requestEnable(),
                        icon: const Icon(
                          Icons.bluetooth_disabled_sharp,
                          size: 120,
                          color: Color.fromARGB(255, 209, 7, 7),
                        )),
                    const Text("Please turn on bluetooth to use the app... ")
                  ],
                ),
              ));
  }
}
