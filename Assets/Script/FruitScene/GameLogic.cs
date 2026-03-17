using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.XR.ARFoundation;

// in charge of basic game logic in the scene
public class GameLogic : MonoBehaviour
{
    [SerializeField] private GameObject gamePlayCanvas;
    [SerializeField] private GameObject gameOverCanvas;
    [SerializeField] private GameObject pauseText;

    public bool isGameOver;
    public int score;

    void Awake()
    {
        isGameOver = false;
        score = 0;
    }

    void Update()
    {
        Time.timeScale = 0.3f;
        Time.fixedDeltaTime = 0.02f;
        //PauseGame();
    }

    public void ResetScore()
    {
        score = 0;
        TMP_Text text = GameObject.Find("ScoreText").GetComponent<TMP_Text>();
        text.text = "Score: " + score.ToString();
    }

    public void AddScore()
    {
        score++;
        TMP_Text text = GameObject.Find("ScoreText").GetComponent<TMP_Text>();
        text.text = "Score: " + score.ToString();
    }

    public void DeductScore()
    {
        score--;
        TMP_Text text = GameObject.Find("ScoreText").GetComponent<TMP_Text>();
        text.text = "Score: " + score.ToString();
    }

    public void GameOver()
    {
        gamePlayCanvas.SetActive(false);
        gameOverCanvas.SetActive(true);
    }

    public void PauseGame()
    {
        ARTrackedImageManager aRTrackedImageManager = GameObject.Find("XR Origin").GetComponent<ARTrackedImageManager>();

        bool attackerActive = FindObjectOfType<StatusListener>().attackerActive;
        bool defenderActive = FindObjectOfType<StatusListener>().defenderActive;

        if (!attackerActive || !defenderActive)
        {
            Time.timeScale = 0;
            pauseText.SetActive(true);
            aRTrackedImageManager.enabled = false;
        }
        else
        {
            Time.timeScale = 0.3f;
            pauseText.SetActive(false);
            aRTrackedImageManager.enabled = true;
        }
    }
}
