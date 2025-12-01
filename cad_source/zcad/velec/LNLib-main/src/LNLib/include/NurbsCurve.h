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

#include "LNEnums.h"
#include "LNLibDefinitions.h"
#include "LNObject.h"
#include "LNEnums.h"
#include <vector>

namespace LNLib
{
	class XYZ;
	class XYZW;
	class Matrix4d;
	class LNLIB_EXPORT NurbsCurve
	{
	public:

		/// <summary>
		/// Check curve whether fits NURBS.
		/// </summary>
		static void Check(const LN_NurbsCurve& curve);

		/// <summary>
		/// The NURBS Book 2nd Edition Page124
		/// Algorithm A4.1
		/// Compute point on rational B-spline curve.
		/// </summary>
		static XYZ GetPointOnCurve(const LN_NurbsCurve& curve, double paramT);

		/// <summary>
		/// The NURBS Book 2nd Edition Page127
		/// Algorithm A4.2
		/// Compute C(paramT) derivatives from Cw(paramT) derivatives.
		/// </summary>
		static std::vector<XYZ> ComputeRationalCurveDerivatives(const LN_NurbsCurve& curve, int derivative, double paramT);

		/// <summary>
		/// Computer left and right hand derivatives.
		/// </summary>
		static bool CanComputerDerivative(const LN_NurbsCurve& curve, double paramT);

		/// <summary>
		/// Calculate curve curvature.
		/// </summary>
		static double Curvature(const LN_NurbsCurve& curve, double paramT);

		/// <summary>
		/// Calculate curve torsion.
		/// </summary>
		static double Torsion(const LN_NurbsCurve& curve, double paramT);

