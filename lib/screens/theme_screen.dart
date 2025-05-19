import 'package:flutter/material.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final colorItems = [
      _ColorItem('primary', theme.colorScheme.primary),
      _ColorItem('onPrimary', theme.colorScheme.onPrimary),
      _ColorItem('secondary', theme.colorScheme.secondary),
      _ColorItem('onSecondary', theme.colorScheme.onSecondary),
      _ColorItem('error', theme.colorScheme.error),
      _ColorItem('onError', theme.colorScheme.onError),
      _ColorItem('surface', theme.colorScheme.surface),
      _ColorItem('onSurface', theme.colorScheme.onSurface),
    ];

    final textItems = [
      _TextItem('headlineLarge', textTheme.headlineLarge),
      _TextItem('titleLarge', textTheme.titleLarge),
      _TextItem('bodyLarge', textTheme.bodyLarge),
      _TextItem('bodyMedium', textTheme.bodyMedium),
      _TextItem('labelLarge', textTheme.labelLarge),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Theme (${isDark ? 'Dark' : 'Light'})')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        children: [
          _SectionGroup(
            title: 'Color Theme',
            children:
                colorItems
                    .map(
                      (item) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: item.color,
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(
                            item.name,
                            style: TextStyle(
                              color: _getContrastColor(item.color),
                            ),
                          ),
                          trailing: Text(
                            '#${_colorToHex(item.color)}',
                            style: TextStyle(
                              color: _getContrastColor(
                                item.color,
                              ).withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 24),
          _SectionGroup(
            title: 'Text Theme',
            children:
                textItems
                    .map(
                      (item) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.transparent,
                        ),
                        child: ListTile(
                          title: Text(item.name, style: item.style),
                          trailing:
                              item.style != null
                                  ? Text(
                                    'S: ${item.style!.fontSize?.toInt() ?? '-'}, W: ${item.style!.fontWeight?.index != null ? _weightToString(item.style!.fontWeight!) : '-'}, C: #${item.style!.color != null ? _colorToHex(item.style!.color!) : '-'}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                      fontSize: 13,
                                    ),
                                  )
                                  : null,
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _ColorItem {
  final String name;
  final Color color;
  const _ColorItem(this.name, this.color);
}

class _TextItem {
  final String name;
  final TextStyle? style;
  const _TextItem(this.name, this.style);
}

Color _getContrastColor(Color color) {
  // YIQ 공식으로 명도에 따라 흰색/검정 텍스트 선택 (0~255 보장)
  // 완전한 흰색(0xFFFFFFFF) 또는 매우 밝은 색상은 무조건 검정색 반환
  if (color == Colors.white) return Colors.black;
  final r = color.r.round();
  final g = color.g.round();
  final b = color.b.round();
  final yiq = ((r * 299) + (g * 587) + (b * 114)) / 1000;
  return yiq >= 128 ? Colors.black : Colors.white;
}

String _colorToHex(Color color) {
  // Flutter Color의 int 값을 0xAARRGGBB 형태로 변환
  final red =
      (color.r * 255).toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
  final green =
      (color.g * 255).toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
  final blue =
      (color.b * 255).toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
  final alpha =
      (color.a * 255).toInt().toRadixString(16).padLeft(2, '0').toUpperCase();

  return '0x$alpha$red$green$blue';
}

String _weightToString(FontWeight weight) {
  switch (weight) {
    case FontWeight.w100:
      return '100';
    case FontWeight.w200:
      return '200';
    case FontWeight.w300:
      return '300';
    case FontWeight.w400:
      return '400';
    case FontWeight.w500:
      return '500';
    case FontWeight.w600:
      return '600';
    case FontWeight.w700:
      return '700';
    case FontWeight.w800:
      return '800';
    case FontWeight.w900:
      return '900';
    default:
      return '-';
  }
}
