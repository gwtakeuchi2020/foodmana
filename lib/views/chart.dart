import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:bubble/bubble.dart';
import '../widget/app_bar.dart';
import '../common/beans.dart';
import '../common/controller.dart';

class GraphScreen extends StatefulWidget{
  const GraphScreen({Key? key}):super(key: key);
  
  @override
  _GraphState createState()=> _GraphState();
}

class _GraphState extends State<GraphScreen>{
  late TooltipBehavior _tooltipBehavior;
  late String _currentDropDown;
  List<ChartData> _graphData = [];
  late DateTime _currentDate;

  // グラフデータを取得
  Future<void> _createChartData() async {
    final total = await FirebaseFirestore.instance.collection('total').doc(Beans.userId).get();
    List<ChartData> res = [];
    if(total.data() != null) {
      // フィルター：日
      if(_currentDropDown == '日') {
        if((total.data() as Map).containsKey(DateFormat('yyyy-MM').format(_currentDate))) {
          (json.decode(total.data()![DateFormat('yyyy-MM').format(_currentDate)]) as Map).forEach((key, value) => res.add(ChartData(key as String, value as double)));
        }
      }
      // フィルター：月
      if(_currentDropDown == '月') {
        (total.data() as Map).forEach((key, value) {
          if((key as String).contains(DateFormat('yyyy').format(_currentDate)) && key.contains('_monthTotal')) {
            res.add(ChartData(key.substring(0,7), value));
          }
        });
      }
      // フィルター：年
      if(_currentDropDown == '年') {
        Map<String, double> yearTotal = {};
        (total.data() as Map).forEach((key, value) {
          if((key as String).contains('_monthTotal')) {
            yearTotal[key.substring(0,4)] = 
              yearTotal.containsKey(key.substring(0,4)) ? yearTotal[key.substring(0,4)]! + value : value as double;
          }
        });
        yearTotal.forEach((key, value) => res.add(ChartData(key, value)));
      }
    }
    setState(() => _graphData = res);
  }

  @override
  void initState(){
    super.initState(); 
    // ナビゲーションガード
    Controller.navigationGuard(context);

    _currentDropDown = Beans.chartFilter  ?? '日';
    _currentDate = Beans.currentDate ?? DateTime.now();
    _tooltipBehavior =  TooltipBehavior(enable: true, header: '合計', format: 'point.x : point.y円');
    // チャートの表示
    _createChartData();
  }
  
  // ウィジェット生成
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWiget.appbar(context, 'Chart'),
        body: Center(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: const Text('YT'),
                      ),
                      Bubble(
                        child: const Text('年月日でフィルタリングして、グラフを\n閲覧できるよ!', style: TextStyle(fontWeight: FontWeight.bold),),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('フィルタ: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        value: _currentDropDown,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        style: const TextStyle(color: Colors.pink),
                        underline: Container(
                          height: 2,
                          color: Colors.pink,
                        ),
                        onChanged: (String? newValue) {
                          setState(() => _currentDropDown = newValue!);
                          _createChartData();
                        },
                        items: <String>['年','月','日']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                  SfCartesianChart(
                    title: ChartTitle(text: '合計金額推移(円/$_currentDropDown)', textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                    tooltipBehavior: _tooltipBehavior,
                    primaryXAxis: CategoryAxis(), // カテゴリ軸の初期化
                    series: <ChartSeries>[
                      LineSeries(
                        color: Colors.orange,
                        dataSource: _graphData, 
                        xValueMapper: (data, _) => data.x,
                        yValueMapper: (data, _) => data.y,
                        markerSettings: const MarkerSettings(isVisible: true)
                      )
                    ],
                  ),
                ],
              ),
            )
        )
      );
  }
}

// データクラス(日付、値)
class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double? y;
}