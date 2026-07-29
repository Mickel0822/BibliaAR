import 'dart:convert';

import 'package:biblia_ar_flutter/data/database/database_access.dart';
import 'package:biblia_ar_flutter/data/database/migrations/migration_v1.dart';
import 'package:biblia_ar_flutter/data/database/migrations/migration_v2.dart';
import 'package:biblia_ar_flutter/data/database/migrations/migration_v3.dart';
import 'package:biblia_ar_flutter/data/database/migrations/migration_v4.dart';
import 'package:biblia_ar_flutter/data/models/leccion_categoria.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

// kguanoluisa, Base de datos SQLite con migracion v4 de certificados CONADIS simulados, variable v_database, 2026-07-29
class AppDatabase implements DatabaseAccess {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static Database? _database;

  static const String databaseName = 'biar.db';

  @override
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, databaseName);

    return openDatabase(
      path,
      version: MigrationV4.version,
      onCreate: (db, version) async {
        for (final statement in MigrationV1.statements) {
          await db.execute(statement);
        }
        for (final statement in MigrationV4.statements) {
          await db.execute(statement);
        }
        await _seedInitialData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < MigrationV2.version) {
          for (final statement in MigrationV2.statements) {
            await db.execute(statement);
          }
        }
        if (oldVersion < MigrationV3.version) {
          for (final statement in MigrationV3.statements) {
            await db.execute(statement);
          }
        }
        if (oldVersion < MigrationV4.version) {
          for (final statement in MigrationV4.statements) {
            await db.execute(statement);
          }
          await _seedConadisData(db);
        }
      },
    );
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now().toIso8601String();
    const leccionPath = 'assets/lessons/buen_samaritano/fragments.json';

    await db.insert('lecciones', {
      'titulo': 'El Buen Samaritano',
      'referencia_biblica': 'Lucas 10:25-37',
      'contenido_multimedia_path': leccionPath,
      'categoria': LeccionCategoria.biblico,
      'orden': 1,
      'updated_at': now,
      'sync_status': 'local',
    });

    final actividadesSeed = [
      {
        'leccion_id': 1,
        'tipo': 'completar',
        'payload_json': jsonEncode({
          'titulo': 'Completa la historia',
          'pregunta': '¿Quién ayudó al hombre herido?',
          'opciones': ['Un sacerdote', 'Un levita', 'Un samaritano', 'Un soldado'],
          'respuestaCorrecta': 2,
        }),
        'updated_at': now,
        'sync_status': 'local',
      },
      {
        'leccion_id': 1,
        'tipo': 'ordenar',
        'payload_json': jsonEncode({
          'titulo': 'Ordena la historia',
          'instruccion': 'Arrastra los eventos en el orden correcto',
          'elementos': [
            'El hombre es herido en el camino',
            'Pasa un sacerdote sin ayudar',
            'Un samaritano lo auxilia',
            'Lo lleva a un hospedaje',
          ],
          'ordenCorrecto': [0, 1, 2, 3],
        }),
        'updated_at': now,
        'sync_status': 'local',
      },
      {
        'leccion_id': 1,
        'tipo': 'identificar',
        'payload_json': jsonEncode({
          'titulo': 'Identifica al personaje',
          'instruccion': 'Selecciona quién mostró compasión',
          'opciones': [
            {'id': 'sacerdote', 'nombre': 'Sacerdote'},
            {'id': 'samaritano', 'nombre': 'Samaritano'},
            {'id': 'levita', 'nombre': 'Levita'},
          ],
          'respuestaCorrecta': 'samaritano',
        }),
        'updated_at': now,
        'sync_status': 'local',
      },
    ];

    for (final actividad in actividadesSeed) {
      await db.insert('actividades', actividad);
    }

    await _seedConadisData(db);
  }

  // kguanoluisa, Seed de certificados CONADIS simulados con casos variados de discapacidad, sin nuevas variables, 2026-07-29
  Future<void> _seedConadisData(Database db) async {
    final certificadosSeed = [
      {
        'numero_certificado': 'CON-2024-000001',
        'tipo_discapacidad': 'auditiva',
        'porcentaje': 85,
        'nombre_titular': 'María López',
      },
      {
        'numero_certificado': 'CON-2024-000002',
        'tipo_discapacidad': 'auditiva',
        'porcentaje': 45,
        'nombre_titular': 'Carlos Mendoza',
      },
      {
        'numero_certificado': 'CON-2023-000015',
        'tipo_discapacidad': 'visual',
        'porcentaje': 60,
        'nombre_titular': 'Ana Torres',
      },
      {
        'numero_certificado': 'CON-2022-000088',
        'tipo_discapacidad': 'motriz',
        'porcentaje': 70,
        'nombre_titular': 'Pedro Ramírez',
      },
      {
        'numero_certificado': 'CON-2021-000050',
        'tipo_discapacidad': 'intelectual',
        'porcentaje': 55,
        'nombre_titular': 'Lucía Vega',
      },
      {
        'numero_certificado': 'CON-2024-000010',
        'tipo_discapacidad': 'multiple',
        'porcentaje': 90,
        'nombre_titular': 'Diego Salazar',
      },
      {
        'numero_certificado': 'CON-2024-000003',
        'tipo_discapacidad': 'auditiva',
        'porcentaje': 30,
        'nombre_titular': 'Sofía Herrera',
      },
      {
        'numero_certificado': 'CON-2023-000022',
        'tipo_discapacidad': 'visual',
        'porcentaje': 40,
        'nombre_titular': 'Jorge Pérez',
      },
      {
        'numero_certificado': 'CON-2022-000099',
        'tipo_discapacidad': 'motriz',
        'porcentaje': 50,
        'nombre_titular': 'Elena Castro',
      },
      {
        'numero_certificado': 'CON-2024-000011',
        'tipo_discapacidad': 'multiple',
        'porcentaje': 75,
        'nombre_titular': 'Mateo Ruiz',
      },
      {
        'numero_certificado': 'CON-2023-000030',
        'tipo_discapacidad': 'auditiva',
        'porcentaje': 65,
        'nombre_titular': 'Valentina Morales',
      },
      {
        'numero_certificado': 'CON-2021-000077',
        'tipo_discapacidad': 'intelectual',
        'porcentaje': 35,
        'nombre_titular': 'Andrés Guzmán',
      },
    ];

    for (final certificado in certificadosSeed) {
      await db.insert(
        'certificados_conadis',
        certificado,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
