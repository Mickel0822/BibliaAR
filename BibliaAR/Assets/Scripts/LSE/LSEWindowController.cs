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
