import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:gsheets/gsheets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Spreadsheet Demo',
      theme: ThemeData(primarySwatch: Colors.blue,),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('飲料訂購', style: TextStyle(color: Colors.purple)),
        centerTitle: true,
        backgroundColor: Colors.orange[50],),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
                labelStyle: TextStyle(fontWeight: FontWeight.w700),
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.black,
                isScrollable: true,
                tabs: [
                  Tab(text: '查看表單'),
                  Tab(text: 'GAS'),
                  Tab(text: '統計'),
                ]),
            Expanded(child: TabBarView(
              children: [
                FirstPage(),
                SecondPage(),
                ThirdPage(),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

// Use http api

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);
  @override
  State<FirstPage> createState() => FirstPageState();
}

class FirstPageState extends State<FirstPage> {

  final nameController=TextEditingController();
  final ageController=TextEditingController();
  final salaryController=TextEditingController();
  String exportURL="https://docs.google.com/spreadsheets/d/18O_NzGF_syimk1cXVmdsr_ogfroqalaClWZA7tPJO3I/export?format=csv";

  Future<void> getData1(String url) async {
    var result=await http.get(Uri.parse(url));
    if (result.statusCode==200) {}
  }

  List<List<dynamic>> csv_data=[[0,0,0]];

  Future<void> getCSV(String url) async {
    var result=await http.get(Uri.parse(url));
    var x=Utf8Decoder().convert(result.bodyBytes);
    CsvToListConverter converter=CsvToListConverter(eol: '\r\n', fieldDelimiter: ',');
    List<List<dynamic>> listData=CsvToListConverter().convert(Utf8Decoder().convert(result.bodyBytes));
    csv_data=listData;
    setState(() {
      csv_data=listData;
    });
  }

  @override
  void initState() {
    super.initState();
    getCSV(exportURL);
  }

  Widget padding1(TextEditingController t, String inputVar, Size size) {
    return Padding(
        padding: EdgeInsets.all(8),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: size.width * 0.8,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(30),),
          child: TextField(
            cursorColor: Colors.black,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: IconButton(
                icon: Icon(Icons.email_outlined),
                color: Colors.grey,
                onPressed: () {},),
              hintText: inputVar,
              hintStyle: TextStyle(color: Colors.grey),
            ),
            style: TextStyle(color: Colors.black),
            controller: t,
          ),
        ));
  }


  @override
  Widget build(BuildContext context) {
    final formKey=GlobalKey<FormState>();
    Size size=MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.red,),
        onPressed: () {
          showDialog(context: context,
              builder: (context) {
                return AlertDialog(
                  content: Stack(
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            padding1(nameController, '訂購人', size),
                            padding1(ageController, '品項', size),
                            padding1(salaryController, '甜度冰塊', size),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: ElevatedButton(
                                child: Text('送出'),
                                onPressed: () {
                                  //print('${nameController.text}, ${ageController.text}, ${salaryController.text}');
                                  String url1="https://docs.google.com/forms/d/1mnrCK4tEjANvLFUgSROI5WhdNcgJbyyF_yTA0ceuils/formResponse?" + "entry.1440591498=" + nameController.text + "&entry.205811761=" + ageController.text + "&entry.1556362491=" + salaryController.text;
                                  getData1(url1);
                                  const snackBar1=SnackBar(content: Text('資料已寫入!'));
                                  getCSV(exportURL);
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar1);
                                  Navigator.of(context).pop();
                                },
                              ),),
                          ],
                        ),),
                    ],
                  ),
                );
              });
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height:30),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(20),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.all(width: 1,
                  borderRadius: BorderRadius.circular(20),),
                children:
                csv_data.map((item){
                  return TableRow(children: item.map((row) {
                    return Container(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(row.toString(), textAlign: TextAlign.center,),),);
                  }).toList());
                }).toList(),),
            ),
          ],
        ),
      ),
    );
  }
}

// Use Google Apps Script
class User {
  String? name;
  String? age;
  String? salary;

  User({
    this.name,
    this.age,
    this.salary,
  });

  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      age: json['age'],
      salary: json['salary'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': this.name,
    'age': this.age,
    'salary': this.salary,
  };
}

String scriptURL="https://script.google.com/macros/s/AKfycbyyi03AZ4lTIeBu0PpEp4Dt6VhA0ui4fuLx0lkux77NuaLgJTbiriBkGt-01oWrL8ybZw/exec";

Widget UserList(List<User> UserList) {
  return ListView.builder(
      itemCount: UserList.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 5,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("訂購人: "+UserList[index].name!, style: TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 25),),
                Container(
                  child: Text("品項: "+UserList[index].age!, style: TextStyle(color: Colors.grey),),
                ),
                Container(
                  child: Text("甜度冰塊: "+UserList[index].salary!, style: TextStyle(color: Colors.grey),),),
              ],
            ),
          ),
        );
      });
}

List<User> decodeUser(String responseBody) {
  final parsed=jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<User>((json)=>User.fromMap(json)).toList();
}

