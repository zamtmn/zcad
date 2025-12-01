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
#include "Constants.h"
#include <vector>

namespace LNLib
{
	class LNLIB_EXPORT MathUtils
	{

	public:

		/// <summary>
		/// According to https://referencesource.microsoft.com/#windowsbase/Shared/MS/Internal/DoubleUtil.cs,73bdd52106b3a9e3,references
		/// 
		/// Notice that Google Gtest EXPECT_NEAR is more restrict:
		/// https://github.com/google/googletest/blob/fa6de7f4382f5c8fb8b9e32eea28a2eb44966c32/googletest/include/gtest/gtest.h#L2001
		/// https://github.com/google/googletest/blob/fa6de7f4382f5c8fb8b9e32eea28a2eb44966c32/googletest/src/gtest.cc#L1661
		/// </summary>
		static bool IsAlmostEqualTo(double value1, double value2, double tolerance = Constants::DoubleEpsilon);

		static bool IsGreaterThan(double value1, double value2, double tolerance = Constants::DoubleEpsilon);

		static bool IsGreaterThanOrEqual(double value1, double value2, double tolerance = Constants::DoubleEpsilon);

		static bool IsLessThan(double value1, double value2, double tolerance = Constants::DoubleEpsilon);

		static bool IsLessThanOrEqual(double value1, double value2, double tolerance = Constants::DoubleEpsilon);

		static bool IsInfinite(double value);

		static bool IsNaN(double value);

		static double RadiansToAngle(double radians);

		static double AngleToRadians(double angle);

		static int Factorial(int number);

		static double Binomial(int number, int i);

		/// <summary>
		/// The NURBS Book 2nd Edition Page445
		/// Equation 9.102.
		/// </summary>
		static double ComputerCubicEquationsWithOneVariable(double cubic, double quadratic, double linear, double constant);

		template<typename T>
		static void Transpose(const std::vector<std::vector<T>>& matrix, std::vector<std::vector<T>>& transposed)
		{
			std::vector<T> temp;

			for (int i = 0; i < matrix[0].size(); i++)
			{
				for (int j = 0; j < matrix.size(); j++)
				{
					temp.emplace_back(matrix[j][i]);
				}
				transposed.emplace_back(temp);
				temp.erase(temp.begin(), temp.end());
			}
		}

		template<typename T>
		static std::vector<T> GetColumn(const std::vector<std::vector<T>>& matrix, int columnIndex)
		{
			int size = matrix.size();
			std::vector<T> result(size);
			for (int i = 0; i < size; i++)
			{
				result[i] = matrix[i][columnIndex];
			}
			return result;
		}

		static std::vector<std::vector<double>> MatrixMultiply(const std::vector<std::vector<double>>& left, const std::vector<std::vector<double>>& right);
	
		static std::vector<std::vector<double>> MakeDiagonal(int size);
		
		static std::vector<std::vector<double>> CreateMatrix(int row, int column);

		static double GetDeterminant(const std::vector<std::vector<double>>& matrix);

		static bool MakeInverse(const std::vector<std::vector<double>>& matrix, std::vector<std::vector<double>>& inverse);

		/// <summary>
		/// matrix * result = right.
		/// </summary>
		static std::vector<std::vector<double>> SolveLinearSystem(const std::vector<std::vector<double>>& matrix, const std::vector<std::vector<double>>& right);

		/// <summary>
		/// matrix * result = right.
		/// </summary>
		static bool SolveLinearSystemBanded(int matrixDimension, const std::vector<std::vector<double>>& matrix, int bandwidth, const std::vector<std::vector<double>>& right, std::vector<std::vector<double>>& result);
	};
}


