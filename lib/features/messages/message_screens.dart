import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

void showContactDialog(BuildContext context, {bool video = false}) =>
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(video ? 'Video call' : 'Call owner'),
        content: const Text(
          'Calling is not connected in this local demo. You can explore the chat screen and save messages on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Got it'),
          ),
        ],
      ),
    );

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return PageFrame(
      title: 'Message',
      back: false,
      child: ListView(
        children: [
          for (final (i, name, subtitle) in [
            (0, 'Monika', 'Is this little one still available?'),
            (1, 'James', 'I’d love to know more.'),
            (2, 'Daniel', 'Thanks for your help!'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  leading: i == 0
                      ? const Avatar(size: 50)
                      : CircleAvatar(
                          backgroundColor: i == 1
                              ? const Color(0xFFDBE6F3)
                              : const Color(0xFFE0EFDD),
                          child: Text(
                            name[0],
                            style: const TextStyle(color: ink),
                          ),
                        ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    state.messages[name]?.lastOrNull ?? subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: muted),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: orange,
                    size: 20,
                  ),
                  onTap: () => openPage(context, ChatScreen(contact: name)),
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Demo conversations · messages stay on this device',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.contact = 'Monika'});
  final String contact;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final input = TextEditingController();
  final scroll = ScrollController();
  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  void send() {
    if (input.text.trim().isEmpty) return;
    AppScope.of(context).send(input.text, widget.contact);
    input.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget bubble(String text, {bool sent = false, Widget? child}) => Align(
    alignment: sent ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: sent ? cream : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(fontSize: 12, height: 1.7)),
          ?child,
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return PageFrame(
      child: Column(
        children: [
          Surface(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Avatar(size: 48),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.contact,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        'Demo pet owner',
                        style: TextStyle(color: muted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                SquareAction(
                  Icons.call_outlined,
                  label: 'Call',
                  onTap: () => showContactDialog(context),
                ),
                const SizedBox(width: 8),
                SquareAction(
                  Icons.videocam_outlined,
                  label: 'Video call',
                  color: blue,
                  onTap: () => showContactDialog(context, video: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              controller: scroll,
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      'TODAY',
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                bubble('Hi, how are you? 🐾', sent: true),
                bubble(
                  'I’m good, thank you! Would you like to meet this little friend?',
                ),
                bubble(
                  'Such a sweet companion. Is there anything I should know before we meet?',
                  sent: true,
                ),
                for (final text in state.messages[widget.contact] ?? <String>[])
                  bubble(text, sent: true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    onSubmitted: (_) => send(),
                    textInputAction: TextInputAction.send,
                    decoration: const InputDecoration(
                      hintText: 'Type something…',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SquareAction(
                  Icons.send_rounded,
                  label: 'Send message',
                  color: blue,
                  onTap: send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
