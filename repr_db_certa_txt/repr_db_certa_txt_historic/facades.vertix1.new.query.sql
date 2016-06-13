select f.blockFacadeId, f.blockId, b.objectNameId, g1.blockgeoorder, f.blockVerIni, f.blockVerEnd, g1.x, g1.y
from smblockfacades f
inner join smBlocks b on b.blockId = f.blockId
inner join smBlockGeo g1 on b.blockId = g1.blockId and (g1.blockgeoorder >=  blockverini and g1.blockgeoorder <= blockverend )
where (logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin and logIdTo <= $logIdSyncMax) 
order by logIdFrom, f.blockFacadeId, g1.blockgeoorder