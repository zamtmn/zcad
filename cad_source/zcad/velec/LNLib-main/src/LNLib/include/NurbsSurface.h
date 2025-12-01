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
#include "LNObject.h"
#include "LNEnums.h"
#include <vector>

namespace LNLib
{
	class UV;
	class XYZ;
	class XYZW;
	class LNLIB_EXPORT NurbsSurface
	{
	public:

		static void Check(const LN_NurbsSurface& surface);

		/// <summary>
		/// The NURBS Book 2nd Edition Page134
		/// Algorithm A4.3
		/// Compute point on rational B-spline surface.
		/// </summary>
		static XYZ GetPointOnSurface(const LN_NurbsSurface& surface, UV uv);

		/// <summary>
		/// The NURBS Book 2nd Edition Page137
		/// Algorithm A4.4
		/// Compute S(paramU,paramV) derivatives.
		/// </summary>
		static std::vector<std::vector<XYZ>> ComputeRationalSurfaceDerivatives(const LN_NurbsSurface& surface, int derivative, UV uv);

		/// <summary>
		/// This is an optimized function of ComputeRationalSurfaceDerivatives, for order 1 case.
		/// </summary>
		static void ComputeRationalSurfaceFirstOrderDerivative(const LN_NurbsSurface& surface, UV uv, XYZ& S, XYZ& Su, XYZ& Sv);

		static double Curvature(const LN_NurbsSurface& surface, SurfaceCurvature curvature, UV uv);

		static XYZ Normal(const LN_NurbsSurface& surface, UV uv);

		/// <summary>
		/// Swap surface UV.
		/// </summary>
		static void Swap(const LN_NurbsSurface& surface, LN_NurbsSurface& result);

