# coding: latin-1
# Copyright (c) 2009,2010,2011,2012,2013,2014 Dirk Baechle.
# www: https://bitbucket.org/dirkbaechle/dottoxml
# mail: dl9obn AT darc.de
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
"""
  %dottoxml.py [options] <infile.dot> <outfile.graphml>

  convert a DOT file to Graphml XML (and various other formats)
"""

import sys
import locale
import optparse

import dot

# Usage message
usgmsg = "Usage: dottoxml.py [options] infile.dot outfile.graphml"

def usage():
    print "dottoxml 1.6, 2014-04-10, Dirk Baechle\n"
    print usgmsg
    print "Hint: Try '-h' or '--help' for further infos!"

def exportDot(o, nodes, edges, options):
    o.write("graph [\n")

    for k,nod in nodes.iteritems():
        nod.exportDot(o,options)
    for el in edges:
        el.exportDot(o,nodes,options)

def exportGML(o, nodes, edges, options):
    o.write("graph [\n")
    o.write("  comment \"Created by dottoxml.py\"\n")
    o.write("  directed 1\n")
    o.write("  IsPlanar 1\n")

    for k,nod in nodes.iteritems():
        nod.exportGML(o,options)
    for el in edges:
        el.exportGML(o,nodes,options)

    o.write("]\n")

def exportGraphml(o, nodes, edges, options):
    import xml.dom.minidom
    doc = xml.dom.minidom.Document()
    root = doc.createElement(u'graphml')
    root.setAttribute(u'xmlns',u'http://graphml.graphdrawing.org/xmlns')
    root.setAttribute(u'xmlns:xsi',u'http://www.w3.org/2001/XMLSchema-instance')
    root.setAttribute(u'xmlns:y',u'http://www.yworks.com/xml/graphml')
    root.setAttribute(u'xsi:schemaLocation',u'http://graphml.graphdrawing.org/xmlns http://www.yworks.com/xml/schema/graphml/1.0/ygraphml.xsd')
    doc.appendChild(root)        
    key = doc.createElement(u'key')
    key.setAttribute(u'for',u'node')    
    key.setAttribute(u'id',u'd0')    
    key.setAttribute(u'yfiles.type',u'nodegraphics')    
    root.appendChild(key)

    key = doc.createElement(u'key')
    key.setAttribute(u'attr.name',u'description')    
    key.setAttribute(u'attr.type',u'string')    
    key.setAttribute(u'for',u'node')    
    key.setAttribute(u'id',u'd1')    
    root.appendChild(key)

    key = doc.createElement(u'key')
    key.setAttribute(u'for',u'edge')    
    key.setAttribute(u'id',u'd2')    
    key.setAttribute(u'yfiles.type',u'edgegraphics')    
    root.appendChild(key)

    key = doc.createElement(u'key')
    key.setAttribute(u'attr.name',u'description')    
    key.setAttribute(u'attr.type',u'string')    
    key.setAttribute(u'for',u'edge')    
    key.setAttribute(u'id',u'd3')    
    root.appendChild(key)

    key = doc.createElement(u'key')
    key.setAttribute(u'for',u'graphml')    
    key.setAttribute(u'id',u'd4')    
    key.setAttribute(u'yfiles.type',u'resources')    
    root.appendChild(key)

    graph = doc.createElement(u'graph')
    graph.setAttribute(u'edgedefault',u'directed')    
    graph.setAttribute(u'id',u'G')    
    graph.setAttribute(u'parse.edges',u'%d' % len(edges))   
    graph.setAttribute(u'parse.nodes',u'%d' % len(nodes))
    graph.setAttribute(u'parse.order', u'free')    
    
    for k,nod in nodes.iteritems():
        nod.exportGraphml(doc, graph, options)
    for el in edges:
        el.exportGraphml(doc, graph, nodes, options)

    root.appendChild(graph)
    
    data = doc.createElement(u'data')
    data.setAttribute(u'key',u'd4')    
    res = doc.createElement(u'y:Resources')
    data.appendChild(res)    
    root.appendChild(data)
    
    o.write(doc.toxml(encoding="utf-8"))

