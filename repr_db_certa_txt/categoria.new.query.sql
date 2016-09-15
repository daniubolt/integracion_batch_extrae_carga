select categid id, categcaption name, nettypeid net_type_id, entitytype obj_type_id, logIdFrom, logIdTo, 
to_char(dateFrom,'YYYY-MM-DD HH24:MI:SS')fec_inc_desde, to_char(dateTo,'YYYY-MM-DD HH24:MI:SS' )fec_inc_hasta
from categories_h
where logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax
order by logIdFrom, categid