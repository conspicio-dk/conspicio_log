// Copyright (c) 2015, Bjarne Hansen. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library conspicio_log.base;

import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:conspicio_fmt/fmt.dart' as fmt;

abstract class LogRecordFormatter
{
  String format(LogRecord record);
}

abstract class LogHandler
{
  void call(LogRecord record);
}


// %{item[,width][:format]}
//
//  {l}  Level               (String)
//  {m}  Message             (String)
//  {n}  Name                (String)
//  {t}  Timestamp           (DateTime)
//  {s}  Sequence            (int)
//  {x}  Exception           (String)
//  {e}  Exception Message.  (String) Hmmm...
//  {z}   StackTrace         (String) ???

const String _default_pattern = r"{t:yyyy-MM-dd HH:mm:ss.SSS} [{l,-6}] {n,10}: {m} {x}";
final PatternFormatter DEFAULT_PATTERN_FORMATTER = new PatternFormatter();

class PatternFormatter extends LogRecordFormatter
{
  String _pattern = _default_pattern;

  PatternFormatter([String pattern]) {
    if (pattern != null) _pattern = pattern;
  }

  @override
  String format(LogRecord record) {
    return fmt.format(_pattern, {
      "l": record.level,
      "m": record.message,
      "n": record.loggerName,
      "t": record.time,
      "s": record.sequenceNumber,
      "x": record.error,
      "z": record.stackTrace
    });
  }
}

class PrintLogHandler extends LogHandler
{
  LogRecordFormatter _formatter = DEFAULT_PATTERN_FORMATTER;

  PrintLogHandler([LogRecordFormatter formatter]) {
    if (formatter != null) _formatter = formatter;
  }

  @override
  void call(LogRecord record)
  {
    print(_formatter.format(record));
  }
}







