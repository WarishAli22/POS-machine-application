import 'package:flutter/material.dart';

class DiscountPage extends StatelessWidget {
  final Function(int) onDiscountSelected;
  final Function() onCustomDiscount;

  const DiscountPage({
    Key? key,
    required this.onDiscountSelected,
    required this.onCustomDiscount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Discount'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Discount',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // FSF Section (from the image)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FSF',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Special Offer',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DiscountButton(
                      percentage: 30,
                      onPressed: () => onDiscountSelected(30),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Regular discount options
            const Text(
              'Standard Discounts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                DiscountButton(
                  percentage: 5,
                  onPressed: () => onDiscountSelected(5),
                ),
                DiscountButton(
                  percentage: 10,
                  onPressed: () => onDiscountSelected(10),
                ),
                DiscountButton(
                  percentage: 15,
                  onPressed: () => onDiscountSelected(15),
                ),
                DiscountButton(
                  percentage: 20,
                  onPressed: () => onDiscountSelected(20),
                ),
                DiscountButton(
                  percentage: 25,
                  onPressed: () => onDiscountSelected(25),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Custom discount button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: onCustomDiscount,
                child: const Text('Custom Discount Percentage'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscountButton extends StatelessWidget {
  final int percentage;
  final VoidCallback onPressed;

  const DiscountButton({
    Key? key,
    required this.percentage,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text('$percentage%'),
    );
  }
}