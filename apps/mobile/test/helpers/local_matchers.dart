import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/domain/errors/local_data_exception.dart';

Matcher hasCode(LocalDataError code) =>
    isA<LocalDataException>().having((e) => e.code, 'code', code);
