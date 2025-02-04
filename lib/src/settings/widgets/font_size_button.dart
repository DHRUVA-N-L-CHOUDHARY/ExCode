import 'package:excode/src/settings/providers/settings_provider.dart';
import 'package:excode/src/settings/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FontSizeButtonWidget extends ConsumerWidget {
  const FontSizeButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 160,
      child: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: ref.watch(themeStateProvider).primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () => (ref.read(fontSizeProvider) == 10)
                  ? null
                  : ref.watch(fontSizeProvider.notifier).decrement(),
              child: const Icon(Icons.text_decrease),
              style: const ButtonStyle(
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              ref.watch(fontSizeProvider).toStringAsFixed(0),
              style: const TextStyle(fontSize: 16),
            ),
            TextButton(
              onPressed: () => (ref.read(fontSizeProvider) == 40)
                  ? null
                  : ref.watch(fontSizeProvider.notifier).increment(),
              child: const Icon(Icons.text_increase),
              style: const ButtonStyle(
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
