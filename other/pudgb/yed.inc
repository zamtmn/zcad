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
square='"';//кавычка
y_Edx='x';
y_Edy='y';
y_Edw='w';
y_Edh='h';
yEdConf1='"BevelNode"';
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
yEdTarget='target';
yEdType='type';
yEdType1='"bezier"';
yEdStyle='Style';
yEdStyle1='"dotted"';//пунктир если обычная линия, то просто опускается
ColorBlack='"#000000"';
ColorWhite='"#FFFFF0"';
Color1='"#9999FF"';
yEdTargetArrow='targetArrow';
yEdTargetArrow1='"standard"';

yEdedgeAnchor='edgeAnhor';
yEdxSourse='xSource';
yEdySourse='ySource';
yEdxTarget='xTarget';
yEdyTarget='yTarget';
yEdStep=50.0; //шаг сетки

Type

TAnchor=record
      xSource, ySourse, xTarget, yTarget: real;
end;
Tedge=record
     Sourse,Target:word; // это номера узлов, так что вполне хватит и слова (байта мало)
end;
Tgraphics=record
     types,fill, TargetArrow:Real;
End;
Tgraphics2=record
x, y, w, h, hasOutline:real; //hasOutline располагается на последнем месте!!!
customconfiguration, fill:String;
End;
TLabelGraphics=record
text:String;
fontSize:Byte;//нет смысла больше, так как шрифт больше 50 неудобен
fontName,	model:string;
End;
Node=record
graph:TGraphics2;
LabelGr:TLabelGraphics;
end;
