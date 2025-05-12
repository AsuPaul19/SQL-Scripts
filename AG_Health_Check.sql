/**********************************************************************
-- Script: AG_Health_Check.sql
-- Purpose: Check SQL Server Availability Groups, replica roles, and 
--          database synchronization status with detailed metrics.
-- Author: [Paul Asu]
-- Date: [2023-05-12]
**********************************************************************/

-- ========================================
-- 1. Check Availability Groups and Replica Roles
# This query gives you a snapshot of who is in the AG, where they are, and how they’re currently connected and synchronized.
-- ========================================
SELECT 
    ag.name AS [AG Name],                                -- Name of the Availability Group
    rcs.role_desc AS [Replica Role],                     -- PRIMARY or SECONDARY
    rcs.connected_state_desc AS [Connected State],       -- CONNECTED or NOT_CONNECTED
    ar.replica_server_name AS [Replica Server],          -- Name of the server hosting the replica
    db.name AS [Database Name],                          -- Name of the database in the AG
    drs.synchronization_state_desc AS [Synchronization State], -- SYNC/SYNCING/NOT SYNCHRONIZED
    drs.is_commit_participant AS [Is Commit Participant],-- 1 if replica participates in commit
    drs.is_suspended AS [Is Suspended],                  -- 1 if data movement is suspended
    drs.synchronization_health_desc AS [Synchronization Health] -- Overall health status
FROM sys.availability_groups ag
JOIN sys.availability_replicas ar 
    ON ag.group_id = ar.group_id
JOIN sys.dm_hadr_availability_replica_states rcs 
    ON ar.replica_id = rcs.replica_id
JOIN sys.dm_hadr_database_replica_states drs 
    ON rcs.replica_id = drs.replica_id
JOIN sys.databases db 
    ON drs.database_id = db.database_id
ORDER BY 
    ag.name, 
    ar.replica_server_name, 
    db.name;

-- ========================================
-- 2. Check Databases' Synchronization Status in AG
--# This query drills into the database-level synchronization metrics, giving you insight
--  into replication lag (via queue sizes) and LSN progress to help you troubleshoot latency or data movement issues.
-- ========================================
SELECT 
    ag.name AS [AG Name],                                -- Name of the Availability Group
    db.database_id AS [Database ID],                     -- Database ID
    db.name AS [Database Name],                          -- Name of the database
    drs.is_local AS [Is Local],                          -- 1 if the replica is local
    drs.is_primary_replica AS [Is Primary Replica],      -- 1 if the local is primary replica
    drs.synchronization_state_desc AS [Synchronization State], -- Current synchronization state
    drs.synchronization_health_desc AS [Synchronization Health], -- Overall sync health
    drs.log_send_queue_size AS [Log Send Queue Size],    -- KB of logs waiting to be sent
    drs.redo_queue_size AS [Redo Queue Size],            -- KB of logs waiting to be redone
    drs.last_hardened_lsn AS [Last Hardened LSN],        -- Last LSN written to disk
    drs.last_commit_lsn AS [Last Commit LSN]             -- Last LSN committed on primary
FROM sys.availability_groups ag
JOIN sys.dm_hadr_database_replica_states drs 
    ON ag.group_id = drs.group_id
JOIN sys.databases db 
    ON drs.database_id = db.database_id
ORDER BY 
    ag.name, 
    db.name;
