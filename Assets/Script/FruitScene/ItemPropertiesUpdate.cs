using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemPropertiesUpdate : MonoBehaviour
{
    private float deadzone = 15;

    // Update is called once per frame
    void Update()
    {
        if (Mathf.Abs(transform.position.x) > deadzone ||
            Mathf.Abs(transform.position.y) > deadzone ||
            Mathf.Abs(transform.position.z) > deadzone)
        {
            Destroy(gameObject);
        }
    }
}
