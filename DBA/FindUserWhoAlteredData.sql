--Find Transaction ID
SELECT [Transaction ID],Operation, Context,AllocUnitName FROM fn_dblog(NULL, NULL)
WHERE Operation = 'LOP_INSERT_ROWS'

--Plugin transaction ID
SELECT Operation,[Transaction ID], [Begin Time], [Transaction Name], [Transaction SID]
FROM fn_dblog(NULL, NULL) WHERE [Transaction ID] = '0000:00000752'
AND [Operation] = 'LOP_BEGIN_XACT'

--Get user using transaction ID
Select SUSER_SNAME(0x01050000000000051500000060A4EEB0789A03300FF709CFE8030000)




Sr. No.	OPERATION	DESCRIPTION
1	LOP_ABORT_XACT 	Indicates that a transaction was aborted and rolled back.
2	LOP_BEGIN_CKPT 	A checkpoint has begun.
3	LOP_BEGIN_XACT 	Indicates the start of a transaction.
4	LOP_BUF_WRITE	Writing to Buffer.
5	LOP_COMMIT_XACT	Indicates that a transaction has committed.
6	LOP_COUNT_DELTA	 
7	LOP_CREATE_ALLOCCHAIN	New Allocation chain
8	LOP_CREATE_INDEX	Creating an index.
9	LOP_DELETE_ROWS	Rows were deleted from a table.
10	LOP_DELETE_SPLIT 	A page split has occurred. Rows have moved physically.
11	LOP_DELTA_SYSIND  	SYSINDEXES table has been modified.
12	LOP_DROP_INDEX	Dropping an index.
13	LOP_END_CKPT	Checkpoint has finished.
14	LOP_EXPUNGE_ROWS	Row physically expunged from a page, now free for new rows.
15	LOP_FILE_HDR_MODIF  	SQL Server has grown a database file.
16	LOP_FORGET_XACT	Shows that a 2-phase commit transaction was rolled back.
17	LOP_FORMAT_PAGE  	Write a header of a newly allocated database page.
18	LOP_HOBT_DDL	 
19	LOP_HOBT_DELTA	 
20	LOP_IDENT_NEWVAL	Identity’s New reseed values
21	LOP_INSERT_ROWS  	Insert a row into a user or system table.
22	LOP_LOCK_XACT	 
23	LOP_MARK_DDL	Data Definition Language change – table schema was modified.
24	LOP_MARK_SAVEPOINT	Designate that an application has issued a ‘SAVE TRANSACTION’ command.
25	LOP_MIGRATE_LOCKS	 
26	LOP_MODIFY_COLUMNS  	Designates that a row was modified as the result of an Update command.
27	LOP_MODIFY_HEADER  	A new data page created and has initialized the header of that page.
28	LOP_MODIFY_ROW  	Row modification as a result of an Update command.
29	LOP_PREP_XACT	Transaction is in a 2-phase commit protocol.
30	LOP_SET_BITS	 
31	LOP_SET_BITS	Designates that the DBMS modified space allocation bits as the result of allocating a new extent.
32	LOP_SET_FREE_SPACE  	Designates that a previously allocated extent has been returned to the free pool.
33	LOP_SORT_BEGIN 	A sort begins with index creation. – SORT_END end of the sorting while creating an index.
34	LOP_SORT_EXTENT	Sorting extents as part of building an index.
35	LOP_UNDO_DELETE_SPLIT	The page split process has been dumped.
36	LOP_XACT_CKPT	During the Checkpoint, open transactions were detected.