import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/models.dart';
import 'theme.dart';

void openPage(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
void toast(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));

class SoftBackground extends StatelessWidget {
  const SoftBackground({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/background.png'),
        fit: BoxFit.cover,
      ),
    ),
    child: child,
  );
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.child,
    this.title,
    this.bottom,
    this.trailing,
    this.back = true,
    this.padding = 28,
  });
  final Widget child;
  final String? title;
  final Widget? bottom, trailing;
  final bool back;
  final double padding;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SoftBackground(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(padding - 10, 8, padding, 8),
              child: Row(
                children: [
                  if (back)
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: ink,
                        size: 23,
                      ),
                    )
                  else
                    const SizedBox(height: 48),
                  const Spacer(),
                  ?trailing,
                ],
              ),
            ),
            if (title != null)
              Padding(
                padding: EdgeInsets.fromLTRB(padding, 10, padding, 20),
                child: Text(
                  title!,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: child,
              ),
            ),
            if (bottom != null)
              Padding(
                padding: EdgeInsets.fromLTRB(padding, 12, padding, 22),
                child: bottom,
              ),
          ],
        ),
      ),
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      boxShadow: onPressed == null
          ? []
          : [
              BoxShadow(
                color: orange.withValues(alpha: .23),
                blurRadius: 18,
                offset: const Offset(3, 7),
              ),
            ],
    ),
    child: FilledButton(onPressed: onPressed, child: Text(label)),
  );
}

class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = Colors.white,
    this.radius = 22,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double radius;
  @override
  Widget build(BuildContext context) => Material(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: padding, child: child),
  );
}

class LabeledField extends StatelessWidget {
  const LabeledField(
    this.label, {
    super.key,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.obscure = false,
    this.suffix,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscure;
  final Widget? suffix;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 9),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
        ),
      ],
    ),
  );
}

String? requiredText(String? value) =>
    value == null || value.trim().isEmpty ? 'Please complete this field' : null;
String? emailValidator(String? value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')
    ? null
    : 'Enter a valid email address';

class Avatar extends StatelessWidget {
  const Avatar({super.key, this.size = 54});
  final double size;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: SizedBox(
      width: size,
      height: size,
      child: Image.asset('assets/images/avatar.png', fit: BoxFit.cover),
    ),
  );
}

class SquareAction extends StatelessWidget {
  const SquareAction(
    this.icon, {
    super.key,
    required this.onTap,
    required this.label,
    this.color = orange,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: label,
    onPressed: onTap,
    style: IconButton.styleFrom(
      backgroundColor: color.withValues(alpha: .12),
      foregroundColor: color,
      fixedSize: const Size(48, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    icon: Icon(icon, size: 24),
  );
}

class PetPicture extends StatelessWidget {
  const PetPicture(this.pet, {super.key, this.size = 130, this.hero = false});
  final Pet pet;
  final double size;
  final bool hero;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(hero ? 0 : 24),
    child: Container(
      width: size,
      height: size,
      color: pet.color,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: -size * .15,
            bottom: -size * .6,
            child: Container(
              width: size * 1.3,
              height: size,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .055),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(hero ? 25 : 12),
            child: pet.photo == null
                ? Image.asset(
                    'assets/images/${pet.image}.png',
                    fit: BoxFit.contain,
                    height: size * .9,
                  )
                : Image.memory(
                    base64Decode(pet.photo!),
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                  ),
          ),
        ],
      ),
    ),
  );
}

class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.color = blue});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: TextStyle(fontSize: 10, color: color)),
  );
}

class PetCard extends StatelessWidget {
  const PetCard(
    this.pet, {
    super.key,
    this.onTap,
    this.trailing,
    this.compact = false,
  });
  final Pet pet;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool compact;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: LayoutBuilder(
            builder: (context, box) {
              final imageSize = compact
                  ? 92.0
                  : (box.maxWidth * .4).clamp(88.0, 138.0);
              return Row(
                children: [
                  PetPicture(pet, size: imageSize),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet.name,
                            maxLines: 2,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: compact ? 12 : 14,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!compact) ...[
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Tag(pet.sex),
                                Tag(pet.age, color: orange),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '⌖ ${pet.location} (${pet.distance} km)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 9, color: muted),
                            ),
                            const SizedBox(height: 5),
                          ],
                          Text(
                            '${pet.price}\$',
                            style: const TextStyle(
                              color: orange,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          ?trailing,
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState(
    this.title,
    this.detail, {
    super.key,
    this.icon = Icons.pets_rounded,
  });
  final String title, detail;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: orange, size: 48),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}
