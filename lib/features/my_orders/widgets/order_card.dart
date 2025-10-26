import 'package:flutter/material.dart';
import 'package:jconnect/features/my_orders/model/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (order.status) {
      case 'Active':
        statusColor = Colors.blue;
        break;
      case 'Pending Confirmation':
        statusColor = Colors.amber;
        break;
      case 'Completed':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    // ✅ Different background for type
    final bgColor = order.type == 'Given'
        ? const Color(0xFF242629)
        : const Color(0xFF1E1E20);
    final borderColor = order.type == 'Given'
        ? Colors.blueAccent.withOpacity(0.3)
        : Colors.greenAccent.withOpacity(0.3);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Image.asset(order.icon, width: 28, height: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.platform,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  order.title,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      order.status,
                      style: TextStyle(color: statusColor, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '\$${order.price.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
