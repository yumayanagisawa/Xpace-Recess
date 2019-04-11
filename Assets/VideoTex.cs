using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VideoTex : MonoBehaviour
{
    // Start is called before the first frame update
    /*void Start()
    {
        WebCamDevice[] devices = WebCamTexture.devices;
        for (int i = 0; i < devices.Length; i++)
            Debug.Log(devices[i].name);
        WebCamTexture webcamTexture = new WebCamTexture("Logitech HD Webcam C270");
        Renderer renderer = GetComponent<Renderer>();
        renderer.material.mainTexture = webcamTexture;
        webcamTexture.Play();
    }*/
    private string deviceName;

    void findWebCams()
    {
        foreach (var device in WebCamTexture.devices)
        {
            Debug.Log("Name: " + device.name);
            deviceName = device.name;
        }
    }
    /*
    void Start()
    {
        WebCamDevice[] devices = WebCamTexture.devices;
        Debug.Log("Number of web cams connected: " + devices.Length);
        Renderer rend = GetComponent<Renderer>();

        WebCamTexture mycam = new WebCamTexture();
        string camName = devices[1].name;
        Debug.Log("The webcam name is " + camName);
        mycam.deviceName = camName;
        rend.material.mainTexture = mycam;

        mycam.Play();
    }
    */

    IEnumerator Start()
    {
        findWebCams();

        yield return Application.RequestUserAuthorization(UserAuthorization.WebCam);
        if (Application.HasUserAuthorization(UserAuthorization.WebCam))
        {
            Cursor.visible = false;
            Debug.Log("webcam found");
            WebCamTexture webcamTexture = new WebCamTexture("Logitech HD Webcam C270", 1280, 720, 30);
            Debug.Log(webcamTexture.requestedHeight);
            Debug.Log(webcamTexture.requestedWidth);
            //webcamTexture.deviceName = deviceName;
            Renderer renderer = GetComponent<Renderer>();
            renderer.material.mainTexture = webcamTexture;
            webcamTexture.Play();
        }
        else
        {
            Debug.Log("webcam not found");
        }

        //findMicrophones();

        yield return Application.RequestUserAuthorization(UserAuthorization.Microphone);
        if (Application.HasUserAuthorization(UserAuthorization.Microphone))
        {
            Debug.Log("Microphone found");
        }
        else
        {
            Debug.Log("Microphone not found");
        }
    }




    // Update is called once per frame
    void Update()
    {
        
    }
}
