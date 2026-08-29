import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/format.dart';
import '../theme/atelier_theme.dart';

class BrandLockup extends StatelessWidget {
  const BrandLockup({
    super.key,
    this.size = BrandSize.medium,
    this.slogan,
  });

  final BrandSize size;
  final String? slogan;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final word = size == BrandSize.large ? 52.0 : 36.0;
    return Column(
      children: [
        Text(
          'شطبة',
          style: GoogleFonts.cairo(
            fontSize: word,
            fontWeight: FontWeight.w800,
            color: size == BrandSize.large ? c.ivory : c.brass,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'SHATBHA ATELIER',
          style: GoogleFonts.cinzel(
            fontSize: size == BrandSize.large ? 13 : 11,
            fontWeight: FontWeight.w600,
            color: c.brass,
            letterSpacing: 4,
          ),
        ),
        if (slogan != null) ...[
          const SizedBox(height: 10),
          Text(
            slogan!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: c.ivoryMuted,
                  fontSize: 13,
                ),
          ),
        ],
        const SizedBox(height: 12),
        const BrassDiamond(),
      ],
    );
  }
}

enum BrandSize { medium, large }

class BrassDiamond extends StatelessWidget {
  const BrassDiamond({super.key, this.width = 72});
  final double width;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return SizedBox(
      width: width,
      height: 10,
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: c.brass)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Transform.rotate(
              angle: 0.785,
              child: Container(width: 6, height: 6, color: c.brass),
            ),
          ),
          Expanded(child: Container(height: 1, color: c.brass)),
        ],
      ),
    );
  }
}

class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: c.brass,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            '— $subtitle —',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: c.ivoryMuted,
                ),
          ),
        ],
        const SizedBox(height: 8),
        const BrassDiamond(),
      ],
    );
  }
}

class AtelierButton extends StatelessWidget {
  const AtelierButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = AtelierButtonKind.primary,
    this.expanded = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AtelierButtonKind kind;
  final bool expanded;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    late final Color bg;
    late final Color fg;
    late final BorderSide border;
    switch (kind) {
      case AtelierButtonKind.primary:
        bg = c.brass;
        fg = c.stone;
        border = BorderSide.none;
      case AtelierButtonKind.terracotta:
        bg = c.terracotta;
        fg = c.ivory;
        border = BorderSide.none;
      case AtelierButtonKind.secondary:
        bg = c.raised;
        fg = c.ivory;
        border = BorderSide(color: c.brass.withValues(alpha: 0.7));
      case AtelierButtonKind.danger:
        bg = c.terracotta;
        fg = c.ivory;
        border = BorderSide.none;
      case AtelierButtonKind.teal:
        bg = c.teal;
        fg = c.ivory;
        border = BorderSide.none;
    }
    final child = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: c.muted,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: border,
        ),
        textStyle: GoogleFonts.ibmPlexSansArabic(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(label),
        ],
      ),
    );
    if (expanded) return SizedBox(width: double.infinity, child: child);
    return child;
  }
}

enum AtelierButtonKind { primary, secondary, danger, teal, terracotta }

class KpiStrip extends StatelessWidget {
  const KpiStrip({super.key, required this.items});
  final List<KpiItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _KpiCard(item: items[i])),
        ],
      ],
    );
  }
}

class KpiItem {
  const KpiItem(this.label, this.value, {this.tint, this.icon, this.onInk = false});
  final String label;
  final String value;
  final Color? tint;
  final IconData? icon;
  final bool onInk;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.item});
  final KpiItem item;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final tinted = item.tint != null;
    final bg = item.tint ?? c.raised;
    final labelColor = tinted ? c.stone.withValues(alpha: 0.72) : c.ivoryMuted;
    final valueColor = tinted ? c.stone : c.brassBright;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: tinted ? null : Border.all(color: c.brass.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          if (item.icon != null) ...[
            Icon(item.icon, size: 18, color: tinted ? c.stone : c.brass),
            const SizedBox(height: 6),
          ],
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatMoney(item.value),
            style: GoogleFonts.ibmPlexSansArabic(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: valueColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class LedgerList extends StatelessWidget {
  const LedgerList({super.key, required this.rows, this.onTap});

  final List<LedgerRow> rows;
  final ValueChanged<LedgerRow>? onTap;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const StatusView.empty();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: rows.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final row = rows[i];
        return LedgerCard(row: row, onTap: onTap == null ? null : () => onTap!(row));
      },
    );
  }
}

