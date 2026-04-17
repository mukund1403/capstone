using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IIMUSource
{
    Quaternion GetOrientation();
}
