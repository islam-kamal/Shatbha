import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shatbha/core/core.dart';
import 'package:shatbha/features/company/data/repositories/company_repository.dart';

import 'package:shatbha/features/auth/presentation/cubit/auth_bloc.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final _name = TextEditingController();
  final _english = TextEditingController(text: 'Shatbha Atelier');
  final _phone1 = TextEditingController(text: '01060639899');
  final _phone2 = TextEditingController(text: '01224174194');
  final _addr1 = TextEditingController(text: 'القاهرة — الفرع الأول');
  final _addr2 = TextEditingController(text: 'القاهرة — الفرع الثاني');
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    sl<CompanyRepository>().get().then((company) {
      if (!mounted) return;
      setState(() {
        _name.text = company?.name ?? 'شطبها';
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _english.dispose();
    _phone1.dispose();
    _phone2.dispose();
    _addr1.dispose();
    _addr2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('بيانات الشركة'),
        toolbarHeight: 76,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: c.brass, width: 1.4),
                          color: c.raised,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ش',
                              style: GoogleFonts.cairo(
                                color: c.brass,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                            Text(
                              'شطبها',
                              style: GoogleFonts.cairo(
                                color: c.ivory,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: c.brass,
                          child: Icon(Icons.photo_camera_outlined, size: 16, color: c.stone),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'الاسم العربي')),
                const SizedBox(height: 12),
                TextField(controller: _english, decoration: const InputDecoration(labelText: 'الاسم بالإنجليزية')),
                const SizedBox(height: 12),
                TextField(
                  controller: _phone1,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف الأول',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phone2,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف الثاني',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addr1,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الفرع الأول',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addr2,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الفرع الثاني',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                const SectionLabel('هوية العلامة التجارية'),
                DarkMenuCard(
                  children: [
                    ListTile(
                      title: const Text('اللون الأساسي'),
                      subtitle: const Text('حجر داكن'),
                      trailing: CircleAvatar(backgroundColor: c.stone, radius: 12),
                    ),
                    ListTile(
                      title: const Text('اللون الثانوي'),
                      subtitle: const Text('نحاسي'),
                      trailing: CircleAvatar(backgroundColor: c.brass, radius: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AtelierButton(
                  label: _saving ? 'جارٍ الحفظ…' : 'حفظ التغييرات',
                  icon: Icons.save_outlined,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final company = await sl<CompanyRepository>().update({
        'name': _name.text.trim(),
        'subtitle': _english.text.trim(),
      });
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthCompanyUpdated(company));
      await showAtelierSuccess(context, body: 'تم حفظ بيانات الشركة بنجاح');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class PacksScreen extends StatefulWidget {
  const PacksScreen({super.key});

  @override
  State<PacksScreen> createState() => _PacksScreenState();
}

class _PacksScreenState extends State<PacksScreen> {
  static const packs = [
    ('finishing', 'تشطيبات ومقاولات', Icons.apartment_outlined),
    ('manufacturing', 'تصنيع', Icons.settings_outlined),
    ('food', 'صناعات غذائية', Icons.grass_outlined),
    ('wood', 'أخشاب ومطابخ', Icons.kitchen_outlined),
    ('aluminum', 'ألوميتال', Icons.window_outlined),
    ('realestate', 'تطوير عقاري', Icons.location_city_outlined),
    ('carpets', 'غزل وسجاد', Icons.texture),
  ];

  String _selected = 'finishing';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      _selected = auth.user.company?.pack ?? 'finishing';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle(
          'إعدادات النشاط',
          subtitle: 'اختر باقة النشاط المناسبة لشركتك',
        ),
        toolbarHeight: 96,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          IvoryMenuCard(
            children: [
              for (final pack in packs)
                InkWell(
                  onTap: () => setState(() => _selected = pack.$1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: c.dateTint.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(pack.$3, color: c.brass),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            pack.$2,
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: c.stone,
                            ),
                          ),
                        ),
                        Icon(
                          _selected == pack.$1
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: c.brass,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'تختلف الوحدات والخيارات المتاحة حسب باقة النشاط المختارة',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.ivoryMuted, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 20),
          AtelierButton(
            label: _saving ? 'جارٍ الحفظ…' : 'حفظ',
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final company = await sl<CompanyRepository>().update({'pack': _selected});
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthCompanyUpdated(company));
      await showAtelierSuccess(context, body: 'تم حفظ باقة النشاط');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
