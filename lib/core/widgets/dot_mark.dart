import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DotMark extends StatelessWidget {
  const DotMark({
    this.size = 44,
    super.key,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.brown,
          borderRadius: BorderRadius.circular(size * 0.24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x242F2923),
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.18),
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: size * 0.08,
            crossAxisSpacing: size * 0.08,
            children: List.generate(9, (index) {
              final active = index == 0 ||
                  index == 2 ||
                  index == 4 ||
                  index == 6 ||
                  index == 8;
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: active ? AppTheme.caramel : AppTheme.surface,
                  borderRadius: BorderRadius.circular(size * 0.035),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
