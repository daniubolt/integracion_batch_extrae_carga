--------------------------------------------------------
--  DDL for Trigger AMAREAS_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "AMAREAS_DELETE" 
BEFORE DELETE ON AMAREAS FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
    v_new BOOLEAN;
BEGIN

    v_id := TRACKER.ABRE_REVISION( 'amAreas', :OLD.areaId, v_fecha, v_new );
        
    -- Hace la baja lógica en la tabla histórica
    UPDATE amAreas_h h SET h.logIdTo = v_id, h.dateTo = v_fecha WHERE h.areaId = :OLD.areaId AND h.logIdTo = 0;
    
    IF v_new THEN
        -- Esto no deberia ocurrir, pero prefiero manejar de forma amable los imprevistos
        TRACKER.CIERRA_REVISION( v_id );      
    END IF;
    
END;
/
ALTER TRIGGER "AMAREAS_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger AMAREAS_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "AMAREAS_INSERT" 
BEFORE INSERT ON AMAREAS FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
    v_id := TRACKER.NUEVA_REVISION( 'amAreas', :NEW.areaId, v_fecha );
            
    INSERT INTO amAreas_h (
        areaId,areaTypeId,areaName,areaShortName,superArea,fsAreaCode,logIdFrom,logIdTo,dateFrom,dateTo)
    VALUES (
        :NEW.areaId, :NEW.areaTypeId, :NEW.areaName, :NEW.areaShortName, :NEW.superArea, :NEW.fsAreaCode, v_id, 0, v_fecha, null ); 
END;
/
ALTER TRIGGER "AMAREAS_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger AMAREAS_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "AMAREAS_UPDATE" 
BEFORE UPDATE ON AMAREAS FOR EACH ROW
DECLARE
   v_id NUMBER;
   v_fecha DATE;
    v_new BOOLEAN;
BEGIN

    v_id := TRACKER.ABRE_REVISION( 'amAreas', :NEW.areaId, v_fecha, v_new );
    
    IF :OLD.areaTypeId <> :NEW.areaTypeId OR
        :OLD.areaName <> :NEW.areaName OR
        :OLD.areaShortName <> :NEW.areaShortName OR 
        :OLD.superArea <> :NEW.superArea THEN
        
        -- Da de baja el area anterior
        UPDATE amAreas_h h SET h.logIdTo = v_id, h.dateTo = v_fecha 
        WHERE h.areaId = :OLD.areaId AND h.logIdTo = 0;

        -- Inserta el nuevo area
        INSERT INTO amAreas_h (areaId, areaTypeId,areaName,areaShortName,superArea,fsAreaCode,logIdFrom,logIdTo,dateFrom,dateTo)
        VALUES (:NEW.areaId, :NEW.areaTypeId, :NEW.areaName, :NEW.areaShortName, :NEW.superArea, :NEW.fsAreaCode, v_id, 0, v_fecha, NULL); 
    END IF;
      
    TRACKER.CIERRA_REVISION( v_id );
       
END;
/
ALTER TRIGGER "AMAREAS_UPDATE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger AMPOLYGONGEO_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "AMPOLYGONGEO_DELETE" 
BEFORE DELETE ON amPolygonGeo FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_count NUMBER;
    v_fecha DATE;
    v_areaId NUMBER;
    v_new BOOLEAN;
BEGIN
    -- Obtengo el area a partir del poligono
    SELECT areaId
    INTO v_areaId
    FROM amPolygons
    WHERE polygonId = :OLD.polygonId;
                
    v_id := TRACKER.ABRE_REVISION( 'amAreas', v_areaId, v_fecha, v_new );
   
    -- Baja lógica del registro
    UPDATE amPolygonGeo_h h 
    SET h.logIdTo = v_id 
    WHERE h.polygonId = :OLD.polygonId AND h.logIdTo = 0;
    
END;
/
ALTER TRIGGER "AMPOLYGONGEO_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger AMPOLYGONGEO_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "AMPOLYGONGEO_INSERT" 
BEFORE INSERT ON amPolygonGeo FOR EACH ROW
DECLARE
    v_id NUMBER; 
    v_areaId NUMBER; 
    v_fecha DATE;
    v_new BOOLEAN;      
BEGIN
    -- Obtengo el area a partir del poligono
    SELECT areaId
    INTO v_areaId
    FROM amPolygons
    WHERE polygonId = :NEW.polygonId;
    
    v_id := TRACKER.ABRE_REVISION( 'amAreas', v_areaId, v_fecha, v_new );
    
    INSERT INTO amPolygonGeo_h (polygonId,polygonVerOrder,x,y,logIdFrom,logIdTo)
    VALUES (:NEW.polygonId, :NEW.polygonverOrder, :NEW.x, :NEW.y, v_id, 0);
END;
/
ALTER TRIGGER "AMPOLYGONGEO_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger AMPOLYGONS_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "AMPOLYGONS_DELETE" 
BEFORE DELETE ON amPolygons FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
    v_new BOOLEAN;
BEGIN

    v_id := TRACKER.ABRE_REVISION( 'amAreas', :OLD.areaId, v_fecha, v_new );
   
    UPDATE amPolygons_h h 
    SET h.logIdTo = v_id, dateTo=v_fecha 
    WHERE h.polygonId = :OLD.polygonId AND h.logIdTo = 0;
    
END;
/
ALTER TRIGGER "AMPOLYGONS_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger AMPOLYGONS_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "AMPOLYGONS_INSERT" 
BEFORE INSERT ON amPolygons FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;    
    v_count NUMBER;
    v_new BOOLEAN;    
BEGIN
    v_id := TRACKER.ABRE_REVISION( 'amAreas', :NEW.areaId, v_fecha, v_new );
    INSERT INTO amPolygons_h (polygonId,areaId,polygonAddSub,logIdFrom,logIdTo,dateFrom,dateTo)
    VALUES (:NEW.polygonId, :NEW.areaId, :NEW.polygonAddSub, v_id, 0, v_fecha, null);
END;
/
ALTER TRIGGER "AMPOLYGONS_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger AREA_TYPES_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "AREA_TYPES_DELETE" 
BEFORE DELETE ON amAreaTypes FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN

    v_id := TRACKER.NUEVA_REVISION( 'amAreaTypes', :OLD.areaTypeId, v_fecha );
                
    -- Baja lógica en la tabla histórica
    UPDATE amAreaTypes_h 
    SET logIdTo = v_id, dateTo = v_fecha
    WHERE areaTypeId = :OLD.areaTypeId AND logIdTo = 0;
    
    TRACKER.CIERRA_REVISION( v_id );    
END;
/
ALTER TRIGGER "AREA_TYPES_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger AREA_TYPES_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "AREA_TYPES_INSERT" 
BEFORE INSERT ON amAreaTypes FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN

    v_id := TRACKER.NUEVA_REVISION( 'amAreaTypes', :NEW.areaTypeId, v_fecha );
             
    INSERT INTO amAreaTypes_h (
        areaTypeId, areaTypeName, superAreaType, fsAreaTypeCode, logIdFrom, logIdTo, dateFrom, dateTo)
    VALUES (
        :NEW.areaTypeId, :NEW.areaTypeName, :NEW.superAreaType, :NEW.fsAreaTypeCode, v_id, 0, v_fecha, null ); 
        
    TRACKER.CIERRA_REVISION( v_id );    
END;
/
ALTER TRIGGER "AREA_TYPES_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger AREA_TYPES_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "AREA_TYPES_UPDATE" 
BEFORE UPDATE ON amAreaTypes FOR EACH ROW
DECLARE
   v_id NUMBER;
   v_fecha DATE;
BEGIN
    IF :OLD.areaTypeName <> :NEW.areaTypeName OR
        :OLD.superAreaType <> :NEW.superAreaType OR
        NVL(:OLD.fsAreaTypeCode,'') <> NVL(:NEW.fsAreaTypeCode,'') THEN 
        
        v_id := TRACKER.NUEVA_REVISION( 'amAreaTypes', :NEW.areaTypeId, v_fecha );
         
        -- Da de baja el usuario anterior
        UPDATE amAreaTypes_h  
        SET logIdTo = v_id, dateTo = v_fecha 
        WHERE areaTypeId = :OLD.areaTypeId AND logIdTo = 0;

        -- Inserta el nuevo usuario
        INSERT INTO amAreaTypes_h (
            areaTypeId, areaTypeName, superAreaType, fsAreaTypeCode, logIdFrom, logIdTo, dateFrom, dateTo)
        VALUES (
            :NEW.areaTypeId, :NEW.areaTypeName, :NEW.superAreaType, :NEW.fsAreaTypeCode, v_id, 0, v_fecha, null ); 
            
        TRACKER.CIERRA_REVISION( v_id );             
    END IF;
            
END;
/
ALTER TRIGGER "AREA_TYPES_UPDATE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger CATEGORIES_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "CATEGORIES_DELETE" 
BEFORE DELETE ON CATEGORIES FOR EACH ROW
DECLARE 
  v_id NUMBER;
  v_fecha DATE;
BEGIN
   v_id := TRACKER.NUEVA_REVISION( 'categories', :OLD.categId, v_fecha );
                
  -- Baja lógica en la tabla histórica
  UPDATE categories_h 
    SET logIdTo = v_id, dateTo = v_fecha
    WHERE categId = :OLD.categId AND logIdTo = 0;
    
  TRACKER.CIERRA_REVISION( v_id );
  
