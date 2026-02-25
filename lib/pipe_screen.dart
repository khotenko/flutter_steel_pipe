import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
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


  ValueNotifier<int> _selectedOD = ValueNotifier<int>(0);

  bool mmBold = true;
  bool inBold = false;



  static const List<String> diam = ["NPS [inches]  OD [mm] OD [in]",
    "1/8  10.3 mm 0.405 in",
    "1/4  13.7 mm 0.540 in",
    "3/8  17.1 mm 0.675 in",
    "1/2  21.3 mm 0.840 in",
    "3/4  26.7 mm 1.050 in",
    "1  33.4 mm 1.315 in",
    "1-1/4  42.2 mm 1.660 in",
    "1-1/2  48.3 mm 1.900 in",
    "2  60.3 mm 2.375 in",
    "2-1/2  73.0 mm 2.875 in",
    "3  88.9 mm 3.500 in",
    "3-1/2  101.6 mm 4.000 in",
    "4  114.3 mm 4.500 in",
    "5  141.3 mm 5.563 in",
    "6  168.3 mm 6.625 in",
    "8  219.1 mm 8.625 in",
    "10  273.0 mm 10.750 in",
    "12  323.9 mm 12.750 in",
    "14  355.6 mm 14.000 in",
    "16  406.4 mm 16.000 in",
    "18  457.2 mm 18.000 in",
    "20  508 mm 20.000 in",
    "22  559 mm 22.000 in",
    "24  610 mm 24.000 in",
    "26  660 mm 26.000 in",
    "28  711 mm 28.000 in",
    "30  762 mm 30.000 in",
    "32  813 mm 32.000 in",
    "34  864 mm 34.000 in",
    "36  914 mm 36.000 in",
    "38  965 mm 38.000 in",
    "40  1016 mm 40.000 in",
    "42  1067 mm 42.000 in",
    "48  1219 mm 48.000 in",
    "54  1372 mm 54.000 in",
    "60  1524 mm 60.000 in"
  ];



   List<dynamic> wantedODInfo = [];

  List<Widget> getPickerItems() {
    List<Widget> pickerItems = [];

    for (String diameter in diam) {
     // diam.add(diameter);

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


  var scrollCount = 0;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool doneLoadingJSON = false;

  bool webPlatform = false;
  bool androidPlatform = false;
  bool windowsPlatform = false;

  getJSON() async {
    final String response =
    await rootBundle.loadString('assets/actualData.json');
    List<dynamic> data = jsonDecode(response);

    sList = List<Map<String, dynamic>>.from(data);

    setState(() {
      doneLoadingJSON = true;
    });


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
          );
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

  ScrollController _scrollController = ScrollController();

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


    getJSON();

    _getUserData().whenComplete(()  {
      setState(() {
        if (mmBold == true && inBold == false) {
          fontWeightMM = FontWeight.w600;
          fontWeightInches = FontWeight.w200;
        }
        if (mmBold == false && inBold == true) {
          fontWeightMM = FontWeight.w200;
          fontWeightInches = FontWeight.w600;
        }
      });
    });
  }

  Future<void> _showMyDialog(BuildContext ctx) async {
    showModalBottomSheet(
      context: ctx,
      builder: (context) {
        return BottomRow(key: ValueKey('bottom_row'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: LayoutBuilder(builder: (context, constraints) {
              final cfg = _LayoutConfig.resolve(constraints);

              if (!doneLoadingJSON) {
                return const Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          'loading...',
                          style: TextStyle(fontWeight: FontWeight.w200),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 25),
                  // ── Header row ──────────────────────────────────────────
                  _PipeHeaderRow(
                    cfg: cfg,
                    fontWeightInches: fontWeightInches,
                    fontWeightMM: fontWeightMM,
                    onTapInches: () {
                      inBold = true;
                      mmBold = false;
                      setState(() {
                        _setUserPref();
                        fontWeightInches = FontWeight.w600;
                        fontWeightMM = FontWeight.w200;
                      });
                    },
                    onTapMM: () {
                      inBold = false;
                      mmBold = true;
                      setState(() {
                        _setUserPref();
                        fontWeightInches = FontWeight.w200;
                        fontWeightMM = FontWeight.w600;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  // ── Data + picker ────────────────────────────────────────
                  Expanded(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _selectedOD,
                      builder: (context, value, _) {
                        wantedODInfo = sList
                            .where((e) => e['Name'] == diam[value])
                            .toList();

                        return Column(children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: wantedODInfo.length,
                              itemBuilder: (context, i) {
                                return _PipeDataRow(
                                  cfg: cfg,
                                  rowData: wantedODInfo[i],
                                  fontWeightInches: fontWeightInches,
                                  fontWeightMM: fontWeightMM,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (androidPlatform)
                            Container(
                              height: cfg.pickerSize,
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(bottom: cfg.pickerInset),
                              child: CupertinoPicker(
                                useMagnifier: true,
                                magnification: 1.2,
                                itemExtent: 30,
                                onSelectedItemChanged: (selectedIndex) {
                                  scrollCount += 1;
                                  _setScrollCount();
                                  SystemSound.play(SystemSoundType.click);
                                  HapticFeedback.lightImpact();
                                  _selectedOD.value = selectedIndex;
                                },
                                children: getPickerItems(),
                              ),
                            ),
                          if (webPlatform || windowsPlatform)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  onPressed: () => _showMyDialog(context),
                                  icon: const Icon(
                                    CupertinoIcons.info_circle,
                                    color: Colors.grey,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: cfg.pickerSize,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Scrollbar(
                                      controller: _scrollController,
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        itemCount: diam.length,
                                        itemBuilder: (context, index) {
                                          return MouseRegion(
                                            child: Card(
                                              elevation: (_selectedOD.value ==
                                                      index)
                                                  ? 10
                                                  : null,
                                              child: ListTile(
                                                selected:
                                                    _selectedOD.value == index,
                                                selectedColor: Colors.blue,
                                                onTap: () {
                                                  _selectedOD.value = index;
                                                  _setScrollCount();
                                                  SystemSound.play(
                                                      SystemSoundType.click);
                                                  HapticFeedback.lightImpact();
                                                },
                                                title: Text(
                                                  diam[index],
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                        ]);
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// Layout configuration — resolved once per build from LayoutBuilder constraints.
// No more magic int variables or setState() calls inside build().
// ─────────────────────────────────────────────────────────────────────────────
class _LayoutConfig {
  final double headerFont;
  final double dividerThickness;
  final double pickerSize;
  final double pickerInset;

  const _LayoutConfig({
    required this.headerFont,
    required this.dividerThickness,
    required this.pickerSize,
    required this.pickerInset,
  });

  factory _LayoutConfig.resolve(BoxConstraints constraints) {
    final double w = constraints.maxWidth;
    final bool wide = w >= 540;

    return _LayoutConfig(
      headerFont: wide ? 17 : 12,
      dividerThickness: 15,
      pickerSize: 175,
      pickerInset: wide ? 30 : 15,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared column flex values — header and data rows both use these so the
// columns are guaranteed to align without any manual pixel arithmetic.
// ─────────────────────────────────────────────────────────────────────────────
class _Col {
  static const int leading = 3;  // left margin
  static const int wtIn    = 5;  // WT inches
  static const int wtMm    = 5;  // WT mm
  static const int lbFt    = 5;  // lb/ft
  static const int kgM     = 5;  // kg/m
  static const int sch1    = 4;  // Schedule col 1
  static const int sch2    = 4;  // Schedule col 2
  static const int trailing= 2;  // right margin
}

// ─────────────────────────────────────────────────────────────────────────────
// Header row — clickable WT inches / WT mm toggle, static labels for the rest.
// ─────────────────────────────────────────────────────────────────────────────
class _PipeHeaderRow extends StatelessWidget {
  final _LayoutConfig cfg;
  final FontWeight fontWeightInches;
  final FontWeight fontWeightMM;
  final VoidCallback onTapInches;
  final VoidCallback onTapMM;

  const _PipeHeaderRow({
    required this.cfg,
    required this.fontWeightInches,
    required this.fontWeightMM,
    required this.onTapInches,
    required this.onTapMM,
  });

  Widget _label(String text, {FontWeight? weight, VoidCallback? onTap}) {
    final child = Text(
      text,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: cfg.headerFont, fontWeight: weight),
    );
    if (onTap == null) return child;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(flex: _Col.leading),
        Expanded(
          flex: _Col.wtIn,
          child: _label('WT inches', weight: fontWeightInches, onTap: onTapInches),
        ),
        Expanded(
          flex: _Col.wtMm,
          child: _label('WT mm', weight: fontWeightMM, onTap: onTapMM),
        ),
        Expanded(
          flex: _Col.lbFt,
          child: _label('lb/ft'),
        ),
        Expanded(
          flex: _Col.kgM,
          child: _label('kg/m'),
        ),
        Expanded(
          flex: _Col.sch1 + _Col.sch2,
          child: _label('Schedule'),
        ),
        const Spacer(flex: _Col.trailing),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data row — one row per wall-thickness entry, uses identical flex values to
// _PipeHeaderRow so columns always line up perfectly.
// ─────────────────────────────────────────────────────────────────────────────
class _PipeDataRow extends StatelessWidget {
  final _LayoutConfig cfg;
  final Map<String, dynamic> rowData;
  final FontWeight fontWeightInches;
  final FontWeight fontWeightMM;

  const _PipeDataRow({
    required this.cfg,
    required this.rowData,
    required this.fontWeightInches,
    required this.fontWeightMM,
  });

  Widget _cell(String text, {FontWeight weight = FontWeight.w200}) {
    return SelectableText(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: weight),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 2),
        Row(
          children: [
            const Spacer(flex: _Col.leading),
            Expanded(
              flex: _Col.wtIn,
              child: _cell(
                rowData['WT_inch'].toStringAsFixed(3),
                weight: fontWeightInches,
              ),
            ),
            Expanded(
              flex: _Col.wtMm,
              child: _cell(
                rowData['WT_mm'].toStringAsFixed(2),
                weight: fontWeightMM,
              ),
            ),
            Expanded(
              flex: _Col.lbFt,
              child: _cell(rowData['lb_per_ft'].toStringAsFixed(1)),
            ),
            Expanded(
              flex: _Col.kgM,
              child: _cell(rowData['kg_per_m'].toStringAsFixed(1)),
            ),
            Expanded(
              flex: _Col.sch1,
              child: _cell(rowData['Sch_1'].toString()),
            ),
            Expanded(
              flex: _Col.sch2,
              child: _cell(rowData['Sch_2'].toString()),
            ),
            const Spacer(flex: _Col.trailing),
          ],
        ),
        Divider(height: cfg.dividerThickness, thickness: 0.25),
        const SizedBox(height: 2),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class BottomRow extends StatelessWidget {
  const BottomRow({
    required Key key,
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,

        children: [
          IconButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),

            icon: Icon(Icons.clear),color: Colors.grey,),
          Wrap(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      _launchURLApple();
                    },
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 40,
                      ),
                      child: Image.asset(appleStoreImage),
                    ),
                  ),
                ),
              ),
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 55,
                  maxWidth: 150,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        _launchURLGoogle();
                      },
                      child: Image.asset('assets/storeLogos/google-play-badge.png'),
                    ),
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      _launchURLMS();
                    },
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 40,
                      ),
                      child: Image.asset('assets/storeLogos/MS.png'),
                    ),
                  ),
                ),
              ),
            ],
          ),

        ],
      );
      // return Column(
      //   children: [
      //     Expanded(
      //       flex: 1,
      //       child: Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: InkWell(
      //           borderRadius: BorderRadius.circular(10),
      //           onTap: () {
      //             _launchURLApple();
      //           },
      //           child: Container(
      //             child: Container(
      //               constraints: BoxConstraints(
      //                 maxHeight: 40,
      //               ),
      //               child: Image.asset(appleStoreImage),
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       flex: 1,
      //       child: Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: InkWell(
      //           borderRadius: BorderRadius.circular(10),
      //           onTap: () {
      //             _launchURLGoogle();
      //           },
      //           child: Container(
      //             constraints: BoxConstraints(
      //               maxHeight: 55,
      //             ),
      //             child: Image.asset('assets/storeLogos/google-play-badge.png'),
      //           ),
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       flex: 1,
      //       child: Padding(
      //         padding: const EdgeInsets.all(16.0),
      //         child: InkWell(
      //           borderRadius: BorderRadius.circular(10),
      //           onTap: () {
      //             _launchURLMS();
      //           },
      //           child: Container(
      //             constraints: BoxConstraints(
      //               maxHeight: 55,
      //             ),
      //             child: Padding(
      //               padding: const EdgeInsets.all(8.0),
      //               child: Image.asset('assets/storeLogos/MS.png'),
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // );
    } else {
      return  Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,

        children: [
          IconButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),

            icon: Icon(Icons.clear),color: Colors.grey,),

          TextButton(onPressed: () {

          },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('https://pipesizes.web.app/'),
              )),

        ],
      );
    }
  }
}