class LedgerCard extends StatelessWidget {
  const LedgerCard({super.key, required this.row, this.onTap});
  final LedgerRow row;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Material(
      color: c.ivory,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.title,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: c.stone,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      row.subtitle,
                      style: TextStyle(
                        color: c.stone.withValues(alpha: 0.55),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatMoney(row.amount),
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: row.accent,
                    ),
                  ),
                  if (row.badge != null)
                    Text(
                      row.badge!,
                      style: TextStyle(color: row.accent, fontSize: 11),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LedgerRow {
  const LedgerRow({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.accent,
    this.badge,
  });
  final int id;
  final String title;
  final String subtitle;
  final String amount;
  final Color accent;
  final String? badge;
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    const items = [
      (Icons.home_outlined, Icons.home, 'الرئيسية'),
      (Icons.menu_book_outlined, Icons.menu_book, 'دفتر'),
      (Icons.pie_chart_outline, Icons.pie_chart, 'تقارير'),
      (Icons.more_horiz, Icons.more_horiz, 'المزيد'),
    ];
    return Material(
      color: c.stone,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: index == i ? items[i].$2 : items[i].$1,
                    label: items[i].$3,
                    selected: index == i,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final color = selected ? c.brass : c.ivoryMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: selected ? 22 : 0,
              decoration: BoxDecoration(
                color: c.brass,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusView extends StatelessWidget {
  const StatusView.empty({
    super.key,
    this.title = 'لا توجد حركات',
    this.body = 'أضف أول قيد ليظهر هنا.',
    this.actionLabel,
    this.onAction,
  })  : icon = Icons.inbox_outlined,
        forbidden = false;

  const StatusView.error({
    super.key,
    this.body = 'تعذر تحميل البيانات.',
    this.actionLabel = 'إعادة المحاولة',
    this.onAction,
  })  : title = 'حدث خطأ',
        icon = Icons.error_outline,
        forbidden = false;

  const StatusView.forbidden({super.key})
      : title = 'غير مسموح',
        body = 'هذا التقرير متاح للمدير فقط.',
        actionLabel = null,
        onAction = null,
        icon = Icons.lock_outline,
        forbidden = true;

  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;
  final bool forbidden;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c.brass, width: 1.4),
              ),
              child: Icon(icon, size: 36, color: c.brass),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: c.brass,
                  ),
            ),
            const SizedBox(height: 8),
            const BrassDiamond(),
            const SizedBox(height: 12),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: c.ivoryMuted,
                    height: 1.6,
                  ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AtelierButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

class AtelierScaffold extends StatelessWidget {
  const AtelierScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions,
    this.fab,
    this.header,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final Widget? fab;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(title, subtitle: subtitle),
        toolbarHeight: subtitle == null ? 72 : 88,
        actions: actions,
      ),
      body: Column(
        children: [
          if (header != null) header!,
          Expanded(child: body),
        ],
      ),
      floatingActionButton: fab,
    );
  }
}

class IvorySheet extends StatelessWidget {
  const IvorySheet({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.ivory,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: child,
    );
  }
}

class HomeNavTile extends StatelessWidget {
  const HomeNavTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Material(
      color: c.raised.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.brass.withValues(alpha: 0.85), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: c.brass, size: 28),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.35,
                    color: c.ivory,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HubRow extends StatelessWidget {
  const HubRow({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.dark = false,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    final titleColor = dark ? c.ivory : c.stone;
    final subColor = dark ? c.ivoryMuted : c.stone.withValues(alpha: 0.55);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: dark ? c.muted : c.dateTint.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: c.brass, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(color: subColor, fontSize: 12, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: c.brass),
          ],
        ),
      ),
    );
  }
}

class IvoryMenuCard extends StatelessWidget {
  const IvoryMenuCard({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Container(
      decoration: BoxDecoration(
        color: c.ivory,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 1, color: c.stone.withValues(alpha: 0.08)),
          ],
        ],
      ),
    );
  }
}

class DarkMenuCard extends StatelessWidget {
  const DarkMenuCard({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return Container(
      decoration: BoxDecoration(
        color: c.raised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.brass.withValues(alpha: 0.28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 1, color: c.muted),
          ],
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.atelier.brass,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}

class DateRangeChip extends StatelessWidget {
  const DateRangeChip({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.atelier;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: c.raised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.brass.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_outlined, color: c.brass, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.ibmPlexSansArabic(
                  color: c.ivory,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TileCard extends StatelessWidget {
  const TileCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HomeNavTile(title: title, icon: icon, onTap: onTap);
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

Future<void> showAtelierSuccess(
  BuildContext context, {
  String title = 'تم الحفظ',
  String body = 'تم تسجيل العملية بنجاح',
}) {
  final c = context.atelier;
  return showDialog<void>(
    context: context,
    barrierColor: c.stone.withValues(alpha: 0.78),
    builder: (ctx) {
      return Dialog(
        backgroundColor: c.raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: c.brass.withValues(alpha: 0.7)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.brass,
                ),
                child: Icon(Icons.check, color: c.stone, size: 38),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: c.brass,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(color: c.ivoryMuted, height: 1.5, fontSize: 14),
              ),
              const SizedBox(height: 22),
              AtelierButton(
                label: 'حسنًا',
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      );
    },
  );
}
