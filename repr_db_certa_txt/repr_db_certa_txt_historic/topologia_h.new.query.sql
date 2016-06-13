SELECT 0 id_vista, o1.objectnameid  id_ele_desde,o2.objectnameid id_ele_hasta,nodeindexfrom nodo_desde,nodeindexto nodo_hasta,topologytype tipo_topologia,
top.logidfrom id_inc_desde,top.logidto id_inc_hasta,
to_char(top.dateFrom,'YYYY-MM-DD HH24:MI:SS') fec_inc_desde, to_char(top.dateTo,'YYYY-MM-DD HH24:MI:SS' ) fec_inc_hasta
FROM sprtopology top inner join sprobjects o1 on top.objectidfrom = o1.objectid
                                inner join sprobjects o2 on top.objectidto = o2.objectid
WHERE (top.logIdFrom > $logIdSyncMin and top.logIdFrom <= $logIdSyncMax) or (top.logIdTo > $logIdSyncMin AND top.logIdTo <= $logIdSyncMax)
ORDER BY objectidfrom,objectidto