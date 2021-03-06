import 'package:easymoveinapp/pages/general_widgets/widget_loading_page.dart';
import 'package:easymoveinapp/pages/qrcode/show_data_qr.dart';
import 'package:easymoveinapp/sqlite/db.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DataEletric extends StatefulWidget {
  // Function getData;
  // DataEletric({Key key, this.getData}) : super(key: key);
  @override
  _DataEletricState createState() => _DataEletricState();
}

class _DataEletricState extends State<DataEletric> {
  bool loading = true;
  List<Tbl_mkrt_unit> dataList = [];
  getData() async {
    setState(() {
      dataList = [];
      loading = true;
    });
    final data = await DbModel().execDataTable(
        'SELECT DISTINCT mu.* FROM tbl_mkrt_units AS mu INNER JOIN tbl_electrics e ON e.unit_code = mu.unit_code');
    for (var e in data) {
      dataList.add(new Tbl_mkrt_unit(
          unit_code: e['unit_code'],
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
          sync_date: e['sync_date']));
    }
    setState(() {
      dataList = dataList;
      loading = false;
    });
  }

  navigateTo(Tbl_mkrt_unit res, String type) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => ShowDataQR(
                  res: res,
                  type: type,
                )),
        (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? WidgetLoadingPage()
        : RefreshIndicator(
            // ignore: missing_return
            onRefresh: () {
              getData();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 32),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: dataList.length,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (BuildContext content, int index) {
                    Tbl_mkrt_unit item = dataList[index];
                    return InkWell(
                      onTap: () {
                        navigateTo(item, "Electric");
                      },
                      child: Card(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.unit_code),
                            Text(item.customer_name),
                          ],
                        )),
                      )),
                    );
                  }),
            ),
          );
  }
}
