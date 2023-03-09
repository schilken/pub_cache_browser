import 'package:flutter/material.dart';

import '../models/detail_record.dart';

class DetailPage extends StatelessWidget {
  DetailPage({
    super.key,
    required this.selectedDetail,
  });
  final DetailRecord selectedDetail;
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('DetailPage'));
  }
}
