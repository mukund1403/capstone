using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.XR.ARFoundation;

// in charge of basic game logic in the scene
public class GameLogic : MonoBehaviour
{
    [SerializeField] private GameObject gamePlayCanvas;
    [SerializeField] private GameObject gameOverCanvas;
    [SerializeField] private GameObject tutorialCanvas;
    [SerializeField] private GameObject godModeCanvas;
    [SerializeField] private GameObject pauseText;
    [SerializeField] private GameObject spawnBombButton;

    public bool isGameOver;
    public int score;

    void Awake()
    {
        isGameOver = false;
        score = 0;
    }

    private void Start()
    {
        if (spawnBombButton != null)
        {
            if (PlayerStatusManager.Instance.GetIdentity() != "Attacker")
            {
                spawnBombButton.SetActive(false);
            }
            else
            {
                spawnBombButton.SetActive(true);
            }
        }
        if (godModeCanvas == null)
        {
            return;
        }
        if (PlayerStatusManager.Instance.GetIfGodMode())
        {
            godModeCanvas.SetActive(true);
        }
        else
        {
            godModeCanvas.SetActive(false);
        }
    }

    void Update()
    {
        Time.timeScale = 0.1f;
        Time.fixedDeltaTime = 0.055f * Time.timeScale;
        if (FindObjectOfType<StatusListener>() != null)
        {
            PauseGame();
        }
        Debug.Log("Timescale is " + Time.timeScale);
    }

    public void ResetScore()
    {
        score = 0;
        TMP_Text text = GameObject.Find("TotalScoreText").GetComponent<TMP_Text>();
        text.text = "Score: " + score.ToString();
    }

    public void AddScore()
    {
        score++;
        TMP_Text text = GameObject.Find("TotalScoreText").GetComponent<TMP_Text>();
        text.text = "Score: " + score.ToString();
    }

    public void DeductScore()
    {
        score--;
        TMP_Text text = GameObject.Find("TotalScoreText").GetComponent<TMP_Text>();
        text.text = "Score: " + score.ToString();
    }

    public void GameOver()
    {
        gamePlayCanvas.SetActive(false);
        gameOverCanvas.SetActive(true);
        if (tutorialCanvas != null)
        {
            tutorialCanvas.SetActive(false);
        }
    }

    public void EnableGameplay()
    {
        gamePlayCanvas.SetActive(true);
    }

    public void SetGameplayOnClick(bool isActive)
    {
        Button[] buttons = FindObjectsOfType<Button>();

        foreach (Button btn in buttons)
        {
            if (btn.transform.IsChildOf(tutorialCanvas.transform))
            {
                continue;
            }
            btn.interactable = isActive;
        }
    }

    public void PauseGame()
    {
        ARTrackedImageManager aRTrackedImageManager = GameObject.Find("XR Origin").GetComponent<ARTrackedImageManager>();

        //bool attackerActive = FindObjectOfType<StatusListener>().attackerActive;
        //bool defenderActive = FindObjectOfType<StatusListener>().defenderActive;
        //bool playersOnline = FindObjectOfType<StatusListener>().playersOnline;
        bool gamePaused = FindObjectOfType<StatusListener>().gamePaused;
        bool attackerActive = true;
        bool defenderActive = true;
        bool playersOnline = true;

        if (!playersOnline || !attackerActive || !defenderActive || gamePaused)
        {
            Time.timeScale = 0;
            pauseText.SetActive(true);
            pauseText.GetComponent<TMP_Text>().text = gamePaused ? "Game Paused" : "Player's Connection Lost";
            gamePlayCanvas.SetActive(false);
            aRTrackedImageManager.enabled = false;
        }
        else
        {
            Time.timeScale = 0.1f;
            pauseText.SetActive(false);
            gamePlayCanvas.SetActive(true);
            aRTrackedImageManager.enabled = true;
        }
    }
}