		/// <summary>
		/// Reverse surface U or V direction.
		/// </summary>
		static void Reverse(const LN_NurbsSurface& surface, SurfaceDirection direction,  LN_NurbsSurface& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page137
		/// Algorithm A5.3
		/// Surface knot insertion along U or V direction.
		/// </summary>
		static void InsertKnot(const LN_NurbsSurface& surface, double insertKnot, int times, bool isUDirection, LN_NurbsSurface& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page167
		/// Algorithm A5.5
		/// Refine surface knot vector.
		/// </summary>
		static void RefineKnotVector(const LN_NurbsSurface& surface, const std::vector<double>& insertKnotElements, bool isUDirection, LN_NurbsSurface& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page177
		/// Algorithm A5.7
		/// Decompose surface into Bezier patches.
		/// </summary>
		static std::vector<LN_NurbsSurface> DecomposeToBeziers(const LN_NurbsSurface& surface);

		/// <summary>
		/// The NURBS Book 2nd Edition Page186
		/// Surface knot removal.
		/// </summary>
		static void RemoveKnot(const LN_NurbsSurface& surface, double removeKnot, int times, bool isUDirection, LN_NurbsSurface& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page209
		/// Algorithm A5.10
		/// Degree elevate a surface t times.
		/// </summary>
		static void ElevateDegree(const LN_NurbsSurface& surface, int times, bool isUDirection, LN_NurbsSurface& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page227
		/// Degree reduce U or V Direction Bezier-shape nurbs curve from degree to degree - 1.
		/// </summary>
		static bool ReduceDegree(const LN_NurbsSurface& surface, bool isUDirection, LN_NurbsSurface& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page232
		/// Equally spaced parameter values on each candidate span.
		/// </summary>
		static void EquallyTessellate(const LN_NurbsSurface& surface, std::vector<XYZ>& tessellatedPoints, std::vector<UV>& correspondingKnots);

		///  [0][0]  [0][1] ... ...  [0][m]     ------- v direction
		///  [1][0]  [1][1] ... ...  [1][m]    |
		///    .                               |
		///    .                               u direction
		///    .							   
		///  [n][0]  [n][1] ... ...  [n][m]    
		static bool IsClosed(const LN_NurbsSurface& surface, bool isUDirection);

		/// <summary>
		/// The NURBS Book 2nd Edition Page232
		/// Point inversion:finding the corresponding parameter make S(u,v) = P.
		/// </summary>
		static UV GetParamOnSurface(const LN_NurbsSurface& surface, const XYZ& givenPoint);

		/// <summary>
		/// Experimental:
		/// According to https://jcst.ict.ac.cn/fileup/1000-9000/PDF/2019-6-9-9388.pdf
		/// A Geometric Strategy Algorithm for Orthogonal Projection onto a Parametric Surface
		/// </summary>
		static UV GetParamOnSurfaceByGSA(const LN_NurbsSurface& surface, const XYZ& givenPoint);

		static void Reparametrize(const LN_NurbsSurface& surface, double minU, double maxU, double minV, double maxV, LN_NurbsSurface& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page235
		/// Surface Tangent Vector Inversion: finding the corresponding UV tangent [du dv] make T = Su*du+Sv*dv.
		/// </summary>
		static bool GetUVTangent(const LN_NurbsSurface& surface, const UV param, const XYZ& tangent, UV& uvTangent);
		
		/// <summary>
		/// The NURBS Book 2nd Edition Page334
		/// Create a bilinear surface.
		/// 
		/// ------- v direction
		/// |
		/// |
		/// u direction
		///   
		/// </summary>
		static void CreateBilinearSurface(const XYZ& topLeftPoint, const XYZ& topRightPoint, const XYZ& bottomLeftPoint, const XYZ& bottomRightPoint, LN_NurbsSurface& surface);

		/// <summary>
		/// The NURBS Book 2nd Edition Page336
		/// Create a right cirular cylinder.
		/// </summary>
		static bool CreateCylindricalSurface(const XYZ& origin, const XYZ& xAxis, const XYZ& yAxis, double startRad, double endRad, double radius, double height, LN_NurbsSurface& surface);

		/// <summary>
		/// The NURBS Book 2nd Edition Page337
		/// Create a ruled surface.
		/// </summary>
		static void CreateRuledSurface(const LN_NurbsCurve& curve0, const LN_NurbsCurve& curve1, LN_NurbsSurface& surface);

		/// <summary>
		/// The NURBS Book 2nd Edition Page346
		/// Algorithm A8.1
		/// Create a revolved surface.
		/// </summary>
		static bool CreateRevolvedSurface(const XYZ& origin, const XYZ& axis, double rad, const LN_NurbsCurve& profile, LN_NurbsSurface& surface);

		/// <summary>
		/// The NURBS Book 2nd Edition Page348
		/// Nonuniform scaling of surface.
		/// </summary>
		static std::vector<std::vector<XYZW>> NonUniformScaling(const std::vector<std::vector<XYZW>>& controlPoints, double xFactor, double yFactor, double zFactor, const XYZ& referencePoint);

		/// <summary>
		/// The NURBS Book 2nd Edition Page359
		/// Algorithm A8.2
		/// Create NURBS corner fillet surface.
		/// 
		/// Curve1,2,3 are three boundary arcs and could arbitrarily positioned and oriented in space but joined at their endpoints. 
		/// The parameter 'arc' represents curve2;
		/// </summary>
		static void MakeCornerFilletSurface(const LN_NurbsCurve& arc, LN_NurbsSurface& surface);

		/// <summary>
		/// The NURBS Book 2nd Edition Page380
		/// Algorithm A9.4
		/// Global surface interpolation.
		/// </summary>
		static void GlobalInterpolation(const std::vector<std::vector<XYZ>>& throughPoints, int degreeU, int degreeV, LN_NurbsSurface& surface);

		/// <summary>
		/// The NURBS Book 2nd Edition Page404
		/// Algorithm A9.5
		/// Local surface interpolation through (n+1)*(m+1) points.
		/// </summary>
		static bool BicubicLocalInterpolation(const std::vector<std::vector<XYZ>>& throughPoints, LN_NurbsSurface& surface);

		/// <summary>
		/// The NURBS Book 2nd Edition Page422
		/// Algorithm A9.7
		/// Global surface approximation with fixed number of control points.
		/// </summary>
		static bool GlobalApproximation(const std::vector<std::vector<XYZ>>& throughPoints, int degreeU, int degreeV, int controlPointsRows, int controlPointsColumns, LN_NurbsSurface& surface);

		/// <summary>
		/// The NURBS Book 2nd Edition Page456
		/// Create swung surface.
		/// The profile curve lie on the xz-plane and trajectory curve along its y-axis.
		/// </summary>
		static bool CreateSwungSurface(const LN_NurbsCurve& profile, const LN_NurbsCurve& trajectory, double scale, LN_NurbsSurface& surface);

		/// <summary>
		/// The NURBS Book 2nd Edition Page457
		/// Create loft surface (called Skinned Surface in The NURBS Book).
		/// </summary>
		static void CreateLoftSurface(const std::vector<LN_NurbsCurve>& sections, LN_NurbsSurface& surface, 
										int customTrajectoryDegree = 0, const std::vector<double>& customTrajectoryKnotVector = {});

		/// <summary>
		/// The NURBS Book 2nd Edition Page472
		/// Create generalized translational sweep surface.
		/// </summary>
		static void CreateGeneralizedTranslationalSweepSurface(const LN_NurbsCurve& profile, const LN_NurbsCurve& trajectory, LN_NurbsSurface& surface);

		/// <summary>
		/// The NURBS Book 2nd Edition Page475
		/// Algorithm A10.1
		/// Create sweep surface by trajectory interpolated.
		/// Profile must lie on XOY plane.
		/// </summary>
		static void CreateSweepSurface(const LN_NurbsCurve& profile, const LN_NurbsCurve& trajectory, int minimumProfiles, LN_NurbsSurface& surface);

		/// <summary>
		/// The NURBS Book 2nd Edition Page477
		/// Algorithm A10.2
		/// Create sweep surface by trajectory not interpolated.
		/// Profile must lie on XOY plane.
		/// </summary>
		static void CreateSweepSurface(const LN_NurbsCurve& profile, const LN_NurbsCurve& trajectory, int minimumProfiles, int customTrajectoryDegree, LN_NurbsSurface& surface);

		/// <summary>
		/// The NURBS Book 2nd Edition Page494
		/// Algorithm A10.3
		/// Create Gordon surface.
		/// Gordon surface has a number of restrictions:
		/// 1. All input curves must be NURBS or NURBS-like. Only non-rational curves are supported - i.e., without weights (or all weights equal).
		/// 2. All U-curves must be have “the same” direction; all V-curves must be also have “the same” direction.
		/// 3. There must be N curves along one direction, and M curves along another direction, which must be exactly intersect at N x M points.
		/// 4. Intersection points must be located evenly in parameter spaces of curves. 
		/// 5. U-curves must be ordered along direction of V-curves, and vice versa. 
		/// </summary>
		static void CreateGordonSurface(const std::vector<LN_NurbsCurve>& uCurves, const std::vector<LN_NurbsCurve>& vCurves, const std::vector<std::vector<XYZ>>& intersectionPoints, LN_NurbsSurface& surface);

		/// <summary>
		/// The NURBS Book 2nd Edition Page502
		/// Algorithm A10.4
		/// Create Coons surface.
		/// The difference between Coons and Gordon is that Coons surface is created by 4 anti-clock curves.
		/// The Coons surface is the special case of Gordon Surface.
		/// </summary>
		static void CreateCoonsSurface(const LN_NurbsCurve& leftCurve, const LN_NurbsCurve& bottomCurve, const LN_NurbsCurve& rightCurve, const LN_NurbsCurve& topCurve, LN_NurbsSurface& surface);

		/// <summary>
		/// Calculate surface area.
		/// </summary>
		static double ApproximateArea(const LN_NurbsSurface& surface, IntegratorType type = IntegratorType::GaussLegendre);

		/// <summary>
		/// Triangulate nurbs surface.
		/// 1. if useDelaunay = true，it is more accurate but need more time. Algorithm according to https://github.com/nortikin/sverchok/blob/master/utils/adaptive_surface.py
		/// 2. if useDelaunay = false, it is simple and run faster.
		/// </summary>
		static LN_Mesh Triangulate(const LN_NurbsSurface& surface, int resolutionU, int resolutionV, bool useDelaunay);
	};
}
