// 共通変数格納クラス
class Beans {
  /*---------------------------------------------------------------
    共通項目
  -----------------------------------------------------------------*/
  static String? _userId;
  
  // Getter
  static String? get userId => _userId;
  
  // Setter
  static setUserId(String userId) {
    _userId = userId;
  }

  /* -------------------------------------------------------------
    ホーム画面 
  ----------------------------------------------------------------*/
  static DateTime? _targetDate;
  static int? _monthTotal;
  static List? _purchaseList;
  
  // Getter
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

  /* -------------------------------------------------------------
    グラフ画面
  ----------------------------------------------------------------*/
  static String? _chartFilter;
  static DateTime? _currentDate;

  // Getter
  static String? get chartFilter => _chartFilter;
  static DateTime? get currentDate => _currentDate;

  // Setter
  static void setChartFilter(String chartFilter) {
    _chartFilter = chartFilter;
  }
  static void setCurrentDate(DateTime currentDate) {
    _currentDate = currentDate;
  }
}