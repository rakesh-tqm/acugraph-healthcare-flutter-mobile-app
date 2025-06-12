import 'package:acugraph6/data_layer/exceptions/custom.dart';

class ModelException extends CustomException {
  ModelException(String message, String prefix) : super(message, prefix);
}

class ModelUpdateException extends ModelException {
  ModelUpdateException(String message)
      : super(message, 'Cannot update model: ');
}

class ModelIdentifierException extends ModelException {
  ModelIdentifierException(String message)
      : super(message, 'Model doesnt have a valid identifier: ');
}

class ParamException extends ModelException {
  ParamException(String message) : super(message, 'Invalid parameter: ');
}
