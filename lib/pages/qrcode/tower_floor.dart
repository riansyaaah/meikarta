import 'package:easymoveinapp/models/res_menus.dart';
import 'package:easymoveinapp/models/res_temp_problem.dart';
import 'package:easymoveinapp/pages/general_widgets/widget_loading_page.dart';
import 'package:easymoveinapp/pages/qrcode/floor_number.dart';
import 'package:easymoveinapp/sqlite/db.dart';
import 'package:easymoveinapp/style/colors.dart';
import 'package:easymoveinapp/style/size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';

class TowerFloor extends StatefulWidget {
  final Menu menu;
  final String blocks;
  TowerFloor({Key key, this.menu, this.blocks}) : super(key: key);
  @override
  _TowerFloorState createState() => _TowerFloorState();
}

class _TowerFloorState extends State<TowerFloor> {
  bool loading = true;
  String table = '';
  String tableServer = '';
  String title = "";
  String blocks = "";
  String tower = "1B";
  List<Tbl_mkrt_unit> dataList = [];
  List<Tbl_mkrt_unit> dataCheck = [];
  List<Tbl_mkrt_unit> dataHo = [];

  getData() async {
    setState(() {
      loading = true;
      dataList.clear();
      dataCheck.clear();
    });

    final data = await DbModel().execDataTable(
        "SELECT DISTINCT mu.blocks,  mu.tower, mu.floor FROM tbl_mkrt_units AS mu " +
            " WHERE mu.blocks = '" +
            widget.blocks +
            "' AND mu.tower = '" +
            tower +
            "' " +
            " ORDER by mu.floor ASC");
    for (var e in data) {
      final dataColor = await DbModel().execDataTable(
          "SELECT mu.* FROM tbl_mkrt_units AS mu " +
              " WHERE mu.blocks = '" +
              widget.blocks +
              "' AND mu.tower = '" +
              tower +
              "' AND mu.floor = '" +
              e['floor'] +
              "' ORDER by mu.floor ASC");

      for (var eC in dataColor) {
        dataCheck.add(new Tbl_mkrt_unit(
          unit_code: eC['unit_code'],
          blocks: eC['blocks'],
          tower: eC['tower'],
          floor: eC['floor'],
          water: eC['water'],
          electric: eC['electric'],
          ho: eC['ho'],
        ));
      }
      dataHo = dataCheck
          .where((i) => i.ho.contains('1') && i.floor.contains(e['floor']))
          .toList();
      List<Tbl_mkrt_unit> dataWater = dataCheck
          .where((i) =>
              i.water.contains('0') &&
              i.ho.contains('1') &&
              i.floor.contains(e['floor']))
          .toList();
      List<Tbl_mkrt_unit> dataElec = dataCheck
          .where((i) =>
              i.electric.contains('0') &&
              i.ho.contains('1') &&
              i.floor.contains(e['floor']))
          .toList();
      String hoCheck = '0';
      if (dataHo.length > 0) {
        hoCheck = '1';
      }

      String hoWater = "";
      String hoElec = "";
      if (widget.menu.className == 'QCListrik') {
        hoElec = '0';
        if (dataElec.length != dataHo.length) {
          List<Tbl_mkrt_unit> dataElecP = dataCheck
              .where((i) =>
                  i.electric.contains('4') &&
                  i.ho.contains('1') &&
                  i.floor.contains(e['floor']))
              .toList();
          List<Tbl_mkrt_unit> dataElecOK = dataCheck
              .where((i) =>
                  (i.electric.contains('1') ||
                      i.electric.contains('2') ||
                      i.electric.contains('3')) &&
                  i.ho.contains('1') &&
                  i.floor.contains(e['floor']))
              .toList();
          int totalQC = dataElecP.length + dataElecOK.length;
          if (totalQC == dataHo.length) {
            hoElec = '1';
          } else if (totalQC != dataHo.length) {
            hoElec = '4';
          }
        }
      } else if (widget.menu.className == 'QCAir') {
        hoWater = '0';
        if (dataWater.length != dataHo.length) {
          List<Tbl_mkrt_unit> dataWaterP = dataCheck
              .where((i) =>
                  i.water.contains('4') &&
                  i.ho.contains('1') &&
                  i.floor.contains(e['floor']))
              .toList();
          List<Tbl_mkrt_unit> dataWaterOK = dataCheck
              .where((i) =>
                  (i.water.contains('1') ||
                      i.water.contains('2') ||
                      i.water.contains('3')) &&
                  i.ho.contains('1') &&
                  i.floor.contains(e['floor']))
              .toList();
          int totalQC = dataWaterP.length + dataWaterOK.length;
          if (totalQC == dataHo.length) {
            hoWater = '1';
          } else if (totalQC != dataHo.length) {
            hoWater = '4';
          }
        }
      } else if (widget.menu.className == 'ReadingListrik') {
        hoElec = '1';
        if (dataElec.length != dataHo.length) {
          String dataElecP =
              await getDatatempServerPRReading(blocks, tower, e['floor']);
          String dataElecOK =
              await getDatatempServerOKReading(blocks, tower, e['floor']);
          int totalReading = int.parse(dataElecP) + int.parse(dataElecOK);
          if (totalReading == dataHo.length) {
            hoElec = '2';
          } else if (totalReading != dataHo.length && totalReading != 0)
            hoElec = '3';
        }
      } else if (widget.menu.className == 'ReadingAir') {
        hoWater = '1';

        if (dataWater.length != dataHo.length) {
          String dataWaterP =
              await getDatatempServerPRReading(blocks, tower, e['floor']);
          String dataWaterOK =
              await getDatatempServerOKReading(blocks, tower, e['floor']);
          int totalReading = int.parse(dataWaterP) + int.parse(dataWaterOK);
          if (totalReading == dataHo.length) {
            hoWater = '2';
          } else if (totalReading != dataHo.length && totalReading != 0)
            hoWater = '3';

          // print(blocks +
          //     "-" +
          //     tower +
          //     "-" +
          //     e['floor'] +
          //     " - " +
          //     dataWaterP.toString());
        }
      }

      dataList.add(new Tbl_mkrt_unit(
          unit_code: e['unit_code'],
          blocks: e['blocks'],
          tower: e['tower'],
          floor: e['floor'],
          customer_name: e['customer_name'],
          customer_address: e['customer_address'],
          email: e['email'],
          electric_id: e['electric_id'],
          water_id: e['water_id'],
          phone: e['phone'],
          pppu: e['pppu'],
          date_pppu: e['date_pppu'],
          date_ho: e['date_ho'],
          eligible: e['eligible'],
          tanggal_dari: e['tanggal_dari'],
          tanggal_sampai: e['tanggal_sampai'],
          ho: hoCheck,
          water: hoWater,
          electric: hoElec,
          water_color: e['water_color'],
          electric_color: e['electric_color'],
          sync_date: e['sync_date']));
    }
    setState(() {
      dataList = dataList;
      dataCheck = dataCheck;
      loading = false;
      dataHo = dataHo;
    });
  }

