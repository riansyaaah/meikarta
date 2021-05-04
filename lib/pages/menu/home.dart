import 'dart:async';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:easymoveinapp/api/service.dart';
import 'package:easymoveinapp/models/post_qrcode_list.dart';
import 'package:easymoveinapp/models/post_qrcode_list_qc.dart';
import 'package:easymoveinapp/models/res_menus.dart';
import 'package:easymoveinapp/pages/auth/login.dart';
import 'package:easymoveinapp/pages/general_widgets/widget_progress.dart';
import 'package:easymoveinapp/pages/general_widgets/widget_snackbar.dart';
import 'package:easymoveinapp/pages/qrcode/tower_floor.dart';
import 'package:easymoveinapp/sqlite/db.dart';
import 'package:easymoveinapp/style/colors.dart';
import 'package:easymoveinapp/style/size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int index = 0;
  String sesBlock = "";
  String sesName = "";
  String title = "Meikarta App";
  bool permissionCamera = false;
  bool isConnect = true;
  List<Tbl_electric> listElectric = [];
  List<Tbl_water> listWater = [];
  List<Tbl_electrics_problem> listElectricPR = [];
  List<Tbl_waters_problem> listWaterPR = [];
  List<Tbl_mkrt_unit> listMkrtUnit = [];
  int countTempWater = 0;
  int countTempElectric = 0;
  int totalTemp = 0;
  List<Menu> menus = [];

  Timer timer;
  checkConnection() async {
    try {
      final result = await InternetAddress.lookup('easymovein.id');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (mounted)
          setState(() {
            isConnect = true;
          });
      }
    } on SocketException catch (_) {
      setState(() {
        isConnect = false;
      });
    }
  }

  displayDialog() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Confirmation')),
            content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 12,
                  ),
                  //USERNAME FIELD
                  Text("Are you sure exit this app ?")
                ]),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        left: SizeConfig.screenLeftRight1, bottom: 8),
                    child: Container(
                      width: SizeConfig.screenWidth * 0.3,
                      child: SizedBox(
                        height: SizeConfig.screenHeight * 0.045,
                        child: RaisedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          color: Colors.white,
                          child: Text(
                            "NO",
                            style: TextStyle(
                                color: ColorsTheme.text1,
                                fontSize: SizeConfig.fontSize4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        right: SizeConfig.screenLeftRight1, bottom: 8),
                    child: Container(
                      width: SizeConfig.screenWidth * 0.3,
                      child: SizedBox(
                        height: SizeConfig.screenHeight * 0.045,
                        child: RaisedButton(
                          onPressed: () {
                            goToLogin();
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          color: ColorsTheme.primary1,
                          child: Text(
                            "YES",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeConfig.fontSize4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false);
  }

  getRange() {
    getClient().getRangeInput().then((res) async {
      // Navigator.pop(context);
      if (res.status) {
      } else {
        WidgetSnackbar(context: context, message: res.remarks, warna: "merah");
      }
    }).catchError((Object obj) {
      WidgetSnackbar(
          context: context,
          message: "Failed connect to server!",
          warna: "merah");
    });
  }

  syncUpload() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => WidgetProgressSubmit());

    ModelPostQrCodeList dataPost = new ModelPostQrCodeList();
    List<WaterElectric> electrics = [];
    List<WaterElectric> waters = [];
    List<WaterElectricProblem> electricsProblem = [];
    List<WaterElectricProblem> watersProblem = [];
    var dataElectric = await Tbl_electrics_temp()
        .select()
        .orderBy("bulan")
        .orderBy("insert_date")
        .toList();
    var dataWater = await Tbl_waters_temp()
        .select()
        .orderBy("bulan")
        .orderBy("insert_date")
        .toList();
    var dataElectricProblem =
        await Tbl_electrics_temp_problem().select().toList();
    var dataWaterProblem = await Tbl_waters_temp_problem().select().toList();

    for (var e in dataElectric) {
      electrics.add(new WaterElectric(
          unitCode: e.unit_code,
          type: "Electric",
          bulan: e.bulan,
          tahun: e.tahun,
          nomorSeri: e.nomor_seri,
          pemakaian: e.pemakaian,
          foto: e.foto,
          insertBy: e.insert_by,
          insertDate: e.insert_date));
    }
    for (var w in dataWater) {
      waters.add(new WaterElectric(
          unitCode: w.unit_code,
          type: "Water",
          bulan: w.bulan,
          tahun: w.tahun,
          nomorSeri: w.nomor_seri,
          pemakaian: w.pemakaian,
          insertBy: w.insert_by,
          foto: w.foto,
          insertDate: w.insert_date));
    }
    for (var ep in dataElectricProblem) {
      electricsProblem.add(new WaterElectricProblem(
          unitCode: ep.unit_code,
          type: "READING",
          bulan: ep.bulan,
          tahun: ep.tahun,
          idxProblem: ep.idx_problem));
    }
    for (var wp in dataWaterProblem) {
      watersProblem.add(new WaterElectricProblem(
          unitCode: wp.unit_code,
          type: "READING",
          bulan: wp.bulan,
          tahun: wp.tahun,
          idxProblem: wp.idx_problem));
    }

    dataPost.electrics = electrics;
    dataPost.waters = waters;
    dataPost.electricsProblem = electricsProblem;
    dataPost.watersProblem = watersProblem;
    getClient().synchronize(dataPost).then((res) async {
      Navigator.pop(context);
      if (res.status) {
        await Tbl_electrics_temp().select().delete();
        await Tbl_waters_temp().select().delete();
        await Tbl_electrics_temp_problem().select().delete();
        await Tbl_waters_temp_problem().select().delete();
        if (dataElectric.length > 0 || dataElectricProblem.length > 0) {
          syncElectrics();
        }
        if (dataWater.length > 0 || dataWaterProblem.length > 0) {
          syncWaters();
        }
      } else {
        WidgetSnackbar(
            context: context, message: "Failed to upload", warna: "merah");
      }
    }).catchError((Object obj) {
      print(obj.toString());
      Navigator.pop(context);
      WidgetSnackbar(
          context: context,
          message: "Failed connect to server!",
          warna: "merah");
    });
  }

  syncUploadQC() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => WidgetProgressSubmit());

    ModelPostQrCodeListQc dataPost = new ModelPostQrCodeListQc();
    List<WaterElectricQc> electricsQC = [];
    List<WaterElectricQc> watersQC = [];
    List<WaterElectricProblem> electricsProblemQC = [];
    List<WaterElectricProblem> watersProblemQC = [];
    final dataElectricQC =
        await Tbl_electrics_temp_qc().select().orderBy("bulan").toList();
    final dataWaterQC =
        await Tbl_waters_temp_qc().select().orderBy("bulan").toList();
    final dataElectricProblemQC =
        await Tbl_electrics_temp_problem_qc().select().toList();
    final dataWaterProblemQC =
        await Tbl_waters_temp_problem_qc().select().toList();

    for (var e in dataElectricQC) {
      print(e.unit_code +
          " == " +
          e.tahun +
          " == " +
          e.bulan +
          " == " +
          e.qc_check +
          " == " +
          e.qc_date +
          " == " +
          e.qc_id.toString());
      electricsQC.add(new WaterElectricQc(
          unitCode: e.unit_code,
          bulan: e.bulan,
          tahun: e.tahun,
          qcCheck: e.qc_check,
          qcDate: e.qc_date,
          qcId: e.qc_id));
    }
    for (var w in dataWaterQC) {
      watersQC.add(new WaterElectricQc(
          unitCode: w.unit_code,
          bulan: w.bulan,
          tahun: w.tahun,
          qcCheck: w.qc_check,
          qcDate: w.qc_date,
          qcId: w.qc_id));
    }
    for (var ep in dataElectricProblemQC) {
      electricsProblemQC.add(new WaterElectricProblem(
          unitCode: ep.unit_code,
          type: "QC",
          bulan: ep.bulan,
          tahun: ep.tahun,
          idxProblem: ep.idx_problem));
    }
    for (var wp in dataWaterProblemQC) {
      watersProblemQC.add(new WaterElectricProblem(
          unitCode: wp.unit_code,
          type: "QC",
          bulan: wp.bulan,
          tahun: wp.tahun,
          idxProblem: wp.idx_problem));
    }
    dataPost.electricQc = electricsQC;
    dataPost.waterQc = watersQC;
    dataPost.electricsProblemQc = electricsProblemQC;
    dataPost.watersProblemQc = watersProblemQC;
    getClient().synchronizeQC(dataPost).then((res) async {
      Navigator.pop(context);
      if (res.status) {
        // await Tbl_electrics_temp_qc().select().delete();
        // await Tbl_waters_temp_qc().select().delete();
        // await Tbl_electrics_temp_problem_qc().select().delete();
        // await Tbl_waters_temp_problem_qc().select().delete();
        WidgetSnackbar(
            context: context,
            message: "Successfully Uploaded to Server",
            warna: "hijau");
        if (dataElectricQC.length > 0 || dataElectricProblemQC.length > 0) {
          syncElectrics();
        }
        if (dataWaterQC.length > 0 || dataWaterProblemQC.length > 0) {
          syncWaters();
        }
      } else {
        WidgetSnackbar(
            context: context, message: "Failed to upload", warna: "merah");
      }
    }).catchError((Object obj) {
      print(obj.toString());
      Navigator.pop(context);
      WidgetSnackbar(
          context: context,
          message: "Failed connect to server!",
          warna: "merah");
    });
  }

  syncUnits(String blocks) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => WidgetProgressSubmit());
    getClient().getUnits(blocks).then((res) async {
      Navigator.pop(context);
      if (res.status) {
        listMkrtUnit = res.mkrtUnit;
        await Tbl_mkrt_unit().select().blocks.equals(blocks).delete();
        final results = await Tbl_mkrt_unit().upsertAll(listMkrtUnit);
        WidgetSnackbar(context: context, message: res.remarks, warna: "hijau");
      } else {
        WidgetSnackbar(context: context, message: res.remarks, warna: "merah");
      }
    }).catchError((Object obj) {
      print(obj.toString());
      Navigator.pop(context);
      WidgetSnackbar(
          context: context,
          message: "Failed connect to server!",
          warna: "merah");
    });
  }

  syncElectrics() {
    print(sesBlock);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => WidgetProgressSubmit());
    getClient().getElectrics(sesBlock).then((res) async {
      Navigator.pop(context);
      if (res.status) {
        listElectric = res.listElectric;
        listElectricPR = res.listElectricProblem;
        await Tbl_electric().select().delete();
        final results = await Tbl_electric().upsertAll(listElectric);
        final results_pr =
            await Tbl_electrics_problem().upsertAll(listElectricPR);

        WidgetSnackbar(context: context, message: res.remarks, warna: "hijau");
      } else {
        WidgetSnackbar(context: context, message: res.remarks, warna: "merah");
      }
    }).catchError((Object obj) {
      Navigator.pop(context);
      WidgetSnackbar(
          context: context,
          message: "Failed connect to server!",
          warna: "merah");
    });
  }

  syncWaters() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => WidgetProgressSubmit());
    getClient().getWaters(sesBlock).then((res) async {
      Navigator.pop(context);
      if (res.status) {
        listWater = res.listWater;
        listWaterPR = res.listWaterPR;
        await Tbl_water().select().delete();
        await Tbl_waters_problem().select().delete();
        final results = await Tbl_water().upsertAll(listWater);
        final results_pr = await Tbl_waters_problem().upsertAll(listWaterPR);

        WidgetSnackbar(context: context, message: res.remarks, warna: "hijau");
      } else {
        WidgetSnackbar(context: context, message: res.remarks, warna: "merah");
      }
    }).catchError((Object obj) {
      Navigator.pop(context);
      WidgetSnackbar(
          context: context,
          message: "Failed connect to server!",
          warna: "merah");
    });
  }

  getLocalElectric() async {
    final el = await Tbl_electrics_temp().select().toList();
    setState(() {
      countTempElectric = el.length;
      totalTemp = countTempWater + countTempElectric;
    });
  }

  getLocalWater() async {
    final wa = await Tbl_waters_temp().select().toList();
    setState(() {
      countTempWater = wa.length;
      totalTemp = countTempWater + countTempElectric;
    });
  }

  getData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {});
    getClient().getMasterProblem().then((res) async {
      if (res.status) {
        List<Tbl_master_problem> listMasterProblem = res.dataProblem;
        await Tbl_master_problem().select().delete();
        await Tbl_master_problem().upsertAll(listMasterProblem);
      } else {
        WidgetSnackbar(
            context: context,
            message: "Failed get data problem",
            warna: "merah");
      }
    }).catchError((Object obj) {
      WidgetSnackbar(
          context: context,
          message: "Failed connect to server!",
          warna: "merah");
    });

    setState(() {
      sesBlock = preferences.getString("PREF_PICBLOCK");
      sesName = preferences.getString("PREF_FULLNAME");
      menus.add(Menu(
          appName: "Meter Air\nQC",
          titleName: "Meter Air QC",
          className: "QCAir",
          icons: ""));
      menus.add(Menu(
          appName: "Meter Listrik\nQC",
          titleName: "Meter Listrik QC",
          className: "QCListrik",
          icons: ""));
      menus.add(Menu(
          appName: "Meter Air\nReading",
          titleName: "Meter Air Reading",
          className: "ReadingAir",
          icons: ""));
      menus.add(Menu(
          appName: "Meter Listrik\nReading",
          titleName: "Meter Listrik Reading",
          className: "ReadingListrik",
          icons: ""));
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: TextStyle(color: ColorsTheme.primary1),
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    width: 0.5, color: Colors.white, style: BorderStyle.solid),
                color: isConnect ? ColorsTheme.hijau : ColorsTheme.merah,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: PopupMenuButton(
              padding: EdgeInsets.only(top: 20),
              offset: Offset(0, SizeConfig.screenHeight * 0.02),
              onSelected: (val) {
                if (val == "Logout") {
                  displayDialog();
                } else if (val == "Upload QC") {
                  syncUploadQC();
                } else if (val == "Upload Reading") {
                  syncUpload();
                } else if (val == "Sync Units") {
                  syncUnits(sesBlock);
                } else if (val == "Sync Electrics") {
                  syncElectrics();
                } else if (val == "Sync Waters") {
                  syncWaters();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  height: SizeConfig.screenHeight * 0.05,
                  child: Badge(
                      showBadge: totalTemp == 0 ? false : true,
                      badgeContent: Text(
                        totalTemp.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      position: BadgePosition.topEnd(top: -12, end: -20),
                      child: Text("Upload QC")),
                  value: "Upload QC",
                ),
                PopupMenuItem(
                  height: SizeConfig.screenHeight * 0.05,
                  child: Badge(
                      showBadge: totalTemp == 0 ? false : true,
                      badgeContent: Text(
                        totalTemp.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      position: BadgePosition.topEnd(top: -12, end: -20),
                      child: Text("Upload Reading")),
                  value: "Upload Reading",
                ),
                PopupMenuItem(
                  height: SizeConfig.screenHeight * 0.05,
                  child: Text("Sync Units"),
                  value: "Sync Units",
                ),
                PopupMenuItem(
                  height: SizeConfig.screenHeight * 0.05,
                  child: Text("Sync Electrics"),
                  value: "Sync Electrics",
                ),
                PopupMenuItem(
                  height: SizeConfig.screenHeight * 0.05,
                  child: Text("Sync Waters"),
                  value: "Sync Waters",
                ),
                PopupMenuItem(
                  height: SizeConfig.screenHeight * 0.05,
                  child: Text("Logout"),
                  value: "Logout",
                ),
              ],
              child: Icon(
                Icons.more_vert,
                color: ColorsTheme.primary1,
                size: SizeConfig.screenWidth * 0.07,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    " Hi, ",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    sesName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    color: ColorsTheme.primary1,
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: Text(
                        sesBlock,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              StaggeredGridView.count(
                padding: EdgeInsets.all(0),
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 1,
                physics: NeverScrollableScrollPhysics(),
                staggeredTiles: List.generate(
                    menus.length, (int index) => StaggeredTile.fit(1)),
                children: List.generate(
                  menus.length,
                  (i) {
                    return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TowerFloor(
                                      menu: menus[i], blocks: sesBlock)));
                        },
                        child: cardMenu(context, menus[i]));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardMenu(BuildContext context, Menu menu) {
    return Card(
      elevation: 2,
      child: Container(
        height: SizeConfig.screenHeight * 0.1,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Center(
              child: Text(
            menu.appName,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: SizeConfig.screenHeight * 0.02),
          )),
        ),
      ),
    );
  }
}