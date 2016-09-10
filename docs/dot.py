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
  Helper classes and functions for the dottoxml.py tool
"""

import re
import X11Colors

r_label = re.compile(r'label\s*=\s*"\s*\{[^\}]*\}\s*"\s*')
r_labelstart = re.compile(r'label\s*=\s*"\s*\{')
r_labelclose = re.compile(r'\}\s*"')

# Default output encoding for the ASCII output formats GML and GDF
latinenc = "latin-1"

def compileAttributes(attribs):
    """ return the list of attributes as a DOT text string """
    atxt = ""
    first = True
    for key, value in attribs.iteritems():
        if not first:
            atxt += ", %s=\"%s\"" % (key, value)
        else:
            atxt += "%s=\"%s\"" % (key, value)
            first = False
            
    return "[%s]" % atxt

def parseAttributes(attribs):
    """ parse the attribute list and return a key/value dict for it """
    adict = {}
    tlist = []
    lmode = False
    ltext = ''
    # First pass: split entries by ,
    for a in attribs.split(','):
        if r_label.findall(a):
            tlist.append(a)
        elif r_labelstart.findall(a):
            ltext = a
            lmode = True
        else:
            if lmode:
                ltext += ",%s" % a
                if r_labelclose.findall(a):
                    lmode = False
                    tlist.append(ltext)
            else:
                tlist.append(a)

    # Second pass: split keys from values by =
    for t in tlist:
        apos = findUnquoted(t, '=')
        if apos > 0:
            adict[t[:apos].strip()] = t[apos+1:].strip().strip('"')

    return adict

def getLabelAttributes(label):
    """ return the sections of the label attributes in a list structure """
    sections = []
    slist = label.split('|')
    for s in slist:
        mlist = []
        s = s.replace('\\r','\\l')
        s = s.replace('\\n','\\l')
        alist = s.split('\\l')
        for a in alist:
            a = a.strip()
            if a != "":
                mlist.append(a)
        sections.append(mlist)
    return sections

def colorNameToRgb(fcol, defaultcol):
    """ convert the color name fcol to an RGB string, if required """
    if not fcol.startswith('#'):
        return X11Colors.color_map.get(fcol, defaultcol)
    else:
        return fcol
    
def getColorAttribute(attribs, key, defaultcol, conf):
    """ extract the color for the attribute key and convert it
        to RGB format if required
    """
    if conf.Colors:
        if attribs.has_key(key):
            return colorNameToRgb(attribs[key], defaultcol)
    return defaultcol

def escapeNewlines(label):
    """ convert the newline escape sequences in the given label """
    l = label.replace('\\n','\n')
    l = l.replace('\\l','\n')
    l = l.replace('\\r','\n')
    return l

def findUnescapedQuote(string, spos=0, qchar='"'):
    """ Return the position of the next unescaped quote
        character in the given string, starting at the
        position spos.
        Returns a -1, if no occurrence was found.
    """
    qpos = -1
    
    escaped = 0
    for idx, c in enumerate(string[spos:]):
        if not escaped:
            if c == '\\':
                escaped = 1
            elif c == qchar:
                return idx+spos
        else:
            escaped = 0
        
    return qpos

def findUnquoted(string, char, spos=0, qchar='"'):
    """ Return the position of the next unquoted
        character char in the given string.
        Searching for the next position starts at
        spos, while parsing the quote characters is
        always done from the start of the string.
        Returns a -1, if no occurrence was found.
        Warning: Assumes that the user never searches for an
        actual quote char with this, but uses findUnescapedQuote
        instead (see above).
    """

    # Do we find a quote char at all?
    if string.find(qchar) >= 0:
        # Yes, so try to count matching quotes
        inquotes = 0
        # Find first quote char
        qpos = findUnescapedQuote(string, 0, qchar)
        if qpos >= 0:
            inquotes = 1 - inquotes
        # Find first char to search for
        fpos = string.find(char, spos)
        while fpos >= 0 and qpos >= 0 and qpos < fpos:
            # Keep track of quote chars (inside/outside),
            # until we reach a position after the char to search for
            while qpos < fpos and qpos >= 0:
                qpos = findUnescapedQuote(string, qpos+1, qchar)
                if qpos >= 0:
                    # Toggle inside/outside counter with each found quote char
                    inquotes = 1 - inquotes
            # Did we enter a quoted environment? 
            if qpos > fpos and inquotes:
                # Then, our last occurrence of the char to search for
                # wasn't quoted and we found our match...
                return fpos
            else:
                if qpos < 0:
                    if inquotes:
                        # Catch unbalanced quoted environments
                        return -1
                    else:
                        # No further quote chars follow,
                        # so simply return our current match
                        return fpos
                # Continue search with next char position,
                # outside the current quoted environment
                while fpos < qpos and fpos >= 0:
                    fpos = string.find(char, fpos+1)
        # Couldn't find any further occurrence of the char
        return fpos
    else:
        # Return result for a simple search
        return string.find(char, spos)

def findLastUnquoted(string, char, spos=0, qchar='"'):
    """ Return the position of the last unquoted
        character char in the given string.
        Searching for the last position starts at
        spos, while parsing the quote characters is
        always done from the start of the string.
        Returns a -1, if no occurrence was found.
        Warning: Assumes that the user never searches for an
        actual quote char with this, but uses findUnescapedQuote
        instead (see above).
    """
    lastpos = findUnquoted(string, char, spos, qchar)
    if lastpos >= 0:
        curpos = findUnquoted(string, char, lastpos+1, qchar)
        while curpos > 0:
            lastpos = curpos
            curpos = findUnquoted(string, char, lastpos+1, qchar)
            
    return lastpos

class Node:
    """ a single node in the graph """
    def __init__(self):
        self.label = ""
        self.id = 0
        self.attribs = {}
        self.referenced = False
        self.sections = []

    def initFromString(self, line):
        """ extract node info from the given text line """
        spos = findUnquoted(line, '[')
        atts = ""
        if spos >= 0:
            epos = findLastUnquoted(line, ']', spos)
            if epos > 0:
                atts = line[spos+1:epos]
                line = line[:spos] + line[epos+1:]
                line = line.strip()
            else:
                atts = line[spos+1:]
                line = line[:spos].strip()
            if line.startswith('node '):
                line = line[5:]
                line = line.lstrip()
                # Hack that allows a single "node [attributes]"
                # with default values...
                tline = line.rstrip(';')
                tline = tline.rstrip()
                if len(tline) == 0:
                    line = 'node ' + line
        # Strip off trailing ;
        line = line.rstrip(';')
        line = line.rstrip()
        # Process label
        self.label = line.strip('"')
        # Process attributes
        if len(atts):
            self.attribs = parseAttributes(atts)
        # Process sections
        if self.attribs.has_key("label"):
            tlabel = self.attribs["label"]
            if (tlabel != "" and     
                tlabel.startswith('{') and
                tlabel.endswith('}')):
                tlabel = tlabel[1:-1]
                self.sections = getLabelAttributes(tlabel)

    def getLabel(self, conf, multiline=False):
        """ return the label of the node """
        if conf.NodeLabels:
            if self.attribs.has_key('label'):
                if len(self.sections) > 0:
                    if multiline:
                        return '\n'.join(self.sections[0])
                    else:
                        return ','.join(self.sections[0])
                else:
                    return self.attribs['label']
            else:
                return self.label
        else:
            return ""

    def getLabelWidth(self, conf, multiline=False):
        """ return the maximum width label of the node label"""
        if conf.NodeLabels:
            if self.attribs.has_key('label'):
                if len(self.sections) > 0:
                    if multiline:
                        # Find maximum label width
                        width = 1
                        for s in self.sections[0]:
                            if len(s) > width:
                                width = len(s)
                        for s in self.sections[1]:
                            if len(s) > width:
                                width = len(s)
                        for s in self.sections[2]:
                            if len(s) > width:
                                width = len(s)
                        return width
                    else:
                        return len(','.join(self.sections[0]))
                else:
                    return len(self.attribs['label'])
            else:
                return len(self.label)
        else:
            return 0

    def complementAttributes(self, node):
        """ from node copy all new attributes, that do not exist in self """
        for a in node.attribs:
            if not self.attribs.has_key(a):
                self.attribs[a] = node.attribs[a]
                
    def exportDot(self, o, conf):
        """ write the node in DOT format to the given file """
        if len(self.attribs) > 0:
            o.write("\"%s\" %s;\n" % (self.label, compileAttributes(self.attribs)))
        else:
            o.write("\"%s\";\n" % (self.label))

    def exportGDF(self, o, conf):
        """ write the node in GDF format to the given file """
        tlabel = self.getLabel(conf).encode(latinenc, errors="ignore")
        if tlabel == "":
            tlabel = "n%d" % self.id
        o.write("%s\n" % tlabel)

    def exportGML(self, o, conf):
        """ write the node in GML format to the given file """
        o.write("  node [\n")
        o.write("    id %d\n" % self.id)
        o.write("    label\n")
        o.write("    \"%s\"\n" % self.getLabel(conf).encode(latinenc, errors="ignore"))
        o.write("  ]\n")

    def exportGraphml(self, doc, parent, conf):        
        """ export the node in Graphml format and append it to the parent XML node """
        node = doc.createElement(u'node')
        node.setAttribute(u'id',u'n%d' % self.id)
        
        data0 = doc.createElement(u'data')
        data0.setAttribute(u'key', u'd0')

        exportUml = False
        if len(self.sections) > 0 and conf.NodeUml and not conf.LumpAttributes:
            exportUml = True
            snode = doc.createElement(u'y:UMLClassNode')
        else:
            snode = doc.createElement(u'y:ShapeNode')
        geom = doc.createElement(u'y:Geometry')
        geom.setAttribute(u'height',u'30.0')
        geom.setAttribute(u'width',u'30.0')
        geom.setAttribute(u'x',u'0.0')
        geom.setAttribute(u'y',u'0.0')
        snode.appendChild(geom)
        if 'fillcolor' in self.attribs:
            color = getColorAttribute(self.attribs, 'fillcolor', conf.DefaultNodeColor, conf)
        else:
            color = getColorAttribute(self.attribs, 'color', conf.DefaultNodeColor, conf)
        fill = doc.createElement(u'y:Fill')
        fill.setAttribute(u'color',u'%s' % color)
        fill.setAttribute(u'transparent',u'false')
        snode.appendChild(fill)
        border = doc.createElement(u'y:BorderStyle')
        border.setAttribute(u'color',u'#000000')
        border.setAttribute(u'type',u'line')
        border.setAttribute(u'width',u'1.0')
        snode.appendChild(border)
        color = getColorAttribute(self.attribs, 'fontcolor', conf.DefaultNodeTextColor, conf)        
        label = doc.createElement(u'y:NodeLabel')
        if conf.LumpAttributes:
            label.setAttribute(u'alignment',u'left')
        else:
            label.setAttribute(u'alignment',u'center')
        label.setAttribute(u'autoSizePolicy',u'content')
        label.setAttribute(u'fontFamily',u'Dialog')
        label.setAttribute(u'fontSize',u'12')
        label.setAttribute(u'fontStyle',u'plain')
        label.setAttribute(u'hasBackgroundColor',u'false')
        label.setAttribute(u'hasLineColor',u'false')
        label.setAttribute(u'modelName',u'internal')
        label.setAttribute(u'modelPosition',u'c')
        label.setAttribute(u'textColor',u'%s' % color)
        label.setAttribute(u'visible',u'true')
        nodeLabelText = escapeNewlines(self.getLabel(conf, True))
        if conf.LumpAttributes:
            # Find maximum label width
            width = self.getLabelWidth(conf, True)
            nodeLabelText += '\n' + conf.SepChar*width + '\n'
            nodeLabelText += u'%s\n' % '\n'.join(self.sections[1])
            nodeLabelText += conf.SepChar*width + '\n'
            nodeLabelText += u'%s' % '\n'.join(self.sections[2])
        label.appendChild(doc.createTextNode(u'%s' % nodeLabelText))        
        snode.appendChild(label)
        if exportUml and not conf.LumpAttributes:
            shape = doc.createElement(u'y:UML')
            shape.setAttribute(u'clipContent',u'true')
            shape.setAttribute(u'constraint',u'')
            shape.setAttribute(u'omitDetails',u'false')
            shape.setAttribute(u'stereotype',u'') 
            shape.setAttribute(u'use3DEffect',u'true')
     
            alabel = doc.createElement(u'y:AttributeLabel')
            alabel.appendChild(doc.createTextNode(u'%s' % '\n'.join(self.sections[1])))
            shape.appendChild(alabel)
            mlabel = doc.createElement(u'y:MethodLabel')
            mlabel.appendChild(doc.createTextNode(u'%s' % '\n'.join(self.sections[2])))
            shape.appendChild(mlabel)
        else:
            shape = doc.createElement(u'y:Shape')
            shape.setAttribute(u'type',u'rectangle')
        snode.appendChild(shape)
        data0.appendChild(snode)
        node.appendChild(data0)

        data1 = doc.createElement(u'data')
        data1.setAttribute(u'key', u'd1')
        node.appendChild(data1)
        
        parent.appendChild(node)

class Edge:
    """ a single edge in the graph """
    def __init__(self):
        self.id = 0
        self.src = ""
        self.dest = ""
        self.attribs = {}

    def initFromString(self, line):
        """ extract edge info from the given text line """
        spos = findUnquoted(line, '[')
        atts = ""
        if spos >= 0:
            epos = findLastUnquoted(line, ']', spos)
            if epos > 0:
                atts = line[spos+1:epos]
                line = line[:spos] + line[epos+1:]
                line = line.strip()
            else:
                atts = line[spos+1:]
                line = line[:spos].strip()
            if line.startswith('edge '):
                line = line[5:]
                line = line.lstrip()
                # Hack that allows a single "edge [attributes]"
                # with default values...
                tline = line.rstrip(';')
                tline = tline.rstrip()
                if len(tline) == 0:
                    line = 'edge ' + line
        # Strip off trailing ;
        line = line.rstrip(';')
        line = line.rstrip()
        # Process labels
        ll = line.replace('->',' ').split()
        if len(ll) > 1:
            self.src = ll[0].strip('"')
            self.dest = ll[1].strip('"')
        # Process attributes
        if len(atts):
            self.attribs = parseAttributes(atts)
                        
    def getLabel(self, nodes, conf):
        """ return the label of the edge """
        if conf.EdgeLabels:
            if self.attribs.has_key('label'):
                return self.attribs['label']
            else:
                if conf.EdgeLabelsAutoComplete:
                    srclink = self.src
                    destlink = self.dest
                    if (nodes[self.src].attribs.has_key('label')):
                        srclink = nodes[self.src].attribs['label']
                    if (nodes[self.dest].attribs.has_key('label')):
                        destlink = nodes[self.dest].attribs['label']
                    return "%s -> %s" % (srclink, destlink)
                else:
                    return ""
        else:
            return ""

    def complementAttributes(self, edge):
        """ from edge copy all new attributes, that do not exist in self """
        for a in edge.attribs:
            if not self.attribs.has_key(a):
                self.attribs[a] = edge.attribs[a]
                
    def exportDot(self, o, nodes, conf):
        """ write the edge in DOT format to the given file """
        if len(self.attribs) > 0:
            o.write("\"%s\" -> \"%s\" %s;\n" % (self.src, self.dest, compileAttributes(self.attribs)))
        else:
            o.write("\"%s\" -> \"%s\";\n" % (self.src, self.dest))

    def exportGDF(self, o, nodes, conf):
        """ write the edge in GDF format to the given file """
        slabel = nodes[self.src].getLabel(conf)
        if slabel == "":
            slabel = "n%d" % nodes[self.src].id
        dlabel = nodes[self.dest].getLabel(conf)
        if dlabel == "":
            dlabel = "n%d" % nodes[self.dest].id
        o.write("%s,%s\n" % (slabel.encode(latinenc, errors="ignore"), dlabel.encode(latinenc, errors="ignore")))

    def exportGML(self, o, nodes, conf):
        """ write the edge in GML format to the given file """
        o.write("  edge [\n")
        o.write("    source %d\n" % nodes[self.src].id)
        o.write("    target %d\n" % nodes[self.dest].id)
        o.write("    label\n")
        o.write("    \"%s\"\n" % self.getLabel(nodes, conf).encode(latinenc, errors="ignore"))
        o.write("  ]\n")

    def exportGraphml(self, doc, parent, nodes, conf):
        """ export the edge in Graphml format and append it to the parent XML node """
        edge = doc.createElement(u'edge')
        edge.setAttribute(u'id',u'e%d' % self.id)
        edge.setAttribute(u'source',u'n%d' % nodes[self.src].id)
        edge.setAttribute(u'target',u'n%d' % nodes[self.dest].id)
        
        data2 = doc.createElement(u'data')
        data2.setAttribute(u'key', u'd2')

        pedge = doc.createElement(u'y:PolyLineEdge')
        line = doc.createElement(u'y:LineStyle')
        color = getColorAttribute(self.attribs, 'color', conf.DefaultEdgeColor, conf)
        line.setAttribute(u'color',u'%s' % color)
        line.setAttribute(u'type', u'line')
        line.setAttribute(u'width', u'1.0')
        pedge.appendChild(line)
        arrow = doc.createElement(u'y:Arrows')
        arrow_tail = conf.DefaultArrowTail
        arrow_head = conf.DefaultArrowHead
        if conf.Arrows:
            if self.attribs.has_key('arrowtail'):
                arrow_tail = self.attribs['arrowtail']
            if self.attribs.has_key('arrowhead'):
                arrow_head = self.attribs['arrowhead']
        arrow.setAttribute(u'source',u'%s' % arrow_tail)                
        arrow.setAttribute(u'target',u'%s' % arrow_head)                
        pedge.appendChild(arrow)
        if conf.EdgeLabels:
            tlabel = self.getLabel(nodes, conf)
            if tlabel != "":
                label = doc.createElement(u'y:EdgeLabel')
                color = getColorAttribute(self.attribs, 'fontcolor', conf.DefaultEdgeTextColor, conf)
                label.setAttribute(u'alignment',u'center')
                label.setAttribute(u'distance',u'2.0')
                label.setAttribute(u'fontFamily',u'Dialog')
                label.setAttribute(u'fontSize',u'12')
                label.setAttribute(u'fontStyle',u'plain')
                label.setAttribute(u'hasBackgroundColor',u'false')
                label.setAttribute(u'hasLineColor',u'false')
                label.setAttribute(u'modelName',u'six_pos')
                label.setAttribute(u'modelPosition',u'tail')
                label.setAttribute(u'textColor',u'%s' % color)
                label.setAttribute(u'visible',u'true')
                label.setAttribute(u'preferredPlacement',u'anywhere')
                label.setAttribute(u'ratio',u'0.5')
                label.appendChild(doc.createTextNode(u'%s' % escapeNewlines(tlabel)))        
                pedge.appendChild(label)
        bend = doc.createElement(u'y:BendStyle')      
        bend.setAttribute(u'smoothed', u'false')
        pedge.appendChild(bend)
        data2.appendChild(pedge)
        edge.appendChild(data2)

        data3 = doc.createElement(u'data')
        data3.setAttribute(u'key', u'd3')
        edge.appendChild(data3)
        
        parent.appendChild(edge)
