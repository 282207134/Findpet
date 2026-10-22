import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:findpet/core/app_state.dart';
import 'package:findpet/data/local_repository.dart';
import 'package:findpet/data/models.dart';

void main() {
  late AppState state;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    state = AppState(await LocalRepository.open());
  });
  test('cart is deduplicated; empty checkout cannot create orders', () {
    expect(state.placeOrder(), isNull);
    state.addToCart(seedPets.first);
    state.addToCart(seedPets.first);
    expect(state.cartPets, hasLength(1));
    expect(state.subtotal, 150);
    state.removeFromCart('dog');
    expect(state.cartPets, isEmpty);
  });
  test('checkout snapshots pets, address, and totals, then clears cart', () {
    state.addToCart(seedPets[0]);
    state.addToCart(seedPets[1]);
    state.addAddress(const Address('Home', 'Tokyo', '1 Pet Street'));
    state.addPayment(const PaymentMethod('Credit Card', 'Anam', '4242'));
    final order = state.placeOrder()!;
    expect(order.subtotal, 300);
    expect(order.total, 310);
    expect(order.address.detail, '1 Pet Street');
    expect(order.payment, contains('4242'));
    expect(state.cartPets, isEmpty);
    state.addToCart(seedPets[2]);
    expect(order.pets, hasLength(2));
  });
  test(
    'local snapshot restores favorites, listings, messages, and orders',
    () async {
      state.finishOnboarding();
      state.signIn('Test');
      state.toggleFavorite('dog');
      state.publish(
        const Pet(
          id: 'my-pet',
          name: 'Milo',
          category: 'Cat',
          image: 'cat',
          color: Color(0xFFCECFFF),
        ),
      );
      state.send('Hello Monika');
      state.send('Hello James', 'James');
      state.addToCart(seedPets[0]);
      state.placeOrder();
      await state.save();
      final restored = AppState(await LocalRepository.open());
      expect(restored.onboarded && restored.signedIn, isTrue);
      expect(restored.name, 'Test');
      expect(restored.favorites, contains('dog'));
      expect(restored.published.single.name, 'Milo');
      expect(restored.messages['Monika'], ['Hello Monika']);
      expect(restored.messages['James'], ['Hello James']);
      expect(restored.orders.single.total, 160);
    },
  );
  test('a malformed snapshot falls back without crashing', () async {
    await state.repository.preferences.setString(
      LocalRepository.storageKey,
      '{broken',
    );
    final restored = AppState(await LocalRepository.open());
    expect(restored.pets, hasLength(4));
    expect(restored.signedIn, isFalse);
  });
}
