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
#include "LNLibDefinitions.h"
#include "XYZ.h"
#include <cmath>

namespace LNLib
{
	/// <summary>
	/// Represents four-dimension location/vector/offset
	/// </summary>
	class LNLIB_EXPORT XYZW
	{

	public:

		XYZW();
		XYZW(XYZ xyz, double w);
		XYZW(double wx, double wy, double wz, double w);

	public:

		double GetWX() const;
		double GetWY() const;
		double GetWZ() const;

		void SetW(const double w);
		double GetW() const;

		double WX() const;
		double& WX();
		double WY() const;
		double& WY();
		double WZ() const;
		double& WZ();
		double W() const;
		double& W();

	public:

		XYZ ToXYZ(bool divideWeight)const;
		bool IsAlmostEqualTo(const XYZW& another) const;
		double Distance(const XYZW& another) const;

	public:

		double& operator[](int index);
		const double& operator[](int index) const;
		XYZW  operator +(const XYZW& xyzw) const;
		XYZW  operator -(const XYZW& xyzw) const;
		XYZW& operator +=(const XYZW& xyzw);

	private:

		double m_xyzw[4];
	};

	LNLIB_EXPORT XYZW operator *(const XYZW& source, const double d);
	LNLIB_EXPORT XYZW operator *(const double& d, const XYZW& source);
	LNLIB_EXPORT XYZW operator /(const XYZW& source, double d);
}

