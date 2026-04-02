using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class DialogManager : MonoBehaviour
{
    [SerializeField] private TMP_Text dialogueText;

    [TextArea]
    [SerializeField] private List<string> dialogueLines;

    private int currentIndex = 0;
    private bool isDialogueActive = true;

    void Start()
    {
        if (dialogueLines.Count > 0)
        {
            dialogueText.text = dialogueLines[currentIndex];
        }
    }

    void Update()
    {
        // Detect screen tap (mobile) OR mouse click (editor)
        if (isDialogueActive && (Input.GetMouseButtonDown(0) || Input.touchCount > 0))
        {
            NextDialogue();
        }
    }

    void NextDialogue()
    {
        currentIndex++;

        if (currentIndex < dialogueLines.Count)
        {
            dialogueText.text = dialogueLines[currentIndex];
        }
        else
        {
            EndDialogue();
        }
    }

    void EndDialogue()
    {
        isDialogueActive = false;
        dialogueText.text = ""; // or keep last line
        Debug.Log("Dialogue finished");
    }
}
