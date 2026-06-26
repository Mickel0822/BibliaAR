using UnityEngine;

// kguanoluisa, Estructura base de la ventana flotante LSE BIAR-25, variables v_expandido y v_titulo, 2026-06-26
public class LSEWindowController : MonoBehaviour
{
    [SerializeField] private string v_titulo = "Intérprete LSE";
    [SerializeField] private bool v_expandido;

    public bool Expandido => v_expandido;
    public string Titulo => v_titulo;
}
