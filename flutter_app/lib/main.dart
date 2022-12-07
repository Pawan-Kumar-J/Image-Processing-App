import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
// import 'package:gallery_saver/gallery_saver.dart'

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print("In build of MyApp");
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Pick an image', param_values: {}, params: {}),
      debugShowCheckedModeBanner: false,
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.param_values,required this.params} );


  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final Map param_values, params;
  @override
  State<MyHomePage> createState() => _MyHomePageState(param_values: param_values, params: this.params);
}



class _MyHomePageState extends State<MyHomePage> {
  File? image;
  File? transformed_image;
  Uint8List bytes = Uint8List.fromList([]);
  String operation = "";
  bool flag = false;
  List<String>? list_of_operations = [];
  String url_base =  "http://192.168.10.5:5000/"; // http://10.0.2.2:5000 to run on emulator (change port accordingly),to run on real device copy link in logs.txt in API folder (after running the app)
  Map params = {}, param_values = {};
  String appDir = "";


  _MyHomePageState({required this.param_values, required this.params});

  Widget customButton({
    required String title,
    required VoidCallback onClick,
    required IconData icon,
    required double width
  }){
    return Container(
        width: width,
        child: ElevatedButton(
            onPressed: onClick,
            child: Row(
              children: [
                Icon(icon),
                SizedBox(width: 20,),
                Text(title)
              ],
            )
        )
    );
  }

