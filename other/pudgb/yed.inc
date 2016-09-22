// константы и типы для формата gml
Const
Title='Creator	"yFiles"';
vers='Version	"2.14"';
BracketLeft='[';
BracketRight=']';
Tab=#09;
Tab2=#09#09;
Tab3=#09#09#09;
Tab4=Tab2+Tab2;
Tab5=Tab3+Tab2;
yEdMode='hierarchic';
yEdLabel='label';
yEdDirected='Directed';
yEdNode='node';
yEdID='id';
yEdgraphics='graphics';
square='"'//кавычка
yEdx='x';
yEdy='y';
yEdw='w';
yEdh='h';
yEdconfiguration='customconfiguration';
yEdConf1='"BevelNode"'
yEdFill='fill';//это цвет. Нужна процедура перевода цвета (шеснадцатеричных цифр) в текстовое представление.
yEdHasOutline='hasOutline';
yEdLabelGraphics='LabelGraphics';
yEdText='text';
yEdFontSize='fontSize';
yEdFontName='fontName';
yEdFontName1='"Dialog"';
yEdModel='model';
yEdModel1='"null"';

//вторая часть файла -- связи.
yEdEdge='edge';
yEdSource='sourse';
yEdTarget='target'
yEdType='type';
yEdType1='"bezier"';
ColorBlack='"#000000"';
yEdTargetArrow='targetArrow';
yEdTargetArrow1='"standard"';
yEdLine='Line';
yEdpoint='point';
yEdedgeAnchor='edgeAnhor';
yEdxSourse='xSource';
yEdySourse='ySource';
yEdxTarget='xTarget';
yEdyTarget='yTarget';
yEdStep=50.0 //шаг сетки

Type
TEdPoint=record
       x, y:real;
end;
TAnchor=record
      xSource, ySourse, xTarget, yTarget: real;
end;
Tedge=record
     Sourse,Target;Real;
end;
Tgraphics=record
     type,fill, TargetArrow:Real;
End;
Tgraphics2=record
x, y. w, h, hasOutline:real; //hasOutline располагается на последнем месте!!!
customconfiguration, fill:String;
End;
TLabelGraphics=record
text:String;
fontSize:Byte;//нет смысла больше, так как шрифт больше 50 неудобен
fontName,	model:string;
Node=record
graph:TGraphics2;
LabelGr:TLabelGraphics;
end;
