import 'src/gdpi_config/config.dart' as cfg;
import 'utils/settings.dart';
import 'utils/utils.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:flutter/material.dart';

gDPI_controller controller = gDPI_controller();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(400, 400),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    maximumSize: Size(800, 1200),
    minimumSize: Size(200, 200),
    title: "DPI Killer",
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
    MenuItem.separator(),
    MenuItem(key: "exit", label: 'Close'),
  ]);

  await trayManager.setToolTip("DPI Killer");
  await trayManager.setContextMenu(menu);

  trayManager.addListener(TrayController());
  windowManager.addListener(WindowController());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DPI Killer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent, brightness: Brightness.light),
        switchTheme: const SwitchThemeData(splashRadius: 0),
        cardTheme: const CardTheme(color: Colors.deepPurpleAccent),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent, brightness: Brightness.dark),
        switchTheme: const SwitchThemeData(splashRadius: 0),
      ),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: 'DPI Killer'),
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
  String statusText = "OFF";
  Color _iconColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DPI Killer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SwitchListTile(
              title: Text(statusText),
              hoverColor: Colors.transparent,
              secondary: Icon(Icons.power_settings_new_sharp, color: _iconColor),
              value: isRunning,
              onChanged: _toggleSwitch,
            ),
            Expanded(child: CheckBoxList(settings: cfg.settings_as_arg)),
          ],
        ),
      ),
    );
  }

  void _toggleSwitch(bool value) async {
    setState(() {
      isRunning = value;
      statusText = isRunning ? "ON" : "OFF";
      _iconColor = isRunning ? Colors.green : Colors.red;
    });

    if (isRunning) {
      try {
        await controller.startgDPI(context);
      } catch (e) {
        controller.showErrorDialog(context, "Program not found", "Program \"goodbyedpi.exe\" not found. Please check \"gdpi\" folder.");
        setState(() {
          isRunning = false;
          statusText = "OFF";
          _iconColor = Colors.red;
        });
      }
    } else {
      await controller.killgDPI();
    }
  }

  @override
  Future<void> dispose() async {
    await controller.killgDPI();
    await TrayManager.instance.destroy();
    super.dispose();
  }
}
