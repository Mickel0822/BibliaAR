enum TipoActividad {
  completar('completar'),
  ordenar('ordenar'),
  identificar('identificar'),
  checklist('checklist');

  const TipoActividad(this.value);
  final String value;

  static TipoActividad fromValue(String value) {
    return TipoActividad.values.firstWhere(
      (tipo) => tipo.value == value,
      orElse: () => TipoActividad.completar,
    );
  }
}
