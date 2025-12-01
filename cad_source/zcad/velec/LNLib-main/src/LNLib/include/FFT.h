/*
*
* The FFT origin written by Takuya OOURA(Copyright) 1996-2001
* You may use, copy, modify and distribute this code for any purpose (include commercial use) and without fee. Please refer to this package when you modify this code.
* https://www.kurims.kyoto-u.ac.jp/~ooura/fft.html
*
Fast Fourier/Cosine/Sine Transform
	dimension   :one
	data length :power of 2
	decimation  :frequency
	radix       :2
	data        :inplace
	table       :not use
functions
	cdft: Complex Discrete Fourier Transform
	rdft: Real Discrete Fourier Transform
	ddct: Discrete Cosine Transform
	ddst: Discrete Sine Transform
	dfct: Cosine Transform of RDFT (Real Symmetric DFT)
	dfst: Sine Transform of RDFT (Real Anti-symmetric DFT)
function prototypes
	void cdft(int, double, double, double *);
	void rdft(int, double, double, double *);
	void ddct(int, double, double, double *);
	void ddst(int, double, double, double *);
	void dfct(int, double, double, double *);
	void dfst(int, double, double, double *);

-------- Complex DFT (Discrete Fourier Transform) --------
	[definition]
		<case1>
			X[k] = sum_j=0^n-1 x[j]*exp(2*pi*i*j*k/n), 0<=k<n
		<case2>
			X[k] = sum_j=0^n-1 x[j]*exp(-2*pi*i*j*k/n), 0<=k<n
		(notes: sum_j=0^n-1 is a summation from j=0 to n-1)
	[usage]
		<case1>
			cdft(2*n, cos(M_PI/n), sin(M_PI/n), a);
		<case2>
			cdft(2*n, cos(M_PI/n), -sin(M_PI/n), a);
	[parameters]
		2*n          :data length (int)
					  n >= 1, n = power of 2
		a[0...2*n-1] :input/output data (double *)
					  input data
						  a[2*j] = Re(x[j]), a[2*j+1] = Im(x[j]), 0<=j<n
					  output data
						  a[2*k] = Re(X[k]), a[2*k+1] = Im(X[k]), 0<=k<n
	[remark]
		Inverse of
			cdft(2*n, cos(M_PI/n), -sin(M_PI/n), a);
		is
			cdft(2*n, cos(M_PI/n), sin(M_PI/n), a);
			for (j = 0; j <= 2 * n - 1; j++) {
				a[j] *= 1.0 / n;
			}

-------- Real DFT / Inverse of Real DFT --------
	[definition]
		<case1> RDFT
			R[k] = sum_j=0^n-1 a[j]*cos(2*pi*j*k/n), 0<=k<=n/2
			I[k] = sum_j=0^n-1 a[j]*sin(2*pi*j*k/n), 0<k<n/2
		<case2> IRDFT (excluding scale)
			a[k] = R[0]/2 + R[n/2]/2 +
				   sum_j=1^n/2-1 R[j]*cos(2*pi*j*k/n) +
				   sum_j=1^n/2-1 I[j]*sin(2*pi*j*k/n), 0<=k<n
	[usage]
		<case1>
			rdft(n, cos(M_PI/n), sin(M_PI/n), a);
		<case2>
			rdft(n, cos(M_PI/n), -sin(M_PI/n), a);
	[parameters]
		n            :data length (int)
					  n >= 2, n = power of 2
		a[0...n-1]   :input/output data (double *)
					  <case1>
						  output data
							  a[2*k] = R[k], 0<=k<n/2
							  a[2*k+1] = I[k], 0<k<n/2
							  a[1] = R[n/2]
					  <case2>
						  input data
							  a[2*j] = R[j], 0<=j<n/2
							  a[2*j+1] = I[j], 0<j<n/2
							  a[1] = R[n/2]
	[remark]
		Inverse of
			rdft(n, cos(M_PI/n), sin(M_PI/n), a);
		is
			rdft(n, cos(M_PI/n), -sin(M_PI/n), a);
			for (j = 0; j <= n - 1; j++) {
				a[j] *= 2.0 / n;
			}

-------- DCT (Discrete Cosine Transform) / Inverse of DCT --------
	[definition]
		<case1> IDCT (excluding scale)
			C[k] = sum_j=0^n-1 a[j]*cos(pi*j*(k+1/2)/n), 0<=k<n
		<case2> DCT
			C[k] = sum_j=0^n-1 a[j]*cos(pi*(j+1/2)*k/n), 0<=k<n
	[usage]
		<case1>
			ddct(n, cos(M_PI/n/2), sin(M_PI/n/2), a);
		<case2>
			ddct(n, cos(M_PI/n/2), -sin(M_PI/n/2), a);
	[parameters]
		n            :data length (int)
					  n >= 2, n = power of 2
		a[0...n-1]   :input/output data (double *)
					  output data
						  a[k] = C[k], 0<=k<n
	[remark]
		Inverse of
			ddct(n, cos(M_PI/n/2), -sin(M_PI/n/2), a);
		is
			a[0] *= T(0.5);
			ddct(n, cos(M_PI/n/2), sin(M_PI/n/2), a);
			for (j = 0; j <= n - 1; j++) {
				a[j] *= 2.0 / n;
			}

-------- DST (Discrete Sine Transform) / Inverse of DST --------
	[definition]
		<case1> IDST (excluding scale)
			S[k] = sum_j=1^n A[j]*sin(pi*j*(k+1/2)/n), 0<=k<n
		<case2> DST
			S[k] = sum_j=0^n-1 a[j]*sin(pi*(j+1/2)*k/n), 0<k<=n
	[usage]
		<case1>
			ddst(n, cos(M_PI/n/2), sin(M_PI/n/2), a);
		<case2>
			ddst(n, cos(M_PI/n/2), -sin(M_PI/n/2), a);
	[parameters]
		n            :data length (int)
					  n >= 2, n = power of 2
		a[0...n-1]   :input/output data (double *)
					  <case1>
						  input data
							  a[j] = A[j], 0<j<n
							  a[0] = A[n]
						  output data
							  a[k] = S[k], 0<=k<n
					  <case2>
						  output data
							  a[k] = S[k], 0<k<n
							  a[0] = S[n]
	[remark]
		Inverse of
			ddst(n, cos(M_PI/n/2), -sin(M_PI/n/2), a);
		is
			a[0] *= T(0.5);
			ddst(n, cos(M_PI/n/2), sin(M_PI/n/2), a);
			for (j = 0; j <= n - 1; j++) {
				a[j] *= 2.0 / n;
			}

-------- Cosine Transform of RDFT (Real Symmetric DFT) --------
	[definition]
		C[k] = sum_j=0^n a[j]*cos(pi*j*k/n), 0<=k<=n
	[usage]
		dfct(n, cos(M_PI/n), sin(M_PI/n), a);
	[parameters]
		n            :data length - 1 (int)
					  n >= 2, n = power of 2
		a[0...n]     :input/output data (double *)
					  output data
						  a[k] = C[k], 0<=k<=n
	[remark]
		Inverse of
			a[0] *= T(0.5);
			a[n] *= T(0.5);
			dfct(n, cos(M_PI/n), sin(M_PI/n), a);
		is
			a[0] *= T(0.5);
			a[n] *= T(0.5);
			dfct(n, cos(M_PI/n), sin(M_PI/n), a);
			for (j = 0; j <= n; j++) {
				a[j] *= 2.0 / n;
			}

-------- Sine Transform of RDFT (Real Anti-symmetric DFT) --------
	[definition]
		S[k] = sum_j=1^n-1 a[j]*sin(pi*j*k/n), 0<k<n
	[usage]
		dfst(n, cos(M_PI/n), sin(M_PI/n), a);
	[parameters]
		n            :data length + 1 (int)
					  n >= 2, n = power of 2
		a[0...n-1]   :input/output data (double *)
					  output data
						  a[k] = S[k], 0<k<n
					  (a[0] is used for work area)
	[remark]
		Inverse of
			dfst(n, cos(M_PI/n), sin(M_PI/n), a);
		is
			dfst(n, cos(M_PI/n), sin(M_PI/n), a);
			for (j = 1; j <= n - 1; j++) {
				a[j] *= 2.0 / n;
			}
*/

