Assumption: "Region: B - Certeral" (typo) = Central
Assumption: This is a multi tenant system with 2 clients
Assumption: Some additional data selection for assigning proper user security will be required to select the correct level of security

So after much back and forth, I opted to use the SQL Server HierarchyID data type to create the hierchical structure required for each tenant.

This allowed me to segregate each client in their own hierarchy structure.  Although they share a database and tables each client has it's own rows in it's own hierarchy.

It makes for pretty easy querying for both user security setup as well as being able to drill up and down through the hierarchy for each client.

This solution is also about the most light weight option I found of the various architectures I explored.  As a note it would be possible to split out the various items into their own tables and relate/join them back to the hierarchy table (I actually did this for "Type" because I didn't like seeing it repeated so many times.)  But for the sake of time and simplicity I chose for this practicum to put the majority of the data right in the hierarchy table.

The most challenging aspect to using this method going forward is deleting parent objects.  As it will require also updating any child objects under it to a new parent in the hierachy or be potentially orphaned.  But the benefits in my view far outway any difficulty in that regard (and really it's not THAT bad to do).  Using the HierarchyID data type opens up a wide range of very handy built in functions that also really help with this process.

Other considerations that I thought about:
Other possible design options;
Adjacency List
Nested Set
Flat Table
Bridge Table

I explored several of these initially but did not like how it was working out.

Seperate Databases?
	Best Data isolation
	Better backup and recovery options
	Easier to migrate
	Easy to be sure client is only connecting to its own data
	Easier to troubleshoot issues
	Easier to track performance

Seperate tables?/Seperate schemas?
	Some specific data isolation based on the clients requirements
	Can be hard to isolate which tenant is potentially causing performance issues
	Can be harder to track down issues

Some other possible options but complicated to implement:
	Partition based
	Shard based

Possible ways to improve performance for a single instance/database multi-tenant system:
	Always-On/Mirroring to offload reads for clients to different servers
	Federation keep all common data used by all tenants in a central location and only have customer centric data in seperate tenant node 

This was kind of a variation on using a bridge table:
Using an "Ownership Matrix Table" to track what data in which tables belongs to which clients
	With this I could dynamically generate SQL queries to build data sets customized to each client based on what fields in the matrix are filled out.
	We could break up our ownership matrix table (and each client data table) into one per client and assign a schema to each to help secure that data