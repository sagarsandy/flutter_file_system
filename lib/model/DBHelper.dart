import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_file_system/model/Student.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  bool _fileExists = false;
  File _filePath;
  Map<String, dynamic> _json = {};
  String _jsonString;

  static String fileName = 'bingo.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print(path);
    return File('$path/$fileName');
  }

  void saveDataToFile(Student student) async {
    _filePath = await _localFile;
    print(_filePath);

    List<dynamic> studentsData = [];

    _fileExists = await _filePath.exists();
    if (_fileExists) {
      // Fetch existing data
      _json = json.decode(_filePath.readAsStringSync());
      print('Existing Students: $_json');
      studentsData = _json['students'];
    }

    // Add new student
    studentsData.add(student.toMap());

    //Map object to store in file
    Map<String, dynamic> _newJson = {'students': studentsData};
    print('All students after inserting new student: $_newJson');

    // Add data to json object
    _json.addAll(_newJson);

    // Encode json object as string
    _jsonString = jsonEncode(_json);

    // Save json string in file
    _filePath.writeAsString(_jsonString);

    // If we want to append to the data, then we can use
//    _filePath.writeAsString('>>append-this-long-text-string-after-json-object', mode: FileMode.append);
  }

  Future<List<Student>> getDataFromFile() async {
    _filePath = await _localFile;
    print(_filePath);

    _fileExists = await _filePath.exists();

    List<Student> students = [];

    if (_fileExists) {
      try {
        // Fetch existing data
        _jsonString = await _filePath.readAsString();
        print('Json String $_jsonString');

        //Decode json string as json object
        _json = jsonDecode(_jsonString);

        print('Json data is: $_json');

        if (_json['students'].length > 0) {
          for (int i = 0; i < _json['students'].length; i++) {
            students.add(Student.fromMap(_json['students'][i]));
          }
        }

        print(students);
        return students;
      } catch (e) {
        // Exception errors
        print('Something went wrong, the error is: $e');
      }
    }

    return students;
  }
}
