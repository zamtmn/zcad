;Комментарий
;*-путь к программе
LoadActions(*menu/electrotechactionscontent.xml)
LoadActions(*menu/velecactionscontent.xml)
LoadMenus(*menu/menuscontent.xml);
;-------------------
;Загрузка УГО блоков
;-------------------
;Сейчас вместо непосредственной загрузки
;файлов с определениями блоков (комманда  MergeBlocks)
;использую загрузку файла с перечнем блоков - где они
;определены и от каких блоков зависят (комманда  ReadBlockLibrary)
;непосредственная загрузка блоков происходит при
;необходимости, с учетом зависимостей
;ReadBlockLibrary(zcadblocks.lst)
MergeBlocks(_sys.dxf)
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

;------------------------
;Загрузка ткстовых файлов
;------------------------
;Load(*sample/test_dxf/teapot.dxf)
;Load(*sample/test_dxf/em.dxf)
;Load(*autosave/autosave.dxf)
;Load(*sample/zigzag.dxf)

;-----------------------------------
;Показ окна "О программе" при старте
;-----------------------------------
About
