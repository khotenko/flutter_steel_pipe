import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> _estNPS(BuildContext ctx) async {
    showDialog(
      context: ctx,
      builder: (context) => const SagittaCalculatorDialog(),
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
                                Column(
                                  children: [
                                    IconButton(
                                      tooltip: 'Estimate NPS from arc',
                                      onPressed: () => _estNPS(context),
                                      icon: const Icon(
                                        CupertinoIcons.circle,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _showMyDialog(context),
                                      icon: const Icon(
                                        CupertinoIcons.info_circle,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Discrete footer — "Developed by River Right Ltd © 2026"
// ─────────────────────────────────────────────────────────────────────────────
class _RiverRightFooter extends StatelessWidget {
  const _RiverRightFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Developed by ',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
          GestureDetector(
            onTap: () => launchUrl(
              Uri.parse('https://www.riverright.ca/'),
              mode: LaunchMode.externalApplication,
            ),
            child: Text(
              'River Right Ltd',
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue.shade400,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Text(
            ' \u00a9 2026',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,

        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              icon: Icon(Icons.clear), color: Colors.grey,
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
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
          _RiverRightFooter(),
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              icon: Icon(Icons.clear), color: Colors.grey,
            ),
          ),

          TextButton(onPressed: () {

          },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('https://pipesizes.web.app/'),
              )),
          _RiverRightFooter(),
        ],
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NPS data helpers
// ─────────────────────────────────────────────────────────────────────────────
class _NpsEntry {
  final String npsLabel;
  final double odIn;
  final double odMm;
  const _NpsEntry(this.npsLabel, this.odIn, this.odMm);
}

List<_NpsEntry> _parseDiam() {
  // matches "NPS  ODmm mm ODin in"  e.g. "1/2  21.3 mm 0.840 in"
  final re = RegExp(r'^(.+?)\s{2,}([\d.]+)\s*mm\s+([\d.]+)\s*in');
  final result = <_NpsEntry>[];
  for (final s in _PriceScreenState.diam.skip(1)) {
    final m = re.firstMatch(s);
    if (m != null) {
      result.add(_NpsEntry(
        m.group(1)!.trim(),
        double.parse(m.group(3)!),
        double.parse(m.group(2)!),
      ));
    }
  }
  return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// Schematic painter – static cross-section: buried pipe with OD / chord / sagitta
// ─────────────────────────────────────────────────────────────────────────────
class _SagittaSchemePainter extends CustomPainter {
  final Color color;
  const _SagittaSchemePainter({required this.color});

  static const Color _chordColor   = Color(0xFF2196F3);
  static const Color _sagittaColor = Color(0xFFE53935);
  static const Color _odColor      = Color(0xFF43A047);
  static const Color _groundColor  = Color(0xFF8D6E63);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final r      = h * 0.52;
    final cy     = h * 0.86;
    final chordY = h * 0.62;

    final arcTopY   = cy - r;
    final halfChord = math.sqrt(math.max(0.0, r * r - math.pow(cy - chordY, 2)));
    final lx = cx - halfChord;
    final rx = cx + halfChord;

    Paint stroke(Color c, {double width = 1.8}) => Paint()
      ..color = c ..style = PaintingStyle.stroke ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    Paint fill(Color c) => Paint()..color = c..style = PaintingStyle.fill;

    // soil fill below chord
    canvas.drawRect(Rect.fromLTRB(0, chordY, w, h), fill(const Color(0x1A795548)));

    // ghost full circle (dashed)
    _drawDashedCircle(canvas, stroke(color.withValues(alpha: 0.22), width: 1.0), Offset(cx, cy), r);

    // visible arc fill + stroke
    final aLeft    = math.atan2(chordY - cy, lx - cx);
    final aRight   = math.atan2(chordY - cy, rx - cx);
    final sweepVis = aRight - aLeft;
    final arcRect  = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final arcPath  = Path()
      ..moveTo(lx, chordY)
      ..arcTo(arcRect, aLeft, sweepVis, false)
      ..lineTo(lx, chordY)
      ..close();
    canvas.drawPath(arcPath, fill(color.withValues(alpha: 0.08)));
    canvas.drawArc(arcRect, aLeft, sweepVis, false, stroke(color, width: 2.2));

    // ground line + hatch
    canvas.drawLine(Offset(0, chordY), Offset(w, chordY), stroke(_groundColor, width: 1.4));
    for (int i = 0; i <= 9; i++) {
      final x = w * i / 9;
      canvas.drawLine(Offset(x, chordY), Offset(x - 7, chordY + 9),
          stroke(_groundColor.withValues(alpha: 0.55), width: 1.0));
    }

    // OD double-arrow (left to right pipe edge)
    final odArrowY = arcTopY - 10;
    _drawDoubleArrow(canvas, stroke(_odColor, width: 1.6),
        Offset(cx - r, odArrowY), Offset(cx + r, odArrowY));
    final dropBottom = cy.clamp(0.0, h);
    for (final x in [cx - r, cx + r]) {
      canvas.drawLine(Offset(x, odArrowY), Offset(x, dropBottom),
          stroke(_odColor.withValues(alpha: 0.3), width: 1.0));
    }
    _drawLabelCentered(canvas, 'OD', Offset(cx, odArrowY - 12), _odColor, fontSize: 10, bold: true);

    // chord double-arrow
    const chordOffset = 14.0;
    final chordArrowY = chordY - chordOffset;
    _drawDoubleArrow(canvas, stroke(_chordColor, width: 1.6),
        Offset(lx, chordArrowY), Offset(rx, chordArrowY));
    for (final x in [lx, rx]) {
      canvas.drawLine(Offset(x, chordY - 6), Offset(x, chordY + 5),
          stroke(_chordColor, width: 1.2));
    }
    _drawLabel(canvas, 'C', Offset(cx + halfChord * 0.35, chordArrowY - 17), _chordColor, fontSize: 10);

    // sagitta double-arrow
    _drawDoubleArrow(canvas, stroke(_sagittaColor, width: 1.8),
        Offset(cx, chordY), Offset(cx, arcTopY));
    final sagMidY = (chordY + arcTopY) / 2;
    _drawLabel(canvas, 'S', Offset(cx - 14, sagMidY - 12), _sagittaColor, fontSize: 11, italic: true);
  }

  void _drawDoubleArrow(Canvas canvas, Paint p, Offset a, Offset b) {
    canvas.drawLine(a, b, p);
    _arrowHead(canvas, p, b, a);
    _arrowHead(canvas, p, a, b);
  }

  void _arrowHead(Canvas canvas, Paint p, Offset tip, Offset away) {
    final d = tip - away;
    final len = d.distance;
    if (len == 0) return;
    final ux = d.dx / len; final uy = d.dy / len;
    const s = 6.0, ww = 3.0;
    canvas.drawLine(tip, tip - Offset(ux * s - uy * ww, uy * s + ux * ww), p);
    canvas.drawLine(tip, tip - Offset(ux * s + uy * ww, uy * s - ux * ww), p);
  }

  void _drawDashedCircle(Canvas canvas, Paint p, Offset c, double r) {
    const steps = 80, on = 4, off = 3;
    Offset? prev;
    for (int i = 0; i <= steps; i++) {
      final a = 2 * math.pi * i / steps;
      final pt = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      if (i % (on + off) < on && prev != null) canvas.drawLine(prev, pt, p);
      prev = pt;
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, Color c,
      {double fontSize = 16, bool italic = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(
          color: c, fontSize: fontSize,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontWeight: FontWeight.w800)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  void _drawLabelCentered(Canvas canvas, String text, Offset center, Color c,
      {double fontSize = 11, bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(
          color: c, fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_SagittaSchemePainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Live proportional schematic – just the pipe circle + OD arrow. No tool drawing.
// ─────────────────────────────────────────────────────────────────────────────
class _LiveSchemePainter extends CustomPainter {
  final double odIn;
  final Color baseColor;

  const _LiveSchemePainter({
    required this.odIn,
    required this.baseColor,
  });

  static const Color _pipeColor = Color(0xFF1565C0);
  static const Color _odColor   = Color(0xFF43A047);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h * 0.54;
    final r  = math.min(w * 0.36, h * 0.38);

    Paint stroke(Color c, {double width = 1.8}) => Paint()
      ..color = c ..style = PaintingStyle.stroke ..strokeWidth = width
      ..strokeCap = StrokeCap.round ..strokeJoin = StrokeJoin.round;
    Paint fill(Color c) => Paint()..color = c..style = PaintingStyle.fill;

    // Pipe circle
    canvas.drawCircle(Offset(cx, cy), r, fill(_pipeColor.withValues(alpha: 0.10)));
    canvas.drawCircle(Offset(cx, cy), r, stroke(_pipeColor, width: 2.5));

    // OD double-arrow
    final odY = cy - r - 14;
    _drawDoubleArrow(canvas, stroke(_odColor, width: 1.6),
        Offset(cx - r, odY), Offset(cx + r, odY));
    for (final x in [cx - r, cx + r]) {
      canvas.drawLine(Offset(x, odY), Offset(x, cy),
          stroke(_odColor.withValues(alpha: 0.22), width: 1.0));
    }

    // OD value label centred above arrow
    final odLabel = 'OD = ${odIn.toStringAsFixed(3)} in  /  ${(odIn * 25.4).toStringAsFixed(1)} mm';
    _drawLabelCentered(canvas, odLabel, Offset(cx, odY - 12), _odColor,
        fontSize: 10.5, bold: true);
  }

  void _drawDoubleArrow(Canvas canvas, Paint p, Offset a, Offset b) {
    canvas.drawLine(a, b, p);
    _ah(canvas, p, b, a);
    _ah(canvas, p, a, b);
  }

  void _ah(Canvas canvas, Paint p, Offset tip, Offset away) {
    final d = tip - away; final len = d.distance;
    if (len == 0) return;
    final ux = d.dx / len; final uy = d.dy / len;
    const s = 6.0, ww = 3.0;
    canvas.drawLine(tip, tip - Offset(ux * s - uy * ww, uy * s + ux * ww), p);
    canvas.drawLine(tip, tip - Offset(ux * s + uy * ww, uy * s - ux * ww), p);
  }


  void _drawLabelCentered(Canvas canvas, String text, Offset center, Color c,
      {double fontSize = 11, bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(
          color: c, fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_LiveSchemePainter old) =>
      old.odIn != odIn || old.baseColor != baseColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sagitta → OD Calculator Dialog
// ─────────────────────────────────────────────────────────────────────────────
class SagittaCalculatorDialog extends StatefulWidget {
  const SagittaCalculatorDialog({super.key});
  @override
  State<SagittaCalculatorDialog> createState() =>
      _SagittaCalculatorDialogState();
}

class _SagittaCalculatorDialogState extends State<SagittaCalculatorDialog> {
  final _sagittaCtrl = TextEditingController();
  final _chordCtrl = TextEditingController();
  bool _useInches = true;

  double? _odIn;          // always stored in inches internally
  bool _sagittaIsOD = false; // true when sagitta >= chord
  List<_NpsEntry>? _matches; // [smaller, closest, larger]
  String? _errorMsg;

  late final List<_NpsEntry> _npsTable;

  @override
  void initState() {
    super.initState();
    _npsTable = _parseDiam();
  }

  @override
  void dispose() {
    _sagittaCtrl.dispose();
    _chordCtrl.dispose();
    super.dispose();
  }

  void _onUnitToggle(bool toInches) {
    final factor = toInches ? (1 / 25.4) : 25.4;
    _convertField(_sagittaCtrl, factor);
    _convertField(_chordCtrl, factor);
    setState(() {
      _useInches = toInches;
    });
    _calculate();
  }

  void _convertField(TextEditingController ctrl, double factor) {
    final v = double.tryParse(ctrl.text);
    if (v != null) {
      ctrl.text = (v * factor).toStringAsFixed(3);
    }
  }

  void _calculate() {
    final sRaw = double.tryParse(_sagittaCtrl.text);
    final cRaw = double.tryParse(_chordCtrl.text);

    if (sRaw == null || cRaw == null || sRaw <= 0 || cRaw <= 0) {
      setState(() {
        _odIn = null;
        _sagittaIsOD = false;
        _matches = null;
        _errorMsg = null;
      });
      return;
    }

    // convert to inches for calculation
    final s = _useInches ? sRaw : sRaw / 25.4;
    final c = _useInches ? cRaw : cRaw / 25.4;
    final halfC = c / 2;

    // When sagitta >= chord the contour tool fully surrounded the pipe —
    // the sagitta IS the full diameter. Use it directly as OD.
    final bool sagittaIsOD = s >= c;

    // Also guard for sagitta >= half-chord but < chord (impossible segment)
    if (!sagittaIsOD && s >= halfC) {
      setState(() {
        _odIn = null;
        _sagittaIsOD = false;
        _matches = null;
        _errorMsg = '⚠ Invalid: S must be less than half the chord';
      });
      return;
    }

    // Excel formula: OD = 2*(s^2 + (chord/2)^2) / (2*s)
    // Full-engulf: tool spans full pipe width → OD = chord
    final od = sagittaIsOD
        ? c
        : 2 * (s * s + halfC * halfC) / (2 * s);

    // find closest, next-smaller, next-larger
    int closestIdx = 0;
    double minDelta = double.infinity;
    for (int i = 0; i < _npsTable.length; i++) {
      final d = (_npsTable[i].odIn - od).abs();
      if (d < minDelta) {
        minDelta = d;
        closestIdx = i;
      }
    }

    _NpsEntry? smaller =
        closestIdx > 0 ? _npsTable[closestIdx - 1] : null;
    _NpsEntry? larger =
        closestIdx < _npsTable.length - 1 ? _npsTable[closestIdx + 1] : null;

    setState(() {
      _odIn = od;
      _sagittaIsOD = sagittaIsOD;
      _matches = [
        if (smaller != null) smaller,
        _npsTable[closestIdx],
        if (larger != null) larger,
      ];
      _errorMsg = null;
    });
  }

  String _fmtOd(double odIn) {
    if (_useInches) return '${odIn.toStringAsFixed(3)} in';
    return '${(odIn * 25.4).toStringAsFixed(1)} mm';
  }

  String _fmtDelta(double npsOdIn, double calcOdIn) {
    final delta = (npsOdIn - calcOdIn).abs();
    if (_useInches) return '±${delta.toStringAsFixed(3)} in';
    return '±${(delta * 25.4).toStringAsFixed(1)} mm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white70 : Colors.black87;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Title row ──
                Row(
                  children: [
                    // const Icon(CupertinoIcons.circle,
                    //     color: Colors.grey),
                    // const SizedBox(width: 8),
                    Expanded(
                      child: Text('Estimate NPS from top part of pipe',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '\n Measure only the top of the exposed pipe in the trench.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 14),
                Text(
                  ' OD = 2·(s² + (c/2)²) / (2·s)',
                 // textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic, color: Colors.grey),
                ),

                const SizedBox(height: 12),

                // ── Schematic ──
                SizedBox(
                  height: 200,
                  child: CustomPaint(
                    painter: _SagittaSchemePainter(
                        color: labelColor),
                    size: const Size(double.infinity, 200),
                  ),
                ),
                const SizedBox(height: 4),


                // ── Unit toggle ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Units:', style: theme.textTheme.bodySmall),
                    const SizedBox(width: 10),
                    ToggleButtons(
                      isSelected: [_useInches, !_useInches],
                      onPressed: (i) {
                        if (i == 0 && !_useInches) _onUnitToggle(true);
                        if (i == 1 && _useInches) _onUnitToggle(false);
                      },
                      borderRadius: BorderRadius.circular(8),
                      constraints: const BoxConstraints(
                          minWidth: 52, minHeight: 34),
                      children: const [
                        Text('  in  '),
                        Text('  mm  '),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Inputs ──
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _sagittaCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText:
                              'S  [${_useInches ? "in" : "mm"}]',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (_) => _calculate(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _chordCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText:
                              'C [${_useInches ? "in" : "mm"}]',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (_) => _calculate(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Error ──
                if (_errorMsg != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(_errorMsg!,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 12)),
                  ),

                // ── Results ──
                if (_odIn != null && _matches != null) ...[
                  const Divider(),
                  const SizedBox(height: 4),
                  if (_sagittaIsOD)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'S ≥ C: the contour tool fully surrounded '
                              'the pipe. S is assumed to be same as C.',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade700,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    'Estimated OD: ${_fmtOd(_odIn!)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ..._matches!.map((entry) {
                    final isClosest = _matches!.indexOf(entry) ==
                        _matches!.indexWhere((e) =>
                            (e.odIn - _odIn!).abs() ==
                            _matches!
                                .map((x) => (x.odIn - _odIn!).abs())
                                .reduce((a, b) => a < b ? a : b));
                    final delta = entry.odIn - _odIn!;
                    final icon = isClosest
                        ? Icons.check_circle_outline
                        : delta > 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward;
                    final iconColor = isClosest
                        ? Colors.green
                        : delta > 0
                            ? Colors.orange
                            : Colors.blue;
                    return Card(
                      elevation: isClosest ? 3 : 0,
                      color: isClosest
                          ? scheme.primaryContainer.withValues(alpha: 0.4)
                          : null,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      child: ListTile(
                        dense: true,
                        leading: Icon(icon, color: iconColor, size: 20),
                        title: Text('NPS ${entry.npsLabel}',
                            style: TextStyle(
                                fontWeight: isClosest
                                    ? FontWeight.w600
                                    : FontWeight.w400)),
                        subtitle: Text(
                            'OD: ${_fmtOd(entry.odIn)}'),
                        trailing: Text(
                          _fmtDelta(entry.odIn, _odIn!),
                          style: TextStyle(
                              fontSize: 12,
                              color: isClosest
                                  ? Colors.green
                                  : Colors.grey),
                        ),
                      ),
                    );
                  }),

                  // ── Live schematic ───────────────────────────────────────────────
                  const SizedBox(height: 12),
                  Text('Live schematic', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 180,
                    child: CustomPaint(
                      painter: _LiveSchemePainter(
                        odIn: _odIn ?? 0,
                        baseColor: labelColor,
                      ),
                      size: const Size(double.infinity, 180),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}























