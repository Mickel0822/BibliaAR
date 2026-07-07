using System;
using System.Collections.Generic;

// kguanoluisa, Manifiesto offline con metadatos de escena, variables v_escenaPrincipal y v_fechaGeneracion, 2026-07-07
[Serializable]
public class OfflinePackageManifest
{
    public string v_version = "1.0.0";
    public string v_escenaPrincipal = "SampleScene";
    public string v_fechaGeneracion = string.Empty;
    public List<string> v_recursos = new List<string>();
    public long v_tamanoBytes;

    public void MarcarGenerado()
    {
        v_fechaGeneracion = DateTime.UtcNow.ToString("o");
    }
}
