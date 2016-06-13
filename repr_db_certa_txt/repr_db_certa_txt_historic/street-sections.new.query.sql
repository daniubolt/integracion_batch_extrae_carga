select s.streetSectionId objectId, s.objectNameId, s.logidfrom, s.logidto, s.datefrom, s.dateto, s.streetId
from smStreetSection s
where (logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin and logIdTo <= $logIdSyncMax) 
order by logIdFrom, streetSectionId