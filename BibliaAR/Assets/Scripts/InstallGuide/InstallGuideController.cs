using System;
using System.Collections.Generic;
using UnityEngine;

// kguanoluisa, Controlador principal de la guia de instalacion BIAR-15, variables v_pasos y v_indiceActual, 2026-06-24
public class InstallGuideController : MonoBehaviour
{
    [SerializeField] private List<InstallGuideStep> v_pasos = new List<InstallGuideStep>();
    private int v_indiceActual;

    public IReadOnlyList<InstallGuideStep> Pasos => v_pasos;
    public int IndiceActual => v_indiceActual;

    public InstallGuideStep PasoActual =>
        v_pasos != null && v_pasos.Count > 0 && v_indiceActual >= 0 && v_indiceActual < v_pasos.Count
            ? v_pasos[v_indiceActual]
            : null;

    public bool AvanzarPaso()
    {
        if (v_pasos == null || v_indiceActual >= v_pasos.Count - 1)
        {
            return false;
        }

        if (PasoActual != null)
        {
            PasoActual.v_completado = true;
        }

        v_indiceActual++;
        return true;
    }

    public void ReiniciarGuia()
    {
        v_indiceActual = 0;
        if (v_pasos == null)
        {
            return;
        }

        foreach (InstallGuideStep v_paso in v_pasos)
        {
            if (v_paso != null)
            {
                v_paso.v_completado = false;
            }
        }
    }
}
