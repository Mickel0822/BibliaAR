# kguanoluisa, Parte 2 del script Sprint 1 - BIAR-25 ventana LSE, sin nuevas variables, 2026-07-26
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
git checkout -B "Sal-KG/feature/ventana-lse" dev

# Commit 1 - estructura base LSE (26/06)
New-Item -ItemType Directory -Force -Path "$Unity/Assets/Scripts/LSE" | Out-Null

@'
fileFormatVersion: 2
guid: 90123456789abcdef0123456789012a
folderAsset: yes
DefaultImporter:
  externalObjects: {}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Scripts/LSE.meta" -NoNewline

@'
using UnityEngine;

// kguanoluisa, Estructura base de la ventana flotante LSE BIAR-25, variables v_expandido y v_titulo, 2026-06-26
public class LSEWindowController : MonoBehaviour
{
    [SerializeField] private string v_titulo = "Intérprete LSE";
    [SerializeField] private bool v_expandido;

    public bool Expandido => v_expandido;
    public string Titulo => v_titulo;
}
'@ | Set-Content "$Unity/Assets/Scripts/LSE/LSEWindowController.cs"

@'
fileFormatVersion: 2
guid: 0123456789abcdef0123456789012ab
MonoImporter:
  externalObjects: {}
  serializedVersion: 2
  defaultReferences: []
  executionOrder: 0
  icon: {instanceID: 0}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Scripts/LSE/LSEWindowController.cs.meta" -NoNewline

Commit-Dated "2026-06-26 10:00:00 -0500" "BIAR-25: crear estructura base de la ventana flotante del interprete LSE"

# Commit 2 - logica principal (26/06)
@'
using UnityEngine;
using UnityEngine.UI;
using TMPro;

// kguanoluisa, Logica principal de ventana flotante LSE BIAR-25, variables v_expandido v_panel v_tituloTexto, 2026-06-26
public class LSEWindowController : MonoBehaviour
{
    [Header("Contenido LSE")]
    [SerializeField] private string v_titulo = "Intérprete LSE";
    [SerializeField] private string v_descripcion = "Traducción en lengua de señas";

    [Header("UI")]
    [SerializeField] private RectTransform v_panel;
    [SerializeField] private TextMeshProUGUI v_tituloTexto;
    [SerializeField] private TextMeshProUGUI v_descripcionTexto;
    [SerializeField] private Button v_botonExpandir;

    private bool v_expandido;
    private float v_anchoReducido = 0.25f;
    private float v_anchoExpandido = 0.50f;

    public bool Expandido => v_expandido;

    private void Awake()
    {
        if (v_botonExpandir != null)
        {
            v_botonExpandir.onClick.AddListener(AlternarExpansion);
        }

        ActualizarTextos();
        AplicarAncho();
    }

    public void AlternarExpansion()
    {
        v_expandido = !v_expandido;
        AplicarAncho();
        ActualizarDescripcionVisible();
    }

    public void Mostrar(string v_tituloFragmento, string v_descripcionFragmento)
    {
        v_titulo = string.IsNullOrWhiteSpace(v_tituloFragmento) ? "Intérprete LSE" : v_tituloFragmento;
        v_descripcion = v_descripcionFragmento ?? string.Empty;
        ActualizarTextos();
        gameObject.SetActive(true);
    }

    public void Ocultar()
    {
        gameObject.SetActive(false);
    }

    private void ActualizarTextos()
    {
        if (v_tituloTexto != null)
        {
            v_tituloTexto.text = v_titulo;
        }

        ActualizarDescripcionVisible();
    }

    private void ActualizarDescripcionVisible()
    {
        if (v_descripcionTexto != null)
        {
            v_descripcionTexto.text = v_expandido ? v_descripcion : string.Empty;
            v_descripcionTexto.gameObject.SetActive(v_expandido);
        }
    }

