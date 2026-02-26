using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ButtonLogic : MonoBehaviour
{
    [SerializeField] private GameObject helpMenu;
    [SerializeField] private GameObject selectRoleMenu;
    private bool isLoadingScene = false;

    public void LoadGameScene()
    {
        if (!helpMenu.activeSelf && !isLoadingScene)
        {
            SceneManager.LoadScene("FruitScene");
            isLoadingScene = true;
            Debug.Log("Scene loading...");
        }
    }

    public void QuitGame()
    {
        if (!helpMenu.activeSelf && !selectRoleMenu.activeSelf)
        {
            Application.Quit();
        }
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
}
