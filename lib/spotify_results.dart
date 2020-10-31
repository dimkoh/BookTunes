import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' as sp;
import 'package:spotify_test/konstants.dart';
import 'package:spotify_test/playback_screen.dart';
import 'package:spotify_test/savespotifylogin.dart';
import 'package:toast/toast.dart';

class SpotifyResultsPage extends StatefulWidget {
  final dynamic data;

  SpotifyResultsPage({this.data});

  @override
  _SpotifyResultsPageState createState() => _SpotifyResultsPageState();
}

class _SpotifyResultsPageState extends State<SpotifyResultsPage> {
  BuildContext _context;
  String _bookName;
  bool _loading;
  String thumbImage;
  Size size;
  dynamic data;
  List<dynamic> tracksList;

  @override
  void initState() {
    super.initState();
    _loading = true;
    data = widget.data;
    _bookName = data['items'][0]['volumeInfo']['title'];

    tracksList = List();
    thumbImage = data['items'][0]['volumeInfo']['imageLinks']['thumbnail'];

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadSpotifyResults();
    });
  }

  _loadSpotifyResults() async {
    Provider.of<GlobalData>(_context, listen: false).thumbImageURL = thumbImage;

    await connectToSpotifyRemote();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    _context = context;
    return SafeArea(
      child: Scaffold(
        backgroundColor: K.bgDarkColor,
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: size.height / 3,
                  width: size.width,
                  child: Image.network(
                    thumbImage,
                    fit: BoxFit.fill,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(32),
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Spotify Results for book",
                        style: TextStyle(
                          fontSize: 14,
                          color: K.lightTextColor,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        _bookName,
                        style: TextStyle(
                          fontSize: 24,
                          color: K.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                _loading
                    ? AlertDialog(
                        content: Row(
                          children: [
                            Container(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    K.bgDarkColor),
                              ),
                            ),
                            SizedBox(width: 16),
                            Text("Loading Spotify Results.."),
                          ],
                        ),
                      )
                    : Flexible(
                        child: Container(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: tracksList.length,
                            itemBuilder: (context, index) {
                              dynamic item = tracksList.elementAt(index);
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => PlaybackScreen(
                                        item: item, index: index),
                                  ));
                                },
                                leading: Icon(
                                  Icons.play_arrow,
                                  color: K.lightTextColor,
                                ),
                                title: Text(
                                  "${item.name}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                subtitle: Text(
                                  "${item.artists[0]?.name}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ],
            ),
            IconButton(
                padding: EdgeInsets.all(16),
                iconSize: 32,
                color: Colors.white,
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        ),
      ),
    );
  }

  Future<void> connectToSpotifyRemote() async {
    try {
      setState(() {
        _loading = true;
      });

      var credentials = sp.SpotifyApiCredentials(
        DotEnv().env['CLIENT_ID'].toString(),
        DotEnv().env['SECRET'].toString(),
      );
      var spotify = sp.SpotifyApi(credentials);

      print("S: $spotify");

      final grant = sp.SpotifyApi.authorizationCodeGrant(credentials);
      print(grant);

      /*  var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: DotEnv().env['CLIENT_ID'].toString(),
          redirectUrl: DotEnv().env['REDIRECT_URL'].toString());*/

      /*  print("Spotify Result : $result");
      setStatus(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');*/

      var search = await spotify.search
          .get(_bookName, types: [sp.SearchType.track])
          .first(5)
          .catchError((err) => print((err as sp.SpotifyException).message));
      if (search == null) {
        return;
      }
      print(search);
      search.forEach((pages) {
        pages.items.forEach((item) {
          /* if (item is sp.PlaylistSimple) {
            print('Playlist::::::::::::::::::: \n'
                'id: ${item.id}\n'
                'name: ${item.name}:\n'
                'collaborative: ${item.collaborative}\n'
                'href: ${item.href}\n'
                'trackslink: ${item.tracksLink.href}\n'
                'owner: ${item.owner}\n'
                'public: ${item.owner}\n'
                'snapshotId: ${item.snapshotId}\n'
                'type: ${item.type}\n'
                'uri: ${item.uri}\n'
                'images: ${item.images.length}\n'
                '-------------------------------');
          }*/
          /* if (item is sp.Artist) {
            print('Artist::::::::::::::::::::::::: \n'
                'id: ${item.id}\n'
                'name: ${item.name}\n'
                'href: ${item.href}\n'
                'type: ${item.type}\n'
                'uri: ${item.uri}\n'
                '-------------------------------');
          }*/
          if (item is sp.TrackSimple) {
            tracksList.add(item);
            print('Track::::::::::::::::::::::::::::::::\n'
                'id: ${item.id}\n'
                'name: ${item.name}\n'
                'href: ${item.href}\n'
                'type: ${item.type}\n'
                'uri: ${item.uri}\n'
                'isPlayable: ${item.isPlayable}\n'
                'artists: ${item.artists.length}\n'
                'discNumber: ${item.discNumber}\n'
                'trackNumber: ${item.trackNumber}\n'
                'explicit: ${item.explicit}\n'
                '-------------------------------');
          }
          /*   if (item is sp.AlbumSimple) {
            print('Album::::::::::::::::::::::::::::::::::::\n'
                'id: ${item.id}\n'
                'name: ${item.name}\n'
                'href: ${item.href}\n'
                'type: ${item.type}\n'
                'uri: ${item.uri}\n'
                'albumType: ${item.albumType}\n'
                'artists: ${item.artists.length}\n'
                'availableMarkets: ${item.availableMarkets.length}\n'
                'images: ${item.images.length}\n'
                'releaseDate: ${item.releaseDate}\n'
                'releaseDatePrecision: ${item.releaseDatePrecision}\n'
                '-------------------------------');
          }*/
        });
      });

      Provider.of<GlobalData>(_context, listen: false).tracksList = tracksList;

      setState(() {
        _loading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _loading = false;
      });
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setState(() {
        _loading = false;
      });
      setStatus('not implemented');
    }
  }

  void setStatus(String code, {String message = ''}) {
    var text = message.isEmpty ? '' : ' : $message';
    Toast.show(text, _context);
  }
}
