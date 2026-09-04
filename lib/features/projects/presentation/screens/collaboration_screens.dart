import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shatbha/core/core.dart';
import 'package:shatbha/features/client/data/repositories/client_repository.dart';
import 'package:shatbha/features/projects/data/repositories/project_repository.dart';
import 'package:shatbha/features/vendors/data/datasources/vendor_project_remote_datasource.dart';

class ProjectTeamScreen extends StatefulWidget {
  const ProjectTeamScreen({super.key, required this.projectId});
  final int projectId;

  @override
  State<ProjectTeamScreen> createState() => _ProjectTeamScreenState();
}

class _ProjectTeamScreenState extends State<ProjectTeamScreen> {
  List<Map<String, dynamic>> _members = [];
  bool _loading = true;
  String? _error;

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
      final rows = await sl<ProjectRepository>().members(widget.projectId);
      if (!mounted) return;
      setState(() {
        _members = rows;
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

  Future<void> _inviteClient() async {
    final email = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('دعوة عميل'),
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
      final detail = await sl<ProjectRepository>().get(widget.projectId);
      final customerId = detail.customerId;
      if (customerId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اربط المشروع بعميل أولاً')),
        );
        return;
      }
      final res = await sl<ProjectRepository>().inviteClient(
        customerId,
        {'email': email.text.trim()},
      );
      if (!mounted) return;
      final temp = res['temporary_password'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            temp != null
                ? 'تمت الدعوة. كلمة المرور المؤقتة: $temp'
                : 'تمت دعوة العميل',
          ),
        ),
      );
      await _load();
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('فريق المشروع'),
        toolbarHeight: 76,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: _inviteClient,
            tooltip: 'دعوة عميل',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : IvorySheet(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: _members.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final m = _members[i];
                        return ListTile(
                          tileColor: context.atelier.raised,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(m['label']?.toString() ?? 'عضو'),
                          subtitle: Text(
                            '${m['member_type']} · ${m['role']}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await sl<ProjectRepository>().removeMember(
                                widget.projectId,
                                m['id'] as int,
                              );
                              await _load();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}

class ProjectRequestsScreen extends StatefulWidget {
  const ProjectRequestsScreen({super.key, required this.projectId});
  final int projectId;

  @override
  State<ProjectRequestsScreen> createState() => _ProjectRequestsScreenState();
}

class _ProjectRequestsScreenState extends State<ProjectRequestsScreen> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  String? _error;

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
      final rows = await sl<ProjectRepository>().requests(widget.projectId);
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

  Future<void> _create() async {
    final title = TextEditingController();
    final body = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('طلب جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'العنوان'),
            ),
            TextField(
              controller: body,
              decoration: const InputDecoration(labelText: 'التفاصيل'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
    if (ok != true || title.text.trim().isEmpty) return;
    try {
      final members = await sl<ProjectRepository>().members(widget.projectId);
      Map<String, dynamic>? client;
      for (final m in members) {
        if (m['member_type'] == 'client') {
          client = m;
          break;
        }
      }
      if (client == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('أضف عميلاً لفريق المشروع أولاً')),
        );
        return;
      }
      await sl<ProjectRepository>().createRequest(widget.projectId, {
        'type': 'general',
        'title': title.text.trim(),
        'body': body.text.trim(),
        'assignee_type': 'client',
        'assignee_id': client['member_id'],
      });
      await _load();
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('طلبات المشروع'),
        toolbarHeight: 76,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _create),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : _rows.isEmpty
                  ? const StatusView.empty(
                      title: 'لا طلبات',
                      body: 'أنشئ طلباً موجّهاً للعميل أو المقاول.',
                    )
                  : IvorySheet(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: _rows.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final r = _rows[i];
                            return ListTile(
                              tileColor: context.atelier.raised,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text(r['title']?.toString() ?? ''),
                              subtitle: Text(
                                '${r['type']} · ${r['status']}',
                              ),
                              onTap: () => context.push(
                                '/projects/${widget.projectId}/requests/${r['id']}',
                              ),
                            );
                          },
                        ),
                      ),
                    ),
    );
  }
}

class ProjectRequestDetailScreen extends StatefulWidget {
  const ProjectRequestDetailScreen({
    super.key,
    required this.projectId,
    required this.requestId,
  });
  final int projectId;
  final int requestId;

  @override
  State<ProjectRequestDetailScreen> createState() =>
      _ProjectRequestDetailScreenState();
}

