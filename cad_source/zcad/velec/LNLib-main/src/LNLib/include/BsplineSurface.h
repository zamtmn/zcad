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
#include "Polynomials.h"
#include "UV.h"
#include "BsplineCurve.h"
#include "ValidationUtils.h"
#include "LNLibExceptions.h"
#include "LNObject.h"
#include <vector>

namespace LNLib
{
	class XYZ;
	class XYZW;
	class LNLIB_EXPORT BsplineSurface
	{
	public:

		template <typename T>
		static void Check(const LN_BsplineSurface<T>& surface)
		{
			int degreeU = surface.DegreeU;
			int degreeV = surface.DegreeV;
			std::vector<double> knotVectorU = surface.KnotVectorU;
			std::vector<double> knotVectorV = surface.KnotVectorV;
			std::vector<std::vector<T>> controlPoints = surface.ControlPoints;

			VALIDATE_ARGUMENT(degreeU > 0, "degreeU", "Degree must be greater than zero.");
			VALIDATE_ARGUMENT(degreeV > 0, "degreeV", "Degree must be greater than zero.");
			VALIDATE_ARGUMENT(knotVectorU.size() > 0, "knotVectorU", "KnotVector size must be greater than zero.");
			VALIDATE_ARGUMENT(ValidationUtils::IsValidKnotVector(knotVectorU), "knotVectorU", "KnotVector must be a nondecreasing sequence of real numbers.");
			VALIDATE_ARGUMENT(knotVectorV.size() > 0, "knotVectorV", "KnotVector size must be greater than zero.");
			VALIDATE_ARGUMENT(ValidationUtils::IsValidKnotVector(knotVectorV), "knotVectorV", "KnotVector must be a nondecreasing sequence of real numbers.");
			VALIDATE_ARGUMENT(controlPoints.size() > 0, "controlPoints", "ControlPoints must contains one point at least.");
			VALIDATE_ARGUMENT(ValidationUtils::IsValidBspline(degreeU, knotVectorU.size(), controlPoints.size()), "controlPoints", "Arguments must be fit: m = n + p + 1");
			VALIDATE_ARGUMENT(ValidationUtils::IsValidBspline(degreeV, knotVectorV.size(), controlPoints[0].size()), "controlPoints", "Arguments must be fit: m = n + p + 1");
		}

		/// <summary>
		/// The NURBS Book 2nd Edition Page103
		/// Algorithm A3.5
		/// Compute surface point.
		/// </summary>
		template <typename T>
		static T GetPointOnSurface(const LN_BsplineSurface<T>& surface, UV uv)
		{
			int degreeU = surface.DegreeU;
			int degreeV = surface.DegreeV;
			const std::vector<double>& knotVectorU = surface.KnotVectorU;
			const std::vector<double>& knotVectorV = surface.KnotVectorV;
			const std::vector<std::vector<T>>& controlPoints = surface.ControlPoints;

			VALIDATE_ARGUMENT_RANGE(uv.GetU(), knotVectorU[0], knotVectorU[knotVectorU.size() - 1]);
			VALIDATE_ARGUMENT_RANGE(uv.GetV(), knotVectorV[0], knotVectorV[knotVectorV.size() - 1]);			

			int uSpanIndex = Polynomials::GetKnotSpanIndex(degreeU, knotVectorU, uv.GetU());
			double Nu[Constants::NURBSMaxDegree + 1];
			Polynomials::BasisFunctions(uSpanIndex, degreeU, knotVectorU, uv.GetU(), Nu);
			int vSpanIndex = Polynomials::GetKnotSpanIndex(degreeV, knotVectorV, uv.GetV());
			double Nv[Constants::NURBSMaxDegree + 1];
			Polynomials::BasisFunctions(vSpanIndex, degreeV, knotVectorV, uv.GetV(), Nv);

			int uind = uSpanIndex - degreeU;
			T point;
			for (int l = 0; l <= degreeV; l++)
			{
				T temp;
				int vind = vSpanIndex - degreeV + l;
				for (int k = 0; k <= degreeU; k++)
				{
					temp += Nu[k] * controlPoints[uind + k][vind];
				}
				point += Nv[l] * temp;
			}
			return point;
		}

