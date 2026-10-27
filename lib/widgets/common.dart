import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'app_icon.dart';

const campaignIcons = <AppIcons>[
  AppIcons.play,
  AppIcons.gift,
  AppIcons.company,
  AppIcons.refresh,
  AppIcons.followup,
  AppIcons.megaphone,
  AppIcons.campaign,
  AppIcons.autodialer,
];

(Color fg, Color bg) statusColors(LeadStatus s) => switch (s) {
  LeadStatus.newLead => (AppColors.primary, AppColors.primarySoft),
  LeadStatus.contacted => (AppColors.purple, AppColors.purpleSoft),
  LeadStatus.qualified => (AppColors.orange, AppColors.orangeSoft),
  LeadStatus.proposal => (const Color(0xFFEA580C), const Color(0xFFFFEDD5)),
  LeadStatus.negotiation => (AppColors.pink, AppColors.pinkSoft),
  LeadStatus.won => (AppColors.green, AppColors.greenSoft),
  LeadStatus.followUp => (const Color(0xFF7C3AED), const Color(0xFFEDE9FE)),
  LeadStatus.lost => (AppColors.textMuted, AppColors.input),
};

/// Back button + title + optional trailing widgets, matching the design's flat headers.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.back = false, this.trailing = const []});

  final String title;
  final bool back;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          if (back)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: IconButton(
                visualDensity: VisualDensity.compact,
                icon: const AppIcon(AppIcons.back, color: AppColors.text),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          ...trailing,
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(14), this.margin});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: cardShadow),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, this.size = 40, this.solid = false, this.image});
  final String name;
  final double size;

  /// Forces the filled style (coloured background, white initials), as on the lead header.
  final bool solid;

  /// Optional photo asset; falls back to initials.
  final String? image;

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return ClipOval(
        child: Image.asset(image!, width: size, height: size, fit: BoxFit.cover),
      );
    }
    final sum = name.codeUnits.fold<int>(0, (a, c) => a + c);
    var (bg, fg) = avatarPalette[sum % avatarPalette.length];
    if (solid && fg != Colors.white) (bg, fg) = (Color.lerp(fg, Colors.white, 0.25)!, Colors.white);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        initials(name),
        style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: size * 0.36),
      ),
    );
  }
}

/// Icon in a soft rounded-square tile (stat cards, call log, tasks, campaigns).
class IconTile extends StatelessWidget {
  const IconTile(this.icon, {super.key, required this.color, required this.bg, this.size = 44, this.iconSize});
  final AppIcons icon;
  final Color color;
  final Color bg;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * 0.28)),
      child: AppIcon(icon, size: iconSize ?? size * 0.5, color: color),
    );
  }
}

class IconCircle extends StatelessWidget {
  const IconCircle(
    this.icon, {
    super.key,
    required this.color,
    required this.bg,
    this.size = 40,
    this.iconSize,
    this.onTap,
  });

  final AppIcons icon;
  final Color color;
  final Color bg;
  final double size;
  final double? iconSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: AppIcon(icon, size: iconSize ?? size * 0.48, color: color),
    );
    if (onTap == null) return circle;
    return InkResponse(onTap: onTap, radius: size * 0.7, child: circle);
  }
}

class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, required this.fg, required this.bg, this.icon});
  final String label;
  final Color fg;
  final Color bg;
  final AppIcons? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[AppIcon(icon!, size: 11, color: fg), const SizedBox(width: 3)],
          Text(
            label,
            style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.status, {super.key});
  final LeadStatus status;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = statusColors(status);
    return Pill(status.label, fg: fg, bg: bg);
  }
}

enum ButtonVariant { primary, outline }

class AppButton extends StatelessWidget {
  const AppButton(
    this.title, {
    super.key,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.height = 50,
  });

  final String title;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final AppIcons? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final outline = variant == ButtonVariant.outline;
    final fg = outline ? AppColors.primary : Colors.white;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: fg),
          ),
        ),
        if (icon != null) ...[const SizedBox(width: 8), AppIcon(icon!, size: 18, color: fg)],
      ],
    );
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    return SizedBox(
      height: height,
      child: outline
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                shape: shape,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                backgroundColor: Colors.white,
              ),
              child: child,
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                shape: shape,
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
              ),
              child: child,
            ),
    );
  }
}

class AppProgressBar extends StatelessWidget {
  const AppProgressBar(this.value, {super.key, this.color = AppColors.green});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 6,
        color: color,
        backgroundColor: AppColors.input,
      ),
    );
  }
}

class Delta extends StatelessWidget {
  const Delta(this.value, {super.key});
  final double value;

  @override
  Widget build(BuildContext context) {
    final up = value >= 0;
    final color = up ? AppColors.green : AppColors.red;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(up ? AppIcons.trendUp : AppIcons.trendDown, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          '${value.abs()}%',
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.subtitle});
  final AppIcons icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          IconCircle(icon, color: AppColors.primary, bg: AppColors.primarySoft, size: 56),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}

