import 'package:acugraph6/data_layer/contracts/model.dart';
import 'package:acugraph6/data_layer/drivers/http_api.dart';

// Models use a generated code inside. Run: "flutter pub run build_runner watch --delete-conflicting-outputs" in project root if you are changing model properties
// https://docs.flutter.dev/development/data-and-backend/json#serializing-json-using-code-generation-libraries

/// A base model for api models outside json:api standard
abstract class ApiModel with HttpApi {}
