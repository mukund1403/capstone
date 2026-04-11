using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using TMPro;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using static GestureListener;
using System.Linq;
using Unity.VisualScripting;

// Manage fruit prefab spawning logic when playing as defender
public class FruitSpawn : MonoBehaviour
{
    private float lowestYPoint = -5;

    [SerializeField] private float spawnRate;
    [SerializeField] private GameObject origin;
    [SerializeField] private GameObject splashPrefab;
    private GameObject splashObj;
    private ARTrackedImageManager aRTrackedImageManager;

    private float timer;

    private bool isActive;
    private bool isFrozen;
    private bool isFruitImageScanned;
    private Vector3 storedFruitImagePos;
    private Vector3 storedAtkerImagePos;

    [SerializeField] private GameObject lemonPrefab, pearPrefab, strawberryPrefab, applePrefab, watermelonPrefab, peachPrefab, cherryPrefab;
    [SerializeField] private GameObject bombPrefab;
    private GameObject[] fruits;
    private GameObject[] fruitsWShape;
    private ARTrackedImage currentFruitImage;
    private ARTrackedImage currentAttackerImage;
    private string gestureResult;
    [SerializeField] private TMP_Text debugMsgShape;
    [SerializeField] private TMP_Text debugMsgAtk;
    [SerializeField] private TMP_Text debugAtkGesture;

    //private float timestamp = 0;
    private string lastAttackerGesture = "none";

    private enum Direction
    {
        Forward,
        Backward,
        Left,
        Right,
        Up,
        Down
    }

    void Awake()
    {
        aRTrackedImageManager = origin.GetComponent<ARTrackedImageManager>();
        isActive = false;
        isFruitImageScanned = false;
        timer = 0;
        fruits = new GameObject[]
        {
            lemonPrefab, 
            pearPrefab, 
            strawberryPrefab, 
            applePrefab, 
            watermelonPrefab, 
            peachPrefab,
            cherryPrefab
        };
        fruitsWShape = new GameObject[]
        {
            lemonPrefab,
            pearPrefab,
            applePrefab,
            watermelonPrefab,
            cherryPrefab
        };
        isFrozen = false;
    }

    // subscribe to ARTrackedImageManager
    private void OnEnable()
    {
        if (aRTrackedImageManager != null)
        {
            aRTrackedImageManager.trackedImagesChanged += OnImageChanged;
        }
    }

    // unsubscribe to ARTrackedImageManager
    private void OnDisable()
    {
        if (aRTrackedImageManager != null)
        {
            aRTrackedImageManager.trackedImagesChanged -= OnImageChanged;
        }
    }

    // store the image's last tracking status 
    private void OnImageChanged(ARTrackedImagesChangedEventArgs obj)
    {
        foreach (ARTrackedImage image in obj.added)
        {
            if (image.referenceImage.name == "NUSLogo")
            {
                currentFruitImage = image;
            }
            if (image.referenceImage.name == "BombOmbThrower")
            {
                currentAttackerImage = image;
            }
        }
        foreach (ARTrackedImage image in obj.updated)
        {
            if (image.referenceImage.name == "NUSLogo")
            {
                currentFruitImage = image;
            }
            if (image.referenceImage.name == "BombOmbThrower")
            {
                currentAttackerImage = image;
            }
        }
    }

    private void SetMessage(string message)
    {
        TMP_Text text = GameObject.Find("ScanText").GetComponent<TMP_Text>();
        text.text = message;
    }

    public void SetSpawnOnClick()
    {
        if (isActive)
        {
            isActive = false;
            SetMessage("Spawn fruit stopped.");
        }
        else if (isFruitImageScanned)
        {
            timer = 0.7f;
            isActive = true;
            SetMessage("Spawn fruit active.");
        }
        else
        {
            SetMessage("No scanned location.");
        }
    }

    // store image's last position detected by AR manager, this position is the anchor point to spawn fruit 
    public void SetImageOnClick()
    {
        string message = "";
        bool anyFound = false;
        if (PlayerStatusManager.Instance.GetIdentity() != "Defender")
        {
            SetMessage("Scan disabled for your role.");
            return;
        }
        if (currentFruitImage != null && currentFruitImage.referenceImage.name == "NUSLogo" &&
            currentFruitImage.trackingState == TrackingState.Tracking)
        {
            isFruitImageScanned = true;
            storedFruitImagePos = currentFruitImage.transform.position;
            message += "Fruit Image Scanned. \n" + storedFruitImagePos.ToString() + "\n";
            anyFound = true;
        }
        if (currentAttackerImage != null && currentAttackerImage.referenceImage.name == "BombOmbThrower" &&
            currentAttackerImage.trackingState == TrackingState.Tracking)
        {
            storedAtkerImagePos = currentAttackerImage.transform.position;
            message += "Attacker Image Scanned. \n" + storedAtkerImagePos.ToString();
            anyFound = true;
        }
        if (!anyFound)
        {
            message = "No Image Found. \n" + storedFruitImagePos.ToString() + "\n" + 
            storedAtkerImagePos.ToString();
        }
        SetMessage(message);
    }

