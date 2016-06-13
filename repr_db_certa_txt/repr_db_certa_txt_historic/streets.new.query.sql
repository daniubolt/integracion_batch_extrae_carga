select streetId, streetTypeId, streetName, regionId, streetShortName, fsStreetCode, userid, logIdFrom, dateFrom, logIdTo, dateTo 
from smStreets_h
where (logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin and logIdTo <= $logIdSyncMax)  
order by logIdFrom, streetId, dateFrom