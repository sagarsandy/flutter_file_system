import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_system/model/DBHelper.dart';
import 'package:flutter_file_system/model/Student.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Storage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Store data in File'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Student>> students;
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  int currentUserId; // Used to determine current updating element for update
  String name;
  int age;
  String bio;
  var dbHelper;
  String terms = 'terms';

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    refreshList();
    getDataFromLocalFile();
  }

  // Once the record is added, we will update the list with following function
  refreshList() {
    setState(() {
      students = dbHelper.getDataFromFile();
    });
  }

  // Once the record is saved in DB, we are clearing text field values
  clearName() {
    nameController.text = '';
    ageController.text = '';
    bioController.text = '';
  }

  // Function to validate input form
  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd – kk:mm:ss').format(now);
      Student stud = Student(formattedDate, name, age, bio);
      dbHelper.saveDataToFile(stud);
      clearName();
      refreshList();
    }
  }

  // List of students with rows and columns widget
  SingleChildScrollView dataTable(List<Student> students) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
            label: Expanded(
              child: Text(
                "NAME",
                textAlign: TextAlign.left,
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                "AGE",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                "BIO",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
        rows: students
            .map(
              (e) => DataRow(
                cells: [
                  DataCell(
                    Text(e.name),
                  ),
                  DataCell(
                    Text(e.age.toString()),
                  ),
                  DataCell(
                    Text(e.bio),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  // Creating list widget
  list() {
    return Expanded(
      child: FutureBuilder(
        future: students,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return dataTable(snapshot.data);
          }

          if (snapshot.data == null || snapshot.data.length == 0) {
            return Text("No data found");
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }

  // Input form widget
  form() {
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
              ),
              validator: (val) => val.length == 0 ? "Enter Name" : null,
              onSaved: (val) => name = val,
            ),
            TextFormField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Age",
              ),
              validator: (val) => val.length == 0 ? "Enter Age" : null,
              onSaved: (val) => age = int.parse(val),
            ),
            TextFormField(
              controller: bioController,
              decoration: InputDecoration(
                labelText: "Bio",
              ),
              validator: (val) => val.length == 0 ? "Enter Bio" : null,
              onSaved: (val) => bio = val,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FlatButton(
                  onPressed: validate,
                  child: Text('ADD'),
                ),
                FlatButton(
                  onPressed: () {
                    clearName();
                  },
                  child: Text('CANCEL'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            Text(terms),
            form(),
            list(),
          ],
        ),
      ),
    );
  }

  // Fetch data from local file mentioned in app folders directory, with in app code folders
  getDataFromLocalFile() async {
    // Load any text from local file
    String termsData = await rootBundle.loadString("data/terms.txt");
    print(termsData);
    if (termsData.isNotEmpty) {
      setState(() {
        terms = termsData;
      });
    }

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
}
