import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:gritzafood/models/categories_sub_model.dart';
import 'package:gritzafood/models/restaurant_model.dart';
import 'package:uuid/uuid.dart';

class CartState with ChangeNotifier, DiagnosticableTreeMixin {
  var uuid = const Uuid();
  List<CategoriesSubModel> _cartitems = [];
  double _total = 0.0;

  RestaurantModel _restaurantDetails;

  List<CategoriesSubModel> get cartitems => _cartitems;
  double get total => _total;

  RestaurantModel get restaurantDetails => _restaurantDetails;

  void addToList(CategoriesSubModel item) {
    item.cartId = uuid.v1();
    _cartitems.add(item);
    addTotal();
    notifyListeners();
  }

  void removeItem(CategoriesSubModel item) {
    var tempProducts = [..._cartitems];
    int index = -1;
    for (int i = 0; i < tempProducts.length; i++) {
      if (tempProducts[i].cartId == item.cartId) {
        index = i;
        break;
      }
    }
    if (index != -1) {
      tempProducts.removeAt(index);
      _cartitems = [...tempProducts];
    }
    addTotal();
    notifyListeners();
  }

  void setRestuarantDetails(RestaurantModel item) {
    _restaurantDetails = item;
    notifyListeners();
  }

  void incrementQuantity(id) {
    var tempCart = [..._cartitems];
    CategoriesSubModel cartItemToIncrement;
    if (tempCart.isNotEmpty) {
      for (int i = 0; i < tempCart.length; i++) {
        if (tempCart[i].cartId == id) {
          cartItemToIncrement = tempCart[i];
          break;
        }
      }
      if (cartItemToIncrement != null) {
        var index = tempCart.indexOf(cartItemToIncrement);
        var product = tempCart[index];
        product.quantity = product.quantity + 1;
        product.total = (product.quantity * product.price).toDouble();
        _cartitems = [...tempCart];
      }
    }
    addTotal();
    notifyListeners();
  }

  void decrementQuantity(id) {
    var tempCart = [..._cartitems];
    CategoriesSubModel cartItemToIncrement;
    if (tempCart.isNotEmpty) {
      for (int i = 0; i < tempCart.length; i++) {
        if (tempCart[i].cartId == id) {
          cartItemToIncrement = tempCart[i];
          break;
        }
      }
      if (cartItemToIncrement != null) {
        var index = tempCart.indexOf(cartItemToIncrement);
        var product = tempCart[index];
        product.quantity = product.quantity - 1;
        if (product.quantity == 0) {
          cartitems.remove(product);
          _restaurantDetails = null;
        } else {
          product.total = (product.quantity * product.price).toDouble();
          _cartitems = [...tempCart];
        }
      }
    }
    addTotal();
    notifyListeners();
  }

  void addTotal() {
    var totalx = 0.0;
    if (_cartitems.isNotEmpty) {
      for (int i = 0; i < _cartitems.length; i++) {
        totalx = totalx + _cartitems[i].total;
      }
    }
    _total = totalx;
    notifyListeners();
  }

  void removeAll() {
    _cartitems.clear();
    addTotal();
    notifyListeners();
  }
}
