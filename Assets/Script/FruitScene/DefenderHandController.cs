using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// Defines Hand Prefab's list of actions as a Defender
public class DefenderHandController : MonoBehaviour
{
    private string playerIdentity;
    private Animator animator;
    private bool animationOngoing;


    private const float slowScale = 0f;
    private const float duration = 6f;


    // Start is called before the first frame update
    void Start()
    {
        playerIdentity = PlayerStatusManager.Instance.GetIdentity();
        if (playerIdentity != "Defender")
        {
            this.enabled = false;
            return;
        }
        animator = GetComponent<Animator>();
        animationOngoing = false;
    }

    public void ApplyFreezeSkill()
    {
        // avoid calling multiple times when last run isn't done
        if (animationOngoing)
        {
            return;
        }
        animationOngoing = true;
        animator.SetBool("isFreezeSkill", true);
        StartCoroutine(SlowMotion());
    }

    // freeze existing prefabs and pause spawning for a set time period
    private System.Collections.IEnumerator SlowMotion()
    {
        Dictionary<Rigidbody, Vector3> storedVelocities = new Dictionary<Rigidbody, Vector3>();
        Dictionary<Rigidbody, Vector3> storedAngularVelocities = new Dictionary<Rigidbody, Vector3>();
        GameObject[] fruits = GameObject.FindGameObjectsWithTag("Safe Object");
        GameObject[] bombs = GameObject.FindGameObjectsWithTag("Pickable");

        foreach (GameObject fruit in fruits)
        {
            Rigidbody rb = fruit.GetComponent<Rigidbody>();

            if (rb != null)
            {
                // Store current motion
                storedVelocities[rb] = rb.velocity;
                storedAngularVelocities[rb] = rb.angularVelocity;

                // Freeze movement
                rb.velocity = Vector3.zero;
                rb.angularVelocity = Vector3.zero;
                rb.constraints = RigidbodyConstraints.FreezeAll;
            }
        }
        foreach (GameObject bomb in bombs)
        {
            Rigidbody rb = bomb.GetComponent<Rigidbody>();

            if (rb != null)
            {
                // Store current motion
                storedVelocities[rb] = rb.velocity;
                storedAngularVelocities[rb] = rb.angularVelocity;

                // Freeze movement
                rb.velocity = Vector3.zero;
                rb.angularVelocity = Vector3.zero;
                rb.constraints = RigidbodyConstraints.FreezeAll;
            }
        }

        FruitSpawn spawn = GameObject.Find("SpawnFruit").GetComponent<FruitSpawn>();
        spawn.SetFrozen(true);

        yield return new WaitForSecondsRealtime(duration);

        foreach (var pair in storedVelocities)
        {
            Rigidbody rb = pair.Key;

            if (rb != null)
            {
                rb.constraints = RigidbodyConstraints.None;
                rb.velocity = pair.Value;
                rb.angularVelocity = storedAngularVelocities[rb];
            }
        }

        spawn.SetFrozen(false);

        animator.SetBool("isFreezeSkill", false);
        animationOngoing = false;
    }
}
