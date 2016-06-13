select f.blockFacadeId, f.streetId, b.objectNameId, f.blockId, f.blockVerIni, f.blockVerEnd, 
f.blockFacadeNumIni, f.blockFacadeNumEnd, f.blockInvertNum, f.blockFacadeParity, f.blockFacadeZip,
logidfrom, logidto, datefrom, dateto
from smblockfacades f
inner join smBlocks b on b.blockId = f.blockId
where (logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin and logIdTo <= $logIdSyncMax) 
order by logIdFrom, f.blockFacadeId    