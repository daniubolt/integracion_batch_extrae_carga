select o.objectNameId, l.objectId, l.linkId, l.seqOrder, TRIM(Replace(l.linkValue, Chr(9), ' ')), l.logIdFrom, l.logIdTo, l.dateFrom, l.dateto
from sprLinks l
inner join smBlocks o on l.objectId = o.blockId
where objectType=20 and (l.logIdFrom > $logIdSyncMin and l.logIdFrom <= $logIdSyncMax) or (l.logIdTo > $logIdSyncMin and l.logIdTo <= $logIdSyncMax)