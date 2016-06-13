select linkid id_atr, linkcaption nombre, linktype id_tipo, linkvalidation id_tip_val, linkmin min_val, linkmax max_val, 
logIdFrom id_inc_desde, logIdTo id_inc_hasta,
to_char(dateFrom,'YYYY-MM-DD HH24:MI:SS')fec_inc_desde, to_char(dateTo,'YYYY-MM-DD HH24:MI:SS' )fec_inc_hasta
from links_h
where logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax 
order by logIdFrom, id_atr