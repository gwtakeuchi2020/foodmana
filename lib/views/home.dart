import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:bubble/bubble.dart';
import 'dart:async';
import '../common/beans.dart';
import '../common/controller.dart';
import '../widget/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomeScreen extends StatefulWidget{
  const HomeScreen({Key? key}):super(key: key);
  
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen>{
  int _monthTotal = 0; //月合計変数
  int _dayTotal = 0; //日合計変数
  List _list = [];
  late DateTime _date;

  // 購入品リスト取得
  Future<void> _getPurchaseList() async{
    setState(()=> _list = (Beans.purchaseList == null || Beans.purchaseList!.isEmpty ? [] : Beans.purchaseList!));
    if(Beans.purchaseList == null || Beans.purchaseList!.isEmpty) {
      final list = await FirebaseFirestore.instance.collection('purchase').doc('${Beans.userId}').get();
      if(list.data()!=null && list.data()!.containsKey(DateFormat('yyyy-MM-dd').format(_date))) {
        setState(()=> _list = list.exists ? json.decode(list.data()![DateFormat('yyyy-MM-dd').format(_date)]) as List : []);
      }
    }
    // 日合計の算出
    num total = 0;
    for (var item in _list) {
      total += item['price'];
    }
    setState(() => _dayTotal = total.toInt());
  }

  // 月合計取得
  Future<void> _getMonthTotal() async{
    if(Beans.monthTotal == null || Beans.monthTotal == 0) {
      final totalList = await FirebaseFirestore.instance.collection('total')
        .doc('${Beans.userId}')
        .get();
      int monthTotal = 0;
      if(totalList.data() != null && (totalList.data() as Map).containsKey(DateFormat('yyyy-MM').format(_date) + '_monthTotal')) {
        monthTotal = totalList.data()![DateFormat('yyyy-MM').format(_date) + '_monthTotal'] as int;
      }
      setState(() => _monthTotal = monthTotal);
    }else{
      setState(() => _monthTotal = Beans.monthTotal ?? 0);
    }
  }

  // デートピッカー取得メソッド(& 値更新)
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
                primary: Colors.pink[200],
              ),
            ),
            child: child!,
          );
        }
    );
    // 対象日付が変更された場合、画面とDBを更新
    if(picked!=null) {
      // 日付変更前にDBを更新しておく(後の処理でDBから値を取得するため、同期敵にする必要あり await)
      await updatePurchase();
      await updateDayTotal();
      // 日付変更後の変数変更
      setState(() => _date = picked);
      Beans.setTargetDate(_date);
      Beans.setPurchaseList([]);
      Beans.setMonthTotal(0);
      // 更新後値取得
      _getPurchaseList();
      _getMonthTotal();
    }
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
    setState(() => direction ? _monthTotal += newPrice! : _monthTotal -= newPrice!);
  }

  // 購入品の一括更新
  Future<void> updatePurchase() async {
    final doc = await FirebaseFirestore.instance
      .collection('purchase')
      .doc('${Beans.userId}')
      .get();
    if(doc.exists) {
      await FirebaseFirestore.instance
      .collection('purchase')
      .doc('${Beans.userId}').update({
        DateFormat('yyyy-MM-dd').format(_date) : json.encode(_list)
      });
    }else{
      await FirebaseFirestore.instance
      .collection('purchase')
      .doc('${Beans.userId}').set({
        DateFormat('yyyy-MM-dd').format(_date) : json.encode(_list)
      });
    }
  }

  // 日合計の一括登録
  Future<void> updateDayTotal() async {
    // 日合計の更新
    final total = await FirebaseFirestore.instance
      .collection('total')
      .doc('${Beans.userId}')
      .get();
    if(total.exists && (total.data() as Map).containsKey(DateFormat('yyyy-MM').format(_date))) {
      Map result = json.decode(total.data()![DateFormat('yyyy-MM').format(_date)]) as Map;
      result[DateFormat('yyyy-MM-dd').format(_date)] = _dayTotal;
      await FirebaseFirestore.instance
      .collection('total')
      .doc('${Beans.userId}').update({
        DateFormat('yyyy-MM').format(_date) + '_monthTotal': _monthTotal,
        DateFormat('yyyy-MM').format(_date) : json.encode(result)
      });
    }else{
      await FirebaseFirestore.instance
      .collection('total')
      .doc('${Beans.userId}')
      .set({
        DateFormat('yyyy-MM').format(_date) + '_monthTotal': _monthTotal,
        DateFormat('yyyy-MM').format(_date): json.encode({DateFormat('yyyy-MM-dd').format(_date) : _dayTotal})
      }, SetOptions(merge: true)); // マージをすることで値の追加となる
    }
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
            onPressed: () async {
                _addList(addItem:addItem, addPrice:addPrice);
              },
          )
        ],
      )
    );
  }

  // 値の初期化
  @override
  void initState() {
    super.initState();
    // ナビゲーションガード
    Controller.navigationGuard(context);
    // 対象日付
    _date = Beans.targetDate != null ? Beans.targetDate! : DateTime.now();
    // 購入品リスト取得
    _getPurchaseList();
    // 月合計取得
    _getMonthTotal();
  }

  // ウィジェット記述 
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWiget.appbar(context, 'Home'),
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

  // Home画面破棄時処理
  @override
  Future<void> dispose() async{
    super.dispose();
    // 画面側の共通変数を更新
    Beans.setPurchaseList(_list);
    Beans.setTargetDate(_date);
    Beans.setMonthTotal(_monthTotal);
    // 購入品の一括登録
    updatePurchase();
    // 日合計の一括登録
    updateDayTotal();
  }
}