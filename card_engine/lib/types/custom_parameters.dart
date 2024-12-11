

import '../Exceptions/parameter_id_does_not_exist_exception.dart';

class CustomParameters {
  final Map<String, String> _parameters = {};

  void addParameter(String uniqueParamID, String value) {
    _parameters[uniqueParamID] = value;
  }

  String? getParameter(String uniqueParamID) {
    return _parameters[uniqueParamID];
  }

  void removeParameter(String uniqueParamID) {
    _parameters.remove(uniqueParamID);
  }

  void modifyParameter(String uniqueParamID, String newValue) {
    if (_parameters.containsKey(uniqueParamID)) {
      _parameters[uniqueParamID] = newValue;
    } else {
      throw(ParameterIdDoesNotExistException('Parameter with ID $uniqueParamID does not exist.', keyId: uniqueParamID));
    }
  }

  @override
  String toString() {
    return _parameters.toString();
  }
}
