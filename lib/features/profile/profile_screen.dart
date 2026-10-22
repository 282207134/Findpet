import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../catalog/catalog_screens.dart';
import '../messages/message_screens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  Future<void> edit(BuildContext context) async {
    final state = AppScope.of(context);
    final name = TextEditingController(text: state.name),
        about = TextEditingController(text: state.about);
    final form = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Edit profile'),
        content: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LabeledField('Name', controller: name, validator: requiredText),
                LabeledField(
                  'About',
                  controller: about,
                  maxLines: 4,
                  validator: requiredText,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (!form.currentState!.validate()) return;
              state.name = name.text.trim();
              state.about = about.text.trim();
              state.save();
              Navigator.pop(c);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    // Dialog exit animations finish before their fields release controllers.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    name.dispose();
    about.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return PageFrame(
      back: false,
      trailing: const CartAction(),
      child: ListView(
        children: [
          const SizedBox(height: 8),
          const Center(child: Avatar(size: 145)),
          const SizedBox(height: 20),
          Surface(
            child: Column(
              children: [
                Text(state.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 5),
                const Text(
                  '⌖ California, Walk suite · 2 km',
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Surface(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareAction(
                  Icons.mail_outline_rounded,
                  label: 'Open chat',
                  color: blue,
                  onTap: () => openPage(context, const ChatScreen()),
                ),
                const SizedBox(width: 18),
                SquareAction(
                  Icons.call_outlined,
                  label: 'Call',
                  onTap: () => showContactDialog(context),
                ),
                const SizedBox(width: 18),
                SquareAction(
                  Icons.videocam_outlined,
                  label: 'Video call',
                  color: blue,
                  onTap: () => showContactDialog(context, video: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Edit profile',
                      onPressed: () => edit(context),
                      icon: const Icon(
                        Icons.edit_note_rounded,
                        color: orange,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                Text(
                  state.about,
                  style: const TextStyle(
                    fontSize: 12,
                    color: muted,
                    height: 1.9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ListTile(
            leading: const Icon(Icons.favorite_border_rounded, color: orange),
            title: const Text('My favorites', style: TextStyle(fontSize: 13)),
            trailing: Text('${state.favorites.length}'),
            onTap: () =>
                openPage(context, const ExploreScreen(favoritesOnly: true)),
          ),
          if (state.storageError.isNotEmpty)
            Text(
              state.storageError,
              style: const TextStyle(color: Colors.red, fontSize: 11),
            ),
          TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Log out?'),
                content: const Text(
                  'Your favorites, messages, and orders stay saved on this device.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(c);
                      state.signOut();
                    },
                    child: const Text('Log out'),
                  ),
                ],
              ),
            ),
            child: const Text(
              'Log out',
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
