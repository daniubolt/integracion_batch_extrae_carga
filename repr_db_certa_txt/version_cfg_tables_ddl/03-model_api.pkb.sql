create or replace PACKAGE  BODY                                                 MODEL_API AS
/******************************************************************************
   NAME:       MODEL_API
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/09/2015      drodriguez       1. Created this package.
******************************************************************************/

--------------------------------------------------------------------------------------------------------------
-- TOOLS -----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
FUNCTION GET_NEXT_ID( 
    p_sequence_name    sprtables.tablename%TYPE,
    p_range            NUMBER DEFAULT 1)
RETURN sprtables.nextid%TYPE
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_table_name   sprtables.tablename%TYPE;
    v_nextid       sprtables.nextid%TYPE;
BEGIN
    v_table_name := TRIM(p_sequence_name);
    
    IF(v_table_name = SEQUENCE_AMAREAS) THEN
        SELECT MAX(areaId) + 1
        INTO v_nextId
        FROM amareas;
    ELSIF(v_table_name = SEQUENCE_AMPOLYGONS) THEN
        SELECT MAX(polygonId) + 1
        INTO v_nextId
        FROM ampolygons;
    ELSIF p_range > 0 THEN
        SELECT (t.nextid)
        INTO v_nextid
        FROM sprTables t
        WHERE t.tableName = v_table_name
        FOR UPDATE ;

        UPDATE sprTables t
        SET nextid = v_nextid + p_range
        WHERE t.tablename = v_table_name;

        COMMIT;
    ELSE
        model_exceptions.invalid_sequence_range;
    END IF;


    RETURN v_nextid;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        model_exceptions.invalid_sequence_name;
    WHEN OTHERS THEN
        RAISE;
END;

FUNCTION GET_MODULE(p_x IN FLOAT, p_y IN FLOAT)
RETURN sprobjects.module%TYPE
IS
    xtmp            NUMBER (30, 0);
    ytmp            NUMBER (30, 0);
    modulostmp      NUMBER;
    valor           NUMBER;
    v_xmin          NUMBER;
    v_xmax          NUMBER;
    v_ymin          NUMBER;
    v_ymax          NUMBER;
    v_lado_modulo   NUMBER;
BEGIN
  --obtiene la informacion del proyecto.
  SELECT TRIM (v8.varvalue) AS v8, TRIM (v9.varvalue) AS v9,
         TRIM (v10.varvalue) AS v10, TRIM (v11.varvalue) AS v11,
         TRIM (v12.varvalue) AS v12
    INTO v_xmin, v_ymin,
         v_xmax, v_ymax,
         v_lado_modulo
    FROM sprgsysvars v8,
         sprgsysvars v9,
         sprgsysvars v10,
         sprgsysvars v11,
         sprgsysvars v12
   WHERE v8.varid = 1008
     AND v9.varid = 1009
     AND v10.varid = 1010
     AND v11.varid = 1011
     AND v12.varid = 1012;

  IF v_lado_modulo = 0
  THEN
     valor := -1;
  ELSE
     xtmp := TRUNC ((p_x - v_xmin) / v_lado_modulo);
     ytmp := TRUNC ((p_y - v_ymin) / v_lado_modulo);
     modulostmp := (v_ymax - v_ymin) / v_lado_modulo;
     valor := xtmp * modulostmp + ytmp + 1;

     IF valor < 0
     THEN
        valor := -1;
     END IF;
  END IF;

  RETURN valor;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        model_exceptions.invalid_project_parameters;
    WHEN OTHERS THEN
        RAISE;
END;

--------------------------------------------------------------------------------------------------------------
-- TRANSACTION -----------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

FUNCTION IS_LOCKED( p_date sprlog.eventdate%TYPE )
RETURN BOOLEAN
IS
    v_locked   NUMBER;
BEGIN
    SELECT COUNT (1)
    INTO v_locked
    FROM sprgintprocesses
    WHERE deletelogid = 0
        AND provisional_analysis = 0
        AND procdateto >= p_date;

    IF v_locked = 0 THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
   

PROCEDURE CREATE_REVISION_SEQ(
    p_logId       IN sprlog.logid%TYPE,
    p_eventDate   IN sprlog.eventdate%TYPE,
    p_userId      IN sprlog.userid%TYPE,
    p_eventData   IN sprlog.eventdata%TYPE,
    p_eventType   IN sprlog.eventtype%TYPE := REVISION_TYPE_MODEL,
    p_eventStatus IN sprlog.eventStatus%TYPE := REVISION_STATUS_PENDING )
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_userid   NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_userid
    FROM users
    WHERE userid = p_userid;
   
    IF v_userid = 0 THEN
       model_exceptions.invalid_user;
    END IF;         
   
    IF IS_LOCKED(p_eventdate) THEN   
       model_exceptions.revision_date_out_of_range;
    END IF;
   
    INSERT INTO sprLog
       (logid, logdate, superlogid, userid, eventtype,
        eventdate, eventstatus, eventdata )
    VALUES (p_logid, SYSDATE, 0, p_userid, p_eventtype, 
        p_eventdate, p_eventStatus, p_eventdata  );   
   
    COMMIT;    
END;


FUNCTION CREATE_REVISION(
    p_userid      IN sprlog.userid%TYPE,
    p_eventdata   IN sprlog.eventdata%TYPE,
    p_eventdate   IN sprlog.eventdate%TYPE := SYSDATE,
    p_eventtype   IN sprlog.eventtype%TYPE := REVISION_TYPE_MODEL )
RETURN NUMBER
AS
    v_revision NUMBER;
BEGIN     
    v_revision := GET_NEXT_ID( SEQUENCE_SPRLOG );
    CREATE_REVISION_SEQ( v_revision, p_eventdate, p_userid, p_eventdata, p_eventtype );
    RETURN v_revision;
END;


PROCEDURE COMMIT_REVISION( p_logid sprlog.logid%TYPE )
IS
    v_transaction   NUMBER;
    v_eventdate     DATE;
BEGIN
    
    SELECT eventstatus, eventdate
    INTO v_transaction, v_eventdate
    FROM sprlog
    WHERE logid = p_logid AND eventstatus = REVISION_STATUS_PENDING;

    IF v_transaction <> REVISION_STATUS_PENDING THEN
        model_exceptions.invalid_revision_state;
    END IF;
    
    IF IS_LOCKED(v_eventdate) THEN   
       model_exceptions.revision_date_out_of_range;
    END IF;
   
    UPDATE sprlog
    SET eventstatus = REVISION_STATUS_OK
    WHERE logid = p_logid;

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         model_exceptions.invalid_revision_state;
    WHEN OTHERS THEN
         RAISE;
