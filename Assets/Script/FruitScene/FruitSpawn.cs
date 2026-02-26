using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

public class FruitSpawn : MonoBehaviour
{
    private float lowestYPoint = -5;

    [SerializeField] private float spawnRate;
    private float timer;

    private bool isActive;

    [SerializeField] private GameObject lemonPrefab, pearPrefab, strawberryPrefab, applePrefab, watermelonPrefab, peachPrefab;
    [SerializeField] private GameObject bombPrefab;
    private GameObject[] fruits;
    [SerializeField] private Camera cam;

    private enum Direction
    {
        Left,
        Right,
        Up,
        Down
    }

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        isActive = false;
        timer = 0;
        fruits = new GameObject[]
        {
            lemonPrefab, 
            pearPrefab, 
            strawberryPrefab, 
            applePrefab, 
            watermelonPrefab, 
            peachPrefab
        };
    }

    public void setSpawnOnClick()
    {
        if (isActive)
        {
            isActive = false;
        }
        else
        {
            isActive = true;
        }
        MqttPubTest();
    }

    // Update is called once per frame
    void Update()
    {
        if (isActive)
        {
            if (timer < spawnRate)
            {
                timer += Time.deltaTime;
            }
            else
            {
                ThrowFromBottom();
                timer = 0;
            }
        }
    }

    private void applyPhysics(GameObject item, float force, Direction dir)
    {
        Rigidbody rb = item.GetComponent<Rigidbody>();
        rb.useGravity = true;
        float spinForce = 5;
        float gravityScale = 10f;
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
        }
        rb.AddForce(Physics.gravity * gravityScale, ForceMode.Acceleration);
    }

    private void ThrowFromBottom()
    {
        Vector3 camPos = cam.transform.position;
        float force = 11;
        GameObject fruitChosen = fruits[Random.Range(0, fruits.Length)];
        bool isBomb = Random.value < 0.1f;
        if (fruitChosen != null && !isBomb)
        {
            GameObject spawnedFruit = Instantiate(fruitChosen, new Vector3(Random.Range(camPos.x-3, camPos.x+3), -5, 7), transform.rotation);
            spawnedFruit.SetActive(true);
            applyPhysics(spawnedFruit, force, Direction.Up);
            //GameObject spawnedFruit = Instantiate(fruitChosen, new Vector3(Random.Range(-1, 1), 0, 5), transform.rotation);
            //spawnedFruit.SetActive(true);
        } else if (isBomb)
        {
            GameObject bomb = Instantiate(bombPrefab, new Vector3(Random.Range(camPos.x - 3, camPos.x + 3), -5, 7), transform.rotation);
            bomb.SetActive(true);
            applyPhysics(bomb, force, Direction.Up);
        }
    }

    private void ThrowFromLeft()
    {

    }

    private void ThrowFromRight()
    {
    }

    private void MqttPubTest()
    {
        MqttApi.BuzzSuccess();
    }
}
