/*
 * Author:
 * 2023/06/08 - Yuqing Liang (BIMCoder Liang)
 * bim.frankliang@foxmail.com
 * 
 *
 * Use of this source code is governed by a LGPL-2.1 license that can be found in
 * the LICENSE file.
 */

#pragma once

#include "Constants.h"
#include "LNLibDefinitions.h"

namespace LNLib
{
	/// <summary>
	/// Represents two-dimension location/vector/offset
	/// </summary>
	class LNLIB_EXPORT UV
	{

	public:

		UV();
		UV(double u, double v);

	public:

		void SetU(const double x);
		double GetU() const;
		void SetV(const double y);
		double GetV() const;

		double U() const;
		double& U();
		double V() const;
		double& V();

	public:

		bool IsZero(const double epsilon = Constants::DoubleEpsilon) const;
		bool IsUnit(const double epsilon = Constants::DoubleEpsilon) const;
		bool IsAlmostEqualTo(const UV& another) const;
		double Length() const;
		double SqrLength() const;
		UV Normalize();
		UV Add(const UV& another) const;
		UV Substract(const UV& another) const;
		UV Negative() const;
		double DotProduct(const UV& another) const;
		double CrossProduct(const UV& another) const;
		double Distance(const UV& another) const;

	public:

		UV& operator =(const UV& uv);
		double& operator[](int index);
		const double& operator[](int index) const;
		UV operator +(const UV& uv) const;
		UV operator -(const UV& uv) const;
		double operator *(const UV& uv) const;
		UV& operator *=(const double& d);
		UV& operator /=(const double& d);
		UV& operator +=(const UV& uv);
		UV& operator -=(const UV& uv);
		UV  operator-() const;

	private:

		double m_uv[2];
	};

	LNLIB_EXPORT UV operator *(const UV& source, const double d);
	LNLIB_EXPORT UV operator *(const double& d, const UV& source);
	LNLIB_EXPORT double operator ^(const UV& uv1, const UV& uv2);
	LNLIB_EXPORT UV operator /(const UV& source, double d);
}



