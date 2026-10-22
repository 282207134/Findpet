import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../catalog/catalog_screens.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return PageFrame(
      title: 'Your Cart',
      bottom: state.cartPets.isEmpty
          ? null
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal', style: TextStyle(color: muted)),
                    Text(
                      '${state.subtotal}\$',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  'Checkout',
                  onPressed: () => openPage(context, const AddressScreen()),
                ),
              ],
            ),
      child: state.cartPets.isEmpty
          ? const EmptyState(
              'Your cart is waiting',
              'Find a little friend you love and tap Checkout.',
            )
          : ListView(
              children: [
                for (final pet in state.cartPets)
                  PetCard(
                    pet,
                    compact: true,
                    trailing: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => state.removeFromCart(pet.id),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFEE7F87),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(48, 36),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    onTap: () => openPage(context, PetDetailScreen(pet: pet)),
                  ),
              ],
            ),
    );
  }
}

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return PageFrame(
      title: 'Address',
      bottom: PrimaryButton(
        'Next',
        onPressed: () => openPage(context, const PaymentScreen()),
      ),
      child: ListView(
        children: [
          for (int i = 0; i < state.addresses.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: state.selectedAddress == i ? cream : Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  title: Text(
                    state.addresses[i].label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${state.addresses[i].detail}\n${state.addresses[i].city}',
                    style: const TextStyle(fontSize: 11, color: muted),
                  ),
                  trailing: Icon(
                    state.selectedAddress == i
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: state.selectedAddress == i
                        ? orange
                        : const Color(0xFFD6DCDA),
                    size: 22,
                  ),
                  onTap: () {
                    state.selectedAddress = i;
                    state.save();
                  },
                ),
              ),
            ),
          ListTile(
            title: const Text('Add Address', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.add_box_rounded, color: orange),
            onTap: () => openPage(context, const NewAddressScreen()),
          ),
        ],
      ),
    );
  }
}

class NewAddressScreen extends StatefulWidget {
  const NewAddressScreen({super.key});
  @override
  State<NewAddressScreen> createState() => _NewAddressScreenState();
}