END;
/
ALTER TRIGGER "CATEGORIES_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger CATEGORIES_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "CATEGORIES_INSERT" 
BEFORE INSERT ON CATEGORIES FOR EACH ROW
DECLARE 
  v_id NUMBER;
  v_fecha DATE;
BEGIN
  
  v_id := TRACKER.NUEVA_REVISION( 'categories', :NEW.categId, v_fecha );
  
  INSERT INTO categories_h ( 
      categId, netTypeId, categCaption, entityType, dateFrom, dateTo, logIdFrom, logIdTo )
  VALUES ( :NEW.categId, :NEW.netTypeId, :NEW.categCaption, :NEW.entityType, v_fecha, null, v_id, 0 );

  TRACKER.CIERRA_REVISION( v_id );
  
END;
/
ALTER TRIGGER "CATEGORIES_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger CATEGORIES_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "CATEGORIES_UPDATE" 
BEFORE UPDATE ON CATEGORIES FOR EACH ROW
DECLARE
  v_id NUMBER;
  v_fecha DATE; 
BEGIN

  IF  :OLD.netTypeId <> :NEW.netTypeId OR
      :OLD.categCaption <> :NEW.categCaption OR
      :OLD.entityType <> :NEW.entityType THEN
          
    v_id := TRACKER.NUEVA_REVISION( 'categories', :NEW.categId, v_fecha );
    
    UPDATE categories_h  
      SET logIdTo = v_id, dateTo = v_fecha 
      WHERE categId = :OLD.categId AND logIdTo = 0;

    INSERT INTO categories_h ( 
      categId, netTypeId, categCaption, entityType, dateFrom, dateTo, logIdFrom, logIdTo )
    VALUES ( :NEW.categId, :NEW.netTypeId, :NEW.categCaption, :NEW.entityType, v_fecha, null, v_id, 0 );

    TRACKER.CIERRA_REVISION( v_id );
    
    END IF;

END;
/
ALTER TRIGGER "CATEGORIES_UPDATE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger LINKS_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "LINKS_DELETE" 
BEFORE DELETE ON LINKS FOR EACH ROW
DECLARE
  v_id NUMBER;
  v_fecha DATE;
BEGIN
  v_id := TRACKER.NUEVA_REVISION( 'links', :OLD.linkId, v_fecha );

  UPDATE links_h 
    SET logIdTo = v_id, dateTo = v_fecha
    WHERE linkId = :OLD.linkId AND logIdTo = 0;

    TRACKER.CIERRA_REVISION( v_id );
END;
/
ALTER TRIGGER "LINKS_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger LINKS_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "LINKS_INSERT" 
BEFORE INSERT ON LINKS FOR EACH ROW
DECLARE
  v_id NUMBER;
  v_fecha DATE;
BEGIN
  v_id := TRACKER.NUEVA_REVISION( 'links', :NEW.linkId, v_fecha );

  INSERT INTO LINKS_H ( 
      linkId, linkCaption, linkType, linkValidation, linkMin, linkMax, 
      dateFrom, dateTo, logIdFrom, logIdTo )
  VALUES ( :NEW.linkId, :NEW.linkCaption, :NEW.linkType, :NEW.linkValidation, :NEW.linkMin, :NEW.linkMax,
      v_fecha, null, v_id, 0 );

  TRACKER.CIERRA_REVISION( v_id );

END;
/
ALTER TRIGGER "LINKS_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger LINKS_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "LINKS_UPDATE" 
BEFORE UPDATE ON LINKS FOR EACH ROW
DECLARE
   v_id NUMBER;
   v_fecha DATE;
BEGIN
  IF :OLD.linkCaption <> :NEW.linkCaption OR 
     :OLD.linkType <> :NEW.linkType OR 
     :OLD.linkvalidation <> :NEW.linkvalidation OR 
     :OLD.linkMin <> :NEW.linkMin OR  
     :OLD.linkMax <> :NEW.linkMax THEN

    v_id := TRACKER.NUEVA_REVISION( 'links', :NEW.linkId, v_fecha );

    UPDATE links_h  
          SET logIdTo = v_id, dateTo = v_fecha 
          WHERE linkId = :OLD.linkId AND logIdTo = 0;

    INSERT INTO links_h ( 
        linkId, linkCaption, linkType, linkValidation, linkMin, linkMax, 
        dateFrom, dateTo, logIdFrom, logIdTo )
    VALUES ( :NEW.linkId, :NEW.linkCaption, :NEW.linkType, :NEW.linkValidation, :NEW.linkMin, :NEW.linkMax,
        v_fecha, null, v_id, 0 );

    TRACKER.CIERRA_REVISION( v_id ); 

  END IF;
END;
/
ALTER TRIGGER "LINKS_UPDATE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger NETTYPES_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "NETTYPES_DELETE" 
BEFORE DELETE ON NETTYPES FOR EACH ROW
DECLARE
  v_id NUMBER;
  v_fecha DATE;
BEGIN
  
  v_id := TRACKER.NUEVA_REVISION( 'nettypes', :OLD.netTypeId, v_fecha );
                
    -- Baja lógica en la tabla histórica
    UPDATE netTypes_h 
    SET logIdTo = v_id, dateTo = v_fecha
    WHERE netTypeId = :OLD.netTypeId AND logIdTo = 0;
    
    TRACKER.CIERRA_REVISION( v_id );
END;
/
ALTER TRIGGER "NETTYPES_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger NETTYPES_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "NETTYPES_INSERT" 
BEFORE INSERT ON NETTYPES FOR EACH ROW
DECLARE
  v_id NUMBER;
  v_fecha DATE;
BEGIN
  
  v_id := TRACKER.NUEVA_REVISION( 'nettypes', :NEW.netTypeId, v_fecha );
  
  INSERT INTO NETTYPES_H (
      netTypeId, netTypeCaption, netTypePrefix, netTypeParent, logIdFrom, logIdTo, dateFrom, dateTo ) 
  VALUES (
      :NEW.netTypeId, :NEW.netTypeCaption, :NEW.netTypePrefix, :NEW.netTypeParent, v_id, 0, v_fecha, null );
  
  TRACKER.CIERRA_REVISION( v_id );
  
END;
/
ALTER TRIGGER "NETTYPES_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger NETTYPES_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "NETTYPES_UPDATE" 
BEFORE UPDATE ON NETTYPES FOR EACH ROW
DECLARE
   v_id NUMBER;
   v_fecha DATE;
BEGIN
  IF :OLD.netTypeCaption <> :NEW.netTypeCaption OR
     :OLD.netTypePrefix <> :NEW.netTypePrefix OR
     :OLD.netTypeParent <> :NEW.netTypeParent THEN
     
     v_id := TRACKER.NUEVA_REVISION( 'netTypes', :NEW.netTypeId, v_fecha );
     
     UPDATE NETTYPES_H  
        SET logIdTo = v_id, dateTo = v_fecha 
        WHERE netTypeId = :OLD.netTypeId AND logIdTo = 0;

        -- Inserta el nuevo tipo de elemento
        INSERT INTO netTypes_h (
            netTypeId, netTypeCaption, netTypePrefix, netTypeParent, logIdFrom, logIdTo, dateFrom, dateTo)
        VALUES (
            :NEW.netTypeId, :NEW.netTypeCaption, :NEW.netTypePrefix, :NEW.netTypeParent, v_id, 0, v_fecha, null ); 
            
        TRACKER.CIERRA_REVISION( v_id );  
     
     END IF;
     
END;
/
ALTER TRIGGER "NETTYPES_UPDATE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SMBLOCKFACADES_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SMBLOCKFACADES_DELETE" 
BEFORE DELETE ON SMBLOCKFACADES FOR EACH ROW
DECLARE 
  v_id NUMBER;
  v_fecha DATE;
BEGIN

  v_id := TRACKER.NUEVA_REVISION( 'smBlockFacades', :OLD.blockFacadeId, v_fecha );
                
  -- Baja lógica en la tabla histórica
  UPDATE smBlockFacades_h 
    SET logIdTo = v_id, dateTo = v_fecha
    WHERE blockFacadeId = :OLD.blockFacadeId AND logIdTo = 0;
    
  TRACKER.CIERRA_REVISION( v_id );
  
END;
/
ALTER TRIGGER "SMBLOCKFACADES_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SMBLOCKFACADES_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "CERTACV"."SMBLOCKFACADES_INSERT" 
BEFORE INSERT ON SMBLOCKFACADES FOR EACH ROW
DECLARE
  v_id NUMBER;
  v_fecha DATE;
BEGIN

  v_id := TRACKER.NUEVA_REVISION( 'smBlockFacades', :NEW.blockFacadeId, v_fecha );
  
  INSERT INTO smBlockFacades_h ( 
      blockFacadeId,streetId, blockId, blockVerIni, blockVerEnd, blockFacadeNumIni, blockFacadeNumEnd, 
      blockInvertNum, dateFrom, dateTo, logIdFrom, logIdTo )
  VALUES ( :NEW.blockFacadeId, :NEW.streetId, :NEW.blockId, :NEW.blockVerIni, :NEW.blockVerEnd, :NEW.blockFacadeNumIni, :NEW.blockFacadeNumEnd, 
      :NEW.blockInvertNum, v_fecha, null, v_id, 0 );

  TRACKER.CIERRA_REVISION( v_id );
  