/* -------------------------------------------------------------------- */

/*
 * Author:
 * 2024/01/23 - Yuqing Liang (BIMCoder Liang)
 * bim.frankliang@foxmail.com
 * 
 *
 * Use of this source code is governed by a LGPL-2.1 license that can be found in
 * the LICENSE file.
 */

#pragma once
#include <vector>

namespace LNLib {

	template <class T>
	void bitrv2(int n, std::vector<T>& a)
	{
		int j, j1, k, k1, l, m, m2, n2;
		T xr, xi;

		m = n >> 2;
		m2 = m << 1;
		n2 = n - 2;
		k = 0;
		for (j = 0; j <= m2 - 4; j += 4) {
			if (j < k) {
				xr = a[j];
				xi = a[j + 1];
				a[j] = a[k];
				a[j + 1] = a[k + 1];
				a[k] = xr;
				a[k + 1] = xi;
			}
			else if (j > k) {
				j1 = n2 - j;
				k1 = n2 - k;
				xr = a[j1];
				xi = a[j1 + 1];
				a[j1] = a[k1];
				a[j1 + 1] = a[k1 + 1];
				a[k1] = xr;
				a[k1 + 1] = xi;
			}
			k1 = m2 + k;
			xr = a[j + 2];
			xi = a[j + 3];
			a[j + 2] = a[k1];
			a[j + 3] = a[k1 + 1];
			a[k1] = xr;
			a[k1 + 1] = xi;
			l = m;
			while (k >= l) {
				k -= l;
				l >>= 1;
			}
			k += l;
		}
	}


