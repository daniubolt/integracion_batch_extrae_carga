select o.objectnameid id_ele,l.OBJECTID id_extra,LINKID fk_atr,SEQORDER orden,LINKVALUE valor,l.LOGIDFROM id_inc_desde,l.LOGIDTO id_inc_hasta,
to_char(l.dateFrom,'YYYY-MM-DD HH24:MI:SS')fec_inc_desde, to_char(l.dateTo,'YYYY-MM-DD HH24:MI:SS' )fec_inc_hasta
from sprlinks l inner join sprobjects o on o.objectid = l.objectid
where  ((l.logIdFrom > $logIdSyncMin and l.logIdFrom <= $logIdSyncMax) or (l.logIdTo > $logIdSyncMin AND l.logIdTo <= $logIdSyncMax))
