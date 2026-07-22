import 'package:biblia_ar_flutter/core/constants/app_constants.dart';
import 'package:biblia_ar_flutter/core/session/biar50_closure_report.dart';
import 'package:biblia_ar_flutter/core/session/usage_alert_verifier.dart';
import 'package:biblia_ar_flutter/core/session/usage_timer_service.dart';

/// Servicio de cierre del ticket BIAR-50 y paso a columna Listo en Jira.
///
/// Consolida la verificación QA con los criterios de aceptación
/// del producto para determinar si el ticket puede cerrarse.
class Biar50ClosureService {
  Biar50ClosureService(this._timer);

  final UsageTimerService _timer;

  /// Genera el informe de cierre evaluando verificación y criterios.
  Biar50ClosureReport generarInformeCierre() {
    final verificacion = UsageAlertVerifier(_timer).run();
    final criterios = <Biar50AcceptanceCriterion>[
      Biar50AcceptanceCriterion(
        id: 'CA-01',
        descripcion: 'Alerta visible tras ${AppConstants.usageAlertMinutes} minutos de uso',
        cumplido: verificacion.items.any((i) => i.id == 'simulacion_umbral' && i.aprobado),
        evidencia: 'Checklist QA automático',
      ),
      Biar50AcceptanceCriterion(
        id: 'CA-02',
        descripcion: 'Contador se reinicia al elegir Continuar',
        cumplido: verificacion.items.any((i) => i.id == 'reset' && i.aprobado),
        evidencia: 'UsageTimerService.reset()',
      ),
      Biar50AcceptanceCriterion(
        id: 'CA-03',
        descripcion: 'No se repite la alerta en el mismo ciclo',
        cumplido: verificacion.items.any((i) => i.id == 'marca_alerta' && i.aprobado),
        evidencia: 'UsageAlertListener',
      ),
      Biar50AcceptanceCriterion(
        id: 'CA-04',
        descripcion: 'Verificación QA completa sin fallos',
        cumplido: verificacion.todoAprobado,
        evidencia: '${verificacion.aprobados}/${verificacion.total} checks',
      ),
    ];

    final reporte = Biar50ClosureReport(
      ticketId: 'BIAR-50',
      estado: Biar50JiraStatus.enProgreso,
      criterios: criterios,
      fechaCierre: DateTime.now(),
    );

    return Biar50ClosureReport(
      ticketId: reporte.ticketId,
      estado: reporte.puedePasarAListo
          ? Biar50JiraStatus.listo
          : Biar50JiraStatus.enProgreso,
      criterios: reporte.criterios,
      fechaCierre: reporte.fechaCierre,
      observaciones: reporte.puedePasarAListo
          ? 'Ticket listo para mover a columna Listo en Jira'
          : 'Pendiente completar criterios de aceptación',
    );
  }
}
