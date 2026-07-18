//各ページのデータの型
import 'package:flutter/material.dart';

class PageInfo {
  final String title;
  final Widget page;
  final bool showCalendar;

  PageInfo({
    required this.title,
    required this.page,
    this.showCalendar = false,
  });
}