END;


PROCEDURE CANCEL_REVISION( p_logid sprlog.logid%TYPE )
IS
    v_transaction   NUMBER;
    v_eventdate     DATE;
BEGIN
    
    SELECT eventstatus, eventdate
    INTO v_transaction, v_eventdate
    FROM sprlog
    WHERE logid = p_logid AND eventstatus = REVISION_STATUS_PENDING;

    IF v_transaction <> REVISION_STATUS_PENDING THEN
        model_exceptions.invalid_revision_state;
    END IF;
    
    IF IS_LOCKED(v_eventdate) THEN   
       model_exceptions.revision_date_out_of_range;
    END IF;
   
    UPDATE sprlog
    SET eventstatus = REVISION_STATUS_DISCARD
    WHERE logid = p_logid;

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        model_exceptions.invalid_revision_state;
    WHEN OTHERS THEN
        RAISE;
END;

----------------------------------------------------------------------------------------------------------
-- SYMBOL ------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
 
PROCEDURE CREATE_SYMBOL_SEQ(
  p_objectId sprobjects.objectId%TYPE,
  p_logId    sprlog.logid%TYPE,
  p_sprid    sprobjects.sprid%TYPE,
  p_x        sprobjects.x%TYPE,
  p_y        sprobjects.y%TYPE,
  p_angle    sprobjects.angle%TYPE,
  p_scale    sprobjects.scale%TYPE,
  p_color    sprobjects.sprcolor%TYPE
)
AS
    v_dateTo DATE;
    v_dateFrom DATE;
    v_module NUMBER;
    v_count NUMBER;
BEGIN

    SELECT eventDate
    INTO v_dateTo   
    FROM sprLog 
    WHERE logid = 0;

     BEGIN
        SELECT eventDate
        INTO v_dateFrom   
        FROM sprLog 
        WHERE logid = p_logId AND eventstatus = 1;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_revision_state;
     END;
      
     IF p_scale < 0 THEN
         model_exceptions.invalid_object_scale;
     END IF;     
     
     SELECT COUNT(*)
     INTO v_count
     FROM sprentities
     WHERE sprid = p_sprid AND entityType = 'S';

     IF v_count = 0 THEN
        model_exceptions.invalid_object_sprid; 
     END IF;
             
     v_module := GET_MODULE( p_x, p_y );
    
     INSERT INTO sprobjects (
        objectid, objectnameid, previousid, nextid,
        sprid, x, y, angle, scale, module,
        objecttype, realdate, realstate,
        normaldate, normalstate, datefrom, dateto,
        logidfrom, logidto, projectid, sprcolor )
     VALUES (
        p_objectId, p_objectId, 0, 0,
        p_sprid, p_x, p_y, p_angle, p_scale, v_module,
        TYPE_SYMBOL, NULL, 15, NULL, 15, v_dateFrom, v_dateTo,
        p_logid, 0, 0, p_color );

     INSERT INTO net_modules 
        (module, objecttype, objectid )
     VALUES (
        v_module, TYPE_SYMBOL, p_objectId );

END;

FUNCTION CREATE_SYMBOL(
    p_logId    sprlog.logid%TYPE,
    p_sprid    sprobjects.sprid%TYPE,
    p_x        sprobjects.x%TYPE,
    p_y        sprobjects.y%TYPE,
    p_angle    sprobjects.angle%TYPE,
    p_scale    sprobjects.scale%TYPE,
    p_color    sprobjects.sprcolor%TYPE
)
RETURN NUMBER
AS
    v_id NUMBER;
BEGIN
    v_id := GET_NEXT_ID( SEQUENCE_SPROBJECTS );
    CREATE_SYMBOL_SEQ( v_id, p_logId, p_sprid, p_x, p_y, p_angle, p_scale, p_color );
    RETURN v_id;
END;

PROCEDURE DELETE_SYMBOL(
    p_objectid    sprobjects.objectid%TYPE,
    p_logid       sprlog.logid%TYPE)
IS
    v_ftv         NUMBER;
    v_dateto      sprlog.eventdate%TYPE;
    v_projectid   sprgprojects.projectid%TYPE;
BEGIN
    BEGIN
        SELECT eventdate
        INTO v_dateto
        FROM sprlog
        WHERE logid = p_logid AND eventstatus = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_revision_state;
    END;

    SELECT COUNT(*)
    INTO v_ftv
    FROM sprobjects
    WHERE     objectid = p_objectid
    AND logidto = 0
    AND v_dateto BETWEEN datefrom AND dateto;

    --IF v_ftv = 1 THEN
    --    model_exceptions.revision_date_out_of_range;
    --END IF;
    
    --v_projectid := get_projectid (p_objectid, model_constants.object_type_sprsymbol);
    --IF v_projectid = 0 THEN 
    --    model_exceptions.object_locked;
    --END IF;
     
    DELETE_ALL_LINKS( p_objectid, TYPE_SYMBOL, p_logid );
    -- FIXME DGE falta DELETE_ALL_TOPOLOGIES

    UPDATE sprobjects
    SET dateto = v_dateto, logidto = p_logid
    WHERE objectid = p_objectid;

END;

----------------------------------------------------------------------------------------------------------
-- CONNECTOR ---------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

PROCEDURE CREATE_CONNECTOR_SEQ(
  p_objectId sprobjects.objectId%TYPE,
  p_sprid   sprobjects.sprid%TYPE,
  arr_x  FLOAT_ARRAY,
  arr_y  FLOAT_ARRAY,
  p_logid   sprlog.logid%TYPE,
  p_color sprobjects.sprcolor%TYPE
)
AS
    v_dateTo DATE;
    v_dateFrom DATE;
    v_count NUMBER;
    v_module NUMBER;
