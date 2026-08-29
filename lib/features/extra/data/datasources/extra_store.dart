import 'package:flutter/foundation.dart';

class DemoLine {
  const DemoLine({
    required this.title,
    required this.amount,
    this.subtitle = '',
    this.date = '',
    this.badge,
    this.negative = false,
    this.path,
  });

  final String title;
  final String subtitle;
  final String amount;
  final String date;
  final String? badge;
  final bool negative;
  final String? path;

  DemoLine copyWith({String? title, String? amount, String? subtitle, String? date}) {
    return DemoLine(
      title: title ?? this.title,
      amount: amount ?? this.amount,
      subtitle: subtitle ?? this.subtitle,
      date: date ?? this.date,
      badge: badge,
      negative: negative,
      path: path,
    );
  }
}

class DemoItem {
  const DemoItem({
    required this.name,
    required this.sku,
    required this.unit,
    required this.packUnit,
    required this.finished,
    this.opening = '1000',
    this.produced = '0',
    this.sold = '0',
    this.returned = '0',
    this.balance = '1000',
  });

  final String name;
  final String sku;
  final String unit;
  final String packUnit;
  final bool finished;
  final String opening;
  final String produced;
  final String sold;
  final String returned;
  final String balance;
}

class ExtraStore extends ChangeNotifier {
  ExtraStore._();
  static final ExtraStore instance = ExtraStore._();

  final List<DemoLine> revenues = [
    const DemoLine(
      title: 'بيع خردة ألوميتال',
      amount: '2500',
      date: '12/03/2026',
      badge: 'إيراد',
    ),
  ];

  final List<DemoLine> supplierEntries = [
    const DemoLine(
      title: 'شراء غزل',
      subtitle: 'موردين غزل',
      amount: '7200',
      date: '15/05/2026',
      badge: 'شراء',
      negative: true,
    ),
    const DemoLine(
      title: 'دفعة مورد',
      subtitle: 'موردين غزل',
      amount: '3000',
      date: '18/05/2026',
      badge: 'سداد',
      negative: true,
    ),
  ];

  final List<DemoLine> generalJournal = [
    const DemoLine(
      title: 'قبض نقدي',
      subtitle: 'إيداع نقدي · الصندوق الرئيسي · 09:15',
      amount: '8500',
      date: '27/06/2026',
      badge: '1001',
    ),
    const DemoLine(
      title: 'مصروفات تشغيلية',
      subtitle: 'تشغيل · 10:30',
      amount: '2450',
      date: '27/06/2026',
      badge: '1002',
      negative: true,
    ),
    const DemoLine(
      title: 'شراء من مورد',
      subtitle: 'موردين غزل · 13:45',
      amount: '7200',
      date: '27/06/2026',
      badge: '1003',
      negative: true,
    ),
    const DemoLine(
      title: 'إيرادات متنوعة',
      subtitle: 'إيرادات أخرى · 16:20',
      amount: '10250',
      date: '27/06/2026',
      badge: '1004',
    ),
  ];

  final List<DemoLine> partnerEntries = [
    const DemoLine(
      title: 'حصة شريك أ',
      subtitle: 'توزيع أرباح',
      amount: '12000',
      date: '01/06/2026',
      badge: '60%',
    ),
    const DemoLine(
      title: 'حصة شريك ب',
      subtitle: 'توزيع أرباح',
      amount: '8000',
      date: '01/06/2026',
      badge: '40%',
    ),
  ];

  final List<DemoLine> materialOut = [
    const DemoLine(
      title: 'سحب ألوميتال',
      subtitle: 'موقع فيلا · 40 م.ط',
      amount: '14000',
      date: '10/05/2026',
      badge: 'صرف',
      negative: true,
    ),
  ];

  final List<DemoLine> production = [
    const DemoLine(
      title: 'إنتاج تام ١',
      subtitle: '12 دستة',
      amount: '1000',
      date: '12/05/2026',
      badge: 'إنتاج',
    ),
  ];

  final List<DemoItem> items = [
    const DemoItem(
      name: 'منتج تام ١',
      sku: 'PT-0001',
      unit: '1 قطعة',
      packUnit: '12 قطعة',
      finished: true,
      opening: '1000',
      produced: '1000',
      sold: '14',
      returned: '2',
      balance: '1988',
    ),
    const DemoItem(
      name: 'منتج تام ٢',
      sku: 'PT-0002',
      unit: '1 قطعة',
      packUnit: '12 قطعة',
      finished: true,
      opening: '800',
      produced: '0',
      sold: '1',
      returned: '1',
      balance: '800',
    ),
    const DemoItem(
      name: 'خامة ألوميتال',
      sku: 'RM-0040',
      unit: '1 متر',
      packUnit: '6 متر',
      finished: false,
      opening: '200',
      produced: '0',
      sold: '40',
      returned: '0',
      balance: '160',
    ),
  ];

  void addRevenue(DemoLine line) {
    revenues.insert(0, line);
    notifyListeners();
  }

  void addSupplierEntry(DemoLine line) {
    supplierEntries.insert(0, line);
    notifyListeners();
  }

  void addGeneral(DemoLine line) {
    generalJournal.insert(0, line);
    notifyListeners();
  }

  void addPartnerEntry(DemoLine line) {
    partnerEntries.insert(0, line);
    notifyListeners();
  }

  void addMaterialOut(DemoLine line) {
    materialOut.insert(0, line);
    notifyListeners();
  }

  void addProduction(DemoLine line) {
    production.insert(0, line);
    notifyListeners();
  }

  void addItem(DemoItem item) {
    items.insert(0, item);
    notifyListeners();
  }
}
