using System.Collections;
using System.Collections.Generic;
using Unity.XR.CoreUtils;
using UnityEngine;
using TMPro;

public class CollideManager : MonoBehaviour
{
    [SerializeField] private GameObject splashPrefab;
    [SerializeField] private GameObject wrongSignPrefab;
    [SerializeField] private GameObject triPrefab;
    [SerializeField] private GameObject rectPrefab;
    [SerializeField] private GameObject cirPrefab;
    private GameLogic logic;
    private GestureListener gestureListener;

    private GameObject splash;
    private GameObject wrongMark;
    private GameObject triangle;
    private GameObject rectangle;
    private GameObject circle;

    void Start()
    {
        logic = GameObject.Find("GameLogic").GetComponent<GameLogic>();
        //gestureListener = FindObjectOfType<GestureListener>();
    }

    public void AddSpecialAnimation(string type, Vector3 pos)
    {
        Vector3 offset = Camera.main.transform.forward * 0.02f;
        if (type == "wrong")
        {
            wrongMark = Instantiate(wrongSignPrefab, pos - offset, Quaternion.identity);
        }
        else if (type == "triangle")
        {
            triangle = Instantiate(triPrefab, pos - offset, Quaternion.identity);
        }
        else if (type == "rectangle")
        {
            rectangle = Instantiate(rectPrefab, pos - offset, Quaternion.identity);
        }
        else if (type == "circle")
        {
            circle = Instantiate(cirPrefab, pos - offset, Quaternion.identity);
        }
    }

    public void OnCollisionEnter(Collision collision)
    {
        MqttPubTest();
        if (collision.gameObject.CompareTag("Safe Object"))
        {
            Vector3 hitPos = collision.transform.position;

            Transform circle = collision.transform.Find("circleSprite");
            Transform triangle = collision.transform.Find("triSprite");
            Transform rectangle = collision.transform.Find("rectSprite");

            splash = Instantiate(splashPrefab, hitPos, Quaternion.identity);

            if (circle != null)
            {
                string gestureDetected = Random.value < 0.5f ? "circle" : "none";
                if (gestureDetected == "circle")
                {
                    AddSpecialAnimation("circle", hitPos);
                }
                else
                {
                    AddSpecialAnimation("wrong", hitPos);
                    logic.DeductScore();
                }
            }
            else if (triangle != null)
            {
                string gestureDetected = Random.value < 0.5f ? "triangle" : "none";
                if (gestureDetected == "triangle")
                {
                    AddSpecialAnimation("triangle", hitPos);
                }
                else
                {
                    AddSpecialAnimation("wrong", hitPos);
                    logic.DeductScore();
                }
            }
            else if (rectangle != null)
            {
                string gestureDetected = Random.value < 0.5f ? "rectangle" : "none";
                if (gestureDetected == "rectangle")
                {
                    AddSpecialAnimation("rectangle", hitPos);
                }
                else
                {
                    AddSpecialAnimation("wrong", hitPos);
                    logic.DeductScore();
                }
            }

            logic.AddScore();
            Destroy(collision.gameObject);
        }
        else
        {
            logic.GameOver();
        }
    }
    private void MqttPubTest()
    {
        MqttApi.BuzzSuccess();
        MqttApi.SliceCollisionDetected();
    }
}
