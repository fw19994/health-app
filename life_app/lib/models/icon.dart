import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/common/category_selector.dart';

class IconModel {
  final int id;
  final String name;
  final String code;
  final String iconType;
  final String iconCode;
  final String colorCode;
  final int categoryId;
  final String category; // '支出' 或 '收入'
  final bool isCustom;

  IconModel({
    required this.id,
    required this.name,
    required this.code,
    required this.iconType,
    required this.iconCode,
    required this.colorCode,
    required this.categoryId,
    required this.category,
    required this.isCustom,
  });

  factory IconModel.fromJson(Map<String, dynamic> json) {
    return IconModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      iconType: json['icon_type'] ?? 'fontawesome',
      iconCode: json['icon_code'] ?? 'fa-tag',
      colorCode: json['color_code'] ?? '#808080',
      categoryId: json['category_id'] ?? 0,
      category: json['category'] ?? '支出',
      isCustom: json['is_custom'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'icon_type': iconType,
      'icon_code': iconCode,
      'color_code': colorCode,
      'category_id': categoryId,
      'category': category,
      'is_custom': isCustom,
    };
  }

  // 将字符串图标代码转换为IconData
  IconData get icon {
    // 解析FontAwesome图标代码
    if (iconType == 'fontawesome') {
      String code = iconCode.replaceAll('fa-', '');
      // 根据图标名称获取对应的IconData
      return _getFontAwesomeIcon(code);
    }
    // 默认返回一个标签图标
    return Icons.label;
  }

  // 将颜色字符串转换为Color对象
  Color get color {
    if (colorCode.isEmpty) return Colors.grey;
    try {
      return Color(int.parse(colorCode.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
  
  // 辅助方法：根据图标名称获取FontAwesomeIcons中的图标
  IconData _getFontAwesomeIcon(String code) {
    switch (code) {
      case 'home': return FontAwesomeIcons.house;
      case 'shopping-cart': return FontAwesomeIcons.cartShopping;
      case 'utensils': return FontAwesomeIcons.utensils;
      case 'car': return FontAwesomeIcons.car;
      case 'graduation-cap': return FontAwesomeIcons.graduationCap;
      case 'medkit': return FontAwesomeIcons.kitMedical;
      case 'plane': return FontAwesomeIcons.plane;
      case 'gift': return FontAwesomeIcons.gift;
      case 'gamepad': return FontAwesomeIcons.gamepad;
      case 'tshirt': return FontAwesomeIcons.shirt;
      case 'baby': return FontAwesomeIcons.baby;
      case 'dog': return FontAwesomeIcons.dog;
      case 'cat': return FontAwesomeIcons.cat;
      case 'book': return FontAwesomeIcons.book;
      case 'music': return FontAwesomeIcons.music;
      case 'briefcase': return FontAwesomeIcons.briefcase;
      case 'dumbbell': return FontAwesomeIcons.dumbbell;
      case 'laptop': return FontAwesomeIcons.laptop;
      case 'mobile': return FontAwesomeIcons.mobileScreen;
      case 'wifi': return FontAwesomeIcons.wifi;
      case 'money-bill': return FontAwesomeIcons.moneyBill;
      case 'money-bill-wave': return FontAwesomeIcons.moneyBillWave;
      case 'piggy-bank': return FontAwesomeIcons.piggyBank;
      case 'chart-line': return FontAwesomeIcons.chartLine;
      case 'dollar-sign': return FontAwesomeIcons.dollarSign;
      case 'credit-card': return FontAwesomeIcons.creditCard;
      case 'store': return FontAwesomeIcons.store;
      case 'coffee': return FontAwesomeIcons.mugHot;
      case 'tags': return FontAwesomeIcons.tags;
      case 'tag': return FontAwesomeIcons.tag;
      case 'hand-holding-usd': return FontAwesomeIcons.handHoldingDollar;
      case 'building': return FontAwesomeIcons.building;
      case 'undo': return FontAwesomeIcons.arrowRotateLeft;
      case 'plus': return FontAwesomeIcons.plus;
      case 'times': return FontAwesomeIcons.xmark;
      case 'arrow-left': return FontAwesomeIcons.arrowLeft;
      case 'pen': return FontAwesomeIcons.pen;
      case 'trash-alt': return FontAwesomeIcons.trash;
      case 'search': return FontAwesomeIcons.magnifyingGlass;
      case 'ellipsis-v': return FontAwesomeIcons.ellipsisVertical;
      case 'calendar': return FontAwesomeIcons.calendar;
      case 'clock': return FontAwesomeIcons.clock;
      case 'save': return FontAwesomeIcons.floppyDisk;
      case 'share-alt': return FontAwesomeIcons.share;
      case 'filter': return FontAwesomeIcons.filter;
      case 'sort-amount-down': return FontAwesomeIcons.arrowDownWideShort;
      case 'sync-alt': return FontAwesomeIcons.arrowsRotate;
      case 'user-clock': return FontAwesomeIcons.userClock;
      case 'hammer': return FontAwesomeIcons.hammer;
      case 'spa': return FontAwesomeIcons.spa;
      case 'bolt': return FontAwesomeIcons.bolt;
      case 'paw': return FontAwesomeIcons.paw;
      case 'shield-alt': return FontAwesomeIcons.shieldHalved;
      case 'coins': return FontAwesomeIcons.coins;
      case 'hand-holding-heart': return FontAwesomeIcons.handHoldingHeart;
      case 'tools': return FontAwesomeIcons.screwdriverWrench;
      case 'newspaper': return FontAwesomeIcons.newspaper;
      case 'file-invoice-dollar': return FontAwesomeIcons.fileInvoiceDollar;
      case 'first-aid': return FontAwesomeIcons.kitMedical;
      case 'laptop-code': return FontAwesomeIcons.laptopCode;
      case 'umbrella-beach': return FontAwesomeIcons.umbrellaBeach;
      case 'couch': return FontAwesomeIcons.couch;
      case 'gem': return FontAwesomeIcons.gem;
      case 'palette': return FontAwesomeIcons.palette;
      case 'star': return FontAwesomeIcons.star;
      case 'ring': return FontAwesomeIcons.ring;
      default: return FontAwesomeIcons.tag; // 默认图标
    }
  }

  // 将IconModel转换为CategoryItem
  CategoryItem toCategoryItem() {
    return CategoryItem(
      icon: icon,
      label: name,
      color: color,
      id: id,
    );
  }
} 