def exportGDF(o, nodes, edges, options):
    o.write("nodedef> name\n")
    for k,nod in nodes.iteritems():
        nod.exportGDF(o, options)
    for el in edges:
        el.exportGDF(o,nodes,options)
    o.write("edgedef> node1,node2\n")

def main():
    parser = optparse.OptionParser(usage=usgmsg)
    parser.add_option('-f', '--format',
                      action='store', dest='format', default='Graphml',
                      help='selects the output format (Graphml|GML|GDF) [default : %default]')
    parser.add_option('-v', '--verbose',
                      action='store_true', dest='verbose', default=False,
                      help='enables messages (infos, warnings)')
    parser.add_option('-s', '--sweep',
                      action='store_true', dest='sweep', default=False,
                      help='sweep nodes (remove nodes that are not connected)')
    parser.add_option('--nn', '--no-nodes',
                      action='store_false', dest='NodeLabels', default=True,
                      help='do not output any node labels [Graphml]')
    parser.add_option('--ne', '--no-edges',
                      action='store_false', dest='EdgeLabels', default=True,
                      help='do not output any edge labels [Graphml]')
    parser.add_option('--nu', '--no-uml',
                      action='store_false', dest='NodeUml', default=True,
                      help='do not output any node methods/attributes in UML [Graphml]')
    parser.add_option('--na', '--no-arrows',
                      action='store_false', dest='Arrows', default=True,
                      help='do not output any arrows [Graphml]')
    parser.add_option('--nc', '--no-colors',
                      action='store_false', dest='Colors', default=True,
                      help='do not output any colors [Graphml]')
    parser.add_option('--la', '--lump-attributes',
                      action='store_true', dest='LumpAttributes', default=False,
                      help='lump class attributes/methods together with the node label [Graphml]')
    parser.add_option('--sc', '--separator-char',
                      action='store', dest='SepChar', default='_', metavar='SEPCHAR',
                      help='default separator char when lumping attributes/methods [default : "_"]')
    parser.add_option('--ae', '--auto-edges',
                      action='store_true', dest='EdgeLabelsAutoComplete', default=False,
                      help='auto-complete edge labels')
    parser.add_option('--ah', '--arrowhead',
                      action='store', dest='DefaultArrowHead', default='standard', metavar='TYPE',
                      help='sets the default appearance of arrow heads for edges (normal|diamond|dot|...) [default : %default]')
    parser.add_option('--at', '--arrowtail',
                      action='store', dest='DefaultArrowTail', default='none', metavar='TYPE',
                      help='sets the default appearance of arrow tails for edges (normal|diamond|dot|...) [default : %default]')
    parser.add_option('--cn', '--color-nodes',
                      action='store', dest='DefaultNodeColor', default='#CCCCFF', metavar='COLOR',
                      help='default node color [default : "#CCCCFF"]')
    parser.add_option('--ce', '--color-edges',
                      action='store', dest='DefaultEdgeColor', default='#000000', metavar='COLOR',
                      help='default edge color [default : "#000000"]')
    parser.add_option('--cnt', '--color-nodes-text',
                      action='store', dest='DefaultNodeTextColor', default='#000000', metavar='COLOR',
                      help='default node text color for labels [default : "#000000"]')
    parser.add_option('--cet', '--color-edges-text',
                      action='store', dest='DefaultEdgeTextColor', default='#000000', metavar='COLOR',
                      help='default edge text color for labels [default : "#000000"]')
    parser.add_option('--ienc', '--input-encoding',
                      action='store', dest='InputEncoding', default='', metavar='ENCODING',
                      help='override encoding for input file [default : locale setting]')
    parser.add_option('--oenc', '--output-encoding',
                      action='store', dest='OutputEncoding', default='', metavar='ENCODING',
                      help='override encoding for text output files [default : locale setting]')

    options, args = parser.parse_args()
    
    if len(args) < 2:
        usage()
        sys.exit(1)

    infile = args[0]
    outfile = args[1]

    options.DefaultNodeColor = dot.colorNameToRgb(options.DefaultNodeColor, '#CCCCFF')
    options.DefaultEdgeColor = dot.colorNameToRgb(options.DefaultEdgeColor, '#000000')
    options.DefaultNodeTextColor = dot.colorNameToRgb(options.DefaultNodeTextColor, '#000000')
    options.DefaultEdgeTextColor = dot.colorNameToRgb(options.DefaultEdgeTextColor, '#000000')
    
    preferredEncoding = locale.getpreferredencoding()
    if options.InputEncoding == "":
        options.InputEncoding = preferredEncoding
    if options.OutputEncoding == "":
        options.OutputEncoding = preferredEncoding
    
    if options.verbose:
        print "Input file: %s " % infile
        print "Output file: %s " % outfile
        print "Output format: %s" % options.format.lower()
        print "Input encoding: %s" % options.InputEncoding
        if options.format.lower() == "graphml":
            print "Output encoding: utf-8 (fix for Graphml)"
        else:
            print "Output encoding: %s" % options.OutputEncoding

    # Collect nodes and edges
    nodes = {}
    edges = []
    default_edge = None
    default_node = None
    nid = 1
    eid = 1
    f = open(infile, 'r')
    content = f.read().splitlines()
    f.close()

    idx = 0
    while idx < len(content):
        l = unicode(content[idx], options.InputEncoding)
        if '->' in l:
            # Check for multiline edge
            if '[' in l and ']' not in l:
                ml = ""
                while ']' not in ml:
                    idx += 1
                    ml = unicode(content[idx], options.InputEncoding)
                    l = ' '.join([l.rstrip(), ml.lstrip()])
            # Process edge
            e = dot.Edge()
            e.initFromString(l)
            e.id = eid
            eid += 1
            if default_edge:
                e.complementAttributes(default_edge)
            edges.append(e)
        elif '[' in l:
            # Check for multiline node
            if ']' not in l:
                ml = ""
                while ']' not in ml:
                    idx += 1
                    ml = unicode(content[idx], options.InputEncoding)
                    l = ' '.join([l.rstrip(), ml.lstrip()])
            # Process node
            n = dot.Node()
            n.initFromString(l)
            lowlabel = n.label.lower()
            if (lowlabel != 'graph' and
                lowlabel != 'edge' and
                lowlabel != 'node'):
                n.id = nid
                nid += 1
                if default_node:
                    n.complementAttributes(default_node)
                nodes[n.label] = n
            else:
                if lowlabel == 'edge':
                    default_edge = n
                elif lowlabel == 'node':
                    default_node = n   
        elif 'charset=' in l:
            # Pick up input encoding from DOT file
            li = l.strip().split('=')
            if len(li) == 2:
                ienc = li[1].strip('"')
                if ienc != "":
                    options.InputEncoding = ienc
                    if options.verbose:
                        print "Info: Picked up input encoding '%s' from the DOT file." % ienc
        idx += 1

    # Add single nodes, if required
    for e in edges:
        if not nodes.has_key(e.src):
            n = dot.Node()
            n.label = e.src
            n.id = nid
            nid += 1
            nodes[e.src] = n
        if not nodes.has_key(e.dest):
            n = dot.Node()
            n.label = e.dest
            n.id = nid
            nid += 1
            nodes[e.dest] = n
        nodes[e.src].referenced = True
        nodes[e.dest].referenced = True

    if options.verbose:
        print "\nNodes: %d " % len(nodes)
        print "Edges: %d " % len(edges)
    
    if options.sweep:
        rnodes = {}
        for key, n in nodes.iteritems():
            if n.referenced:
                rnodes[key] = n
        nodes = rnodes
        if options.verbose:
            print "\nNodes after sweep: %d " % len(nodes)
    
    # Output
    o = open(outfile, 'w')
    format = options.format.lower()
    if format == 'dot':
        exportDot(o, nodes, edges, options)
    elif format == 'graphml':
        exportGraphml(o, nodes, edges, options)
    elif format == 'gdf':
        exportGDF(o, nodes, edges, options)
    else: # GML
        exportGML(o, nodes, edges, options)
    o.close()

    if options.verbose:
        print "\nDone."

if __name__ == '__main__':
    main()
    
