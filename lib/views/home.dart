// ignore_for_file: prefer_const_constructors, unused_import, avoid_unnecessary_containers, avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:recipe_center/models/recipe_model.dart';
import 'package:recipe_center/views/recipe_view.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<RecipeModel> recipes = <RecipeModel>[];
  TextEditingController textEditingController = TextEditingController();

  getRecipes(String query) async {
    String url =
        "https://api.edamam.com/search?q=$query&app_id=450a0be8&app_key=5b8f68e25a2470667dfb73d5d87a9c37";

    var response = await http.get(Uri.parse(url));
    Map<String, dynamic> jsonData = jsonDecode(response.body);

    jsonData["hits"].forEach((element) {
      print(element.toString());

      RecipeModel recipeModel =
          new RecipeModel(image: '', url: '', label: '', source: '');
      recipeModel = RecipeModel.fromMap(element["recipe"]);
      recipes.add(recipeModel);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Color(0xff213A50),
              Color(0xff071930),
            ],
          )),
        ),
        SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: !kIsWeb
                      ? Platform.isIOS
                          ? 60
                          : 24
                      : 24,
                  horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: kIsWeb
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: const [
                        Text(
                          "AppGuy",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Recipes",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]),
                  SizedBox(
                    height: 30,
                  ),
                  Text("What will you cook today?",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: "Overpass",
                      )),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    "Just Enter Ingredients you have and we will show the best recipe for you",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontFamily: "OverpassRegular",
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textEditingController,
                            decoration: InputDecoration(
                              hintText: "Enter Ingredients",
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              hintStyle: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        InkWell(
                          onTap: () {
                            if (textEditingController.text.isNotEmpty) {
                              getRecipes(textEditingController.text);
                              print("just do it");
                            } else {
                              print("just dont do it");
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: LinearGradient(
                                  colors: const [
                                    Color(0xffA2834D),
                                    Color(0xffBC9A5F),
                                  ],
                                )),
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: GridView(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisSpacing: 10.0,
                        // crossAxisCount: 2.0,
                        // crossAxisSpacing: 4.0,
                        // mainAxisSpacing: 4.0,
                      ),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: ClampingScrollPhysics(),
                      children: List.generate(
                        recipes.length,
                        (index) {
                          return RecipieTile(
                            title: recipes[index].label,
                            desc: recipes[index].source,
                            imgUrl: recipes[index].image,
                            url: recipes[index].url,
                          );
                        },
                      ),
                    ),
                  )
                ],
              )),
        ),
      ],
    ));
  }
}

class RecipieTile extends StatefulWidget {
  final String title, desc, imgUrl, url;

  // ignore: use_key_in_widget_constructors
  const RecipieTile(
      {required this.title,
      required this.desc,
      required this.imgUrl,
      required this.url});

  @override
  _RecipieTileState createState() => _RecipieTileState();
}

class _RecipieTileState extends State<RecipieTile> {
  _launchURL(String url) async {
    print(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (kIsWeb) {
              _launchURL(widget.url);
            } else {
              print(widget.url + " this is what we are going to see");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RecipeView(
                            postUrl: widget.url,
                          )));
            }
          },
          child: Container(
            margin: EdgeInsets.all(8),
            child: Stack(
              children: <Widget>[
                Image.network(
                  widget.imgUrl,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: 200,
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: const [Colors.white30, Colors.white],
                          begin: FractionalOffset.centerRight,
                          end: FractionalOffset.centerLeft)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.title,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontFamily: 'Overpass'),
                        ),
                        Text(
                          widget.desc,
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                              fontFamily: 'OverpassRegular'),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
