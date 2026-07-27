enum EstadoProgreso {
  noIniciada('no_iniciada'),
  enCurso('en_curso'),
  completada('completada');

  const EstadoProgreso(this.value);
  final String value;

  static EstadoProgreso fromValue(String value) {
    return EstadoProgreso.values.firstWhere(
      (estado) => estado.value == value,
      orElse: () => EstadoProgreso.noIniciada,
    );
  }
}
