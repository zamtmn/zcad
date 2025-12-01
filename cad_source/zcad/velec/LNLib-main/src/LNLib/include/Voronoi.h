/*
MapManager library for the conversion, manipulation and analysis
of maps used in Mobile Robotics research.
Copyright (C) 2005 Shane O'Sullivan

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

email: shaneosullivan1@gmail.com
*/

/*
 * Author:
 * 2024/04/06 - Yuqing Liang (BIMCoder Liang)
 * bim.frankliang@foxmail.com
 * 
 *
 * Use of this source code is governed by a LGPL-2.1 license that can be found in
 * the LICENSE file.
 */

#pragma once

#include <cmath>
#include <vector>
#include "LNLibDefinitions.h"

#ifndef NULL
#define NULL 0
#endif
#define DELETED -2

#define le 0
#define re 1

namespace LNLib
{
	struct Freenode
	{
		struct	Freenode* nextfree;
	};

	struct FreeNodeArrayList
	{
		struct	Freenode* memory;
		struct	FreeNodeArrayList* next;
	};

	struct Freelist
	{
		struct	Freenode* head;
		int		nodesize;
	};

	struct PointVDG
	{
		float x, y;
	};

	struct Point3
	{
		float x, y, z;
		int count;
	};

	struct VertexLink
	{
		PointVDG coord;
		PointVDG v[3];
		int count;
	};

	// structure used both for sites and for vertices 
	struct Site
	{
		struct	PointVDG	coord;
		int		sitenbr;
		int		refcnt;
		int		overallRefcnt;
	};

	struct Edge
	{
		float   a, b, c;
		struct	Site* ep[2];
		struct	Site* reg[2];
		int		edgenbr;

	};

	struct GraphEdge
	{
		float x1, y1, x2, y2;
		//	long v1,v2; //vertices that this was created from
		struct GraphEdge* next;
	};

	struct Halfedge
	{
		struct	Halfedge* ELleft, * ELright;
		struct	Edge* ELedge;
		int		ELrefcnt;
		char	ELpm;
		struct	Site* vertex;
		float	ystar;
		struct	Halfedge* PQnext;
	};

	class LNLIB_EXPORT VoronoiDiagramGenerator
	{
	public:
		VoronoiDiagramGenerator();
		~VoronoiDiagramGenerator();

		bool generateVoronoi(float* xValues, float* yValues, int numPoints,
			float minX, float maxX, float minY, float maxY, float minDist, bool genVectorInfo = true);

		//By default, the delaunay triangulation is NOT generated
		void setGenerateDelaunay(bool genDel);

		//By default, the voronoi diagram IS generated
		void setGenerateVoronoi(bool genVor);

		void resetIterator()
		{
			iteratorEdges = allEdges;
		}

		bool getNext(float& x1, float& y1, float& x2, float& y2)
		{
			if (iteratorEdges == 0)
				return false;

			x1 = iteratorEdges->x1;
			x2 = iteratorEdges->x2;
			y1 = iteratorEdges->y1;
			y2 = iteratorEdges->y2;

			iteratorEdges = iteratorEdges->next;

			return true;
		}

		void resetDelaunayEdgesIterator()
		{
			iteratorDelaunayEdges = delaunayEdges;
		}

		bool getNextDelaunay(float& x1, float& y1, float& x2, float& y2)
		{
			if (iteratorDelaunayEdges == 0)
			{
				return false;
			}
			x1 = iteratorDelaunayEdges->x1;
			x2 = iteratorDelaunayEdges->x2;
			y1 = iteratorDelaunayEdges->y1;
			y2 = iteratorDelaunayEdges->y2;

			iteratorDelaunayEdges = iteratorDelaunayEdges->next;
			return true;
		}

		void resetVertexPairIterator()
		{
			currentVertexLink = 0;
		}

		bool getNextVertexPair(float& x1, float& y1, float& x2, float& y2);

		void resetVerticesIterator()
		{
			currentVertex = 0;
		}

		bool getNextVertex(float& x, float& y)
		{
			if (finalVertices == 0)
				return false;

			if (currentVertex >= sizeOfFinalVertices) return false;
			x = finalVertices[currentVertex].x;
			y = finalVertices[currentVertex].y;
			currentVertex++;
			return true;
		}

		void reset();
		std::vector<std::vector<int>> getTriangles();

	private:

