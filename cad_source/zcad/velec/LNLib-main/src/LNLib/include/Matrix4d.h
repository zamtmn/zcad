/*
 * Author:
 * 2023/06/22 - Yuqing Liang (BIMCoder Liang)
 * bim.frankliang@foxmail.com
 * 
 *
 * Use of this source code is governed by a LGPL-2.1 license that can be found in
 * the LICENSE file.
 */

#pragma once
#include "LNLibDefinitions.h"

namespace LNLib
{
	class XYZ;
	class XYZW;
	/// <summary>
	/// 4 * 4 Matrix for model transformation, such as T(x) = M * x
	/// Matrix4d : [x y z w]
	/// </summary>
	class LNLIB_EXPORT Matrix4d
	{
	public:

		Matrix4d();

		Matrix4d(XYZ basisX, XYZ basisY, XYZ basisZ, XYZ origin);

		Matrix4d(double a00, double a01, double a02, double a03,
				 double a10, double a11, double a12, double a13,
				 double a20, double a21, double a22, double a23,
				 double a30, double a31, double a32, double a33);

	public:

		static Matrix4d CreateReflection(const XYZ& normal, double distanceFromOrigin);
		//The distance from reflection plane to origin (0,0,0) is set as 0.0.
		static Matrix4d CreateReflection(const XYZ& normal);
		static Matrix4d CreateRotation(const XYZ& axis, double rad);
		static Matrix4d CreateRotationAtPoint(const XYZ& origin, const XYZ& axis, double rad);
		static Matrix4d CreateTranslation(const XYZ& vector);
		static Matrix4d CreateScale(const XYZ& scale);

	public:
		void SetBasisX(const XYZ& basisX);
		XYZ GetBasisX() const;
		void SetBasisY(const XYZ& basisY);
		XYZ GetBasisY() const;
		void SetBasisZ(const XYZ& basisZ);
		XYZ GetBasisZ() const;
		void SetBasisW(const XYZ& basisW);
		XYZ GetBasisW() const;
		double GetElement(int row, int column) const;
		void SetElement(int row, int column, double value);

	public:
		Matrix4d Multiply(const Matrix4d& right);
		XYZ OfPoint(const XYZ& point);
		XYZW OfWeightedPoint(const XYZW& point);
		XYZ OfVector(const XYZ& vector);

	public:
		bool GetInverse(Matrix4d& inverse);
		Matrix4d GetTranspose();
		XYZ GetScale();
		double GetDeterminant();
		bool IsIdentity();
		bool HasReflection();
		bool IsTranslation();

	public:
		Matrix4d& operator =(const Matrix4d & another);

	private:
		double m_matrix4d[4][4];

	};

	LNLIB_EXPORT Matrix4d operator *(const Matrix4d& left, const Matrix4d& right);
	LNLIB_EXPORT Matrix4d operator +(const Matrix4d& left, const Matrix4d& right);
	LNLIB_EXPORT Matrix4d operator -(const Matrix4d& left, const Matrix4d& right);
}