  setTower(String tw) {
    setState(() {
      tower = tw;
    });
    getData();
  }

  Future<String> strResultTemp(Tbl_mkrt_unit dataList) async {
    String blocks = dataList.blocks;
    String tower = dataList.tower;
    String floor = dataList.floor;
    String unit = blocks + "-" + tower + "-" + floor + "-" + floor;

    List<ModelTempProblem> resData = await getDatatemp(unit);
    String resDataServer = await getDatatempServer(blocks, tower, floor);
    String resDataServerHO = await getDatatempServerHO(blocks, tower, floor);
    String result;
    List dataSuccess = resData.where((i) => i.problem.contains('1')).toList();
    List dataProblem = resData.where((i) => i.problem.contains('2')).toList();
    int total = dataSuccess.length + dataProblem.length;

    if (resData.length == 0) {
      result = '0';
    } else if (total == int.parse(resDataServerHO) ||
        resDataServer == resDataServerHO ||
        total + int.parse(resDataServer) >= int.parse(resDataServerHO)) {
      result = '1';
    } else {
      result = '2';
    }
    return result;
  }

  Future<List<ModelTempProblem>> getDatatemp(unit) async {
    DateTime now = DateTime.now();
    if (now.day >= 19) {
      now = new DateTime(now.year, now.month + 1, now.day);
    }
    String tahun = DateFormat('y').format(now);
    String bulan = DateFormat('MM').format(now);
    List<ModelTempProblem> resData = [];
    final data = await DbModel().execDataTable("SELECT * FROM " +
        table +
        " WHERE unit_code LIKE '" +
        unit +
        "%' AND tahun = '" +
        tahun +
        "' AND bulan = '" +
        bulan +
        "' ");
    for (var i in data) {
      String problem;
      if (widget.menu.className == 'QCListrik' ||
          widget.menu.className == 'QCAir') {
        problem = i['qc_check'];
      } else {
        problem = i['problem'];
      }
      resData.add(ModelTempProblem(
        unitCode: i['unit_code'],
        tahun: i['tahun'],
        bulan: i['bulan'],
        problem: problem,
      ));
    }
    return resData;
  }

