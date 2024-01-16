// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:workmanager/workmanager.dart';

// const taskName = "sendNotification";
// sendData() {
//   log("You just parked your vehicle please send sms");
// }

// void callbackDispatcher() {
//   Workmanager().executeTask((taskName, inputData) {
//     switch (taskName) {
//       case 'sendNotification':
//         sendData();
//         break;
//       default:
//     }
//     return Future.value(true);
//   });
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Workmanager().initialize(
//     callbackDispatcher,
//     isInDebugMode: true,
//   );

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatelessWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(onPressed: () async {
//         var uniqueId = DateTime.now().second.toString();
//         await Workmanager().registerOneOffTask(
//           uniqueId,
//           taskName,
//           initialDelay: const Duration(
//             seconds: 10,
//           ),
//         );
//       }),
//       appBar: AppBar(
//         title: Text(title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               'counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

import 'notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request();
  Workmanager().initialize(callbackDispatcher);
  // registerBackgroundTask();
  LocalNotifications.initialize(); // Initialize the LocalNotifications class
  Workmanager().registerOneOffTask(
    jobName,
    jobName,
    inputData: {},
    initialDelay: const Duration(seconds: 10),
  );

  runApp(const MyApp());
}

const String jobName = "speedTrackingJob";

// void registerBackgroundTask() {
//   Workmanager().initialize(
//     callbackDispatcher,
//     isInDebugMode: true,
//   );
//   Workmanager().registerOneOffTask(
//     jobName,
//     jobName,
//     inputData: {},
//     initialDelay: const Duration(seconds: 10),
//   );
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Location Background Demo',
      home: LocationBackgroundApp(),
    );
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case jobName:
        await trackSpeedInBackground();
        break;
      default:
        print("Unknown task name");
        break;
    }

    return Future.value(true);
  });
}

String speed = "";
// void callbackDispatcher() {
//   log("Inside2");
//   Workmanager().executeTask((task, inputData) async {
//     switch (task) {
//       case "location_task":
//         try {
//           Position position = await Geolocator.getCurrentPosition(
//             desiredAccuracy: LocationAccuracy.high,
//           );
//           double speedInMps = position.speed;
//           double speedInKmh = speedInMps * 3.6;
//           log('Current speed: $speedInKmh km/h');
//           if (speedInKmh > 10) {
//             showNotification();
//           }
//         } catch (e) {
//           log('Error: ${e.toString()}');
//         }
//         break;
//       default:
//         log('Unknown task: $task');
//         break;
//     }
//     return Future.value(true);
//   });
// }
Future<void> trackSpeedInBackground() async {
  log("message");
  Position? currentPosition;
  double? currentSpeed;
  bool permission = await Geolocator.isLocationServiceEnabled();
  if (permission == false) {
    log("If");
    Geolocator.checkPermission();
  } else {
    Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      currentSpeed = position.speed;
      double speedInKmh = currentSpeed! * 3.6;
      log(currentSpeed.toString());
      if (speedInKmh > 10) {
        showNotification();
      }
    });
  }
}

void showNotification() {
  LocalNotifications.showNotification(
    id: 01,
    title: "title",
    body: "body",
  );
}

void registerBackgroundTask() {
  log("Inside1");

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  Workmanager().registerOneOffTask(
    jobName,
    jobName,
    inputData: {},
    initialDelay: const Duration(seconds: 10),
  );
}

class LocationBackgroundApp extends StatefulWidget {
  const LocationBackgroundApp({super.key});

  @override
  _LocationBackgroundAppState createState() => _LocationBackgroundAppState();
}

class _LocationBackgroundAppState extends State<LocationBackgroundApp> {
  @override
  void initState() {
    super.initState();
    registerBackgroundTask();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Background Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Location Background Demo'),
        ),
        body: Center(
          child: Text(speed == "" ? 'Location Background Demo' : speed),
        ),
      ),
    );
  }
}