		std::vector<std::vector<int>> triangles;

		void cleanup();
		void cleanupEdges();
		char* getfree(struct Freelist* fl);
		struct	Halfedge* PQfind();
		int PQempty();

		struct	Halfedge** ELhash;
		struct	Halfedge*  HEcreate();
		struct	Halfedge** ELleft();
		struct	Halfedge** ELright();
		struct	Halfedge** ELleftbnd();
		struct	Halfedge*  HEcreate(struct Edge* e, int pm);

		struct PointVDG PQ_min();
		struct Halfedge* PQextractmin();
		void freeinit(struct Freelist* fl, int size);
		void makefree(struct Freenode* curr, struct Freelist* fl);
		void geominit();
		void plotinit();
		bool voronoi(bool genVectorInfo);
		void ref(struct Site* v);
		void deref(struct Site* v);
		void endpoint(struct Edge* e, int lr, struct Site* s);

		void ELdelete(struct Halfedge* he);
		struct Halfedge* ELleftbnd(struct PointVDG* p);
		struct Halfedge* ELright(struct Halfedge* he);
		void makevertex(struct Site* v);
		void out_triple(struct Site* s1, struct Site* s2, struct Site* s3);

		void		PQinsert(struct Halfedge* he, struct Site* v, float offset);
		void		PQdelete(struct Halfedge* he);
		bool		ELinitialize();
		void		ELinsert(struct	Halfedge* lb, struct Halfedge* newHe);
		struct Halfedge* ELgethash(int b);
		struct Halfedge* ELleft(struct Halfedge* he);
		struct Site* leftreg(struct Halfedge* he);
		bool		PQinitialize();
		int			PQbucket(struct Halfedge* he);
		void		clip_line(struct Edge* e);
		char* myalloc(unsigned n);
		int			right_of(struct Halfedge* el, struct PointVDG* p);

		struct Site* rightreg(struct Halfedge* he);
		struct Edge* bisect(struct	Site* s1, struct	Site* s2);
		float dist(struct Site* s, struct Site* t);
		struct Site* intersect(struct Halfedge* el1, struct Halfedge* el2, struct PointVDG* p = 0);

		void		out_bisector(struct Edge* e);
		struct Site* nextone();

		void		pushGraphEdge(float x1, float y1, float x2, float y2);
		void		pushDelaunayGraphEdge(float x1, float y1, float x2, float y2);

		void		line(float x1, float y1, float x2, float y2);
		void		circle(float x, float y, float radius);
		void		range(float minX, float minY, float maxX, float maxY);

		void  		insertVertexAddress(long vertexNum, struct Site* address);
		void		insertVertexLink(long vertexNum, long vertexLinkedTo);
		void		generateVertexLinks();

		bool		genDelaunay;
		bool		genVoronoi;

		struct		Freelist	hfl;
		struct		Halfedge* ELleftend, * ELrightend;
		int 		ELhashsize;

		int			triangulate, sorted, plot, debug;
		float		xmin, xmax, ymin, ymax, deltax, deltay;

		struct		Site* sites;
		int			nsites;
		int			siteidx;
		int			sqrt_nsites;
		int			nvertices;
		struct 		Freelist sfl;
		struct		Site* bottomsite;

		int			nedges;
		struct		Freelist efl;
		int			PQhashsize;
		struct		Halfedge* PQhash;
		int			PQcount;
		int			PQmin;

		int			ntry, totalsearch;
		float		pxmin, pxmax, pymin, pymax, cradius;
		int			total_alloc;

		float		borderMinX, borderMaxX, borderMinY, borderMaxY;

		FreeNodeArrayList* allMemoryList;
		FreeNodeArrayList* currentMemoryBlock;

		GraphEdge* allEdges;
		GraphEdge* iteratorEdges;

		GraphEdge* delaunayEdges;
		GraphEdge* iteratorDelaunayEdges;

		Point3* vertexLinks; //lists all the vectors that each vector is directly connected to	
		long		sizeOfVertexLinks;

		Site** vertices;
		long		sizeOfVertices;

		VertexLink* finalVertexLinks;
		long 		sizeOfFinalVertexLinks;
		long		currentVertexLink;

		PointVDG* finalVertices;
		long		sizeOfFinalVertices;
		long 		currentVertex;

		float		minDistanceBetweenSites;
	};

	int scomp(const void* p1, const void* p2);
}
