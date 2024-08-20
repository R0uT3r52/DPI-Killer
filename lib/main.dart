import 'dart:io';
import 'src/gdpi_config/config.dart' as cfg;
import 'widgets/settings.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(400, 400),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    maximumSize: Size(800, 1200),
    minimumSize: Size(200, 200),
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isRunning = false;
  Process? _process;
  String text = "OFF";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SwitchListTile(
                title: Text(text),
                value: _isRunning,
                onChanged: (bool value) async {
                  setState(() {
                    _isRunning = value;
                  });

                  if (_isRunning) {
                    List<String> args = [];

                    for (int i = 0; i < cfg.settings_as_arg.length; i++) {
                      if (cfg.settings_as_arg[i][2]) {
                        args.add(cfg.settings_as_arg[i][1]);
                      }
                    }
                    //caluclate path
                    final exeDir = File(Platform.resolvedExecutable).parent;
                    final blacklistPath = "${exeDir.path}\\goodbyedpi\\russia-youtube.txt";
                    final dpiPath = "${exeDir.path}\\goodbyedpi\\goodbyedpi.exe";
                    args.add(blacklistPath);

                    _process = await Process.start(
                        dpiPath,
                        args,
                        mode: ProcessStartMode.normal);
                    text = "ON";
                    setState(() {});
                  } else {
                    // Kill gDPI process
                    if (_process != null) {
                      _process!.kill();
                      _process = null;
                    }
                    // Kill WinDivert driver
                    try {
                      ProcessResult result =
                          await Process.run("sc", ["stop", "WinDivert1.4"]);

                      if (result.exitCode == 0) {
                        debugPrint("Service stopped successfully");
                      } else {
                        debugPrint(
                            "Error on service stopping: ${result.stderr}");
                      }
                    } catch (e) {
                      debugPrint("Error: $e");
                    }
                    text = "OFF";
                    setState(() {});
                  }
                }),
            Expanded(child: CheckBoxList(settings: cfg.settings_as_arg)),
          ],
        ),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    // Kill gDPI process
    if (_process != null) {
      _process!.kill();
      _process = null;
    }
    // Kill gDPI Driver
    try {
      ProcessResult result = await Process.run("sc", ["stop", "WinDivert1.4"]);

      if (result.exitCode == 0) {
        debugPrint("Service stopped successfully");
      } else {
        debugPrint("Error on service stopping: ${result.stderr}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    super.dispose();
  }
}
