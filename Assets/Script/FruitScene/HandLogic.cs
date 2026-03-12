using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

// triggers different hand prefab's actions according to player's role
public class HandLogic : MonoBehaviour
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
        string atkGesture = GestureListener.gestureInstance.atkHandGesture;
        string defGesture = GestureListener.gestureInstance.defHandGesture;
        string playerIdentity = PlayerStatusManager.Instance.GetIdentity();
        if (playerIdentity == "Attacker" && atkGesture != null)
        {
            AttackHandRelease();
        }
        else if (playerIdentity == "Defender" && defGesture != null)
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
        clickCount++;
        if (clickCount > 3)
        {
            clickCount = 0;
        }
        string playerIdentity = PlayerStatusManager.Instance.GetIdentity();
        if (playerIdentity == "Attacker")
        {
            AttackHandRelease();
        }
        else if (playerIdentity == "Defender")
        {
            DefendHandSkillRelease();
        }
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
        }
        else
        {
            SetMessage("No hand found: " + hand);
        }
    }
}
