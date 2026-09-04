import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shatbha/core/core.dart';
import 'package:shatbha/features/catalog/data/models/catalog_models.dart';
import 'package:shatbha/features/catalog/data/repositories/catalog_repository.dart';
import 'package:shatbha/features/projects/data/repositories/project_repository.dart';

/// Company CRM directory for customers or contractors (list / add / edit).
class PartyDirectoryScreen extends StatefulWidget {
  const PartyDirectoryScreen({super.key, required this.type});

  /// `customer` or `contractor`
  final String type;

  @override
  State<PartyDirectoryScreen> createState() => _PartyDirectoryScreenState();
}

class _PartyDirectoryScreenState extends State<PartyDirectoryScreen> {
  List<Party> _rows = [];
  bool _loading = true;
  String? _error;

  bool get _isCustomer => widget.type == 'customer';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await sl<CatalogRepository>().parties(widget.type);
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } on Failure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _openForm({Party? party}) async {
    final path = _isCustomer
        ? (party == null ? '/clients/add' : '/clients/${party.id}/edit')
        : (party == null
            ? '/contractors/add'
            : '/contractors/${party.id}/edit');
    await context.push(path);
    if (mounted) await _load();
  }

  Future<void> _delete(Party party) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isCustomer ? 'حذف العميل' : 'حذف المقاول'),
        content: Text('حذف «${party.name}»؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await sl<CatalogRepository>().deleteParty(party.id);
      if (!mounted) return;
      await showAtelierSuccess(context, body: 'تم الحذف');
      await _load();
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _inviteClient(Party party) async {
    final email = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('دعوة ${party.name}'),
        content: TextField(
          controller: email,
          decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('دعوة'),
          ),
        ],
      ),
    );
    if (ok != true || email.text.trim().isEmpty) return;
    try {
      final res = await sl<ProjectRepository>().inviteClient(
        party.id,
        {'email': email.text.trim()},
      );
      if (!mounted) return;
      final temp = res['temporary_password'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            temp != null
                ? 'تمت الدعوة. كلمة المرور المؤقتة: $temp'
                : 'تمت الدعوة',
          ),
        ),
      );
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(
          _isCustomer ? 'العملاء' : 'المقاولون',
          subtitle: _isCustomer
              ? 'إضافة وتعديل قائمة العملاء'
              : 'سجل مقاولي الشركة',
        ),
        toolbarHeight: 88,
        actions: [
          if (!_isCustomer)
            IconButton(
              tooltip: 'سوق المقاولين',
              icon: const Icon(Icons.storefront_outlined),
              onPressed: () => context.push('/contractors/marketplace'),
            ),
          IconButton(
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: Text(_isCustomer ? 'عميل جديد' : 'مقاول جديد'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : _rows.isEmpty
                  ? StatusView.empty(
                      title: _isCustomer ? 'لا يوجد عملاء' : 'لا يوجد مقاولون',
                      body: 'أضف أول عنصر ليظهر هنا.',
                      actionLabel: 'إضافة',
                      onAction: () => _openForm(),
                    )
                  : IvorySheet(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                          itemCount: _rows.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final p = _rows[i];
                            final subtitle = [
                              if (p.email != null && p.email!.isNotEmpty)
                                p.email,
                              if (p.phone != null && p.phone!.isNotEmpty)
                                p.phone,
                              if (p.hasLogin) 'حساب دخول',
                              if (_isCustomer && p.kind == 'supervision')
                                'إشراف ${p.supervisionPercent}%',
                              if (_isCustomer && p.kind == 'agreement')
                                'اتفاق',
                            ].join(' · ');
                            return Material(
                              color: c.raised,
                              borderRadius: BorderRadius.circular(12),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                leading: Icon(
                                  _isCustomer
                                      ? Icons.person_outline
                                      : Icons.engineering_outlined,
                                  color: c.brass,
                                ),
                                title: Text(p.name),
                                subtitle:
                                    subtitle.isEmpty ? null : Text(subtitle),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    if (v == 'edit') {
                                      await _openForm(party: p);
                                      return;
                                    }
                                    if (v == 'statement' && _isCustomer) {
                                      if (!context.mounted) return;
                                      context.push(
                                        '/customers/${p.id}/statement',
                                      );
                                      return;
                                    }
                                    if (v == 'invite' && _isCustomer) {
                                      await _inviteClient(p);
                                      return;
                                    }
                                    if (v == 'delete') await _delete(p);
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('تعديل'),
                                    ),
                                    if (_isCustomer)
                                      const PopupMenuItem(
                                        value: 'statement',
                                        child: Text('كشف حساب'),
                                      ),
                                    if (_isCustomer)
                                      const PopupMenuItem(
                                        value: 'invite',
                                        child: Text('دعوة تطبيق'),
                                      ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('حذف'),
                                    ),
                                  ],
                                ),
                                onTap: () => _openForm(party: p),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
    );
  }
}

