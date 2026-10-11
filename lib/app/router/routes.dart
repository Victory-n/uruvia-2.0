/// Every route path lives here so screens never hard-code strings.
class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const home = '/home';
  static const notifications = '/notifications';

  // Before sign-in and during onboarding
  static const onboarding = '/onboarding';
  static const signIn = '/auth/sign-in';
  static const signUp = '/auth/sign-up';
  static const verifyEmail = '/auth/verify';
  static const forgotPassword = '/auth/forgot';
  static const accountType = '/account-type';
  static const businessSetup = '/business-setup';
  static const pin = '/pin';

  // Shared by both account types
  static const wallet = '/wallet';
  static const budgets = '/budgets';
  static const savings = '/savings';
  static const expenses = '/expenses';
  static const expensesNew = '/expenses/new';
  static const expensesInsights = '/expenses/insights';
  static String expenseEdit(String id) => '/expenses/$id';
  static const budgetsNew = '/budgets/new';
  static String budgetDetail(String id) => '/budgets/$id';
  static String budgetEdit(String id) => '/budgets/$id/edit';
  static const plan = '/plan';
  static const support = '/support';
  static const supportNew = '/support/new';
  static String supportTicket(String id) => '/support/$id';
  static const settings = '/settings';
  static const settingsNotifications = '/settings/notifications';
  static const settingsPin = '/settings/pin';
  static const settingsBusiness = '/settings/business';

  // Business only
  static const inventory = '/inventory';
  static const inventoryNew = '/inventory/new';
  static const inventoryLow = '/inventory/low';
  static const inventoryCategories = '/inventory/categories';
  static String productDetail(String id) => '/inventory/$id';
  static String productEdit(String id) => '/inventory/$id/edit';
  static const invoices = '/invoices';
  static const invoicesNew = '/invoices/new';
  static String invoiceDetail(String id) => '/invoices/$id';
  static String invoicePreview(String id) => '/invoices/$id/preview';
  static String invoiceEdit(String id) => '/invoices/$id/edit';
  static const sales = '/sales';
  static String saleDetail(String id) => '/sales/$id';
  static const customers = '/customers';
  static const customersNew = '/customers/new';
  static String customerDetail(String id) => '/customers/$id';
  static String customerEdit(String id) => '/customers/$id/edit';
  static const reports = '/reports';
  static const hub = '/hub';
}
