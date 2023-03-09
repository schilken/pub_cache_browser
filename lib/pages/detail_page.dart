import 'package:flutter/material.dart';

import '../models/detail.dart';

class DetailPage extends StatelessWidget {
  DetailPage({
    super.key,
    required this.selectedDetail,
  });
  final Detail selectedDetail;
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('DetailPage'));
  }
}
