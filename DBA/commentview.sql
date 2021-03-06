CREATE OR REPLACE VIEW KSS_VP_TIMESHTPUNCHV42_COM
(PERSONFULLNAME,
PERSONNUM,       
EVENTDATE,
STARTDTM,
ENDDTM,
ORIGINALDATE,
TIMEINSECONDS,
DURATIONINSECONDS,
MONEYAMOUNT,
PAYCODENAME,
TIMESHEETITEMTYPE,
PAIDSW,
CURRPAYPERIODSTART,
CURRPAYPERIODEND,
PREVPAYPERIODSTART,
PREVPAYPERIODEND,
NEXTPAYPERIODSTART,
NEXTPAYPERIODEND,
EMPLOYEEID,
TIMESHEETITEMID,
TMSHTITEMTYPEID,
COMMENTTEXT,
COMMENTTYPE,
COMMENTID
)
AS 
SELECT
TP.PERSONFULLNAME,
TP.PERSONNUM,       
TP.EVENTDATE,
TP.STARTDTM,
TP.ENDDTM,
TP.ORIGINALDATE,
TP.TIMEINSECONDS,
TP.DURATIONINSECONDS,
TP.MONEYAMOUNT,
TP.PAYCODENAME,
TP.TIMESHEETITEMTYPE,
TP.PAIDSW,
TP.CURRPAYPERIODSTART,
TP.CURRPAYPERIODEND,
TP.PREVPAYPERIODSTART,
TP.PREVPAYPERIODEND,
TP.NEXTPAYPERIODSTART,
TP.NEXTPAYPERIODEND,
TP.EMPLOYEEID,
TP.TIMESHEETITEMID,
TP.TMSHTITEMTYPEID,
NC.COMMENTTEXT,
'N' AS COMMENTTYPE,
NC.COMMENTID
FROM 
VP_TIMESHTPUNCHV42 TP,
TSCOMMENTMM TC,
COMMENTS NC
WHERE TP.TIMESHEETITEMID = TC.TIMESHEETITEMID
AND  NC.COMMENTID = TC.COMMENTID
UNION ALL
SELECT
TP.PERSONFULLNAME,
TP.PERSONNUM,       
TP.EVENTDATE,
TP.STARTDTM,
TP.ENDDTM,
TP.ORIGINALDATE,
TP.TIMEINSECONDS,
TP.DURATIONINSECONDS,
TP.MONEYAMOUNT,
TP.PAYCODENAME,
TP.TIMESHEETITEMTYPE,
TP.PAIDSW,
TP.CURRPAYPERIODSTART,
TP.CURRPAYPERIODEND,
TP.PREVPAYPERIODSTART,
TP.PREVPAYPERIODEND,
TP.NEXTPAYPERIODSTART,
TP.NEXTPAYPERIODEND,
TP.EMPLOYEEID,
TP.TIMESHEETITEMID,
TP.TMSHTITEMTYPEID,
IC.COMMENTTEXT,
'I' AS COMMENTTYPE,
IC.COMMENTID 
FROM 
VP_TIMESHTPUNCHV42 TP,
PUNCHCOMMENTMM IP,
COMMENTS IC
WHERE IP.PUNCHEVENTID = TP.INPUNCHEVENTID
AND IC.COMMENTID = IP.COMMENTID
UNION ALL
SELECT
TP.PERSONFULLNAME,
TP.PERSONNUM,       
TP.EVENTDATE,
TP.STARTDTM,
TP.ENDDTM,
TP.ORIGINALDATE,
TP.TIMEINSECONDS,
TP.DURATIONINSECONDS,
TP.MONEYAMOUNT,
TP.PAYCODENAME,
TP.TIMESHEETITEMTYPE,
TP.PAIDSW,
TP.CURRPAYPERIODSTART,
TP.CURRPAYPERIODEND,
TP.PREVPAYPERIODSTART,
TP.PREVPAYPERIODEND,
TP.NEXTPAYPERIODSTART,
TP.NEXTPAYPERIODEND,
TP.EMPLOYEEID,
TP.TIMESHEETITEMID,
TP.TMSHTITEMTYPEID,
OC.COMMENTTEXT,
'O' AS COMMENTTYPE,
OC.COMMENTID 
FROM
VP_TIMESHTPUNCHV42 TP,
PUNCHCOMMENTMM OP,
COMMENTS OC
WHERE OP.PUNCHEVENTID = TP.OUTPUNCHEVENTID
AND OC.COMMENTID = OP.COMMENTID
UNION ALL
SELECT 
PE.FULLNM AS PERSONFULLNAME, 
PE.PERSONNUM, 
TRUNC(SH.STARTDTM) AS EVENTDATE,
SH.STARTDTM,
SH.ENDDTM,
NULL AS ORIGINALDATE,
SH.PCESECSQTY AS TIMEINSECONDS, 
NULL AS DURATIONINSECONDS, 
PCEMONEYAMT AS MONEYAMOUNT,
PC.NAME PAYCODENAME, 
'Shift' AS TIMESHEETITEMTYPE,
1 AS PAIDSW,
MP.CPSTARTDATEDTM AS CURRPAYPERIODSTART, 
MP.CPENDDATEDTM AS CURRPAYPERIODEND, 
MP.PPSTARTDATEDTM AS PREVPAYPERIODSTART, 
MP.PPENDDATEDTM AS PREVPAYPERIODEND, 
MP.NPSTARTDATEDTM AS NEXTPAYPERIODSTART, 
MP.NPENDDATEDTM AS NEXTPAYPERIODEND, 
SA.EMPLOYEEID, 
SH.SHIFTID AS TIMESHEETITEMID,
0 AS TMSHTITEMTYPEID, 
CM.COMMENTTEXT,
'S' AS COMMENTTYPE,
CM.COMMENTID 
FROM
COMMENTS CM
JOIN  SHIFTCOMMENTMM  SC ON CM.COMMENTID=SC.COMMENTID
JOIN  SHIFT SH ON SC.SHIFTID=SH.SHIFTID 
JOIN  SHIFTASSIGNMNT SA ON SH.SHIFTID=SA.SHIFTID
JOIN WTKEMPLOYEE WE ON SA.EMPLOYEEID = WE.EMPLOYEEID
JOIN PERSON PE ON WE.PERSONID = PE.PERSONID
LEFT OUTER JOIN MYPAYPERIOD MP ON WE.PAYRULEID = MP.PAYRULEID
JOIN PAYCODE PC ON SH.PAYCODEID=PC.PAYCODEID
WHERE  SH.HASCOMMENTSW=1 
AND (SH.PCESECSQTY>0 OR SH.PCEMONEYAMT>0)
AND SH.DELETEDSW=0
/
GRANT SELECT, INSERT, DELETE, UPDATE ON KSS_VP_TIMESHTPUNCHV42_COM TO KRONOSUSER
/
GRANT SELECT ON KSS_VP_TIMESHTPUNCHV42_COM TO KRONOSUSER
/
DROP PUBLIC SYNONYM KSS_VP_TIMESHTPUNCHV42_COM
/
CREATE PUBLIC SYNONYM KSS_VP_TIMESHTPUNCHV42_COM FOR TKCSOWNER.KSS_VP_TIMESHTPUNCHV42_COM
/
COMMIT
/