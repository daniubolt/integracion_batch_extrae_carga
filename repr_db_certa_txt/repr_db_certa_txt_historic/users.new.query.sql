select userId, userName, userPassword, userFullName, logIdFrom, dateFrom, logIdTo, dateTo  
from users_h
where (logIdFrom > $logIdSyncMin and logIdFrom <= $logIdSyncMax) or (logIdTo > $logIdSyncMin AND logIdTo <= $logIdSyncMax) 
order by logIdFrom, userId