  Future getImage(ImageSource source) async
  {
    final img = await ImagePicker().pickImage(source:source).then((img) {
      if (img == null) {
        print("null");
        return;
      }
      final imgTemp = File(img.path);
      print("Runtime type");
      print(imgTemp.runtimeType);

      setState(() {
        this.image = imgTemp;
        this.bytes = Uint8List.fromList([]);
        this.flag = false;
      });
    }
    );
  }
  void save({required Uint8List bytes}){
    String dt = DateTime.now().toString().replaceAll("-", "").replaceAll(":", "").replaceAll(".", "");
    String? path =  "/storage/emulated/0/Download/${dt}.jpeg";

    File(path).writeAsBytes(bytes);
    ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text("File save at ${path}")));
  }

  Future transform({required String url,
    required String operation}) async
  {
    if(this.operation == ""){
      ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text("Please select a operation to be performed")));
      return;
    }
    print(this.param_values);
    // print(image.runtimeType);
    // print(image!.path);
    // print(image!.readAsBytes().asStream());
    var req = http.MultipartRequest("POST",Uri.parse(url));
    req.fields["operation"] =this.operation;
    Map<String, String> temp = {};
    for(var i in this.param_values.entries){
      if(i.value != ""){
        temp[i.key.toString()] = i.value.toString();
      }
    }
    print("temp : ${temp}");
    req.fields.addEntries(temp.entries);
    print(image!.runtimeType);
    req.files.add(http.MultipartFile("img",
        image!.readAsBytes().asStream(),
        image!.lengthSync(),
        filename: p.basename(image!.path),
        contentType: MediaType('image','jpeg')
    ));

    final response = await req.send();
    await http.Response.fromStream(response).then((res) async
    {
      // print(res);
      // print(response.statusCode);
      // print(response.runtimeType);
      // print(response.stream.runtimeType);
      // print(res.statusCode);
      // print(Image.memory(res.bodyBytes).runtimeType);
      await getApplicationDocumentsDirectory().then( (appDocDirectory) async
      {
        setState(() {
          this.flag = true;
          this.bytes = res.bodyBytes;
        }
        );
        // await File("/storage/emulated/0/Download/Output.jpeg").writeAsBytes(bytes).then((file)
        // {
        //
        //   setState(()
        //   {
        //     print("hello");
        //     this.transformed_image = file;
        //   }
        //   );
        // }

        // );
      }
      );
    }
    );
    return;
  }
  void setTransformedAsInput(){
    setState(() {
      this.image = this.transformed_image;
    }
      );
  }
  void getOperations(){
    List<String>? alist = [];
    http.get(Uri.parse("${url_base}operations")).then(
            (operations) {
              // print(operations.body);
          alist = json.decode(operations.body).cast<String>();
          setState(() {
            this.list_of_operations = alist;
          });

        }
    );
    return;
  }

  void getParams({required String operation})
  {
    // this.params = {};
    this.param_values = {};
    http.get(Uri.parse("${url_base}params/${operation}")).then(
            (res) {
          setState(() {
            this.params = jsonDecode(res.body);
            for(var key in this.params.keys){
              this.param_values[key] = null;
            }
          }
          );
          return;
        }
    );
  }

  // Future transform({required String url, String operation = "Erosion"}) async
  // {
  //   final response = await http.get(Uri.parse(url));
  //   print(response.statusCode);
  //   print(response.body);
  //   print(response.body.runtimeType);
  //   return;
  // }

  @override
  void initState() {

    getApplicationDocumentsDirectory().then((directory) {
      this.appDir = directory.path;


      try {
        File("${this.appDir}/Operation.txt").readAsString().then((value) {
          this.operation = value;
        });
      } catch (e) {
        print("Not successful");
      };
      try {
        File("${this.appDir}/Image.txt").readAsString().then((
            value) {
          this.image = File(value);
        });
      } catch (e) {
        print("Error in image");
      }
    });
    super.initState();
    getOperations();
    // setState(() {
    //
    // // });

  }

  @override
  Widget build(BuildContext context) {
    // getOperations();
    if(!this.list_of_operations!.contains("")) {
      this.list_of_operations!.add("");
    }
    // print(this.list_of_operations);
    print("App dir : ${this.appDir}");
    // print()
    // print(this.param_values);
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(

        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20,),
            this.image == null ? Image.network("https://picsum.photos/250?image=9", height: 200, width: 600,) : Image(image: FileImage(this.image!)..evict(), height: 200, width: 800,),
            SizedBox(height: 20),
            Row( mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Spacer(),
                  customButton(title: "Capture Image", icon: Icons.camera, onClick: () => getImage(ImageSource.camera), width: 175),
                  Spacer(),
                  customButton(title: "Pick from Gallery", icon: Icons.image_outlined, onClick:() => getImage(ImageSource.gallery), width: 200),
                  Spacer(),

                ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    alignment: Alignment.centerRight,

                    width: 175,
                    decoration: BoxDecoration(color: Colors.blue),
                    child: DropdownButton(items: list_of_operations!.map(
                            (String items) {
                          return DropdownMenuItem(child: Text(items), value: items,);
                        }
                    ).toList(),
                        value: this.operation,
                        icon: const Icon(Icons.change_circle, color: Colors.white,),
                        isExpanded: true,
                        menuMaxHeight: 200,
                        dropdownColor: Colors.lightBlueAccent,
                        elevation: 100,
                        style: TextStyle(color: Colors.white, fontSize: 16,),
                        onChanged: (String? newValue) {
                          setState(() {
                            this.operation = newValue!;
                            // print(newValue);
                            getParams(operation: this.operation);
                          }

                          );

                        }
                    )
                ),
                SizedBox(width: 10,),
                customButton(title: "Set Parameters", onClick: () => {
                  getApplicationDocumentsDirectory().then((directory)  {
                    this.appDir = directory.path;
                    print("Appdirectory : ${this.appDir}");
                    File("${this.appDir}/Operation.txt").writeAsString(this.operation);
                    if(this.image != null) {
                      File("${this.appDir}/Image.txt").writeAsString(this.image!.path);
                    }
                    if (this.operation == "") {
                      ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                          content: Text("Please select an operation")));
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            MyParams(params: this.params,)),
                      );
                    }
                  })}, icon: Icons.settings, width: 200)

              ],


            ),
            SizedBox(height: 20),
            image == null ? SizedBox(height: 20) : customButton(title: "Transform", icon: Icons.transform, onClick: () => transform(url: "${url_base}process", operation: this.operation), width: 200),
            flag ? Image.memory(bytes, height: 200, width: 600,) : SizedBox(height: 20,),
            flag ? customButton(title: "Save to Downloads", onClick: () => save(bytes: this.bytes), icon: Icons.save, width: 200) : SizedBox(height: 20)
            // flag ? customButton(title: "Set as New Input", icon: Icons.arrow_upward, onClick: () => setTransformedAsInput(), width: 250) : SizedBox(height: 10,),

          ],
        ),
      )
      ,
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
class MyParams extends StatefulWidget{
  Map params = {};
  String operation = "";
  MyParams({required this.params});
  @override
  _MyParamsState createState() => _MyParamsState(params: this.params);
}

class _MyParamsState extends State<MyParams> {
  Map params = {};
  Map param_values = {};

