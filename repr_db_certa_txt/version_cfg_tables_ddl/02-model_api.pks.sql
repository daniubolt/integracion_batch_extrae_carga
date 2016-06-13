create or replace PACKAGE         MODEL_API AS
/******************************************************************************
   NAME:       MODEL_API
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/09/2015      drodriguez       1. Created this package.
******************************************************************************/

----------------------------------------------------------------------------------------------------
-- OBJECTTYPES -------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
TYPE_SYMBOL              CONSTANT sprobjects.objecttype%TYPE := 12;
TYPE_CONNECTOR           CONSTANT sprobjects.objecttype%TYPE := 11;
TYPE_STREET              CONSTANT sprobjects.objecttype%TYPE := 21;
TYPE_BLOCK               CONSTANT sprobjects.objecttype%TYPE := 20;
TYPE_SYMBOL_OR_CONNECTOR CONSTANT sprobjects.objecttype%TYPE := 23;
----------------------------------------------------------------------------------------------------
-- SEQUENCES ---------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
SEQUENCE_SPRLOG        CONSTANT sprtables.tablename%TYPE := 'sprLog';
SEQUENCE_SPROBJECTS    CONSTANT sprtables.tablename%TYPE := 'sprObjects';
SEQUENCE_SMSTREETS     CONSTANT sprtables.tablename%TYPE := 'smStreets';
SEQUENCE_SPRTOPOLOGY   CONSTANT sprtables.tablename%TYPE := 'sprTopology';
SEQUENCE_AMAREAS       CONSTANT sprtables.tablename%TYPE := 'AMAREAS';
SEQUENCE_AMPOLYGONS    CONSTANT sprtables.tablename%TYPE := 'AMPOLYGONS';

----------------------------------------------------------------------------------------------------
-- REVISIONES --------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
REVISION_STATUS_OK      CONSTANT sprlog.eventstatus%TYPE := 0; 
REVISION_STATUS_PENDING CONSTANT sprlog.eventstatus%TYPE := 1; 
REVISION_STATUS_DISCARD CONSTANT sprlog.eventstatus%TYPE := 2; 
REVISION_TYPE_MODEL     CONSTANT sprlog.eventtype%TYPE   := 32;

/*
|- Descripcion: procedimiento que otorga secuencias (1 a n) de la tabla SprTables
|- Retorno: proximo ID Disponible
|- Commit: SI (autónomo)
|- Validaciones:
|- 1) Si el nombre de la secuencia es correcto.
|- 2) Si el rango solicitado es valido
*/
FUNCTION GET_NEXT_ID( 
    p_sequence_name    sprtables.tablename%TYPE,
    p_range            NUMBER DEFAULT 1)
RETURN sprtables.nextid%TYPE;

/*
|-----------------------------------------------------------------------------------
|- Descripcion: obtiene el modulo para un objeto dado.
|- Retorno: MODULO o excepcion.
|- Commit: NO
|- Validaciones:
|- 1) Si los parametros de proyecto estan configurados
*/
FUNCTION GET_MODULE( p_x IN FLOAT, p_y IN FLOAT )
RETURN sprobjects.module%TYPE;

--------------------------------------------------------------------------------------------------------------
-- TRANSACTION -----------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

/*
|-----------------------------------------------------------------------------------
|- Descripcion: verifica si la red esta bloqueada a la fecha (inclusive).
|- Retorno: BOOLEAN FALSE o TRUE.
|- Commit: NO
*/
FUNCTION IS_LOCKED( p_date sprlog.eventdate%TYPE )
RETURN BOOLEAN;


/*
|-----------------------------------------------------------------------------------
|- Descripcion: crea una revision de modelo. (eventstatus=1).
|- Retorno: solo excepciones
|- Commit: SI
|- Validaciones:
|- 1) Si el usuario es valido
|- 3) Si la red no esta bloqueada por CINT
*/
PROCEDURE CREATE_REVISION_SEQ(
    p_logId       IN sprlog.logid%TYPE,
    p_eventDate   IN sprlog.eventdate%TYPE,
    p_userId      IN sprlog.userid%TYPE,
    p_eventData   IN sprlog.eventdata%TYPE,
    p_eventType   IN sprlog.eventtype%TYPE := REVISION_TYPE_MODEL,
    p_eventStatus IN sprlog.eventStatus%TYPE := REVISION_STATUS_PENDING 
);

