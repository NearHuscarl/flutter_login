class Regex {
  // https://stackoverflow.com/a/32686261/9449426
  Regex._();
  static RegExp regExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static set regexp(RegExp value) {
    regExp = value;
  }
  static RegExp get regexp => regExp;
}
