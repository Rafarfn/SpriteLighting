using UnityEngine;
using System.Collections;

/// <summary>
/// Randomizes the parameter "F_Random" in the AnimatorController in the same GameObject
/// </summary>
public class AnimatorRandomizer : MonoBehaviour
{
	[SerializeField] protected Animator animator;
    
	/// <summary>
	/// Seconds between updates
	/// </summary>
	public float frequency = 1.0f;
	protected float targetTime = 0.0f;

	public readonly static int hashed_F_Random = Animator.StringToHash("F_Random");


	// Use this for initialization

	void OnEnable ()
	{
		if (animator == null)
		{
			animator = GetComponent<Animator>();
		}

		animator.SetFloat(hashed_F_Random, Random.value);
		targetTime = Time.unscaledTime + frequency;
	}

	void Update ()
	{
		if (Time.unscaledTime > targetTime)
		{
			RandomizeNow();
		}
	}


	private void Reset ()
	{
		animator = GetComponent<Animator>();
	}


	public void RandomizeNow ()
	{
		animator.SetFloat(hashed_F_Random, Random.value);
		targetTime = Time.unscaledTime + frequency;
	}


}
