import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pipe_data.dart';
import 'dart:convert';
import 'dart:async' show Future;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'package:rate_my_app/rate_my_app.dart';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  var sList = [];

  List<Widget> tableRow = [];

  bool mmBold = true;
  bool inBold = false;

  List<String> diam = [];

  List<Widget> getPickerItems() {
    List<Widget> pickerItems = [];

    for (String diameter in currenciesList) {
      diam.add(diameter);

      pickerItems.add(
        Center(
          child: Text(
            diameter,
          ),
        ),
      );
    }

    return pickerItems;
  }

  var fontWeightInches = FontWeight.w200;
  var fontWeightMM = FontWeight.w600;

  var selectedIndexGlobal = 0;

  var scrollCount = 0;
  final newUserDefault = SharedPreferences.getInstance();

  getSelectedDiameterData(
      int selected, double containerSize, double dividerThickness) {
    var selectedDiameter = currenciesList[selected];

    final itemList = sList.where((e) => e['Name'] == selectedDiameter).toList();
    // list of maps with selected diameter

    for (var i = 0; i < itemList.length; i++) {
      tableRow.add(
        Column(
          children: [
            SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(
                  flex: 100,
                ),
                Container(
                  width: containerSize,
                  child: Center(
                    child: SelectableText(
                      itemList[i]['WT_inch'].toStringAsFixed(3),
                      style: TextStyle(
                        fontWeight: fontWeightInches,
                      ),
                    ),
                  ),
                ),
                Spacer(
                  flex: 70,
                ),
                Container(
                  width: containerSize,
                  child: Center(
                    child: SelectableText(
                      itemList[i]['WT_mm'].toStringAsFixed(2),
                      style: TextStyle(
                        fontWeight: fontWeightMM,
                      ),
                    ),
                  ),
                ),
                Spacer(
                  flex: 80,
                ),
                Container(
                  width: containerSize,
                  child: Center(
                    child: SelectableText(
                      itemList[i]['lb_per_ft'].toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ),
                Spacer(
                  flex: 70,
                ),
                Container(
                  width: containerSize,
                  child: Center(
                    child: SelectableText(
                      itemList[i]['kg_per_m'].toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ),
                Spacer(
                  flex: 100,
                ),
                Container(
                  width: containerSize / 1.8,
                  child: Center(
                    child: Text(
                      itemList[i]['Sch_1'].toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ),
                Spacer(
                  flex: 50,
                ),
                Container(
                  width: containerSize / 1.8,
                  child: Center(
                    child: Text(
                      itemList[i]['Sch_2'].toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ),
                Spacer(
                  flex: 100,
                ),
              ],
            ),
            Divider(
              height: dividerThickness,
              thickness: 0.5,
              color: Colors.grey,
            ),
            SizedBox(
              height: 2,
            ),
          ],
        ),
      );

      // return tableRow;
    }

    setState(() {
      return tableRow;
    });
  }

  Future myFuture;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool doneLoadingJSON = false;

  bool webPlatform = false;
  bool androidPlatform = false;
  bool windowsPlatform = false;

  Future<void> getJSON() async {
    final String response =
        await rootBundle.loadString('assets/actualData.json');
    List<dynamic> data = jsonDecode(response);
    // list of maps
    sList = List<Map<String, dynamic>>.from(data);

    setState(() {
      doneLoadingJSON = true;
    });

    return myFuture;
  }

  Future<void> _getUserData() async {
    final SharedPreferences prefs = await _prefs;
    mmBold = prefs.getBool('mmBoldBool') ?? true;
    inBold = prefs.getBool('inBoldBool') ?? false;

    scrollCount = prefs.getInt('scrollCount') ?? 0;

    print(scrollCount);

    if (scrollCount > 10) {
      rateMyApp.init().then((_) {
        if (rateMyApp.shouldOpenDialog) {
          rateMyApp.showRateDialog(
            context,
            title: 'Rate this app', // The dialog title.
            message:
                'If this app is useful, please consider supporting by rating - it really helps! Thank you.', // The dialog message.
            rateButton: 'RATE', // The dialog "rate" button text.
            noButton: 'No thanks', // The dialog "no" button text.
            laterButton: 'Maybe later', // The dialog "later" button text.
            listener: (button) {
              // The button click listener (useful if you want to cancel the click event).
              switch (button) {
                case RateMyAppDialogButton.rate:
                  print('Clicked on "Rate".');
                  break;
                case RateMyAppDialogButton.later:
                  print('Clicked on "Later".');
                  break;
                case RateMyAppDialogButton.no:
                  print('Clicked on "No".');
                  break;
              }

              return true; // Return false if you want to cancel the click event.
            },
            ignoreNativeDialog: Platform
                .isAndroid, // Set to false if you want to show the Apple's native app rating dialog on iOS or Google's native app rating dialog (depends on the current Platform).
            dialogStyle: const DialogStyle(), // Custom dialog styles.
            onDismissed: () => rateMyApp.callEvent(RateMyAppEventType
                .laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
            // contentBuilder: (context, defaultContent) => content, // This one allows you to change the default dialog content.
            // actionsBuilder: (context) => [], // This one allows you to use your own buttons.
          );

          // Or if you prefer to show a star rating bar (powered by `flutter_rating_bar`) :

        }
      });
    }
  }

  Future<void> _setUserPref() async {
    final SharedPreferences prefs = await _prefs;

    prefs.setBool('mmBoldBool', mmBold);
    prefs.setBool('inBoldBool', inBold);
  }

  Future<void> _setScrollCount() async {
    final SharedPreferences prefs = await _prefs;

    prefs.setInt('scrollCount', scrollCount);
  }

  ScrollController _scrollController;

  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 3,
    minLaunches: 3,
    remindDays: 3,
    remindLaunches: 3,
    googlePlayIdentifier: 'com.khotenko.steel_pipe',
  );

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    try {
      if (Platform.isAndroid) {
        androidPlatform = true;
      }
      if (Platform.isWindows) {
        windowsPlatform = true;
      }
    } on UnsupportedError catch (_) {
      if (kIsWeb) {
        webPlatform = true;
      } else {
        print('error');
      }
    }

    getPickerItems();
    getJSON();

    _getUserData().whenComplete(() => {
          setState(() {
            if (mmBold == true && inBold == false) {
              fontWeightMM = FontWeight.w600;
              fontWeightInches = FontWeight.w200;
            }
            if (mmBold == false && inBold == true) {
              fontWeightMM = FontWeight.w200;
              fontWeightInches = FontWeight.w600;
            }
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    Brightness lightMode = MediaQuery.of(context).platformBrightness;

    if (lightMode == Brightness.light) {}
    if (lightMode == Brightness.dark) {}

    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    double _containerSize = 50;

    double _pickerExtent = 30;

    double _dividerThickness = 15;
    double _pickerSize = 150;
    double _pickerInset = 15;

    double _headerFont = 15;
    double _containerSizeMultiply = 1.5;

    int a = 100;
    int b = 40;
    int c = 40;
    int d = 40;
    int e = 100;
    int g = 150;

    if (_width >= 540 && _height >= 500) {
      setState(() {
        _containerSize = 50;
        _headerFont = 17;
        _dividerThickness = 15;
        _pickerSize = 175;
        _pickerInset = 30;
        _containerSizeMultiply = 1.5;
        a = 80;
        b = 30;
        c = 30;
        d = 40;
        e = 100;
        g = 120;
      });
    }

    if (_width >= 540) {
      setState(() {
        a = 80;
        b = 30;
        c = 30;
        d = 40;
        e = 100;
        g = 120;
      });
    }

    if (_width < 540) {
      setState(() {
        _headerFont = 12;
        _containerSize = 60;
        _containerSizeMultiply = 1;
        a = 80;
        b = 40;
        c = 60;
        d = 70;
        e = 100;
        g = 150;
      });
    }

    if (_height < 500) {
      setState(() {
        _containerSize = 50;

        _dividerThickness = 5;
        _pickerSize = 100;
        _pickerInset = 10;
      });
    }

    CupertinoDynamicColor.resolve(CupertinoColors.label, context);
    // getJSON();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Builder(builder: (context) {
              if (doneLoadingJSON == true) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Spacer(
                          flex: a,
                        ),
                        Container(
                          width:
                              _containerSize * _containerSizeMultiply * 1.1 + 5,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              inBold = true;
                              mmBold = false;

                              setState(() {
                                _setUserPref();
                                fontWeightInches = FontWeight.w600;
                                fontWeightMM = FontWeight.w200;
                                tableRow = [];
                                getSelectedDiameterData(selectedIndexGlobal,
                                    _containerSize, _dividerThickness);
                              });
                            },
                            child: Center(
                              child: Text(
                                'WT inches',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: _headerFont,
                                  fontWeight: fontWeightInches,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Spacer(
                          flex: b,
                        ),
                        Container(
                          width: _containerSize * _containerSizeMultiply,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              inBold = false;
                              mmBold = true;
                              setState(() {
                                _setUserPref();
                                fontWeightInches = FontWeight.w200;
                                fontWeightMM = FontWeight.w600;
                                tableRow = [];
                                getSelectedDiameterData(selectedIndexGlobal,
                                    _containerSize, _dividerThickness);
                              });
                            },
                            child: Center(
                              child: Text(
                                'WT mm',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: _headerFont,
                                  fontWeight: fontWeightMM,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Spacer(
                          flex: c,
                        ),
                        Container(
                          width: _containerSize * _containerSizeMultiply,
                          child: Center(
                            child: Text(
                              'lb/ft',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: _headerFont,
                              ),
                            ),
                          ),
                        ),
                        Spacer(
                          flex: d,
                        ),
                        Container(
                          width: _containerSize * _containerSizeMultiply,
                          child: Center(
                            child: Text(
                              'kg/m',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: _headerFont,
                              ),
                            ),
                          ),
                        ),
                        Spacer(
                          flex: e,
                        ),
                        Container(
                          width: _containerSize * _containerSizeMultiply,
                          child: Center(
                            child: Text(
                              'Schedule',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: _headerFont,
                              ),
                            ),
                          ),
                        ),
                        Spacer(
                          flex: g,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Scrollbar(
                        child: CupertinoTheme(
                          data: CupertinoThemeData(
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: TextStyle(),
                            ),
                          ),
                          child: ListView(
                            children: tableRow,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (androidPlatform)
                      Container(
                        height: _pickerSize,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(bottom: _pickerInset),
                        child: CupertinoTheme(
                          data: CupertinoThemeData(
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: TextStyle(
                                  // fontSize: 14,
                                  ),
                            ),
                          ),
                          child: CupertinoPicker(
                            useMagnifier: true,
                            magnification: 1.1,
                            itemExtent: _pickerExtent,
                            onSelectedItemChanged: (selectedIndex) {
                              scrollCount = scrollCount + 1;

                              _setScrollCount();

                              print(scrollCount);

                              selectedIndexGlobal = selectedIndex;

                              tableRow = [];
                              SystemSound.play(SystemSoundType.click);
                              HapticFeedback.lightImpact();
                              getSelectedDiameterData(selectedIndexGlobal,
                                  _containerSize, _dividerThickness);
                            },
                            children: getPickerItems(),
                          ),
                        ),
                      ),
                    if (webPlatform || windowsPlatform)
                      Container(
                        height: _pickerSize,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(bottom: _pickerInset),
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: ListView.builder(
                              controller: _scrollController,
                              itemCount: diam.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  selected: (selectedIndexGlobal == index),
                                  onTap: () {
                                    selectedIndexGlobal = index;

                                    tableRow = [];
                                    SystemSound.play(SystemSoundType.click);
                                    HapticFeedback.lightImpact();
                                    getSelectedDiameterData(selectedIndexGlobal,
                                        _containerSize, _dividerThickness);
                                  },
                                  title: Text(
                                    diam[index].toString(),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }),
                        ),
                      ),
                    BottomRow(),
                  ],
                );
              } else {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                        ),
                        width: 30,
                        height: 30,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          'loading...',
                          style: TextStyle(fontWeight: FontWeight.w200),
                        ),
                      )
                    ],
                  ),
                );
              }
            }),
          ),
        ),
      ),
    );
  }
}

