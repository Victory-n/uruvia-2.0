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
  static const settings = '/settings';

  // Business only
  static const inventory = '/inventory';
  static const invoices = '/invoices';
  static const sales = '/sales';
  static const customers = '/customers';
  static const reports = '/reports';
  static const hub = '/hub';
}
