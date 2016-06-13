SELECT logId, logDate, userId, eventDate, eventData
FROM sprLog  
WHERE eventStatus = 0 AND eventType in (32,33) AND logId > $logIdSyncMin AND logId <= $logIdSyncMax
order by logId