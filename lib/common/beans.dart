// 共通変数格納クラス
class Beans {
  static String? _userId;
  static DateTime? _targetDate;
  static int? _monthTotal;
  static List? _purchaseList;

  // Getter
  static String? get userId => _userId;
  static DateTime? get targetDate => _targetDate;
  static int? get monthTotal => _monthTotal;
  static List? get purchaseList => _purchaseList;
  
  // Setter
  static setPurchaseList(List list) {
    _purchaseList = list;
  }
  static setTargetDate(DateTime date) {
    _targetDate = date;
  }
  static setMonthTotal(int monthTotal) {
    _monthTotal = monthTotal;
  }
  static setUserId(String userId) {
    _userId = userId;
  }
}