		/// <summary>
		/// The NURBS Book 2nd Edition Page151
		/// Algorithm A5.1
		/// Curve knot insertion.
		/// Note that multiplicity + times <= degree.
		/// </summary>
		static int InsertKnot(const LN_NurbsCurve& curve, double insertKnot, int times, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page155
		/// Algorithm A5.2
		/// Computes point on rational B-spline curve.
		/// </summary>
		static XYZ GetPointOnCurveByCornerCut(const LN_NurbsCurve& curve, double paramT);

		/// <summary>
		/// The NURBS Book 2nd Edition Page164
		/// Algorithm A5.4
		/// Refine curve knot vector.
		/// </summary>
		static void RefineKnotVector(const LN_NurbsCurve& curve, const std::vector<double>& insertKnotElements, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page173
		/// Algorithm A5.6
		/// Decompose curve into Bezier segements.
		/// </summary>
		static std::vector<LN_NurbsCurve> DecomposeToBeziers(const LN_NurbsCurve& curve);

		/// <summary>
		/// The NURBS Book 2nd Edition Page185
		/// Algorithm A5.8
		/// Curve knot removal.
		/// </summary>
		static bool RemoveKnot(const LN_NurbsCurve& curve, double removeKnot, int times, LN_NurbsCurve& result);

		/// <summary>
		/// Remove excessive knots.
		/// </summary>
		static void RemoveExcessiveKnots(const LN_NurbsCurve& curve, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page206
		/// Algorithm A5.9
		/// Degree elevate a curve t times.
		/// </summary>
		static void ElevateDegree(const LN_NurbsCurve& curve, int times, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page223
		/// Algorithm A5.11
		/// Degree reduce a bezier-shape nurbs curve from degree to degree - 1.
		/// </summary>
		static bool ReduceDegree(const LN_NurbsCurve& curve, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page230
		/// Equally spaced parameter values on each candidate span.
		/// </summary>
		static void EquallyTessellate(const LN_NurbsCurve& curve, std::vector<XYZ>& tessellatedPoints, std::vector<double>& correspondingKnots);

		/// <summary>
		/// Detemine curve is closed.
		/// Close means end point equals start point or points overlap.
		/// </summary>
		static bool IsClosed(const LN_NurbsCurve& curve);

		/// <summary>
		/// The NURBS Book 2nd Edition Page230
		/// Point inversion:finding the corresponding parameter make C(u) = P.
		/// </summary>
		static double GetParamOnCurve(const LN_NurbsCurve& curve, const XYZ& givenPoint);

		/// <summary>
		/// The NURBS Book 2nd Edition Page236
		/// Curve make Transform.
		/// </summary>
		static void CreateTransformed(const LN_NurbsCurve& curve, const Matrix4d& matrix, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page241
		/// Reparameterization of curve.
		/// </summary>
		static void Reparametrize(const LN_NurbsCurve& curve, double min, double max, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page255
		/// Reparameterization using a linear rational function : (alpha * u + beta)/(gamma * u + delta)
		/// </summary>
		static void Reparametrize(const LN_NurbsCurve& curve, double alpha, double beta, double gamma, double delta, LN_NurbsCurve& result);
		
		/// <summary>
		/// The NURBS Book 2nd Edition Page263
		/// Curve reverse,but not use reparameterization.
		/// </summary>
		static void Reverse(const LN_NurbsCurve& curve, LN_NurbsCurve& result);

		/// <summary>
		/// Split curve at certain parameter.
		/// </summary>
		static bool SplitAt(const LN_NurbsCurve& curve, double parameter, LN_NurbsCurve& left, LN_NurbsCurve& right);

		/// <summary>
		/// Segment curve.
		/// </summary>
		static bool Segment(const LN_NurbsCurve& curve, double startParameter, double endParameter, LN_NurbsCurve& segment);

		/// <summary>
		/// Merge two connected curves to one curve.
		/// </summary>
		static bool Merge(const LN_NurbsCurve& left, const LN_NurbsCurve& right, LN_NurbsCurve& result);

		/// <summary>
		/// Offset curve makes bigger or smaller.
		/// </summary>
		static void Offset(const LN_NurbsCurve& curve, double offset, OffsetType type, LN_NurbsCurve& result);

		/// <summary>
		/// Create line represented by NURBS.
		/// </summary>
		static void CreateLine(const XYZ& start, const XYZ& end, LN_NurbsCurve& result);

		/// <summary>
		/// The SISL Reference Manual v4.4 Page30 s1379
		/// Create cubic hermite spline by interpolation.
		/// </summary>
		static void CreateCubicHermite(const std::vector<XYZ>& throughPoints, const std::vector<XYZ>& tangents, LN_NurbsCurve& curve);

		/// <summary>
		/// The NURBS Book 2nd Edition Page308
		/// Algorithm A7.1
		/// Create arbitrary NURBS arc.
		/// </summary>
		static bool CreateArc(const XYZ& center, const XYZ& xAxis, const XYZ& yAxis, double startRad, double endRad, double xRadius, double yRadius, LN_NurbsCurve& curve);

		/// <summary>
		/// The NURBS Book 2nd Edition Page314
		/// Algorithm A7.2
		/// Create one Bezier conic arc.
		/// </summary>
		static bool CreateOneConicArc(const XYZ& start, const XYZ& startTangent, const XYZ& end, const XYZ& endTangent, const XYZ& pointOnConic, XYZ& projectPoint, double& projectPointWeight);

		/// <summary>
		/// The NURBS Book 2nd Edition Page317
		/// Split arc.
		/// </summary>
		static void SplitArc(const XYZ& start, const XYZ& projectPoint, double projectPointWeight, const XYZ& end, XYZ& insertPointAtStartSide, XYZ& splitPoint, XYZ& insertPointAtEndSide, double insertWeight);

		/// <summary>
		/// The NURBS Book 2nd Edition Page317
		/// Algorithm A7.3
		/// Create open conic arc.
		/// </summary>
		static bool CreateOpenConic(const XYZ& start, const XYZ& startTangent, const XYZ& end, const XYZ& endTangent, const XYZ& pointOnConic, LN_NurbsCurve& curve);

		/// <summary>
		/// The NURBS Book 2nd Edition Page369
		/// Algorithm A9.1
		/// Global interpolation through n+1 points.
		/// </summary>
		static void GlobalInterpolation(int degree, const std::vector<XYZ>& throughPoints, LN_NurbsCurve& curve, const std::vector<double>& params = {});

		/// <summary>
		/// The NURBS Book 2nd Edition Page369 - 374
		/// Global interpolation by through points and tangents. (including Algorithm A9.2)
		/// </summary>
		static void GlobalInterpolation(int degree, const std::vector<XYZ>& throughPoints, const std::vector<XYZ>& tangents, double tangentFactor, LN_NurbsCurve& curve);

		/// <summary>
		/// The NURBS Book 2nd Edition Page395
		/// Local cubic curve interpolation by through points.
		/// </summary>
		static bool CubicLocalInterpolation(const std::vector<XYZ>& throughPoints, LN_NurbsCurve& curve);

		/// <summary>
		/// The NURBS Book 2nd Edition Page410
		/// Least square curve approximation.
		/// 
		/// Referenced from https://github.com/iTwin/imodel-native (Bentley Software): 
		///		MSBsplineCurve::GeneralLeastSquaresApproximation.
		/// </summary>
		static bool LeastSquaresApproximation(int degree, const std::vector<XYZ>& throughPoints, int controlPointsCount, LN_NurbsCurve& curve);

		/// <summary>
		/// The NURBS Book 2nd Edition Page413
		/// Algorithm A9.6
		/// Weighted and contrained least squares approximation.
		/// </summary>
		static bool WeightedAndContrainedLeastSquaresApproximation(int degree, const std::vector<XYZ>& throughPoints, const std::vector<double>& throughPointWeights, const std::vector<XYZ>& tangents, const std::vector<int>& tangentIndices, const std::vector<double>& tangentWeights, int controlPointsCount, LN_NurbsCurve& curve);

		/// <summary>
		/// The NURBS Book 2nd Edition Page428
		/// Algorithm A9.8
		/// Get knot removal error bound (nonrational).
		/// </summary>
		static double ComputerRemoveKnotErrorBound(const LN_NurbsCurve& curve, int removalIndex);

		/// <summary>
		/// The NURBS Book 2nd Edition Page429
		/// Algorithm A9.9
		/// Remove knots from curve by given bound.
		/// </summary>
		static void RemoveKnotsByGivenBound(const LN_NurbsCurve& curve, const std::vector<double> params, std::vector<double>& errors, double maxError, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page431
		/// Algorithm A9.10
		/// Global curve approximation to within bound maxError.
		/// </summary>
		static void GlobalApproximationByErrorBound(int degree, const std::vector<XYZ>& throughPoints, double maxError, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page440
		/// Algorithm A9.11
		/// Fit to tolerance with conic segment.
		/// </summary>
		static bool FitWithConic(const std::vector<XYZ>& throughPoints, int startPointIndex, int endPointIndex, const XYZ& startTangent, const XYZ& endTangent, double maxError, std::vector<XYZW>& middleControlPoints);

		/// <summary>
		/// The NURBS Book 2nd Edition Page448
		/// Algorithm A9.12
		/// Fit to tolerance with cubic segment.
		/// </summary>
		static bool FitWithCubic(const std::vector<XYZ>& throughPoints, int startPointIndex, int endPointIndex, const XYZ& startTangent, const XYZ& endTangent, double maxError, std::vector<XYZW>& middleControlPoints);

		/// <summary>
		/// The NURBS Book 2nd Edition Page479
		/// Calculate curve normal direction.
		/// </summary>
		static XYZ Normal(const LN_NurbsCurve& curve, CurveNormal normalType, double paramT);

		/// <summary>
		/// The NURBS Book 2nd Edition Page481
		/// Projection normal method invented by Siltanen and Woodward.
		/// </summary>
		static std::vector<XYZ> ProjectNormal(const LN_NurbsCurve& curve);

		/// <summary>
		/// The NURBS Book 2nd Edition Page511
		/// Reposition an arbitrary control point.
		/// </summary>
		static bool ControlPointReposition(const LN_NurbsCurve& curve, double parameter, int moveIndex, XYZ moveDirection, double moveDistance, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page520
		/// Modify one curve weight.
		/// </summary>
		static void WeightModification(const LN_NurbsCurve& curve, double parameter, int moveIndex, double moveDistance, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page526
		/// Modify two neighboring curve weights. (moveIndex and moveIndex + 1)
		/// </summary>
		static bool NeighborWeightsModification(const LN_NurbsCurve& curve, double parameter, int moveIndex, double moveDistance, double scale, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page533
		/// </summary>
		static void Warping(const LN_NurbsCurve& curve, const std::vector<double>& warpShape, double warpDistance, const XYZ& planeNormal, double startParameter, double endParameter, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page542
		/// </summary>
		static bool Flattening(const LN_NurbsCurve& curve, XYZ lineStartPoint, XYZ lineEndPoint, double startParameter, double endParameter, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page547
		/// </summary>
		static void Bending(const LN_NurbsCurve& curve, double startParameter, double endParameter, XYZ bendCenter, double radius, double crossRatio, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page555
		/// Constraint-based curve modification.
		/// </summary>
		static void ConstraintBasedModification(const LN_NurbsCurve& curve, const std::vector<double>& constraintParams, const std::vector<XYZ>& derivativeConstraints, const std::vector<int>& appliedIndices, const std::vector<int>& appliedDegree, const std::vector<int>& fixedControlPointIndices, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page572
		/// </summary>
		static bool IsClamp(const LN_NurbsCurve& curve);

		/// <summary>
		/// The NURBS Book 2nd Edition Page572
		/// Clamp a unclamped curve.
		/// </summary>
		static void ToClampCurve(const LN_NurbsCurve& curve, LN_NurbsCurve& result);

		/// <summary>
		/// The NURBS Book 2nd Edition Page575
		/// UnClamped, uniform and C[degree-1] continues closed curve.
		/// </summary>
		static bool IsPeriodic(const LN_NurbsCurve& curve);

		/// <summary>
		/// The NURBS Book 2nd Edition Page577
		/// Algorithm A12.1
		/// Unclamp a clamped curve.
		/// </summary>
		static void ToUnclampCurve(const LN_NurbsCurve& curve, LN_NurbsCurve& result);

		/// <summary>
		/// Detemine curve whether is linear.
		/// </summary>
		static bool IsLinear(const LN_NurbsCurve& curve);

		/// <summary>
		/// Detemine curve whether is arc.
		/// </summary>
		static bool IsArc(const LN_NurbsCurve& curve, LN_ArcInfo& arcInfo);

		/// <summary>
		/// Calculate curve arc length.
		/// </summary>
		static double ApproximateLength(const LN_NurbsCurve& curve, IntegratorType type = IntegratorType::GaussLegendre);

		/// <summary>
		/// Calculate parameter makes first segment length equals to given length.
		/// </summary>
		static double GetParamOnCurve(const LN_NurbsCurve& curve, double givenLength, IntegratorType type = IntegratorType::GaussLegendre);

		/// <summary>
		/// Calculate parameters makes every segments length equals to given length.
		/// </summary>
		static std::vector<double> GetParamsOnCurve(const LN_NurbsCurve& curve, double givenLength, IntegratorType type = IntegratorType::GaussLegendre);

		/// <summary>
		/// Tessellate nurbs curve.
		/// </summary>
		static std::vector<XYZ> Tessellate(const LN_NurbsCurve& curve);
	};
}


