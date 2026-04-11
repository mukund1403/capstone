using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ButtonLogic : MonoBehaviour
{
    [SerializeField] private GameObject helpMenu;
    [SerializeField] private GameObject selectRoleMenu;
    [SerializeField] private GameObject selectModeMenu;
    [SerializeField] private GameObject gamePlayCanvas;
    [SerializeField] private GameObject gameOverCanvas;
    [SerializeField] private GameObject tutorialCanvas;
    private bool isLoadingScene = false;

    public void LoadGameScene(string sceneName)
    {
        if (!helpMenu.activeSelf && !isLoadingScene)
        {
            PlayerStatusManager.Instance.SetGodMode(false);
            SceneManager.LoadScene(sceneName);
            isLoadingScene = true;
        }
    }

    public void LoadFruitSceneWMode(bool isGodMode)
    {
        if (!helpMenu.activeSelf && !isLoadingScene)
        {
            PlayerStatusManager.Instance.SetGodMode(isGodMode);
            SceneManager.LoadScene("FruitScene");
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

    public void AtkOpenSelectMode()
    {
        if (!helpMenu.activeSelf && !selectModeMenu.activeSelf)
        {
            PlayerStatusManager.Instance.SetIdentity("Attacker");
            selectModeMenu.SetActive(true);
        }
    }
    public void DefOpenSelectMode()
    {
        if (!helpMenu.activeSelf && !selectModeMenu.activeSelf)
        {
            PlayerStatusManager.Instance.SetIdentity("Defender");
            selectModeMenu.SetActive(true);
        }
    }


    public void OpenSelectRole()
    {
        if (!helpMenu.activeSelf && !selectRoleMenu.activeSelf)
        {
            selectRoleMenu.SetActive(true);
        }
    }

    public void CloseSelectRoleMenu()
    {
        selectRoleMenu.SetActive(false);
    }
    public void CloseSelectModeMenu()
    {
        selectModeMenu.SetActive(false);
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
