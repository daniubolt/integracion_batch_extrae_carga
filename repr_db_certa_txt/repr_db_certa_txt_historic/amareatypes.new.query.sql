select areaTypeId id, areaTypeName name, superAreaType parentId, fsAreaTypeCode extCode, logIdFrom, dateFrom, logIdTo, dateTo  
from amAreaTypes_h
where (logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin AND logIdTo <= $logIdSyncMax) 
order by logIdFrom, areaTypeId