  final String url_base =   "http://192.168.10.5:5000/"; // http://10.0.2.2:5000 to run on emulator (change port accordingly), to run on real device copy link in logs.txt in API folder after running the app
  String operation = "";
  _MyParamsState({required this.params});
  Widget customButton({
    required String title,
    required VoidCallback onClick,
    required IconData icon,
    required double width
  })
  {
    return Container(
        width: width,
        child: ElevatedButton(
            onPressed: onClick,
            child: Row(
              children: [
                Icon(icon),
                SizedBox(width: 20,),
                Text(title),
              ],
            )
        )
    );
  }




  void getParams({required String operation})
  {

    http.get(Uri.parse("${url_base}params/${operation}")).then(
            (res) {
              setState(() {
                this.params = jsonDecode(res.body);
                for(var key in this.params.keys){
                  // this.param_values[key] = null;
                }
              }
              );
          return;
        }
    );
  }
List<Widget> getWidget({
  required String name,required String dtype}) {
  if(dtype != "array") {
    return <Widget>[
      SizedBox(width: 100,
          child: Text(name.toString(), style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold),)),
      SizedBox(width: 5,),
      SizedBox( // <-- SEE HERE
        width: 200,
        child: TextField(
          onChanged: (text) => {
            setState(() {
              this.param_values[name] = text;
              print(param_values);
            }
            )
          },
          decoration: InputDecoration(
            labelText: "${name}",
            border: OutlineInputBorder(),
          ),
        ),
      ),
    ];
  }
  else{
    // final size = this.params.keys.contains("kernel_size") ? this.param_values["kernel_size"] : null
    // if(size == null){
    //   setState(() {
    //   this.param_values["kernel_size"];
    //   });
    // }

    return <Widget>[
      SizedBox(width: 100,
          child: Text(name.toString(), style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold),)),
      SizedBox(width: 5,),
      Column(children: <Widget>[
        SizedBox(
        width: 200,
        child: TextField(
          onChanged: (text) => {
          setState(() {
          this.param_values[name] = text;
          }
          )
          },
          decoration: InputDecoration(
            labelText: "${name}",
            border: OutlineInputBorder(),
          ),
        ),
      ),
      ]
      )
    ];

  }
}
void verifyAndSaveParams(){

    print(this.param_values);
    for (var map in this.params.entries)
      {
        if(this.param_values[map.key] == null || this.param_values[map.key] == "") {
          print("Is null");
          continue;
        }
        switch(map.value){
          case "int" :
            {

              try {
                // print("asdfasdf");
                // print(int.parse(param_values[map.key]));
                int.parse(this.param_values[map.key]);
                if(int.parse(this.param_values[map.key]) <= 0){
                  ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text("${map.key} must be a natural number")));
                  param_values[map.key] == null;
                  return;
                }
              } catch (e) {
                ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text("${map.key} must be natural number")));
                this.param_values[map.key] == null;
                // print("Wrong input");
                return;
              }
            }break;
            // break;
          case "float":
            {
              try{
                double.parse(param_values[map.key]);
                if(double.parse(param_values[map.key]) <= 0.0){
                  ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text("${map.key} must be a non-zero positive real number")));
                  param_values[map.key] == null;
                  return;
                }
              } catch(e){
                ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text("${map.key} must be real number")));
                param_values[map.key] == null;
                return;
              }
            }break;

        }


      }
    for(var key in params.keys) {
      if(!(param_values.keys.contains(key))) {
        this.param_values[key] = "";
      }
    }
    print(this.param_values);
    Navigator.push(context,MaterialPageRoute(builder: (context) => MyHomePage(title: "Select an Image", param_values: this.param_values, params: this.params,)));
}

  @override
  Widget build(BuildContext context)
  {
    // getParams(operation: this.operation);
    final len = this.params.length;

    return Scaffold(
      appBar: AppBar(
        title: Text("Select Parameters"),
      ),
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // for (var i = 0; i < len/2; i++) Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[for (var j = 0; j < 2; j++) customButton(title: i.toString(), onClick: () => {}, icon: Icons.abc, width: 150)]),
          for (var i in params.entries) Row(mainAxisAlignment: MainAxisAlignment.center, children: getWidget(name: i.key,dtype: i.value)),
          customButton(title: "Save", onClick: () => {verifyAndSaveParams()}, icon: Icons.save, width: 200),
          SizedBox(),
          // Text("${this.params.runtimeType}"),
          // Text("${this.param_values.values}")
      ],
    ),
    ),

    );
  }
}
