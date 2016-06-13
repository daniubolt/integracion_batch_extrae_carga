select linkid id, linkcaption nombre, linktype tipo, linkvalidation validacion, linkmin minval, linkmax maxval, 
	logIdFrom, logIdTo, dateFrom, dateTo
from links_h
where (logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin AND logIdTo <= $logIdSyncMax) 
order by logIdFrom, linkId