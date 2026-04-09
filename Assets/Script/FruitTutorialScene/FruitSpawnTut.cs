using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using TMPro;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using static GestureListener;

// Manage fruit prefab spawning logic when playing as defender
public class FruitSpawnTut : MonoBehaviour
{
    private float lowestYPoint = -5;

    [SerializeField] private float spawnRate;
    [SerializeField] private GameObject origin;
    [SerializeField] private DialogManager dialogManager;
    [SerializeField] private GameObject splashPrefab;
    private GameObject splashObj;
    private ARTrackedImageManager aRTrackedImageManager;

    private float timer;

    private bool isActive;
    private bool isFrozen;
    private bool isImageScanned;
    private Vector3 storedImagePos;

    private bool attackerActive;
    private bool shapeIncluded;
    private bool bombIncluded;
    private bool firstBombReleased;

    [SerializeField] private GameObject lemonPrefab, pearPrefab, strawberryPrefab, applePrefab, watermelonPrefab, peachPrefab, cherryPrefab;
    [SerializeField] private GameObject bombPrefab;
    private GameObject[] normFruits;
    private GameObject[] fruitsWShape;
    private GameObject[] allFruits;
    private ARTrackedImage currentFruitImage;
    private ARTrackedImage currentAttackerImage;
    private string gestureResult;


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
        isImageScanned = false;
        attackerActive = false;
        timer = 0;
        normFruits = new GameObject[]
        {
            strawberryPrefab,
            peachPrefab
        };
        fruitsWShape = new GameObject[]
        {
            lemonPrefab,
            pearPrefab,
            applePrefab,
            watermelonPrefab,
            cherryPrefab
        };
        allFruits = new GameObject[]
        {
            lemonPrefab,
            pearPrefab,
            applePrefab,
            watermelonPrefab,
            cherryPrefab,
            strawberryPrefab,
            peachPrefab
        };
        isFrozen = false;
        shapeIncluded = false;
        bombIncluded = false;
        firstBombReleased = false;
    }

    public void SetShapeIncluded(bool input)
    {
        shapeIncluded = input;
    }

    public void SetBombIncluded(bool input)
    {
        bombIncluded = input;
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
            else if (image.referenceImage.name == "BombOmbThrower")
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
            else if (image.referenceImage.name == "BombOmbThrower")
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

    public void ResetSpawnSetting()
    {
        isActive = false;
        isImageScanned = false;
    }

    public void SetSpawnOnClick()
    {
        if (isActive)
        {
            isActive = false;
        }
        else if (isImageScanned)
        {
            timer = 0.5f;
            isActive = true;
            if (dialogManager.getCurrentIndex() == 4)
            {
                dialogManager.SwitchDialog(5);
            }
        }
        else
        {
            SetMessage("No scanned location.");
        }
    }

    // store image's last position detected by AR manager, this position is the anchor point to spawn fruit 
    public void SetImageOnClick()
    {
        if (PlayerStatusManager.Instance.GetIdentity() != "Defender")
        {
            SetMessage("Scan disabled for your role.");
            return;
        }
        if (currentFruitImage.referenceImage.name == "NUSLogo" && currentFruitImage.trackingState == TrackingState.Tracking)
        {
            isImageScanned = true;
            storedImagePos = currentFruitImage.transform.position;
            string message = "Image Scanned. \n" + storedImagePos.ToString();
            SetMessage(message);
            if (dialogManager.getCurrentIndex() == 3)
            {
                dialogManager.SwitchDialog(4);
            }
        }
        else
        {
            string message = "No Image Found. \n" + storedImagePos.ToString();
            SetMessage(message);
        }
    }

    public void AttackerThrowItem()
    {
        if (PlayerStatusManager.Instance.GetIdentity() != "Defender")
        {
            return;
        }

        float force = 5;
        GestureMsg gestureMsg = FindObjectOfType<GestureListener>().takeLatestMsg("atkHand");
        string attakerGesture = gestureMsg == null ? "none" : gestureMsg.gesture;
        if (attakerGesture == "throw")
        {
            Vector3 position = currentAttackerImage.transform.position;
            GameObject bombThrown = Instantiate(bombPrefab, position, Quaternion.identity);
            applyPhysics(bombThrown, force, Direction.Backward);
        }
    }

    public void SetFrozen(bool value)
    {
        isFrozen = value;
    }

    public void SetSpawn()
    {
        if (shapeIncluded && !bombIncluded)
        {
            StartCoroutine(ThrowFromBottom(fruitsWShape, 0));
        }
        else if (bombIncluded)
        {
            if (!firstBombReleased)
            {
                StartCoroutine(ThrowFromBottom(allFruits, 0.1f, true));
            }
            else
            {
                StartCoroutine(ThrowFromBottom(allFruits, 0.1f));
            }
        }
        else
        {
            StartCoroutine(ThrowFromBottom(normFruits, 0));
        }
    }

    // controls fruit spawn rate
    void Update()
    {
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
                SetSpawn();
                timer = 0;
            }
        }
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
    private IEnumerator ThrowFromBottom(GameObject[] fruits, float probability, bool fixedBomb = false)
    {
        float force = 3;
        GameObject fruitChosen = fruits[Random.Range(0, fruits.Length)];
        bool isBomb = Random.value < probability;
        Vector3 offset = new Vector3(0, 0, 0);
        Vector3 spawnPos = storedImagePos + offset;

        if (fixedBomb || isBomb)
        {
            GameObject bomb = Instantiate(bombPrefab, spawnPos, Quaternion.identity);
            bomb.transform.SetParent(null);
            bomb.transform.localScale *= 0.067f;
            bomb.SetActive(true);
            applyPhysics(bomb, force, Direction.Up);
            firstBombReleased = true;
        }
        else if (fruitChosen != null && !isBomb)
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
