select objectId, objectId, linkId, seqOrder, TRIM(Replace(linkValue, Chr(9), ' ')), logIdFrom, logIdTo, dateFrom, dateto
from sprLinks
where objectType=23 and ((logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin and logIdTo <= $logIdSyncMax)) 