InputDecoration inputDecoration({String? hint, AppIcons? icon, Widget? suffix, String? error}) {
  OutlineInputBorder border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
    prefixIcon: icon == null ? null : AppIcon(icon, size: 20, color: AppColors.textMuted),
    suffixIcon: suffix,
    errorText: error,
    filled: true,
    fillColor: AppColors.input,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: border(Colors.transparent),
    enabledBorder: border(Colors.transparent),
    focusedBorder: border(AppColors.primary),
    errorBorder: border(AppColors.red),
    focusedErrorBorder: border(AppColors.red),
  );
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.required = false});
  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.red),
              ),
          ],
        ),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    this.label,
    this.required = false,
    required this.controller,
    this.hint,
    this.icon,
    this.error,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.onSubmitted,
    this.onChanged,
  });

  final String? label;
  final bool required;
  final TextEditingController controller;
  final String? hint;
  final AppIcons? icon;
  final String? error;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) FieldLabel(label!, required: required),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            onSubmitted: onSubmitted,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14),
            decoration: inputDecoration(hint: hint, icon: icon, suffix: suffix, error: error),
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.controller, required this.hint, required this.onChanged});
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: inputDecoration(
        hint: hint,
        icon: AppIcons.search,
        suffix: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const AppIcon(AppIcons.closeCircle, size: 18, color: AppColors.textLight),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
      ),
    );
  }
}

/// Bottom sheet with a title and arbitrary children.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  String? title,
  required List<Widget> Function(BuildContext) children,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 480),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + MediaQuery.viewInsetsOf(ctx).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ...children(ctx),
          ],
        ),
      ),
    ),
  );
}

class SheetOption extends StatelessWidget {
  const SheetOption({super.key, required this.label, required this.onTap, this.icon, this.selected = false});
  final String label;
  final VoidCallback onTap;
  final AppIcons? icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: icon == null ? null : AppIcon(icon!, color: AppColors.text),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      trailing: selected ? const AppIcon(AppIcons.check, color: AppColors.primary, size: 20) : null,
      onTap: onTap,
    );
  }
}

/// Opens a picker sheet for [options] and returns the chosen one.
Future<T?> pickOption<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) label,
  T? selected,
}) {
  return showAppSheet<T>(
    context,
    title: title,
    children: (ctx) => [
      for (final o in options)
        SheetOption(label: label(o), selected: o == selected, onTap: () => Navigator.pop(ctx, o)),
    ],
  );
}

/// Tappable read-only field that opens a picker (Source / Status / Assign to).
class SelectField<T> extends StatelessWidget {
  const SelectField({
    super.key,
    this.label,
    required this.value,
    required this.options,
    required this.optionLabel,
    required this.onChanged,
    this.hint = 'Select',
  });

  final String? label;
  final T? value;
  final List<T> options;
  final String Function(T) optionLabel;
  final ValueChanged<T> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final v = value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) FieldLabel(label!),
          Material(
            color: AppColors.input,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final picked = await pickOption<T>(
                  context,
                  title: label ?? hint,
                  options: options,
                  label: optionLabel,
                  selected: value,
                );
                if (picked != null) onChanged(picked);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        v == null ? hint : optionLabel(v),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: v == null ? AppColors.textLight : AppColors.text),
                      ),
                    ),
                    const AppIcon(AppIcons.chevronDown, size: 18, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small bordered dropdown pill ("Today ▾", "This Month ▾").
class PillSelect extends StatelessWidget {
  const PillSelect({super.key, required this.value, required this.options, required this.onChanged});
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final p = await pickOption<String>(
          context,
          title: 'Select period',
          options: options,
          label: (s) => s,
          selected: value,
        );
        if (p != null) onChanged(p);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            const AppIcon(AppIcons.chevronDown, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

/// Horizontal row of filter chips.
class FilterChips<T> extends StatelessWidget {
  const FilterChips({super.key, required this.items, required this.value, required this.onChanged});
  final List<(T, String)> items;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (key, label) in items)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: key == value ? AppColors.primary : AppColors.chip,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onChanged(key),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: key == value ? Colors.white : AppColors.text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppFab extends StatelessWidget {
  const AppFab({super.key, required this.onPressed, this.icon = AppIcons.add});
  final VoidCallback onPressed;
  final AppIcons icon;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      child: AppIcon(icon, size: 28),
    );
  }
}

class CheckBox extends StatelessWidget {
  const CheckBox({super.key, required this.checked, required this.onTap, this.color = AppColors.primary});
  final bool checked;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: checked ? color : Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: checked ? color : AppColors.border, width: 1.5),
        ),
        child: checked ? const AppIcon(AppIcons.check, size: 14, color: Colors.white) : null,
      ),
    );
  }
}

/// Bottom hairline that starts [indent] px in (rows divided under their text, not their icon).
/// Use as a Container `foregroundDecoration`.
class IndentedDivider extends Decoration {
  const IndentedDivider(this.indent);
  final double indent;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _IndentedDividerPainter(indent);
}

class _IndentedDividerPainter extends BoxPainter {
  _IndentedDividerPainter(this.indent);
  final double indent;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size!;
    final y = offset.dy + size.height - 0.5;
    canvas.drawLine(
      Offset(offset.dx + indent, y),
      Offset(offset.dx + size.width, y),
      Paint()..color = const Color(0xFFEDF1F7),
    );
  }
}