END;
/
ALTER TRIGGER "CERTACV"."SMBLOCKFACADES_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SMBLOCKFACADES_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "CERTACV"."SMBLOCKFACADES_UPDATE" 
BEFORE UPDATE ON SMBLOCKFACADES FOR EACH ROW
DECLARE
  v_id NUMBER;
  v_fecha DATE;
BEGIN

  IF  :OLD.streetId <> :NEW.streetId OR
      :OLD.blockId <> :NEW.blockId OR
      :OLD.blockVerIni <> :NEW.blockVerIni OR
      :OLD.blockVerEnd <> :NEW.blockVerEnd OR
      :OLD.blockFacadeNumIni <> :NEW.blockFacadeNumIni OR
      :OLD.blockFacadeNumEnd <> :NEW.blockFacadeNumEnd OR
      :OLD.blockInvertNum <> :NEW.blockInvertNum THEN
      
    v_id := TRACKER.NUEVA_REVISION( 'smblocFacades', :NEW.blockId, v_fecha );
    
    UPDATE smblockFacades_h  
          SET logIdTo = v_id, dateTo = v_fecha 
          WHERE blockFacadeId = :OLD.blockFacadeId AND logIdTo = 0;
  
    INSERT INTO smBlockFacades_h ( 
      blockFacadeId, streetId, blockId, blockVerIni, blockVerEnd, blockFacadeNumIni, blockFacadeNumEnd, 
      blockInvertNum, dateFrom, dateTo, logIdFrom, logIdTo )
    VALUES ( :NEW.blockFacadeId, :NEW.streetId, :NEW.blockId, :NEW.blockVerIni, :NEW.blockVerEnd, :NEW.blockFacadeNumIni, :NEW.blockFacadeNumEnd, 
      :NEW.blockInvertNum, v_fecha, null, v_id, 0 );
    
    TRACKER.CIERRA_REVISION( v_id );
    
  END IF;
  
END;
/
ALTER TRIGGER "CERTACV"."SMBLOCKFACADES_UPDATE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SMSTREETS_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SMSTREETS_INSERT" 
BEFORE INSERT ON smStreets FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
    v_count NUMBER; 
    v_new BOOLEAN := FALSE;   
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM smStreets_h 
    WHERE streetId = :NEW.streetId AND streetAntiq = 1;

    IF v_count=1 THEN
        SELECT logIdTo
        INTO v_id
        FROM smStreets_h
        WHERE streetId = :NEW.streetId AND streetAntiq = 1;
    ELSE
        v_id := TRACKER.NUEVA_REVISION( 'smStreets', :NEW.streetId, v_fecha );
        v_new := TRUE;
    END IF;
            
    INSERT INTO smStreets_h (
        streetId, streetAntiq, streetTypeId, streetName, regionId, streetShortName, 
        fsStreetCode, streetDeleted, userid, logIdFrom, dateFrom, logIdTo, dateto)
    VALUES (
        :NEW.streetId, :NEW.streetAntiq, :NEW.streetTypeId, :NEW.streetName,
        :NEW.regionId, :NEW.streetShortName, :NEW.fsStreetCode, :NEW.streetDeleted, :NEW.userId, v_id, :NEW.dateFrom, 0, :NEW.dateTo ); 
    
    IF v_new THEN
        TRACKER.CIERRA_REVISION(v_id);
    END IF;    
END;
/
ALTER TRIGGER "SMSTREETS_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SMSTREETS_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SMSTREETS_UPDATE" 
BEFORE UPDATE ON smStreets FOR EACH ROW
DECLARE
   v_id NUMBER;
   v_fecha DATE;
BEGIN
    -- Estan borrando el registro
    IF :OLD.streetDeleted = 0 AND :NEW.streetDeleted = 1 THEN
        
        v_id := TRACKER.NUEVA_REVISION( 'smStreets', :NEW.streetId, v_fecha );
        -- Borro el registro vigente actualizando el dateTo, logIdTo
        UPDATE smStreets_h 
        SET logIdTo = v_id, dateTo=:NEW.dateTo, streetDeleted=1  
        WHERE streetId = :NEW.streetId AND logIdTo = 0 AND streetDeleted=0;
        -- Borro los registros antiguos, sin tocar logIdTo, dateTo
        UPDATE smStreets_h 
        SET streetDeleted=1  
        WHERE streetId = :NEW.streetId AND logIdTo <> 0 AND streetDeleted=0;
        TRACKER.CIERRA_REVISION( v_id );        
    END IF;

    -- Cambio de vigencia del registro    
    IF :OLD.streetAntiq <> :NEW.streetAntiq THEN
        IF :OLD.streetAntiq = 0 THEN
            -- El vigente pasa a ser antiguo -> actualizo logIdTo, dateTo
            v_id := TRACKER.NUEVA_REVISION( 'smStreets', :NEW.streetId, v_fecha );
            
            UPDATE smStreets_h 
            SET logIdTo = v_id, dateTo=:NEW.dateTo, streetAntiq=:NEW.streetAntiq 
            WHERE streetId = :NEW.streetId AND streetAntiq = 0; 
            
            TRACKER.CIERRA_REVISION( v_id );
        ELSE
            -- Los antiguos pasan a ser mas antiguos
            UPDATE smStreets_h 
            SET streetAntiq = :NEW.streetAntiq 
            WHERE streetId = :NEW.streetId AND streetAntiq <> 0;        
        END IF;       
    END IF;
    
END;
/
ALTER TRIGGER "SMSTREETS_UPDATE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SMSTREETTYPES_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SMSTREETTYPES_DELETE" 
BEFORE DELETE ON SMSTREETTYPES FOR EACH ROW
DECLARE 
  v_id NUMBER;
  v_fecha DATE;
BEGIN
  v_id := TRACKER.NUEVA_REVISION( 'smStreetTypes', :OLD.streetTypeId, v_fecha );
                
  -- Baja lógica en la tabla histórica
  UPDATE smStreetTypes_h 
    SET logIdTo = v_id, dateTo = v_fecha
    WHERE streetTypeId = :OLD.streetTypeId AND logIdTo = 0;
    
  TRACKER.CIERRA_REVISION( v_id );
END;
/
ALTER TRIGGER "SMSTREETTYPES_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SMSTREETTYPES_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SMSTREETTYPES_INSERT" 
BEFORE INSERT ON SMSTREETTYPES FOR EACH ROW
DECLARE 
  v_id NUMBER;
  v_fecha DATE;
BEGIN
  v_id := TRACKER.NUEVA_REVISION( 'smStreetTypes', :NEW.streetTypeId, v_fecha );
  
  INSERT INTO smStreetTypes_h ( 
      streetTypeId, streetTypeName, numberTypeId, magConvid, dateFrom, dateTo, logIdFrom, logIdTo )
  VALUES ( :NEW.streetTypeId, :NEW.streetTypeName, :NEW.numberTypeId, :NEW.magConvid, v_fecha, null, v_id, 0 );

  TRACKER.CIERRA_REVISION( v_id );
END;
/
ALTER TRIGGER "SMSTREETTYPES_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SMSTREETTYPES_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SMSTREETTYPES_UPDATE" 
BEFORE UPDATE ON SMSTREETTYPES FOR EACH ROW
DECLARE
  v_id NUMBER;
  v_fecha DATE; 
BEGIN
  
  IF  :OLD.streetTypeName <> :NEW.streetTypeName OR
      :OLD.numberTypeId <> :NEW.numberTypeId OR
      :OLD.magConvid <> :NEW.magConvid THEN
          
    v_id := TRACKER.NUEVA_REVISION( 'smStreetTypes', :NEW.streetTypeId, v_fecha );
    
    UPDATE smStreetTypes_h  
      SET logIdTo = v_id, dateTo = v_fecha 
      WHERE streetTypeId = :OLD.streetTypeId AND logIdTo = 0;
    
    INSERT INTO smStreetTypes_h ( 
      streetTypeId, streetTypeName, numberTypeId, magConvid, dateFrom, dateTo, logIdFrom, logIdTo )
    VALUES ( :NEW.streetTypeId, :NEW.streetTypeName, :NEW.numberTypeId, :NEW.magConvid, v_fecha, null, v_id, 0 );
    
    TRACKER.CIERRA_REVISION( v_id );
    
  END IF;
  
END;
/
ALTER TRIGGER "SMSTREETTYPES_UPDATE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPRENTITIES_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "CERTACV"."SPRENTITIES_DELETE" 
BEFORE DELETE ON SPRENTITIES FOR EACH ROW
DECLARE
  v_id NUMBER;
  v_fecha DATE;
BEGIN
  
  v_id := TRACKER.NUEVA_REVISION( 'sprEntities', :OLD.sprId, v_fecha );
                
  -- Baja lógica en la tabla histórica
  UPDATE sprEntities_h 
    SET logIdTo = v_id, dateTo = v_fecha
    WHERE sprId = :OLD.sprId AND logIdTo = 0;
    
  TRACKER.CIERRA_REVISION( v_id );
  
END;
/
ALTER TRIGGER "CERTACV"."SPRENTITIES_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPRENTITIES_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "CERTACV"."SPRENTITIES_INSERT" 
BEFORE INSERT ON SPRENTITIES FOR EACH ROW
DECLARE
  v_id NUMBER;
  v_fecha DATE;