BEGIN

    SELECT eventDate
    INTO v_dateTo   
    FROM sprLog 
    WHERE logid = 0;

    BEGIN
        SELECT eventDate
        INTO v_dateFrom   
        FROM sprLog 
        WHERE logid = p_logId AND eventstatus = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_revision_state;
    END;
          
    SELECT COUNT(*)
    INTO v_count
    FROM sprentities
    WHERE sprid = p_sprid AND entityType = 'C';

    --IF v_count = 0 THEN
    --    model_exceptions.invalid_object_sprid; 
    --END IF;
             
    INSERT INTO sprobjects (
        objectid, objectnameid, previousid, nextid,
        sprid, x, y, angle, scale, module,
        objecttype, realdate, realstate,
        normaldate, normalstate, datefrom, dateto,
        logidfrom, logidto, projectid, sprcolor )
    VALUES (
        p_objectid, p_objectid, 0, 0,
        p_sprid, NULL, NULL, NULL, NULL, NULL,
        TYPE_CONNECTOR, NULL, 15, NULL, 15, v_datefrom, v_dateTo,
        p_logid, 0, 0, p_color );

    FOR i IN 1 .. arr_x.COUNT
    LOOP
        INSERT INTO SPROBJECTVERTIXS ( OBJECTID, VERTIXORDER, X, Y) 
        VALUES ( p_objectId, (i-1), arr_x(i), arr_y(i) );
    END LOOP;

    FOR i IN 1 .. arr_x.COUNT
    LOOP
        v_module := GET_MODULE(arr_x(i),arr_y(i));
        SELECT COUNT(*) 
        INTO v_count
        FROM net_modules
        WHERE module = v_module AND objectType = TYPE_CONNECTOR AND objectId = p_objectId;
        
        IF v_count = 0 THEN 
            INSERT INTO net_modules (
                module, objecttype, objectid)
            VALUES (
                v_module, TYPE_CONNECTOR, p_objectId);    
        END IF;
                    
    END LOOP;
  
END;

FUNCTION CREATE_CONNECTOR (
    p_sprid   sprobjects.sprid%TYPE,
    arr_x  FLOAT_ARRAY,
    arr_y  FLOAT_ARRAY,
    p_logid   sprlog.logid%TYPE,
    p_color sprobjects.sprcolor%TYPE
)
RETURN NUMBER
AS
    v_id NUMBER;
BEGIN
    v_id := GET_NEXT_ID( SEQUENCE_SPROBJECTS );
    CREATE_CONNECTOR_SEQ( v_id, p_sprid, arr_x, arr_y, p_logid, p_color );
    RETURN v_id;
END;


PROCEDURE DELETE_CONNECTOR(
    p_objectid    sprobjects.objectid%TYPE,
    p_logid       sprlog.logid%TYPE)
IS
    v_ftv         NUMBER;
    v_dateto      sprlog.eventdate%TYPE;
    v_projectid   sprgprojects.projectid%TYPE;
BEGIN
    BEGIN
        SELECT eventdate
        INTO v_dateto
        FROM sprlog
        WHERE logid = p_logid AND eventstatus = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_revision_state;
    END;

    SELECT COUNT(*)
    INTO v_ftv
    FROM sprobjects
    WHERE objectid = p_objectid
        AND logidto = 0
        AND v_dateto>datefrom AND v_dateTo<dateto;

    --IF v_ftv <> 1 THEN
    --    model_exceptions.revision_date_out_of_range;
    --END IF;
    
    --v_projectid := get_projectid(p_objectid, TYPE_CONNECTOR );
    --IF v_projectid = 0
    --END IF;
    
    DELETE_ALL_LINKS( p_objectid, TYPE_CONNECTOR, p_logid );
    -- FIXME DGR delete_object_topologies (p_objectid, p_logid);

    UPDATE sprobjects
    SET dateto = v_dateto, logidto = p_logid
    WHERE objectid = p_objectid;

END;


--------------------------------------------------------------------------------------------------------------
-- BLOCKS ----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

PROCEDURE CREATE_BLOCK_SEQ(
    p_objectId sprobjects.objectId%TYPE,
    p_sprid    sprobjects.sprid%TYPE,
    arr_x      FLOAT_ARRAY,
    arr_y      FLOAT_ARRAY,
    p_logid    sprlog.logid%TYPE
)
AS
    v_dateTo DATE;
    v_dateFrom DATE;
    v_count NUMBER;
BEGIN

    SELECT eventDate
    INTO v_dateTo   
    FROM sprLog 
    WHERE logid = 0;

    BEGIN
        SELECT eventDate
        INTO v_dateFrom   
        FROM sprLog 
        WHERE logid = p_logId AND eventstatus = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_revision_state;
    END;
          
    SELECT COUNT(*)
    INTO v_count
    FROM sprentities
    WHERE sprid = p_sprid AND entityType = 'M';

    IF v_count = 0 THEN
        model_exceptions.invalid_object_sprid; 
    END IF;

    INSERT INTO smBlocks (
       blockid, objectnameid, previousid, nextid, sprid, 
       blockname, areaid, blockflags,  
       datefrom, dateto, 
       logidfrom, logidto, projectid ) 
    VALUES ( 
        p_objectid, p_objectid, 0, 0, p_sprid, 
        NULL, 0, 0,
        v_datefrom, v_dateTo, 
        p_logid, 0,  0 );
        
    FOR i IN 1 .. arr_x.COUNT LOOP
        INSERT INTO smBlockGeo (
            blockId, blockGeoOrder, x, y, z )
        VALUES ( 
            p_objectId, i-1, arr_x(i), arr_y(i), 0 );
    END LOOP;
  
END;

FUNCTION CREATE_BLOCK(
    p_sprid     sprobjects.sprid%TYPE,
    arr_x       FLOAT_ARRAY,
    arr_y       FLOAT_ARRAY,
    p_logid     sprlog.logid%TYPE
) 
RETURN NUMBER
IS
    v_id NUMBER;
BEGIN
    v_id := GET_NEXT_ID( SEQUENCE_SPROBJECTS );
    CREATE_BLOCK_SEQ( v_id, p_sprid, arr_x, arr_y, p_logid );
    RETURN v_id;
END;


PROCEDURE DELETE_BLOCK(
    p_blockid    smblocks.blockid%TYPE,
    p_logid      sprlog.logid%TYPE)
IS
    v_ftv         NUMBER;
    v_dateto      sprlog.eventdate%TYPE;
    v_projectid   sprgprojects.projectid%TYPE;
BEGIN
    BEGIN
        SELECT eventdate
        INTO v_dateto
        FROM sprlog
        WHERE logid = p_logid AND eventstatus = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_revision_state;
    END;

    SELECT COUNT(*)
    INTO v_ftv
    FROM smblocks
    WHERE blockid = p_blockid
        AND logidto = 0
        AND v_dateto > datefrom AND v_dateto < dateto;

    --IF v_ftv <> 1 THEN
    --    model_exceptions.revision_date_out_of_range;
    --END IF;
    
    --v_projectid := get_projectid( p_blockid, TYPE_BLOCK );
    --IF v_projectid <> 0 THEN
    --END IF;
      
    DELETE_ALL_LINKS( p_blockid, TYPE_BLOCK, p_logid );
    -- Las manzanas no tienen topologias
    
    UPDATE smblocks
    SET dateto = v_dateto, logidto = p_logid
    WHERE blockid = p_blockid;

