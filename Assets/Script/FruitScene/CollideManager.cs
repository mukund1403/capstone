using System.Collections;
using System.Collections.Generic;
using Unity.XR.CoreUtils;
using UnityEngine;
using TMPro;

// Manage katana prefab's collision during gameplay
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
        if (collision.gameObject.CompareTag("Safe Object"))
        {
            Vector3 hitPos = collision.transform.position;

            // check if the object collided has special child object
            Transform circle = collision.transform.Find("circleSprite");
            Transform triangle = collision.transform.Find("triSprite");
            Transform rectangle = collision.transform.Find("rectSprite");

            splash = Instantiate(splashPrefab, hitPos, Quaternion.identity);

            string swordGesture = FindObjectOfType<GestureListener>().defSwordGesture;

            if (circle != null)
            {
                // dummy data input simulating AI gesture detection  
                string tempGesture = Random.value < 0.5f ? "circle" : "none";
                string gestureDetected = swordGesture;
                if (gestureDetected == "circle")
                {
                    AddSpecialAnimation("circle", hitPos);
                    MqttApi.BuzzSuccess();
                }
                else
                {
                    AddSpecialAnimation("wrong", hitPos);
                    logic.DeductScore();
                    MqttApi.BuzzFailure();
                }
            }
            else if (triangle != null)
            {
                // dummy data input simulating AI gesture detection 
                string tempGesture = Random.value < 0.5f ? "triangle" : "none";
                string gestureDetected = swordGesture;
                if (gestureDetected == "triangle")
                {
                    AddSpecialAnimation("triangle", hitPos);
                    MqttApi.BuzzSuccess();
                }
                else
                {
                    AddSpecialAnimation("wrong", hitPos);
                    logic.DeductScore();
                    MqttApi.BuzzFailure();
                }
            }
            else if (rectangle != null)
            {
                // dummy data input simulating AI gesture detection 
                string tempGesture = Random.value < 0.5f ? "rectangle" : "none";
                string gestureDetected = swordGesture;
                if (gestureDetected == "rectangle")
                {
                    AddSpecialAnimation("rectangle", hitPos);
                    MqttApi.BuzzSuccess();
                }
                else
                {
                    AddSpecialAnimation("wrong", hitPos);
                    logic.DeductScore();
                    MqttApi.BuzzFailure();
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
}
