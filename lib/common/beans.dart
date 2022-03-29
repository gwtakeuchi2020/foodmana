// 共通変数格納クラス
class Beans {
  static List? _purchaseList;

  // Getter
  static List? get purchaseList => _purchaseList;
  
  // Setter
  static setPurchaseList(List list){
    _purchaseList = list;
  }
}