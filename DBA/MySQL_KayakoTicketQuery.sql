--Increment (or decliment) the year number in the select to count it down (or up) year by year and save off results.

     SELECT y, m, Count(dateline)
     FROM (
      SELECT y, m
      FROM
         (SELECT YEAR(CURDATE()) y UNION ALL SELECT YEAR(CURDATE())-8) years,
         (SELECT 1 m UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
           UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
           UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12) months) ym
       LEFT JOIN `support_prospectorplushelpdesk_com`.`swtickets`
       ON ym.y = YEAR(FROM_UNIXTIME(dateline))
          AND ym.m = MONTH(FROM_UNIXTIME(dateline))
     WHERE
       (y IN ('2010','2011','2012','2013','2014','2015','2016','2017') AND m<=MONTH(CURDATE()))
       OR
       (y IN ('2010','2011','2012','2013','2014','2015','2016','2017') AND m>MONTH(CURDATE()))
     GROUP BY y, m;