		/// <summary>
		/// The NURBS Book 2nd Edition Page111
		/// Algorithm A3.6
		/// Compute surface derivatives. (Usually Use)
		/// </summary>
		template <typename T>
		static std::vector<std::vector<T>> ComputeDerivatives(const LN_BsplineSurface<T>& surface, int derivative, UV uv)
		{
			int degreeU = surface.DegreeU;
			int degreeV = surface.DegreeV;
			const std::vector<double>& knotVectorU = surface.KnotVectorU;
			const std::vector<double>& knotVectorV = surface.KnotVectorV;
			const std::vector<std::vector<T>>& controlPoints = surface.ControlPoints;

			VALIDATE_ARGUMENT(derivative > 0, "derivative", "derivative must be greater than zero.");	
			VALIDATE_ARGUMENT_RANGE(uv.GetU(), knotVectorU[0], knotVectorU[knotVectorU.size() - 1]);
			VALIDATE_ARGUMENT_RANGE(uv.GetV(), knotVectorV[0], knotVectorV[knotVectorV.size() - 1]);		

			std::vector<std::vector<T>> derivatives(derivative + 1, std::vector<T>(derivative + 1));

			int uSpanIndex = Polynomials::GetKnotSpanIndex(degreeU, knotVectorU, uv.GetU());
			std::vector<std::vector<double>> Nu = Polynomials::BasisFunctionsDerivatives(uSpanIndex, degreeU, derivative, knotVectorU, uv.GetU());

			int vSpanIndex = Polynomials::GetKnotSpanIndex(degreeV, knotVectorV, uv.GetV());
			std::vector<std::vector<double>> Nv = Polynomials::BasisFunctionsDerivatives(vSpanIndex, degreeV, derivative, knotVectorV, uv.GetV());

			int du = std::min(derivative, degreeU);
			int dv = std::min(derivative, degreeV);

			std::vector<T> temp(degreeV + 1);

			for (int k = 0; k <= du; k++)
			{
				for (int s = 0; s <= degreeV; s++)
				{
					temp[s] = T();
					for (int r = 0; r <= degreeU; r++)
					{
						temp[s] += Nu[k][r] * controlPoints[uSpanIndex - degreeU + r][vSpanIndex - degreeV + s];
					}
				}
				int dd = std::min(derivative, dv);
				for (int l = 0; l <= dd; l++)
				{
					for (int s = 0; s <= degreeV; s++)
					{
						derivatives[k][l] += Nv[l][s] * temp[s];
					}
				}
			}
			return derivatives;
		}

