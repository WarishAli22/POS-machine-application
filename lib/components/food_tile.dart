import 'package:flutter/material.dart';
import 'package:my_pos/models/food_model.dart';
import 'package:my_pos/components/expanding_counter.dart';
import 'package:my_pos/providers/ticket_provider.dart';
import 'package:provider/provider.dart';
import 'package:my_pos/components/buttons.dart';
import 'package:my_pos/providers/ticket_provider.dart';
import 'dart:math' as math;

class FoodTile extends StatefulWidget {
  final Food item;
  const FoodTile({super.key, required this.item});

  @override
  State<FoodTile> createState() => _FoodTileState();
}

class _FoodTileState extends State<FoodTile> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flyAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isFlying = false;
  Offset _flightPath = Offset.zero;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800), // Reduced from 1200ms
      vsync: this,
    );

    _flyAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad, // Changed for faster acceleration
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutQuad), // Simplified and optimized
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn), // Delayed fade out
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleAddFood(BuildContext context) {
    if (_isFlying) return;

    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    ticketProvider.addFoodItem(widget.item);

    // Calculate flight path to ticket bar (assuming it's at top right)
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final offset = renderBox.localToGlobal(Offset.zero);

      // Target position (top right corner of screen)
      final targetPosition = Offset(MediaQuery.of(context).size.width - 50, 50);

      // Calculate flight path with a slight arc
      _flightPath = Offset(
        targetPosition.dx - offset.dx - size.width / 2,
        targetPosition.dy - offset.dy - size.height / 2,
      );
    }

    _isFlying = true;
    _animationController.forward().then((_) {
      setState(() {
        _isFlying = false;
      });
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        final currentQty = ticketProvider.getItemQuantity(widget.item.id);

        return GestureDetector(
          onTap: () => _handleAddFood(context),
          child: Stack(
            children: [
              // Original Food Tile
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final double arcHeight = 100 * math.sin(_flyAnimation.value * math.pi);

                  return Transform.translate(
                    offset: _isFlying
                        ? Offset(
                        _flightPath.dx * _flyAnimation.value,
                        _flightPath.dy * _flyAnimation.value - arcHeight
                    )
                        : Offset.zero,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(widget.item.imageUrl, fit: BoxFit.cover),

                      // Flying food trail effect - simplified for performance
                      if (_isFlying)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: FlightTrailPainter(
                              progress: _flyAnimation.value,
                              color: Colors.orange.withOpacity(0.6),
                            ),
                          ),
                        ),

                      // Quantity badge
                      if (currentQty > 0 && !_isFlying)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '$currentQty',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                      // Bottom info bar
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.55),
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    shadows: [Shadow(blurRadius: 2)],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bounce effect on tap (even when not flying)
              if (!_isFlying)
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150), // Slightly faster
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.transparent,
                    ),
                    child: const Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.white30,
                        highlightColor: Colors.white10,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class FlightTrailPainter extends CustomPainter {
  final double progress;
  final Color color;

  FlightTrailPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw dashed trail behind the flying food - optimized with fewer circles
    final center = Offset(size.width / 2, size.height / 2);
    final trailLength = progress * 80; // Slightly shorter trail

    for (var i = 0; i < trailLength; i += 6) { // Increased step for fewer circles
      final alpha = 1.0 - (i / trailLength);
      paint.color = color.withOpacity(alpha * 0.5);

      canvas.drawCircle(
        Offset(center.dx - i * 0.5, center.dy + i * 0.3),
        2.0 * alpha,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FlightTrailPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}



// class FoodTile extends StatefulWidget {
//   final Food item;
//   const FoodTile({super.key, required this.item});
//
//   @override
//   State<FoodTile> createState() => _FoodTileState();
// }
//
// class _FoodTileState extends State<FoodTile> {
//   int _currentQuantity = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize with the current quantity from provider
//     // final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
//     // _currentQuantity = ticketProvider.getItemQuantity(widget.item.id);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: GestureDetector(
//         //add to ticket from this onTap function
//         onTap: () {
//           showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return Consumer<TicketProvider>(
//                     builder: (context, ticketProvider, child) {
//                       final currentQty = ticketProvider.getItemQuantity(widget.item.id);
//                       return AlertDialog(
//                           title: const Text("Add food"),
//                           content: Row(
//                             children: [
//                               DecreaseButton(onTap: () {
//                                 ticketProvider.removeFoodItem(widget.item.id);
//                               }),
//                               const SizedBox(width: 8),
//                               Text('$currentQty'),
//                               const SizedBox(width: 8),
//                               IncreaseButton(onTap: () {
//                                 ticketProvider.addFoodItem(widget.item);
//                               })
//                             ],
//                           )
//                       );
//                     }
//                 );
//               }
//           );
//         },
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             Image.asset(widget.item.imageUrl, fit: BoxFit.cover),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.black.withOpacity(0.0),
//                       Colors.black.withOpacity(0.55),
//                     ],
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         widget.item.title,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w700,
//                           shadows: [Shadow(blurRadius: 2)],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

