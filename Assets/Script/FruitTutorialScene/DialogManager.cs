using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using TMPro;

// Manage the dialog progress in the tutorial mode
public class DialogManager : MonoBehaviour
{
    [SerializeField] private TMP_Text dialogueText;

    [TextArea]
    [SerializeField] private List<string> dialogueLines;

    private int currentIndex;
    private bool isDialogueActive;
    private List<int> indexPaused = new List<int> { 3, 4, 5, 8, 11, 12, 16, 18 };

    private bool defenderSet;
    private bool attackerSet;
   
    void Awake()
    {
        currentIndex = 0;
        isDialogueActive = true;
        defenderSet = false;
        attackerSet = false;
        if (dialogueLines.Count > 0)
        {
            dialogueText.text = dialogueLines[currentIndex];
        }
        PlayerStatusManager.Instance.SetIdentity(null);
    }

    void Update()
    {
        if (SceneManager.GetActiveScene().name != "FruitTutorialScene")
        {
            return;
        }
        if (!indexPaused.Contains(currentIndex))
        {
            SetActive(true);
        }
        if (currentIndex == 2 && !defenderSet)
        {
            PlayerStatusManager.Instance.SetIdentity("Defender");
            defenderSet = true;
        }
        if (currentIndex == 10)
        {
            FruitSpawnTut spawn = FindObjectOfType<FruitSpawnTut>();
            spawn.SetShapeIncluded(true);
        }
        if (currentIndex == 14)
        {
            FruitSpawnTut spawn = FindObjectOfType<FruitSpawnTut>();
            spawn.SetBombIncluded(true);
        }
        if (currentIndex == 15)
        {
            VideoController.Instance.SwitchStep("stop");
            FruitSpawnTut spawn = FindObjectOfType<FruitSpawnTut>();
            spawn.ResetSpawnSetting();
            PlayerStatusManager.Instance.SetIdentity(null);
            PrefabCreatorImage creator = FindObjectOfType<PrefabCreatorImage>();
            if (creator != null)
            {
                creator.RemovePrefabs();
            }
        }
        if (currentIndex == 16 && !attackerSet)
        {
            PlayerStatusManager.Instance.SetIdentity("Attacker");
            attackerSet = true;
        }
    }

    public void SwitchDialog(int index)
    {
        currentIndex = index;
        dialogueText.text = dialogueLines[currentIndex];
        SetActive(false);
    }

    public void SetActive(bool input)
    {
        isDialogueActive = input;
    }

    public int getCurrentIndex()
    {
        return currentIndex;
    }

    public void NextDialogue()
    {
        if (isDialogueActive)
        {
            currentIndex++;

            if (currentIndex < dialogueLines.Count)
            {
                dialogueText.text = dialogueLines[currentIndex];
            }
            SetActive(false);
        }
    }
}
