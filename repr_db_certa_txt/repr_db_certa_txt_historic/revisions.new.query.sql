SELECT logId,to_char(logDate,'YYYY-MM-DD HH24:MI:SS'), userId, to_char(eventDate,'YYYY-MM-DD HH24:MI:SS'), eventData
FROM sprLog  
WHERE eventStatus = 0 AND eventType in (32,33)
order by logId