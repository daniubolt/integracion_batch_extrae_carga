SELECT ID,NOMBRE,UDN,REGION,SUBREGION,PARTIDO,LOCALIDAD,CALLE,ALTURA,ES_RURAL,LATITUD,LONGITUD,TIPO_SITIO,NORMALIZADO,NODOS_ACTIVOS,TIPO_EDIFICACION,TIPO_CABEZAL_AN,TIPO_CABEZAL_DI,
CLASIFICACION_CABEZAL,CLASIFICACION_HUB,PROPIEDAD,RECIBE_MMDS,RECIBE_UHF,RECIBE_AML,RECIBE_FO_RF,SERVICIO_MMDS,SERVICIO_UHF,SERVICIO_AML,SERVICIO_FO_RF,
DEPENDENCIA_AN,DEPENDENCIA_DI,DEPENDENCIA_DT,DEPENDENCIA_DR,MANZANAS_DIRECTAS_330,MANZANAS_DIRECTAS_450,MANZANAS_DIRECTAS_550,MANZANAS_DIRECTAS_750,
MANZANAS_DIRECTAS_1W,MANZANAS_DIRECTAS_2W,MANZANAS_INDIRECTAS_330,MANZANAS_INDIRECTAS_450,MANZANAS_INDIRECTAS_550,MANZANAS_INDIRECTAS_750,MANZANAS_INDIRECTAS_1W,MANZANAS_INDIRECTAS_2W,
CLIENTES_DIRECTOS_CLI,CLIENTES_DIRECTOS_CATV,CLIENTES_DIRECTOS_CM,CLIENTES_INDIRECTOS_CLI,CLIENTES_INDIRECTOS_CATV,CLIENTES_INDIRECTOS_CM,CLIENTES_AIRE,
GERENCIAMIENTO_CNL,MAX_CH,CODIFICACION,BBI,SIMULCAST,ESPECTRO_ACTUALIZADO,TRAZA,PROPIETARIO,PASSTHROUGH,COMENTARIO,FECHA_ACTUALIZACION,OBJECTID,
TIPO_CODIFICACION,LOGIDFROM,LOGIDTO,DATEFROM,DATETO 
FROM GIS_DET_SITIOS_H
WHERE (logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin and logIdTo <= $logIdSyncMax)
order by logIdFrom, id