/*
|-----------------------------------------------------------------------------------
|- Descripcion: crea una revision de modelo. (eventstatus=1).
|- Retorno: Número de revision
|- Commit: SI
|- Validaciones:
|- 1) Si el usuario es valido
|- 3) Si la red no esta bloqueada por CINT
*/
FUNCTION CREATE_REVISION(
    p_userid      IN sprlog.userid%TYPE,
    p_eventdata   IN sprlog.eventdata%TYPE,
    p_eventdate   IN sprlog.eventdate%TYPE := SYSDATE,
    p_eventtype   IN sprlog.eventtype%TYPE := REVISION_TYPE_MODEL )
RETURN NUMBER;    

/*
|-----------------------------------------------------------------------------------
|- Descripcion: cierra la revision de modelo. (eventstatus=0)
|- Retorno: -
|- Commit: SI
|- Validaciones:
|- 1) Si la transaccion esta abierta
|- 2) Si la red no esta bloqueada
*/
PROCEDURE COMMIT_REVISION( p_logid sprlog.logid%TYPE );

/*
|-----------------------------------------------------------------------------------
|- Descripcion: Cancela la revision de modelo. (eventstatus=2)
|- Retorno: -
|- Commit: SI
|- Validaciones:
|- 1) Si la transaccion esta abierta
|- 2) Si la red no esta bloqueada
*/
PROCEDURE CANCEL_REVISION( p_logid sprlog.logid%TYPE );

PROCEDURE CREATE_SYMBOL_SEQ(
  p_objectId sprobjects.objectId%TYPE,
  p_logId    sprlog.logid%TYPE,
  p_sprid    sprobjects.sprid%TYPE,
  p_x        sprobjects.x%TYPE,
  p_y        sprobjects.y%TYPE,
  p_angle    sprobjects.angle%TYPE,
  p_scale    sprobjects.scale%TYPE,
  p_color    sprobjects.sprcolor%TYPE
);

FUNCTION CREATE_SYMBOL(
  p_logId    sprlog.logid%TYPE,
  p_sprid    sprobjects.sprid%TYPE,
  p_x        sprobjects.x%TYPE,
  p_y        sprobjects.y%TYPE,
  p_angle    sprobjects.angle%TYPE,
  p_scale    sprobjects.scale%TYPE,
  p_color    sprobjects.sprcolor%TYPE
)
RETURN NUMBER;


--------------------------------------------------------------------------------------------------------------
--|- LINKS ---------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------


/*
|-----------------------------------------------------------------------------------
|- Descripcion: agrega un link a un objeto (simbolo, conector, manzana, calle).
|- Retorno: secuencia del link creado
|- Commit: NO
|- Validaciones:
|- 1) Si la transaccion esta abierta (eventstatus=1)
|- 2) Si el objeto no esta bloqueado
|- 3) Si el tipo de objeto es valido
|- 4) Si el link esta permitido para el objeto
*/
FUNCTION ADD_LINK(
    p_objectid      sprlinks.objectid%TYPE,
    p_linkid        sprlinks.linkid%TYPE,
    p_linkvalue     sprlinks.linkvalue%TYPE,
    p_logid         sprlog.logid%TYPE,
    p_objecttype    sprobjects.objecttype%TYPE)
RETURN NUMBER;

/*
|-----------------------------------------------------------------------------------
|- Descripcion: elimina un link a un objeto (simbolo, conector, manzana, calle).
|- Retorno: solo excepciones
|- Commit: NO
|- Validaciones:
|- 1) Si la transaccion esta abierta (eventstatus=1)
|- 2) Si el objeto no esta bloqueado
*/
PROCEDURE DELETE_LINK(
    p_objectid    sprlinks.objectid%TYPE,
    p_seqorder    sprlinks.seqorder%TYPE,
    p_logid       sprlog.logid%TYPE);
    
    
