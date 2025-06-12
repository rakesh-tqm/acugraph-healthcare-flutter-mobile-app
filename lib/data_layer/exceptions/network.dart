import 'package:acugraph6/data_layer/exceptions/custom.dart';

class NetworkException extends CustomException {
  NetworkException(String message, String prefix) : super(message, prefix);
}

class FetchDataException extends NetworkException {
  FetchDataException(String message)
      : super(message, "Error During Communication: ");
}

class BadRequestException extends NetworkException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends NetworkException {
  UnauthorisedException([message]) : super(message, "Unauthorized: ");
}

class InvalidInputException extends NetworkException {
  InvalidInputException(String message) : super(message, "Invalid Input: ");
}

class InternalServerException extends NetworkException {
  InternalServerException(String message)
      : super(message, "Internal Server Error: ");
}
