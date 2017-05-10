using UnityEngine;

namespace CBS
{
	namespace SpriteLighting
	{

		[RequireComponent(typeof(SpriteRenderer))]
		/// <summary>
		/// Clones a sprite renderer into a child gameObject, updating its
		/// sprite every frame to match the original one, but with a different material.
		/// </summary>
		public class SpriteMimic : MonoBehaviour
		{
			/// <summary>
			/// The material to the copy spriteRenderer.
			/// </summary>
			[SerializeField]
			protected Material mimicMaterial;

			[SerializeField]
			protected Vector3 mimicScale = Vector3.one;

			[SerializeField]
			protected SpriteRenderer originalRenderer;
			protected SpriteRenderer mimicRenderer;

			protected Transform originalTransform;
			protected Transform mimicTransform;
			protected Vector3 displacement = new Vector3(0.0f, 0.0f, 0.15f);

			/// <summary>
			/// Mark as true if the sprite won't change over time, so the copy will not
			/// be updated.
			/// </summary>
			public bool isStatic = true;


			// Use this for initialization
			void Start ()
			{
				if (originalRenderer == null)
				{
					// Create a copy of the sprite renderer in a new child gameObject
					originalRenderer = GetComponent<SpriteRenderer>();
				}

				GameObject copyGameObject = new GameObject();

				mimicTransform = copyGameObject.transform;
				mimicTransform.parent = transform;
				mimicTransform.localScale = mimicScale;
				mimicTransform.localRotation = Quaternion.identity;
				mimicTransform.position = originalRenderer.transform.position + displacement;

				mimicRenderer = copyGameObject.AddComponent<SpriteRenderer>();
				mimicRenderer.material = mimicMaterial;
				mimicRenderer.sprite = originalRenderer.sprite;

				if (isStatic)
				{
					Destroy(this);
				}

				originalTransform = originalRenderer.transform;
				mimicTransform = mimicRenderer.transform;
			}

			void Reset ()
			{
				if (originalRenderer == null)
				{
					originalRenderer = GetComponent<SpriteRenderer>();
				}
			}

			void LateUpdate ()
			{
				mimicRenderer.sprite = originalRenderer.sprite;

				mimicTransform.position = originalTransform.position + displacement;
			}

		}

	}
}