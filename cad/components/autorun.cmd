;Комментарий
;*-путь к программе
;-------------------
;Загрузка УГО блоков
;-------------------
MergeBlocks(_connector.dxf)
MergeBlocks(_el.dxf)
MergeBlocks(_nok.dxf)
MergeBlocks(_OPS.dxf)
MergeBlocks(_KIP.dxf)
MergeBlocks(_ss.dxf)
MergeBlocks(_spds.dxf)
;------------------------
;Создание пустого чертежа
;------------------------
;NewDWG
;
;;projecttree
;;load(*sample\test_dxf\ps.dxf)
;;OPS_SPBuild
;------------------------
;Загрузка ткстовых файлов
;------------------------
;Load(*sample\test_dxf\teapot.dxf)
;Load(*sample\test_dxf\em.dxf)
;;Load(*autosave\autosave.dxf)