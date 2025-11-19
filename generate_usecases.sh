#!/bin/bash

# Define la ruta base para los casos de uso
BASE_DIR="lib/domain/settings/usecases"

# Define la plantilla para los casos de uso
USE_CASE_TEMPLATE='''import 'package:get/get.dart';
import '../repository/settings_repository.dart';

class %CLASS_NAME% {
  final SettingsRepository _settingsRepository = Get.find<SettingsRepository>();

  %RETURN_TYPE% call(%PARAMS%) {
    return _settingsRepository.%METHOD_NAME%(%ARGS%);
  }
}
'''

# Lee la interfaz del repositorio y genera los casos de uso
while IFS= read -r line; do
  # Ignora las líneas vacías y las importaciones
  if [[ -z "$line" || "$line" == "import "* || "$line" == "abstract class"* || "$line" == "}" ]]; then
    continue
  fi

  # Extrae el tipo de retorno, el nombre del método y los parámetros
  RETURN_TYPE=$(echo "$line" | awk -F' ' '{print $1}')
  METHOD_NAME=$(echo "$line" | awk -F' ' '{print $2}' | cut -d'(' -f1)
  PARAMS=$(echo "$line" | awk -F'[()]' '{print $2}')
  ARGS=$(echo "$PARAMS" | sed 's/[^,]* //g')

  # Convierte el nombre del método a PascalCase para el nombre de la clase
  CLASS_NAME=$(echo "$METHOD_NAME" | sed -r 's/(^|_)([a-z])/\U\2/g')

  # Reemplaza los placeholders en la plantilla
  USE_CASE_CODE=$(echo "$USE_CASE_TEMPLATE" | \
    sed "s/%CLASS_NAME%/${CLASS_NAME}UseCase/g" | \
    sed "s/%RETURN_TYPE%/$RETURN_TYPE/g" | \
    sed "s/%PARAMS%/$PARAMS/g" | \
    sed "s/%METHOD_NAME%/$METHOD_NAME/g" | \
    sed "s/%ARGS%/$ARGS/g")

  # Escribe el caso de uso en un archivo
  echo "$USE_CASE_CODE" > "$BASE_DIR/$(echo "$METHOD_NAME" | sed -r 's/([A-Z])/_\L\1/g' | sed 's/^_//')_usecase.dart"
done < "lib/domain/settings/repository/settings_repository.dart"
