select sprId id, netTypeId idRed, categid idcateg, caption nombre, alias, entitytype, logIdFrom, dateFrom, logIdTo, dateTo 
from sprEntities_h
where (logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin AND logIdTo <= $logIdSyncMax) 
order by logIdFrom, sprId