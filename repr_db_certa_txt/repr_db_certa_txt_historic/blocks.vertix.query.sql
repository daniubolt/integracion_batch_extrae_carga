select o.blockid objectid, objectNameId, v.blockgeoorder orden, v.x, v.y
from smblocks o
inner join smblockgeo v on o.blockid = v.blockid
where (logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin and logIdTo <= $logIdSyncMax) 
order by logIdFrom, v.blockid, v.blockgeoorder