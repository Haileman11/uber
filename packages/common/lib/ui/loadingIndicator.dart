import 'package:flutter/material.dart';

var loadingIndicator = Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      CircularProgressIndicator.adaptive(),
    ],
  ),
);
