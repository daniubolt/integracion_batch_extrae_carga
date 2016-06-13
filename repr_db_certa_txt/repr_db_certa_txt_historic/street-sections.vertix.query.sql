select s.objectNameId, geo.streetSectionId, geo.streetGeoOrder, geo.x, geo.y 
from smstreetgeo geo
inner join smStreetSection s on s.streetSectionId = geo.streetSectionId
where (logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin and logIdTo <= $logIdSyncMax) 
order by logIdFrom, geo.streetSectionId, geo.streetGeoOrder