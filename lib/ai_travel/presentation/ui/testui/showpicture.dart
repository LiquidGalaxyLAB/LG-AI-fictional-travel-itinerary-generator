import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class showPicture extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Picture'),
      ),
      body: Center(
        child: Image.network("https://places.googleapis.com/v1/places/ChIJe4IR9Z8oQg0RrqMktRYnbJ4/photos/AelY_Cv7IKlxI55Zct5wa3uunKNY6D0dtN5aDu7WBJq4kehLhA9B1NpndbbjTgXXHMnltv-aqOuCxepz8hOR8owZW3suQP34F7ZF47HGFaYWOyX2NFlt0tuwCyJUlo1X2tR5gT9rB33_YA0ed-o-jVC_n62XsXJDC9OSN0DO/media?maxHeightPx=400&maxWidthPx=400&key=AIzaSyDZ9xpCY1-z6OGRLKBaCZ37RyJj9A2x8TI"),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: showPicture(),
  ));
}