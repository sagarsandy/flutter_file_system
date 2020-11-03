# Flutter: Working with file system

1. Create a file in phone applciation documents directory and store and read data from that file
2. Read data from a file, which is mentioned in project folders

Let's get started:

Note: For better understanding of variables and all, please check DBHelper.dart file

Storing data in application documents directory: 
    
1. Create a file in applciation docs directoy
    
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

2. Store data in that file

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
  
3. Retrieve/fetch Data:
    
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
  
Fetch data from local project directory files

// Fetch data from local file mentioned in app folders directory, with in app code folders
      getDataFromLocalFile() async {
            // Load any text from local file
            String termsData = await rootBundle.loadString("data/terms.txt");
            print(termsData);
        
            // If we want to load json data from local file
            String jsonData = await rootBundle.loadString("data/users.json");
            print('1: $jsonData');
            final jsonResponse = json.decode(jsonData);
            print('2: $jsonResponse');
        
            List<Student> jsonStudents = [];
            if (jsonResponse['students'].length > 0) {
              for (int i = 0; i < jsonResponse['students'].length; i++) {
                jsonStudents.add(Student.fromMap(jsonResponse['students'][i]));
              }
            }
            print('Students Are: $jsonStudents');
      }
        
        
Flutter Info:
## Getting Started

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
