import 'src/gdpi_config/config.dart' as cfg;
import 'widgets/settings.dart';
import 'widgets/utils.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:flutter/material.dart';


gDPI_controller controller = gDPI_controller();

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
  await setupTray();
}

Future<void> setupTray() async {
  final trayManager = TrayManager.instance;

  await trayManager.setIcon('assets/ryodan.ico');

  final menu = Menu(items: [
    MenuItem(key: "show", label: 'Show', onClick: (menuItem) async {
      await windowManager.show();
      await windowManager.focus();
    }),
    // MenuItem.separator(),
    // MenuItem.checkbox(key: "enable", label: "Disabled", checked: isRunning,),
    MenuItem.separator(),
    MenuItem(key: "exit", label: 'Close'),
  ]);

  await trayManager.setContextMenu(menu);

  // Регистрация слушателя событий трея
  trayManager.addListener(TrayController());

  // Скрытие окна при сворачивании
  windowManager.addListener(WindowController());
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
  //Process? _process;
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
                value: isRunning,
                onChanged: (bool value) async {
                  setState(() {
                    isRunning = value;
                  });

                  if (isRunning) {
                    controller.startgDPI();
                    text = "ON";
                    setState(() {});
                  } else {
                    // Kill gDPI process
                    controller.killgDPI();
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
    controller.killgDPI();

    super.dispose();
  }
}