PROCEDURE DELETE_ALL_LINKS(
    p_objectid    sprlinks.objectid%TYPE,
    p_objecttype  sprlinks.objecttype%TYPE,
    p_logid       sprlog.logid%TYPE);    
    
/*
|-----------------------------------------------------------------------------------
|- Descripcion: elimina un objeto con sus links y topologias asociadas.
|- Retorno: solo excepciones
|- Commit: NO
|- Validaciones:
|- 1) Si la transaccion esta abierta (eventstatus=1)
|- 2) Si el objeto no esta bloqueado.
|- 3) Si la baja esta dentro de la vida del objeto.
*/    
PROCEDURE DELETE_SYMBOL(
    p_objectid    sprobjects.objectid%TYPE,
    p_logid       sprlog.logid%TYPE);
        
    
PROCEDURE CREATE_CONNECTOR_SEQ(
  p_objectId sprobjects.objectId%TYPE,
  p_sprid   sprobjects.sprid%TYPE,
  arr_x  FLOAT_ARRAY,
  arr_y  FLOAT_ARRAY,
  p_logid   sprlog.logid%TYPE,
  p_color sprobjects.sprcolor%TYPE
);


FUNCTION CREATE_CONNECTOR (
  p_sprid   sprobjects.sprid%TYPE,
  arr_x  FLOAT_ARRAY,
  arr_y  FLOAT_ARRAY,
  p_logid   sprlog.logid%TYPE,
  p_color sprobjects.sprcolor%TYPE
)
RETURN NUMBER;    
    
/*
|-----------------------------------------------------------------------------------
|- Descripcion: elimina un conector con sus links y topologias asociadas.
|- Retorno: solo excepciones
|- Commit: NO
|- Validaciones:
|- 1) Si la transaccion esta abierta (eventstatus=1)
|- 2) Si el conector no esta bloqueado.
|- 3) Si la baja esta dentro de la vida del objeto.
*/
PROCEDURE DELETE_CONNECTOR(
    p_objectid    sprobjects.objectid%TYPE,
    p_logid       sprlog.logid%TYPE);


--------------------------------------------------------------------------------------------------------------
-- BLOCKS ----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

PROCEDURE CREATE_BLOCK_SEQ(
  p_objectId sprobjects.objectId%TYPE,
  p_sprid   sprobjects.sprid%TYPE,
  arr_x  FLOAT_ARRAY,
  arr_y  FLOAT_ARRAY,
  p_logid   sprlog.logid%TYPE
);

FUNCTION CREATE_BLOCK(
    p_sprid     sprobjects.sprid%TYPE,
    arr_x       FLOAT_ARRAY,
    arr_y       FLOAT_ARRAY,
    p_logid     sprlog.logid%TYPE
) 
RETURN NUMBER;

/*
|-----------------------------------------------------------------------------------
|- Descripcion: elimina una manzana con sus links
|- Retorno: solo excepciones
|- Commit: NO
|- Validaciones:
|- 1) Si la transaccion esta abierta (eventstatus=1)
|- 2) Si el objeto no esta bloqueado.
|- 3) Si la baja esta dentro de la vida del objeto.
*/
PROCEDURE DELETE_BLOCK(
    p_blockid     smblocks.blockid%TYPE,
    p_logid       sprlog.logid%TYPE);
    
   
--------------------------------------------------------------------------------------------------------------
-- CALLES ----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
PROCEDURE CREATE_STREET_SEQ(
    p_streetId          smStreets.streetId%TYPE,
    p_street_type_id    smStreets.streetTypeId%TYPE,
    p_street_name       smStreets.streetName%TYPE,
    p_region_id         smStreets.regionId%TYPE, 
    p_logId             sprLog.logId%TYPE,
    p_streetShortName   smStreets.streetShortName%TYPE,
    p_fsStreetCode      smStreets.fsStreetCode%TYPE := NULL  
);

