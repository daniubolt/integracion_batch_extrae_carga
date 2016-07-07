select streetTypeId id, streetTypeName name, numberTypeId, 0, 0, magConvId, logIdFrom, dateFrom, logIdTo, dateTo 
from smStreetTypes_h
where (logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin AND logIdTo <= $logIdSyncMax) 
order by logIdFrom, streetTypeId