    public void AttackerThrowItem()
    {
        Debug.Log("Attack throw called");
        if (PlayerStatusManager.Instance.GetIdentity() != "Defender")
        {
            return;
        }
        float force = 5;
        GestureMsg thrownMsg = FindObjectOfType<GestureListener>().takeLatestMsg("atkthrown");
        if (thrownMsg != null)
        {
            lastAttackerGesture = thrownMsg.gesture;
        }
        string attackerGesture = thrownMsg == null ? "none" : thrownMsg.gesture;
        Debug.Log(debugAtkGesture.text);
        if (lastAttackerGesture == "bombThrown" && storedAtkerImagePos != null)
        {
            lastAttackerGesture = "none";
            GameObject bombThrown = Instantiate(bombPrefab, storedAtkerImagePos, Quaternion.identity);
            bombThrown.transform.SetParent(null);
            bombThrown.transform.localScale *= 0.067f;
            bombThrown.SetActive(true);
            applyPhysics(bombThrown, force, Direction.Up);
            Debug.Log("bomb is THROWN.");
            debugAtkGesture.text = "BOMB IS THROWN";
        }
    }

    public void SetFrozen(bool value)
    {
        isFrozen = value;
    }

    // controls fruit spawn rate
    void Update()
    {
        debugMsgShape.text = FindObjectOfType<GestureListener>().GetLastFiveGestures();
        debugMsgAtk.text = FindObjectOfType<GestureListener>().GetLastFiveGesturesHand();
        if (isFrozen)
        {
            return;
        }
        if (isActive)
        {
            if (timer < spawnRate)
            {
                timer += Time.deltaTime;
            }
            else
            {
                StartCoroutine(ThrowFromBottom());
                timer = 0;
            }
        }
        AttackerThrowItem();
    }

    // throw fruit prefabs in the direction
    private void applyPhysics(GameObject item, float force, Direction dir)
    {
        Rigidbody rb = item.GetComponent<Rigidbody>();
        rb.useGravity = true;
        float spinForce = 5;
        switch (dir)
        {
            case Direction.Left:
                rb.AddForce(Vector3.left * force, ForceMode.Impulse);
                rb.AddTorque(Random.insideUnitSphere * spinForce, ForceMode.Impulse);
                break;
            case Direction.Right:
                rb.AddForce(Vector3.right * force, ForceMode.Impulse);
                rb.AddTorque(Random.insideUnitSphere * spinForce, ForceMode.Impulse);
                break;
            case Direction.Up:
                rb.AddForce(Vector3.up * force, ForceMode.Impulse);
                rb.AddTorque(Random.insideUnitSphere * spinForce, ForceMode.Impulse);
                break;
            case Direction.Backward:
                Vector3 camPos = Camera.main.transform.position;
                Vector3 backwardDir = (camPos - item.transform.position).normalized;
                rb.AddForce(backwardDir * force, ForceMode.Impulse);
                rb.AddTorque(Random.insideUnitSphere * spinForce, ForceMode.Impulse);
                break;
        }
    }

    // Randomly spawn fruits and bombs bottom-up
    private IEnumerator ThrowFromBottom()
    {
        float force = 3;
        GameObject fruitChosen = fruits[Random.Range(0, fruits.Length)];
        bool isBomb = Random.value < 0.1f;
        Vector3 offset = new Vector3(0, 0, 0);
        Vector3 spawnPos = storedFruitImagePos + offset;

        if (fruitChosen != null && !isBomb)
        {
            GameObject spawnedFruit = Instantiate(fruitChosen, spawnPos, Quaternion.identity);
            spawnedFruit.transform.SetParent(null);
            spawnedFruit.transform.localScale *= 0.067f;
            spawnedFruit.SetActive(true);
            applyPhysics(spawnedFruit, force, Direction.Up);
            if (fruitsWShape.Contains(fruitChosen))
            {
                yield return StartCoroutine(ListeningShape(fruitChosen));
                FruitSplash(spawnedFruit);
            }
        }
        else if (isBomb)
        {
            GameObject bomb = Instantiate(bombPrefab, spawnPos, Quaternion.identity);
            bomb.transform.SetParent(null);
            bomb.transform.localScale *= 0.067f;
            bomb.SetActive(true);
            applyPhysics(bomb, force, Direction.Up);
        }
    }

    public void FruitSplash(GameObject fruit)
    {
        Vector3 hitPos = fruit.transform.position;
        CollideManager manager = FindObjectOfType<CollideManager>();
        GameLogic logic = GameObject.Find("GameLogic").GetComponent<GameLogic>();
        if (manager == null)
        {
            return;
        }
        splashObj = Instantiate(splashPrefab, hitPos, Quaternion.identity);
        manager.AddSpecialAnimation(gestureResult, hitPos);
        if (gestureResult != "wrong")
        {
            logic.AddScore();
            MqttApi.BuzzSuccess();
        }
        else
        {
            MqttApi.BuzzFailure();
        }
        Destroy(fruit);
    }

    IEnumerator ListeningShape(GameObject fruit)
    {
        string expectedOutput;
        switch (fruit)
        {
            case var f when f == lemonPrefab:
                expectedOutput = "carat";
                break;
            case var f when f == applePrefab:
                expectedOutput = "circle";
                break;
            case var f when f == pearPrefab:
                expectedOutput = "z";
                break;
            case var f when f == watermelonPrefab:
                expectedOutput = "checkmark";
                break;
            case var f when f == cherryPrefab:
                expectedOutput = "infinity";
                break;
            default:
                expectedOutput = "null";
                break;
        }
        float elapsed = 0f;
        gestureResult = "wrong"; // default if timeout

        while (elapsed < 4f)
        {
            if (!isFrozen)
            {
                elapsed += Time.unscaledDeltaTime;
            }

            GestureMsg gestureMsg = FindObjectOfType<GestureListener>().takeLatestMsg("defSword");
            string gestureDetected = gestureMsg == null ? "none" : gestureMsg.gesture;

            if (gestureDetected == expectedOutput)
            {
                gestureResult = gestureDetected;
                yield break; // exit early, no need to wait further
            }

            yield return null; // wait one frame then check again
        }
    }
}
