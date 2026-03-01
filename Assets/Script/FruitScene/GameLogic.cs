using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class GameLogic : MonoBehaviour
{
    [SerializeField] private GameObject gamePlayCanvas;
    [SerializeField] private GameObject gameOverCanvas;

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
}