class BottomRow extends StatelessWidget {
  const BottomRow({
    Key key,
  }) : super(key: key);

  _launchURLMS() async {
    final url =
        'https://apps.microsoft.com/store/detail/steel-pipe/9PH4SN4SQ71D';

    final MSUri = Uri(
        scheme: 'https',
        host: 'apps.microsoft.com',
        path: '/store/detail/steel-pipe/9PH4SN4SQ71D');

    if (await canLaunchUrl(MSUri)) {
      await launchUrl(MSUri);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURLGoogle() async {
    final url =
        'https://play.google.com/store/apps/details?id=com.khotenko.steel_pipe';

    final GoggleUri = Uri(
        scheme: 'https',
        host: 'play.google.com',
        path: '/store/apps/details',
        queryParameters: {'id': 'com.khotenko.steel_pipe'});

    if (await canLaunchUrl(GoggleUri)) {
      await launchUrl(GoggleUri);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURLApple() async {
    final url = 'https://apps.apple.com/ca/app/steel-pipe/id1517543497';

    final AppleUri = Uri(
        scheme: 'https',
        host: 'apps.apple.com',
        path: '/ca/app/steel-pipe/id1517543497');

    if (await canLaunchUrl(AppleUri)) {
      await launchUrl(AppleUri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Brightness lightMode = MediaQuery.of(context).platformBrightness;

    String appleStoreImage = '';
    if (lightMode == Brightness.light) {
      appleStoreImage =
          'assets/storeLogos/Download_on_the_App_Store_Badge_US-UK_wht_092917.png';
    }
    if (lightMode == Brightness.dark) {
      appleStoreImage =
          'assets/storeLogos/Download_on_the_App_Store_Badge_US-UK_blk_092917.png';
    }

    if (kIsWeb) {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  _launchURLApple();
                },
                child: Container(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 40,
                    ),
                    child: Image.asset(appleStoreImage),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  _launchURLGoogle();
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 55,
                  ),
                  child: Image.asset('assets/storeLogos/google-play-badge.png'),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  _launchURLMS();
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 55,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/storeLogos/MS.png'),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        height: 0,
      );
    }
  }
}