BEGIN

  v_id := TRACKER.NUEVA_REVISION( 'sprEntities', :NEW.sprId, v_fecha );

  INSERT INTO sprEntities_h ( 
      sprId, netTypeId, categId, caption, alias, entityType, flags, propertyId, layer,
      dateFrom, dateTo, logIdFrom, logIdTo )
  VALUES ( :NEW.sprId, :NEW.netTypeId, :NEW.categId, :NEW.caption, :NEW.alias, :NEW.entityType,
      :NEW.flags, :NEW.propertyId, :NEW.layer,
      v_fecha, null, v_id, 0 );

  TRACKER.CIERRA_REVISION( v_id );
  
END;
/
ALTER TRIGGER "CERTACV"."SPRENTITIES_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPRENTITIES_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "CERTACV"."SPRENTITIES_UPDATE" 
BEFORE UPDATE ON SPRENTITIES FOR EACH ROW
DECLARE
  v_id NUMBER;
  v_fecha DATE;
BEGIN
  IF :OLD.sprId <> :NEW.sprId OR
     :OLD.netTypeId <> :NEW.netTypeId OR
     :OLD.categID <> :NEW.categID OR
     :OLD.caption <> :NEW.caption OR
     :OLD.alias <> :NEW.alias OR
     :OLD.entityType <> :NEW.entityType THEN
    
    v_id := TRACKER.NUEVA_REVISION( 'sprEntities', :NEW.sprId, v_fecha );
    
    UPDATE sprEntities_h  
          SET logIdTo = v_id, dateTo = v_fecha 
          WHERE sprId = :OLD.sprId AND logIdTo = 0;
    
    INSERT INTO sprEntities_h ( 
      sprId, netTypeId, categId, caption, alias, entityType, flags, propertyId, layer,
      dateFrom, dateTo, logIdFrom, logIdTo )
    VALUES ( :NEW.sprId, :NEW.netTypeId, :NEW.categId, :NEW.caption, :NEW.alias, :NEW.entityType,
      :NEW.flags, :NEW.propertyId, :NEW.layer,
      v_fecha, null, v_id, 0 );

  TRACKER.CIERRA_REVISION( v_id );
    
  END IF;
END;
/
ALTER TRIGGER "CERTACV"."SPRENTITIES_UPDATE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger USERS_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "USERS_DELETE" 
BEFORE DELETE ON users FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN

    v_id := TRACKER.NUEVA_REVISION( 'users', :OLD.userId, v_fecha );
                
    -- Baja lógica en la tabla histórica
    UPDATE users_h 
    SET logIdTo = v_id, dateTo = v_fecha
    WHERE userId = :OLD.userId AND logIdTo = 0;
    
    TRACKER.CIERRA_REVISION( v_id );    
END;
/
ALTER TRIGGER "USERS_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger USERS_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "USERS_INSERT" 
BEFORE INSERT ON Users FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN

    v_id := TRACKER.NUEVA_REVISION( 'users', :NEW.userId, v_fecha );
             
    INSERT INTO users_h (
        userId,userName,userPassword,userFullName,logIdFrom,logIdTo,dateFrom,dateTo)
    VALUES (
        :NEW.userId, :NEW.userName, :NEW.userPassword, :NEW.userFullName, v_id, 0, v_fecha, null ); 
        
    TRACKER.CIERRA_REVISION( v_id );    
END;
/
ALTER TRIGGER "USERS_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger USERS_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "USERS_UPDATE" 
BEFORE UPDATE ON Users FOR EACH ROW
DECLARE
   v_id NUMBER;
   v_fecha DATE;
BEGIN
    IF :OLD.userName <> :NEW.userName OR
        :OLD.userPassword <> :NEW.userPassword OR
        :OLD.userFullName <> :NEW.userFullName THEN 
        
        v_id := TRACKER.NUEVA_REVISION( 'users', :NEW.userId, v_fecha );
         
        -- Da de baja el usuario anterior
        UPDATE users_h  
        SET logIdTo = v_id, dateTo = v_fecha 
        WHERE userId = :OLD.userId AND logIdTo = 0;

        -- Inserta el nuevo usuario
        INSERT INTO users_h (
            userId,userName,userPassword,userFullName,logIdFrom,logIdTo,dateFrom,dateTo)
        VALUES (
            :NEW.userId, :NEW.userName, :NEW.userPassword, :NEW.userFullName, v_id, 0, v_fecha, null ); 
            
        TRACKER.CIERRA_REVISION( v_id );             
    END IF;
            
END;
/
ALTER TRIGGER "USERS_UPDATE" ENABLE;

--------------------------------------------------------
--  DDL for Trigger AREAUSERGROUPS_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "AREAUSERGROUPS_DELETE" 
BEFORE DELETE ON AREAUSERGROUPS FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
    v_new BOOLEAN;
BEGIN
    v_id := TRACKER.ABRE_REVISION( 'areaUserGroups', :OLD.areaId, v_fecha, v_new );
        
    -- Hace la baja lógica en la tabla histórica
    UPDATE areaUserGroups_h h SET h.logIdTo = v_id, h.dateTo = v_fecha WHERE h.areaId = :OLD.areaId AND h.logIdTo = 0;
    
    IF v_new THEN
        -- Esto no deberia ocurrir, pero prefiero manejar de forma amable los imprevistos
        TRACKER.CIERRA_REVISION( v_id );      
    END IF;
END;
/
ALTER TRIGGER "AREAUSERGROUPS_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger AREAUSERGROUPS_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "AREAUSERGROUPS_INSERT" 
BEFORE INSERT ON AREAUSERGROUPS FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
  v_id := TRACKER.NUEVA_REVISION( 'areaUserGroups', :NEW.areaId, v_fecha );
  
  INSERT INTO areaUserGroups_h (
        areaId,userGroupId,permissionId, logIdFrom,logIdTo,dateFrom,dateTo)
  VALUES (
        :NEW.areaId, :NEW.userGroupId, :NEW.permissionId, v_id, 0, v_fecha, null ); 
  
  TRACKER.CIERRA_REVISION( v_id );
END;
/
ALTER TRIGGER "AREAUSERGROUPS_INSERT" ENABLE;

--------------------------------------------------------
--  DDL for Trigger AREAUSERGROUPS_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "AREAUSERGROUPS_UPDATE" 
BEFORE UPDATE ON AREAUSERGROUPS FOR EACH ROW
DECLARE
   v_id NUMBER;
   v_fecha DATE;
BEGIN
  IF :OLD.userGroupId <> :NEW.userGroupId OR
        :OLD.permissionId <> :NEW.permissionId THEN
        
        v_id := TRACKER.NUEVA_REVISION( 'areaUserGroups', :NEW.areaId, v_fecha );
         
        -- Da de baja el usuario anterior
        UPDATE areaUserGroups_h  
        SET logIdTo = v_id, dateTo = v_fecha 
        WHERE areaId = :OLD.areaId AND logIdTo = 0;

        -- Inserta el nuevo usuario
        INSERT INTO areaUserGroups_h (
            areaId,userGroupId,permissionId,logIdFrom,logIdTo,dateFrom,dateTo)
        VALUES (
            :NEW.areaId, :NEW.userGroupId, :NEW.permissionId, v_id, 0, v_fecha, null ); 
            
        TRACKER.CIERRA_REVISION( v_id );             
    END IF;
END;
/
ALTER TRIGGER "AREAUSERGROUPS_UPDATE" ENABLE;

--------------------------------------------------------
--  DDL for Trigger USERUSERGROUPS_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "USERUSERGROUPS_DELETE" 
BEFORE DELETE ON USERUSERGROUPS  FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
    v_new BOOLEAN;
BEGIN
    v_id := TRACKER.ABRE_REVISION( 'userUserGroups', :OLD.userGroupId, v_fecha, v_new );
        
    -- Hace la baja lógica en la tabla histórica
    UPDATE userUserGroups_h h SET h.logIdTo = v_id, h.dateTo = v_fecha WHERE h.userGroupId = :OLD.userGroupId AND h.logIdTo = 0;
    
    IF v_new THEN
        -- Esto no deberia ocurrir, pero prefiero manejar de forma amable los imprevistos
        TRACKER.CIERRA_REVISION( v_id );      
    END IF;
END;
/
ALTER TRIGGER "USERUSERGROUPS_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger USERUSERGROUPS_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "USERUSERGROUPS_INSERT" 
BEFORE INSERT ON USERUSERGROUPS FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
  v_id := TRACKER.NUEVA_REVISION( 'userUserGroups', :NEW.userGroupId, v_fecha );
  
  INSERT INTO userUserGroups_h (
        userGroupId,userId,logIdFrom,logIdTo,dateFrom,dateTo)
  VALUES (
        :NEW.userGroupId, :NEW.userId, v_id, 0, v_fecha, null ); 
  
  TRACKER.CIERRA_REVISION( v_id );
END;
/
ALTER TRIGGER "USERUSERGROUPS_INSERT" ENABLE;

--------------------------------------------------------
--  DDL for Trigger USERGROUPS_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "USERGROUPS_DELETE" 
BEFORE DELETE ON USERGROUPS FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
    v_id := TRACKER.NUEVA_REVISION( 'userGroups', :OLD.userGroupId, v_fecha );
                
    -- Baja lógica en la tabla histórica
    UPDATE userGroups_h 
    SET logIdTo = v_id, dateTo = v_fecha
    WHERE userGroupId = :OLD.userGroupId AND logIdTo = 0;
    
    TRACKER.CIERRA_REVISION( v_id );  