	template <class T>
	void cdft(int n, T wr, T wi, std::vector<T>& a)
	{
		int i, j, k, l, m;
		T wkr, wki, wdr, wdi, ss, xr, xi;

		m = n;
		while (m > 4) {
			l = m >> 1;
			wkr = 1;
			wki = 0;
			wdr = 1 - 2 * wi * wi;
			wdi = 2 * wi * wr;
			ss = 2 * wdi;
			wr = wdr;
			wi = wdi;
			for (j = 0; j <= n - m; j += m) {
				i = j + l;
				xr = a[j] - a[i];
				xi = a[j + 1] - a[i + 1];
				a[j] += a[i];
				a[j + 1] += a[i + 1];
				a[i] = xr;
				a[i + 1] = xi;
				xr = a[j + 2] - a[i + 2];
				xi = a[j + 3] - a[i + 3];
				a[j + 2] += a[i + 2];
				a[j + 3] += a[i + 3];
				a[i + 2] = wdr * xr - wdi * xi;
				a[i + 3] = wdr * xi + wdi * xr;
			}
			for (k = 4; k <= l - 4; k += 4) {
				wkr -= ss * wdi;
				wki += ss * wdr;
				wdr -= ss * wki;
				wdi += ss * wkr;
				for (j = k; j <= n - m + k; j += m) {
					i = j + l;
					xr = a[j] - a[i];
					xi = a[j + 1] - a[i + 1];
					a[j] += a[i];
					a[j + 1] += a[i + 1];
					a[i] = wkr * xr - wki * xi;
					a[i + 1] = wkr * xi + wki * xr;
					xr = a[j + 2] - a[i + 2];
					xi = a[j + 3] - a[i + 3];
					a[j + 2] += a[i + 2];
					a[j + 3] += a[i + 3];
					a[i + 2] = wdr * xr - wdi * xi;
					a[i + 3] = wdr * xi + wdi * xr;
				}
			}
			m = l;
		}
		if (m > 2) {
			for (j = 0; j <= n - 4; j += 4) {
				xr = a[j] - a[j + 2];
				xi = a[j + 1] - a[j + 3];
				a[j] += a[j + 2];
				a[j + 1] += a[j + 3];
				a[j + 2] = xr;
				a[j + 3] = xi;
			}
		}
		if (n > 4) {
			bitrv2(n, a);
		}
	}


