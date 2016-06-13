SELECT sprid id_clase, caption nombre, alias, netTypeId fk_red, categId fk_categ, entityType fk_tipo_obj,logIdFrom id_inc_desde, logIdTo id_inc_hasta, 
to_char(dateFrom,'YYYY-MM-DD HH24:MI:SS')fec_inc_desde, to_char(dateTo,'YYYY-MM-DD HH24:MI:SS' )fec_inc_hasta
FROM sprEntities_h
WHERE logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax
order by logIdFrom, id_clase 