END;
/
ALTER TRIGGER "USERGROUPS_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger USERGROUPS_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "USERGROUPS_INSERT" 
BEFORE INSERT ON USERGROUPS FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
   v_id := TRACKER.NUEVA_REVISION( 'userGroups', :NEW.userGroupId, v_fecha );
   
   INSERT INTO userGroups_h (
        userGroupId, userGroupName,userGroupFullName,fsuserGroupName,logIdFrom,logIdTo,dateFrom,dateTo)
   VALUES (
        :NEW.userGroupId, :NEW.userGroupName, :NEW.userGroupFullName, :NEW.fsuserGroupName, v_id, 0, v_fecha, null ); 
        
    TRACKER.CIERRA_REVISION( v_id );    
             
END;
/
ALTER TRIGGER "USERGROUPS_INSERT" ENABLE;

--------------------------------------------------------
--  DDL for Trigger USERGROUPS_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "USERGROUPS_UPDATE" 
BEFORE UPDATE ON USERGROUPS FOR EACH ROW
DECLARE
   v_id NUMBER;
   v_fecha DATE;
BEGIN
  IF :OLD.userGroupName <> :NEW.userGroupName OR
        :OLD.userGroupFullName <> :NEW.userGroupFullName OR
        :OLD.fsUserGroupName <> :NEW.fsUserGroupName THEN
        
        v_id := TRACKER.NUEVA_REVISION( 'userGroups', :NEW.userGroupId, v_fecha );
         
        -- Da de baja el usuario anterior
        UPDATE userGroups_h  
        SET logIdTo = v_id, dateTo = v_fecha 
        WHERE userGroupId = :OLD.userGroupId AND logIdTo = 0;

        -- Inserta el nuevo usuario
        INSERT INTO userGroups_h (
            userGroupId,userGroupName,userGroupFullName,fsUserGroupName,logIdFrom,logIdTo,dateFrom,dateTo)
        VALUES (
            :NEW.userGroupId, :NEW.userGroupName, :NEW.userGroupFullName, :NEW.fsUserGroupName, v_id, 0, v_fecha, null ); 
            
        TRACKER.CIERRA_REVISION( v_id );             
    END IF;
END;
/
ALTER TRIGGER "USERGROUPS_UPDATE" ENABLE;

--------------------------------------------------------
--  DDL for Trigger GIS_DET_AREA_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "GIS_DET_AREA_DELETE" 
BEFORE DELETE ON GIS_DET_AREA FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
    v_new BOOLEAN;
BEGIN
    v_id := TRACKER.ABRE_REVISION( 'gis_det_area', 0, v_fecha, v_new );
        
    -- Hace la baja lógica en la tabla histórica
    UPDATE gis_det_area_h h SET h.logIdTo = v_id, h.dateTo = v_fecha WHERE h.areaName = :OLD.areaName AND h.logIdTo = 0;
    
    IF v_new THEN
        -- Esto no deberia ocurrir, pero prefiero manejar de forma amable los imprevistos
        TRACKER.CIERRA_REVISION( v_id );      
    END IF;
END;
/
ALTER TRIGGER "GIS_DET_AREA_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger GIS_DET_AREA_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "GIS_DET_AREA_INSERT" 
BEFORE INSERT ON GIS_DET_AREA FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
  v_id := TRACKER.NUEVA_REVISION( 'gis_det_area', 0, v_fecha );
  
  INSERT INTO gis_det_area_h (
    areaname, constr, alimen, pelos, bidirec, nodos, fecha_hab, doc, dispo1, dispo2, manzanas, viviendas, clientes, 
    ancho_banda, nse_nodo, partido, label_mgt, viv_relev, ord_porc, zona_comercial, zona_ust, sched_area, descripcion, 
    cablemodem, rxo, tecnico_id, fecha_alta_cablemodem, grilla_reducida, fecha_hab_digitalizada, plan_dalvi, empresa, red, 
    fecha_hab_unificacion, agrup_subnodo, marca_in, canal_barrial, phone, fecha_hab_phone, estado, agrup_directa, fecha_normal_red, 
    tipo_bidirec, fecha_cambio_bidirec, vod, fecha_cambio_ab, fecha_hab_vod, fecha_cambio_bidirec_old, tipo_bidirec_old, 
    fecha_hab_phone_old, phone_old, fecha_hab_digitalizada_old, grilla_reducida_old, fecha_cambio_ab_old, pelos_old, 
    ancho_banda_old, vod_old, fecha_hab_vod_old, viable_2w, tx_nodo, puerto_apex, node_group, om_nodo, antiguedad_red, 
    apex, om, max_vel_acc, fecha_cambio_vel, max_vel_acc_old, logIdFrom, logIdTo, dateFrom, dateTo ) 
  VALUES (
    :NEW.areaname, :NEW.constr, :NEW.alimen, :NEW.pelos, :NEW.bidirec, :NEW.nodos, :NEW.fecha_hab, :NEW.doc, :NEW.dispo1, 
    :NEW.dispo2, :NEW.manzanas, :NEW.viviendas, :NEW.clientes, :NEW.ancho_banda, :NEW.nse_nodo, :NEW.partido, :NEW.label_mgt,
    :NEW.viv_relev, :NEW.ord_porc, :NEW.zona_comercial, :NEW.zona_ust, :NEW.sched_area, :NEW.descripcion, :NEW.cablemodem,
    :NEW.rxo, :NEW.tecnico_id, :NEW.fecha_alta_cablemodem, :NEW.grilla_reducida, :NEW.fecha_hab_digitalizada, :NEW.plan_dalvi, 
    :NEW.empresa, :NEW.red, :NEW.fecha_hab_unificacion, :NEW.agrup_subnodo, :NEW.marca_in, :NEW.canal_barrial, :NEW.phone,
    :NEW.fecha_hab_phone, :NEW.estado, :NEW.agrup_directa, :NEW.fecha_normal_red, :NEW.tipo_bidirec, :NEW.fecha_cambio_bidirec, 
    :NEW.vod, :NEW.fecha_cambio_ab, :NEW.fecha_hab_vod, :NEW.fecha_cambio_bidirec_old, :NEW.tipo_bidirec_old, :NEW.fecha_hab_phone_old, 
    :NEW.phone_old, :NEW.fecha_hab_digitalizada_old, :NEW.grilla_reducida_old, :NEW.fecha_cambio_ab_old, :NEW.pelos_old, 
    :NEW.ancho_banda_old, :NEW.vod_old, :NEW.fecha_hab_vod_old, :NEW.viable_2w, :NEW.tx_nodo, :NEW.puerto_apex, 
    :NEW.node_group, :NEW.om_nodo, :NEW.antiguedad_red, :NEW.apex, :NEW.om, :NEW.max_vel_acc, :NEW.fecha_cambio_vel, 
    :NEW.max_vel_acc_old, v_id, 0, v_fecha, null ); 
  
  TRACKER.CIERRA_REVISION( v_id );
END;
/
ALTER TRIGGER "GIS_DET_AREA_INSERT" ENABLE;

--------------------------------------------------------
--  DDL for Trigger GIS_DET_AREA_UPDATE
--------------------------------------------------------

  create or replace TRIGGER "GIS_DET_AREA_UPDATE" 
BEFORE UPDATE ON GIS_DET_AREA FOR EACH ROW
DECLARE
   v_id NUMBER;
   v_fecha DATE;
