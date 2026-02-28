using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class HandLogic : MonoBehaviour
{
    [SerializeField] private TMP_Text text;
    private void SetMessage(string message)
    {
        text.text = message;
    }

    public void ApplyHandAction()
    {
        string playerIdentity = PlayerStatusManager.Instance.GetIdentity();
        if (playerIdentity == "Attacker")
        {
            SetMessage("identity is attacker");
            AttackHandRelease();
        }
        else if (playerIdentity == "Defender")
        {
            SetMessage("identity is attacker");
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

    }
}
