import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeFunction(),
    );
  }
}

class HomeFunction extends StatefulWidget {
  const HomeFunction({Key? key}) : super(key: key);

  @override
  State<HomeFunction> createState() => _HomeFunctionState();
}

class _HomeFunctionState extends State<HomeFunction> {

  TextEditingController _toGetKeyword = TextEditingController(); //used to get keyword from box
  late ScrollController _controller;

  List? data; //there will be saved json string (part which is after keyword data)
  List imagesUrl = []; //all URL's of images are stored in this list

  @override
  void initState() {
     super.initState();

     //_controller could be used to check if the end of loaded gifs is coming and then load new group
     //_controller.position.extentAfter < 300
     //this line could be used for checking.
     //Then there could be different function for this purpose.

     _controller = new ScrollController();
  }

   //This function loads images in cache which would need to make
  //load quicker later; however, it does not help in this case
  @override
  void didChangeDependencies(){
     int i;
     for(i = 0; i < imagesUrl.length; i++){
       precacheImage(NetworkImage(imagesUrl[i]), context);
     }
     super.didChangeDependencies();
  }

  //This function parses json given in the link by adding keyword which client gave
  //puts all json in data list and then goes through each gif's part and gets url from the needed location
  //saves all links in imagesUrl list for later use
   Future<String> fromAPI() async {
     var keyword = _toGetKeyword.text;
     Uri url = Uri.parse('https://api.giphy.com/v1/gifs/search?q=$keyword&api_key=MiRpglUUp0Smi8UeQ4WgbJI9jpS0pRu2&limit=12');
     var jsonData = await http.get(url);
     var fetchData = jsonDecode(jsonData.body);
     setState(() {
       data = fetchData['data'];
       data?.forEach((element) {
         //print("element " + element);
         imagesUrl.add(element['images']['original']['url']); //store in list url
       }
       );
       didChangeDependencies;
     });

     return "Success";
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pictures'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body:
          SingleChildScrollView( //this should make everything scrollable, but for some reason it does
            //fully work. It can be scrolled only if putting mouse on the text fields and buttons area
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _toGetKeyword,
                  decoration: InputDecoration(
                    hintText: "Type keyword",
                    labelText: "Keyword",
                    border: UnderlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  maxLength: 20,
                ),

                ElevatedButton(
                    onPressed: (){
                      print("Keyword " + _toGetKeyword.text); //checking if in console is the right keyword
                      fromAPI(); //calling function above to search for gifs with needed keyword
                    },
                    child: Text("Search")),

                ListView.builder(
                  shrinkWrap: true,
                  itemCount: imagesUrl.length, //for now it is static 12 as I dod not manage to even implement scrolling
                  itemBuilder: (BuildContext context, int index) {
                    return Image.network(
                      imagesUrl[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
          ],
          ),
          ),
    );
  }
}

//Unit testing part
//1) If keyword written is added to link in needed place
//2) If there would be scrolling and loading more gifs actions added ->
//if pictures are loaded at the right moment


//As this was first interaction for me with this language, lot of documentations
//and tutorials were used, but no direct code blocks were copied for better understanding
//For example https://www.youtube.com/watch?v=eWa6iGncZ5Q for testFields and hot to get text from them
//https://www.appsdeveloperblog.com/loading-images-from-a-remote-url-in-flutter/ to get pictures from link and json

//I also tried to work with giphy_picker, but that was a lot easier way as it already had
//search and scroll option included; therefore, I did not consider that to be in expected level