using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SplashSpriteController : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        Destroy(gameObject, 5.0f);
    }

    private void EditColour(float rValue, float gValue, float bValue, float aValue)
    {
        SpriteRenderer sr = GetComponent<SpriteRenderer>();
    }
}
