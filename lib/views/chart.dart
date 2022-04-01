import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:bubble/bubble.dart';
import '../widget/app_bar.dart';

class GraphScreen extends StatefulWidget{
  const GraphScreen({Key? key}):super(key: key);
  
  @override
  _GraphState createState()=> _GraphState();
}

class _GraphState extends State<GraphScreen>{
  late TooltipBehavior _tooltipBehavior;
  late String _currentDropDown;
  late DateTime _currentDate; // 現在年月日

  // グラフデータを取得
  List<ChartData> _createChartData() {
    if(_currentDropDown == '月') {
      return [
        ChartData('Jan', 2035),
        ChartData('Feb', 4028),
        ChartData('Mar', 6034),
        ChartData('Apr', 7032),
        ChartData('May', 4040),
        ChartData('Jun', 5040),
        ChartData('Jul', 6020),
        ChartData('Aug', 8015),
        ChartData('Sep', 1017),
        ChartData('Oct', 2030),
        ChartData('Nov', 3038),
        ChartData('Dec', 4040),
      ];
    }
    if(_currentDropDown == '日') {
      return [
        ChartData('1日', 1035),
        ChartData('2日', 1028),
        ChartData('3日', 1034),
        ChartData('4日', 1032),
        ChartData('5日', 1040),
        ChartData('6日', null),
        ChartData('7日', 1020),
        ChartData('8日', 1015),
        ChartData('9日', 1017),
        ChartData('10日', 1030),
        ChartData('11日', 1038),
        ChartData('12日', 1040),
      ];
    }
    return [
      ChartData('2012', 3035),
      ChartData('2013', 5028),
      ChartData('2014', 6034),
      ChartData('2015', 3032),
      ChartData('2016', 3040),
      ChartData('2017', 4040),
      ChartData('2018', 5020),
      ChartData('2019', 6015),
      ChartData('2020', 2017),
      ChartData('2021', 3030),
      ChartData('2022', 6038),
    ];
  }

  @override
  void initState(){
    _currentDropDown = '日';
    _tooltipBehavior =  TooltipBehavior(enable: true, header: '合計', format: 'point.x : point.y円');
    _currentDate = DateTime.now();
    super.initState(); 
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
                          setState(() {
                            _currentDropDown = newValue!;
                          });
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
                        dataSource: _createChartData(), 
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