		/// <summary>
		/// This is an optimized function of ComputeDerivatives for order 1 case.
		/// </summary>
		template <typename T>
		static void ComputeFirstOrderDerivative(const LN_BsplineSurface<T>& surface, UV uv,
			T derivatives[2][2])
		{
			int degreeU = surface.DegreeU;
			int degreeV = surface.DegreeV;
			const std::vector<double>& knotVectorU = surface.KnotVectorU;
			const std::vector<double>& knotVectorV = surface.KnotVectorV;
			const std::vector<std::vector<T>>& controlPoints = surface.ControlPoints;

			VALIDATE_ARGUMENT_RANGE(uv.GetU(), knotVectorU[0], knotVectorU[knotVectorU.size() - 1]);
			VALIDATE_ARGUMENT_RANGE(uv.GetV(), knotVectorV[0], knotVectorV[knotVectorV.size() - 1]);		

			int uSpanIndex = Polynomials::GetKnotSpanIndex(degreeU, knotVectorU, uv.GetU());
			double Nu[2][Constants::NURBSMaxDegree + 1];
			Polynomials::BasisFunctionsFirstOrderDerivative(uSpanIndex, degreeU, knotVectorU, uv.GetU(), Nu);

			int vSpanIndex = Polynomials::GetKnotSpanIndex(degreeV, knotVectorV, uv.GetV());
			double Nv[2][Constants::NURBSMaxDegree + 1];
			Polynomials::BasisFunctionsFirstOrderDerivative(vSpanIndex, degreeV, knotVectorV, uv.GetV(), Nv);

			int du = std::min(1, degreeU);
			int dv = std::min(1, degreeV);

			T temp[Constants::NURBSMaxDegree + 1];

			for (int k = 0; k <= du; k++)
			{
				for (int s = 0; s <= degreeV; s++)
				{
					temp[s] = T();
					for (int r = 0; r <= degreeU; r++)
					{
						temp[s] += Nu[k][r] * controlPoints[uSpanIndex - degreeU + r][vSpanIndex - degreeV + s];
					}
				}
				int dd = std::min(1, dv);
				for (int l = 0; l <= dd; l++)
				{
					for (int s = 0; s <= degreeV; s++)
					{
						derivatives[k][l] += Nv[l][s] * temp[s];
					}
				}
			}
		}

		/// <summary>
		/// The NURBS Book 2nd Edition Page114.
		/// Algorithm A3.7
		/// Compute control points of derivative surfaces.
		/// </summary>
		template <typename T>
		static std::vector<std::vector<std::vector<std::vector<T>>>> ComputeControlPointsOfDerivatives(const LN_BsplineSurface<T>& surface, int derivative, int minSpanIndexU, int maxSpanIndexU, int minSpanIndexV, int maxSpanIndexV, UV uv)
		{
			int degreeU = surface.DegreeU;
			int degreeV = surface.DegreeV;
			std::vector<double> knotVectorU = surface.KnotVectorU;
			std::vector<double> knotVectorV = surface.KnotVectorV;
			std::vector<std::vector<T>> controlPoints = surface.ControlPoints;

			VALIDATE_ARGUMENT(derivative > 0, "derivative", "derivative must be greater than zero.");
			VALIDATE_ARGUMENT_RANGE(minSpanIndexU, 0, maxSpanIndexU);
			VALIDATE_ARGUMENT_RANGE(minSpanIndexV, 0, maxSpanIndexV);
			VALIDATE_ARGUMENT_RANGE(uv.GetU(), knotVectorU[0], knotVectorU[knotVectorU.size() - 1]);
			VALIDATE_ARGUMENT_RANGE(uv.GetV(), knotVectorV[0], knotVectorV[knotVectorV.size() - 1]);	

			std::vector<std::vector<std::vector<std::vector<T>>>> PKL(derivative + 1,
				std::vector<std::vector<std::vector<T>>>(derivative + 1,
					std::vector<std::vector<T>>(controlPoints.size(), std::vector<T>(controlPoints[0].size()))));

			int du = std::min(derivative, degreeU);
			int dv = std::min(derivative, degreeV);
			int rangeU = maxSpanIndexU - minSpanIndexU;
			int rangeV = maxSpanIndexV - minSpanIndexV;

			for (int j = minSpanIndexV; j <= maxSpanIndexV; j++)
			{
				std::vector<T> points;
				for (int i = 0; i < controlPoints.size(); i++)
				{
					points.emplace_back(controlPoints[i][j]);
				}

				LN_BsplineCurve<T> bsplineCurve;
				bsplineCurve.Degree = degreeU;
				bsplineCurve.KnotVector = knotVectorU;
				bsplineCurve.ControlPoints = points;

				std::vector<std::vector<T>> temp = BsplineCurve::ComputeControlPointsOfDerivatives(bsplineCurve, du, minSpanIndexU, maxSpanIndexU);
				for (int k = 0; k <= du; k++)
				{
					for (int i = 0; i <= rangeU - k; i++)
					{
						PKL[k][0][i][j - minSpanIndexV] = temp[k][i];
					}
				}
			}
			std::vector<double> tempKv(knotVectorV.size(), minSpanIndexV);
			for (int k = 0; k < du; k++)
			{
				for (int i = 0; i <= rangeU - k; i++)
				{
					int dd = std::min(derivative - k, dv);

					LN_BsplineCurve<T> bsplineCurve;
					bsplineCurve.Degree = degreeV;
					bsplineCurve.KnotVector = tempKv;
					bsplineCurve.ControlPoints = PKL[k][0][i];

					std::vector<std::vector<T>> temp = BsplineCurve::ComputeControlPointsOfDerivatives(bsplineCurve, dd, 0, rangeV);
					for (int l = 1; l <= dd; l++)
					{
						for (int j = 0; j < rangeV - l; j++)
						{
							PKL[k][l][i][j] = temp[l][j];
						}
					}
				}
			}
			return PKL;
		}

