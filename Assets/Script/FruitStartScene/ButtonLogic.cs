using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ButtonLogic : MonoBehaviour
{
    [SerializeField] private GameObject helpMenu;
    [SerializeField] private GameObject selectRoleMenu;
    [SerializeField] private GameObject gamePlayCanvas;
    [SerializeField] private GameObject gameOverCanvas;
    private bool isLoadingScene = false;

    public void LoadGameScene()
    {
        if (!helpMenu.activeSelf && !isLoadingScene)
        {
            SceneManager.LoadScene("FruitScene");
            isLoadingScene = true;
        }
    }

    public void QuitGame()
    {
        Application.Quit();
    }

    public void OpenHelp()
    {
        if (!helpMenu.activeSelf && !selectRoleMenu.activeSelf)
        {
            helpMenu.SetActive(true);
        }
    }

    public void CloseHelp()
    {
        helpMenu.SetActive(false);
    }

    public void OpenSelectRole()
    {
        if (!helpMenu.activeSelf && !selectRoleMenu.activeSelf)
        {
            selectRoleMenu.SetActive(true);
        }
    }

    public void CloseSelectRole()
    {
        selectRoleMenu.SetActive(false);
    }

    public void RestartGame()
    {
        gamePlayCanvas.SetActive(true);
        gameOverCanvas.SetActive(false);
        GameLogic logic = GameObject.Find("GameLogic").GetComponent<GameLogic>();
        logic.ResetScore();
    }
}