BEGIN
  IF  :NEW.constr <> :OLD.constr OR
      :NEW.alimen <> :OLD.alimen OR
      :NEW.pelos <> :OLD.pelos OR
      :NEW.bidirec <> :OLD.bidirec OR
      :NEW.nodos <> :OLD.nodos OR
      :NEW.fecha_hab <> :OLD.fecha_hab OR
      :NEW.doc <> :OLD.doc OR
      :NEW.dispo1 <> :OLD.dispo1 OR
      :NEW.dispo2 <> :OLD.dispo2 OR
      :NEW.manzanas <> :OLD.manzanas OR
      :NEW.viviendas <> :OLD.viviendas OR
      :NEW.clientes <> :OLD.clientes OR
      :NEW.ancho_banda <> :OLD.ancho_banda OR
      :NEW.nse_nodo <> :OLD.nse_nodo OR
      :NEW.partido <> :OLD.partido OR
      :NEW.label_mgt <> :OLD.label_mgt OR
      :NEW.viv_relev <> :OLD.viv_relev OR
      :NEW.ord_porc <> :OLD.ord_porc OR
      :NEW.zona_comercial <> :OLD.zona_comercial OR
      :NEW.zona_ust <> :OLD.zona_ust OR
      :NEW.sched_area <> :OLD.sched_area OR
      :NEW.descripcion <> :OLD.descripcion OR
      :NEW.cablemodem <> :OLD.cablemodem OR
      :NEW.rxo <> :OLD.rxo OR
      :NEW.tecnico_id <> :OLD.tecnico_id OR
      :NEW.fecha_alta_cablemodem <> :OLD.fecha_alta_cablemodem OR
      :NEW.grilla_reducida <> :OLD.grilla_reducida OR
      :NEW.fecha_hab_digitalizada <> :OLD.fecha_hab_digitalizada OR
      :NEW.plan_dalvi <> :OLD.plan_dalvi OR
      :NEW.empresa <> :OLD.empresa OR
      :NEW.red <> :OLD.red OR
      :NEW.fecha_hab_unificacion <> :OLD.fecha_hab_unificacion OR
      :NEW.agrup_subnodo <> :OLD.agrup_subnodo OR
      :NEW.marca_in <> :OLD.marca_in OR
      :NEW.canal_barrial <> :OLD.canal_barrial OR
      :NEW.phone <> :OLD.phone OR
      :NEW.fecha_hab_phone <> :OLD.fecha_hab_phone OR
      :NEW.estado <> :OLD.estado OR
      :NEW.agrup_directa <> :OLD.agrup_directa OR
      :NEW.fecha_normal_red <> :OLD.fecha_normal_red OR
      :NEW.tipo_bidirec <> :OLD.tipo_bidirec OR
      :NEW.fecha_cambio_bidirec <> :OLD.fecha_cambio_bidirec OR
      :NEW.vod <> :OLD.vod OR
      :NEW.fecha_cambio_ab <> :OLD.fecha_cambio_ab OR
      :NEW.fecha_hab_vod <> :OLD.fecha_hab_vod OR
      :NEW.fecha_cambio_bidirec_old <> :OLD.fecha_cambio_bidirec_old OR
      :NEW.tipo_bidirec_old <> :OLD.tipo_bidirec_old OR
      :NEW.fecha_hab_phone_old <> :OLD.fecha_hab_phone_old OR
      :NEW.phone_old <> :OLD.phone_old OR
      :NEW.fecha_hab_digitalizada_old <> :OLD.fecha_hab_digitalizada_old OR
      :NEW.grilla_reducida_old <> :OLD.grilla_reducida_old OR
      :NEW.fecha_cambio_ab_old <> :OLD.fecha_cambio_ab_old OR
      :NEW.pelos_old <> :OLD.pelos_old OR
      :NEW.ancho_banda_old <> :OLD.ancho_banda_old OR
      :NEW.vod_old <> :OLD.vod_old OR
      :NEW.fecha_hab_vod_old <> :OLD.fecha_hab_vod_old OR
      :NEW.viable_2w <> :OLD.viable_2w OR
      :NEW.tx_nodo <> :OLD.tx_nodo OR
      :NEW.puerto_apex <> :OLD.puerto_apex OR
      :NEW.node_group <> :OLD.node_group OR
      :NEW.om_nodo <> :OLD.om_nodo OR
      :NEW.antiguedad_red <> :OLD.antiguedad_red OR
      :NEW.apex <> :OLD.apex OR
      :NEW.om <> :OLD.om OR
      :NEW.max_vel_acc <> :OLD.max_vel_acc OR
      :NEW.fecha_cambio_vel <> :OLD.fecha_cambio_vel OR
      :NEW.max_vel_acc_old <> :OLD.max_vel_acc_old THEN
        
        v_id := TRACKER.NUEVA_REVISION( 'gis_det_area', 0, v_fecha );
         
        -- Da de baja el usuario anterior
        UPDATE gis_det_area_h  
        SET logIdTo = v_id, dateTo = v_fecha 
        WHERE areaName = :OLD.areaName AND logIdTo = 0;

        INSERT INTO gis_det_area_h (
          areaname, constr, alimen, pelos, bidirec, nodos, fecha_hab, doc, dispo1, dispo2, manzanas, viviendas, clientes, 
          ancho_banda, nse_nodo, partido, label_mgt, viv_relev, ord_porc, zona_comercial, zona_ust, sched_area, descripcion, 
          cablemodem, rxo, tecnico_id, fecha_alta_cablemodem, grilla_reducida, fecha_hab_digitalizada, plan_dalvi, empresa, red, 
          fecha_hab_unificacion, agrup_subnodo, marca_in, canal_barrial, phone, fecha_hab_phone, estado, agrup_directa, fecha_normal_red, 
          tipo_bidirec, fecha_cambio_bidirec, vod, fecha_cambio_ab, fecha_hab_vod, fecha_cambio_bidirec_old, tipo_bidirec_old, 
          fecha_hab_phone_old, phone_old, fecha_hab_digitalizada_old, grilla_reducida_old, fecha_cambio_ab_old, pelos_old, 
          ancho_banda_old, vod_old, fecha_hab_vod_old, viable_2w, tx_nodo, puerto_apex, node_group, om_nodo, antiguedad_red, 
          apex, om, max_vel_acc, fecha_cambio_vel, max_vel_acc_old, logIdFrom, logIdTo, dateFrom, dateTo ) 
        VALUES (
          :NEW.areaname, :NEW.constr, :NEW.alimen, :NEW.pelos, :NEW.bidirec, :NEW.nodos, :NEW.fecha_hab, :NEW.doc, :NEW.dispo1, 
          :NEW.dispo2, :NEW.manzanas, :NEW.viviendas, :NEW.clientes, :NEW.ancho_banda, :NEW.nse_nodo, :NEW.partido, :NEW.label_mgt,
          :NEW.viv_relev, :NEW.ord_porc, :NEW.zona_comercial, :NEW.zona_ust, :NEW.sched_area, :NEW.descripcion, :NEW.cablemodem,
          :NEW.rxo, :NEW.tecnico_id, :NEW.fecha_alta_cablemodem, :NEW.grilla_reducida, :NEW.fecha_hab_digitalizada, :NEW.plan_dalvi, 
          :NEW.empresa, :NEW.red, :NEW.fecha_hab_unificacion, :NEW.agrup_subnodo, :NEW.marca_in, :NEW.canal_barrial, :NEW.phone,
          :NEW.fecha_hab_phone, :NEW.estado, :NEW.agrup_directa, :NEW.fecha_normal_red, :NEW.tipo_bidirec, :NEW.fecha_cambio_bidirec, 
          :NEW.vod, :NEW.fecha_cambio_ab, :NEW.fecha_hab_vod, :NEW.fecha_cambio_bidirec_old, :NEW.tipo_bidirec_old, :NEW.fecha_hab_phone_old, 
          :NEW.phone_old, :NEW.fecha_hab_digitalizada_old, :NEW.grilla_reducida_old, :NEW.fecha_cambio_ab_old, :NEW.pelos_old, 
          :NEW.ancho_banda_old, :NEW.vod_old, :NEW.fecha_hab_vod_old, :NEW.viable_2w, :NEW.tx_nodo, :NEW.puerto_apex, 
          :NEW.node_group, :NEW.om_nodo, :NEW.antiguedad_red, :NEW.apex, :NEW.om, :NEW.max_vel_acc, :NEW.fecha_cambio_vel, 
          :NEW.max_vel_acc_old, v_id, 0, v_fecha, null ); 
            
        TRACKER.CIERRA_REVISION( v_id );             
    END IF;
END;
/
ALTER TRIGGER "GIS_DET_AREA_UPDATE" ENABLE;

--------------------------------------------------------
--  DDL for Trigger SPRSYMBGSCAT_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSYMBGSCAT_DELETE" 
BEFORE DELETE ON SPRSYMBGSCAT FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
    v_id := TRACKER.NUEVA_REVISION( 'sprSymbGsCat', :OLD.categoryId, v_fecha );
                
    -- Baja lógica en la tabla histórica
    UPDATE sprSymbGsCat_h 
    SET logIdTo = v_id, dateTo = v_fecha
    WHERE categoryId = :OLD.categoryId AND logIdTo = 0;
    
    TRACKER.CIERRA_REVISION( v_id );   
END;
/
ALTER TRIGGER "SPRSYMBGSCAT_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPRSYMBGSCAT_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSYMBGSCAT_INSERT" 
BEFORE INSERT ON SPRSYMBGSCAT FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
   v_id := TRACKER.NUEVA_REVISION( 'sprSymbGsCat', :NEW.categoryId, v_fecha );
             
    INSERT INTO sprSymbGsCat_h (
        categoryId,caption,parentCategoryId,logIdFrom,logIdTo,dateFrom,dateTo)
    VALUES (
        :NEW.categoryId, :NEW.caption, :NEW.parentCategoryId, v_id, 0, v_fecha, null ); 
        
    TRACKER.CIERRA_REVISION( v_id );    
END;
/
ALTER TRIGGER "SPRSYMBGSCAT_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPRSYMBGSCAT_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSYMBGSCAT_UPDATE" 
BEFORE UPDATE ON SPRSYMBGSCAT FOR EACH ROW
DECLARE
   v_id NUMBER;
   v_fecha DATE;
BEGIN
  IF :OLD.caption <> :NEW.caption OR
        :OLD.parentCategoryId <> :NEW.parentCategoryId THEN 
        
        v_id := TRACKER.NUEVA_REVISION( 'sprSymbGsCat', :NEW.categoryId, v_fecha );
         
        -- Da de baja el usuario anterior
        UPDATE sprSymbGsCat_h  
        SET logIdTo = v_id, dateTo = v_fecha 
        WHERE categoryId = :OLD.categoryId AND logIdTo = 0;

        -- Inserta el nuevo usuario
        INSERT INTO sprSymbGsCat_h (
            categoryId,caption,parentCategoryId,logIdFrom,logIdTo,dateFrom,dateTo)
        VALUES (
            :NEW.categoryId, :NEW.caption, :NEW.parentCategoryId, v_id, 0, v_fecha, null ); 
            
        TRACKER.CIERRA_REVISION( v_id );             
    END IF;
END;
/
ALTER TRIGGER "SPRSYMBGSCAT_UPDATE" ENABLE;

