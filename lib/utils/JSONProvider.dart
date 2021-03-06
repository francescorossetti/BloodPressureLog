import 'dart:convert';
import 'dart:io';

import 'package:bloodpressurelog/utils/database/controllers/measurementService.dart';
import 'package:bloodpressurelog/utils/database/models/measurement.dart';
import 'package:path_provider/path_provider.dart';

class JSONProvider {
  static Future<Directory> getPath() async {
    Directory documentsDirectory;
    if (Platform.isAndroid)
      documentsDirectory = await getExternalStorageDirectory();
    else if (Platform.isIOS)
      documentsDirectory = await getApplicationDocumentsDirectory();

    return documentsDirectory;
  }

  static Future<String> exportMeasurements() async {
    List<Measurement> measurements = await MeasurementService().readAll();

    String contents = jsonEncode(measurements);

    String dir = (await getPath()).path;
    dir = "$dir/output";

    String path = "$dir/export" + "_" + DateTime.now().toString() + ".json";
    File file = File(path);

    var dir2check = Directory(dir);

    bool dirExists = await dir2check.exists();
    if (!dirExists) {
      await dir2check.create();
    }

    await file.writeAsBytes(utf8.encode(contents));

    return path;
  }

  static Future<void> importMeasurements(String path) async {
    String contents = File(path).readAsStringSync();

    List<dynamic> map = jsonDecode(contents);

    List<Measurement> result = new List<Measurement>();

    map.forEach((element) {
      result.add(Measurement.fromJson(element));
    });

    await MeasurementService().insertBulk(result);
  }
}