	template <class T>
	void rdft(int n, T wr, T wi, std::vector<T>& a)
	{
		int j, k;
		T wkr, wki, wdr, wdi, ss, xr, xi, yr, yi;

		if (n > 4) {
			wkr = 0;
			wki = 0;
			wdr = wi * wi;
			wdi = wi * wr;
			ss = 4 * wdi;
			wr = 1 - 2 * wdr;
			wi = 2 * wdi;
			if (wi >= 0) {
				cdft(n, wr, wi, a);
				xi = a[0] - a[1];
				a[0] += a[1];
				a[1] = xi;
			}
			for (k = (n >> 1) - 4; k >= 4; k -= 4) {
				j = n - k;
				xr = a[k + 2] - a[j - 2];
				xi = a[k + 3] + a[j - 1];
				yr = wdr * xr - wdi * xi;
				yi = wdr * xi + wdi * xr;
				a[k + 2] -= yr;
				a[k + 3] -= yi;
				a[j - 2] += yr;
				a[j - 1] -= yi;
				wkr += ss * wdi;
				wki += ss * (T(0.5) - wdr);
				xr = a[k] - a[j];
				xi = a[k + 1] + a[j + 1];
				yr = wkr * xr - wki * xi;
				yi = wkr * xi + wki * xr;
				a[k] -= yr;
				a[k + 1] -= yi;
				a[j] += yr;
				a[j + 1] -= yi;
				wdr += ss * wki;
				wdi += ss * (T(0.5) - wkr);
			}
			j = n - 2;
			xr = a[2] - a[j];
			xi = a[3] + a[j + 1];
			yr = wdr * xr - wdi * xi;
			yi = wdr * xi + wdi * xr;
			a[2] -= yr;
			a[3] -= yi;
			a[j] += yr;
			a[j + 1] -= yi;
			if (wi < 0) {
				a[1] = T(0.5) * (a[0] - a[1]);
				a[0] -= a[1];
				cdft(n, wr, wi, a);
			}
		}
		else {
			if (wi < 0) {
				a[1] = T(0.5) * (a[0] - a[1]);
				a[0] -= a[1];
			}
			if (n > 2) {
				xr = a[0] - a[2];
				xi = a[1] - a[3];
				a[0] += a[2];
				a[1] += a[3];
				a[2] = xr;
				a[3] = xi;
			}
			if (wi >= 0) {
				xi = a[0] - a[1];
				a[0] += a[1];
				a[1] = xi;
			}
		}
	}


	template <class T>
	void ddct(int n, T wr, T wi, std::vector<T>& a)
	{
		int j, k, m;
		T wkr, wki, wdr, wdi, ss, xr;

		if (n > 2) {
			wkr = T(0.5);
			wki = T(0.5);
			wdr = T(0.5) * (wr - wi);
			wdi = T(0.5) * (wr + wi);
			ss = 2 * wi;
			if (wi < 0) {
				xr = a[n - 1];
				for (k = n - 2; k >= 2; k -= 2) {
					a[k + 1] = a[k] - a[k - 1];
					a[k] += a[k - 1];
				}
				a[1] = 2 * xr;
				a[0] *= 2;
				rdft(n, 1 - ss * wi, ss * wr, a);
				xr = wdr;
				wdr = wdi;
				wdi = xr;
				ss = -ss;
			}
			m = n >> 1;
			for (k = 1; k <= m - 3; k += 2) {
				j = n - k;
				xr = wdi * a[k] - wdr * a[j];
				a[k] = wdr * a[k] + wdi * a[j];
				a[j] = xr;
				wkr -= ss * wdi;
				wki += ss * wdr;
				xr = wki * a[k + 1] - wkr * a[j - 1];
				a[k + 1] = wkr * a[k + 1] + wki * a[j - 1];
				a[j - 1] = xr;
				wdr -= ss * wki;
				wdi += ss * wkr;
			}
			k = m - 1;
			j = n - k;
			xr = wdi * a[k] - wdr * a[j];
			a[k] = wdr * a[k] + wdi * a[j];
			a[j] = xr;
			a[m] *= wki + ss * wdr;
			if (wi >= 0) {
				rdft(n, 1 - ss * wi, ss * wr, a);
				xr = a[1];
				for (k = 2; k <= n - 2; k += 2) {
					a[k - 1] = a[k] - a[k + 1];
					a[k] += a[k + 1];
				}
				a[n - 1] = xr;
			}
		}
		else {
			if (wi >= 0) {
				xr = T(0.5) * (wr + wi) * a[1];
				a[1] = a[0] - xr;
				a[0] += xr;
			}
			else {
				xr = a[0] - a[1];
				a[0] += a[1];
				a[1] = T(0.5) * (wr - wi) * xr;
			}
		}
	}


