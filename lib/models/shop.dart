import 'package:shop_app/models/product.dart';

class UserInfo {
  String username;
  String userid;
  String userpswd;
  String useremailaccount;
  String userphn;

  UserInfo({
    required this.username,
    required this.userid,
    required this.userpswd,
    required this.useremailaccount,
    required this.userphn,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'userid': userid,
      'userpswd': userpswd,
      'useremailaccount': useremailaccount,
      'userphn': userphn,
    };
  }

  factory UserInfo.fromMap(Map<String, dynamic> map) {
    return UserInfo(
      username: map['username'],
      userid: map['userid'],
      userpswd: map['userpswd'],
      useremailaccount: map['useremailaccount'],
      userphn: map['userphn'],
    );
  }
}

class Shop {
  final String shopid;
  final String shopename;
  final String shopaddress;
  final String shopcontactno;
  final String openingtime;
  final String closingtime;
  final String googleMapLink;
  final bool isOnline;
  final bool deliveryAvailable;
  final String? shopImageUrl;
  final List<String> shopeimages;
  final List<Product> products;
  final String shopowner_name;
  final String shopowner_mailid;
  final String shopowner_mobileno;

  Shop({
    required this.shopid,
    required this.shopename,
    required this.shopaddress,
    required this.shopcontactno,
    required this.openingtime,
    required this.closingtime,
    required this.googleMapLink,
    required this.isOnline,
    required this.deliveryAvailable,
    this.shopImageUrl,
    required this.shopeimages,
    required this.products,
    required this.shopowner_name,
    required this.shopowner_mailid,
    required this.shopowner_mobileno,
  });

  Map<String, dynamic> toMap() {
    return {
      'shopid': shopid,
      'shopename': shopename,
      'shopaddress': shopaddress,
      'shopcontactno': shopcontactno,
      'openingtime': openingtime,
      'closingtime': closingtime,
      'googleMapLink': googleMapLink,
      'isOnline': isOnline,
      'deliveryAvailable': deliveryAvailable,
      'shopImageUrl': shopImageUrl,
      'shopeimages': shopeimages,
      'products': products.map((product) => product.toMap()).toList(),
      'shopowner_name': shopowner_name,
      'shopowner_mailid': shopowner_mailid,
      'shopowner_mobileno': shopowner_mobileno,
    };
  }

  static Shop fromMap(Map<String, dynamic> map) {
    return Shop(
      shopid: map['shopid'],
      shopename: map['shopename'],
      shopaddress: map['shopaddress'],
      shopcontactno: map['shopcontactno'],
      openingtime: map['openingtime'],
      closingtime: map['closingtime'],
      googleMapLink: map['googleMapLink'],
      isOnline: map['isOnline'],
      deliveryAvailable: map['deliveryAvailable'],
      shopImageUrl: map['shopImageUrl'],
      shopeimages: List<String>.from(map['shopeimages']),
      products: List<Product>.from(
          map['products'].map((product) => Product.fromMap(product))),
      shopowner_name: map['shopowner_name'],
      shopowner_mailid: map['shopowner_mailid'],
      shopowner_mobileno: map['shopowner_mobileno'],
    );
  }
}
