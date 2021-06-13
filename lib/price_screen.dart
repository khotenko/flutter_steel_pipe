import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'coin_data.dart';
import 'dart:convert';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  var sList = [];

  List<Widget> tableRow = [];

  List<Widget> getPickerItems() {
    List<Widget> pickerItems = [];

    for (String diameter in currenciesList) {
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

  List<Widget> getSelectedDiameterData(
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

  Future<void> getJSON() async {
    final String response =
        await rootBundle.loadString('assets/actualData.json');
    List<dynamic> data = jsonDecode(response);
    // list of maps
    sList = List<Map<String, dynamic>>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    // getDropDownItems();

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
    int f = 50;
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
        f = 50;
        g = 120;
      });
    }

    if (_width >= 540) {
      setState(() {
        // _containerSize = 50;
        // _headerFont = 17;
        // _dividerThickness = 15;
        // _pickerSize = 175;
        // _pickerInset = 30;
        // _containerSizeMultiply = 1.5;
        a = 80;
        b = 30;
        c = 30;
        d = 40;
        e = 100;
        f = 50;
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
        f = 50;
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
    getJSON();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
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
                      width: _containerSize * _containerSizeMultiply * 1.1 + 5,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(() {
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
                          setState(() {
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
                        dateTimePickerTextStyle: TextStyle(
                            // fontSize: 16,
                            ),
                      ),
                    ),
                    child: ListView(
                      children: tableRow,
                    ),
                  ),
                )),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: _pickerSize,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(bottom: _pickerInset),
                  // color: Colors.lightBlue,
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
                      // backgroundColor: Colors.white,
                      itemExtent: _pickerExtent,
                      onSelectedItemChanged: (selectedIndex) {
                        selectedIndexGlobal = selectedIndex;

                        tableRow = [];
                        SystemSound.play(SystemSoundType.click);
                        HapticFeedback.lightImpact();
                        getSelectedDiameterData(selectedIndexGlobal,
                            _containerSize, _dividerThickness);

                        //print(selectedIndex);
                      },
                      children: getPickerItems(),
                    ),
                  ),
                ),
                BottomRow(),
              ],
            ),
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
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    String appleStoreImage = '';
    if (lightMode == Brightness.light) {
      appleStoreImage =
          'assets/storeLogos/Download_on_the_App_Store_Badge_US-UK_wht_092917.png';
    }
    if (lightMode == Brightness.dark) {
      appleStoreImage =
          'assets/storeLogos/Download_on_the_App_Store_Badge_US-UK_blk_092917.png';
    }

    if (kIsWeb && _width >= 700 && _height >= 900) {
      // running on the web!
      //_pickerInset = 15;

      return Row(
        children: [
          Padding(
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
          Padding(
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
        ],
      );
    } else {
      return SizedBox(
        height: 0,
      );
    }
  }
}
