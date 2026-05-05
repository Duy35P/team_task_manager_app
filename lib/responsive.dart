import 'package:flutter/material.dart';

bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 900;
bool isCompactBar(BuildContext context) => MediaQuery.of(context).size.width < 700;