Future<List<User>> fetchUser() async {
  final response=await http.get(Uri.parse(scriptURL));
  if (response.statusCode==200) {
    return decodeUser(response.body);
  }
  else {
    throw Exception('無法取得資料!');
  }
}

Future<void> addUser(User user) async {
  final response=await http.post(Uri.parse("https://script.google.com/macros/s/AKfycbyyi03AZ4lTIeBu0PpEp4Dt6VhA0ui4fuLx0lkux77NuaLgJTbiriBkGt-01oWrL8ybZw/exec"), body: user.toJson());
}

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);
  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {

  final nameController=TextEditingController();
  final ageController=TextEditingController();
  final salaryController=TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Widget padding1(TextEditingController t, String inputVar, Size size) {
    return Padding(
        padding: EdgeInsets.all(8),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: size.width * 0.8,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(30),),
          child: TextField(
            cursorColor: Colors.black,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: IconButton(
                icon: Icon(Icons.email_outlined),
                color: Colors.grey,
                onPressed: () {},),
              hintText: inputVar,
              hintStyle: TextStyle(color: Colors.grey),
            ),
            style: TextStyle(color: Colors.black),
            controller: t,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final formKey=GlobalKey<FormState>();
    Size size=MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.red,),
        onPressed: () {
          showDialog(context: context,
              builder: (context) {
                return AlertDialog(
                  content: Stack(
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            padding1(nameController, '訂購人', size),
                            padding1(ageController, '品項', size),
                            padding1(salaryController, '甜度冰塊', size),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: ElevatedButton(
                                child: Text('送出'),
                                onPressed: () {
                                  //print('${nameController.text}, ${ageController.text}, ${salaryController.text}');
                                  User user0=User(name: nameController.text,
                                    age: ageController.text,
                                    salary: salaryController.text,);
                                  addUser(user0);

                                  const snackBar1=SnackBar(content: Text('資料已寫入!'));
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar1);
                                  Navigator.of(context).pop();
                                },
                              ),),
                          ],
                        ),),
                    ],
                  ),
                );
              });
        },
      ),
      body: Center(
        child: FutureBuilder<List<User>>(
          future: fetchUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) print(snapshot.error);
            return snapshot.hasData? UserList(snapshot.data!):Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

// Use Gsheets package

class ThirdPage extends StatefulWidget {
  const ThirdPage({Key? key}) : super(key: key);
  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {

  final nameController=TextEditingController();
  final ageController=TextEditingController();
  final salaryController=TextEditingController();
  var gs1, ss, sheet, totalRows, currentRow;
  List<List<dynamic>> csv_data1=[['0','0','0']];

  static const credentials= {
  "type": "service_account",
  "project_id": "marine-cycle-389912",
  "private_key_id": "387d45886078d3c1d9aaf1a567c5166a27544138",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDTrX2OIcVp0hdv\n3s9eccECwj+KVUoxDe0o+22SwCmBixMB5lytzL8Wk2JVUTKVrdXBFkEUxPM3keLv\ncw5D2YYQ33lDA4O432oY14BNOCwq5eUOczubKKZkV9NcvqLdwKGzGRfQz9c6EkXF\n5in6/OOENwaq+ivn4QVWjj4GpBmAinWOmwDJR+lxSDy0T6r7nm2vKr6cbtFWTRpj\n4Id98KXTcJwqqW46K1cOcPG7MReOWfJvPvYq8uvKxjkImz+12/StuYSNTVhaM+8y\n/OPlQ1hIcAU7aevMCVDjEyz8Y+qI9yU8gaWK+u7o6sRfGc2fCLaKCT5luP1izQ1Y\nx/yZYPkPAgMBAAECggEAKRqJRO493VyUfH6xmc9RAW4i1IPXUks4ADtCfbqe1K7i\n0/2dhYo6mPGpqJOJ1RLabRIbNSNBb0r+3CxlWruEkwYyD9dA3sdTXNuL6HK98N6P\nagzqSCjOlrGPM3U5PwJG4/Y9b6jMTFR8A/+7qycsLuJYgx7tI6vIU5Rvau62nQTr\nMmZ/bP5ho4YpeUrTvUU9vdZTWberfCk6SKiw7GaMU2r8lHmL/BFZc3W/9JB3seWL\nSuSOF4S23EkLYlMVJ0tgc5oo2hTVE6r3FdvpFxt4JRsweT/zxZLBvQ9Uqmg1E0/w\nxocGQqx8Bbw058OJqbq0ZZkAypxVmfiuxBOSf8ijIQKBgQD9Bya35wq9essY90uo\nyE/Y/zrvVM/gAOKzTPfwF+WJqYhR3DGriCJbhJK4ONn1DzXCEs5EjHgmsgSvBjuQ\n68LbjpvvLaLLRXWq7AfiAoYvxjcIm6nAvz7/bnzhMkV/17euxcXtJrDz1H6HjKg7\nFNN6aRTJ9G8nkmiT9GT6spHAiQKBgQDWKgAEGKMmDPFPru2eV1XsSspo4w8gkfOL\n8d/9cl1946zTl0lIWxsYz8SmApfnbYjoS7TeRphp6NdFdzMn4cjMigqf8zSbJwIL\nIVwaup2hhEmxGT6ZQa9/NBzrelw5dRRpf96/PMP+AyiNsK35G4VLkmxCez5TDUyF\nXb3XTuiW1wKBgCnuvnbpvjjqma/4g7xj/f+bRLwXFSAtZWSLk+dhPnQS+Xl/gWfI\n9tCt5tbK7SwUqjcQgMiRcvQOuoH7CXIZ8EAMoUEBEiKXz0lVNnU5L93I/qPZkEdW\nKm2QdPepKiVmrZU0R3nm2JqAE7wJDnREHkwCECTr8mPfep9SeE2nvEnpAoGAENX8\nalYFfVhHIByAUZJMDudSQiyXY9gVbUr2cNYsw1jCnV+nQyjmWGz86JALoQXbXWeW\nMGMcWDcVtUBJpTj6sBmp/CkCWbAXWQimVPOWsLvVjzaM1T90rGtMWrajyWCK2kBT\nInWEctOMvJbHFm4zbF12ZUOLArxo55MW+XYaksECgYAV5Zkd4Y3/V/JuvkVu8WQ6\nXz1NDjBiAUKf+306riRu7cxWiPuqSN8uG9IZb7ucmR1yOCjwpn+SJ6ZECVwQBFuR\nIiQITSQSpeOmZF7/vbcEW4xWMXGrx/T7YFEv8Z6eXcTXnF7ZCSfK3KRTZIN0wIN7\nLxiAjwl0x6GCVtoHul+tqg==\n-----END PRIVATE KEY-----\n",
  "client_email": "service-account@marine-cycle-389912.iam.gserviceaccount.com",
  "client_id": "107935403612371934682",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/service-account%40marine-cycle-389912.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
};
  static const spreadSheetId='18O_NzGF_syimk1cXVmdsr_ogfroqalaClWZA7tPJO3I';

  Future<void> getData1(String url1) async {
    var result=await http.get(Uri.parse(url1));
    if (result.statusCode==200) {}
  }

  GSsetup() async {
    final gs1=GSheets(credentials);
    final ss=await gs1.spreadsheet(spreadSheetId);
    sheet=ss.worksheetByTitle('sheet2');
    var rows1=await sheet.values.map.allRows();
    totalRows=rows1.length;
    currentRow=totalRows+1;
  }

  //新增資料
  uploadData(t,a,b,c) async {
    GSsetup();
    currentRow=currentRow+1;
    await sheet.values.insertValue(t, column: 1, row: currentRow);
    await sheet.values.insertValue(a, column: 2, row: currentRow);
    await sheet.values.insertValue(b, column: 3, row: currentRow);
    await sheet.values.insertValue(c, column: 4, row: currentRow);
  }

  loadData() async {
    final gs1=GSheets(credentials);
    final ss=await gs1.spreadsheet(spreadSheetId);
    sheet=ss.worksheetByTitle('sheet2');
    var rows1=await sheet.values.map.allRows();
    if (rows1!=null) {
      totalRows=rows1.length;
      currentRow=totalRows+1;
      var rowData;
      csv_data1.clear();
      for (var k=1; k<=totalRows+1; k++) {
        rowData=await sheet.values.row(k);
        csv_data1.add(rowData);
        setState(() {});
      }
    }
  }

  Widget padding1(TextEditingController t, String inputVar, Size size) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        width: size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          cursorColor: Colors.black,
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: IconButton(
              onPressed: () {},
              icon: Icon(Icons.email_outlined),
              color: Colors.grey,
            ),
            hintText: inputVar,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: TextStyle(color: Colors.black),
          controller: t,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final formKey=GlobalKey<FormState>();
    Size size=MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.red),
        onPressed: () {
          showDialog(context: context,
              builder: (context) {
                return AlertDialog(
                  content: Stack(
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            padding1(nameController, '訂購人', size),
                            padding1(ageController, '品項', size),
                            padding1(salaryController, '甜度冰塊', size),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: ElevatedButton(
                                child: Text('送出'),
                                onPressed: () {
                                  //print('${nameController.text}, ${ageController.text}, ${salaryController.text}');
                                  String date=DateFormat("yyyy/MM/dd a h:m:s").format(DateTime.now());
                                  sheet.values.appendRow([date, nameController.text, ageController.text, salaryController.text]);
                                  const snackBar1=SnackBar(content: Text('資料已寫入!'));
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar1);
                                  Navigator.of(context).pop();
                                },
                              ),),
                          ],
                        ),),
                    ],
                  ),
                );
              });
        },
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height:30),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(20),
              child:
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.all(width: 1,
                  borderRadius: BorderRadius.circular(20),),
                children: csv_data1.map((item) {
                  return TableRow(children: item.map((row) {
                    return Container(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(row.toString(),
                          textAlign: TextAlign.center,),
                      ),
                    );
                  }).toList());
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
