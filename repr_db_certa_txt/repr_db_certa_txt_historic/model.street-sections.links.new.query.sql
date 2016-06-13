select s.objectNameId, l.objectId, l.linkId, l.seqOrder, TRIM(Replace(l.linkValue, Chr(9), ' ')), l.logIdFrom, l.logIdTo, l.dateFrom, l.dateto
from sprLinks l
inner join smStreetSection s on  l.objectId = s.streetSectionId
where objectType=21 and (l.logIdFrom > $logIdSyncMin and l.logIdFrom <= $logIdSyncMax) or (l.logIdTo > $logIdSyncMin and l.logIdTo <= $logIdSyncMax)     
