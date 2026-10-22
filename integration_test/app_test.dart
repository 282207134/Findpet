import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:findpet/app.dart';
import 'package:findpet/core/app_state.dart';
import 'package:findpet/core/widgets.dart';
import 'package:findpet/data/local_repository.dart';
import 'package:findpet/data/models.dart';

import 'responsive_tests.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('complete demo journeys and capture every reference screen', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(LocalRepository.storageKey);
    final state = AppState(LocalRepository(prefs));
    await tester.pumpWidget(FindpetApp(state: state));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();

    Future<void> shot(String name) async {
      FocusManager.instance.primaryFocus?.unfocus();
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first)
          .removeCurrentSnackBar();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: name);
      await binding.takeScreenshot(name);
    }

    Future<void> tap(Finder finder) async {
      await tester.ensureVisible(finder.first);
      await tester.tap(finder.first);
      await tester.pumpAndSettle();
    }

    Future<void> text(String value) => tap(find.text(value));
    Future<void> back() async {
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }

    Future<void> field(String label, String value) async {
      final f = find.descendant(
        of: find.widgetWithText(LabeledField, label),
        matching: find.byType(TextFormField),
      );
      await tester.ensureVisible(f.first);
      await tester.enterText(f.first, value);
      await tester.pumpAndSettle();
    }

    await shot('01-welcome');
    await text('Get started');
    await shot('02-onboarding-1');
    await text('Next');
    await shot('03-onboarding-2');
    await text('Next');
    await shot('04-onboarding-3');
    await text('Let’s get started');
    await shot('05-login');
    await tap(find.textContaining('Don’t have an account'));
    await shot('06-register');
    await text('Create Account');
    expect(find.text('Please complete this field'), findsOneWidget);
    await back();
    await text('Forgot Password?');
    await shot('07-forgot-password');
    await back();
    await text('Try the demo');
    await shot('08-home');
    await tap(find.textContaining('View All'));
    await shot('09-explore');
    await text('Sort By');
    await shot('10-sort');
    await text('Lowest Price');
    await text('Filter');
    await shot('11-filter');
    await field('Highest Price', '100');
    await text('Apply filters');
    expect(find.text('Speckled Tortoise'), findsOneWidget);
    expect(find.text('Labrador Retriever'), findsNothing);
    await back();
    await text('Labrador Retriever');
    await tap(find.byTooltip('Favorite pet'));
    expect(state.favorites, contains('dog'));
    await shot('12-pet-detail');
    await text('Checkout');
    state.addToCart(seedPets[1]);
    await tester.pumpAndSettle();
    await shot('13-cart');
    await text('Checkout');
    await shot('14-address');
    await text('Add Address');
    await shot('15-new-address');
    await field('Address Name', 'Home');
    await field('Select Address', 'Tokyo');
    await field('Detail Address', '1 Pet Street');
    await text('Save');
    expect(state.address.label, 'Home');
    await text('Next');
    await shot('16-payment');
    await text('Add Payment');
    await shot('17-new-payment');
    await field('Card Number', '4242424242424242');
    await field('Name Card', 'Anam');
    await field('Expiry Date', '12/30');
    await field('CVV', '123');
    await text('Save');
    expect(state.payment.last4, '4242');
    await text('Next');
    await shot('18-confirmation');
    await text('Place demo order');
    await shot('19-success');
    expect(state.orders.single.total, 310);
    expect(state.cart, isEmpty);
    await text('Back To Dashboard');
    await tap(find.byKey(const ValueKey('nav-Orders')));
    await shot('20-orders');
    await text('Labrador Retriever');
    await shot('27-order-detail');
    await back();
    await tap(find.byKey(const ValueKey('nav-Messages')));
    await shot('21-messages');
    await text('Monika');
    await tester.enterText(
      find.byType(TextField),
      'I would love to meet this pet.',
    );
    await tap(find.byTooltip('Send message'));
    await shot('22-chat');
    expect(state.messages['Monika']!.last, 'I would love to meet this pet.');
    await back();
    await tap(find.byKey(const ValueKey('nav-Upload')));
    await shot('23-upload');
    await text('Upload Image');
    await shot('24-explorer');
    await text('Album');
    await shot('25-album');
    await text('Use photo');
    await field('Pet Name', 'Milo');
    await text('Select birthdate');
    await text('OK');
    await field('Weight', '2.5');
    await field('Price', '75');
    await field('Location', 'Tokyo');
    await field(
      'About your pet',
      'A playful friend looking for a loving home.',
    );
    await shot('29-upload-filled');
    await text('Publish Pet');
    expect(state.published.single.name, 'Milo');
    await tap(find.byKey(const ValueKey('nav-Profile')));
    await shot('26-profile');
    await tap(find.byTooltip('Edit profile'));
    await field('Name', 'Anam');
    await field(
      'About',
      'Pet lover, helping little companions find their forever homes.',
    );
    await text('Save');
    await tester.pumpAndSettle();
    await state.save();
    final restored = AppState(await LocalRepository.open());
    expect(restored.orders, hasLength(1));
    expect(restored.published.single.name, 'Milo');
    expect(restored.favorites, contains('dog'));
    expect(restored.messages['Monika'], hasLength(1));
    expect(restored.payment.last4, '4242');
    expect(restored.address.city, 'Tokyo');
    await tap(find.byKey(const ValueKey('nav-Home')));
    await tester.scrollUntilVisible(
      find.text('Milo'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await shot('28-home-with-published-pet');
  });
  responsiveTests();
}