class _NewAddressScreenState extends State<NewAddressScreen> {
  final form = GlobalKey<FormState>();
  final label = TextEditingController(),
      city = TextEditingController(),
      detail = TextEditingController();
  @override
  void dispose() {
    label.dispose();
    city.dispose();
    detail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'New Address',
    bottom: PrimaryButton(
      'Save',
      onPressed: () {
        if (!form.currentState!.validate()) return;
        AppScope.of(context).addAddress(
          Address(label.text.trim(), city.text.trim(), detail.text.trim()),
        );
        Navigator.pop(context);
      },
    ),
    child: Form(
      key: form,
      child: ListView(
        children: [
          LabeledField(
            'Address Name',
            controller: label,
            hint: 'Home',
            validator: requiredText,
          ),
          LabeledField(
            'Select Address',
            controller: city,
            hint: 'Jakarta',
            validator: requiredText,
          ),
          LabeledField(
            'Detail Address',
            controller: detail,
            hint: 'Street, building, apartment',
            maxLines: 4,
            validator: requiredText,
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.location_on_outlined, color: orange, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Add a complete address so your companion\ncan find the way home.',
                  style: TextStyle(fontSize: 11, color: muted, height: 1.8),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return PageFrame(
      title: 'Payment',
      bottom: PrimaryButton(
        'Next',
        onPressed: () => openPage(context, const ConfirmationScreen()),
      ),
      child: ListView(
        children: [
          for (int i = 0; i < state.payments.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: state.selectedPayment == i ? cream : Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Text(
                    i == 1 ? '●●' : 'VISA',
                    style: TextStyle(
                      color: i == 1 ? orange : const Color(0xFF28628B),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  title: Text(
                    '${state.payments[i].label} •••• ${state.payments[i].last4}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    state.payments[i].holder,
                    style: const TextStyle(fontSize: 10, color: muted),
                  ),
                  trailing: state.selectedPayment == i
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: orange,
                          size: 22,
                        )
                      : null,
                  onTap: () {
                    state.selectedPayment = i;
                    state.save();
                  },
                ),
              ),
            ),
          ListTile(
            title: const Text('Add Payment', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.add_box_rounded, color: orange),
            onTap: () => openPage(context, const NewPaymentScreen()),
          ),
          const SizedBox(height: 24),
          const Text(
            'Demo checkout only. No money is charged.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class NewPaymentScreen extends StatefulWidget {
  const NewPaymentScreen({super.key});
  @override
  State<NewPaymentScreen> createState() => _NewPaymentScreenState();
}

class _NewPaymentScreenState extends State<NewPaymentScreen> {
  final form = GlobalKey<FormState>();
  final number = TextEditingController(),
      name = TextEditingController(),
      expiry = TextEditingController(),
      cvv = TextEditingController();
  @override
  void dispose() {
    for (final c in [number, name, expiry, cvv]) {
      c.dispose();
    }
    super.dispose();
  }

  String? validateNumber(String? v) {
    final digits = (v ?? '').replaceAll(' ', '');
    if (!RegExp(r'^\d{13,19}$').hasMatch(digits)) return 'Enter 13–19 digits';
    var sum = 0;
    for (int i = 0; i < digits.length; i++) {
      var d = int.parse(digits[digits.length - 1 - i]);
      if (i.isOdd) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
    }
    return sum % 10 == 0 ? null : 'Check the sample card number';
  }

  String? validateExpiry(String? v) {
    final match = RegExp(r'^(0[1-9]|1[0-2])/(\d{2})$').firstMatch(v ?? '');
    if (match == null) return 'Use MM/YY';
    final end = DateTime(2000 + int.parse(match[2]!), int.parse(match[1]!) + 1);
    return end.isAfter(DateTime.now()) ? null : 'Card has expired';
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'New Payment',
    bottom: PrimaryButton(
      'Save',
      onPressed: () {
        if (!form.currentState!.validate()) return;
        final digits = number.text.replaceAll(' ', '');
        AppScope.of(context).addPayment(
          PaymentMethod(
            'Credit Card',
            name.text.trim(),
            digits.substring(digits.length - 4),
          ),
        );
        Navigator.pop(context);
      },
    ),
    child: Form(
      key: form,
      child: ListView(
        children: [
          LabeledField(
            'Card Number',
            controller: number,
            hint: '4242 4242 4242 4242',
            validator: validateNumber,
            keyboardType: TextInputType.number,
          ),
          LabeledField(
            'Name Card',
            controller: name,
            hint: 'Anam',
            validator: requiredText,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LabeledField(
                  'Expiry Date',
                  controller: expiry,
                  hint: 'MM/YY',
                  validator: validateExpiry,
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: LabeledField(
                  'CVV',
                  controller: cvv,
                  hint: '123',
                  obscure: true,
                  keyboardType: TextInputType.number,
                  validator: (v) => RegExp(r'^\d{3,4}$').hasMatch(v ?? '')
                      ? null
                      : 'Use 3–4 digits',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Use sample details only. We save the display name and last four digits, never the full number or CVV.',
            style: TextStyle(color: muted, fontSize: 11, height: 1.9),
          ),
        ],
      ),
    ),
  );
}

class OrderSummary extends StatelessWidget {
  const OrderSummary({
    super.key,
    required this.pets,
    required this.address,
    required this.payment,
  });
  final List<Pet> pets;
  final Address address;
  final String payment;
  @override
  Widget build(BuildContext context) => ListView(
    children: [
      const Text('Address', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              address.label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              '${address.detail}, ${address.city}',
              style: const TextStyle(color: muted, fontSize: 11),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const Text('Payment', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Surface(
        child: Row(
          children: [
            const Text(
              'VISA',
              style: TextStyle(
                color: Color(0xFF28628B),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(payment, style: const TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const Text('Your Order', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 14),
      for (final pet in pets) PetCard(pet, compact: true),
    ],
  );
}

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return PageFrame(
      title: 'Detail Order',
      bottom: Column(
        children: [
          PriceSummary(subtotal: state.subtotal),
          const SizedBox(height: 12),
          PrimaryButton(
            'Place demo order',
            onPressed: state.cartPets.isEmpty
                ? null
                : () {
                    final order = state.placeOrder();
                    if (order != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => SuccessScreen(order: order),
                        ),
                      );
                    }
                  },
          ),
        ],
      ),
      child: OrderSummary(
        pets: state.cartPets,
        address: state.address,
        payment: '${state.payment.label} •••• ${state.payment.last4}',
      ),
    );
  }
}

class PriceSummary extends StatelessWidget {
  const PriceSummary({super.key, required this.subtotal});
  final int subtotal;
  @override
  Widget build(BuildContext context) => Surface(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        for (final (label, amount) in [
          ('Sub Total', subtotal),
          ('Shipping', 10),
          ('Total', subtotal + 10),
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: label == 'Total' ? ink : muted,
                    fontWeight: label == 'Total'
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                Text(
                  '$amount\$',
                  style: TextStyle(
                    fontSize: 12,
                    color: label == 'Total' ? ink : muted,
                    fontWeight: label == 'Total'
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.order});
  final PetOrder order;
  @override
  Widget build(BuildContext context) => PageFrame(
    back: false,
    bottom: PrimaryButton(
      'Back To Dashboard',
      onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 230,
          height: 290,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 12,
                child: Image.asset(
                  'assets/images/success-heart.png',
                  width: 86,
                ),
              ),
              const Positioned(
                top: 19,
                right: 33,
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 15,
                child: Image.asset('assets/images/success-dog.png', width: 185),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Your Shopping Orders have\nBeen Placed',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Thank you for your order. Follow your little\nfriend’s journey from the order status page.',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, fontSize: 12, height: 1.9),
        ),
        const SizedBox(height: 16),
        Tag('Demo order · ${order.total}\$', color: orange),
      ],
    ),
  );
}
