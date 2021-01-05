WITH ordered AS
(
  SELECT *, ROW_NUMBER() OVER (ORDER BY [Ticket_ID], [EnteredDate]) rn
    FROM [ServiceManager].[dbo].[NOC_TicketsWiComments_Vw]
)
SELECT o1.[Ticket_ID] id1, o1.[EnteredDate] date1, o2.[Ticket_ID] id2, o2.[EnteredDate] date2, DATEDIFF(d, o1.[EnteredDate], o2.[EnteredDate]) diff
  FROM ordered o1 JOIN ordered o2
    ON o1.rn + 1 = o2.rn 
 WHERE o1.[Ticket_ID]=o2.[Ticket_ID] AND DATEDIFF(d, o1.[EnteredDate], o2.[EnteredDate]) > 2