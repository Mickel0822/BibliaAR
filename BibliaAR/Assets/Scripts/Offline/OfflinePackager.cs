using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

// kguanoluisa, Logica principal del empaquetado offline, variables v_rutaDestino v_manifiesto y v_extensionesPermitidas, 2026-07-07
public class OfflinePackager : MonoBehaviour
{
    [SerializeField] private OfflinePackageManifest v_manifiesto = new OfflinePackageManifest();
    [SerializeField] private string v_rutaDestino = "StreamingAssets/Offline";
    [SerializeField] private string[] v_extensionesPermitidas = { ".json", ".png", ".mp3", ".mp4", ".prefab" };

    public OfflinePackageManifest Manifiesto => v_manifiesto;

    public bool EmpaquetarRecursos(IEnumerable<string> v_rutasRecursos)
    {
        v_manifiesto.v_recursos.Clear();
        v_manifiesto.v_tamanoBytes = 0;

        string v_destinoAbsoluto = Path.Combine(Application.dataPath, v_rutaDestino);
        Directory.CreateDirectory(v_destinoAbsoluto);

        foreach (string v_ruta in v_rutasRecursos)
        {
            if (string.IsNullOrWhiteSpace(v_ruta) || !File.Exists(v_ruta))
            {
                continue;
            }

            if (!EsExtensionPermitida(v_ruta))
            {
                Debug.LogWarning($"[OfflinePackager] Extension no permitida: {v_ruta}");
                continue;
            }

            string v_nombreArchivo = Path.GetFileName(v_ruta);
            string v_destinoArchivo = Path.Combine(v_destinoAbsoluto, v_nombreArchivo);
            File.Copy(v_ruta, v_destinoArchivo, true);

            FileInfo v_info = new FileInfo(v_destinoArchivo);
            v_manifiesto.v_recursos.Add(v_nombreArchivo);
            v_manifiesto.v_tamanoBytes += v_info.Length;
        }

        return v_manifiesto.v_recursos.Count > 0;
    }

    private bool EsExtensionPermitida(string v_ruta)
    {
        string v_ext = Path.GetExtension(v_ruta).ToLowerInvariant();
        foreach (string v_permitida in v_extensionesPermitidas)
        {
            if (v_ext == v_permitida)
            {
                return true;
            }
        }

        return false;
    }
}