END;

PROCEDURE INTERNAL_DELETE_BLOCK(
    p_blockid    smblocks.blockid%TYPE,
    p_nextId     smBlocks.nextid%TYPE,
    p_logid      sprlog.logid%TYPE)
IS
    v_ftv         NUMBER;
    v_dateTo      sprlog.eventdate%TYPE;

BEGIN
    BEGIN
        SELECT eventdate
        INTO v_dateto
        FROM sprlog
        WHERE logid = p_logid AND eventstatus = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_revision_state;
    END;

    SELECT COUNT(*)
    INTO v_ftv
    FROM smblocks
    WHERE blockid = p_blockid
        AND logidto = 0
        AND v_dateto > datefrom AND v_dateto < dateto;

    IF v_ftv <> 1 THEN
        model_exceptions.revision_date_out_of_range;
    END IF;
      
    DELETE_ALL_LINKS( p_blockid, TYPE_BLOCK, p_logid );
    -- Las manzanas no tienen topologias
    
    UPDATE smBlocks
    SET dateTo = v_dateTo, logidTo = p_logid, nextId = p_nextId
    WHERE blockid = p_blockid;

END;

PROCEDURE CLONE_AND_DELETE_BLOCK(
    p_blockId       sprobjects.objectId%TYPE,
    p_newBlockId    sprobjects.objectId%TYPE, 
    p_logId         sprlog.logid%TYPE
)
AS
    v_dateTo DATE;
    v_dateFrom DATE; 
    
BEGIN 
    SELECT eventDate
    INTO v_dateTo   
    FROM sprLog 
    WHERE logid = 0;

    BEGIN
        SELECT eventDate
        INTO v_dateFrom   
        FROM sprLog 
        WHERE logid = p_logId AND eventstatus = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_revision_state;
    END;

    INSERT INTO smBlocks (
       blockid, objectnameid, previousid, nextid, sprid, 
       blockname, areaid, blockflags,  
       datefrom, dateto, 
       logidfrom, logidto, projectid ) 
    SELECT p_newBlockId, objectnameid, p_blockId, 0, sprid, 
        blockname, areaid, blockflags, 
        v_datefrom, v_dateTo, p_logid, 0, 0 
    FROM smBlocks
    WHERE blockid = p_blockId;

    INSERT INTO smBlockGeo (blockId, blockGeoOrder, x, y, z) 
    SELECT p_newBlockId, blockGeoOrder, x, y, z 
    FROM smBlockGeo
    WHERE blockId = p_blockId;

    INSERT INTO sprLinks ( objectId, objectType, linkId, seqOrder, linkValue, 
    dateFrom, dateTo, logIdFrom, logIdTo )
    SELECT p_newBlockId, objectType, linkId, seqOrder, linkValue, 
        v_dateFrom, v_dateTo, p_logId, 0
    FROM sprLinks 
    WHERE objectId = p_blockId;

    INTERNAL_DELETE_BLOCK( p_blockId, p_newBlockId, p_logId );

END;


--------------------------------------------------------------------------------------------------------------
-- STREETS ---------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
PROCEDURE CREATE_STREET_SEQ(
    p_streetId          smStreets.streetId%TYPE,
    p_street_type_id    smStreets.streetTypeId%TYPE,
    p_street_name       smStreets.streetName%TYPE,
    p_region_id         smStreets.regionId%TYPE, 
    p_logId             sprLog.logId%TYPE,
    p_streetShortName   smStreets.streetShortName%TYPE,
    p_fsStreetCode      smStreets.fsStreetCode%TYPE := NULL  
)
AS
    v_dateTo DATE;
    v_dateFrom DATE;
    v_userId NUMBER;
BEGIN

    SELECT eventDate
    INTO v_dateTo   
    FROM sprLog 
    WHERE logid = 0;

    -- FIXME DGR falta control de streeet type id y region_id 

    BEGIN
        SELECT eventDate, userId
        INTO v_dateFrom, v_userId   
        FROM sprLog 
        WHERE logId = p_logId AND eventStatus = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_revision_state;
    END;

    INSERT INTO smStreets ( 
        streetId, streetAntiq, streetTypeId, streetName, regionId, streetDeleted, userId, streetShortName, 
        fsStreetCode, datefrom, dateto ) 
    VALUES (
        p_streetId, 0, p_street_type_id, p_street_name, p_region_id, 0, v_userId, p_streetShortName, 
        p_fsStreetCode, v_dateFrom, v_dateTo );

END;
    

PROCEDURE UPDATE_STREET_SEQ(
    p_fromStreetId      smStreets.streetId%TYPE,
    p_toStreetId        smStreets.streetId%TYPE,
    p_name              smStreets.streetName%TYPE,
    p_regionId          smStreets.regionId%TYPE, 
    p_logId             sprLog.logId%TYPE,
    p_streetShortName   smStreets.streetShortName%TYPE,
    p_fsStreetCode      smStreets.fsStreetCode%TYPE := NULL  
)
AS
    v_dateTo DATE;
    v_dateFrom DATE;
    v_userId NUMBER;
    v_streetTypeId      smStreets.streetTypeId%TYPE;
    v_streetAntiq       smStreets.streetAntiq%TYPE; 
    v_streetName        smStreets.streetName%TYPE; 
    v_regionId          smStreets.regionId%TYPE;
    v_streetShortName   smStreets.streetShortName%TYPE;
    v_fsStreetCode      smStreets.fsStreetCode%TYPE;
