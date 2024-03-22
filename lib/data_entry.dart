import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';

class DataEntry extends StatefulWidget {
  const DataEntry({super.key});

  @override
  State<DataEntry> createState() => _DataEntryState();
}

class _DataEntryState extends State<DataEntry> {
  String? message;
  var metre = TextEditingController();
  var paid = TextEditingController();
  var mvrLtr = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _storage = const FlutterSecureStorage();

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> pushData({
    required String date, required double metre, required double paid,
    required double mvrLtr, required String credentials,
    required String sheetID, required String sheetName
  }) async {
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(sheetID);
    Worksheet? sheet = ss.worksheetByTitle(sheetName);

    if(sheet == null) {
      sheet = await ss.addWorksheet(sheetName);
      final firstRow = [
        'date', 'distance reading', 'paid', 'mvr/ltr', "travelled",
        "km/mvr", "fuel input (ltrs)", "km/ltr"
      ];
      await sheet.values.insertRow(1, firstRow);
    }

    var lastRow = await sheet.values.map.lastRow();
    double fuelInput = paid / mvrLtr;
    Map<String, dynamic> nextRow;

    if(lastRow == null) {
      nextRow = {
        'date': date,
        'distance reading': metre,
        'paid': paid,
        'mvr/ltr': mvrLtr,
        "travelled": "-",
        "km/mvr": "-",
        "fuel input (ltrs)": fuelInput,
        "km/ltr": "-",
      };
    } else {

      String prevTravelled0 = lastRow["distance reading"]!;
      double prevTravelled = double.parse(prevTravelled0);
      double travelled = metre-prevTravelled;
      double fuelInput = paid / mvrLtr;

      nextRow = {
        'date': date,
        'distance reading': metre,
        'paid': paid,
        'mvr/ltr': mvrLtr,
        "travelled": travelled,
        "km/mvr": travelled/paid,
        "fuel input (ltrs)": fuelInput,
        "km/ltr": travelled/fuelInput,
      };
    }

    await sheet.values.map.appendRow(nextRow);
  }

  Future<void> prepareData() async {
    String metreValue0 = metre.text;
    String paidValue0 = paid.text;
    String mvrLtrValue0 = mvrLtr.text;

    if(metreValue0.isEmpty || paidValue0.isEmpty || mvrLtrValue0.isEmpty) {
      return;
    }

    double metreValue;
    double paidValue;
    double mvrLtrValue;

    try {
      metreValue = double.parse(metreValue0);
      paidValue = double.parse(paidValue0);
      mvrLtrValue = double.parse(mvrLtrValue0);
    } on FormatException {
      message = "Invalid input";
      setState(() {

      });
      return;
    }

    if(DateTime.now().millisecondsSinceEpoch < _selectedDate.millisecondsSinceEpoch) {
      message = "Invalid input";
      setState(() {

      });
      return;
    }

    String? credentials = await _storage.read(key: "credentials");
    String? sheetID = await _storage.read(key: "sheetID");
    String? sheetName = await _storage.read(key: "sheetName");

    if(credentials == null || sheetID == null || sheetName == null) {
      message = "Invalid credentials";
      setState(() {

      });
      return;
    }

    String date = _formatDate(_selectedDate);

    await pushData(
        date: date, metre: metreValue, paid: paidValue, mvrLtr: mvrLtrValue,
        credentials: credentials, sheetID: sheetID, sheetName: sheetName
    );

    metre.clear();
    paid.clear();
    mvrLtr.clear();
    _selectedDate = DateTime.now();
    setState(() {

    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MMM-yy');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Container(
          //     width: 500,
          //     padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
          //     child: ElevatedButton(
          //       onPressed: (loadFile),
          //       child: const Text("Load File"),
          //     )
          // ),
          Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Text(
              "Selected Date: ${_formatDate(_selectedDate)}",
            )
          ),
          Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              child: const Text(
                "Select Date",
              ),
              onPressed: () {
                _selectDate(context);
              },
            )
          ),
          Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: metre,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Value on Distance Metre"
              )
            )
          ),
          Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: paid,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Amount Paid"
              )
            )
          ),
          Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: mvrLtr,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "MVR/ltr"
              )
            )
          ),
          Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: (prepareData),
              child: const Text("Enter"),
            )
          ),

          message != null ? Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Text(
              message ?? "",
              style: const TextStyle(
                  color: Colors.red
              ),
            )
          )
              : const SizedBox(),
        ],
      ),
    );
  }
}


