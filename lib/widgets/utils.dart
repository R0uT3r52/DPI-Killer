import 'dart:io';
import '../src/gdpi_config/config.dart' as cfg;
import 'package:dpi_gui/main.dart';
import 'package:flutter/services.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';


bool isRunning = false;

class gDPI_controller {
  Process? _process;
  void startgDPI() async {
    List<String> args = [];
    final exeDir = File(Platform.resolvedExecutable).parent;
    final blacklistPath = "${exeDir.path}\\goodbyedpi\\russia-youtube.txt";
    final dpiPath = "${exeDir.path}\\goodbyedpi\\goodbyedpi.exe";

    for (int i = 0; i < cfg.settings_as_arg.length; i++) {
      if (cfg.settings_as_arg[i][2]) {
        args.add(cfg.settings_as_arg[i][1]);
      }
    }
    args.add(blacklistPath);
    _process = await Process.start(dpiPath, args, mode: ProcessStartMode.normal);
  }

  void killgDPI() async {
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
  @override
  void onWindowClose() {
    controller.killgDPI();
    windowManager.destroy();
    //super.onWindowClose();
  }
  @override
  void onWindowEvent(String eventName) async {
    if (eventName == "minimize") {
      await windowManager.hide();
    }
  }
}