--------------------------------------------------------
--  DDL for Trigger SPRSYMBGS_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSYMBGS_DELETE" 
BEFORE DELETE ON SPRSYMBGS FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
   v_id := TRACKER.NUEVA_REVISION( 'sprSymbGs', :OLD.gsid, v_fecha );
                
    -- Baja lógica en la tabla histórica
    UPDATE sprSymbGs_h 
    SET logIdTo = v_id, dateTo = v_fecha
    WHERE gsid = :OLD.gsid AND logIdTo = 0;
    
    TRACKER.CIERRA_REVISION( v_id );   
END;
/
ALTER TRIGGER "SPRSYMBGS_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPRSYMBGS_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSYMBGS_INSERT" 
BEFORE INSERT ON SPRSYMBGS FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
   v_id := TRACKER.NUEVA_REVISION( 'sprSymbGs', :NEW.gsId, v_fecha );
             
    INSERT INTO sprSymbGs_h (
        gsId, caption, categoryId, scale, type, imagePath, logIdFrom,logIdTo,dateFrom,dateTo)
    VALUES (
        :NEW.gsId, :NEW.caption, :NEW.categoryId, :NEW.scale, :NEW.type, :NEW.imagePath, v_id, 0, v_fecha, null ); 
        
    TRACKER.CIERRA_REVISION( v_id );    
END;
/
ALTER TRIGGER "SPRSYMBGS_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPRSYMBGS_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSYMBGS_UPDATE" 
BEFORE UPDATE ON SPRSYMBGS FOR EACH ROW
DECLARE
   v_id NUMBER;
   v_fecha DATE;
BEGIN
      IF :OLD.caption <> :NEW.caption OR
        :OLD.categoryId <> :NEW.categoryId OR
        :OLD.scale <> :NEW.scale OR 
        :OLD.type <> :NEW.type OR 
        :OLD.imagePath <> :NEW.imagePath THEN 
      
        v_id := TRACKER.NUEVA_REVISION( 'sprSymbGs', :NEW.gsId, v_fecha );
         
        -- Da de baja el usuario anterior
        UPDATE sprSymbGs_h  
        SET logIdTo = v_id, dateTo = v_fecha 
        WHERE gsId = :OLD.gsId AND logIdTo = 0;

        -- Inserta el nuevo usuario
        INSERT INTO sprSymbGs_h (
            gsId, caption, categoryId, scale, type, imagePath, logIdFrom,logIdTo,dateFrom,dateTo)
        VALUES (
            :NEW.gsId, :NEW.caption, :NEW.categoryId, :NEW.scale, :NEW.type, :NEW.imagePath, v_id, 0, v_fecha, null ); 
            
        TRACKER.CIERRA_REVISION( v_id );             
    END IF;
            
END;
/
ALTER TRIGGER "SPRSYMBGS_UPDATE" ENABLE;

--------------------------------------------------------
--  DDL for Trigger NODEPOINTS_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "NODEPOINTS_DELETE" 
BEFORE DELETE ON NODEPOINTS FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
   v_id := TRACKER.NUEVA_REVISION( 'nodePoints', :OLD.sprId, v_fecha );
                
    -- Baja lógica en la tabla histórica
    UPDATE nodePoints_h 
    SET logIdTo = v_id, dateTo = v_fecha
    WHERE sprId = :OLD.sprId AND logIdTo = 0;
    
    TRACKER.CIERRA_REVISION( v_id );   
END;
/
ALTER TRIGGER "NODEPOINTS_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger NODEPOINTS_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "NODEPOINTS_INSERT" 
BEFORE INSERT ON NODEPOINTS FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
    v_id := TRACKER.NUEVA_REVISION( 'nodePoints', :NEW.sprId, v_fecha );
             
    INSERT INTO nodePoints_h (
        sprId, nodeIndex, x, y, z, logIdFrom,logIdTo,dateFrom,dateTo)
    VALUES (
        :NEW.sprId, :NEW.nodeIndex, :NEW.x, :NEW.y, :NEW.z, v_id, 0, v_fecha, null ); 
        
    TRACKER.CIERRA_REVISION( v_id );    
END;
/
ALTER TRIGGER "NODEPOINTS_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger NODEPOINTS_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "NODEPOINTS_UPDATE" 
BEFORE UPDATE ON NODEPOINTS FOR EACH ROW
DECLARE
   v_id NUMBER;
   v_fecha DATE;
BEGIN
  
    IF :OLD.nodeIndex <> :NEW.nodeIndex OR
        :OLD.x <> :NEW.x OR
        :OLD.y <> :NEW.y OR
        :OLD.z <> :NEW.z THEN 
        
        v_id := TRACKER.NUEVA_REVISION( 'nodePoints', :NEW.sprId, v_fecha );
         
        -- Da de baja el usuario anterior
        UPDATE nodePoints_h  
        SET logIdTo = v_id, dateTo = v_fecha 
        WHERE sprId = :OLD.sprId AND logIdTo = 0;

        -- Inserta el nuevo usuario
        INSERT INTO nodePoints_h (
            sprId, nodeIndex, x, y, z, logIdFrom,logIdTo,dateFrom,dateTo)
        VALUES (
            :NEW.sprId, :NEW.nodeIndex, :NEW.x, :NEW.y, :NEW.z, v_id, 0, v_fecha, null ); 
            
        TRACKER.CIERRA_REVISION( v_id );             
    END IF;
END;
/
ALTER TRIGGER "NODEPOINTS_UPDATE" ENABLE;

--------------------------------------------------------
--  DDL for Trigger SPRSYMBGSPART_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSYMBGSPART_DELETE" 
BEFORE DELETE ON SPRSYMBGSPART FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
    v_id := TRACKER.NUEVA_REVISION( 'sprSymbGsPart', :OLD.gsPartId, v_fecha );
                
    -- Baja lógica en la tabla histórica
    UPDATE sprSymbGsPart_h 
    SET logIdTo = v_id, dateTo = v_fecha
    WHERE gsPartId = :OLD.gsPartId AND logIdTo = 0;
    
    TRACKER.CIERRA_REVISION( v_id );    
END;
/
ALTER TRIGGER "SPRSYMBGSPART_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPRSYMBGSPART_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSYMBGSPART_INSERT" 
BEFORE INSERT ON SPRSYMBGSPART FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
    v_id := TRACKER.NUEVA_REVISION( 'sprSymbGsPart', :NEW.gsPartId, v_fecha );
             
    INSERT INTO sprSymbGsPart_h (
        gsPartId, gsId, item, type, flags, color, lineType, lineTypeInfo, dbl1, dbl2, dbl3, 
        dbl4, dbl5, dbl6, logIdFrom,logIdTo,dateFrom,dateTo)
    VALUES (
        :NEW.gsPartId, :NEW.gsId, :NEW.item, :NEW.type, :NEW.flags, :NEW.color, :NEW.lineType, 
        :NEW.lineTypeInfo, :NEW.dbl1, :NEW.dbl2, :NEW.dbl3, :NEW.dbl4, :NEW.dbl5, :NEW.dbl6, 
        v_id, 0, v_fecha, null ); 
        
    TRACKER.CIERRA_REVISION( v_id );  
END;
/
ALTER TRIGGER "SPRSYMBGSPART_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPRSYMBGSPART_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSYMBGSPART_UPDATE" 
BEFORE UPDATE ON SPRSYMBGSPART FOR EACH ROW
DECLARE
   v_id NUMBER;
   v_fecha DATE;
BEGIN
    IF :OLD.gsId <> :NEW.gsId OR
        :OLD.item <> :NEW.item OR
        :OLD.type <> :NEW.type OR
        :OLD.flags <> :NEW.flags OR
        :OLD.color <> :NEW.color OR
        :OLD.lineType <> :NEW.lineType OR
        :OLD.lineTypeInfo <> :NEW.lineTypeInfo OR
        :OLD.dbl1 <> :NEW.dbl1 OR
        :OLD.dbl2 <> :NEW.dbl2 OR
        :OLD.dbl3 <> :NEW.dbl3 OR
        :OLD.dbl4 <> :NEW.dbl4 OR
        :OLD.dbl5 <> :NEW.dbl5 OR
        :OLD.dbl6 <> :NEW.dbl6 THEN 
        
        v_id := TRACKER.NUEVA_REVISION( 'sprSymbGsPart', :NEW.gsPartId, v_fecha );
         
        -- Da de baja el usuario anterior
        UPDATE sprSymbGsPart_h  
        SET logIdTo = v_id, dateTo = v_fecha 
        WHERE gsPartId = :OLD.gsPartId AND logIdTo = 0;

        -- Inserta el nuevo usuario
        INSERT INTO sprSymbGsPart_h (
            gsPartId, gsId, item, type, flags, color, lineType, lineTypeInfo, dbl1, dbl2, dbl3, 
            dbl4, dbl5, dbl6, logIdFrom,logIdTo,dateFrom,dateTo)
        VALUES (
            :NEW.gsPartId, :NEW.gsId, :NEW.item, :NEW.type, :NEW.flags, :NEW.color, :NEW.lineType, 
            :NEW.lineTypeInfo, :NEW.dbl1, :NEW.dbl2, :NEW.dbl3, :NEW.dbl4, :NEW.dbl5, :NEW.dbl6, 
            v_id, 0, v_fecha, null ); 
            
        TRACKER.CIERRA_REVISION( v_id );             
    END IF;
END;
/
ALTER TRIGGER "SPRSYMBGSPART_UPDATE" ENABLE;


