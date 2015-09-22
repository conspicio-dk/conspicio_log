// Copyright (c) 2015, Bjarne Hansen. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library conspicio_log.server;

import 'dart:io';
import 'package:logging/logging.dart';
import '../base.dart';

class SyncFileLogHandler extends LogHandler
{
  LogRecordFormatter _formatter = DEFAULT_PATTERN_FORMATTER;
  String _filename;
  File _file;

  SyncFileLogHandler(String filename, [LogRecordFormatter formatter]) {
    _filename = filename;
    _file = new File(_filename);
    if (formatter != null) _formatter = formatter;

  }

  @override
  void call(LogRecord record)
  {
    var raf = _file.openSync(mode:FileMode.APPEND);
    raf.writeStringSync(_formatter.format(record) + "\n");
    raf.closeSync();
  }
}

class SyncRollingFileLogHandler extends LogHandler
{
  LogRecordFormatter _formatter = DEFAULT_PATTERN_FORMATTER;
  String _filename;
  File _file;
  int _max_size = 1 * 1024; // 1024K = 1M
  int _max_files = 5;

  SyncRollingFileLogHandler(String filename, {int max_size: 1014 * 1024, int max_files: 5, LogRecordFormatter formatter: null}) {
    _filename = filename;
    _file = new File(_filename);

    if (max_size != null) _max_size = max_size;
    if (max_files != null) _max_files = max_files;
    if (formatter != null) _formatter = formatter;

    if (!_file.existsSync()) _file.createSync(recursive: true);
  }

  void _roll() {
    if (_max_files > 0) {
      // Delete the oldest file numberet maxFiles.
      var df = new File(_filename + ".$_max_files");
      if (df.existsSync()) df.deleteSync();

      // Rename files younger that maxFiles.
      for (int i = _max_files - 1; i > 0; i --) {
        var ff = new File(_filename + ".$i");
        if (ff.existsSync()) ff.renameSync(_filename + ".${i + 1}");
      }

      // Rename the current file to have
      if (_file.existsSync()) _file.renameSync(_filename + ".1");

      _file.createSync(recursive: false);
    }
    else {
      _file.deleteSync();
      _file.createSync(recursive: false);
    }
  }

  @override
  void call(LogRecord record) {
    _file.writeAsStringSync(_formatter.format(record) + "\n", mode: FileMode.APPEND, flush: true);
    if (_file.lengthSync() >= _max_size) _roll();
  }
}