BEGIN

    SELECT eventDate
    INTO v_dateTo   
    FROM sprLog 
    WHERE logid = 0;

    -- FIXME DGR falta control de  region_id 

    BEGIN
        SELECT eventDate, userId
        INTO v_dateFrom, v_userId   
        FROM sprLog 
        WHERE logId = p_logId AND eventStatus = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_revision_state;
    END;

    SELECT streetAntiq, streetTypeId, streetName, regionId, streetShortName, fsStreetCode
    INTO v_streetAntiq, v_streetTypeId, v_streetName, v_regionId, v_streetShortName, v_fsStreetCode
    FROM smStreets
    WHERE streetId = p_fromStreetId AND streetAntiq=0;
    
    IF p_name IS NOT NULL THEN v_streetName := p_name; END IF;
    IF p_regionId IS NOT NULL THEN v_regionId := p_regionId; END IF;
    IF p_streetShortName IS NOT NULL THEN v_streetShortName := p_streetShortName; END IF;
    IF p_fsStreetCode IS NOT NULL THEN v_fsStreetCode := p_fsStreetCode; END IF;

    UPDATE smStreets 
    SET streetAntiq = (streetAntiq+1)
    WHERE streetId = p_fromStreetId  AND streetAntiq != 0;
    
    UPDATE smStreets 
    SET dateTo = v_dateFrom, streetAntiq = 1
    WHERE streetId = p_fromStreetId AND streetAntiq = 0;

    INSERT INTO smStreets ( 
        streetId, streetAntiq, streetTypeId, streetName, 
        regionId, streetDeleted, userId, streetShortName, 
        fsStreetCode, dateFrom, dateTo ) 
    VALUES (
        p_toStreetId, 0, v_streetTypeId, v_streetName, 
        v_regionId, 0, v_userId, v_streetShortName, 
        v_fsStreetCode, v_dateFrom, v_dateTo );

END;

PROCEDURE DELETE_STREET(
    p_streetId          smStreets.streetId%TYPE,
    p_logid             sprlog.logid%TYPE )
IS
    v_ftv         NUMBER;
    v_dateTo      sprlog.eventdate%TYPE;
    v_projectId   sprgprojects.projectid%TYPE;
