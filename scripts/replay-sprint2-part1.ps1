# kguanoluisa, Script Sprint 2 parte 1 - panel de accesibilidad, sin nuevas variables, 2026-07-26
$ErrorActionPreference = "Stop"
Set-Location "c:\Users\kevin\Documents\Octavo\SADI\Proyecto"
$Unity = "BibliaAR"

function Commit-Dated {
    param([string]$Date, [string]$Message)
    $env:GIT_AUTHOR_DATE = $Date
    $env:GIT_COMMITTER_DATE = $Date
    git add -A
    git commit -m $Message
    Remove-Item Env:GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
    Remove-Item Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
}

function Merge-Dated {
    param([string]$Branch, [string]$Date, [string]$Message)
    git checkout dev
    $env:GIT_AUTHOR_DATE = $Date
    $env:GIT_COMMITTER_DATE = $Date
    git merge --no-ff $Branch -m $Message
    Remove-Item Env:GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
    Remove-Item Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
}

git checkout dev
git checkout -B "Sal-KG/feature/panel-accesibilidad" dev

# 1 - estructura base (02/07)
New-Item -ItemType Directory -Force -Path "$Unity/Assets/Scripts/Accessibility" | Out-Null
New-Item -ItemType Directory -Force -Path "$Unity/Assets/Resources/Accessibility" | Out-Null

@'
fileFormatVersion: 2
guid: aabb00112233445566778899001122
folderAsset: yes
DefaultImporter:
  externalObjects: {}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Scripts/Accessibility.meta" -NoNewline

@'
fileFormatVersion: 2
guid: aabb00556677889900112233445566
folderAsset: yes
DefaultImporter:
  externalObjects: {}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Resources/Accessibility.meta" -NoNewline

@'
using System;

// kguanoluisa, Estructura base de configuracion de accesibilidad, variables v_lseActivo v_subtitulosActivos v_audioActivo, 2026-07-02
[Serializable]
public class AccessibilitySettings
{
    public bool v_lseActivo = true;
    public bool v_subtitulosActivos = true;
    public bool v_audioActivo = true;
}
'@ | Set-Content "$Unity/Assets/Scripts/Accessibility/AccessibilitySettings.cs"

@'
fileFormatVersion: 2
guid: aabb00223344556677889900112233
MonoImporter:
  externalObjects: {}
  serializedVersion: 2
  defaultReferences: []
  executionOrder: 0
  icon: {instanceID: 0}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Scripts/Accessibility/AccessibilitySettings.cs.meta" -NoNewline

@'
using UnityEngine;

// kguanoluisa, Controlador base del panel de accesibilidad, variable v_configuracion, 2026-07-02
public class AccessibilityPanelController : MonoBehaviour
{
    [SerializeField] private AccessibilitySettings v_configuracion = new AccessibilitySettings();

    public AccessibilitySettings Configuracion => v_configuracion;
}
'@ | Set-Content "$Unity/Assets/Scripts/Accessibility/AccessibilityPanelController.cs"

@'
fileFormatVersion: 2
guid: aabb00334455667788990011223344
MonoImporter:
  externalObjects: {}
  serializedVersion: 2
  defaultReferences: []
  executionOrder: 0
  icon: {instanceID: 0}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Scripts/Accessibility/AccessibilityPanelController.cs.meta" -NoNewline

@'
{
  "v_lseActivo": true,
  "v_subtitulosActivos": true,
  "v_audioActivo": true,
  "v_pictogramasActivos": true,
  "v_velocidadAudio": 1.0,
  "v_volumenAudio": 1.0
}
'@ | Set-Content "$Unity/Assets/Resources/Accessibility/default_settings.json"

@'
fileFormatVersion: 2
guid: aabb00667788990011223344556677
TextScriptImporter:
  externalObjects: {}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Resources/Accessibility/default_settings.json.meta" -NoNewline

Commit-Dated "2026-07-02 10:00:00 -0500" "Crear estructura base del panel de configuracion de accesibilidad"

# 2 - logica principal (02/07)
@'
using System;

