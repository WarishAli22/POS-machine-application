import '../models/food_model.dart';
import 'package:flutter/foundation.dart';
import '../models/ticket_model.dart';

class FoodProvider extends ChangeNotifier{

  /*
  * Difference between `List <Food> _foodItems = []` and
  *                          `List  _foodItems = <Food> []`
  * _fooditems is set as a <Food> type List if we use the first line
  * It is not set as a <Food> type List if we use the second line. It is dynamic
  * even though it has been assigned a <Food> type list
  * */

  List <Food> _foodItems = [
    Food(id: '1', title:'বীফ চাপ', imageUrl: 'lib/images/beefchap.jpg', price:20),
    Food(id: '2', title:'চিকেন লিভার', imageUrl: 'lib/images/chickenliver.png', price:30),
    Food(id: '3', title:'চিল্লি কারি', imageUrl: 'lib/images/chillicurry.png', price:40),
    Food(id: '4', title:'চিকেন মশলা', imageUrl: 'lib/images/cmasala.jpg', price:50),
    Food(id: '5', title:'ডিম্ চপ', imageUrl: 'lib/images/dimchop.png', price:60),
    Food(id: '6', title:'অমলেট', imageUrl: 'lib/images/omlet.jpg', price:70),
    Food(id: '7', title:'অন্থন', imageUrl: 'lib/images/onthon.png', price:80),
    Food(id: '8', title:'সূপ', imageUrl: 'lib/images/soup.jpg', price:90),
    Food(id: '9', title:'চিকেন রোল', imageUrl: 'lib/images/croll.png', price:100),
    Food(id: '10', title:'কফি', imageUrl: 'lib/images/coffee.jpg', price:110),
  ];

  List<Food> get getFoodItems => _foodItems;

  FoodProvider(){

  }
}