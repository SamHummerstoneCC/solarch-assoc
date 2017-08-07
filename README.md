# Solutions Architech Associate
##### Exam notes

###### Documentation:

1. [AWS S3 FAQ](https://aws.amazon.com/s3/faqs/)
2. [AWS EC2 FAQ](https://aws.amazon.com/ec2/faqs/)
3. [AWS SQS FAQ](https://aws.amazon.com/sqs/faqs/)
4. [AWS ELB Classic FAQ](https://aws.amazon.com/elasticloadbalancing/classicloadbalancer/faqs/)
5. [AWS VPC Security Groups](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_SecurityGroups.html)  
        
------

##### General notes on AWS

###### Regions and AZs:

1. A region is a distinct geographical area that comprises multiple Availability Zones
2. An availability zone is an isolated data centre or cluster of data centres that hosts AWS services within a region.
   A region contains at least two availability zones.
3. an Edge logation is an access point for AWS services - this is generally hosted in major urban areas, and is used
   mainly by systems such as CloudFront
   
   
###### IAM
   
1.  IAM is global, not bound to a region.
2.  IAM comprises users, groups, roles and policies.  
3.  Users can have api access (access keys) or username + password access ( console login ) - a user cannot log in
    to the console with an access key
    
###### IAM Roles
1.  Role types:
    1. AWS Service roles - permit AWS services to call other services on your behalf
    2. AWS Service linked roles - used for bots for things like Alexa / Polly
    3. Roles for cross account - permit one account to call another account, either yours or 3rd party
    4. Roles for Identity Provider access - permit OpenID, Single sign on etc access to AWS account
  
    
###### S3 - read FAQ before exam.
    
1.  S3 is a global namespace.  Bucket names must be unique across S3, not just across your account.
2.  URL Format:  https://s3-<region>.amazonaws.com/<bucketname>
3.  Consistency model:
    1.  Read after write consistency for PUT (new objects) 
    2.  Eventual consistency for Overwrite or delete (has non-zero propagation time)
4.  Sorts lexographically - data will stored in the same physical area on S3 and can cause performance bottlenecks.
    Consider salting file names with a random prefix for distribution
5.  Subresources
    1.  ACL - fine-grained permissions - at bucket level or at object level
    2.  Torrent - supports BitTorrent protocol
6.  SLA 99.9% but built for 99.99% - 11 9's durability guarantee
7.  S3 - IA (Infrequently accessed) - much cheaper
    S3 - RR (Reduced redundancy) - 99.99% availability over a year
    S3 vs Glacier - Glacier much cheaper but takes 3 - 5 hours to access data
8.  Charged for storage, request counts, storage management, data transfer, transfer acceleration
9.  For CRR, versioning must be on in the source and target buckets.  CRR will only replicate NEW objects.
    Old objects will be replicated if they are updated, and their entire history will be replicated as well.
    Object deletes are replicated but Object VERSION deletes are NOT replicated.
10. Can secure either via bucket policy or via ACLs
11. Transfer acceleration - use Cloudfront Edge location to speed upload to backing S3 bucket.
    
###### CloudFront

1.  Edge location - point at which content will be cached 'locally'
2.  Origin - original source of data [EC2, ALB, S3, Route53]
3.  Distribution - CDN consisting of 2 - N Edge locations
4.  can read from and write to Edge locations - writes are cached for the object's TTL.  You can expire early but you
    will be charged.
5.  two types - Web & RTMP     
6.  TTLs must be set to match periodicity of content
7.  Use signed cookies or urls to enforce access control onto resources.
8.  15-20 mins to provision a distribution.
9.  Possile to customise HTTP responses; restrict or permit (white XOR blacklist) by geographical location;  
10. Can create an *invalidation* to prevent caching of specific media objects on edge locations - billable.

###### Encryption
    
1.  In transit
    SSL/TLS
2.  At rest
    1. Server-side
        1. S3 managed keys - AES256 : SSE-S3
        2. SSE with KMS managed keys : SSE-KMS - permissioned envelope key + audit trail
        3. SSE with customer-provided keys - customer manages keys - SSE-C
    2. Client-side
        1. Encrypt client side, upload encrypted data to S3

###### Storage Gateway

1. acts as a async gateway between on-premise systems and AWS storage infrastructure (S3 and potentially Gateway)
2. downloadable as a virtual machine image - install and associate with AWS account
3. GW types:
   1. File Gateway (NFS) - store flat files in S3.  Permissions, ownership etc are stored as S3 metadata.  Once they are
   in S3 they can be managed as usual in S3 - versioning, ACL, bucket policies etc.
   2. Volumes Gateway (iSCSI) - store block 
      1. Stored volumes - store entire volume on premise.  Snapshots are written to AWS - use case for e.g backups.
      2. Cached volumes - store frequently accessed items locally, but S3 is the main data store for infrequent access.
      
      Volumes Gatway devices are virtual hard drives which can be saved as EBS snapshots (deltas) on AWS.
   3. Tape Gateway - VTL, create tape images then sync to AWS
      
###### Snowball
1. Legacy app was Import/Export - clients shipped physical drives to AWS for import but managing this became uneconomical
and impractical at large scale
2. 3 Types
   1. Snowball - beer-crate sized storage device.  Tamper-resistant, encrypted at rest, erased by Amazon once migration is complete
   2. Snowball Edge - similar sized appliance but has compute capabilities as well as just storage.  Essentially a small mobile
      AWS Data center that can cluster.  Support Lambda functions. 
   3. Snowmobile - peta/exabyte scale mobile AWS datacenter on truck.     
             
        
------

##### AWS Compute
        
###### EC2 - Elastic Compute Cloud
        
1.  Instance types : On Demand, Reserved (typically cheaper), Spot (at spot market rate), Dedicated Host (can be paid for by the hour)
2.  Spot instances - if the instance is terminated by AWS you do not pay for a partial hour of usage; if you terminate it you will be charged for any hour the instance ran

        | instance type  | Optimised for         |
        |  C             | Computation           |
        |  D             | Storage - Warehousing |
        |  F             | FPGA                  |
        |  G             | Graphics Intens       |
        |  I             | I/O  - RDBMS,NOSQL    |
        |  M             | General Purpose       |
        |  P             | Graphics / GPU        |
        |  R             | Memory (app/db)       |
        |  X             | Memory (Spark/bigdata)|
        
3. AMIs can be EBS backed or Instance Store (Ephemeral Storage) backed.
   1.  You cannot attach additional IS volumes once an instance is running.
   2.  You can only Reboot or Terminate an EC2 backed by IS.  Rebooting an instance backed by IS will not result
      in data loss, but if the underlying Hypervisor fails you effectively lose your data.
   3.  Instance Store used to be the only backing store; EBS is a newer feature.
   4.  Instance Store volumes do not display in the AWS Console.  Hence Ephemeral.
   5.  EC2 root EBS volumes are created from EBS snaphots.  EC2 root IS volumes are created from an S3 Template.
      IS root volumes can therefore take MORE time to provision than EBS volumes.
   6.  Root volumes are deleted on termination by default but you can instruct AWS not to delete EBS.  No option
      to do so for IS.
   7. instance metadata is available at http://169.254.169.254      
   
###### EC2 Placement Groups
   
1.  Permit a group of EC2 instances to be grouped logically within an AZ; share low latency 10Gbps network
2.  Cannot span AZs
3.  Must be uniquely named within the Account
4.  Limited to optimised instances (Compute / GPU / Storage / Memory optimised)
5.  AWS recommend homogenous instances within a placement group
6.  Cannot merge placement groups
7.  Cannot move running instances into a placement group; all instances must be launched into the placement group

###### EFS (Elastic File System)

1.  Supports NFS v4
2.  Pay for usage, not preprovisioned size.
3.  Scales to PB, supports thousands of concurrent NFS connections
4.  Data is stored across AZ's
5.  Block-based storage as opposed to object based (e.g S3)
6.  Read-after-write consistency.
7.  Good solution for sharing a usable filesystem between instances - e.g. code for websites / applications?
   
###### EBS (Elastic Block Storage)
        
1. Create logical block devices and attach them to EC2 instances.  Great for keeping filesystem deltas where if
   an instance dies you need to keep the data (e.g. jenkins CI)
2. EBS are in an AZ and are automatically replicated.
3. Types:   
   1.  SSD (GP2) - 3 IOPS (io/s) per gigabyte.  Up to 10k iops and burst of 3k iops/s for volumes < 1 Gb, bootable
   2.  Provisioned IOPS (IO1) - use for > 10k iops, bootable
   3.  Throughput-optimised HDD (ST1) (Magnetic) - Big Data / Warehousing / Log processing.  Sequential data, cannot be boot volumes
   4.  Cold HDD (SC1) -  fileservers.  low cost / infrequently accessed - cannot be boot volumes
   5.  Magnetic (Standard) - lowest cost / gig , bootable
4. EBS can only bind to one instance at a time.  For multiple instance sharing you have to use EFS
5. Never, ever create a Raid 5 device on EBS.  Amazon strongly de-incentivises this.
6. Snapshots of encrypted volumes are encrypted.  Likewise volumes restored from encrypted snapshots are encrypted.
7. You can only share unencrypted snapshots since the encryption keys are bound to your AWS accounts.  
8. You cannot delete an EBS snapshot if it is used as the root volume of a registered AMI.
   
###### Security Groups
   
1. Changes take place immediately
2. Security group ingress rules are automatically mirrored to egress - unlike VPC. 
3. All traffic is blocked by default; you can only PERMIT traffic.  You cannot DENY specific traffic.
4. 1 SG can apply to an infinity of EC2 instances
5. An instance can have 5 SGs bound to it

###### ALB And Health Checks

1. ALBs work at the application layer, support path based routing, and are recommended for HTTP traffic. Classic load
   balancers work at application or transport level but cannot do path-based routing.
2. ALBS route via Target Groups; Classic LBs route directly to EC2 instances.   
3. EC2 instances monitored by an ELB are reported as InService or OutOfService.
4. Health checks are conducted by connecting to the instances within an ALB or CLB.
5. ELBs are always addressed by DNS name; no IPv4 address is published for them.
6. It's advisable to have an ALB in two or more subnets across different AZ's to provide redundancy in case an AZ
goes offline.  This is especially true for public ALBs - you should have two different public subnets in different AZs

###### Cloudwatch

1. Free tier updates metrics every 5 minutes; Detailed monitoring has granularity of 1 minute but is not free.
2. Metrics are for any Cloudwatch-enabled service
3. Default metrics for an EC2 instance are always CPU,Disk,Network and Status related by default.
4. Cloudwatch Alarms - permit notification when metrics exceed preconfigured limits e.g. 80% cpu usage, min credit etc. 
5. Cloudwatch Events - permit async rule-based triggers in response to Cloudwatch events e.g calling a Lambda function.
6. Cloudwatch Logs - permit log analysis such as exception monitoring, httpd access logs etc.
 
###### Lambda

1. Serverless compute service that abstracts away all lower level systems and abstractions.
2. Can be triggered from events (e.g. Cloudwatch) or in response to HTTP requests (API Gateway)
3. Need CORS permission - Access-Control-Allow-Origin: * 
  
###### RDS
  
1. RDS: Two different types of backup strategies - automated backups and database snapshots
    1. Automated Backups
        1. Automated backups permit recovery to any day within the retention period (1-35 days, defaulting to 7 days)
        2. Automated backups store take a full daily snapshot + transaction logs for the day.
        3. When restoring, the most recent Automated Backup is chosen and restored, followed with TX logs for the day,
       permitting recovery up to the second.
        4. Automated backups are enabled by default, and are backed up to S3.  Free S3 storage equivalent to RDS instance size
        5. Backups are taken during a defined window; during which time I/O latency may increase and storage I/O may be suspended
        6. Automated Backups are deleted if you delete the source RDS instance
    2. DB Snapshots
        1. DB snapshots are manual
2. Restored Automated backups AND snapshots are always created as a NEW RDS INSTANCE with a new endpoint 
3. Encryption at reset is supported, but you cannot encrypt an existing database; you need to create a new encrypted
   instance and migrate your unencrypted data into the encrypted instance.  Once an RDS instance is encrypted, all
   automated backups, snapshots and read replicas are encrypted as well.
4. Multi-AZ - you can have an RDS as a syncronous replica of an existing RDS in a separate AZ; if your primary RDS 
   fails, but you are set up Multi AZ, AWS will automatically fail over to the backup RDS using the same domain name.
   This is a DR solution, not a SCALING solution.
5. Read replicas are async replicas of the primary DB which can be used to boost performance.  This is a SCALING solution
   not a DR Solution.
   1.  Require automatic backups to be enabled
   2.  Can have up to 5 read replicas on a RDS instance
   3.  Can have read replicas of read replicas but latency stacks up very quickly. 
   4.  Each read replica has its own DNS entry.  Read replicas cannot be chained in Multi-AZ.  You can create read
   replicas of a Multi-AZ source DB though.
   5.  Read replicas can be promoted to source databases, but this breaks replication.
6. RDS scaling requires manual intervention e.g stopping instance to resize it.   
   
###### DynamoDB
                           
1. Is a fast NoSQL DB service
2. Supports documents AND key/value pairs.  Good fit for Web / Mobile / Game / IoT
3. Stored on SSD, spread across 3 different facilities (not necessarily AZ's)  
4. Supports Eventually Consistent Reads (1s consistency), Strongly-consistent reads (returns all data which was successfully written prior to read)                           
5. Pricing by provisioned throughput capacity
    1. Write throughput, hourly fee per 10 units
    2. Read throughput, hourly fee per 50 units
    3. Storage costs
6.  Expensive for writes, cheap for reads.
7.  Push-button scaling; can scale reads + writes on the fly    
    
###### Red Shift
 
1. Modes
    1. Single Node
    2. Multi-node which comprised a Leader node (manages clients) and up to 128 compute nodes (manage calculations)
    3. Column-based - used for aggregate queries and statistics
2. Distributes queries and data across all available nodes
3. Pricing
    1. compute node usage - 1 unit per node per hour
    2. backup
    3. data transfer, within a vpc
4. Encryption in transit, encrypted at rest using AES-256, can manage keys through hardware or KMS
5. Single AZ
6. Can restore snapshots to a new AZ if there's an outage.
7. Can be used to reduce load on primary transactional dbs caused by management running OLAP reports etc.

###### Elasticache

1. Permits deployment, operation and scale in-memory caches in AWS
2. Engines
    1. Memcached
    2. Redis - supports Multi-AZ and Master/Slave replication
3. Elasticache is a good choice to help reduce latency between app and db by caching results of calcs if the database
    is read heavy
    
###### Aurora
    
1. Maintains 2 copies of DB per AZ, minimum of 3 AZs, minimum of 6 copies of data.
2. Designed to sustain loss of 2 copies without affecting write availability and 3 copies without affecting read
    availability
3. Storage is self-healing
4. Two types of replicas
   1. Aurora replicas (up to 15) - fail over automatically
   2. Mysql Read Replicas (up to 5) - will require intervention to fail over  
 
------
##### AWS Networking
###### Route 53

1. Route53 is a GLOBAL service
2. SOA record holds
    1. server that supplied zone data
    2. administrator contact details
3. A record translates a domain name to an ip address.  This means you cannot route to a ELB via Route53 as ELBs do not have
    ipv4 or ipv6 addresses, just an amazon DNS entry.  You need to use an A or AAAA ALIAS record to route to an ELB.
4. TTL - cache length of DNS entry on server or resolving client.  Defaults in most places to 2 days.
5. CNAME - can resolve one domain name to another.  CNAME cannot map to the zone apex e.g google.com.  CNAME could map
   www.google.com
6. ALIAS records are specific to AWS and are not a DNS standard.  ALIAS records can map to zone apexes, and map these
  most commonly to ELBs. ALIAS records update transparently when for e.g. a backing ELB changes internal dns name; this
  change is completely opaque to the outside world.
7. Routing policies for ALIAS records:
    1. Simple (default) - most commonly used for single resource (e.g. single webserver)
    2. Weighted
        1. permit routing of traffic by weight e.g 80% to one region and 20% to another region.  Could also be used for A/B
       testing for e.g.
        2. weighting is ON AVERAGE - on average over time x % will go to A and y % will go to B.  Max weight for route is 255, min 0.
    3. Latency
        1. Route based on lowest network atency for end user - create a latency resource record set in every region 
        that hosts your site.  R53 selects latency resource set with lowest latency.
    4. Failover
        1. Routing policy for active/passive failover
        2. R53 monitors health of primary site via a health check; if health check fails then R53 routes to the failover site.
        3. R53 Health check url cannot be the url of the ALIAS record; it must be the url of the ELB endpoint
    5. Geolocation
        1. permits traffic routing based on geographical location
        2. Geolocation can be done by Continent (e.g. Europe), by Country (e.g Germany) or by State in the case of the USA.
8. Route 53 is a fully fledged DNS system e.g it supports MX records        
    
###### VPC

1. VPC acts like a logical datacenter in a region - cannot span regions
2. Consist of Internet Gateway or VPG, Route Tables, ACLS, Subnets and SG's
3. VPC Creation
    1. Cannot create a CIDR block greater than /16 for a VPC
    2. When a VPC is created, a MAIN route table is created with it.
    3. When a VPC is created, a default security group is created for the VPC
    4. When a VPC is created, a default Network ACL is created for the VPC
4. Subnets are bound to a single AZ within a region. ACLs and Security Groups can span AZs.  Subnets are associated
   to the MAIN route table by default on creation.
5. 3 addresses are reserved by default in a subnet, not including .0 and .255 
   a.b.c.1 is reserved for the VPC router.  a.b.c.2 is reserved for DNS and a.b.c.3 is reserved for future use.
   .255 is broadcast, but broadcast isn't possible in VPC so this is simply reserved.
6. To connect a VPC to the internet you need to create an Internet Gateway.  Only one IG can be bound to a VPC.
7. VPC can peer to other VPCs in different accounts.  NO transitive VPC peering though. VPCs must peer directly with one another

###### NAT Instances and NAT Gateways

1. NAT-GReleased in 2016.  Old method was NAT instances.  NAT Gateways scale automatically, no need to patch or put in SG's - AWS manage everything.
2. NAT instances are provisioned from specific NAT Amis
3. EC2 instances have a default Source/Dest check which checks that traffic to them is either for or from them.  A NAT instance
needs to be able to route traffic so this setting needs to be disabled.
4. NAT Instances are configured as the targets of routing tables in much the same way as IG's are. 
5. NAT instances must be in a public subnet and must have an elastic IP allocated to them.
6. NAT instance traffic max throughput depends on instance size
7. NAT instances require scripts to do failover in HA
8. Private subnets must have a route to the NAT instance in order to see the public internet through them.
9. NAT Gateway is always deployed into subnets which are or can face PUBLIC internet - it is automatically given a public ip address
10 . NAT Gateway doesn't require a SG or disable of source/dest traffic check
                                     
###### Network Access Control Lists

1. Operates at the subnet level; unlike SGs ACLS support both allow and deny rules.   SGs can only PERMIT, everything is denied by default.
2. Unlike SGs, ACLs are stateless.  Both incoming and outgoing traffic has to be explicitly allowed; it is not implicitly
   allowed like SGs.
3. Rules are processed in numerical order to decide whether to permit or deny traffic.   
4. Automatically enacted on all instances in a subnet that has an ACL defined, unlike SGs which need to be explicitly added
    to instances
5. A VCP comes with a default ACL which allows all inbound and outbound traffic by default.  Subnets are associated with this
default ACL unless they are assigned to a custom ACL.  Subnets must always be a member of one and only one ACL. 
6. A custom ACL denies all inbound and outbound traffic by default when created.
7. An ACL can apply to multiple subnets in multiple AZs but a subnet can only be associated with a single ACL
8. Amazon recommend rule numbers incrementing in hundreds e.g 100,200 etc - this gives space to make later amendments.        
9. Ephemeral ports - you need to open ephemeral ports (1024-65535) if you for e.g have a webserver on an instance.
10. Remember that rules are evaluated in order.  If you're going to block specific ip addresses or ports you need to do this
   BEFORE you have any global permissive rules for e.g
   
###### Bastions vs NATs
   
1. NAT routes internet traffic from public subnet to private subnets
2. BASTION host permits ssh connections from public internet, and from there can act as a staging host to jump to internal servers

###### Resilient architecture
1. Always have at least two subnets in two different AZs
2. Use autoscale groups with a min size of 2
3. Use Route53 with round robin or health-check routing to fail over
4. NAT instances are tricky to HA - you need one in each public subnet, with different ips, and scripts to fail over between them.
NAT Gateway is a better solution.

###### VPC Flow Logs   
  
1. Permit you to capture traffic logs a la wiresark, tcpdump
2. Can then push data to CloudWatch for metrics and analysis

------
##### AWS Application Services
###### SQS

1. Oldest AWS service
2. Visibility Timeout window - message processed by one client is invisible to other clients till timeout expires.
3. 256kb payload size
4. Queue acts as a buffer
5. Autoscaling groups can be configured to provision based on SQS queue size
6. Standard Queues and FIFO Queues - FIFO are new.
    6.1 Standard (Default) queues - unlimited Tx/s, messages guaranteed at least once, more than one copy might be delivered out of order - no guarantees of ordering.
    6.2 FIFO - guaranteed delivery order.  Remains available until consumer deletes message. Limited to 300 Tx/s
7. SQS is pull based, not push based.  256k max payload, Message TTL from 1 minute to 14 days, defaults 4 days
8. Max Visibility Time Out is 12 hours     
9. SQS Long Polling - attempt to get message; block and wait for message
10. SQS maintains no application state; app needs to track this
    
###### SWF - Simple Workflow Service

1. Workers are applications that interact with SWF to get tasks, process tasks and return results
2. Starter is the application that initiates an SWS process e.g your website.  
   Decider is the orcestrator : controls scheduling, concurrency and ordering based on app logic.
   Activity works perform the work associated with each task.
3. SWF guarantees tasks assigned once, never duplicated 
4. SWF maintains app state so workers and deciders don't need to and can scale quickly as a result
5. Domains isolate units for a work flow / process into logical groups
6. Max Workflow TTL is a year, expressed in seconds
7. SWF presents a task-orientated API whereas SQS presents a message-orientated API

###### SNS
    
1. Can deliver push notifications to many cloud systems; also SMS, SQS or HTTP endpoints
2. Messages are stored redundantly across multiple AZs
3. Can spool to multiple recipients via topics.  Topics can also spool to multiple different endpoint types.
4. Instantaneous, push-based delivery.  Simple APIS, flexible message delivery. 
5. Pay as you go cost
6. SQS is poll, SNS is push

###### API Gateway

1. API-G is a facade that can provide serverless computing through lambda etc
2. API-G supports caching and throttling
3. API-G scales automatically with load
4. API-G can log to CloudWatch

###### Kinesis

1. Kinesis is a sink for Streaming Data - permits analysis and creation of custom apps based on the data
2. Kinesis core services
    1. Kinesis Streams
        1. Data stored for 24h (default) -> 7 days(max). Data is sharded.  
        2. Consumers (Ec2 instances) run transformations against the Stream data
        3. Consumers forward calculations on for persistance elsewhere
        4. Data capacity of Kinesis stream is sum(capacity of shards in stream)
    2. Kinesis Firehose
        1. Automated aggregation and processing of data - persists direct to SE, analysis etc is optional.
        2. Firehose has no data persistence itself.
        3. Data is either analysed vi Lambda, or else persisted straight to S3.
        4. Firehose can write Kinesis data into Elastic Search
    3. Kinesis Analytics
        1. Permits you to run SQL queries on data within Firehose or Streams; queried data can be stored to S3, RedShift or ElasticSearch
3. Shards implies Streams as Firehose has no shards.  Automatic Analysis via Lambda implies FireHose
        
        
    
    