class PartyFormScreen extends StatefulWidget {
  const PartyFormScreen({
    super.key,
    required this.type,
    this.partyId,
  });

  final String type;
  final int? partyId;

  @override
  State<PartyFormScreen> createState() => _PartyFormScreenState();
}

class _PartyFormScreenState extends State<PartyFormScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _percent = TextEditingController(text: '8');
  String _kind = 'agreement';
  bool _loading = false;
  bool _bootstrapping = false;
  Party? _existing;

  bool get _isCustomer => widget.type == 'customer';
  bool get _isEdit => widget.partyId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _bootstrapping = true);
    try {
      final rows = await sl<CatalogRepository>().parties(widget.type);
      final match = rows.where((p) => p.id == widget.partyId).toList();
      if (match.isEmpty) throw const ValidationFailure('العنصر غير موجود');
      final p = match.first;
      _existing = p;
      _name.text = p.name;
      _phone.text = p.phone ?? '';
      _email.text = p.email ?? '';
      _kind = p.kind ?? 'agreement';
      _percent.text = '${p.supervisionPercent}';
    } on Failure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
        context.pop();
      }
      return;
    } finally {
      if (mounted) setState(() => _bootstrapping = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _percent.dispose();
    super.dispose();
  }

  String _successBody(Party party) {
    final temp = party.temporaryPassword;
    if (temp == null || temp.isEmpty) return 'تم الحفظ';
    final emailed = party.credentialsEmailed == true;
    return emailed
        ? 'تم الحفظ وإرسال بيانات الدخول إلى البريد.\nكلمة المرور المؤقتة: $temp'
        : 'تم الحفظ. كلمة المرور المؤقتة: $temp\n(تعذّر إرسال البريد — انسخها الآن)';
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    if (!_isEdit && _email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('البريد الإلكتروني مطلوب لإنشاء حساب الدخول')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final body = <String, dynamic>{
        'type': widget.type,
        'name': _name.text.trim(),
        'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        if (_email.text.trim().isNotEmpty) 'email': _email.text.trim(),
        'kind': _isCustomer ? _kind : 'agreement',
        if (_isCustomer && _kind == 'supervision')
          'supervision_percent': int.tryParse(_percent.text) ?? 8,
      };
      final Party saved;
      if (_isEdit) {
        saved = await sl<CatalogRepository>().updateParty(widget.partyId!, body);
      } else {
        saved = await sl<CatalogRepository>().createParty(body);
      }
      if (!mounted) return;
      await showAtelierSuccess(context, body: _successBody(saved));
      if (mounted) context.pop();
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit
        ? (_isCustomer ? 'تعديل عميل' : 'تعديل مقاول')
        : (_isCustomer ? 'عميل جديد' : 'مقاول جديد');
    if (_bootstrapping) {
      return Scaffold(
        appBar: AppBar(title: ScreenTitle(title), toolbarHeight: 76),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: ScreenTitle(title), toolbarHeight: 76),
      body: IvorySheet(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'الاسم *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              decoration: InputDecoration(
                labelText: _isEdit
                    ? 'البريد الإلكتروني (حساب الدخول)'
                    : 'البريد الإلكتروني *',
                helperText: _isEdit
                    ? 'اتركه فارغاً إن لم ترد تغيير كلمة المرور'
                    : 'يُنشأ حساب دخول وتُرسل كلمة مرور مؤقتة لهذا البريد',
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'الهاتف'),
              keyboardType: TextInputType.phone,
            ),
            if (_isCustomer) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _kind,
                items: const [
                  DropdownMenuItem(value: 'agreement', child: Text('اتفاق')),
                  DropdownMenuItem(value: 'supervision', child: Text('إشراف')),
                ],
                onChanged: (v) => setState(() => _kind = v ?? 'agreement'),
                decoration: const InputDecoration(labelText: 'النوع'),
              ),
              if (_kind == 'supervision') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _percent,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'نسبة الإشراف %'),
                ),
              ],
            ],
            if (_existing != null) ...[
              const SizedBox(height: 8),
              Text(
                [
                  'رقم ${_existing!.id}',
                  if (_existing!.hasLogin) 'لديه حساب دخول',
                ].join(' · '),
                style: TextStyle(color: context.atelier.ivoryMuted),
              ),
            ],
            const SizedBox(height: 24),
            AtelierButton(
              label: _loading ? 'جاري الحفظ…' : 'حفظ',
              onPressed: _loading ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