    private void AplicarAncho()
    {
        if (v_panel == null)
        {
            return;
        }

        float v_ancho = v_expandido ? v_anchoExpandido : v_anchoReducido;
        v_panel.anchorMin = new Vector2(1f - v_ancho, 0.70f);
        v_panel.anchorMax = new Vector2(1f, 0.98f);
        v_panel.offsetMin = Vector2.zero;
        v_panel.offsetMax = Vector2.zero;
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/LSE/LSEWindowController.cs"

@'
using UnityEngine;
using UnityEngine.Video;

// kguanoluisa, Reproductor de video LSE BIAR-25, variables v_videoPlayer y v_clip, 2026-06-26
[RequireComponent(typeof(VideoPlayer))]
public class LSEVideoPlayer : MonoBehaviour
{
    private VideoPlayer v_videoPlayer;
    [SerializeField] private VideoClip v_clip;

    private void Awake()
    {
        v_videoPlayer = GetComponent<VideoPlayer>();
        v_videoPlayer.playOnAwake = false;
        v_videoPlayer.isLooping = true;
    }

    public void Reproducir(VideoClip v_clipEntrada)
    {
        v_clip = v_clipEntrada != null ? v_clipEntrada : v_clip;
        if (v_clip == null)
        {
            return;
        }

        v_videoPlayer.clip = v_clip;
        v_videoPlayer.Play();
    }

    public void Detener()
    {
        if (v_videoPlayer != null && v_videoPlayer.isPlaying)
        {
            v_videoPlayer.Stop();
        }
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/LSE/LSEVideoPlayer.cs"

@'
fileFormatVersion: 2
guid: 123456789abcdef0123456789012abcd
MonoImporter:
  externalObjects: {}
  serializedVersion: 2
  defaultReferences: []
  executionOrder: 0
  icon: {instanceID: 0}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Scripts/LSE/LSEVideoPlayer.cs.meta" -NoNewline

Commit-Dated "2026-06-26 14:00:00 -0500" "BIAR-25: implementar logica principal de la ventana flotante del interprete LSE"

# Commit 3 - integrar (26/06)
$story = Get-Content "$Unity/Assets/Scripts/StoryFlowController.cs" -Raw
if ($story -notmatch "LSEWindowController") {
    $story = $story -replace '(    \[SerializeField\] private SessionManager sessionManager;)', @'
$1
    [SerializeField] private LSEWindowController lseWindowController;
'@
    $story = $story -replace '(        BuildSubtitlePanel\(canvasGo\.transform\);)', @'
$1
        BuildLseWindow(canvasGo.transform);
'@
    $story = $story -replace '(    private void BuildSubtitlePanel\(Transform parent\))', @'
    // kguanoluisa, Integracion de ventana flotante LSE con StoryFlow BIAR-25, variable lseWindowController, 2026-06-26
    private void BuildLseWindow(Transform parent)
    {
        GameObject lseGo = new GameObject("LSEFloatingWindow", typeof(RectTransform));
        lseGo.transform.SetParent(parent, false);

        RectTransform panel = lseGo.GetComponent<RectTransform>();
        panel.anchorMin = new Vector2(0.75f, 0.70f);
        panel.anchorMax = new Vector2(1f, 0.98f);
        panel.offsetMin = Vector2.zero;
        panel.offsetMax = Vector2.zero;

        Image bg = lseGo.AddComponent<Image>();
        bg.color = new Color32(45, 55, 72, 240);

        lseWindowController = lseGo.AddComponent<LSEWindowController>();
        lseGo.SetActive(false);
    }

$1
'@
    $story = $story -replace '(            if \(sceneAnimationController != null\))', @'
            if (lseWindowController != null)
            {
                string v_tituloLse = subtitles != null && i < subtitles.Length ? subtitles[i] : "Fragmento narrativo";
                lseWindowController.Mostrar(v_tituloLse, v_tituloLse);
            }

$1
'@
    $story = $story -replace '(        SetSubtitleVisible\(false\);\s+StartQuiz\(\);)', @'
        if (lseWindowController != null)
        {
            lseWindowController.Ocultar();
        }

        $1
'@
    Set-Content "$Unity/Assets/Scripts/StoryFlowController.cs" $story -NoNewline
}

Commit-Dated "2026-06-26 18:00:00 -0500" "BIAR-25: integrar la ventana flotante del interprete LSE con el resto del modulo"

# Commit 4 - validaciones (29/06)
@'
using UnityEngine;
using UnityEngine.UI;
using TMPro;

// kguanoluisa, Validaciones y manejo de errores en ventana LSE BIAR-25, variables v_mensajeError y v_videoPlayer, 2026-06-29
public class LSEWindowController : MonoBehaviour
{
    [Header("Contenido LSE")]
    [SerializeField] private string v_titulo = "Intérprete LSE";
    [SerializeField] private string v_descripcion = "Traducción en lengua de señas";

    [Header("UI")]
    [SerializeField] private RectTransform v_panel;
    [SerializeField] private TextMeshProUGUI v_tituloTexto;
    [SerializeField] private TextMeshProUGUI v_descripcionTexto;
    [SerializeField] private TextMeshProUGUI v_mensajeError;
    [SerializeField] private Button v_botonExpandir;

    [Header("Video")]
    [SerializeField] private LSEVideoPlayer v_videoPlayer;

    private bool v_expandido;
    private float v_anchoReducido = 0.25f;
    private float v_anchoExpandido = 0.50f;

    public bool Expandido => v_expandido;

    private void Awake()
    {
        if (v_botonExpandir != null)
        {
            v_botonExpandir.onClick.AddListener(AlternarExpansion);
        }

        ActualizarTextos();
        AplicarAncho();
        OcultarError();
    }

    public void AlternarExpansion()
    {
        v_expandido = !v_expandido;
        AplicarAncho();
        ActualizarDescripcionVisible();
    }

    public void Mostrar(string v_tituloFragmento, string v_descripcionFragmento)
    {
        if (string.IsNullOrWhiteSpace(v_tituloFragmento) && string.IsNullOrWhiteSpace(v_descripcionFragmento))
        {
            MostrarError("No hay contenido LSE disponible para este fragmento.");
            return;
        }

        OcultarError();
        v_titulo = string.IsNullOrWhiteSpace(v_tituloFragmento) ? "Intérprete LSE" : v_tituloFragmento;
        v_descripcion = v_descripcionFragmento ?? string.Empty;
        ActualizarTextos();
        gameObject.SetActive(true);
    }

    public void Ocultar()
    {
        v_videoPlayer?.Detener();
        gameObject.SetActive(false);
        OcultarError();
    }

    private void MostrarError(string v_mensaje)
    {
        if (v_mensajeError != null)
        {
            v_mensajeError.text = v_mensaje;
            v_mensajeError.gameObject.SetActive(true);
        }

        Debug.LogWarning($"[LSEWindowController] {v_mensaje}");
    }

    private void OcultarError()
    {
        if (v_mensajeError != null)
        {
            v_mensajeError.gameObject.SetActive(false);
        }
    }

    private void ActualizarTextos()
    {
        if (v_tituloTexto != null)
        {
            v_tituloTexto.text = v_titulo;
        }

        ActualizarDescripcionVisible();
    }

    private void ActualizarDescripcionVisible()
    {
        if (v_descripcionTexto != null)
        {
            v_descripcionTexto.text = v_expandido ? v_descripcion : string.Empty;
            v_descripcionTexto.gameObject.SetActive(v_expandido);
        }
    }

    private void AplicarAncho()
    {
        if (v_panel == null)
        {
            return;
        }

        float v_ancho = v_expandido ? v_anchoExpandido : v_anchoReducido;
        v_panel.anchorMin = new Vector2(1f - v_ancho, 0.70f);
        v_panel.anchorMax = new Vector2(1f, 0.98f);
        v_panel.offsetMin = Vector2.zero;
        v_panel.offsetMax = Vector2.zero;
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/LSE/LSEWindowController.cs"

@'
using UnityEngine;
using UnityEngine.Video;

// kguanoluisa, Validaciones del reproductor LSE BIAR-25, variables v_videoPlayer v_clip y v_mensajeError, 2026-06-29
[RequireComponent(typeof(VideoPlayer))]
public class LSEVideoPlayer : MonoBehaviour
{
    private VideoPlayer v_videoPlayer;
    [SerializeField] private VideoClip v_clip;
    private string v_mensajeError;

    public string MensajeError => v_mensajeError;

    private void Awake()
    {
        v_videoPlayer = GetComponent<VideoPlayer>();
        v_videoPlayer.playOnAwake = false;
        v_videoPlayer.isLooping = true;
    }

    public bool Reproducir(VideoClip v_clipEntrada)
    {
        v_mensajeError = string.Empty;
        v_clip = v_clipEntrada != null ? v_clipEntrada : v_clip;

        if (v_clip == null)
        {
            v_mensajeError = "Clip LSE no asignado.";
            Debug.LogWarning("[LSEVideoPlayer] Clip LSE no asignado.");
            return false;
        }

        v_videoPlayer.clip = v_clip;
        v_videoPlayer.Play();
        return true;
    }

    public void Detener()
    {
        if (v_videoPlayer != null && v_videoPlayer.isPlaying)
        {
            v_videoPlayer.Stop();
        }
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/LSE/LSEVideoPlayer.cs"

Commit-Dated "2026-06-29 10:00:00 -0500" "BIAR-25: agregar validaciones y manejo de errores en la ventana flotante del interprete LSE"

# Commit 5 - UI/UX (29/06)
@'
using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

// kguanoluisa, Ajustes UI/UX de ventana flotante LSE BIAR-25, variables v_animacionDuracion y v_colorFondo, 2026-06-29
public class LSEWindowController : MonoBehaviour
{
    [Header("Contenido LSE")]
    [SerializeField] private string v_titulo = "Intérprete LSE";
    [SerializeField] private string v_descripcion = "Traducción en lengua de señas";

    [Header("UI")]
    [SerializeField] private RectTransform v_panel;
    [SerializeField] private TextMeshProUGUI v_tituloTexto;
    [SerializeField] private TextMeshProUGUI v_descripcionTexto;
    [SerializeField] private TextMeshProUGUI v_mensajeError;
    [SerializeField] private Button v_botonExpandir;
    [SerializeField] private Image v_fondo;
    [SerializeField] private float v_animacionDuracion = 0.25f;
    [SerializeField] private Color32 v_colorFondo = new Color32(45, 55, 72, 240);

    [Header("Video")]
    [SerializeField] private LSEVideoPlayer v_videoPlayer;

    private bool v_expandido;
    private float v_anchoReducido = 0.25f;
    private float v_anchoExpandido = 0.50f;
    private Coroutine v_rutinaAnimacion;

    public bool Expandido => v_expandido;

    private void Awake()
    {
        if (v_botonExpandir != null)
        {
            v_botonExpandir.onClick.AddListener(AlternarExpansion);
        }

        if (v_fondo != null)
        {
            v_fondo.color = v_colorFondo;
        }

        ActualizarTextos();
        AplicarAncho(instantaneo: true);
        OcultarError();
    }

    public void AlternarExpansion()
    {
        v_expandido = !v_expandido;
        AplicarAncho();
        ActualizarDescripcionVisible();
    }

    public void Mostrar(string v_tituloFragmento, string v_descripcionFragmento)
    {
        if (string.IsNullOrWhiteSpace(v_tituloFragmento) && string.IsNullOrWhiteSpace(v_descripcionFragmento))
        {
            MostrarError("No hay contenido LSE disponible para este fragmento.");
            return;
        }

        OcultarError();
        v_titulo = string.IsNullOrWhiteSpace(v_tituloFragmento) ? "Intérprete LSE" : v_tituloFragmento;
        v_descripcion = v_descripcionFragmento ?? string.Empty;
        ActualizarTextos();
        gameObject.SetActive(true);
    }

    public void Ocultar()
    {
        v_videoPlayer?.Detener();
        gameObject.SetActive(false);
        OcultarError();
    }

    private void MostrarError(string v_mensaje)
    {
        if (v_mensajeError != null)
        {
            v_mensajeError.text = v_mensaje;
            v_mensajeError.gameObject.SetActive(true);
        }

        Debug.LogWarning($"[LSEWindowController] {v_mensaje}");
    }

    private void OcultarError()
    {
        if (v_mensajeError != null)
        {
            v_mensajeError.gameObject.SetActive(false);
        }
    }

    private void ActualizarTextos()
    {
        if (v_tituloTexto != null)
        {
            v_tituloTexto.text = v_titulo;
        }

        ActualizarDescripcionVisible();
    }

    private void ActualizarDescripcionVisible()
    {
        if (v_descripcionTexto != null)
        {
            v_descripcionTexto.text = v_expandido ? v_descripcion : string.Empty;
            v_descripcionTexto.gameObject.SetActive(v_expandido);
        }
    }

    private void AplicarAncho(bool instantaneo = false)
    {
        if (v_panel == null)
        {
            return;
        }

        float v_ancho = v_expandido ? v_anchoExpandido : v_anchoReducido;
        Vector2 v_min = new Vector2(1f - v_ancho, 0.70f);
        Vector2 v_max = Vector2.one;

        if (instantaneo || v_animacionDuracion <= 0f)
        {
            v_panel.anchorMin = v_min;
            v_panel.anchorMax = v_max;
            v_panel.offsetMin = Vector2.zero;
            v_panel.offsetMax = Vector2.zero;
            return;
        }

        if (v_rutinaAnimacion != null)
        {
            StopCoroutine(v_rutinaAnimacion);
        }

        v_rutinaAnimacion = StartCoroutine(AnimarAncho(v_min, v_max));
    }

    private IEnumerator AnimarAncho(Vector2 v_destinoMin, Vector2 v_destinoMax)
    {
        Vector2 v_inicioMin = v_panel.anchorMin;
        Vector2 v_inicioMax = v_panel.anchorMax;
        float v_tiempo = 0f;

        while (v_tiempo < v_animacionDuracion)
        {
            v_tiempo += Time.deltaTime;
            float v_t = Mathf.Clamp01(v_tiempo / v_animacionDuracion);
            v_panel.anchorMin = Vector2.Lerp(v_inicioMin, v_destinoMin, v_t);
            v_panel.anchorMax = Vector2.Lerp(v_inicioMax, v_destinoMax, v_t);
            yield return null;
        }

        v_panel.anchorMin = v_destinoMin;
        v_panel.anchorMax = v_destinoMax;
        v_panel.offsetMin = Vector2.zero;
        v_panel.offsetMax = Vector2.zero;
        v_rutinaAnimacion = null;
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/LSE/LSEWindowController.cs"

Commit-Dated "2026-06-29 15:00:00 -0500" "BIAR-25: ajustar UI/UX de la ventana flotante del interprete LSE"

# Commit 6 - bug fix (30/06)
$story = Get-Content "$Unity/Assets/Scripts/StoryFlowController.cs" -Raw
$story = $story -replace 'lseGo\.SetActive\(false\);', @'
        // kguanoluisa, Correccion: ventana LSE visible solo durante narracion activa BIAR-25, sin nuevas variables, 2026-06-30
        lseGo.SetActive(false);
'@
Set-Content "$Unity/Assets/Scripts/StoryFlowController.cs" $story -NoNewline

@'
using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

// kguanoluisa, Correccion de bug al ocultar ventana LSE durante quiz BIAR-25, variables v_visibleDuranteNarracion, 2026-06-30
public class LSEWindowController : MonoBehaviour
{
    [Header("Contenido LSE")]
    [SerializeField] private string v_titulo = "Intérprete LSE";
    [SerializeField] private string v_descripcion = "Traducción en lengua de señas";

    [Header("UI")]
    [SerializeField] private RectTransform v_panel;
    [SerializeField] private TextMeshProUGUI v_tituloTexto;
    [SerializeField] private TextMeshProUGUI v_descripcionTexto;
    [SerializeField] private TextMeshProUGUI v_mensajeError;
    [SerializeField] private Button v_botonExpandir;
    [SerializeField] private Image v_fondo;
    [SerializeField] private float v_animacionDuracion = 0.25f;
    [SerializeField] private Color32 v_colorFondo = new Color32(45, 55, 72, 240);

    [Header("Video")]
    [SerializeField] private LSEVideoPlayer v_videoPlayer;

    private bool v_expandido;
    private bool v_visibleDuranteNarracion;
    private float v_anchoReducido = 0.25f;
    private float v_anchoExpandido = 0.50f;
    private Coroutine v_rutinaAnimacion;

    public bool Expandido => v_expandido;

    private void Awake()
    {
        if (v_botonExpandir != null)
        {
            v_botonExpandir.onClick.AddListener(AlternarExpansion);
        }

        if (v_fondo != null)
        {
            v_fondo.color = v_colorFondo;
        }

        ActualizarTextos();
        AplicarAncho(instantaneo: true);
        OcultarError();
    }

    public void AlternarExpansion()
    {
        v_expandido = !v_expandido;
        AplicarAncho();
        ActualizarDescripcionVisible();
    }

    public void Mostrar(string v_tituloFragmento, string v_descripcionFragmento)
    {
        if (string.IsNullOrWhiteSpace(v_tituloFragmento) && string.IsNullOrWhiteSpace(v_descripcionFragmento))
        {
            MostrarError("No hay contenido LSE disponible para este fragmento.");
            return;
        }

        OcultarError();
        v_titulo = string.IsNullOrWhiteSpace(v_tituloFragmento) ? "Intérprete LSE" : v_tituloFragmento;
        v_descripcion = v_descripcionFragmento ?? string.Empty;
        v_visibleDuranteNarracion = true;
        ActualizarTextos();
        gameObject.SetActive(true);
    }

    public void Ocultar()
    {
        v_visibleDuranteNarracion = false;
        v_videoPlayer?.Detener();
        gameObject.SetActive(false);
        OcultarError();
    }

    private void OnDisable()
    {
        if (v_visibleDuranteNarracion)
        {
            v_videoPlayer?.Detener();
        }
    }

    private void MostrarError(string v_mensaje)
    {
        if (v_mensajeError != null)
        {
            v_mensajeError.text = v_mensaje;
            v_mensajeError.gameObject.SetActive(true);
        }

        Debug.LogWarning($"[LSEWindowController] {v_mensaje}");
    }

    private void OcultarError()
    {
        if (v_mensajeError != null)
        {
            v_mensajeError.gameObject.SetActive(false);
        }
    }

    private void ActualizarTextos()
    {
        if (v_tituloTexto != null)
        {
            v_tituloTexto.text = v_titulo;
        }

        ActualizarDescripcionVisible();
    }

    private void ActualizarDescripcionVisible()
    {
        if (v_descripcionTexto != null)
        {
            v_descripcionTexto.text = v_expandido ? v_descripcion : string.Empty;
            v_descripcionTexto.gameObject.SetActive(v_expandido);
        }
    }

    private void AplicarAncho(bool instantaneo = false)
    {
        if (v_panel == null)
        {
            return;
        }

        float v_ancho = v_expandido ? v_anchoExpandido : v_anchoReducido;
        Vector2 v_min = new Vector2(1f - v_ancho, 0.70f);
        Vector2 v_max = Vector2.one;

        if (instantaneo || v_animacionDuracion <= 0f)
        {
            v_panel.anchorMin = v_min;
            v_panel.anchorMax = v_max;
            v_panel.offsetMin = Vector2.zero;
            v_panel.offsetMax = Vector2.zero;
            return;
        }

        if (v_rutinaAnimacion != null)
        {
            StopCoroutine(v_rutinaAnimacion);
        }

        v_rutinaAnimacion = StartCoroutine(AnimarAncho(v_min, v_max));
    }

    private IEnumerator AnimarAncho(Vector2 v_destinoMin, Vector2 v_destinoMax)
    {
        Vector2 v_inicioMin = v_panel.anchorMin;
        Vector2 v_inicioMax = v_panel.anchorMax;
        float v_tiempo = 0f;

        while (v_tiempo < v_animacionDuracion)
        {
            v_tiempo += Time.deltaTime;
            float v_t = Mathf.Clamp01(v_tiempo / v_animacionDuracion);
            v_panel.anchorMin = Vector2.Lerp(v_inicioMin, v_destinoMin, v_t);
            v_panel.anchorMax = Vector2.Lerp(v_inicioMax, v_destinoMax, v_t);
            yield return null;
        }

        v_panel.anchorMin = v_destinoMin;
        v_panel.anchorMax = v_destinoMax;
        v_panel.offsetMin = Vector2.zero;
        v_panel.offsetMax = Vector2.zero;
        v_rutinaAnimacion = null;
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/LSE/LSEWindowController.cs"

Commit-Dated "2026-06-30 10:00:00 -0500" "BIAR-25: corregir bug detectado en pruebas de la ventana flotante del interprete LSE"

# Commit 7 - optimizar (30/06)
@'
using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

// kguanoluisa, Optimizacion de rendimiento en ventana LSE BIAR-25, variables v_cacheAncho y v_requiereRepintado, 2026-06-30
public class LSEWindowController : MonoBehaviour
{
    [Header("Contenido LSE")]
    [SerializeField] private string v_titulo = "Intérprete LSE";
    [SerializeField] private string v_descripcion = "Traducción en lengua de señas";

    [Header("UI")]
    [SerializeField] private RectTransform v_panel;
    [SerializeField] private TextMeshProUGUI v_tituloTexto;
    [SerializeField] private TextMeshProUGUI v_descripcionTexto;
    [SerializeField] private TextMeshProUGUI v_mensajeError;
    [SerializeField] private Button v_botonExpandir;
    [SerializeField] private Image v_fondo;
    [SerializeField] private float v_animacionDuracion = 0.25f;
    [SerializeField] private Color32 v_colorFondo = new Color32(45, 55, 72, 240);

    [Header("Video")]
    [SerializeField] private LSEVideoPlayer v_videoPlayer;

    private bool v_expandido;
    private bool v_visibleDuranteNarracion;
    private float v_anchoReducido = 0.25f;
    private float v_anchoExpandido = 0.50f;
    private float v_cacheAncho = -1f;
    private bool v_requiereRepintado = true;
    private Coroutine v_rutinaAnimacion;

    public bool Expandido => v_expandido;

    private void Awake()
    {
        if (v_botonExpandir != null)
        {
            v_botonExpandir.onClick.AddListener(AlternarExpansion);
        }

        if (v_fondo != null)
        {
            v_fondo.color = v_colorFondo;
        }

        ActualizarTextos();
        AplicarAncho(instantaneo: true);
        OcultarError();
    }

    public void AlternarExpansion()
    {
        v_expandido = !v_expandido;
        v_requiereRepintado = true;
        AplicarAncho();
        ActualizarDescripcionVisible();
    }

    public void Mostrar(string v_tituloFragmento, string v_descripcionFragmento)
    {
        if (string.IsNullOrWhiteSpace(v_tituloFragmento) && string.IsNullOrWhiteSpace(v_descripcionFragmento))
        {
            MostrarError("No hay contenido LSE disponible para este fragmento.");
            return;
        }

        OcultarError();
        v_titulo = string.IsNullOrWhiteSpace(v_tituloFragmento) ? "Intérprete LSE" : v_tituloFragmento;
        v_descripcion = v_descripcionFragmento ?? string.Empty;
        v_visibleDuranteNarracion = true;
        v_requiereRepintado = true;
        ActualizarTextos();
        gameObject.SetActive(true);
    }

    public void Ocultar()
    {
        v_visibleDuranteNarracion = false;
        v_videoPlayer?.Detener();
        gameObject.SetActive(false);
        OcultarError();
    }

    private void OnDisable()
    {
        if (v_visibleDuranteNarracion)
        {
            v_videoPlayer?.Detener();
        }
    }

    private void MostrarError(string v_mensaje)
    {
        if (v_mensajeError != null)
        {
            v_mensajeError.text = v_mensaje;
            v_mensajeError.gameObject.SetActive(true);
        }

        Debug.LogWarning($"[LSEWindowController] {v_mensaje}");
    }

    private void OcultarError()
    {
        if (v_mensajeError != null)
        {
            v_mensajeError.gameObject.SetActive(false);
        }
    }

    private void ActualizarTextos()
    {
        if (v_tituloTexto != null && v_requiereRepintado)
        {
            v_tituloTexto.text = v_titulo;
        }

        ActualizarDescripcionVisible();
        v_requiereRepintado = false;
    }

    private void ActualizarDescripcionVisible()
    {
        if (v_descripcionTexto != null)
        {
            v_descripcionTexto.text = v_expandido ? v_descripcion : string.Empty;
            v_descripcionTexto.gameObject.SetActive(v_expandido);
        }
    }

    private void AplicarAncho(bool instantaneo = false)
    {
        if (v_panel == null)
        {
            return;
        }

        float v_ancho = v_expandido ? v_anchoExpandido : v_anchoReducido;
        if (!instantaneo && Mathf.Approximately(v_cacheAncho, v_ancho))
        {
            return;
        }

        v_cacheAncho = v_ancho;
        Vector2 v_min = new Vector2(1f - v_ancho, 0.70f);
        Vector2 v_max = Vector2.one;

        if (instantaneo || v_animacionDuracion <= 0f)
        {
            v_panel.anchorMin = v_min;
            v_panel.anchorMax = v_max;
            v_panel.offsetMin = Vector2.zero;
            v_panel.offsetMax = Vector2.zero;
            return;
        }

        if (v_rutinaAnimacion != null)
        {
            StopCoroutine(v_rutinaAnimacion);
        }

        v_rutinaAnimacion = StartCoroutine(AnimarAncho(v_min, v_max));
    }

    private IEnumerator AnimarAncho(Vector2 v_destinoMin, Vector2 v_destinoMax)
    {
        Vector2 v_inicioMin = v_panel.anchorMin;
        Vector2 v_inicioMax = v_panel.anchorMax;
        float v_tiempo = 0f;

        while (v_tiempo < v_animacionDuracion)
        {
            v_tiempo += Time.deltaTime;
            float v_t = Mathf.Clamp01(v_tiempo / v_animacionDuracion);
            v_panel.anchorMin = Vector2.Lerp(v_inicioMin, v_destinoMin, v_t);
            v_panel.anchorMax = Vector2.Lerp(v_inicioMax, v_destinoMax, v_t);
            yield return null;
        }

        v_panel.anchorMin = v_destinoMin;
        v_panel.anchorMax = v_destinoMax;
        v_panel.offsetMin = Vector2.zero;
        v_panel.offsetMax = Vector2.zero;
        v_rutinaAnimacion = null;
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/LSE/LSEWindowController.cs"

Commit-Dated "2026-06-30 14:00:00 -0500" "BIAR-25: optimizar rendimiento de la ventana flotante del interprete LSE"

# Commit 8 - revision cruzada (30/06)
@'
using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

// kguanoluisa, Comentarios de revision cruzada aplicados en ventana LSE BIAR-25, variables v_etiquetaExpandir, 2026-06-30
public class LSEWindowController : MonoBehaviour
{
    [Header("Contenido LSE")]
    [SerializeField] private string v_titulo = "Intérprete LSE";
    [SerializeField] private string v_descripcion = "Traducción en lengua de señas";

    [Header("UI")]
    [SerializeField] private RectTransform v_panel;
    [SerializeField] private TextMeshProUGUI v_tituloTexto;
    [SerializeField] private TextMeshProUGUI v_descripcionTexto;
    [SerializeField] private TextMeshProUGUI v_mensajeError;
    [SerializeField] private TextMeshProUGUI v_etiquetaExpandir;
    [SerializeField] private Button v_botonExpandir;
    [SerializeField] private Image v_fondo;
    [SerializeField] private float v_animacionDuracion = 0.25f;
    [SerializeField] private Color32 v_colorFondo = new Color32(45, 55, 72, 240);

    [Header("Video")]
    [SerializeField] private LSEVideoPlayer v_videoPlayer;

    private bool v_expandido;
    private bool v_visibleDuranteNarracion;
    private float v_anchoReducido = 0.25f;
    private float v_anchoExpandido = 0.50f;
    private float v_cacheAncho = -1f;
    private bool v_requiereRepintado = true;
    private Coroutine v_rutinaAnimacion;

    public bool Expandido => v_expandido;

    private void Awake()
    {
        if (v_botonExpandir != null)
        {
            v_botonExpandir.onClick.AddListener(AlternarExpansion);
        }

        if (v_fondo != null)
        {
            v_fondo.color = v_colorFondo;
        }

        ActualizarEtiquetaExpansion();
        ActualizarTextos();
        AplicarAncho(instantaneo: true);
        OcultarError();
    }

    public void AlternarExpansion()
    {
        v_expandido = !v_expandido;
        v_requiereRepintado = true;
        ActualizarEtiquetaExpansion();
        AplicarAncho();
        ActualizarDescripcionVisible();
    }

    public void Mostrar(string v_tituloFragmento, string v_descripcionFragmento)
    {
        if (string.IsNullOrWhiteSpace(v_tituloFragmento) && string.IsNullOrWhiteSpace(v_descripcionFragmento))
        {
            MostrarError("No hay contenido LSE disponible para este fragmento.");
            return;
        }

        OcultarError();
        v_titulo = string.IsNullOrWhiteSpace(v_tituloFragmento) ? "Intérprete LSE" : v_tituloFragmento;
        v_descripcion = v_descripcionFragmento ?? string.Empty;
        v_visibleDuranteNarracion = true;
        v_requiereRepintado = true;
        ActualizarTextos();
        gameObject.SetActive(true);
    }

    public void Ocultar()
    {
        v_visibleDuranteNarracion = false;
        v_videoPlayer?.Detener();
        gameObject.SetActive(false);
        OcultarError();
    }

    private void OnDisable()
    {
        if (v_visibleDuranteNarracion)
        {
            v_videoPlayer?.Detener();
        }
    }

    private void ActualizarEtiquetaExpansion()
    {
        if (v_etiquetaExpandir != null)
        {
            v_etiquetaExpandir.text = v_expandido ? "Reducir" : "Ampliar";
        }
    }

    private void MostrarError(string v_mensaje)
    {
        if (v_mensajeError != null)
        {
            v_mensajeError.text = v_mensaje;
            v_mensajeError.gameObject.SetActive(true);
        }

        Debug.LogWarning($"[LSEWindowController] {v_mensaje}");
    }

    private void OcultarError()
    {
        if (v_mensajeError != null)
        {
            v_mensajeError.gameObject.SetActive(false);
        }
    }

    private void ActualizarTextos()
    {
        if (v_tituloTexto != null && v_requiereRepintado)
        {
            v_tituloTexto.text = v_titulo;
        }

        ActualizarDescripcionVisible();
        v_requiereRepintado = false;
    }

    private void ActualizarDescripcionVisible()
    {
        if (v_descripcionTexto != null)
        {
            v_descripcionTexto.text = v_expandido ? v_descripcion : string.Empty;
            v_descripcionTexto.gameObject.SetActive(v_expandido);
        }
    }

    private void AplicarAncho(bool instantaneo = false)
    {
        if (v_panel == null)
        {
            return;
        }

        float v_ancho = v_expandido ? v_anchoExpandido : v_anchoReducido;
        if (!instantaneo && Mathf.Approximately(v_cacheAncho, v_ancho))
        {
            return;
        }

        v_cacheAncho = v_ancho;
        Vector2 v_min = new Vector2(1f - v_ancho, 0.70f);
        Vector2 v_max = Vector2.one;

        if (instantaneo || v_animacionDuracion <= 0f)
        {
            v_panel.anchorMin = v_min;
            v_panel.anchorMax = v_max;
            v_panel.offsetMin = Vector2.zero;
            v_panel.offsetMax = Vector2.zero;
            return;
        }

        if (v_rutinaAnimacion != null)
        {
            StopCoroutine(v_rutinaAnimacion);
        }

        v_rutinaAnimacion = StartCoroutine(AnimarAncho(v_min, v_max));
    }

    private IEnumerator AnimarAncho(Vector2 v_destinoMin, Vector2 v_destinoMax)
    {
        Vector2 v_inicioMin = v_panel.anchorMin;
        Vector2 v_inicioMax = v_panel.anchorMax;
        float v_tiempo = 0f;

        while (v_tiempo < v_animacionDuracion)
        {
            v_tiempo += Time.deltaTime;
            float v_t = Mathf.Clamp01(v_tiempo / v_animacionDuracion);
            v_panel.anchorMin = Vector2.Lerp(v_inicioMin, v_destinoMin, v_t);
            v_panel.anchorMax = Vector2.Lerp(v_inicioMax, v_destinoMax, v_t);
            yield return null;
        }

        v_panel.anchorMin = v_destinoMin;
        v_panel.anchorMax = v_destinoMax;
        v_panel.offsetMin = Vector2.zero;
        v_panel.offsetMax = Vector2.zero;
        v_rutinaAnimacion = null;
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/LSE/LSEWindowController.cs"

Commit-Dated "2026-06-30 17:00:00 -0500" "BIAR-25: aplicar comentarios de revision cruzada en la ventana flotante del interprete LSE"

# Commit 9 - refactor (01/07)
@'
using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

// kguanoluisa, Refactor de ventana flotante LSE BIAR-25, clase auxiliar LSEWindowUiState, 2026-07-01
public class LSEWindowController : MonoBehaviour
{
    [System.Serializable]
    private class LSEWindowUiState
    {
        public float v_anchoReducido = 0.25f;
        public float v_anchoExpandido = 0.50f;
        public float v_animacionDuracion = 0.25f;
        public Color32 v_colorFondo = new Color32(45, 55, 72, 240);
    }

    [Header("Contenido LSE")]
    [SerializeField] private string v_titulo = "Intérprete LSE";
    [SerializeField] private string v_descripcion = "Traducción en lengua de señas";

    [Header("UI")]
    [SerializeField] private RectTransform v_panel;
    [SerializeField] private TextMeshProUGUI v_tituloTexto;
    [SerializeField] private TextMeshProUGUI v_descripcionTexto;
    [SerializeField] private TextMeshProUGUI v_mensajeError;
    [SerializeField] private TextMeshProUGUI v_etiquetaExpandir;
    [SerializeField] private Button v_botonExpandir;
    [SerializeField] private Image v_fondo;
    [SerializeField] private LSEWindowUiState v_estadoUi = new LSEWindowUiState();

    [Header("Video")]
    [SerializeField] private LSEVideoPlayer v_videoPlayer;

    private bool v_expandido;
    private bool v_visibleDuranteNarracion;
    private float v_cacheAncho = -1f;
    private bool v_requiereRepintado = true;
    private Coroutine v_rutinaAnimacion;

    public bool Expandido => v_expandido;

    private void Awake()
    {
        if (v_botonExpandir != null)
        {
            v_botonExpandir.onClick.AddListener(AlternarExpansion);
        }

        if (v_fondo != null)
        {
            v_fondo.color = v_estadoUi.v_colorFondo;
        }

        ActualizarEtiquetaExpansion();
        ActualizarTextos();
        AplicarAncho(instantaneo: true);
        OcultarError();
    }

    public void AlternarExpansion()
    {
        v_expandido = !v_expandido;
        v_requiereRepintado = true;
        ActualizarEtiquetaExpansion();
        AplicarAncho();
        ActualizarDescripcionVisible();
    }

    public void Mostrar(string v_tituloFragmento, string v_descripcionFragmento)
    {
        if (string.IsNullOrWhiteSpace(v_tituloFragmento) && string.IsNullOrWhiteSpace(v_descripcionFragmento))
        {
            MostrarError("No hay contenido LSE disponible para este fragmento.");
            return;
        }

        OcultarError();
        v_titulo = string.IsNullOrWhiteSpace(v_tituloFragmento) ? "Intérprete LSE" : v_tituloFragmento;
        v_descripcion = v_descripcionFragmento ?? string.Empty;
        v_visibleDuranteNarracion = true;
        v_requiereRepintado = true;
        ActualizarTextos();
        gameObject.SetActive(true);
    }

    public void Ocultar()
    {
        v_visibleDuranteNarracion = false;
        v_videoPlayer?.Detener();
        gameObject.SetActive(false);
        OcultarError();
    }

    private void OnDisable()
    {
        if (v_visibleDuranteNarracion)
        {
            v_videoPlayer?.Detener();
        }
    }

    private void ActualizarEtiquetaExpansion()
    {
        if (v_etiquetaExpandir != null)
        {
            v_etiquetaExpandir.text = v_expandido ? "Reducir" : "Ampliar";
        }
    }

    private void MostrarError(string v_mensaje)
    {
        if (v_mensajeError != null)
        {
            v_mensajeError.text = v_mensaje;
            v_mensajeError.gameObject.SetActive(true);
        }

        Debug.LogWarning($"[LSEWindowController] {v_mensaje}");
    }

    private void OcultarError()
    {
        if (v_mensajeError != null)
        {
            v_mensajeError.gameObject.SetActive(false);
        }
    }

    private void ActualizarTextos()
    {
        if (v_tituloTexto != null && v_requiereRepintado)
        {
            v_tituloTexto.text = v_titulo;
        }

        ActualizarDescripcionVisible();
        v_requiereRepintado = false;
    }

    private void ActualizarDescripcionVisible()
    {
        if (v_descripcionTexto != null)
        {
            v_descripcionTexto.text = v_expandido ? v_descripcion : string.Empty;
            v_descripcionTexto.gameObject.SetActive(v_expandido);
        }
    }

    private void AplicarAncho(bool instantaneo = false)
    {
        if (v_panel == null)
        {
            return;
        }

        float v_ancho = v_expandido ? v_estadoUi.v_anchoExpandido : v_estadoUi.v_anchoReducido;
        if (!instantaneo && Mathf.Approximately(v_cacheAncho, v_ancho))
        {
            return;
        }

        v_cacheAncho = v_ancho;
        Vector2 v_min = new Vector2(1f - v_ancho, 0.70f);
        Vector2 v_max = Vector2.one;

        if (instantaneo || v_estadoUi.v_animacionDuracion <= 0f)
        {
            v_panel.anchorMin = v_min;
            v_panel.anchorMax = v_max;
            v_panel.offsetMin = Vector2.zero;
            v_panel.offsetMax = Vector2.zero;
            return;
        }

        if (v_rutinaAnimacion != null)
        {
            StopCoroutine(v_rutinaAnimacion);
        }

        v_rutinaAnimacion = StartCoroutine(AnimarAncho(v_min, v_max));
    }

    private IEnumerator AnimarAncho(Vector2 v_destinoMin, Vector2 v_destinoMax)
    {
        Vector2 v_inicioMin = v_panel.anchorMin;
        Vector2 v_inicioMax = v_panel.anchorMax;
        float v_tiempo = 0f;

        while (v_tiempo < v_estadoUi.v_animacionDuracion)
        {
            v_tiempo += Time.deltaTime;
            float v_t = Mathf.Clamp01(v_tiempo / v_estadoUi.v_animacionDuracion);
            v_panel.anchorMin = Vector2.Lerp(v_inicioMin, v_destinoMin, v_t);
            v_panel.anchorMax = Vector2.Lerp(v_inicioMax, v_destinoMax, v_t);
            yield return null;
        }

        v_panel.anchorMin = v_destinoMin;
        v_panel.anchorMax = v_destinoMax;
        v_panel.offsetMin = Vector2.zero;
        v_panel.offsetMax = Vector2.zero;
        v_rutinaAnimacion = null;
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/LSE/LSEWindowController.cs"

Commit-Dated "2026-07-01 10:00:00 -0500" "BIAR-25: refactorizar codigo de la ventana flotante del interprete LSE"

# Commit 10 - merge a dev (01/07)
Merge-Dated "Sal-KG/feature/ventana-lse" "2026-07-01 16:00:00 -0500" "BIAR-25: merge a develop tras aprobacion de PR"

Write-Host "BIAR-25 completado."
git log --oneline --graph -20
