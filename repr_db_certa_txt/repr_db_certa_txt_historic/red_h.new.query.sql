select netTypeId id_red, netTypeCaption nombre, nettypePrefix alias, nettypeparent fk_padre, logIdFrom id_inc_desde, logIdTo id_inc_hasta, 
to_char(dateFrom,'YYYY-MM-DD HH24:MI:SS')fec_inc_desde, to_char(dateTo,'YYYY-MM-DD HH24:MI:SS' )fec_inc_hasta
from netTypes_h
where logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax
order by logIdFrom, id_red