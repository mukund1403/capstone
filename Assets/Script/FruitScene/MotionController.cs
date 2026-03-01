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
    //private FixedJoystick fixedJoystickL = GameObject.FindWithTag("Left Stick").getComponent<FixedJoystick>();
    //private FixedJoystick fixedJoystickR = GameObject.FindWithTag("Right Stick").getComponent<FixedJoystick>();
    private Rigidbody rigidBody;

    public float rotationSpeed = 30f;
    //public Quaternion GetOrientation()
    //{
    //    float xValL = fixedJoystick.Horizontal;
    //    float yValL = fixedJoystick.Vertical;
    //    Vector3 movement = new Vector3(xValL, 0, yValL);
    //    return Quaternion.LookRotation(movement, Vector3.up);
    //}

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
        //fixedJoystick = FindAnyObjectByType<FixedJoystick>();
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

        //if (xValL != 0 && yValL != 0)
        //{
        //    transform.eulerAngles = new Vector3(transform.eulerAngles.x, Mathf.Atan2(xValL, yValL) * Mathf.Rad2Deg, transform.eulerAngles.z);
        //}
    }
}
