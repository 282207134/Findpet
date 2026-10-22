import 'package:flutter/material.dart';

import '../data/local_repository.dart';
import '../data/models.dart';

class AppState extends ChangeNotifier {
  AppState(this.repository) {
    final j = repository.load();
    try {
      signedIn = j['signedIn'] ?? false;
      onboarded = j['onboarded'] ?? false;
      name = j['name'] ?? 'Anam';
      selectedAddress = j['selectedAddress'] ?? 0;
      selectedPayment = j['selectedPayment'] ?? 1;
      favorites.addAll(List<String>.from(j['favorites'] ?? []));
      published.addAll(
        (j['published'] as List? ?? []).map((p) => Pet.fromJson(p)),
      );
      cart.addAll(List<String>.from(j['cart'] ?? []));
      orders.addAll(
        (j['orders'] as List? ?? []).map((o) => PetOrder.fromJson(o)),
      );
      for (final entry
          in (j['messages'] as Map<String, dynamic>? ?? {}).entries) {
        messages[entry.key] = List<String>.from(entry.value);
      }
      if (j['addresses'] != null) {
        addresses
          ..clear()
          ..addAll((j['addresses'] as List).map((a) => Address.fromJson(a)));
      }
      if (j['payments'] != null) {
        payments
          ..clear()
          ..addAll(
            (j['payments'] as List).map((p) => PaymentMethod.fromJson(p)),
          );
      }
      about = j['about'] ?? about;
    } on Object {
      storageError = 'Some saved data could not be restored.';
    }
  }
  final LocalRepository repository;
  bool signedIn = false, onboarded = false;
  String
  name = 'Anam',
  about =
      'Pet lover, happy to help little companions find a caring home. Let’s make their next chapter a wonderful one.',
  storageError = '';
  final Set<String> favorites = {};
  final List<Pet> published = [];
  final List<String> cart = [];
  final Map<String, List<String>> messages = {};
  final List<PetOrder> orders = [];
  final List<Address> addresses = [
    Address('Honduras', 'Jakarta', '891 Village Boulevard'),
    Address('Marvihoje', 'Jakarta', '215 Woods Heights'),
  ];
  final List<PaymentMethod> payments = [
    PaymentMethod('Credit Card', 'Anam', '3579'),
    PaymentMethod('Mobile Banking', 'Anam', '3579'),
  ];
  int selectedAddress = 0, selectedPayment = 1;
  List<Pet> get pets => [...seedPets, ...published];
  List<Pet> get cartPets => pets.where((p) => cart.contains(p.id)).toList();
  int get subtotal => cartPets.fold(0, (total, p) => total + p.price);
  Address get address =>
      addresses[selectedAddress.clamp(0, addresses.length - 1)];
  PaymentMethod get payment =>
      payments[selectedPayment.clamp(0, payments.length - 1)];

  Future<void> save() async {
    notifyListeners();
    try {
      await repository.save({
        'signedIn': signedIn,
        'onboarded': onboarded,
        'name': name,
        'about': about,
        'selectedAddress': selectedAddress,
        'selectedPayment': selectedPayment,
        'favorites': favorites.toList(),
        'cart': cart,
        'published': published.map((p) => p.toJson()).toList(),
        'orders': orders.map((o) => o.toJson()).toList(),
        'messages': messages,
        'addresses': addresses.map((a) => a.toJson()).toList(),
        'payments': payments.map((p) => p.toJson()).toList(),
      });
    } on Object {
      storageError = 'Your changes could not be saved on this device.';
      notifyListeners();
    }
  }

  void finishOnboarding() {
    onboarded = true;
    save();
  }

  void signIn(String displayName) {
    name = displayName.trim().isEmpty ? 'Anam' : displayName.trim();
    signedIn = true;
    save();
  }

  void signOut() {
    signedIn = false;
    save();
  }

  void toggleFavorite(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    save();
  }

  void addToCart(Pet pet) {
    if (!cart.contains(pet.id)) cart.add(pet.id);
    save();
  }

  void removeFromCart(String id) {
    cart.remove(id);
    save();
  }

  void publish(Pet pet) {
    published.insert(0, pet);
    save();
  }

  void send(String message, [String contact = 'Monika']) {
    if (message.trim().isNotEmpty) {
      messages.putIfAbsent(contact, () => []).add(message.trim());
      save();
    }
  }

  void addAddress(Address value) {
    addresses.add(value);
    selectedAddress = addresses.length - 1;
    save();
  }

  void addPayment(PaymentMethod value) {
    payments.add(value);
    selectedPayment = payments.length - 1;
    save();
  }

  PetOrder? placeOrder() {
    if (cartPets.isEmpty) return null;
    final order = PetOrder(
      id: 'FP${DateTime.now().millisecondsSinceEpoch}',
      pets: List.of(cartPets),
      address: address,
      payment: '${payment.label} •••• ${payment.last4}',
      createdAt: DateTime.now(),
    );
    orders.insert(0, order);
    cart.clear();
    save();
    return order;
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
