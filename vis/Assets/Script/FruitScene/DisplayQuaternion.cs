using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class DisplayQuaternion : MonoBehaviour
{
    [SerializeField] private GameObject katana;
    private TextMeshProUGUI tmpText;
    private Quaternion toDisplay;
    // Start is called before the first frame update
    void Start()
    {
        tmpText = GetComponent<TextMeshProUGUI>();
        katana = GameObject.Find("Katana");
    }

    // Update is called once per frame
    void Update()
    {
        if (katana != null)
        {
            toDisplay = katana.transform.rotation;
            tmpText.text = $"({toDisplay.x:F3}, {toDisplay.y:F3}, {toDisplay.z:F3}, {toDisplay.w:F3})";
        }
        else
        {
            tmpText.text = "Object not found";
        }
    }
}
