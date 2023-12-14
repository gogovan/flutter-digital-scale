import 'dart:io';

class DigitalScaleException extends IOException {
  DigitalScaleException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DigitalScaleConnectionException extends DigitalScaleException {
  DigitalScaleConnectionException(super.message);
}
