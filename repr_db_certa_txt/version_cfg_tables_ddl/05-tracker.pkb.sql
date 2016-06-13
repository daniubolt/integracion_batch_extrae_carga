create or replace PACKAGE BODY         TRACKER AS

FUNCTION NUEVA_REVISION( 
    p_nom_entidad VARCHAR2,
    p_id_entidad NUMBER,
    p_fecha OUT DATE 
) RETURN NUMBER
AS
    v_id NUMBER;
BEGIN
    p_fecha := SYSDATE;
    -- Genero nueva revision      
    v_id := MODEL_API.GET_NEXT_ID('sprLog');  
    
    INSERT INTO controlc (logId,entidad,fecha,estado,id_entidad) 
        VALUES(v_id,p_nom_entidad,p_fecha,1,p_id_entidad); 
        
    MODEL_API.CREATE_REVISION_SEQ( v_id, p_fecha, 1, p_nom_entidad, 33, 1 );    
    RETURN v_id;
END;    

FUNCTION ABRE_REVISION(
    p_nom_entidad VARCHAR2,
    p_id_entidad NUMBER,
    p_fecha OUT DATE,
    p_es_nuevo OUT BOOLEAN   
) RETURN NUMBER
AS
    v_count NUMBER;
    v_id NUMBER;
BEGIN
    -- Se fija si ya tiene una revision abierta
    SELECT COUNT(*) 
    INTO v_count
    FROM controlc 
    WHERE entidad=p_nom_entidad AND estado=1 AND id_entidad=p_id_entidad;
    
    IF v_count = 0 THEN 
        -- En caso de que no, genera una nueva revision 
        v_id := NUEVA_REVISION( p_nom_entidad, p_id_entidad, p_fecha ); 
        p_es_nuevo := TRUE;
    ELSE
        SELECT logId, fecha
        INTO v_id, p_fecha
        FROM controlc 
        WHERE entidad=p_nom_entidad AND estado=1 AND id_entidad=p_id_entidad;      
        p_es_nuevo := FALSE;
    END IF;
    
    RETURN v_id;
END;

PROCEDURE CIERRA_REVISION(
    p_revision_id NUMBER
)
AS
BEGIN
    UPDATE controlc 
    SET estado=0,fecha_fin=SYSDATE 
    WHERE logId = p_revision_id; 
        
    UPDATE sprLog 
    SET eventStatus = 0
    WHERE logId = p_revision_id; 
        
END;
   
END TRACKER;