BEGIN
    BEGIN
        SELECT eventDate
        INTO v_dateTo
        FROM sprLog
        WHERE logId = p_logId AND eventStatus = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_revision_state;
    END;

    --SELECT COUNT(*)
    --INTO v_ftv
    --FROM smStreets
    --WHERE streetId = p_streetId
    --    AND streetDeleted = 0
    --    AND streetAntiq = 0
    --    AND v_dateTo > dateFrom AND v_dateTo < dateTo;

    --IF v_ftv <> 1 THEN
    --    model_exceptions.revision_date_out_of_range;
    --END IF;
    
    --v_projectid := get_projectid( p_blockid, TYPE_BLOCK );
    --IF v_projectid <> 0 THEN
    --END IF;
      
    -- No es necesario, las calles no tienen links
    -- DELETE_ALL_LINKS( 
    
    -- No es necesario, las callles no tienen topologias
    -- DELETE_ALL_TOPOLOGIES( 
    
    UPDATE smStreets
    SET dateTo = v_dateTo, streetDeleted = 1
    WHERE streetId = p_streetId AND streetAntiq = 0;

    UPDATE smStreets
    SET streetDeleted = 1
    WHERE streetId = p_streetId AND streetAntiq <> 0;
    
END;  

FUNCTION CREATE_STREET(
    p_street_type_id    smStreets.streetTypeId%TYPE,
    p_street_name       smStreets.streetName%TYPE,
    p_region_id         smStreets.regionId%TYPE, 
    p_logId             sprLog.logId%TYPE,
    p_streetShortName   smStreets.streetShortName%TYPE,
    p_fsStreetCode      smStreets.fsStreetCode%TYPE := NULL  
)
RETURN NUMBER
AS
    v_id NUMBER;
BEGIN
    v_id := GET_NEXT_ID( SEQUENCE_SMSTREETS );
    CREATE_STREET_SEQ( v_id, p_street_type_id, p_street_name, p_region_id, p_logId, p_streetShortName, p_fsStreetCode );
    RETURN v_id;
END;


PROCEDURE CREATE_STREET_SECTION_SEQ(
    p_objectId  smStreetSection.streetSectionId%TYPE,
    p_streetId  smstreetsection.streetId%TYPE,
    arr_x       FLOAT_ARRAY,
    arr_y       FLOAT_ARRAY,
    p_logid     sprlog.logid%TYPE
)
AS
    v_dateTo DATE;
    v_dateFrom DATE;
BEGIN

    SELECT eventDate
    INTO v_dateTo   
    FROM sprLog 
    WHERE logid = 0;

    BEGIN
        SELECT eventDate
        INTO v_dateFrom   
        FROM sprLog 
        WHERE logid = p_logId AND eventstatus = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_revision_state;
    END;

    INSERT INTO smStreetSection (
       streetsectionid, objectnameid, streetid, previousid, nextid,
       datefrom, dateto, logidfrom, logidto, projectid ) 
    VALUES (
        p_objectId, p_objectId, p_streetId, 0, 0,
        v_datefrom, v_dateTo, p_logid, 0,  0 );
        
    FOR i IN 1 .. arr_x.COUNT LOOP
        INSERT INTO smstreetgeo (
            streetSectionId, streetGeoOrder, x, y, z )
        VALUES ( 
            p_objectId, i-1, arr_x(i), arr_y(i), 0 );
     END LOOP;
  
END;


FUNCTION CREATE_STREET_SECTION(
    p_street_id smstreetsection.streetId%TYPE,
    arr_x       FLOAT_ARRAY,
    arr_y       FLOAT_ARRAY,
    p_logid     sprlog.logid%TYPE
) 
RETURN NUMBER
IS
    v_id NUMBER;
BEGIN
    v_id := GET_NEXT_ID( SEQUENCE_SPROBJECTS );
    CREATE_STREET_SECTION_SEQ( v_id, p_street_id, arr_x, arr_y, p_logid );
    RETURN v_id;
END;


PROCEDURE DELETE_STREET_SECTION(
    p_objectId    smstreetsection.streetsectionid%TYPE,
    p_logid       sprlog.logid%TYPE)
IS
    v_ftv         NUMBER;
    v_dateto      sprlog.eventdate%TYPE;
    v_projectid   sprgprojects.projectid%TYPE;
BEGIN
    BEGIN
        SELECT eventdate
        INTO v_dateto
        FROM sprlog
        WHERE logid = p_logid AND eventstatus = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_revision_state;
    END;

    SELECT COUNT(*)
    INTO v_ftv
    FROM smStreetSection
    WHERE streetsectionid = p_objectId
        AND logidto = 0
        AND v_dateto > datefrom AND v_dateto < dateto;

    --IF v_ftv <> 1 THEN
    --    model_exceptions.revision_date_out_of_range;
    --END IF;
    
    --v_projectid := get_projectid( p_blockid, TYPE_BLOCK );
    --IF v_projectid <> 0 THEN
    --END IF;
      
    DELETE_ALL_LINKS( p_objectId, TYPE_BLOCK, p_logid );
    -- Las calles no tienen topologias
    
    UPDATE smStreetSection
    SET dateto = v_dateto, logidto = p_logid
    WHERE streetsectionid = p_objectId;

END;


--------------------------------------------------------------------------------------------------------------
-- LINKS -----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

FUNCTION ADD_LINK(
    p_objectid      sprlinks.objectid%TYPE,
    p_linkid        sprlinks.linkid%TYPE,
    p_linkvalue     sprlinks.linkvalue%TYPE,
    p_logid         sprlog.logid%TYPE,
    p_objecttype    sprobjects.objecttype%TYPE)
RETURN NUMBER
IS
    v_datefrom    sprlinks.dateFrom%TYPE;
    v_dateTo      sprlinks.dateTo%TYPE;
    v_projectid   sprgprojects.projectid%TYPE;
    v_seqorder    sprlinks.seqorder%TYPE;
BEGIN

    --verifica si la revision es en 1.
    BEGIN
        SELECT eventdate
        INTO v_datefrom
        FROM sprlog
        WHERE logid = p_logid AND eventstatus = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_revision_state;
    END;

    SELECT eventDate
    INTO v_dateTo   
    FROM sprLog 
    WHERE logid = 0;
    
    --FIXME DGR FALTA
    --v_projectid := get_projectid (p_objectid, p_objecttype);
    --IF v_projectid <> 0 THEN
    --  model_exceptions.object_locked;
    --END IF;
    --IF link_allowed (p_objectid, p_objecttype, p_linkid) THEN
    --END IF;
    --IF valid_format(p_linkid, p_linkvalue) THEN
    --END IF;  
  
    SELECT NVL(MAX(seqorder) + 1, 0) AS seqorder
    INTO v_seqorder
    FROM sprlinks
    WHERE objectid = p_objectid;
            
    INSERT INTO sprlinks (
        objectid, objecttype, linkid, seqorder,
        linkvalue, datefrom, dateto,
        logidfrom, logidto )
    VALUES (
        p_objectId, p_objectType, p_linkId, v_seqOrder,
        p_linkvalue, v_dateFrom, v_dateTo,
        p_logid, 0 ); 
           
    RETURN v_seqOrder;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;


PROCEDURE DELETE_LINK(
    p_objectid    sprlinks.objectid%TYPE,
    p_seqorder    sprlinks.seqorder%TYPE,
    p_logid       sprlog.logid%TYPE)
IS
    v_objecttype   sprlinks.objecttype%TYPE;
    v_projectid    sprgprojects.projectid%TYPE;
    v_dateTo      sprlinks.dateTo%TYPE;
BEGIN

    -- verifica si la revision es en 1.
    BEGIN
        SELECT eventdate
        INTO v_dateTo
        FROM sprlog
        WHERE logid = p_logid AND eventstatus = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_revision_state;
    END;

    SELECT objecttype
    INTO v_objecttype
    FROM sprlinks
    WHERE objectid = p_objectid AND seqorder = p_seqorder;

    -- FIXME DGR FALTA
    --v_projectid := get_projectid (p_objectid, p_objecttype);
    --IF v_projectid <> 0 THEN
    --  model_exceptions.object_locked;
    --END IF;
    
    UPDATE sprlinks
    SET logidto = p_logid, dateto = v_dateto
    WHERE objectid = p_objectid AND seqorder = p_seqorder AND logidto = 0;
          
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        model_exceptions.object_not_found;
    WHEN OTHERS THEN
        RAISE;
END;


PROCEDURE DELETE_ALL_LINKS(
    p_objectid    sprlinks.objectid%TYPE,
    p_objecttype  sprlinks.objecttype%TYPE,
    p_logid       sprlog.logid%TYPE)
IS
    v_projectid   sprgprojects.projectid%TYPE;
    v_dateTo      sprlinks.dateTo%TYPE;
BEGIN

    --verifica si la revision es en 1.
    BEGIN
        SELECT eventdate
        INTO v_dateTo
        FROM sprlog
        WHERE logid = p_logid AND eventstatus = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_revision_state;
    END;

    -- FIXME DGR FALTA
    --v_projectid := get_projectid (p_objectid, p_objecttype);
    --IF v_projectid <> 0 THEN
    --  model_exceptions.object_locked;
    --END IF;
    
    UPDATE sprlinks
    SET logidto = p_logid, dateto = v_dateto
    WHERE objectid = p_objectid AND logidto = 0;
          
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        model_exceptions.object_not_found;
    WHEN OTHERS THEN
        RAISE;
END;


--------------------------------------------------------------------------------------------------------------
-- AREAS -----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

PROCEDURE UPDATE_XY_MIN_MAX(
    p_areaId  AMAREAS.AREAID%TYPE,
    p_xMin    AMAREAS.AREAXMIN%TYPE,
    p_yMin    AMAREAS.AREAYMIN%TYPE,
    p_xMax    AMAREAS.AREAXMAX%TYPE,
    p_yMax    AMAREAS.AREAYMAX%TYPE
)
IS
BEGIN
  
    UPDATE amareas
    SET areaXMin = p_xMin, areaYMin = p_yMin, areaXMax = p_xMax, areaYMax = p_yMax
    WHERE areaId = p_areaId;
    
END;


PROCEDURE DELETE_AREA_POLYGON_POINTS(
    p_polygonId ampolygons.polygonId%TYPE
)
IS
BEGIN
      
    DELETE FROM amPolygonGeo 
    WHERE polygonId = p_polygonId;

END;

PROCEDURE DELETE_AREA_POLYGON(
    p_areaId   amareas.areaId%TYPE
)
IS
    v_polygonId     Ampolygons.Areaid%TYPE;
    v_pointsCount   NUMBER := 0;
BEGIN

    BEGIN
      SELECT polygonId 
      INTO v_polygonId
      FROM ampolygons
      WHERE areaId = p_areaId;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_polygonId := 0;
    END;
  
    IF v_polygonId <> 0 THEN
        
      SELECT COUNT(polygonId)
      INTO v_pointsCount
      FROM Ampolygongeo
      WHERE polygonId = v_polygonId;
      
      IF v_polygonId > 0 THEN
        
        DELETE_AREA_POLYGON_POINTS(v_polygonId);
  
      END IF;
      
      DELETE FROM amPolygons 
      WHERE polygonId = v_polygonId;
    
    END IF;
    
    UPDATE_XY_MIN_MAX(p_areaId, 0, 0, 0, 0);
    
END;

FUNCTION ADD_AREA_POLYGON_POINTS(
    p_polygonId     Ampolygons.Polygonid%TYPE,
    arr_x           FLOAT_ARRAY,
    arr_y           FLOAT_ARRAY
)
RETURN FLOAT_ARRAY
IS
    v_xMin          amareas.areaXMin%TYPE;
    v_yMin          amareas.areaYMin%TYPE;
    v_xMax          amareas.areaXMax%TYPE;
    v_yMax          amareas.areaYMax%TYPE;
    v_arrXYMinMax   FLOAT_ARRAY;
  
BEGIN
    v_arrXYMinMax := FLOAT_ARRAY(4);
    v_xMin  := arr_x(1);
    v_yMin  := arr_y(1);
    v_xMax  := arr_x(1);
    v_yMax  := arr_y(1);
    
    FOR i IN 1 .. arr_x.COUNT LOOP

        IF v_xMin > arr_x(i) THEN
            v_xMin := arr_x(i);
        END IF;

        IF v_yMin > arr_y(i) THEN
            v_yMin := arr_y(i);
        END IF;

        IF v_xMax < arr_x(i) THEN
            v_xMax := arr_x(i);
        END IF;

        IF v_yMax < arr_y(i) THEN
            v_yMax := arr_y(i);
        END IF;
        
        INSERT INTO ampolygongeo (
              polygonId, polygonVerOrder, module, x, y, z )
          VALUES ( 
              p_polygonId, i-1, 0 ,arr_x(i), arr_y(i), 0 ); 
      
    END LOOP;
    v_arrXYMinMax.extend;
    v_arrXYMinMax(1) := v_xMin;
    v_arrXYMinMax.extend;
    v_arrXYMinMax(2) := v_yMin;
    v_arrXYMinMax.extend;
    v_arrXYMinMax(3) := v_xMax;
    v_arrXYMinMax.extend;
    v_arrXYMinMax(4) := v_yMax;
    
    RETURN v_arrXYMinMax;
     
END;


PROCEDURE ADD_AREA_POLYGON( 
    p_areaId  amareas.areaId%TYPE, 
    arr_x     FLOAT_ARRAY,
    arr_y     FLOAT_ARRAY
)
IS
    v_arrXYMinMax   FLOAT_ARRAY;
    v_polygonId     ampolygongeo.polygonId%Type;
BEGIN
       
    v_polygonId := GET_NEXT_ID( SEQUENCE_AMPOLYGONS );
    
    INSERT INTO ampolygons ( polygonId, areaId, polygonAddSub )
    VALUES (v_polygonId, p_areaId, 1);
  
    v_arrXYMinMax := ADD_AREA_POLYGON_POINTS( v_polygonId, arr_x, arr_y ); 
    
    UPDATE_XY_MIN_MAX( p_areaId, v_arrXYMinMAx(1), v_arrXYMinMAx(2), v_arrXYMinMAx(3), v_arrXYMinMAx(4) );
          
END;

PROCEDURE UPDATE_AREA_POLYGON(
    p_areaId    amareas.areaId%TYPE,
    arr_x       FLOAT_ARRAY,
    arr_y       FLOAT_ARRAY
)
IS
    v_polygonId     ampolygons.polygonId%TYPE;
    v_arrXYMinMax   FLOAT_ARRAY;
BEGIN
    
    BEGIN
      SELECT polygonId
      INTO v_polygonId
      FROM ampolygons
      WHERE areaId = p_areaId;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_area;
    END;
    
    DELETE_AREA_POLYGON_POINTS(v_polygonId);
           
    v_arrXYMinMax := ADD_AREA_POLYGON_POINTS( v_polygonId, arr_x, arr_y ); 
    
    UPDATE_XY_MIN_MAX( p_areaId, v_arrXYMinMAx(1), v_arrXYMinMAx(2), v_arrXYMinMAx(3), v_arrXYMinMAx(4) );
          
END;

PROCEDURE UPDATE_AREA_DEFINITION(
  p_areaId        amareas.areaId%TYPE,
  p_areaTypeId    amareas.areaTypeId%TYPE,
  p_areaName      amareas.areaName%TYPE,
  p_areaShortName amareas.areaShortName%TYPE,
  p_superArea     amareas.superArea%TYPE
)
IS
BEGIN
  
    UPDATE amareas
    SET areaTypeId = p_areaTypeId, areaName = p_areaName, areaShortName = p_areaShortName, superArea = p_superArea
    WHERE areaId = p_areaId;
    
END;

FUNCTION CREATE_AREA(
    p_area_type_id          amareas.areaTypeId%TYPE,
    p_area_name             amareas.areaName%TYPE,
    p_area_short_name       amareas.areaShortName%TYPE,
    p_super_area            amareas.superArea%TYPE,
    arr_x                   FLOAT_ARRAY,
    arr_y                   FLOAT_ARRAY
) 
RETURN NUMBER
IS
    v_id NUMBER;
BEGIN
    v_id := GET_NEXT_ID( SEQUENCE_AMAREAS );
    CREATE_AREA_SEQ( 
        v_id, p_area_type_id, p_area_name, p_area_short_name, p_super_area, 
        arr_x, arr_y
    );
    RETURN v_id;
END;


PROCEDURE CREATE_AREA_SEQ(
    p_areaId                amareas.areaId%TYPE,
    p_areaTypeId            amareas.areaTypeId%TYPE,
    p_areaName              amareas.areaName%TYPE,
    p_areaShortName         amareas.areaShortName%TYPE,
    p_superArea             amareas.superArea%TYPE,
    arr_x                   FLOAT_ARRAY,
    arr_y                   FLOAT_ARRAY
)
IS
    v_polygonId NUMBER;
    v_xMin amareas.areaXMin%TYPE;
    v_yMin amareas.areaYMin%TYPE;
    v_xMax amareas.areaXMax%TYPE;
    v_yMax amareas.areaYMax%TYPE;
    v_polygonsCount NUMBER;

BEGIN
    v_polygonsCount := arr_x.COUNT;
    
    v_xMin := 0;
    v_yMin := 0;
    v_xMax := 0;
    v_yMax := 0;
    
    INSERT INTO amareas (
       areaId, areaTypeId, areaName, areaShortName, superArea,
       areaPolygonsFlag, areaNRows, areaNCols, areaRefCount, areaExtentsFlag,
       areaXMin, areaXMax, areaYMin, areaYMax, fsAreaCode ) 
    VALUES (
        p_areaId, p_areaTypeId, p_areaName, p_areaShortName, p_superArea,
        1, 1, 1, 0, 1, v_xMin, v_xMax, v_yMin, v_yMax, null );
    --TODO: VERIFICAR QUE EL ULTIMO PUNTO SEA IGUAL AL PRIMERO (AREAPOLYGONSFLAG = 1);
    
    IF v_polygonsCount > 0 THEN
    
      ADD_AREA_POLYGON( p_areaId, arr_x, arr_y );

    END IF;
   
END;

PROCEDURE DELETE_AREA(
    p_areaId         amareas.areaId%TYPE
)
IS
    v_asociatedBlocks   NUMBER;
    v_polygonId         NUMBER:=0;

BEGIN
    BEGIN
        SELECT areaRefCount
        INTO v_asociatedBlocks
        FROM amareas
        WHERE areaId = p_areaId;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_area;
    END;

    IF v_asociatedBlocks > 0 THEN
        model_exceptions.area_referencial_integrity;
    END IF;

    DELETE_AREA_POLYGON(p_areaId);
    
    DELETE FROM amareas
    WHERE areaId = p_areaId;

END;  
--------------------------------------------------------------------------------------------------------------
-- VEREDAS ----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------


FUNCTION CREATE_FACADE(
    p_street_id             smblockfacades.streetId%TYPE,
    p_block_id              smblockfacades.blockId%TYPE,
    p_block_ver_ini         smblockfacades.blockVerIni%TYPE,
    p_block_ver_end         smblockfacades.blockVerEnd%TYPE,
    p_block_facade_num_ini  smblockfacades.blockFacadeNumIni%TYPE,
    p_block_facade_num_end  smblockfacades.blockFacadeNumEnd%TYPE,
    p_block_invert_num      smblockfacades.blockInvertNum%TYPE,
    p_block_facade_parity   smblockfacades.blockFacadeParity%TYPE,
    p_block_facade_zip      smblockfacades.blockFacadeZip%TYPE,
    p_logId                 sprlog.logid%TYPE 
) 
RETURN NUMBER
IS
    v_id NUMBER;
BEGIN
    v_id := GET_NEXT_ID( SEQUENCE_SPROBJECTS );
    CREATE_FACADE_SEQ( 
        v_id, p_street_id, p_block_id, p_block_ver_ini, p_block_ver_end, 
        p_block_facade_num_ini, p_block_facade_num_end, p_block_invert_num,
        p_block_facade_parity, p_block_facade_zip, p_logId
    );
    RETURN v_id;
END;


PROCEDURE CREATE_FACADE_SEQ(
    p_blockFacadeId        smblockfacades.blockFacadeId%TYPE,
    p_streetId             smblockfacades.streetId%TYPE,
    p_blockId              smblockfacades.blockId%TYPE,
    p_blockVerIni          smblockfacades.blockVerIni%TYPE,
    p_blockVerEnd          smblockfacades.blockVerEnd%TYPE,
    p_blockFacadeNumIni    smblockfacades.blockFacadeNumIni%TYPE,
    p_blockFacadeNumEnd    smblockfacades.blockFacadeNumEnd%TYPE,
    p_blockInvertNum       smblockfacades.blockInvertNum%TYPE,
    p_blockFacadeParity    smblockfacades.blockFacadeParity%TYPE,
    p_blockFacadeZip       smblockfacades.blockFacadeZip%TYPE,
    p_logId                sprlog.logid%TYPE       
)
IS
  v_maxBlockVtxForFacade  NUMBER;
  v_blockVtxs             NUMBER;
  v_streetId              NUMBER;
  v_newBlockId            NUMBER;
BEGIN
    v_newBlockId := GET_NEXT_ID( SEQUENCE_SPROBJECTS );

    SELECT count(bg.blockId)
    INTO v_blockVtxs
    FROM smblockGeo bg
    INNER JOIN smblocks b
    ON bg.blockId = b.blockId
    WHERE bg.blockId = p_blockId
    AND b.logIdTo = 0;
    
    IF v_blockVtxs = 0 THEN
      model_exceptions.invalid_block;
    END IF;
    
    IF ABS(p_blockVerEnd - p_blockVerIni) > 1 THEN
      model_exceptions.facade_vtxs_not_continuous;
    END IF;
    
    IF p_blockVerEnd > p_blockVerIni THEN
      v_maxBlockVtxForFacade := p_blockVerEnd;
    ELSIF p_blockVerEnd < p_blockVerIni THEN
      v_maxBlockVtxForFacade := p_blockVerIni;
    ELSE
      model_exceptions.facade_vtxs_equals;
    END IF;
    
    IF v_maxBlockVtxForFacade > v_blockVtxs THEN
      model_exceptions.invalid_block_vtx;
    END IF;
    
    BEGIN
      SELECT streetId
      INTO v_streetId
      FROM smstreets
      WHERE streetId = p_streetId
      AND streetAntiq = 0
      AND streetDeleted = 0;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
          model_exceptions.invalid_street;
    END;

    -- TODO: VALIDAR PARIDAD DE LOS NROS. (EMPIEZA CON PAR TERMINA CON PAR => PARITY = 0, 
    -- EMPIEZA CON IMPAR TERMINA CON IMPAR => PARITY = 1) VER CASO EN QUE LAS VEREDAS TIENEN 
    -- NROS PARES E IMPARES DEL MISMO LADO (PARITY = 2 ?). 
    
    CLONE_AND_DELETE_BLOCK( p_blockId, v_newBlockId, p_logId );
    
    INSERT INTO smblockfacades (
       blockFacadeId, streetId, blockId, blockVerIni, blockVerEnd,
       blockFacadeNumIni, blockFacadeNumEnd, blockInvertNum, blockFacadeParity, blockFacadeZip )
    VALUES (
        p_blockFacadeId, p_streetId, v_newBlockId, p_blockVerIni, p_blockVerEnd,
        p_blockFacadeNumIni, p_blockFacadeNumEnd, p_blockInvertNum, p_blockFacadeParity, p_blockFacadeZip );  
END;


PROCEDURE DELETE_FACADE(
    p_blockFacadeId     smblockfacades.blockFacadeId%TYPE,
    p_logId             sprlog.logid%TYPE
)
IS
    v_blockId           NUMBER;
    v_newBlockId        NUMBER;
    
BEGIN

    BEGIN
        SELECT blockId
        INTO v_blockId
        FROM smblockfacades
        WHERE blockFacadeId = p_blockFacadeId;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            model_exceptions.invalid_facade;
    END;

    v_newBlockId := GET_NEXT_ID( SEQUENCE_SPROBJECTS );


    CLONE_AND_DELETE_BLOCK( v_blockId, v_newBlockId, p_logId );

END;  

END MODEL_API;