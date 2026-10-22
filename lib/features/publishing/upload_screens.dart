import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

class PetPhoto {
  const PetPhoto({this.asset = 'dog', this.bytes});
  final String asset;
  final String? bytes;
  Widget image({double? height}) => bytes == null
      ? Image.asset(
          'assets/images/$asset.png',
          height: height,
          fit: BoxFit.contain,
        )
      : Image.memory(base64Decode(bytes!), height: height, fit: BoxFit.contain);
}

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      weight = TextEditingController(),
      price = TextEditingController(),
      location = TextEditingController(),
      description = TextEditingController();
  PetPhoto? photo;
  String type = 'Dog', gender = 'Female';
  DateTime? birthday;
  bool publishing = false;
  @override
  void dispose() {
    for (final c in [name, weight, price, location, description]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> selectPhoto() async {
    final value = await Navigator.push<PetPhoto>(
      context,
      MaterialPageRoute(builder: (_) => const PhotoExplorer()),
    );
    if (value != null && mounted) setState(() => photo = value);
  }

  void publish() {
    if (publishing || !form.currentState!.validate()) return;
    if (photo == null) {
      toast(context, 'Please choose a pet photo');
      return;
    }
    if (birthday == null) {
      toast(context, 'Please select a birthdate');
      return;
    }
    setState(() => publishing = true);
    final years = DateTime.now().difference(birthday!).inDays ~/ 365;
    final pet = Pet(
      id: 'pet-${DateTime.now().microsecondsSinceEpoch}',
      name: name.text.trim(),
      category: type,
      image: photo!.asset,
      photo: photo!.bytes,
      color: const Color(0xFFE4E7FF),
      sex: gender,
      price: int.parse(price.text),
      age: years == 0 ? 'Under 1 year' : '$years years',
      location: location.text.trim(),
      description: '${description.text.trim()}\n\nWeight: ${weight.text} kg',
    );
    AppScope.of(context).publish(pet);
    form.currentState!.reset();
    for (final c in [name, weight, price, location, description]) {
      c.clear();
    }
    setState(() {
      photo = null;
      birthday = null;
      publishing = false;
    });
    toast(context, '${pet.name} is published! Find your listing on Home.');
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    back: false,
    title: 'Upload Pet',
    child: Form(
      key: form,
      child: ListView(
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: selectPhoto,
              child: SizedBox(
                height: 155,
                child: photo == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera_rounded,
                            size: 48,
                            color: Color(0xFFD9DDDE),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Upload Image',
                            style: TextStyle(color: muted, fontSize: 12),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12),
                        child: photo!.image(height: 130),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          LabeledField(
            'Pet Name',
            controller: name,
            hint: 'Your Pet Title',
            validator: requiredText,
          ),
          const Text(
            'Type Of Pet',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: type,
            items: ['Dog', 'Cat', 'Birds', 'Others']
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(v, style: const TextStyle(fontSize: 12)),
                  ),
                )
                .toList(),
            onChanged: (v) => type = v!,
          ),
          const SizedBox(height: 20),
          const Text(
            'Birthdate',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final value = await showDatePicker(
                context: context,
                initialDate:
                    birthday ?? DateTime(DateTime.now().year - 1, 8, 12),
                firstDate: DateTime(1990),
                lastDate: DateTime.now(),
              );
              if (value != null && mounted) setState(() => birthday = value);
            },
            icon: const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: orange,
            ),
            label: Text(
              birthday == null
                  ? 'Select birthdate'
                  : '${birthday!.day} / ${birthday!.month} / ${birthday!.year}',
              style: const TextStyle(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide.none,
              alignment: Alignment.centerLeft,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Gender',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: gender,
            items: ['Female', 'Male']
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(v, style: const TextStyle(fontSize: 12)),
                  ),
                )
                .toList(),
            onChanged: (v) => gender = v!,
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LabeledField(
                  'Weight',
                  controller: weight,
                  hint: '2.5 kg',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) => (double.tryParse(v ?? '') ?? 0) > 0
                      ? null
                      : 'Enter a weight',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LabeledField(
                  'Price',
                  controller: price,
                  hint: '150 \$',
                  keyboardType: TextInputType.number,
                  validator: (v) => (int.tryParse(v ?? '') ?? -1) >= 0
                      ? null
                      : 'Enter a valid price',
                ),
              ),
            ],
          ),
          LabeledField(
            'Location',
            controller: location,
            hint: 'City, street',
            validator: requiredText,
          ),
          LabeledField(
            'About your pet',
            controller: description,
            hint: 'Personality, health, and care needs',
            maxLines: 3,
            validator: requiredText,
          ),
          const SizedBox(height: 8),
          PrimaryButton('Publish Pet', onPressed: publishing ? null : publish),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}

