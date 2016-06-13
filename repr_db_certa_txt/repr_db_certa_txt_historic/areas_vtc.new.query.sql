select p.areaId,  p.polygonId, g.polygonverOrder, g.x, g.y, g.logIdFrom, g.logIdTo
from amPolygons_h p
inner join amPolygonGeo_h g on p.polygonId = g.polygonId 
where (g.logIdFrom > $logIdSyncMin and g.logIdFrom <= $logIdSyncMax) or (g.logIdTo > $logIdSyncMin and g.logIdTo <= $logIdSyncMax) 
order by g.logIdFrom, p.areaId, p.polygonId, g.polygonVerOrder 