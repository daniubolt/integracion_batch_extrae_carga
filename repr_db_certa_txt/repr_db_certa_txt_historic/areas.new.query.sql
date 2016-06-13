select areaId,areaTypeId,areaName,areaShortName,superArea,fsAreaCode, logIdFrom, dateFrom, logIdTo, dateTo 
from amAreas_h
where (logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin AND logIdTo <= $logIdSyncMax) 
order by logIdFrom, areaId