FUNCTION CREATE_STREET(
    p_street_type_id    smStreets.streetTypeId%TYPE,
    p_street_name       smStreets.streetName%TYPE,
    p_region_id         smStreets.regionId%TYPE, 
    p_logId             sprLog.logId%TYPE,
    p_streetShortName   smStreets.streetShortName%TYPE,
    p_fsStreetCode      smStreets.fsStreetCode%TYPE := NULL  
)
RETURN NUMBER;

PROCEDURE DELETE_STREET(
    p_streetId          smStreets.streetId%TYPE,
    p_logid             sprlog.logid%TYPE );

 
PROCEDURE UPDATE_STREET_SEQ(
    p_fromStreetId      smStreets.streetId%TYPE,
    p_toStreetId        smStreets.streetId%TYPE,
    p_name              smStreets.streetName%TYPE,
    p_regionId          smStreets.regionId%TYPE, 
    p_logId             sprLog.logId%TYPE,
    p_streetShortName   smStreets.streetShortName%TYPE,
    p_fsStreetCode      smStreets.fsStreetCode%TYPE := NULL  
);

PROCEDURE CREATE_STREET_SECTION_SEQ(
    p_objectId  smStreetSection.streetSectionId%TYPE,
    p_streetId  smstreetsection.streetId%TYPE,
    arr_x       FLOAT_ARRAY,
    arr_y       FLOAT_ARRAY,
    p_logid     sprlog.logid%TYPE );

FUNCTION CREATE_STREET_SECTION(
    p_street_id   smstreetsection.streetId%TYPE,
    arr_x         FLOAT_ARRAY,
    arr_y         FLOAT_ARRAY,
    p_logid       sprlog.logid%TYPE
) 
RETURN NUMBER;

PROCEDURE DELETE_STREET_SECTION(
    p_objectId    smstreetsection.streetSectionId%TYPE,
    p_logid       sprlog.logid%TYPE);    
    
    
--------------------------------------------------------------------------------------------------------------
-- AREAS -- ---------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
PROCEDURE DELETE_AREA_POLYGON(
    p_areaId   amareas.areaId%TYPE
);

PROCEDURE ADD_AREA_POLYGON( 
    p_areaId  amareas.areaId%TYPE, 
    arr_x     FLOAT_ARRAY,
    arr_y     FLOAT_ARRAY
);

PROCEDURE UPDATE_AREA_POLYGON(
    p_areaId    amareas.areaId%TYPE,
    arr_x       FLOAT_ARRAY,
    arr_y       FLOAT_ARRAY
);

PROCEDURE UPDATE_AREA_DEFINITION(
  p_areaId        amareas.areaId%TYPE,
  p_areaTypeId    amareas.areaTypeId%TYPE,
  p_areaName      amareas.areaName%TYPE,
  p_areaShortName amareas.areaShortName%TYPE,
  p_superArea     amareas.superArea%TYPE
);

PROCEDURE CREATE_AREA_SEQ(
    p_areaId                amareas.areaId%TYPE,
    p_areaTypeId            amareas.areaTypeId%TYPE,
    p_areaName              amareas.areaName%TYPE,
    p_areaShortName         amareas.areaShortName%TYPE,
    p_superArea             amareas.superArea%TYPE,
    arr_x                   FLOAT_ARRAY,
    arr_y                   FLOAT_ARRAY
);

FUNCTION CREATE_AREA(
    p_area_type_id          amareas.areaTypeId%TYPE,
    p_area_name             amareas.areaName%TYPE,
    p_area_short_name       amareas.areaShortName%TYPE,
    p_super_area            amareas.superArea%TYPE,
    arr_x                   FLOAT_ARRAY,
    arr_y                   FLOAT_ARRAY
)
RETURN NUMBER;

PROCEDURE DELETE_AREA(
    p_areaId         amareas.areaId%TYPE
);


--------------------------------------------------------------------------------------------------------------
-- VEREDAS ---------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

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
);

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
RETURN NUMBER;

PROCEDURE DELETE_FACADE(
	p_blockFacadeId     smblockfacades.blockFacadeId%TYPE,
    p_logId             sprlog.logid%TYPE
);



END MODEL_API;