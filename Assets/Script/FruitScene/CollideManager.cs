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

            // Detect if this is a gesture fruit by checking for sprite children
            bool isGestureFruit = collision.transform.Find("zSprite") != null
                               || collision.transform.Find("checkSprite") != null
                               || collision.transform.Find("caretSprite") != null
                               || collision.transform.Find("infinitySprite") != null
                               || collision.transform.Find("circleSprite") != null;

            if (isGestureFruit)
            {
                // Do nothing — FruitSpawn's ListeningShape coroutine owns this fruit's lifecycle
                return;
            }

            // Non-gesture fruit: normal sword-slice handling
            splashObj = Instantiate(splashPrefab, hitPos, Quaternion.identity);

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