		/// <summary>
		/// The NURBS Book 2nd Edition Page115.
		/// Algorithm A3.8
		/// Compute surface derivatives.
		/// </summary>
		template <typename T>
		static std::vector<std::vector<T>> ComputeDerivativesByAllBasisFunctions(const LN_BsplineSurface<T>& surface, int derivative, UV uv)
		{
			int degreeU = surface.DegreeU;
			int degreeV = surface.DegreeV;
			std::vector<double> knotVectorU = surface.KnotVectorU;
			std::vector<double> knotVectorV = surface.KnotVectorV;
			std::vector<std::vector<T>> controlPoints = surface.ControlPoints;

			VALIDATE_ARGUMENT(derivative > 0, "derivative", "derivative must be greater than zero.");
			VALIDATE_ARGUMENT_RANGE(uv.GetU(), knotVectorU[0], knotVectorU[knotVectorU.size() - 1]);
			VALIDATE_ARGUMENT_RANGE(uv.GetV(), knotVectorV[0], knotVectorV[knotVectorV.size() - 1]);
			
			std::vector<std::vector<T>> SKL(derivative + 1, std::vector<T>(derivative + 1));

			int uSpanIndex = Polynomials::GetKnotSpanIndex(degreeU, knotVectorU, uv.GetU());
			int vSpanIndex = Polynomials::GetKnotSpanIndex(degreeV, knotVectorV, uv.GetV());
			std::vector<std::vector<double>> Nu = Polynomials::AllBasisFunctions(uSpanIndex, degreeU, knotVectorU, uv.GetU());
			std::vector<std::vector<double>> Nv = Polynomials::AllBasisFunctions(vSpanIndex, degreeV, knotVectorV, uv.GetV());

			LN_BsplineSurface<T> bsplineSurface;
			bsplineSurface.DegreeU = degreeU;
			bsplineSurface.DegreeV = degreeV;
			bsplineSurface.KnotVectorU = knotVectorU;
			bsplineSurface.KnotVectorV = knotVectorV;
			bsplineSurface.ControlPoints = controlPoints;

			std::vector<std::vector<std::vector<std::vector<T>>>> PKL = ComputeControlPointsOfDerivatives(bsplineSurface, derivative, uSpanIndex - degreeU, uSpanIndex, vSpanIndex - degreeV, vSpanIndex, uv);

			int du = std::min(derivative, degreeU);
			int dv = std::min(derivative, degreeV);

			for (int k = 0; k <= du; k++)
			{
				int dd = std::min(derivative - k, dv);
				for (int l = 0; l <= dd; l++)
				{
					SKL[k][l] = T();
					for (int i = 0; i <= degreeV - l; i++)
					{
						T temp = T();
						for (int j = 0; j <= degreeU - k; j++)
						{
							temp += Nu[j][degreeU - k] * PKL[k][l][j][i];
						}
						SKL[k][l] += Nv[i][degreeV - l] * temp;
					}
				}
			}
			return SKL;
		}
	};
}


