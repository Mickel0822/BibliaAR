using UnityEngine;

// kguanoluisa, Empaquetador offline base, variable v_manifiesto, 2026-07-07
public class OfflinePackager : MonoBehaviour
{
    [SerializeField] private OfflinePackageManifest v_manifiesto = new OfflinePackageManifest();

    public OfflinePackageManifest Manifiesto => v_manifiesto;
}
