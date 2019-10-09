using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleExpController : MonoBehaviour
{

    public Material particleExp;
    public MeshRenderer[] smRs;
    private Material[] originalMaterial;
    public GameObject model;

    // Use this for initialization
    void Start()
    {

    }

    IEnumerator EXP()
    {
        smRs = model.GetComponentsInChildren<MeshRenderer>();
        Material p_exp = new Material(particleExp);
        p_exp.SetFloat("_ShaderStartTime", Time.time);
        for (int i = 0; i < smRs.Length; i++)
        {
            Material[] temp = smRs[i].materials;
            for (int j = 0; j < smRs[i].materials.Length; j++)
            {
                temp[j] = p_exp;
            }
            smRs[i].materials = temp;
            yield return new WaitForSeconds(0.5f);
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.E))
        {
            StartCoroutine(EXP());
        }

        Shader.SetGlobalFloat("unityTime", Time.time);
    }
}