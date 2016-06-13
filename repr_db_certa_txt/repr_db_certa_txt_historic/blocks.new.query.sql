select blockId objectId, objectNameId, sprid, blockFlags, areaId, blockName, logidfrom, logidto, datefrom, dateto
from smBlocks
where (logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin and logIdTo <= $logIdSyncMax) 
order by logIdFrom, blockId