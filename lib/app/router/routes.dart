/// Every route path lives here so screens never hard-code strings.
class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const home = '/home';
  static const notifications = '/notifications';

  // Shared by both account types
  static const wallet = '/wallet';
  static const budgets = '/budgets';
  static const savings = '/savings';
  static const expenses = '/expenses';
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
