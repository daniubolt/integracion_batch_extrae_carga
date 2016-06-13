create or replace PACKAGE         TRACKER AS 

FUNCTION NUEVA_REVISION( 
    p_nom_entidad VARCHAR2,
    p_id_entidad NUMBER,
    p_fecha OUT DATE 
) RETURN NUMBER;

FUNCTION ABRE_REVISION(
    p_nom_entidad VARCHAR2,
    p_id_entidad NUMBER,
    p_fecha OUT DATE,
    p_es_nuevo OUT BOOLEAN   
) RETURN NUMBER;

PROCEDURE CIERRA_REVISION(
    p_revision_id NUMBER
);

END TRACKER;