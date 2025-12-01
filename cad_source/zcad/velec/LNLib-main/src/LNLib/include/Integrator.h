/*
 * Author:
 * 2024/01/08 - Yuqing Liang (BIMCoder Liang)
 * bim.frankliang@foxmail.com
 * 
 *
 * Use of this source code is governed by a LGPL-2.1 license that can be found in
 * the LICENSE file.
 */

#pragma once
#include "LNLibDefinitions.h"
#include "LNObject.h"
#include <vector>

namespace LNLib
{
	class LNLIB_EXPORT IntegrationFunction
	{
	public:
		virtual double operator()(double parameter, void* customData) = 0;
	};

	class LNLIB_EXPORT BinaryIntegrationFunction
	{
	public:
		virtual double operator()(double u, double v, void* customData)const = 0;
	};

	class LNLIB_EXPORT Integrator
	{

	public:
		static double Simpson(IntegrationFunction& function, void* customData, double start, double end);
		static double Simpson(BinaryIntegrationFunction& function, void* customData, double uStart, double uEnd, double vStart, double vEnd);

		/// <summary>
		/// According to https://github.com/Pomax/bezierjs
		/// Order is set 24.
		/// </summary>
		static const std::vector<double> GaussLegendreAbscissae;
		static const std::vector<double> GaussLegendreWeights;

		/// <summary>
		/// According to https://github.com/chrisidefix/nurbs
		/// </summary>
		static std::vector<double> ChebyshevSeries(int size = 100);
		static double ClenshawCurtisQuadrature(IntegrationFunction& function, void* customData, double start, double end, std::vector<double>& series, double epsilon = Constants::DistanceEpsilon);
		static double ClenshawCurtisQuadrature2(IntegrationFunction& function, void* customData, double start, double end, std::vector<double> series, double epsilon = Constants::DistanceEpsilon);
	};
	
}


