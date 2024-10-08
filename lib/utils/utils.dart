import 'dart:io';
import 'package:windows_notification/notification_message.dart';

import '../src/gdpi_config/config.dart' as cfg;
import 'package:windows_notification/windows_notification.dart';
import 'package:dpi_gui/main.dart';
import 'package:flutter/services.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';


bool isRunning = false;

class gDPI_controller {
  Process? _process;
  Future <void> startgDPI(BuildContext context) async {
    List<String> args = [];
    final exeDir = File(Platform.resolvedExecutable).parent;
    final blacklistPath = "${exeDir.path}\\gdpi\\blacklist.txt";
    final dpiPath = "${exeDir.path}\\gdpi\\goodbyedpi.exe";

    for (int i = 0; i < cfg.settings_as_arg.length; i++) {
      if (cfg.settings_as_arg[i][2]) {
        args.add(cfg.settings_as_arg[i][1]);
      }
    }
    args.add(blacklistPath);
    try{
    _process = await Process.start(dpiPath, args, mode: ProcessStartMode.normal);
    }
    catch(e){
      throw Exception("Program not found");
    }
  }

  void showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  Future <void> killgDPI() async {
    if (_process != null) {
      _process!.kill();
      _process = null;
    }

    try {
      ProcessResult result = await Process.run("sc", ["stop", "WinDivert1.4"]);
      if (result.exitCode == 0) {
        debugPrint("Service stopped successfully");
      } else {
        debugPrint("Error on service stopping: ${result.stderr}");
      }
    } 
    catch (e) {
      debugPrint("Error: $e");
    }
  }
}

class TrayController extends TrayListener {
  @override
  void onTrayIconRightMouseDown() async {
    await trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == "show") {
      await windowManager.show();
      await windowManager.focus();
    } else if (menuItem.key == "exit") {
      controller.killgDPI();
      windowManager.destroy();
      trayManager.destroy();
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    } 
  }

  @override
  void onTrayIconMouseDown() async {
    if (await windowManager.isMinimized() == true) {
      await windowManager.show();
      await windowManager.focus();
    } else if (await windowManager.isMinimized() == false) {
      await windowManager.minimize();
      await windowManager.hide();
    }
  }
}

class WindowController extends WindowListener {

  void showNotification(){
    final _winNotifyPlugin = WindowsNotification(applicationId: "DPI Killer"); // idk why it wants appId, but I can place anything
    final exeDir = File(Platform.resolvedExecutable).parent;
    _winNotifyPlugin.clearNotificationHistory(); // Don't spawn a lot of notifications

    NotificationMessage message = NotificationMessage.fromPluginTemplate(
        "DPI Killer", // idk what is this
        "Application minimized",
        "DPI Killer minimized to system tray",
        image: "${exeDir.path}\\data\\appNotifyIcon.png"
    );
    _winNotifyPlugin.showNotificationPluginTemplate(message);
  }


  @override
  void onWindowClose() {
    controller.killgDPI();
    trayManager.destroy();
    windowManager.destroy();
  }
  @override
  void onWindowEvent(String eventName) async {
    if (eventName == "minimize") {
      await windowManager.hide();
      showNotification();
    }
  }
}
