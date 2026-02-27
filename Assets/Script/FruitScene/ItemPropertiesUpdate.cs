using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemPropertiesUpdate : MonoBehaviour
{
    private float deadzone = -50;

    // Update is called once per frame
    void Update()
    {
        if (transform.position.y < deadzone)
        {
            Destroy(gameObject);
        }
    }
}
