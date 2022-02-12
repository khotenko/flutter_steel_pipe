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
  }

  Future<void> _setUserPref() async {
    final SharedPreferences prefs = await _prefs;

    prefs.setBool('mmBoldBool', mmBold);
    prefs.setBool('inBoldBool', inBold);
  }

  ScrollController _scrollController;

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

    print(androidPlatform);
    print(windowsPlatform);
    print(webPlatform);

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
                        // child: Scrollbar(
                        //   controller: _scrollController,
                        //   isAlwaysShown: true,
                        //   child: ListView.builder(
                        //       controller: _scrollController,
                        //       itemCount: diam.length,
                        //       itemBuilder: (context, index) {
                        //         return ListTile(
                        //           selected: (selectedIndexGlobal == index),
                        //           onTap: () {
                        //             selectedIndexGlobal = index;
                        //
                        //             tableRow = [];
                        //             SystemSound.play(SystemSoundType.click);
                        //             HapticFeedback.lightImpact();
                        //             getSelectedDiameterData(selectedIndexGlobal,
                        //                 _containerSize, _dividerThickness);
                        //           },
                        //           title: Text(
                        //             diam[index].toString(),
                        //             textAlign: TextAlign.center,
                        //           ),
                        //         );
                        //       }),
                        // ),

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
                          isAlwaysShown: true,
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

                        // child: CupertinoTheme(
                        //   data: CupertinoThemeData(
                        //     textTheme: CupertinoTextThemeData(
                        //       dateTimePickerTextStyle: TextStyle(
                        //           // fontSize: 14,
                        //           ),
                        //     ),
                        //   ),
                        //   child: CupertinoPicker(
                        //     useMagnifier: true,
                        //     magnification: 1.1,
                        //     itemExtent: _pickerExtent,
                        //     onSelectedItemChanged: (selectedIndex) {
                        //       selectedIndexGlobal = selectedIndex;
                        //
                        //       tableRow = [];
                        //       SystemSound.play(SystemSoundType.click);
                        //       HapticFeedback.lightImpact();
                        //       getSelectedDiameterData(selectedIndexGlobal,
                        //           _containerSize, _dividerThickness);
                        //     },
                        //     children: getPickerItems(),
                        //   ),
                        // ),
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
    const url =
        'https://www.microsoft.com/en-ca/p/unit-converter-convert-units/9PH4SN4SQ71D';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURLGoogle() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.khotenko.steel_pipe';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURLApple() async {
    const url = 'https://apps.apple.com/us/app/steel-pipe/id1517543497';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Brightness lightMode = MediaQuery.of(context).platformBrightness;
    // double _height = MediaQuery.of(context).size.height;
    // double _width = MediaQuery.of(context).size.width;

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
      //&& _width >= 700 && _height >= 900
      // running on the web!
      //_pickerInset = 15;

      return Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  print('hello');
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
