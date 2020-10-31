import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_test/konstants.dart';
import 'package:spotify_test/spotify_results.dart';
import 'package:toast/toast.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _isbnNoCtrl;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isbnNoCtrl = TextEditingController();

    _isbnNoCtrl.text = "9780439139601";
    //_isbnNoCtrl.text = "9781603090254";
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: K.bgDarkColor,
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                ),
                Row(
                  children: [
                    Text(
                      "Hello!",
                      style: TextStyle(
                        color: K.lightTextColor,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "What book are you reading?",
                      style: TextStyle(
                        color: K.lightTextColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 64),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: TextField(
                        style: TextStyle(
                          color: K.lightTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                        keyboardType: TextInputType.number,
                        controller: _isbnNoCtrl,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: K.textFieldBgColor,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 64),
                FlatButton(
                  onPressed: () => _navigateToResults(context),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: Text(
                    "Search",
                    style: TextStyle(
                      color: K.bgDarkColor,
                      fontSize: 20,
                    ),
                  ),
                  color: K.lightTextColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToResults(BuildContext context) async {
    if (_isbnNoCtrl.text.isEmpty) {
      Toast.show("Enter Book Number", context);
      return;
    }

    var res = showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              Container(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(K.bgDarkColor),
                ),
              ),
              SizedBox(width: 16),
              Text("Loading Book details.."),
            ],
          ),
        );
      },
    );

    var result = await http.get(
        "https://www.googleapis.com/books/v1/volumes?q=isbn:${_isbnNoCtrl.text}");

    print(result.request.url);
    var json = jsonDecode(result.body);
    try {
      var name = json['items'][0]['volumeInfo']['title'];
      print("Name : $name");
      Navigator.of(context).pop();

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SpotifyResultsPage(data: json),
      ));
    } on NoSuchMethodError catch (e) {
      Toast.show("No Results found!", context, duration: Toast.LENGTH_LONG);
      Navigator.of(context).pop();
    }
  }
}
