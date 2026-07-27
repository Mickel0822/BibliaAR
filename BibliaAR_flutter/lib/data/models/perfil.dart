import 'package:biblia_ar_flutter/data/models/tipo_usuario.dart';

class Perfil {
  const Perfil({
    this.id,
    required this.nombre,
    required this.tipoUsuario,
    this.avatarPath,
    required this.creadoEn,
    this.updatedAt,
    this.syncStatus = 'local',
  });

  final int? id;
  final String nombre;
  final TipoUsuario tipoUsuario;
  final String? avatarPath;
  final DateTime creadoEn;
  final DateTime? updatedAt;
  final String syncStatus;

  Perfil copyWith({
    int? id,
    String? nombre,
    TipoUsuario? tipoUsuario,
    String? avatarPath,
    DateTime? creadoEn,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return Perfil(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      avatarPath: avatarPath ?? this.avatarPath,
      creadoEn: creadoEn ?? this.creadoEn,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'tipo_usuario': tipoUsuario.value,
      'avatar_path': avatarPath,
      'creado_en': creadoEn.toIso8601String(),
      'updated_at': (updatedAt ?? creadoEn).toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  factory Perfil.fromMap(Map<String, dynamic> map) {
    return Perfil(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      tipoUsuario: TipoUsuario.fromValue(map['tipo_usuario'] as String),
      avatarPath: map['avatar_path'] as String?,
      creadoEn: DateTime.parse(map['creado_en'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      syncStatus: map['sync_status'] as String? ?? 'local',
    );
  }
}