--------------------------------------------------------
--  DDL for Trigger SPRSYMBGSPARTVERTEX_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSYMBGSPARTVERTEX_DELETE" 
BEFORE DELETE ON SPRSYMBGSPARTVERTEX FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
    v_id := TRACKER.NUEVA_REVISION( 'sprSymbGsPartVertex', :NEW.gsPartVertexId, v_fecha );
                
    -- Baja lógica en la tabla histórica
    UPDATE sprSymbGsPartVertex_h 
    SET logIdTo = v_id, dateTo = v_fecha
    WHERE gsPartVertexId = :OLD.gsPartVertexId AND logIdTo = 0;
    
    TRACKER.CIERRA_REVISION( v_id );     
END;
/
ALTER TRIGGER "SPRSYMBGSPARTVERTEX_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPRSYMBGSPARTVERTEX_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSYMBGSPARTVERTEX_INSERT" 
BEFORE INSERT ON SPRSYMBGSPARTVERTEX FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
    v_id := TRACKER.NUEVA_REVISION( 'sprSymbGsPartVertex', :NEW.gsPartVertexId, v_fecha );
             
    INSERT INTO sprSymbGsPartVertex_h (
        gsPartVertexId,gsPartId,item, x, y, bulge, startwidth, endwidth, logIdFrom,logIdTo,dateFrom,dateTo)
    VALUES (
        :NEW.gsPartVertexId, :NEW.gsPartId, :NEW.item, :NEW.x, :NEW.y, :NEW.bulge, :NEW.startwidth, 
        :NEW.endwidth, v_id, 0, v_fecha, null ); 
        
    TRACKER.CIERRA_REVISION( v_id );    
END;
/
ALTER TRIGGER "SPRSYMBGSPARTVERTEX_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPRSYMBGSPARTVERTEX_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSYMBGSPARTVERTEX_UPDATE" 
BEFORE UPDATE ON SPRSYMBGSPARTVERTEX FOR EACH ROW
DECLARE
   v_id NUMBER;
   v_fecha DATE;
BEGIN
  IF :OLD.gsPartId <> :NEW.gsPartId OR
        :OLD.item <> :NEW.item OR
        :OLD.x <> :NEW.x OR 
        :OLD.y <> :NEW.y OR 
        :OLD.bulge <> :NEW.bulge OR 
        :OLD.startWidth <> :NEW.startWidth OR 
        :OLD.endWidth <> :NEW.endWidth THEN 
        
        v_id := TRACKER.NUEVA_REVISION( 'sprSymbGsPartVertex', :NEW.gsPartVertexId, v_fecha );
         
        -- Da de baja el usuario anterior
        UPDATE sprSymbGsPartVertex_h  
        SET logIdTo = v_id, dateTo = v_fecha 
        WHERE gsPartVertexId = :OLD.gsPartVertexId AND logIdTo = 0;

        -- Inserta el nuevo usuario
        INSERT INTO sprSymbGsPartVertex_h (
            gsPartVertexId,gsPartId,item, x, y, bulge, startwidth, endwidth, logIdFrom,logIdTo,dateFrom,dateTo)
        VALUES (
            :NEW.gsPartVertexId, :NEW.gsPartId, :NEW.item, :NEW.x, :NEW.y, :NEW.bulge, :NEW.startwidth, 
            :NEW.endwidth, v_id, 0, v_fecha, null ); 
            
        TRACKER.CIERRA_REVISION( v_id );             
    END IF;
END;
/
ALTER TRIGGER "SPRSYMBGSPARTVERTEX_UPDATE" ENABLE;

--------------------------------------------------------
--  DDL for Trigger SPRSYMBRULES_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSYMBRULES_DELETE" 
BEFORE DELETE ON SPRSYMBRULES FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
    v_id := TRACKER.NUEVA_REVISION( 'sprSymbRules', :OLD.ruleId, v_fecha );
                
    -- Baja lógica en la tabla histórica
    UPDATE sprSymbRules_h 
    SET logIdTo = v_id, dateTo = v_fecha
    WHERE ruleId = :OLD.ruleId AND logIdTo = 0;
    
    TRACKER.CIERRA_REVISION( v_id );    
END;
/
ALTER TRIGGER "SPRSYMBRULES_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPRSYMBRULES_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSYMBRULES_INSERT" 
BEFORE INSERT ON SPRSYMBRULES FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
    v_id := TRACKER.NUEVA_REVISION( 'sprSymbRules', :NEW.ruleId, v_fecha );
             
    INSERT INTO sprSymbRules_h (
        ruleId, profileId, scaleRangeId, sprId, providerName, configStringId, drawOrder,
        logIdFrom,logIdTo,dateFrom,dateTo)
    VALUES (
        :NEW.ruleId, :NEW.profileId, :NEW.scaleRangeId, :NEW.sprId, :NEW.providerName, :NEW.configStringId, 
        :NEW.drawOrder, v_id, 0, v_fecha, null ); 
        
    TRACKER.CIERRA_REVISION( v_id );    
END;
/
ALTER TRIGGER "SPRSYMBRULES_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPRSYMBRULES_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSYMBRULES_UPDATE" 
BEFORE UPDATE ON SPRSYMBRULES FOR EACH ROW
DECLARE
   v_id NUMBER;
   v_fecha DATE;
BEGIN
    IF :OLD.profileId <> :NEW.profileId OR
        :OLD.scaleRangeId <> :NEW.scaleRangeId OR 
        :OLD.sprId <> :NEW.sprId OR
        :OLD.providerName <> :NEW.providerName OR
        :OLD.configStringId <> :NEW.configStringId OR
        :OLD.drawOrder <> :NEW.drawOrder THEN
        
        v_id := TRACKER.NUEVA_REVISION( 'sprSymbRules', :NEW.ruleId, v_fecha );
         
        -- Da de baja el usuario anterior
        UPDATE sprSymbRules_h  
        SET logIdTo = v_id, dateTo = v_fecha 
        WHERE ruleId = :OLD.ruleId AND logIdTo = 0;

        -- Inserta el nuevo usuario
        INSERT INTO sprSymbRules_h (
            ruleId, profileId, scaleRangeId, sprId, providerName, configStringId, drawOrder,
            logIdFrom,logIdTo,dateFrom,dateTo)
        VALUES (
            :NEW.ruleId, :NEW.profileId, :NEW.scaleRangeId, :NEW.sprId, :NEW.providerName, :NEW.configStringId, 
            :NEW.drawOrder, v_id, 0, v_fecha, null ); 
        
    TRACKER.CIERRA_REVISION( v_id );          
    END IF;
END;
/
ALTER TRIGGER "SPRSYMBRULES_UPDATE" ENABLE;

--------------------------------------------------------
--  DDL for Trigger SPRSTRINGCHUNKS_DELETE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSTRINGCHUNKS_DELETE" 
BEFORE DELETE ON SPRSTRINGCHUNKS FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
   v_id := TRACKER.NUEVA_REVISION( 'sprStringChunks', :OLD.stringId, v_fecha );
                
    -- Baja lógica en la tabla histórica
    UPDATE sprStringChunks_h 
    SET logIdTo = v_id, dateTo = v_fecha
    WHERE stringId = :OLD.stringId AND logIdTo = 0;
    
    TRACKER.CIERRA_REVISION( v_id );    
END;
/
ALTER TRIGGER "SPRSTRINGCHUNKS_DELETE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPRSTRINGCHUNKS_INSERT
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSTRINGCHUNKS_INSERT" 
BEFORE INSERT ON SPRSTRINGCHUNKS FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
    v_id := TRACKER.NUEVA_REVISION( 'sprStringChunks', :NEW.stringId, v_fecha );
             
    INSERT INTO sprStringChunks_h (
        stringId, chunkOrder, stringChunk, logIdFrom, logIdTo, dateFrom, dateTo)
    VALUES (
        :NEW.stringId, :NEW.chunkOrder, :NEW.stringChunk, v_id, 0, v_fecha, null ); 
        
    TRACKER.CIERRA_REVISION( v_id );   
END;
/
ALTER TRIGGER "SPRSTRINGCHUNKS_INSERT" ENABLE;
--------------------------------------------------------
--  DDL for Trigger SPRSTRINGCHUNKS_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "SPRSTRINGCHUNKS_UPDATE" 
BEFORE UPDATE ON SPRSTRINGCHUNKS FOR EACH ROW
DECLARE
    v_id NUMBER;
    v_fecha DATE;
BEGIN
    IF :OLD.chunkOrder <> :NEW.chunkOrder OR
        :OLD.stringChunk <> :NEW.stringChunk THEN 
      
      v_id := TRACKER.NUEVA_REVISION( 'sprStringChunks', :NEW.stringId, v_fecha );
      
      UPDATE sprStringChunks_h  
        SET logIdTo = v_id, dateTo = v_fecha 
        WHERE stringId = :OLD.stringId AND logIdTo = 0;
             
      INSERT INTO sprStringChunks_h (
          stringId, chunkOrder, stringChunk, logIdFrom, logIdTo, dateFrom, dateTo)
      VALUES (
          :NEW.stringId, :NEW.chunkOrder, :NEW.stringChunk, v_id, 0, v_fecha, null ); 
        
      TRACKER.CIERRA_REVISION( v_id );  
      
    END IF;
END;
/
ALTER TRIGGER "SPRSTRINGCHUNKS_UPDATE" ENABLE;