	template <class T>
	void ddst(int n, T wr, T wi, std::vector<T>& a)
	{
		int j, k, m;
		T wkr, wki, wdr, wdi, ss, xr;

		if (n > 2) {
			wkr = T(0.5);
			wki = T(0.5);
			wdr = T(0.5) * (wr - wi);
			wdi = T(0.5) * (wr + wi);
			ss = 2 * wi;
			if (wi < 0) {
				xr = a[n - 1];
				for (k = n - 2; k >= 2; k -= 2) {
					a[k + 1] = a[k] + a[k - 1];
					a[k] -= a[k - 1];
				}
				a[1] = -2 * xr;
				a[0] *= 2;
				rdft(n, 1 - ss * wi, ss * wr, a);
				xr = wdr;
				wdr = -wdi;
				wdi = xr;
				wkr = -wkr;
			}
			m = n >> 1;
			for (k = 1; k <= m - 3; k += 2) {
				j = n - k;
				xr = wdi * a[j] - wdr * a[k];
				a[k] = wdr * a[j] + wdi * a[k];
				a[j] = xr;
				wkr -= ss * wdi;
				wki += ss * wdr;
				xr = wki * a[j - 1] - wkr * a[k + 1];
				a[k + 1] = wkr * a[j - 1] + wki * a[k + 1];
				a[j - 1] = xr;
				wdr -= ss * wki;
				wdi += ss * wkr;
			}
			k = m - 1;
			j = n - k;
			xr = wdi * a[j] - wdr * a[k];
			a[k] = wdr * a[j] + wdi * a[k];
			a[j] = xr;
			a[m] *= wki + ss * wdr;
			if (wi >= 0) {
				rdft(n, 1 - ss * wi, ss * wr, a);
				xr = a[1];
				for (k = 2; k <= n - 2; k += 2) {
					a[k - 1] = a[k + 1] - a[k];
					a[k] += a[k + 1];
				}
				a[n - 1] = -xr;
			}
		}
		else {
			if (wi >= 0) {
				xr = T(0.5) * (wr + wi) * a[1];
				a[1] = xr - a[0];
				a[0] += xr;
			}
			else {
				xr = a[0] + a[1];
				a[0] -= a[1];
				a[1] = T(0.5) * (wr - wi) * xr;
			}
		}
	}


	template <class T>
	void bitrv(int n, std::vector<T>& a)
	{
		int j, k, l, m, m2, n1;
		T xr;

		if (n > 2) {
			m = n >> 2;
			m2 = m << 1;
			n1 = n - 1;
			k = 0;
			for (j = 0; j <= m2 - 2; j += 2) {
				if (j < k) {
					xr = a[j];
					a[j] = a[k];
					a[k] = xr;
				}
				else if (j > k) {
					xr = a[n1 - j];
					a[n1 - j] = a[n1 - k];
					a[n1 - k] = xr;
				}
				xr = a[j + 1];
				a[j + 1] = a[m2 + k];
				a[m2 + k] = xr;
				l = m;
				while (k >= l) {
					k -= l;
					l >>= 1;
				}
				k += l;
			}
		}
	}


	template <class T>
	void dfct(int n, T wr, T wi, std::vector<T>& a)
	{
		int j, k, m, mh;
		T xr, xi, an;

		m = n >> 1;
		for (j = 0; j <= m - 1; j++) {
			k = n - j;
			xr = a[j] + a[k];
			a[j] -= a[k];
			a[k] = xr;
		}
		an = a[n];
		while (m >= 2) {
			ddct(m, wr, wi, a);
			xr = 1 - 2 * wi * wi;
			wi *= 2 * wr;
			wr = xr;
			bitrv(m, a);
			mh = m >> 1;
			xi = a[m];
			a[m] = a[0];
			a[0] = an - xi;
			an += xi;
			for (j = 1; j <= mh - 1; j++) {
				k = m - j;
				xr = a[m + k];
				xi = a[m + j];
				a[m + j] = a[j];
				a[m + k] = a[k];
				a[j] = xr - xi;
				a[k] = xr + xi;
			}
			xr = a[mh];
			a[mh] = a[m + mh];
			a[m + mh] = xr;
			m = mh;
		}
		xi = a[1];
		a[1] = a[0];
		a[0] = an + xi;
		a[n] = an - xi;
		bitrv(n, a);
	}


	template <class T>
	void dfst(int n, T wr, T wi, std::vector<T>& a)
	{
		int j, k, m, mh;
		T xr, xi;

		m = n >> 1;
		for (j = 1; j <= m - 1; j++) {
			k = n - j;
			xr = a[j] - a[k];
			a[j] += a[k];
			a[k] = xr;
		}
		a[0] = a[m];
		while (m >= 2) {
			ddst(m, wr, wi, a);
			xr = 1 - 2 * wi * wi;
			wi *= 2 * wr;
			wr = xr;
			bitrv(m, a);
			mh = m >> 1;
			for (j = 1; j <= mh - 1; j++) {
				k = m - j;
				xr = a[m + k];
				xi = a[m + j];
				a[m + j] = a[j];
				a[m + k] = a[k];
				a[j] = xr + xi;
				a[k] = xr - xi;
			}
			a[m] = a[0];
			a[0] = a[m + mh];
			a[m + mh] = a[mh];
			m = mh;
		}
		a[1] = a[0];
		a[0] = 0;
		bitrv(n, a);
	}
}
