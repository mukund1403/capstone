using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using static GestureListener;
using Unity.VisualScripting;

// triggers different hand prefab's actions according to player's role
public class HandLogicTut : MonoBehaviour
{
    [SerializeField] private TMP_Text text;
    private int clickCount = 0;

    void Awake()
    {
        string playerIdentity = PlayerStatusManager.Instance.GetIdentity();
        if (playerIdentity == "Attacker")
        {
            SetMessage("Tracking hand status.");
        }
    }
    void Update()
    {
        GestureMsg atkGestureMsg = FindObjectOfType<GestureListener>().takeFirstMsg("atkHand");
        GestureMsg defGestureMsg = FindObjectOfType<GestureListener>().takeFirstMsg("defHand");
        string atkGesture = atkGestureMsg == null ? "none" : atkGestureMsg.gesture;
        string defGesture = defGestureMsg == null ? "none" : defGestureMsg.gesture;
        string playerIdentity = PlayerStatusManager.Instance.GetIdentity();
        if (playerIdentity == "Attacker" && atkGesture == "throw")
        {
            AttackHandRelease();
        }
        else if (playerIdentity == "Defender" && defGesture == "block")
        {
            DefendHandSkillRelease();
        }
    }

    private void SetMessage(string message)
    {
        text.text = message;
    }

    public void ApplyHandAction()
    {
        string playerIdentity = PlayerStatusManager.Instance.GetIdentity();
        SetMessage("button clicked, identity is: " + playerIdentity);
        if (playerIdentity == "Attacker")
        {
            //MqttApi.DummyGesture("throw", "atkHand");
            AttackHandRelease();
        }
        else if (playerIdentity == "Defender")
        {
            //MqttApi.DummyGesture("block" ,"defHand");
            DefendHandSkillRelease();
        }
        MqttApi.BuzzSuccess();
        //Debug.Log($"ApplyHandAction called on: {gameObject.name} in scene: {UnityEngine.SceneManagement.SceneManager.GetActiveScene().name}");
    }

    private void AttackHandRelease()
    {
        GameObject hand = GameObject.FindWithTag("Attacker AR Spawn");
        if (hand != null)
        {
            AttackerHandController controller = hand.GetComponent<AttackerHandController>();
            controller.Release();
            bool isNull = controller.heldObject == null;
            SetMessage("hand released. is held object null: " + isNull);
            UpdateTutDialog();
        }
        else
        {
            SetMessage("No hand found: " + hand);
        }
    }

    private void DefendHandSkillRelease()
    {
        GameObject hand = GameObject.FindWithTag("Defender AR Spawn");
        if (hand != null)
        {
            DefenderHandController controller = hand.GetComponent<DefenderHandController>();
            controller.ApplyFreezeSkill();
            SetMessage("skill released.");
            UpdateTutDialog();
        }
        else
        {
            SetMessage("No hand found: " + hand);
        }
    }

    private void UpdateTutDialog()
    {
        DialogManager dialogManager = FindObjectOfType<DialogManager>();
        int currentIndex = dialogManager.getCurrentIndex();
        int nextIndex;
        if (dialogManager == null)
        {
            return;
        }
        if (currentIndex == 8 || currentIndex == 18)
        {
            nextIndex = currentIndex + 1;
            dialogManager.SwitchDialog(nextIndex);
        }
    }
}
