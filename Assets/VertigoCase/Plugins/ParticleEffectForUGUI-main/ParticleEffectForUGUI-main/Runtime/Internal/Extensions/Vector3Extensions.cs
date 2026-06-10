using UnityEngine;

namespace Coffee.UIParticleInternal
{
    internal static class Vector3Extensions
    {
        public static Vector3 Inverse(this Vector3 self)
        {
            self.x = Mathf.Abs(self.x) < 0.0001f ? 0f : 1f / self.x;
            self.y = Mathf.Abs(self.y) < 0.0001f ? 0f : 1f / self.y;
            self.z = Mathf.Abs(self.z) < 0.0001f ? 0f : 1f / self.z;
            return self;
        }

        public static Vector3 GetScaled(this Vector3 self, Vector3 other1)
        {
            self.Scale(other1);
            return self;
        }

        public static Vector3 GetScaled(this Vector3 self, Vector3 other1, Vector3 other2)
        {
            self.Scale(other1);
            self.Scale(other2);
            return self;
        }

        public static Vector3 GetScaled(this Vector3 self, Vector3 other1, Vector3 other2, Vector3 other3)
        {
            self.Scale(other1);
            self.Scale(other2);
            self.Scale(other3);
            return self;
        }

        public static bool IsVisible(this Vector3 self)
        {
            return Mathf.Abs(self.x) > 0.0001f && Mathf.Abs(self.y) > 0.0001f && Mathf.Abs(self.z) > 0.0001f;
        }

        public static bool IsVisible2D(this Vector3 self)
        {
            return Mathf.Abs(self.x) > 0.0001f && Mathf.Abs(self.y) > 0.0001f;
        }
    }
}
