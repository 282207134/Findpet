import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../catalog/catalog_screens.dart';
import 'checkout_screens.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String selected = 'On Process';
  @override
  Widget build(BuildContext context) {
    final orders = AppScope.of(context).orders
        .where((o) => o.status == selected)
        .toList();
    return PageFrame(
      back: false,
      title: 'Status Order',
      trailing: const CartAction(),
      child: Column(
        children: [
          Row(
            children: [
              for (final label in ['On Process', 'Unpaid', 'Finish'])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: TextButton(
                      onPressed: () => setState(() => selected = label),
                      style: TextButton.styleFrom(
                        backgroundColor: selected == label
                            ? Colors.white
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(label, style: const TextStyle(fontSize: 11)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: orders.isEmpty
                ? const EmptyState(
                    'No orders here yet',
                    'Your orders will appear here after checkout.',
                    icon: Icons.receipt_long_outlined,
                  )
                : ListView(
                    children: [
                      for (final order in orders) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Order ${order.id.substring(order.id.length - 6)} · ${order.createdAt.month}/${order.createdAt.day}',
                            style: const TextStyle(color: muted, fontSize: 11),
                          ),
                        ),
                        for (final pet in order.pets)
                          PetCard(
                            pet,
                            compact: true,
                            trailing: const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Tag('On Delivery', color: orange),
                            ),
                            onTap: () => openPage(
                              context,
                              OrderDetailScreen(order: order),
                            ),
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});
  final PetOrder order;
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Order Details',
    bottom: PriceSummary(subtotal: order.subtotal),
    child: OrderSummary(
      pets: order.pets,
      address: order.address,
      payment: order.payment,
    ),
  );
}
