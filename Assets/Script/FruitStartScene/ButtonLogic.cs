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
    [SerializeField] private GameObject tutorialCanvas;
    private bool isLoadingScene = false;

    public void LoadGameScene(string sceneName)
    {
        if (!helpMenu.activeSelf && !isLoadingScene)
        {
            SceneManager.LoadScene(sceneName);
            isLoadingScene = true;
        }
    }

    public void AtkLoadGameScene(string sceneName)
    {
        if (!helpMenu.activeSelf && !isLoadingScene)
        {
            PlayerStatusManager.Instance.SetIdentity("Attacker");
            SceneManager.LoadScene(sceneName);
            isLoadingScene = true;
        }
    }
    public void DefLoadGameScene(string sceneName)
    {
        if (!helpMenu.activeSelf && !isLoadingScene)
        {
            PlayerStatusManager.Instance.SetIdentity("Defender");
            SceneManager.LoadScene(sceneName);
            isLoadingScene = true;
        }
    }

    public void LoadMainPageScene()
    {
        SceneManager.LoadScene("FruitStartScene");
    }

    public void QuitGameScene1()
    {
        if (!helpMenu.activeSelf && !selectRoleMenu.activeSelf)
        {
            Application.Quit();
        }
    }

    public void QuitGameScene2()
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
        if (tutorialCanvas != null)
        {
            tutorialCanvas.SetActive(true);
        }
        gamePlayCanvas.SetActive(true);
        gameOverCanvas.SetActive(false);
        GameLogic logic = GameObject.Find("GameLogic").GetComponent<GameLogic>();
        logic.ResetScore();
    }
}