  Future<String> getDatatempServer(blocks, tower, floor) async {
    DateTime now = DateTime.now();
    if (now.day >= 19) {
      now = new DateTime(now.year, now.month + 1, now.day);
    }
    List<Tbl_mkrt_unit> resData = [];
    if (widget.menu.className == 'QCListrik' ||
        widget.menu.className == 'ReadingListrik') {
      resData = await Tbl_mkrt_unit()
          .distinct(columnsToSelect: ["unit_code", "electric"])
          .blocks
          .equals(blocks)
          .and
          .tower
          .equals(tower)
          .and
          .floor
          .equals(floor)
          .and
          .electric
          .inValues(["1", "2", "3", "4"])
          .toList();
      if (widget.menu.className == 'ReadingListrik') {
        resData = resData
            .where((i) => i.electric == "2" || i.electric == "3")
            .toList();
      }
    } else {
      resData = await Tbl_mkrt_unit()
          .distinct(columnsToSelect: ["unit_code", "water"])
          .blocks
          .equals(blocks)
          .and
          .tower
          .equals(tower)
          .and
          .floor
          .equals(floor)
          .toList();
      if (widget.menu.className == 'ReadingAir') {
        resData = resData
            .where((i) => i.electric == "2" || i.electric == "3")
            .toList();
      }
    }
    return resData.length.toString();
  }

  Future<String> getDatatempServerPRReading(blocks, tower, floor) async {
    DateTime now = DateTime.now();
    if (now.day >= 19) {
      now = new DateTime(now.year, now.month + 1, now.day);
    }
    List<Tbl_mkrt_unit> resData = [];
    if (widget.menu.className == 'ReadingListrik') {
      resData = await Tbl_mkrt_unit()
          .distinct(columnsToSelect: ["unit_code", "electric"])
          .blocks
          .equals(blocks)
          .and
          .tower
          .equals(tower)
          .and
          .floor
          .equals(floor)
          .and
          .electric
          .inValues(["3"])
          .toList();
    } else if (widget.menu.className == 'ReadingAir') {
      resData = await Tbl_mkrt_unit()
          .distinct(columnsToSelect: ["unit_code", "water"])
          .blocks
          .equals(blocks)
          .and
          .tower
          .equals(tower)
          .and
          .floor
          .equals(floor)
          .and
          .water
          .equals("3")
          .toList();
    }
    return resData.length.toString();
  }

  Future<String> getDatatempServerOKReading(blocks, tower, floor) async {
    DateTime now = DateTime.now();
    if (now.day >= 19) {
      now = new DateTime(now.year, now.month + 1, now.day);
    }
    List<Tbl_mkrt_unit> resData = [];
    if (widget.menu.className == 'ReadingListrik') {
      resData = await Tbl_mkrt_unit()
          .distinct(columnsToSelect: ["unit_code", "electric"])
          .blocks
          .equals(blocks)
          .and
          .tower
          .equals(tower)
          .and
          .floor
          .equals(floor)
          .and
          .electric
          .inValues(["2"])
          .toList();
    } else {
      resData = await Tbl_mkrt_unit()
          .distinct(columnsToSelect: ["unit_code", "water"])
          .blocks
          .equals(blocks)
          .and
          .tower
          .equals(tower)
          .and
          .floor
          .equals(floor)
          .and
          .water
          .inValues(["2"])
          .toList();
    }
    return resData.length.toString();
  }

  Future<String> getDatatempServerHO(blocks, tower, floor) async {
    DateTime now = DateTime.now();
    if (now.day >= 19) {
      now = new DateTime(now.year, now.month + 1, now.day);
    }
    List<Tbl_mkrt_unit> resData = [];
    resData = await Tbl_mkrt_unit()
        .distinct(columnsToSelect: ["unit_code"])
        .blocks
        .equals(blocks)
        .and
        .tower
        .equals(tower)
        .and
        .floor
        .equals(floor)
        .and
        .ho
        .equals("1")
        .toList();
    return resData.length.toString();
  }

