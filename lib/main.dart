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

// 統計

class ThirdPage extends StatefulWidget {
  const ThirdPage({Key? key}) : super(key: key);
  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  List<List<dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://docs.google.com/spreadsheets/d/18O_NzGF_syimk1cXVmdsr_ogfroqalaClWZA7tPJO3I/export?format=csv'));
    final csvString = utf8.decode(response.bodyBytes); // 使用 UTF-8 解碼資料

    List<List<dynamic>> csvData = CsvToListConverter().convert(csvString);
    csvData.removeAt(0);
    // 將資料按照姓名欄位排序
    csvData.sort((a, b) => a[1].toString().compareTo(b[1].toString()));

    setState(() {
      data = csvData;
    });
  }
  @override
  Widget build(BuildContext context) {
    final nameCounts = <String, int>{};
    for (final row in data) {
      final name = row[1].toString();
      nameCounts[name] = (nameCounts[name] ?? 0) + 1;
    }

    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 统计表格
              DataTable(
                columns: [
                  DataColumn(
                    label: Text('訂購人', style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  DataColumn(
                    label: Text('杯數', style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ],
                rows: nameCounts.entries.map((entry) {
                  return DataRow(
                    cells: [
                      DataCell(Text(entry.key)),
                      DataCell(Text(entry.value.toString())),
                    ],
                  );
                }).toList(),
              ),

              SizedBox(height: 20), // 添加间距

              // 数据表格
              DataTable(
                columns: [
                  DataColumn(
                    label: Text('訂購人', style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  DataColumn(
                    label: Text('品項', style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  DataColumn(
                    label: Text('甜度冰塊', style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ],
                rows: List.generate(
                  data.length,
                      (index) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(data[index][1].toString()),
                        ),
                        DataCell(
                          Text(data[index][2].toString()),
                        ),
                        DataCell(
                          Text(data[index][3].toString()),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