class PhotoExplorer extends StatelessWidget {
  const PhotoExplorer({super.key});
  Future<void> pick(BuildContext context, ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 75,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!context.mounted) return;
      if (bytes.length > 4 * 1024 * 1024) {
        toast(context, 'Please choose an image smaller than 4 MB');
        return;
      }
      Navigator.pop(context, PetPhoto(bytes: base64Encode(bytes)));
    } on Object {
      if (context.mounted) {
        toast(
          context,
          'Photo access is unavailable. Check permissions or choose a sample photo.',
        );
      }
    }
  }

  Future<void> album(BuildContext context, String folder) async {
    final value = await Navigator.push<PetPhoto>(
      context,
      MaterialPageRoute(builder: (_) => AlbumScreen(folder: folder)),
    );
    if (value != null && context.mounted) Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Explorer',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          mainAxisSpacing: 18,
          crossAxisSpacing: 14,
          children: [
            for (final (icon, label) in [
              (Icons.photo_camera_rounded, 'Take Picture'),
              (Icons.folder_rounded, 'Album'),
              (Icons.folder_rounded, 'Download'),
              (Icons.folder_rounded, 'Bluetooth'),
              (Icons.folder_rounded, 'Camera'),
              (Icons.folder_rounded, 'DCIM'),
            ])
              Material(
                color: label == 'Take Picture'
                    ? const Color(0xFFE3E7FF)
                    : Colors.white,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => label == 'Take Picture'
                      ? pick(context, ImageSource.camera)
                      : album(context, label),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 42,
                        color: label == 'Take Picture' ? blue : orange,
                      ),
                      const SizedBox(height: 8),
                      Text(label, style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 26),
        TextButton.icon(
          onPressed: () => pick(context, ImageSource.gallery),
          icon: const Icon(Icons.photo_library_outlined, color: blue),
          label: const Text(
            'Choose from device',
            style: TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Sample folders contain the original Pixso pet photos. You can also choose a photo from your device.',
          style: TextStyle(color: muted, fontSize: 11, height: 1.9),
        ),
      ],
    ),
  );
}

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key, required this.folder});
  final String folder;
  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  String selected = 'dog';
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Explorer',
    bottom: PrimaryButton(
      'Use photo',
      onPressed: () => Navigator.pop(context, PetPhoto(asset: selected)),
    ),
    child: ListView(
      children: [
        Row(
          children: [
            Surface(
              child: Column(
                children: [
                  const Icon(Icons.folder_rounded, size: 58, color: orange),
                  Text(widget.folder, style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Name',
                    style: TextStyle(fontSize: 10, color: muted),
                  ),
                  Text(widget.folder),
                  const SizedBox(height: 8),
                  const Text(
                    '4 sample photos\nSource: Pixso reference',
                    style: TextStyle(fontSize: 11, color: muted, height: 1.8),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Surface(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final pet in seedPets)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: PetPicture(pet, size: 48),
                  title: Text(
                    '${pet.image}.png',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Icon(
                    selected == pet.image
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected == pet.image
                        ? orange
                        : const Color(0xFFD4D8D9),
                    size: 20,
                  ),
                  onTap: () => setState(() => selected = pet.image),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
