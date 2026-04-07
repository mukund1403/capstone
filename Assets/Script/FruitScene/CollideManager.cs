using System.Collections;
using System.Collections.Generic;
using Unity.XR.CoreUtils;
using UnityEngine;
using TMPro;
using static GestureListener;

// Manage katana prefab's collision during gameplay
public class CollideManager : MonoBehaviour
{
    [SerializeField] private GameObject splashPrefab;
    [SerializeField] private GameObject wrongSignPrefab;
    [SerializeField] private GameObject zPrefab;
    [SerializeField] private GameObject chkPrefab;
    [SerializeField] private GameObject caretPrefab;
    [SerializeField] private GameObject infPrefab;
    [SerializeField] private GameObject cirPrefab;

    private DialogManager dialogManager;
    private GameLogic logic;
    private GestureListener gestureListener;

    private GameObject splashObj;
    private GameObject wrongMarkObj;
    private GameObject zObj;
    private GameObject chkObj;
    private GameObject caretObj;
    private GameObject infObj;
    private GameObject cirObj;

    private int sliceCount;

    void Start()
    {
        logic = GameObject.Find("GameLogic").GetComponent<GameLogic>();
        dialogManager = FindObjectOfType<DialogManager>();
    }

    private void Awake()
    {
        sliceCount = 0;
    }

    public void AddSpecialAnimation(string type, Vector3 pos)
    {
        if (dialogManager != null && 
           (dialogManager.getCurrentIndex() == 11 || 
           dialogManager.getCurrentIndex() == 12))
        {
            sliceCount++;
            int dialogNum = type == "wrong" ? 12 : 13;
            dialogManager.SwitchDialog(dialogNum);
            if (sliceCount >= 3)
            {
                dialogManager.SwitchDialog(14);
            }
        }

        Vector3 offset = Camera.main.transform.forward * 0.02f;
        if (type == "wrong")
        {
            wrongMarkObj = Instantiate(wrongSignPrefab, pos - offset, Quaternion.identity);
        }
        else if (type == "z")
        {
            zObj = Instantiate(zPrefab, pos - offset, Quaternion.identity);
        }
        else if (type == "checkmark")
        {
            chkObj = Instantiate(chkPrefab, pos - offset, Quaternion.identity);
        }
        else if (type == "carat")
        {
            caretObj = Instantiate(caretPrefab, pos - offset, Quaternion.identity);
        }
        else if (type == "infinity")
        {
            infObj = Instantiate(infPrefab, pos - offset, Quaternion.identity);
        }
        else if (type == "circle")
        {
            cirObj = Instantiate(cirPrefab, pos - offset, Quaternion.identity);
        }
    }

    public void OnCollisionEnter(Collision collision)
    {
        bool isGodMode = PlayerStatusManager.Instance.GetIfGodMode();
        if (collision.gameObject.CompareTag("Safe Object"))
        {
            Vector3 hitPos = collision.transform.position;

            // check if the object collided has special child object
            Transform z = collision.transform.Find("zSprite");
            Transform checkmark = collision.transform.Find("checkSprite");
            Transform caret = collision.transform.Find("caretSprite");
            Transform infinity = collision.transform.Find("infinitySprite");
            Transform circle = collision.transform.Find("circleSprite");

            splashObj = Instantiate(splashPrefab, hitPos, Quaternion.identity);

            GestureMsg gestureMsg = FindObjectOfType<GestureListener>().takeFirstMsg("defSword");

            if (circle != null)
            {
                // dummy data input simulating AI gesture detection  
                string tempGesture = Random.value < 0.5f ? "circle" : "none";
                string gestureDetected = gestureMsg == null ? "none" : gestureMsg.gesture;
                if (gestureDetected == "circle" || isGodMode)
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
            else if (infinity != null)
            {
                // dummy data input simulating AI gesture detection 
                string tempGesture = Random.value < 0.5f ? "infinity" : "none";
                string gestureDetected = gestureMsg == null ? "none" : gestureMsg.gesture;
                if (gestureDetected == "infinity" || isGodMode)
                {
                    AddSpecialAnimation("infinity", hitPos);
                    MqttApi.BuzzSuccess();
                }
                else
                {
                    AddSpecialAnimation("wrong", hitPos);
                    logic.DeductScore();
                    MqttApi.BuzzFailure();
                }
            }
            else if (caret != null)
            {
                // dummy data input simulating AI gesture detection 
                string tempGesture = Random.value < 0.5f ? "carat" : "none";
                string gestureDetected = gestureMsg == null ? "none" : gestureMsg.gesture;
                if (gestureDetected == "carat" || isGodMode)
                {
                    AddSpecialAnimation("carat", hitPos);
                    MqttApi.BuzzSuccess();
                }
                else
                {
                    AddSpecialAnimation("wrong", hitPos);
                    logic.DeductScore();
                    MqttApi.BuzzFailure();
                }
            }
            else if (checkmark != null)
            {
                // dummy data input simulating AI gesture detection 
                string tempGesture = Random.value < 0.5f ? "checkmark" : "none";
                string gestureDetected = gestureMsg == null ? "none" : gestureMsg.gesture;
                if (gestureDetected == "checkmark" || isGodMode)
                {
                    AddSpecialAnimation("checkmark", hitPos);
                    MqttApi.BuzzSuccess();
                }
                else
                {
                    AddSpecialAnimation("wrong", hitPos);
                    logic.DeductScore();
                    MqttApi.BuzzFailure();
                }
            }
            else if (z != null)
            {
                // dummy data input simulating AI gesture detection 
                string tempGesture = Random.value < 0.5f ? "z" : "none";
                string gestureDetected = gestureMsg == null ? "none" : gestureMsg.gesture;
                if (gestureDetected == "z" || isGodMode)
                {
                    AddSpecialAnimation("z", hitPos);
                    MqttApi.BuzzSuccess();
                }
                else
                {
                    AddSpecialAnimation("wrong", hitPos);
                    logic.DeductScore();
                    MqttApi.BuzzFailure();
                }
            }
            if (dialogManager != null && dialogManager.getCurrentIndex() == 5)
            {
                dialogManager.SwitchDialog(6);
            }
            if (isGodMode)
            {
                SetMessage("All slices registered correct");
            }
            logic.AddScore();
            Destroy(collision.gameObject);
        }
        else
        {
            if (isGodMode)
            {
                SetMessage("You cut a bomb");
            }
            else
            {
                logic.GameOver();
            }
        }
    }

    private void SetMessage(string message)
    {
        TMP_Text text = GameObject.Find("GameTrackingText").GetComponent<TMP_Text>();
        text.text = message;
    }
}
