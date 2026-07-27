enum TipoUsuario {
  nino('nino'),
  docente('docente');

  const TipoUsuario(this.value);
  final String value;

  static TipoUsuario fromValue(String value) {
    return TipoUsuario.values.firstWhere(
      (tipo) => tipo.value == value,
      orElse: () => TipoUsuario.nino,
    );
  }
}
