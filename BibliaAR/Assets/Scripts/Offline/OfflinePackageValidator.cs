using System.Collections.Generic;
using System.IO;

// kguanoluisa, Validaciones del empaquetado offline, variables v_errores y v_advertencias, 2026-07-08
public class OfflinePackageValidator
{
    private readonly List<string> v_errores = new List<string>();
    private readonly List<string> v_advertencias = new List<string>();

    public IReadOnlyList<string> Errores => v_errores;
    public IReadOnlyList<string> Advertencias => v_advertencias;

    public bool ValidarManifiesto(OfflinePackageManifest v_manifiesto)
    {
        v_errores.Clear();
        v_advertencias.Clear();

        if (v_manifiesto == null)
        {
            v_errores.Add("El manifiesto offline es nulo.");
            return false;
        }

        if (string.IsNullOrWhiteSpace(v_manifiesto.v_version))
        {
            v_errores.Add("La version del paquete offline es obligatoria.");
        }

        if (v_manifiesto.v_recursos == null || v_manifiesto.v_recursos.Count == 0)
        {
            v_advertencias.Add("El paquete offline no contiene recursos.");
        }

        return v_errores.Count == 0;
    }

    public bool ValidarRutaDestino(string v_rutaDestino)
    {
        v_errores.Clear();

        if (string.IsNullOrWhiteSpace(v_rutaDestino))
        {
            v_errores.Add("La ruta destino del paquete offline es obligatoria.");
            return false;
        }

        if (v_rutaDestino.Contains(".."))
        {
            v_errores.Add("La ruta destino no puede contener segmentos invalidos.");
            return false;
        }

        return true;
    }

    public string ObtenerResumen()
    {
        return $"Errores: {v_errores.Count}, Advertencias: {v_advertencias.Count}";
    }
}
