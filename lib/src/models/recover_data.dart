import 'package:quiver/core.dart';

class RecoverData {
  final Map<String, String>? customRecoverData;

  RecoverData({this.customRecoverData});

  @override
  String toString() {
    return '$runtimeType($customRecoverData)';
  }

  @override
  bool operator ==(Object other) {
    if (other is RecoverData) {
      return customRecoverData == other.customRecoverData;
    }
    return false;
  }

  @override
  int get hashCode => hash2('hello', customRecoverData);
}