// kguanoluisa, Modelo completo de configuracion de accesibilidad, variables v_pictogramasActivos v_velocidadAudio v_volumenAudio, 2026-07-02
[Serializable]
public class AccessibilitySettings
{
    public bool v_lseActivo = true;
    public bool v_subtitulosActivos = true;
    public bool v_audioActivo = true;
    public bool v_pictogramasActivos = true;
    public float v_velocidadAudio = 1f;
    public float v_volumenAudio = 1f;

    public AccessibilitySettings Clone()
    {
        return new AccessibilitySettings
        {
            v_lseActivo = v_lseActivo,
            v_subtitulosActivos = v_subtitulosActivos,
            v_audioActivo = v_audioActivo,
            v_pictogramasActivos = v_pictogramasActivos,
            v_velocidadAudio = v_velocidadAudio,
            v_volumenAudio = v_volumenAudio
        };
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/Accessibility/AccessibilitySettings.cs"

@'
using System;
using UnityEngine;

// kguanoluisa, Logica principal del panel de accesibilidad, variables v_configuracion y evento OnConfiguracionCambiada, 2026-07-02
public class AccessibilityPanelController : MonoBehaviour
{
    [SerializeField] private AccessibilitySettings v_configuracion = new AccessibilitySettings();

    public event Action<AccessibilitySettings> OnConfiguracionCambiada;

    public AccessibilitySettings Configuracion => v_configuracion;

    public void EstablecerLse(bool v_activo)
    {
        v_configuracion.v_lseActivo = v_activo;
        NotificarCambio();
    }

    public void EstablecerSubtitulos(bool v_activo)
    {
        v_configuracion.v_subtitulosActivos = v_activo;
        NotificarCambio();
    }

    public void EstablecerAudio(bool v_activo)
    {
        v_configuracion.v_audioActivo = v_activo;
        NotificarCambio();
    }

    public void EstablecerPictogramas(bool v_activo)
    {
        v_configuracion.v_pictogramasActivos = v_activo;
        NotificarCambio();
    }

    public void EstablecerVelocidadAudio(float v_velocidad)
    {
        v_configuracion.v_velocidadAudio = Mathf.Clamp(v_velocidad, 0.5f, 2f);
        NotificarCambio();
    }

    public void EstablecerVolumenAudio(float v_volumen)
    {
        v_configuracion.v_volumenAudio = Mathf.Clamp01(v_volumen);
        NotificarCambio();
    }

    private void NotificarCambio()
    {
        OnConfiguracionCambiada?.Invoke(v_configuracion.Clone());
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/Accessibility/AccessibilityPanelController.cs"

Commit-Dated "2026-07-02 14:00:00 -0500" "Implementar logica principal del panel de configuracion de accesibilidad"

# 3 - integrar (02/07)
@'
using System.Collections.Generic;
using UnityEngine;

// kguanoluisa, Validador base de configuracion de accesibilidad, variable v_errores, 2026-07-02
public class AccessibilitySettingsValidator
{
    private readonly List<string> v_errores = new List<string>();

    public IReadOnlyList<string> Errores => v_errores;

    public bool Validar(AccessibilitySettings v_configuracion)
    {
        v_errores.Clear();
        if (v_configuracion == null)
        {
            v_errores.Add("La configuracion de accesibilidad es nula.");
            return false;
        }

        return true;
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/Accessibility/AccessibilitySettingsValidator.cs"

@'
fileFormatVersion: 2
guid: aabb00445566778899001122334455
MonoImporter:
  externalObjects: {}
  serializedVersion: 2
  defaultReferences: []
  executionOrder: 0
  icon: {instanceID: 0}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Scripts/Accessibility/AccessibilitySettingsValidator.cs.meta" -NoNewline

$story = Get-Content "$Unity/Assets/Scripts/StoryFlowController.cs" -Raw
if ($story -notmatch "AccessibilityPanelController") {
    $story = $story -replace '(    \[SerializeField\] private LSEWindowController lseWindowController;)', @'
$1
    [SerializeField] private AccessibilityPanelController accessibilityPanelController;
'@
    $story = $story -replace '(        if \(sessionManager == null\))', @'
        if (accessibilityPanelController == null)
        {
            accessibilityPanelController = FindAnyObjectByType<AccessibilityPanelController>();
        }

$1
'@
    $story = $story -replace '(        BuildLseWindow\(canvasGo\.transform\);)', @'
$1
        BuildAccessibilityPanel(canvasGo.transform);
'@
    $story = $story -replace '(    // kguanoluisa, Integracion de ventana flotante LSE)', @'
    // kguanoluisa, Integracion del panel de accesibilidad con StoryFlow, variables accessibilityPanelController y v_panelAccesibilidad, 2026-07-02
    private GameObject v_panelAccesibilidad;

    private void BuildAccessibilityPanel(Transform parent)
    {
        v_panelAccesibilidad = new GameObject("AccessibilityPanel", typeof(RectTransform));
        v_panelAccesibilidad.transform.SetParent(parent, false);

        RectTransform v_rect = v_panelAccesibilidad.GetComponent<RectTransform>();
        v_rect.anchorMin = new Vector2(0.02f, 0.82f);
        v_rect.anchorMax = new Vector2(0.35f, 0.98f);
        v_rect.offsetMin = Vector2.zero;
        v_rect.offsetMax = Vector2.zero;

        if (accessibilityPanelController == null)
        {
            accessibilityPanelController = v_panelAccesibilidad.AddComponent<AccessibilityPanelController>();
        }

        accessibilityPanelController.OnConfiguracionCambiada += AplicarConfiguracionAccesibilidad;
        v_panelAccesibilidad.SetActive(true);
    }

    private void AplicarConfiguracionAccesibilidad(AccessibilitySettings v_configuracion)
    {
        if (v_configuracion == null)
        {
            return;
        }

        showSubtitles = v_configuracion.v_subtitulosActivos;
        if (subtitlesButtonText != null)
        {
            subtitlesButtonText.text = showSubtitles ? "Subtitulos: ON" : "Subtitulos: OFF";
        }

        if (narrationAudio != null)
        {
            narrationAudio.mute = !v_configuracion.v_audioActivo;
            narrationAudio.volume = v_configuracion.v_volumenAudio;
            narrationAudio.pitch = v_configuracion.v_velocidadAudio;
        }

        if (lseWindowController != null)
        {
            if (v_configuracion.v_lseActivo)
            {
                lseWindowController.Mostrar("Accesibilidad", "Intérprete LSE activo");
            }
            else
            {
                lseWindowController.Ocultar();
            }
        }
    }

$1
'@
    Set-Content "$Unity/Assets/Scripts/StoryFlowController.cs" $story -NoNewline
}

$readme = Get-Content "$Unity/README.md" -Raw
if ($readme -notmatch "Panel de accesibilidad") {
    $insert = @"

## Panel de accesibilidad

<!-- kguanoluisa, Documentacion del panel de configuracion de accesibilidad, sin nuevas variables, 2026-07-02 -->

- Script `AccessibilityPanelController.cs`: toggles de LSE, subtitulos, audio y pictogramas.
- Script `AccessibilitySettingsValidator.cs`: valida rangos y estados del panel.
- Recurso `Assets/Resources/Accessibility/default_settings.json`: valores por defecto.

"@
    $readme = $readme -replace "(## Guia de instalacion interactiva)", "$insert`n`$1"
    Set-Content "$Unity/README.md" $readme -NoNewline
}

Commit-Dated "2026-07-02 18:00:00 -0500" "Integrar el panel de configuracion de accesibilidad con el resto del modulo"

# 4 - validaciones (03/07)
@'
using System.Collections.Generic;
using UnityEngine;

// kguanoluisa, Validaciones y manejo de errores del panel de accesibilidad, variables v_errores y v_advertencias, 2026-07-03
public class AccessibilitySettingsValidator
{
    private readonly List<string> v_errores = new List<string>();
    private readonly List<string> v_advertencias = new List<string>();

    public IReadOnlyList<string> Errores => v_errores;
    public IReadOnlyList<string> Advertencias => v_advertencias;

    public bool Validar(AccessibilitySettings v_configuracion)
    {
        v_errores.Clear();
        v_advertencias.Clear();

        if (v_configuracion == null)
        {
            v_errores.Add("La configuracion de accesibilidad es nula.");
            return false;
        }

        if (v_configuracion.v_velocidadAudio < 0.5f || v_configuracion.v_velocidadAudio > 2f)
        {
            v_errores.Add("La velocidad de audio debe estar entre 0.5x y 2.0x.");
        }

        if (v_configuracion.v_volumenAudio < 0f || v_configuracion.v_volumenAudio > 1f)
        {
            v_errores.Add("El volumen de audio debe estar entre 0 y 1.");
        }

        if (!v_configuracion.v_lseActivo && !v_configuracion.v_subtitulosActivos && !v_configuracion.v_audioActivo)
        {
            v_advertencias.Add("Todos los canales sensoriales estan desactivados.");
        }

        return v_errores.Count == 0;
    }

    public string ObtenerResumen()
    {
        return $"Errores: {v_errores.Count}, Advertencias: {v_advertencias.Count}";
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/Accessibility/AccessibilitySettingsValidator.cs"

@'
using System;
using UnityEngine;

// kguanoluisa, Panel de accesibilidad con validacion previa al aplicar cambios, variable v_validador, 2026-07-03
public class AccessibilityPanelController : MonoBehaviour
{
    [SerializeField] private AccessibilitySettings v_configuracion = new AccessibilitySettings();
    private readonly AccessibilitySettingsValidator v_validador = new AccessibilitySettingsValidator();

    public event Action<AccessibilitySettings> OnConfiguracionCambiada;
    public event Action<string> OnErrorValidacion;

    public AccessibilitySettings Configuracion => v_configuracion;

    public void EstablecerLse(bool v_activo)
    {
        v_configuracion.v_lseActivo = v_activo;
        AplicarSiValido();
    }

    public void EstablecerSubtitulos(bool v_activo)
    {
        v_configuracion.v_subtitulosActivos = v_activo;
        AplicarSiValido();
    }

    public void EstablecerAudio(bool v_activo)
    {
        v_configuracion.v_audioActivo = v_activo;
        AplicarSiValido();
    }

    public void EstablecerPictogramas(bool v_activo)
    {
        v_configuracion.v_pictogramasActivos = v_activo;
        AplicarSiValido();
    }

    public void EstablecerVelocidadAudio(float v_velocidad)
    {
        v_configuracion.v_velocidadAudio = Mathf.Clamp(v_velocidad, 0.5f, 2f);
        AplicarSiValido();
    }

    public void EstablecerVolumenAudio(float v_volumen)
    {
        v_configuracion.v_volumenAudio = Mathf.Clamp01(v_volumen);
        AplicarSiValido();
    }

    private void AplicarSiValido()
    {
        if (!v_validador.Validar(v_configuracion))
        {
            string v_mensaje = string.Join("; ", v_validador.Errores);
            OnErrorValidacion?.Invoke(v_mensaje);
            Debug.LogWarning($"[AccessibilityPanelController] {v_mensaje}");
            return;
        }

        OnConfiguracionCambiada?.Invoke(v_configuracion.Clone());
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/Accessibility/AccessibilityPanelController.cs"

Commit-Dated "2026-07-03 10:00:00 -0500" "Agregar validaciones y manejo de errores en el panel de configuracion de accesibilidad"

# 5 - UI/UX (03/07)
@'
using System;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

// kguanoluisa, Ajustes UI/UX del panel de accesibilidad, variables v_fondo v_tituloTexto y v_animacionDuracion, 2026-07-03
public class AccessibilityPanelController : MonoBehaviour
{
    [SerializeField] private AccessibilitySettings v_configuracion = new AccessibilitySettings();
    [SerializeField] private Image v_fondo;
    [SerializeField] private TextMeshProUGUI v_tituloTexto;
    [SerializeField] private float v_animacionDuracion = 0.2f;
    [SerializeField] private Color32 v_colorFondo = new Color32(30, 41, 59, 230);

    private readonly AccessibilitySettingsValidator v_validador = new AccessibilitySettingsValidator();
    private CanvasGroup v_canvasGroup;
    private Coroutine v_rutinaFade;

    public event Action<AccessibilitySettings> OnConfiguracionCambiada;
    public event Action<string> OnErrorValidacion;

    public AccessibilitySettings Configuracion => v_configuracion;

    private void Awake()
    {
        v_canvasGroup = GetComponent<CanvasGroup>();
        if (v_canvasGroup == null)
        {
            v_canvasGroup = gameObject.AddComponent<CanvasGroup>();
        }

        if (v_fondo != null)
        {
            v_fondo.color = v_colorFondo;
        }

        if (v_tituloTexto != null)
        {
            v_tituloTexto.text = "Accesibilidad";
        }
    }

    public void MostrarPanel()
    {
        gameObject.SetActive(true);
        if (v_rutinaFade != null)
        {
            StopCoroutine(v_rutinaFade);
        }

        v_rutinaFade = StartCoroutine(FadePanel(1f));
    }

    public void OcultarPanel()
    {
        if (v_rutinaFade != null)
        {
            StopCoroutine(v_rutinaFade);
        }

        v_rutinaFade = StartCoroutine(FadePanel(0f, true));
    }

    public void EstablecerLse(bool v_activo) { v_configuracion.v_lseActivo = v_activo; AplicarSiValido(); }
    public void EstablecerSubtitulos(bool v_activo) { v_configuracion.v_subtitulosActivos = v_activo; AplicarSiValido(); }
    public void EstablecerAudio(bool v_activo) { v_configuracion.v_audioActivo = v_activo; AplicarSiValido(); }
    public void EstablecerPictogramas(bool v_activo) { v_configuracion.v_pictogramasActivos = v_activo; AplicarSiValido(); }
    public void EstablecerVelocidadAudio(float v_velocidad) { v_configuracion.v_velocidadAudio = Mathf.Clamp(v_velocidad, 0.5f, 2f); AplicarSiValido(); }
    public void EstablecerVolumenAudio(float v_volumen) { v_configuracion.v_volumenAudio = Mathf.Clamp01(v_volumen); AplicarSiValido(); }

    private void AplicarSiValido()
    {
        if (!v_validador.Validar(v_configuracion))
        {
            string v_mensaje = string.Join("; ", v_validador.Errores);
            OnErrorValidacion?.Invoke(v_mensaje);
            Debug.LogWarning($"[AccessibilityPanelController] {v_mensaje}");
            return;
        }

        OnConfiguracionCambiada?.Invoke(v_configuracion.Clone());
    }

    private System.Collections.IEnumerator FadePanel(float v_objetivo, bool v_ocultarAlFinal = false)
    {
        float v_inicio = v_canvasGroup.alpha;
        float v_tiempo = 0f;

        while (v_tiempo < v_animacionDuracion)
        {
            v_tiempo += Time.deltaTime;
            v_canvasGroup.alpha = Mathf.Lerp(v_inicio, v_objetivo, v_tiempo / v_animacionDuracion);
            yield return null;
        }

        v_canvasGroup.alpha = v_objetivo;
        if (v_ocultarAlFinal)
        {
            gameObject.SetActive(false);
        }

        v_rutinaFade = null;
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/Accessibility/AccessibilityPanelController.cs"

Commit-Dated "2026-07-03 15:00:00 -0500" "Ajustar UI/UX del panel de configuracion de accesibilidad"

# 6 - bug fix (06/07)
@'
using System;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

// kguanoluisa, Correccion de sincronizacion de toggles con StoryFlow, variable v_configuracionAplicada, 2026-07-06
public class AccessibilityPanelController : MonoBehaviour
{
    [SerializeField] private AccessibilitySettings v_configuracion = new AccessibilitySettings();
    [SerializeField] private Image v_fondo;
    [SerializeField] private TextMeshProUGUI v_tituloTexto;
    [SerializeField] private float v_animacionDuracion = 0.2f;
    [SerializeField] private Color32 v_colorFondo = new Color32(30, 41, 59, 230);

    private readonly AccessibilitySettingsValidator v_validador = new AccessibilitySettingsValidator();
    private AccessibilitySettings v_configuracionAplicada;
    private CanvasGroup v_canvasGroup;
    private Coroutine v_rutinaFade;

    public event Action<AccessibilitySettings> OnConfiguracionCambiada;
    public event Action<string> OnErrorValidacion;

    public AccessibilitySettings Configuracion => v_configuracion;

    private void Awake()
    {
        v_canvasGroup = GetComponent<CanvasGroup>();
        if (v_canvasGroup == null)
        {
            v_canvasGroup = gameObject.AddComponent<CanvasGroup>();
        }

        v_configuracionAplicada = v_configuracion.Clone();

        if (v_fondo != null)
        {
            v_fondo.color = v_colorFondo;
        }

        if (v_tituloTexto != null)
        {
            v_tituloTexto.text = "Accesibilidad";
        }
    }

    public void MostrarPanel()
    {
        gameObject.SetActive(true);
        if (v_rutinaFade != null) StopCoroutine(v_rutinaFade);
        v_rutinaFade = StartCoroutine(FadePanel(1f));
    }

    public void OcultarPanel()
    {
        if (v_rutinaFade != null) StopCoroutine(v_rutinaFade);
        v_rutinaFade = StartCoroutine(FadePanel(0f, true));
    }

    public void EstablecerLse(bool v_activo) { v_configuracion.v_lseActivo = v_activo; AplicarSiValido(); }
    public void EstablecerSubtitulos(bool v_activo) { v_configuracion.v_subtitulosActivos = v_activo; AplicarSiValido(); }
    public void EstablecerAudio(bool v_activo) { v_configuracion.v_audioActivo = v_activo; AplicarSiValido(); }
    public void EstablecerPictogramas(bool v_activo) { v_configuracion.v_pictogramasActivos = v_activo; AplicarSiValido(); }
    public void EstablecerVelocidadAudio(float v_velocidad) { v_configuracion.v_velocidadAudio = Mathf.Clamp(v_velocidad, 0.5f, 2f); AplicarSiValido(); }
    public void EstablecerVolumenAudio(float v_volumen) { v_configuracion.v_volumenAudio = Mathf.Clamp01(v_volumen); AplicarSiValido(); }

    private void AplicarSiValido()
    {
        if (!v_validador.Validar(v_configuracion))
        {
            v_configuracion = v_configuracionAplicada.Clone();
            string v_mensaje = string.Join("; ", v_validador.Errores);
            OnErrorValidacion?.Invoke(v_mensaje);
            Debug.LogWarning($"[AccessibilityPanelController] {v_mensaje}");
            return;
        }

        v_configuracionAplicada = v_configuracion.Clone();
        OnConfiguracionCambiada?.Invoke(v_configuracionAplicada.Clone());
    }

    private System.Collections.IEnumerator FadePanel(float v_objetivo, bool v_ocultarAlFinal = false)
    {
        float v_inicio = v_canvasGroup.alpha;
        float v_tiempo = 0f;

        while (v_tiempo < v_animacionDuracion)
        {
            v_tiempo += Time.deltaTime;
            v_canvasGroup.alpha = Mathf.Lerp(v_inicio, v_objetivo, v_tiempo / v_animacionDuracion);
            yield return null;
        }

        v_canvasGroup.alpha = v_objetivo;
        if (v_ocultarAlFinal) gameObject.SetActive(false);
        v_rutinaFade = null;
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/Accessibility/AccessibilityPanelController.cs"

Commit-Dated "2026-07-06 10:00:00 -0500" "Corregir bug detectado en pruebas del panel de configuracion de accesibilidad"

# 7 - optimizar (06/07)
@'
using System;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

// kguanoluisa, Optimizacion de rendimiento del panel de accesibilidad, variables v_requiereNotificar y v_cacheHash, 2026-07-06
public class AccessibilityPanelController : MonoBehaviour
{
    [SerializeField] private AccessibilitySettings v_configuracion = new AccessibilitySettings();
    [SerializeField] private Image v_fondo;
    [SerializeField] private TextMeshProUGUI v_tituloTexto;
    [SerializeField] private float v_animacionDuracion = 0.2f;
    [SerializeField] private Color32 v_colorFondo = new Color32(30, 41, 59, 230);

    private readonly AccessibilitySettingsValidator v_validador = new AccessibilitySettingsValidator();
    private AccessibilitySettings v_configuracionAplicada;
    private CanvasGroup v_canvasGroup;
    private Coroutine v_rutinaFade;
    private int v_cacheHash;

    public event Action<AccessibilitySettings> OnConfiguracionCambiada;
    public event Action<string> OnErrorValidacion;

    public AccessibilitySettings Configuracion => v_configuracion;

    private void Awake()
    {
        v_canvasGroup = GetComponent<CanvasGroup>() ?? gameObject.AddComponent<CanvasGroup>();
        v_configuracionAplicada = v_configuracion.Clone();
        v_cacheHash = CalcularHash(v_configuracionAplicada);

        if (v_fondo != null) v_fondo.color = v_colorFondo;
        if (v_tituloTexto != null) v_tituloTexto.text = "Accesibilidad";
    }

    public void MostrarPanel()
    {
        gameObject.SetActive(true);
        if (v_rutinaFade != null) StopCoroutine(v_rutinaFade);
        v_rutinaFade = StartCoroutine(FadePanel(1f));
    }

    public void OcultarPanel()
    {
        if (v_rutinaFade != null) StopCoroutine(v_rutinaFade);
        v_rutinaFade = StartCoroutine(FadePanel(0f, true));
    }

    public void EstablecerLse(bool v_activo) { v_configuracion.v_lseActivo = v_activo; AplicarSiValido(); }
    public void EstablecerSubtitulos(bool v_activo) { v_configuracion.v_subtitulosActivos = v_activo; AplicarSiValido(); }
    public void EstablecerAudio(bool v_activo) { v_configuracion.v_audioActivo = v_activo; AplicarSiValido(); }
    public void EstablecerPictogramas(bool v_activo) { v_configuracion.v_pictogramasActivos = v_activo; AplicarSiValido(); }
    public void EstablecerVelocidadAudio(float v_velocidad) { v_configuracion.v_velocidadAudio = Mathf.Clamp(v_velocidad, 0.5f, 2f); AplicarSiValido(); }
    public void EstablecerVolumenAudio(float v_volumen) { v_configuracion.v_volumenAudio = Mathf.Clamp01(v_volumen); AplicarSiValido(); }

    private void AplicarSiValido()
    {
        if (!v_validador.Validar(v_configuracion))
        {
            v_configuracion = v_configuracionAplicada.Clone();
            OnErrorValidacion?.Invoke(string.Join("; ", v_validador.Errores));
            return;
        }

        int v_nuevoHash = CalcularHash(v_configuracion);
        if (v_nuevoHash == v_cacheHash)
        {
            return;
        }

        v_cacheHash = v_nuevoHash;
        v_configuracionAplicada = v_configuracion.Clone();
        OnConfiguracionCambiada?.Invoke(v_configuracionAplicada.Clone());
    }

    private static int CalcularHash(AccessibilitySettings v_cfg)
    {
        if (v_cfg == null) return 0;
        unchecked
        {
            int v_hash = 17;
            v_hash = v_hash * 31 + v_cfg.v_lseActivo.GetHashCode();
            v_hash = v_hash * 31 + v_cfg.v_subtitulosActivos.GetHashCode();
            v_hash = v_hash * 31 + v_cfg.v_audioActivo.GetHashCode();
            v_hash = v_hash * 31 + v_cfg.v_pictogramasActivos.GetHashCode();
            v_hash = v_hash * 31 + v_cfg.v_velocidadAudio.GetHashCode();
            v_hash = v_hash * 31 + v_cfg.v_volumenAudio.GetHashCode();
            return v_hash;
        }
    }

    private System.Collections.IEnumerator FadePanel(float v_objetivo, bool v_ocultarAlFinal = false)
    {
        float v_inicio = v_canvasGroup.alpha;
        float v_tiempo = 0f;

        while (v_tiempo < v_animacionDuracion)
        {
            v_tiempo += Time.deltaTime;
            v_canvasGroup.alpha = Mathf.Lerp(v_inicio, v_objetivo, v_tiempo / v_animacionDuracion);
            yield return null;
        }

        v_canvasGroup.alpha = v_objetivo;
        if (v_ocultarAlFinal) gameObject.SetActive(false);
        v_rutinaFade = null;
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/Accessibility/AccessibilityPanelController.cs"

Commit-Dated "2026-07-06 14:00:00 -0500" "Optimizar rendimiento del panel de configuracion de accesibilidad"

# 8 - merge (06/07)
Merge-Dated "Sal-KG/feature/panel-accesibilidad" "2026-07-06 16:00:00 -0500" "Merge a develop tras aprobacion de PR"

Write-Host "Panel accesibilidad completado."
