using System.Collections;
using System.Collections.Generic;
using Unity.XR.CoreUtils;
using UnityEngine;
using TMPro;

public class CollideManager : MonoBehaviour
{
    [SerializeField] private GameObject splashPrefab;
    [SerializeField] private GameObject wrongSignPrefab;
    private GameLogic logic;
    private GestureListener gestureListener;

    private GameObject splash;
    private GameObject wrongMark;

    void Start()
    {
        logic = GameObject.Find("GameLogic").GetComponent<GameLogic>();
        gestureListener = GameObject.Find("GestureListener").GetComponent<GestureListener>();
    }

    public void AddSpecialAnimation(string type, Vector3 pos)
    {
        Vector3 offset = Camera.main.transform.forward * 0.02f;
        if (type == "wrong")
        {
            wrongMark = Instantiate(wrongSignPrefab, pos + offset, Quaternion.identity);
        }
    }

    public void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Safe Object"))
        {
            Vector3 hitPos = collision.transform.position;

            Transform circle = collision.transform.Find("circleSprite");
            Transform triangle = collision.transform.Find("triSprite");
            Transform rectangle = collision.transform.Find("rectSprite");
            if (circle != null)
            {
                string gestureDetected = gestureListener.tempGestureInput("circle");
                if (gestureDetected == "circle")
                {
                    splash = Instantiate(splashPrefab, hitPos, Quaternion.identity);
                }
                else
                {
                    AddSpecialAnimation("wrong", hitPos);
                    logic.DeductScore();
                }
            }
            else if (triangle != null)
            {
                string gestureDetected = gestureListener.tempGestureInput("circle");
                if (gestureDetected == "triangle")
                {
                }
                else
                {
                    AddSpecialAnimation("wrong", hitPos);
                    logic.DeductScore();
                }
            }
            else if (rectangle != null)
            {
                string gestureDetected = gestureListener.tempGestureInput("circle");
                if (gestureDetected == "rectangle")
                {
                }
                else
                {
                    AddSpecialAnimation("wrong", hitPos);
                    logic.DeductScore();
                }
            }

            logic.AddScore();
            splash = Instantiate(splashPrefab, hitPos, Quaternion.identity);

            Destroy(collision.gameObject);
        }
        else
        {
            logic.GameOver();
        }
    }
}
