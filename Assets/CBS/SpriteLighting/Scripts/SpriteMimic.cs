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
			[SerializeField] protected Material mimicMaterial;

			[SerializeField] protected SpriteRenderer originalRenderer;
			protected SpriteRenderer mimicRenderer;

			/// <summary>
			/// Mark as true if the sprite won't change over time, so the copy will not
			/// be updated.
			/// </summary>
			[SerializeField] protected bool isStatic = true;


			// Use this for initialization
			void Start ()
			{
				if (originalRenderer == null)
				{
					// Create a copy of the sprite renderer in a new child gameObject
					originalRenderer = GetComponent<SpriteRenderer>();
				}

				GameObject copyGameObject = new GameObject();

				Transform mimicTransform = copyGameObject.transform;
				mimicTransform.parent = transform;
				mimicTransform.localScale = Vector3.one;
				mimicTransform.localRotation = Quaternion.identity;
				mimicTransform.position = originalRenderer.transform.position;

				mimicRenderer = copyGameObject.AddComponent<SpriteRenderer>();
				mimicRenderer.material = mimicMaterial;
				mimicRenderer.sprite = originalRenderer.sprite;

				if (isStatic)
				{
					Destroy(this);
				}
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
			}

		}

	}
}