select categid id, nettypeid net_type_id, categcaption name, entitytype obj_type_id, logIdFrom, dateFrom, logIdTo, dateTo 
from categories_h
where (logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin AND logIdTo <= $logIdSyncMax) 
order by logIdFrom, categid