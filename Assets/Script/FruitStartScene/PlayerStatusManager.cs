using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.XR.ARFoundation;

// Set the role player chose at start scene, this class is not destroyed on load
public class PlayerStatusManager : MonoBehaviour
{
    public static PlayerStatusManager Instance;
    private string playerIdentity;
    private bool isGodMode;

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);
        SceneManager.sceneLoaded += OnSceneLoaded;
    }

    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        StartCoroutine(ResetARSession());
    }

    private IEnumerator ResetARSession()
    {
        yield return null;
        ARSession arSession = FindObjectOfType<ARSession>();
        if (arSession != null)
        {
            arSession.Reset();
        }
    }

    void OnDestroy()
    {
        SceneManager.sceneLoaded -= OnSceneLoaded;
    }

    void Update()
    {
        Debug.Log("identity is: " + playerIdentity + "\n");
        Debug.Log("Is God Mode: " + isGodMode);
    }

    public void SetGodMode(bool input)
    {
        isGodMode = input;
    }

    public bool GetIfGodMode()
    {
        return isGodMode;
    }

    public void SetIdentity(string role)
    {
        playerIdentity = role;
    }

    public string GetIdentity()
    {
        return playerIdentity;
    }
}