class _ProjectRequestDetailScreenState
    extends State<ProjectRequestDetailScreen> {
  Map<String, dynamic>? _row;
  bool _loading = true;
  final _comment = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final row = await sl<ProjectRepository>()
          .getRequest(widget.projectId, widget.requestId);
      if (!mounted) return;
      setState(() {
        _row = row;
        _loading = false;
      });
    } on Failure catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _row == null) {
      return Scaffold(
        appBar: AppBar(title: const ScreenTitle('تفاصيل الطلب')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final comments = (_row!['comments'] as List?) ?? [];
    final status = _row!['status']?.toString() ?? '';
    final open = status == 'open' || status == 'in_review';
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(_row!['title']?.toString() ?? 'طلب'),
        toolbarHeight: 76,
      ),
      body: IvorySheet(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(_row!['body']?.toString() ?? ''),
            const SizedBox(height: 8),
            Text('الحالة: $status'),
            const SectionLabel('التعليقات'),
            ...comments.map(
              (c) => ListTile(
                title: Text((c as Map)['author_label']?.toString() ?? ''),
                subtitle: Text(c['body']?.toString() ?? ''),
              ),
            ),
            TextField(
              controller: _comment,
              decoration: const InputDecoration(labelText: 'تعليق'),
            ),
            const SizedBox(height: 8),
            AtelierButton(
              label: 'إرسال تعليق',
              onPressed: () async {
                if (_comment.text.trim().isEmpty) return;
                await sl<ProjectRepository>().commentRequest(
                  widget.projectId,
                  widget.requestId,
                  _comment.text.trim(),
                );
                _comment.clear();
                await _load();
              },
            ),
            if (open) ...[
              const SizedBox(height: 12),
              AtelierButton(
                label: 'اعتماد',
                onPressed: () async {
                  await sl<ProjectRepository>().decideRequest(
                    widget.projectId,
                    widget.requestId,
                    approve: true,
                  );
                  await _load();
                },
              ),
              const SizedBox(height: 8),
              AtelierButton(
                label: 'رفض',
                kind: AtelierButtonKind.danger,
                onPressed: () async {
                  final note = TextEditingController();
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('سبب الرفض'),
                      content: TextField(controller: note),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('رفض'),
                        ),
                      ],
                    ),
                  );
                  if (ok != true || note.text.trim().isEmpty) return;
                  await sl<ProjectRepository>().decideRequest(
                    widget.projectId,
                    widget.requestId,
                    approve: false,
                    note: note.text.trim(),
                  );
                  await _load();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class VendorProjectsScreen extends StatefulWidget {
  const VendorProjectsScreen({super.key});

  @override
  State<VendorProjectsScreen> createState() => _VendorProjectsScreenState();
}

class _VendorProjectsScreenState extends State<VendorProjectsScreen> {
  List<dynamic> _projects = [];
  bool _loading = true;
  String? _error;

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
      final rows = await sl<VendorProjectRemoteDatasource>().list();
      if (!mounted) return;
      setState(() {
        _projects = rows;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('مشاريعي'),
        toolbarHeight: 76,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusView.error(body: _error!, onAction: _load)
              : _projects.isEmpty
                  ? const StatusView.empty(
                      title: 'لا مشاريع',
                      body: 'ستظهر المشاريع بعد قبول عرض السعر.',
                    )
                  : IvorySheet(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: _projects.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final p = _projects[i];
                          return ListTile(
                            tileColor: context.atelier.raised,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Text(p.name),
                            subtitle: Text(p.status),
                            onTap: () =>
                                context.push('/vendor/projects/${p.id}'),
                          );
                        },
                      ),
                    ),
    );
  }
}

class VendorProjectDetailScreen extends StatefulWidget {
  const VendorProjectDetailScreen({super.key, required this.projectId});
  final int projectId;

  @override
  State<VendorProjectDetailScreen> createState() =>
      _VendorProjectDetailScreenState();
}

class _VendorProjectDetailScreenState extends State<VendorProjectDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data =
          await sl<VendorProjectRemoteDatasource>().show(widget.projectId);
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } on Failure catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _data == null) {
      return Scaffold(
        appBar: AppBar(title: const ScreenTitle('مشروع')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final project = _data!['project'] as Map<String, dynamic>? ?? {};
    final requests = (_data!['requests'] as List?) ?? [];
    final tasks = (_data!['tasks'] as List?) ?? [];
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(project['title']?.toString() ?? 'مشروع'),
        toolbarHeight: 76,
      ),
      body: IvorySheet(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const SectionLabel('الطلبات المفتوحة'),
            ...requests.map(
              (r) => ListTile(
                title: Text((r as Map)['title']?.toString() ?? ''),
                subtitle: Text(r['status']?.toString() ?? ''),
                trailing: TextButton(
                  child: const Text('تسليم'),
                  onPressed: () async {
                    await sl<VendorProjectRemoteDatasource>().submitResponse(
                      widget.projectId,
                      r['id'] as int,
                      'تم الإنجاز',
                    );
                    await _load();
                  },
                ),
              ),
            ),
            const SectionLabel('المهام'),
            ...tasks.map(
              (t) => ListTile(
                title: Text((t as Map)['title']?.toString() ?? ''),
                subtitle: Text(t['status']?.toString() ?? ''),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientProjectRequestsScreen extends StatefulWidget {
  const ClientProjectRequestsScreen({super.key, required this.projectId});
  final int projectId;

  @override
  State<ClientProjectRequestsScreen> createState() =>
      _ClientProjectRequestsScreenState();
}

class _ClientProjectRequestsScreenState
    extends State<ClientProjectRequestsScreen> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final rows =
          await sl<ClientRepository>().requests(widget.projectId);
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } on Failure catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('الطلبات'),
        toolbarHeight: 76,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rows.isEmpty
              ? const StatusView.empty(
                  title: 'لا طلبات',
                  body: 'لا توجد طلبات تحتاج موافقتك حالياً.',
                )
              : IvorySheet(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: _rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final r = _rows[i];
                      final open = r['status'] == 'open' ||
                          r['status'] == 'in_review';
                      return ListTile(
                        tileColor: context.atelier.raised,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(r['title']?.toString() ?? ''),
                        subtitle: Text(r['status']?.toString() ?? ''),
                        trailing: open
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    child: const Text('اعتماد'),
                                    onPressed: () async {
                                      await sl<ClientRepository>()
                                          .decideRequest(
                                        widget.projectId,
                                        r['id'] as int,
                                        approve: true,
                                      );
                                      await _load();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('رفض'),
                                    onPressed: () async {
                                      await sl<ClientRepository>()
                                          .decideRequest(
                                        widget.projectId,
                                        r['id'] as int,
                                        approve: false,
                                        note: 'مرفوض من العميل',
                                      );
                                      await _load();
                                    },
                                  ),
                                ],
                              )
                            : null,
                      );
                    },
                  ),
                ),
    );
  }
}
