import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_test/konstants.dart';
import 'package:spotify_test/savespotifylogin.dart';
import 'package:toast/toast.dart';

class PlaybackScreen extends StatefulWidget {
  final item;
  final index;

  PlaybackScreen({this.item, this.index});

  @override
  _PlaybackScreenState createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  Size size;
  BuildContext _context;
  bool isPlaying;
  bool _loading;
  dynamic _currentItem;
  String _thumbNail;
  int _currentIndex;
  List list;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    isPlaying = false;
    _loading = true;
    _currentItem = widget.item;
    _thumbNail = "https://picsum.photos/200/300/?blur";
    print(_currentItem);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadRemoteSpotifySdk();
    });
  }

  _loadRemoteSpotifySdk() async {
    setState(() {
      _thumbNail =
          Provider.of<GlobalData>(_context, listen: false).thumbImageURL;
    });

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
              Text("Connecting to Spotify.."),
            ],
          ),
        );
      },
    );

    var result = await SpotifySdk.connectToSpotifyRemote(
        clientId: DotEnv().env['CLIENT_ID'].toString(),
        redirectUrl: DotEnv().env['REDIRECT_URL'].toString());

    print("Spotify Result : $result");
    if (result) {
      Toast.show("Connected to SPOTIFY", _context);
      Navigator.of(context).pop();
      print("URI____________ ${_currentItem.uri}");
      list = Provider.of<GlobalData>(_context, listen: false).tracksList;
      for (int i = 0; i < list.length; i++) {
        print("URI____________ ${list.elementAt(i).uri}");
        await SpotifySdk.queue(spotifyUri: list.elementAt(i).uri);
      }
      _currentItem = list.elementAt(_currentIndex);
      SpotifySdk.play(spotifyUri: _currentItem.uri);
      setState(() {
        isPlaying = true;
      });
    } else {
      Toast.show("Failed to Connect to SPOTIFY", _context);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: K.bgDarkColor,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: size.height / 3,
                    width: size.width,
                    child: Image.network(
                      _thumbNail,
                      fit: BoxFit.fill,
                    ),
                  ),

                  // meta info
                  Container(
                    margin: EdgeInsets.all(32),
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        Text(
                          "${_currentItem.name}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: K.lightTextColor,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "${_currentItem.artists[0].name}",
                          style: TextStyle(
                            fontSize: 18,
                            color: K.lightTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // player controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.skip_previous_sharp),
                        iconSize: 72,
                        color: Colors.greenAccent,
                        onPressed: skipPrevious,
                      ),
                      IconButton(
                          icon: isPlaying
                              ? Icon(Icons.pause)
                              : Icon(Icons.play_arrow_sharp),
                          iconSize: 72,
                          color: Colors.greenAccent,
                          onPressed: () {
                            handlePausePlay(context);
                          }),
                      IconButton(
                        icon: Icon(Icons.skip_next_sharp),
                        iconSize: 72,
                        color: Colors.greenAccent,
                        onPressed: skipNext,
                      ),
                    ],
                  ),

                  //playerStateWidget(),
                ],
              ),
            ),
            IconButton(
              padding: EdgeInsets.all(16),
              iconSize: 32,
              color: Colors.white,
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
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
      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: DotEnv().env['CLIENT_ID'].toString(),
          redirectUrl: DotEnv().env['REDIRECT_URL'].toString());

      print("Spotify Result : $result");
      setStatus(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
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

  void handlePausePlay(BuildContext context) async {
    if (isPlaying) {
      var res = await SpotifySdk.pause();

      print("Que Results: $res");
    } else {
      var res = await SpotifySdk.resume();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  Future<void> skipNext() async {
    try {
      await SpotifySdk.skipNext();
      setState(() {
        if (_currentIndex < (list.length - 1)) {
          _currentIndex++;
          _currentItem = list.elementAt(_currentIndex);

          setState(() {});
        } else {
          Toast.show("Reached end of the playlist", _context);
        }
      });
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> skipPrevious() async {
    try {
      await SpotifySdk.skipPrevious();
      setState(() {
        if (_currentIndex > 0) {
          _currentIndex--;
          _currentItem = list.elementAt(_currentIndex);

          setState(() {});
        } else {
          Toast.show("Reached Start of the playlist", _context);
        }
      });
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }
}
