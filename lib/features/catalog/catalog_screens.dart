import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../checkout/checkout_screens.dart';
import '../messages/message_screens.dart';

class CartAction extends StatelessWidget {
  const CartAction({super.key});
  @override
  Widget build(BuildContext context) => Badge(
    isLabelVisible: AppScope.of(context).cart.isNotEmpty,
    label: Text('${AppScope.of(context).cart.length}'),
    backgroundColor: orange,
    child: SquareAction(
      Icons.shopping_cart_outlined,
      label: 'Cart',
      color: orange,
      onTap: () => openPage(context, const CartScreen()),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final search = TextEditingController();
  String? category;
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final pets = state.pets
        .where((p) => category == null || p.category == category)
        .toList();
    return Scaffold(
      body: SoftBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => toast(context, 'Welcome, ${state.name}!'),
                    child: const Avatar(),
                  ),
                  const Spacer(),
                  const CartAction(),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Hello ${state.name}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Text(
                'Find a pet to be your friends',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 26),
              TextField(
                controller: search,
                onSubmitted: (v) => openPage(context, ExploreScreen(query: v)),
                decoration: InputDecoration(
                  hintText: 'Search',
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(7),
                    child: SquareAction(
                      Icons.search_rounded,
                      label: 'Search pets',
                      onTap: () =>
                          openPage(context, ExploreScreen(query: search.text)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 55,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final (name, icon, color) in [
                      ('Dog', Icons.pets, cream),
                      ('Cat', Icons.pets_outlined, const Color(0xFFE2E7FF)),
                      ('Birds', Icons.flutter_dash, const Color(0xFFE8FFDB)),
                      (
                        'Others',
                        Icons.emoji_nature_outlined,
                        const Color(0xFFFFDEE2),
                      ),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: TextButton.icon(
                          onPressed: () => setState(
                            () => category = category == name ? null : name,
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: color,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: category == name
                                    ? ink
                                    : Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: Icon(icon, size: 17),
                          label: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Popular',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontSize: 20),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => openPage(context, const ExploreScreen()),
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(
                      Icons.north_east_rounded,
                      color: orange,
                      size: 18,
                    ),
                    label: const Text(
                      'View All',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Favorites',
                    onPressed: () => openPage(
                      context,
                      const ExploreScreen(favoritesOnly: true),
                    ),
                    icon: const Icon(
                      Icons.favorite_border_rounded,
                      size: 21,
                      color: orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final pet in pets)
                PetCard(
                  pet,
                  onTap: () => openPage(context, PetDetailScreen(pet: pet)),
                ),
              if (pets.isEmpty)
                const EmptyState(
                  'No pets here yet',
                  'Try a different category or publish a pet.',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PetFilter {
  const PetFilter({
    this.min = 0,
    this.max = 2000,
    this.location = '',
    this.keyword = '',
    this.sex = 'Any',
  });
  final int min, max;
  final String location, keyword, sex;
  bool matches(Pet p) =>
      p.price >= min &&
      p.price <= max &&
      p.location.toLowerCase().contains(location.toLowerCase()) &&
      '${p.name} ${p.category}'.toLowerCase().contains(keyword.toLowerCase()) &&
      (sex == 'Any' || p.sex == sex);
  bool get active =>
      min != 0 ||
      max != 2000 ||
      location.isNotEmpty ||
      keyword.isNotEmpty ||
      sex != 'Any';
}

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, this.query = '', this.favoritesOnly = false});
  final String query;
  final bool favoritesOnly;
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final search = TextEditingController(text: widget.query);
  String sort = 'Recommended';
  PetFilter filter = const PetFilter();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final pets = state.pets
        .where(
          (p) =>
              (!widget.favoritesOnly || state.favorites.contains(p.id)) &&
              '${p.name} ${p.category}'.toLowerCase().contains(
                search.text.toLowerCase(),
              ) &&
              filter.matches(p),
        )
        .toList();
    switch (sort) {
      case 'Lowest Price':
        pets.sort((a, b) => a.price.compareTo(b.price));
      case 'Highest Price':
        pets.sort((a, b) => b.price.compareTo(a.price));
      case 'Nearest':
        pets.sort((a, b) => a.distance.compareTo(b.distance));
      default:
        break;
    }
    return PageFrame(
      title: widget.favoritesOnly ? 'Favorites' : 'Explore',
      trailing: const CartAction(),
      bottom: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              icon: const Icon(Icons.sort_rounded, size: 20),
              label: const Text('Sort By'),
              onPressed: () async {
                final value = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => SortScreen(selected: sort)),
                );
                if (value != null && mounted) setState(() => sort = value);
              },
            ),
          ),
          Container(width: 1, height: 24, color: const Color(0xFFEAEAEA)),
          Expanded(
            child: TextButton.icon(
              icon: const Icon(Icons.filter_alt_outlined, size: 20),
              label: Text(filter.active ? 'Filter •' : 'Filter'),
              onPressed: () async {
                final value = await Navigator.push<PetFilter>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FilterScreen(value: filter),
                  ),
                );
                if (value != null && mounted) setState(() => filter = value);
              },
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Search pets',
              prefixIcon: Icon(Icons.search, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              Tag('${pets.length} companions', color: orange),
              if (filter.sex != 'Any') Tag(filter.sex),
              if (filter.active)
                ActionChip(
                  label: const Text('Reset', style: TextStyle(fontSize: 10)),
                  onPressed: () => setState(() => filter = const PetFilter()),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: pets.isEmpty
                ? const EmptyState(
                    'No matching friends',
                    'Try another search or reset your filters.',
                  )
                : ListView(
                    children: [
                      for (final pet in pets)
                        PetCard(
                          pet,
                          onTap: () =>
                              openPage(context, PetDetailScreen(pet: pet)),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class SortScreen extends StatelessWidget {
  const SortScreen({super.key, required this.selected});
  final String selected;
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Sort',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Arrange pets by what matters to you',
          style: TextStyle(color: muted, fontSize: 12),
        ),
        const SizedBox(height: 26),
        for (final value in [
          'Recommended',
          'Nearest',
          'Lowest Price',
          'Highest Price',
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: value == selected ? cream : Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: ListTile(
                title: Text(value, style: const TextStyle(fontSize: 13)),
                trailing: value == selected
                    ? const Icon(Icons.check_rounded, color: orange)
                    : null,
                onTap: () => Navigator.pop(context, value),
              ),
            ),
          ),
      ],
    ),
  );
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key, required this.value});
  final PetFilter value;
  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final form = GlobalKey<FormState>();
  late final min = TextEditingController(text: '${widget.value.min}'),
      max = TextEditingController(text: '${widget.value.max}'),
      location = TextEditingController(text: widget.value.location),
      keyword = TextEditingController(text: widget.value.keyword);
  late String sex = widget.value.sex;
  @override
  void dispose() {
    for (final c in [min, max, location, keyword]) {
      c.dispose();
    }
    super.dispose();
  }

  String? priceValidator(String? v) =>
      int.tryParse(v ?? '') == null || int.parse(v!) < 0
      ? 'Enter a valid price'
      : null;
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Filter',
    bottom: PrimaryButton(
      'Apply filters',
      onPressed: () {
        if (!form.currentState!.validate()) return;
        if (int.parse(min.text) > int.parse(max.text)) {
          toast(context, 'Lowest price must be below highest price');
          return;
        }
        Navigator.pop(
          context,
          PetFilter(
            min: int.parse(min.text),
            max: int.parse(max.text),
            location: location.text.trim(),
            keyword: keyword.text.trim(),
            sex: sex,
          ),
        );
      },
    ),
    child: Form(
      key: form,
      child: ListView(
        children: [
          const Text(
            'A little closer to your perfect companion',
            style: TextStyle(fontSize: 12, color: muted),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: LabeledField(
                  'Lowest Price',
                  controller: min,
                  validator: priceValidator,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LabeledField(
                  'Highest Price',
                  controller: max,
                  validator: priceValidator,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          LabeledField(
            'By Location',
            controller: location,
            hint: 'California',
            suffix: const Icon(Icons.location_on_outlined, color: blue),
          ),
          LabeledField(
            'Keyword',
            controller: keyword,
            hint: 'Type, breed, or name',
            suffix: const Icon(Icons.search_rounded, color: orange),
          ),
          const Text(
            'Gender',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: sex,
            items: [
              'Any',
              'Male',
              'Female',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => sex = v!,
          ),
        ],
      ),
    ),
  );
}

class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({super.key, required this.pet});
  final Pet pet;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      body: SoftBackground(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    SizedBox(
                      height: 385,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          PetPicture(pet, size: 385, hero: true),
                          Positioned(
                            top: MediaQuery.paddingOf(context).top + 10,
                            left: 18,
                            child: IconButton(
                              tooltip: 'Back',
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                          ),
                          Positioned(
                            top: MediaQuery.paddingOf(context).top + 10,
                            right: 28,
                            child: const CartAction(),
                          ),
                          Positioned(
                            bottom: 18,
                            right: 24,
                            child: SquareAction(
                              state.favorites.contains(pet.id)
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              label: 'Favorite pet',
                              color: Colors.white,
                              onTap: () => state.toggleFavorite(pet.id),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(28, 18, 28, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Avatar(),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Monika A\nPet owner',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SquareAction(
                                Icons.call_outlined,
                                label: 'Call owner',
                                onTap: () => showContactDialog(context),
                              ),
                              const SizedBox(width: 10),
                              SquareAction(
                                Icons.mail_outline_rounded,
                                label: 'Message owner',
                                color: blue,
                                onTap: () =>
                                    openPage(context, const ChatScreen()),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Text(
                            pet.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${pet.price}\$',
                            style: const TextStyle(
                              color: orange,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '⌖ ${pet.location} (${pet.distance} km)',
                            style: const TextStyle(fontSize: 11, color: muted),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Detail',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              for (final (label, value) in [
                                ('Sex', pet.sex),
                                ('Age', pet.age),
                                ('Type', pet.category),
                              ])
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        label,
                                        style: const TextStyle(
                                          color: muted,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        value,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            pet.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: muted,
                              height: 1.9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 22),
                child: PrimaryButton(
                  'Checkout',
                  onPressed: () {
                    state.addToCart(pet);
                    openPage(context, const CartScreen());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
