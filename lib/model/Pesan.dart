import 'package:flutter/material.dart';

@immutable
class Pesan {
  final String title, body, sound;

  const Pesan(
      {@required this.title, @required this.body, @required this.sound});
}