  @override
  void initState() {
    super.initState();
    getData();
    title = widget.menu.titleName;
    blocks = widget.blocks;
    if (widget.menu.className == 'QCListrik') {
      table = 'tbl_electrics_temp_qc';
      tableServer = 'tbl_electrics';
    } else if (widget.menu.className == 'QCAir') {
      table = 'tbl_waters_temp_qc';
      tableServer = 'tbl_waters';
    } else if (widget.menu.className == 'ReadingListrik') {
      table = 'tbl_electrics_temp';
      tableServer = 'tbl_electrics';
    } else if (widget.menu.className == 'ReadingAir') {
      table = 'tbl_waters_temp';
      tableServer = 'tbl_waters';
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorsTheme.primary1),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: TextStyle(color: ColorsTheme.primary1),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        blocks + '-' + tower,
                        style: TextStyle(
                            color: ColorsTheme.primary1,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Card(
                      color:
                          tower == '1B' ? ColorsTheme.primary1 : Colors.white,
                      child: InkWell(
                        onTap: () {
                          setTower('1B');
                        },
                        child: Container(
                          width: SizeConfig.screenWidth * 0.2,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                "1B",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: tower == '1B'
                                        ? Colors.white
                                        : ColorsTheme.primary1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      color:
                          tower == '2B' ? ColorsTheme.primary1 : Colors.white,
                      child: InkWell(
                        onTap: () {
                          setTower('2B');
                        },
                        child: Container(
                          width: SizeConfig.screenWidth * 0.2,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                "2B",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: tower == '2B'
                                        ? Colors.white
                                        : ColorsTheme.primary1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6),
              loading
                  ? WidgetLoadingPage()
                  : StaggeredGridView.count(
                      padding: EdgeInsets.all(0),
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      mainAxisSpacing: 1,
                      physics: NeverScrollableScrollPhysics(),
                      staggeredTiles: List.generate(
                          dataList.length, (int index) => StaggeredTile.fit(1)),
                      children: List.generate(
                        dataList.length,
                        (i) {
                          return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FloorNumber(
                                            menu: widget.menu,
                                            mkrtUnit: dataList[i])));
                              },
                              child: cardLantai(
                                  context, dataList[i], widget.menu.className));
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardLantai(
      BuildContext context, Tbl_mkrt_unit dataList, String param) {
    Color bgColor = Colors.black;
    Color fontColor = Colors.white;
    return FutureBuilder(
        future: strResultTemp(dataList),
        builder: (_, snapshot) {
          bool isLocal = false;
          String tempData = snapshot.data;
          if (dataList.ho == '1') {
            if (tempData != '0') {
              isLocal = true;
              if (tempData == '1') {
                bgColor = Colors.green[800];
                fontColor = Colors.white;
              } else {
                bgColor = Colors.yellow[600];
                fontColor = Colors.black;
              }
            } else {
              if (param == 'QCListrik') {
                if (dataList.electric == '0') {
                  bgColor = Colors.red[800];
                  fontColor = Colors.white;
                } else if (dataList.electric == '1') {
                  bgColor = Colors.green[800];
                  fontColor = Colors.white;
                } else if (dataList.electric == '4') {
                  bgColor = Colors.yellow[600];
                  fontColor = Colors.black;
                }
              } else if (param == 'QCAir') {
                if (dataList.water == '0') {
                  bgColor = Colors.red[800];
                  fontColor = Colors.white;
                } else if (dataList.water == '1') {
                  bgColor = Colors.green[800];
                  fontColor = Colors.white;
                } else if (dataList.water == '4') {
                  bgColor = Colors.yellow[600];
                  fontColor = Colors.black;
                }
              } else if (param == 'ReadingListrik') {
                if (dataList.electric == '1') {
                  bgColor = Colors.red[800];
                  fontColor = Colors.white;
                } else if (dataList.electric == '2') {
                  bgColor = Colors.green[800];
                  fontColor = Colors.white;
                } else if (dataList.electric == '3') {
                  bgColor = Colors.yellow[600];
                  fontColor = Colors.black;
                }
              } else if (param == 'ReadingAir') {
                if (dataList.water == '1') {
                  bgColor = Colors.red[800];
                  fontColor = Colors.white;
                } else if (dataList.water == '2') {
                  bgColor = Colors.green[800];
                  fontColor = Colors.white;
                } else if (dataList.water == '3') {
                  bgColor = Colors.yellow[600];
                  fontColor = Colors.black;
                }
              }
            }
          }

          if (snapshot.hasData) {
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 2,
              child: Container(
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.only(topLeft: const Radius.circular(20.0)),
                  borderRadius: BorderRadius.circular(8),
                  color: bgColor,
                ),
                height: SizeConfig.screenHeight * 0.1,
                child: Stack(
                  children: [
                    isLocal
                        ? Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8)),
                                color: ColorsTheme.primary1,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  'LOCAL',
                                  style: TextStyle(
                                      fontSize: 8, color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(
                          child: Text(
                        dataList.floor,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: fontColor,
                            fontSize: SizeConfig.screenHeight * 0.02),
                      )),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return WidgetLoadingPage();
          }
        });
  }
}
