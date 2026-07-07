using System;
using System.Collections.Generic;

// kguanoluisa, Estructura base del manifiesto de empaquetado offline, variables v_version v_recursos y v_tamanoBytes, 2026-07-07
[Serializable]
public class OfflinePackageManifest
{
    public string v_version = "1.0.0";
    public List<string> v_recursos = new List<string>();
    public long v_tamanoBytes;
}
