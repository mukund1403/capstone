using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimulatedIMU : MonoBehaviour, IIMUSource
{
    public float rotationSpeed = 30f;
    public Quaternion GetOrientation()
    {
        float yaw = Time.time * rotationSpeed;
        float pitch = Mathf.Sin(Time.time) * 30f;
        float roll = Mathf.Cos(Time.time) * 20f;
        return Quaternion.Euler(pitch, yaw, roll);
    }
}
