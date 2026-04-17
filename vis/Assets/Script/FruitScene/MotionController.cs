using System.Collections;
using System.Collections.Generic;
using Unity.XR.CoreUtils;
using UnityEngine;

public class MotionManager : MonoBehaviour, IIMUSource
{
    [SerializeField] private float speed;
    [SerializeField] private IIMUSource imuSource;

    [SerializeField] private FixedJoystick fixedJoystickL;
    [SerializeField] private FixedJoystick fixedJoystickR;
    private Rigidbody rigidBody;

    public float rotationSpeed = 30f;

    public Quaternion GetOrientation()
    {
        float xValL = fixedJoystickL.Horizontal;
        float yValL = fixedJoystickL.Vertical;
        Quaternion newQ = new Quaternion();
        newQ.Set(yValL, 0, -xValL, 1);
        return newQ;
    }

    private void OnEnable()
    {
        rigidBody = gameObject.GetComponent<Rigidbody>();
    }

    private void FixedUpdate()
    {
        float xValL = fixedJoystickL.Horizontal;
        float yValL = fixedJoystickL.Vertical;
        float xValR = fixedJoystickR.Horizontal;
        float yValR = fixedJoystickR.Vertical;

        Vector3 movement = new Vector3(xValR, 0, yValR);
        rigidBody.velocity = movement * speed;

        transform.rotation = GetOrientation();
    }
}
