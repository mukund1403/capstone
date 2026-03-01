using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AttackerHandController : MonoBehaviour
{
    private Transform holdPoint;
    private Animator animator;
    private string playerIdentity;

    public GameObject heldObject;
    public bool canHold;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
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
        if (!canHold)
        {
            return;
        }

        if (collision.gameObject.CompareTag("Pickable"))
        {
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
        rb.AddForce(transform.forward * force, ForceMode.Impulse);
        rb.AddTorque(Random.insideUnitSphere * spinForce, ForceMode.Impulse);
    }

    IEnumerator WaitTwoSeconds()
    {
        yield return new WaitForSeconds(2);
        canHold = true;
    }

    public void Release()
    {
        if (heldObject == null)
        {
            return;
        }

        heldObject.transform.SetParent(null);

        Rigidbody rb = heldObject.GetComponent<Rigidbody>();
        applyPhysics(rb);

        heldObject = null;

        animator.SetBool("isHolding", false);
        StartCoroutine(WaitTwoSeconds());
    }
}
