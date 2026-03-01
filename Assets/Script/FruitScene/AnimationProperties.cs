using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationProperties : MonoBehaviour
{
    private Animator animator;

    void Awake()
    {
        animator = GetComponent<Animator>();
    }

    void Start()
    {
        animator.speed = 3.5f;
    }

    public void OnAnimationFinished()
    {
        Destroy(gameObject);
    }
}
