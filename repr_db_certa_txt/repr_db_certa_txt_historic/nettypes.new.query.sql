select netTypeId id, netTypeCaption name, nettypePrefix alias, nettypeparent parentId, logIdFrom, dateFrom, logIdTo, dateTo 
from netTypes_h
where (logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin AND logIdTo <= $logIdSyncMax) 
order by logIdFrom, netTypeId