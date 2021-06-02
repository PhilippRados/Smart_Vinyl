import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:popup_card/popup_card.dart';
import 'album.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tuple/tuple.dart';

void main() {
  runApp(MyApp());
}

List<Album> records = [
  Album(
      cover:
          "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fupload.wikimedia.org%2Fwikipedia%2Fen%2Fthumb%2Fe%2Fe8%2FModerat_cover1.jpg%2F220px-Moderat_cover1.jpg&f=1&nofb=1",
      album_name: "Moderat",
      artist: "Uwe Wöllner",
      mbid: "jkfhadjsk"),
  Album(
      cover:
          "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fupload.wikimedia.org%2Fwikipedia%2Fen%2Fthumb%2Fe%2Fe8%2FModerat_cover1.jpg%2F220px-Moderat_cover1.jpg&f=1&nofb=1",
      album_name: "Moderat",
      artist: "Moderat_Band",
      mbid: "uziew"),
];

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xff1D2732),
          body: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Your Records",
                    style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Color(0xffF6F8F8)),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ListView.builder(
                        itemExtent: 75,
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AlbumInfo()));
                            },
                            title: Text(
                              records[index].album_name,
                              style: TextStyle(
                                  color: Color(0xffE9EDF1),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(records[index].artist,
                                style: TextStyle(
                                  color: Color(0xffE9EDF1),
                                )),
                            leading: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18)),
                              child: Image.network(records[index].cover,
                                  fit: BoxFit.cover, width: 75, height: 75),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                setState(() {
                                  records.removeAt(index);
                                });
                              },
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          );
                        },
                        key: UniqueKey(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: PopupItemLauncher(
            child: Container(
              color: Color(0xffDC4250),
              width: 60,
              height: 60,
              child: Icon(
                Icons.library_add,
                color: Colors.white,
                size: 26,
              ),
            ),
            tag: "test",
            popUp: PopUpItem(
              child: PopUpItemBody(),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              tag: "test",
              elevation: 2,
              padding: EdgeInsets.all(8),
            ),
          ),
        ),
      ),
    );
  }
}

class Album {
  const Album(
      {required this.cover,
      required this.album_name,
      required this.artist,
      required this.mbid});
  final String cover;
  final String album_name;
  final String artist;
  final String mbid;
}

class PopUpItemBody extends StatefulWidget {
  @override
  _PopUpItemBodyState createState() => _PopUpItemBodyState();
}

class _PopUpItemBodyState extends State<PopUpItemBody> {
  final _searchController = TextEditingController();
  String search_query = "";
  List<Tuple2<dynamic, dynamic>> list_view_albums = [];
  bool empty = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      color: Colors.white,
      height: 550,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_downward)),
          Row(
            children: [
              Container(
                width: 305,
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    search_query = query;
                  },
                  decoration: InputDecoration(
                    hintText: "Artist:Album",
                  ),
                  style: TextStyle(fontSize: 18),
                ),
              ),
              IconButton(
                onPressed: () async {
                  setState(() {
                    list_view_albums.clear();
                  });
                  List<String> cover_list = [];
                  List<dynamic> responded_albums =
                      await musicBrainzRequest(search_query);

                  for (int i = 0; i < responded_albums.length; i++) {
                    dynamic cover =
                        await coverRequest(responded_albums[i]["id"]);
                    if (cover != null) {
                      cover_list.add(cover);
                    } else {
                      cover_list.add(
                          "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse4.mm.bing.net%2Fth%3Fid%3DOIP.dcLjdUq0P5z9MgVUDQgMSgHaHa%26pid%3DApi&f=1");
                    }
                  }

                  setState(() {
                    if (responded_albums.length != 0) {
                      empty = false;
                      for (int i = 0; i < responded_albums.length; i++) {
                        list_view_albums
                            .add(Tuple2(responded_albums[i], cover_list[i]));
                      }
                    } else {
                      empty = true;
                    }
                  });
                },
                icon: Icon(
                  Icons.search,
                  size: 30,
                ),
              )
            ],
          ),
          Container(
            width: 1000,
            height: 450,
            child: empty
                ? Container(
                    alignment: Alignment.center,
                    child: Text(
                      "Nothing found",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : Container(
                    height: 300,
                    child: ListView.builder(
                        itemExtent: 80,
                        itemCount: list_view_albums.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Container(
                              width: 70,
                              height: 70,
                              child: Image.network(
                                list_view_albums[index].item2,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            title: Text(
                              list_view_albums[index].item1["release-group"]
                                  ["title"],
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800),
                            ),
                            subtitle: Text(
                              list_view_albums[index].item1["artist-credit"][0]
                                  ["name"],
                              style: TextStyle(
                                color: Colors.black, //Color(0xff35393D),
                                fontSize: 12,
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                setState(() {
                                  records.add(
                                    Album(
                                        artist: list_view_albums[index]
                                            .item1["artist-credit"][0]["name"],
                                        album_name: list_view_albums[index]
                                            .item1["release-group"]["title"],
                                        mbid:
                                            list_view_albums[index].item1["id"],
                                        cover: list_view_albums[index].item2),
                                  );
                                });
                                print(records);
                              },
                              icon: Icon(
                                Icons.add,
                                color: Color(0xff35393D),
                                size: 28,
                              ),
                            ),
                          );
                        }),
                  ),
          ),
        ],
      ),
    );
  }
}

Future coverRequest(String mbid) async {
  print(mbid);
  dynamic image_url;
  http.Response json_response = await http
      .get(Uri.parse("http://coverartarchive.org/release/$mbid?fmt=json"));

  if (json_response.statusCode == 200) {
    final decoded_json = json.decode(json_response.body);
    image_url = decoded_json["images"][0]["image"];
  } else {
    print("Failed to connect to Cover-api");
    image_url = null;
  }
  return image_url;
}

Future musicBrainzRequest(String search_query) async {
  List<dynamic> responded_albums = [];
  List<String> info_query = search_query.split(":");
  String artist_name = info_query[0].replaceAll(" ", "%20");
  String album_name = info_query[1].replaceAll(" ", "%20");

  http.Response json_response = await http.get(Uri.parse(
      "https://musicbrainz.org/ws/2/release?query=title%3A%22$album_name%22%20AND%20artist%3A%22$artist_name%22%20AND%20(format%3A%227%5C%22%20vinyl%22%20OR%20format%3A%2210%5C%22%20vinyl%22%20OR%20format%3A%2212%5C%22%20vinyl%22)&fmt=json"));

  if (json_response.statusCode == 200) {
    final decoded_response = json.decode(json_response.body);
    final response_len = decoded_response["releases"].length;

    for (int i = 0; i < response_len; i++) {
      if (decoded_response["releases"][i]["media"][0]["format"] != null &&
          decoded_response["releases"][i]["media"][0]["format"]
              .contains("Vinyl") &&
          decoded_response["releases"][i]["release-group"]["primary-type"] ==
              "Album") {
        responded_albums.add(decoded_response["releases"][i]);
        print(decoded_response["releases"][i]["media"][0]["format"]);
      }
    }
  } else {
    print("Failed to connect to album-api");
  }
  return responded_albums;
}
