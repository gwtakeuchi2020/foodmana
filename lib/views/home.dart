import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:bubble/bubble.dart';
import 'dart:async';
import '../common/beans.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({Key? key}):super(key: key);
  
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen>{
  final int _monthTotal = 1234; //月合計変数
  late int _dayTotal; //日合計変数
  late List _list;
  DateTime _date = DateTime.now();

  // デートピッカー取得メソッド
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2015),
        lastDate: DateTime.now(),
        locale: const Locale('ja'),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light().copyWith(
                primary: Colors.purple[300],
              ),
            ),
            child: child!,
          );
        }
    );
    if(picked!=null) setState(() => _date = picked); // 変数名+!でnull判定できるっぽい
  }

  // 購入品リストに要素を追加
  void _addList({String? addItem, int? addPrice}) {
    if(addItem != null && addPrice != null) {
      setState(() => _list.insert(0, {'name': addItem, 'price':addPrice}));
      _updateTotal(addPrice, true);
    }
    Navigator.pop(context);
  }
  // 購入品リストの要素を削除
  void _removeList(removeItem) {
    setState(() => _list.remove(removeItem));
    _updateTotal(removeItem['price'], false);
  }

  // 合計金額の更新
  void _updateTotal(int? newPrice, bool direction) {
    setState(() => direction ? _dayTotal += newPrice! : _dayTotal -= newPrice!);
  }
  // ポップアップ表示メソッド
  void _popUp() {
    String? addItem;
    int? addPrice;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('購入品の追加', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          height: 150,
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  label: Text('名称')
                ),
                onChanged: (value) => addItem = value.toString(),
              ),
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[ 
                    FilteringTextInputFormatter.digitsOnly // 数字入力のみ許可する
                ], 
                decoration: const InputDecoration(
                  label: Text('金額')
                ),
                onChanged: (value) => {if(double.tryParse(value) != null) {addPrice = int.parse(value)}},
              )
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text('キャンセル', style: TextStyle(color: Colors.white, fontSize: 20)),
            style: ElevatedButton.styleFrom(
              primary: Colors.red,
              onPrimary: Colors.white,
              shape: const StadiumBorder(),
            ),
            onPressed: () => Navigator.pop(context)
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
              onPrimary: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: const Text('追 加', style: TextStyle(color: Colors.white, fontSize: 20)),
            onPressed: () =>_addList(addItem:addItem, addPrice:addPrice)
          )
        ],
      )
    );
  }

  // 値の初期化
  @override
  void initState() {
    super.initState();
    // 購入リストを取得
    setState(()=> _list = (Beans.purchaseList ?? []));

    // 日合計の算出
    num total = 0;
    for (var item in _list) {
      total += item['price'];
    }setState(() => _dayTotal = total.toInt());
  }

  // ウィジェット記述 
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple[300],
          title: const Text(
            'Home',
            style: TextStyle(fontSize: 16),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Center(
                // ignore: deprecated_member_use
                child: FlatButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Chip(
                        label: Text('対象日付',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          )
                        ),
                        backgroundColor: Colors.orange,
                      ),
                      Text(DateFormat('yyyy-MM-dd').format(_date),
                        style: const TextStyle(fontSize: 30,)
                      ),
                    ],
                  ),
                  onPressed: () => _selectDate(context)
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Chip(
                    padding: const EdgeInsets.all(10),
                    backgroundColor: Colors.red[100],
                    label: Column(
                      children: [
                        const Chip(
                          label: Text('月合計', style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            
                          )),
                          backgroundColor: Colors.red,
                        ),
                        Text('$_monthTotal 円', style: const TextStyle(fontSize: 30)),
                      ],
                    ),
                  ),
                  Chip(
                    padding: const EdgeInsets.all(10),
                    backgroundColor: Colors.green[100],
                    label: Column(
                      children: [
                        const Chip(
                          label: Text('日合計', style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                          )),
                          backgroundColor: Colors.green,
                        ),
                        Text('$_dayTotal 円', style: const TextStyle(fontSize: 30))
                      ]
                    ) 
                  )
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: const Text('YT'),
                  ),
                  Bubble(
                    child: const Text('購入した商品の登録、閲覧ができるよ!', style: TextStyle(fontWeight: FontWeight.bold),),
                  )
                ],
              ),
              Center(
                child: Column(
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          WidgetSpan(
                            child: Icon(Icons.shopping_cart),
                          ),
                          TextSpan(text: '今日の購入品', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange, width: 3),
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 253, 247, 239)
                      ),
                      height: 400,
                      child: ListView(
                        padding: const EdgeInsets.only(right: 15),
                        children: [
                          for(var item in _list) Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      child: IconButton(
                                        hoverColor: Colors.white,
                                        splashRadius: 5,
                                        onPressed: ()=>_removeList(item),
                                        icon: const Icon(Icons.clear,color: Colors.red,)
                                      ),
                                    ),
                                    TextSpan(text: item['name'], style: const TextStyle(fontSize: 20, color: Colors.black)),
                                  ],
                                ),
                              ),
                              Text(item['price'].toString() + '円', style: const TextStyle(fontSize: 20), textAlign: TextAlign.end),
                            ],
                          )
                        ],
                      ) 
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          child: const Icon(Icons.add),
                          onPressed: () => _popUp()
                        )
                      ],
                    )
                  ],
                )
              )
            ],
          )
        )
      );
  }
  @override
  void dispose() {
    Beans.setPurchaseList(_list);
    super.dispose();
  }
}