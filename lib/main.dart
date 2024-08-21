import 'src/gdpi_config/config.dart' as cfg;
import 'utils/settings.dart';
import 'utils/utils.dart';
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
    title: "DPI Killer"
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
      title: 'DPI Killer',
       theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent, brightness: Brightness.light),
        switchTheme: const SwitchThemeData(splashRadius: 0),
        cardTheme: const CardTheme(color: Colors.deepPurpleAccent)
        ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent, brightness: Brightness.dark),
        switchTheme: const SwitchThemeData(splashRadius: 0)
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
  //Process? _process;
  String text = "OFF";
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
                title: Text(text),
                hoverColor: Colors.transparent,
                secondary: Icon(Icons.power_settings_new_sharp, color: _iconColor,),
                value: isRunning,
                onChanged: (bool value) async {
                  setState(() {
                    isRunning = value;
                    debugPrint("$isRunning $value");
                  });

                  if (isRunning) {
                    try{
                      _iconColor = Colors.green;
                      text = "ON";
                      await controller.startgDPI(context);
                    }
                    catch(e){
                      // ignore: use_build_context_synchronously
                      controller.showErrorDialog(context, "Program not found", "Program \"goodbyedpi.exe\" not found. Please check \"gdpi\" folder.");
                      isRunning = false;
                      value = false;
                      _iconColor = Colors.red;
                      text = "OFF";
                    }
                    //setState(() {});
                  } else {
                    _iconColor = Colors.red;
                    text = "OFF";
                    await controller.killgDPI();
                    //setState(() {});
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
