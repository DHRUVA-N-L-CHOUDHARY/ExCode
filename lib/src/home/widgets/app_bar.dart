import 'package:clipboard/clipboard.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:excode/src/app.dart';
import 'package:excode/src/factory.dart';
import 'package:excode/src/home/providers/editor_provider.dart';
import 'package:excode/src/home/providers/output_provider.dart';
import 'package:excode/src/home/services/api.dart';
import 'package:excode/src/home/services/language.dart';
import 'package:excode/src/home/widgets/snackbar.dart';
import 'package:excode/src/settings/providers/settings_provider.dart';
import 'package:excode/src/settings/providers/theme_provider.dart';
import 'package:excode/src/settings/services/hastebin.dart';
import 'package:excode/src/settings/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../helpers.dart';

class AppBarWidget extends HookConsumerWidget with PreferredSizeWidget {
  const AppBarWidget({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorLanguage = ref.watch(editorLanguageStateProvider);
    final globalTheme = ref.watch(themeStateProvider);

    return AppBar(
      title: DropdownSearch<Languages>(
        mode: Mode.MENU,
        popupBackgroundColor: globalTheme.primaryColor,
        showSearchBox: true,
        selectedItem: langMap[editorLanguage]!.lang,
        items: Languages.values,
        itemAsString: (Languages? e) => e.toString().substring(10).capitalize(),
        onChanged: (val) {
          String lang = ApiHandler.getNameFromLang(val!);
          ref.watch(editorLanguageStateProvider.notifier).setLanguage(lang);
          ref
              .watch(editorContentStateProvider.notifier)
              .setContent(const None(), lang);
        },
      ),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () async {
            await ref.watch(outputStateProvider.notifier).setOutput(
                  langMap[editorLanguage]!.lang,
                  ref.watch(editorContentStateProvider),
                );
            ref.watch(outputIsVisibleStateProvider.notifier).showOutput();
            if (ref.watch(saveOnRunProvider)) {
              await ref.watch(editorContentStateProvider.notifier).saveContent(
                    ref.read(editorLanguageStateProvider),
                    ref.read(editorContentStateProvider),
                  );
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.restorablePushNamed(context, SettingsView.routeName);
          },
        ),
        Consumer(builder: (_, ref, __) {
          return PopupMenuButton<String>(itemBuilder: ((context) {
            return [
              PopupMenuItem(
                child: const Text('Clear'),
                onTap: () {
                  if (!ref.watch(lockProvider)) {
                    ref
                        .watch(editorContentStateProvider.notifier)
                        .setContent(const Some(''));
                  }
                },
              ),
              PopupMenuItem(
                child: const Text('Save'),
                onTap: () async {
                  await ref
                      .watch(editorContentStateProvider.notifier)
                      .saveContent(
                        ref.read(editorLanguageStateProvider),
                        ref.read(editorContentStateProvider),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                    content: 'Saved to local storage!',
                    state: ActionState.success,
                  ));
                },
              ),
              PopupMenuItem(
                child: const Text('Hastebin'),
                onTap: () async {
                  final url =
                      await HasteBin.post(ref.read(editorContentStateProvider));
                  url.match(
                    (l) => ScaffoldMessenger.of(context).showSnackBar(
                        snackBarWidget(content: l, state: ActionState.error)),
                    (r) => ScaffoldMessenger.of(context).showSnackBar(
                      snackBarWidget(
                        content:
                            'Uploaded to hastebin. The url expires after a few days!',
                        state: ActionState.success,
                        action: SnackBarAction(
                          label: 'Copy',
                          onPressed: () =>
                              FlutterClipboard.copy(r).then((value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              snackBarWidget(
                                content: 'Copied hastebin url to clipboard',
                                state: ActionState.success,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ];
          }));
        }),
      ],
    );
  }
}
