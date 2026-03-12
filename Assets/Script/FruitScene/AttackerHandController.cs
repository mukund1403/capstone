using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// Defines Hand Prefab's list of actions as an Attacker
public class AttackerHandController : MonoBehaviour
{
    private Transform holdPoint;
    private Animator animator;
    private string playerIdentity;

    public GameObject heldObject;
    public bool canHold;

    void Start()
    {
        playerIdentity = PlayerStatusManager.Instance.GetIdentity();
        if (playerIdentity != "Attacker")
        {
            this.enabled = false;
            return;
        }
        holdPoint = transform.Find("HoldPoint");
        animator = GetComponent<Animator>();
        canHold = true;
    }

    public void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Pickable"))
        {
            if (!canHold)
            {
                return;
            }

            MqttPubTest();
            Grab(collision.gameObject);
            canHold = false;
        }
    }

    public void Grab(GameObject picked)
    {
        heldObject = picked;

        Rigidbody rb = picked.GetComponent<Rigidbody>();
        rb.isKinematic = true;
        rb.useGravity = false;

        // set picked item's orientation ralative to the holdPoint
        picked.transform.SetParent(holdPoint);
        picked.transform.localPosition = new Vector3(0, -0.065f, 0);
        picked.transform.localRotation = Quaternion.Euler(0, 0, -90);

        animator.SetBool("isHolding", true);
    }

    private void applyPhysics(Rigidbody rb)
    {
        float force = 5;
        rb.isKinematic = false;
        rb.useGravity = true;
        float spinForce = 5;
        rb.AddForce(-holdPoint.up * force, ForceMode.Impulse);
        rb.AddTorque(Random.insideUnitSphere * spinForce, ForceMode.Impulse);
    }

    IEnumerator WaitOneSecond()
    {
        yield return new WaitForSeconds(1);
        canHold = true;
    }

    public void Release()
    {
        if (heldObject == null)
        {
            return;
        }

        // release picked item from hand prefab's holdPoint 
        heldObject.transform.SetParent(null);

        Rigidbody rb = heldObject.GetComponent<Rigidbody>();
        applyPhysics(rb);

        heldObject = null;

        animator.SetBool("isHolding", false);
        // wait for one second to prevent re-grabbing from collision
        StartCoroutine(WaitOneSecond());
    }

    // Simulating topic publishing using MQTT
    private void MqttPubTest()
    {
        MqttApi.PickCollisionDetected();
    }
}
