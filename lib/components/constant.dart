/*Store all constant values here*/

class Constant {
  static final String NO_PREF_FOUND = "prefNot_found";
  static final String TERMINAL_KEY = "TerminalKey";
  static final String IS_JOIN_SERVER = "isJoinSever";
  static final String SERVER_IP = "serverIp";
  static final String BRANCH_ID = "branchId";
  static final String LOIGN_USER = "Login_user";
  static final String IS_USER_LOGIN = "isUserLogin";
  static final String LAGUAGE_CODE = 'languageCode';
  static final String LastSync_Table = "LastSync_Table";
  static final String lastAppVersion = "lastAppVersion";
  static final String IS_SHIFT_OPEN = "IS_SHIFT_OPENE";
  static final String IS_FIRST_TIME_SYNC = "firsttimeSync";
  static final String SERVER_DATE_TIME = "ServertDateTime";
  static final String ORDER_SERVER_DATE_TIME = "orderServerTime";
  static final String SERVER_TIME_ZONE = "ServertTimeZone";
  static final String TABLE_DATA = "table_id";
  static final String CUSTOMER_DATA = "customerData";
  static final String CUSTOMER_DATA_SPLIT = "customerDataSplit";
  static final String IS_CHECKIN = "Checkin";
  static final String IS_CHECKOUT = "Checkout";
  static final String SHIFT_ID = "Shift_Id";
  static final String DASH_SHIFT = "dashShift";
  static final String IS_LOGIN = "IsLogin";
  static final String MANAGER = "manager";
  static final String SYNC_TIMER = "syncTimer";
  static final String CURRENCY = "Currency";
  static final String OFFSET = "image_offset";
  // static final String USER_ROLE = "Roledata";
  static final String USER_PERMISSION = "user_permission";
  static final String IS_AUTO_SYNC = "is_Ayto_Sync";
  static final String isPausePrint = "isPausePrint";
  static final String lastOrderId = "lastOrderId";

  /*==============================================================================
                              Manage Permission  status
  =================================================================================*/

  //static final String VIEW_ORDER = "view_order";
  //static final String ADD_ORDER = "add_order";
  //static final String EDIT_ORDER = "edit_order";
  //static final String DELETE_ORDER = "delete_order";

  // static final String VIEW_ITEM = "view_item";
  // static final String ADD_ITEM = "add_item";
  // static final String DELETE_ITEM = "delete_item";

  // static final String VIEW_REPORT = "view_report";
  // static final String ADD_REPORT = "add_report";
  // static final String EDIT_REPORT = "edit_report";
  // static final String DELETE_REPORT = "delete_report";
  // static final String OPEN_DRAWER = "viewOpen_drawer";
  static final String PRINT_RECIEPT = "print_receipt";
  static final String VIEW_SYNC = "opening"; //"sync";
  static final String ADD_ORDER = "opening"; //"ADD_ORDER"
  static final String EDIT_ITEM = "opening"; //"EDIT_ITEM"
  static final String DELETE_ITEM = "delete_item";
  static final String DELETE_ORDER = "delete_order";
  static final String OPEN_DRAWER = "open_drawer";
  static final String viewSystemAmount = "view_system_amount";
  static final String viewSalesAmount = "view_sales_amount";
  static final String addReservation = "add_reservation";
  static final String CASH_IN = "cash_in";
  static final String CASH_OUT = "cash_out";
  static final String PAYMENT = "payment";
  static final String DISCOUNT_ITEM = "discount_item";
  static final String DISCOUNT_ORDER = "discount_order";
  static final String ENTERTAINMENT_BILL = "entertainment_bill";
  static final String CHANGE_TABLE = "change_table";
  static final String JOIN_TABLE = "join_table";
  static final String CANCEL_ORDER = "cancel_table";
  static final String CHANG_PAX = "opening"; //"change_pax";
  static final String SPLIT_TABLE = "split_table";
  static final String PRINT_QR = "print_qr";
  static final String OPENING = "opening";
  static final String CLOSING = "closing";
  static final String REFUND = "refund";
  static final String CANCLE_TRANSACTION = "cancel_transaction";
  static final String SEND_KITCHEN = "send_kitchen";
  static final String REPRINT_KITECHEN = "reprint_kitchen";
  static final String PRINT_CHECKLIST = "print_checklist";
  static final String PRINT_BILL = "print_bill";
  static final String FREE_ITEM = "free_item";
  static final String OPEN_SHIFT = "open_shift";
  static final String CLOSE_SHIFT = "close_shift";
  static final String REPRINT_PREVIOS_RECIEPT = "reprint_previous_receipt";
  static final String REDEEM_WINE = "redeem_wine";
  static final String APPLY_VOUCHER = "apply_voucher";
  static final String NEW_ORDER = "opening"; //"new_order";
  static final String CHANGE_QUANTITY = "change_quantity";
  static final String ADD_CUSTOMER = "add_customer";
  static final String CLOSE_TABLE = "close_table";
  static final String SYNC_ORDER = "sync_order";
  static final String VIEW_SHIFT = "view_shift";
  static final String RETURN_PREVIOS_TRANSACTION =
      "return_previous_transaction";

  /*==============================================================================
                              Manage API status
  =================================================================================*/
  static final int STATUS200 = 200; //For success response
  static final int STATUS422 = 422; //Validation or not exists data
  static final int STATUS500 = 500; //Ooops something wrong
  static final int STATUS5401 = 401; //Authentication failed

/*==============================================================================
                           Screen name for navigation
  =================================================================================*/
  static final String LoginScreen = "/Login";
  static final String PINScreen = "/PINPage";
  static final String DashboardScreen = "/Dashboard";
  static final String TransactionScreen = "/TansactionsPage";
  //static final String TerminalScreen = "/TerminalKeyPage";
  static final String SelectTableScreen = "/TableSelection";
  static final String SettingsScreen = "/Settings";
  static final String WebOrderPages = "/WebOrders";
  static final String ShiftOrders = "/ShiftReport";
  static final String WineStorage = "/WineStorage";
  static final String OutofStock = "/outOfStock/OutofStock";

  /************************Just for identify on navigation*********************************/
  static final String dashboard = "dashboard";
  static final String splitbill = "splitbill";

/*==============================================================================
                                  Error messages
  =================================================================================*/
  static final String VALID_TERMINAL_KEY = "Please enter terminal key";
}
