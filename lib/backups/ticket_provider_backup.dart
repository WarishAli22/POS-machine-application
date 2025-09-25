import '../models/food_model.dart';
import 'package:flutter/foundation.dart';
import '../models/ticket_model.dart';
import 'package:my_pos/models/discount_model.dart';

class TicketProvider with ChangeNotifier {
  List<Ticket> _tickets = [];
  Ticket? _activeTicket;
  String _selectedPaymentMethod = 'CASH';

  List<Ticket> get tickets => _tickets;
  Ticket? get activeTicket => _activeTicket;
  double get currentTotalAmount => _activeTicket?.totalAmount ?? 0.0;
  String get selectedPaymentMethod => _selectedPaymentMethod;

  // Initialize with a default ticket
  TicketProvider() {
    _createNewTicket();
  }

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;

    // Update active ticket if exists
    if (_activeTicket != null) {
      _activeTicket = _activeTicket!.copyWith(paymentMethod: method);

      // Also update th e ticket in the tickets list
      final index = _tickets.indexWhere((t) => t.id == _activeTicket!.id);
      if (index != -1) {
        _tickets[index] = _activeTicket!;
      }
    }

    notifyListeners();
  }

  void updateTicketPaymentMethod(String method) {
    if (_activeTicket != null) {
      _activeTicket = _activeTicket!.copyWith(paymentMethod: method);
      _selectedPaymentMethod = method;
      notifyListeners();
    }
  }

  void setTicket(Ticket ticket) {
    _activeTicket = ticket;
    _selectedPaymentMethod = ticket.paymentMethod;
    notifyListeners();
  }


  //Active Ticket Index
  int getActiveTicketIndex() {
    if (_activeTicket == null) return -1;

    return _tickets.indexWhere((ticket) => ticket.id == _activeTicket!.id)+1;
  }

  // Select a ticket
  void selectTicket(String ticketId) {
    _activeTicket = _tickets.firstWhere(
          (ticket) => ticket.id == ticketId,
      orElse: () => _tickets.first,
    );
    notifyListeners();
  }

  // Create a new ticket
  void createNewTicket([String? name]) {
    final newTicket = _createNewTicket();
    _tickets.add(newTicket);
    _activeTicket = newTicket;
    notifyListeners();
  }

  Ticket _createNewTicket() {
    print("new ticket creating...");
    final newTicket = Ticket(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Ticket ${_tickets.length + 1}',
      items: [],
      paymentMethod: '',
    );
    // _tickets.add(newTicket);
    // notifyListeners();
    return newTicket;
  }

  void addFoodItem(Food food) {
    if (_activeTicket == null) {
      throw Exception("No active ticket. Start a new ticket first.");
    }

    final ticketIndex = _tickets.indexWhere((t) => t.id == _activeTicket!.id);
    if (ticketIndex == -1) return;

    // Check if the food item already exists in the ticket
    final existingItemIndex = _activeTicket!.items.indexWhere((item) => item.id == food.id);

    List<Food> updatedItems;

    if (existingItemIndex != -1) {
      // Update quantity if item already exists
      final existingItem = _activeTicket!.items[existingItemIndex];
      final updatedItem = existingItem.copyWith(quantity: existingItem.quantity + food.quantity);

      updatedItems = List<Food>.from(_activeTicket!.items);
      updatedItems[existingItemIndex] = updatedItem;
    } else {
      // Add new item
      updatedItems = List<Food>.from(_activeTicket!.items)..add(food);
    }

    // Update both active ticket and the ticket in the list
    final updatedTicket = _activeTicket!.copyWith(items: updatedItems);
    _tickets[ticketIndex] = updatedTicket;
    _activeTicket = updatedTicket;

    notifyListeners();
  }

  void removeFoodItem(String foodId) {
    if (_activeTicket == null) return;

    final ticketIndex = _tickets.indexWhere((t) => t.id == _activeTicket!.id);
    if (ticketIndex == -1) return;

    final updatedItems = _activeTicket!.items.where((item) => item.id != foodId).toList();

    // Update both active ticket and the ticket in the list
    final updatedTicket = _activeTicket!.copyWith(items: updatedItems);
    _tickets[ticketIndex] = updatedTicket;
    _activeTicket = updatedTicket;

    notifyListeners();
  }

  //Edit Ticket
  void updateTicketItems(String ticketId, List<Food> items) {
    final ticketIndex = _tickets.indexWhere((t) => t.id == ticketId);
    if (ticketIndex != -1) {
      final updatedTicket = _tickets[ticketIndex].copyWith(items: items);
      _tickets[ticketIndex] = updatedTicket;

      // If this is the active ticket, update it too
      if (_activeTicket?.id == ticketId) {
        _activeTicket = updatedTicket;
      }

      notifyListeners();
    }
  }


  int getItemQuantity(String itemId) {
    if (_activeTicket != null) {
      final item = _activeTicket!.items.firstWhere(
            (item) => item.id == itemId,
        orElse: () => Food(
          id: '',
          title: '',
          price: 0,
          imageUrl: '',
          quantity: 0,
        ),
      );
      return item.quantity;
    }
    return 0;
  }
  void removeItemFromActiveTicket(String itemId) {
    if (_activeTicket != null) {
      final index = _tickets.indexWhere((t) => t.id == _activeTicket!.id);
      if (index != -1) {
        final updatedItems = _activeTicket!.items.where((item) => item.id != itemId).toList();

        _tickets[index] = _activeTicket!.copyWith(items: updatedItems);
        _activeTicket = _tickets[index];
        notifyListeners();
      }
    }
  }

  // Remove item from active ticket
  void updateItemQuantity(String itemId, int quantity) {
    if (_activeTicket != null) {
      final index = _tickets.indexWhere((t) => t.id == _activeTicket!.id);
      if (index != -1) {
        if (quantity <= 0) {
          // Remove item if quantity is 0 or less
          removeItemFromActiveTicket(itemId);
        } else {
          // Update quantity of existing item
          final itemIndex = _activeTicket!.items.indexWhere((item) => item.id == itemId);
          if (itemIndex != -1) {
            final updatedItems = List<Food>.from(_activeTicket!.items);
            updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
              quantity: quantity,
            );

            _tickets[index] = _activeTicket!.copyWith(items: updatedItems);
            _activeTicket = _tickets[index];
            notifyListeners();
          }
        }
      }
    }
  }

  List<Ticket> get completedTickets {
    return _tickets.where((ticket) =>
    ticket.items.isNotEmpty &&
        ticket.paymentMethod.isNotEmpty &&
        ticket.paymentMethod != '').toList();
  }

  // Delete a ticket
  void deleteTicket(String ticketId) {
    _tickets.removeWhere((ticket) => ticket.id == ticketId);

    // If we deleted the active ticket, select the first one or create new
    if (_activeTicket?.id == ticketId) {
      _activeTicket = _tickets.isNotEmpty ? _tickets.first : null;

      // If no tickets left, create a new one
      if (_activeTicket == null) {
        createNewTicket();
      }
    }
    notifyListeners();
  }

  // DISCOUNT METHODS

  // Apply a percentage discount to the active ticket
  void applyPercentageDiscount(int percentage) {
    if (_activeTicket == null) return;

    final ticketIndex = _tickets.indexWhere((t) => t.id == _activeTicket!.id);
    if (ticketIndex == -1) return;

    // Calculate subtotal (sum of all items)
    final subtotal = _activeTicket!.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

    // Calculate discount amount
    final discountAmount = (subtotal * percentage / 100);

    // Create new discount
    final discount = Discount(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      percentage: percentage,
      amount: discountAmount,
    );

    // Add discount to the ticket
    final updatedDiscounts = List<Discount>.from(_activeTicket!.discounts)..add(discount);

    // Update both active ticket and the ticket in the list
    final updatedTicket = _activeTicket!.copyWith(discounts: updatedDiscounts);
    _tickets[ticketIndex] = updatedTicket;
    _activeTicket = updatedTicket;

    notifyListeners();
  }

  // Remove a discount from the active ticket
  void removeDiscount(String discountId) {
    if (_activeTicket == null) return;

    final ticketIndex = _tickets.indexWhere((t) => t.id == _activeTicket!.id);
    if (ticketIndex == -1) return;

    // Remove the discount
    final updatedDiscounts = _activeTicket!.discounts.where((d) => d.id != discountId).toList();

    // Update both active ticket and the ticket in the list
    final updatedTicket = _activeTicket!.copyWith(discounts: updatedDiscounts);
    _tickets[ticketIndex] = updatedTicket;
    _activeTicket = updatedTicket;

    notifyListeners();
  }

  // Clear all discounts from the active ticket
  void clearAllDiscounts() {
    if (_activeTicket == null) return;

    final ticketIndex = _tickets.indexWhere((t) => t.id == _activeTicket!.id);
    if (ticketIndex == -1) return;

    // Clear all discounts
    final updatedTicket = _activeTicket!.copyWith(discounts: []);
    _tickets[ticketIndex] = updatedTicket;
    _activeTicket = updatedTicket;

    notifyListeners();
  }

  // Get total discount amount for the active ticket
  double getDiscountTotal() {
    if (_activeTicket == null) return 0.0;

    return _activeTicket!.discounts.fold(0.0, (sum, discount) => sum + discount.amount);
  }

  // Get subtotal (before discounts) for the active ticket
  double getSubtotal() {
    if (_activeTicket == null) return 0.0;

    return _activeTicket!.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  //-----------------------------//
// Rename the active ticket
  void renameActiveTicket(String newName) {
    if (_activeTicket == null) return;
    final idx = _tickets.indexWhere((t) => t.id == _activeTicket!.id);
    if (idx == -1) return;

    final updated = _activeTicket!.copyWith(name: newName);
    _tickets[idx] = updated;
    _activeTicket = updated;
    notifyListeners();
  }

// Replace payment method for active ticket (ensures list copy stays consistent)
  void setActiveTicketPaymentMethod(String method) {
    if (_activeTicket == null) return;
    final idx = _tickets.indexWhere((t) => t.id == _activeTicket!.id);
    if (idx == -1) return;

    final updated = _activeTicket!.copyWith(paymentMethod: method);
    _tickets[idx] = updated;
    _activeTicket = updated;
    _selectedPaymentMethod = method;
    notifyListeners();
  }
}
