/**********************************************************************
-- Script: AG_Health_Monitoring.sql
-- Purpose: Log Always On AG health data and send alerts if issues exist.
-- Author: Paul Asu
-- Date: 2025-05-12
**********************************************************************/
-- ============================================
-- Step 1: Create Logging Table (Run Once)
-- ============================================
-- This table stores each snapshot of AG replica and database health status
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'dbo.AG_Health_Log') AND type = 'U'
)
BEGIN
    CREATE TABLE dbo.AG_Health_Log (
        LogID INT IDENTITY(1,1) PRIMARY KEY,              -- Auto-increment log ID
        LogDate DATETIME DEFAULT GETDATE(),              -- Timestamp of the log entry
        AGName NVARCHAR(128),                             -- Availability Group name
        ReplicaServer NVARCHAR(128),                      -- Name of replica host
        DatabaseName NVARCHAR(128),                       -- Name of database
        SyncState NVARCHAR(60),                           -- Sync state (e.g., SYNCHRONIZED)
        SyncHealth NVARCHAR(60),                          -- Sync health (e.g., HEALTHY)
        IsSuspended BIT,                                  -- 1 if suspended
        LogSendQueueSize BIGINT,                          -- Unsent transaction log size (KB)
        RedoQueueSize BIGINT                              -- Log waiting to be redone (KB)
    );
END

-- ============================================
-- Step 2: Insert Current Health Snapshot
-- ============================================
-- This collects current availability group replica + database status and logs it
INSERT INTO dbo.AG_Health_Log (
    AGName, ReplicaServer, DatabaseName, SyncState, SyncHealth, 
    IsSuspended, LogSendQueueSize, RedoQueueSize
)
SELECT 
    ag.name AS AGName,                                   -- Availability Group name
    ar.replica_server_name AS ReplicaServer,             -- Server hosting the replica
    db.name AS DatabaseName,                             -- Database name
    drs.synchronization_state_desc AS SyncState,         -- Synchronization state
    drs.synchronization_health_desc AS SyncHealth,       -- Synchronization health
    drs.is_suspended,                                    -- 1 if synchronization is suspended
    drs.log_send_queue_size,                             -- Log send queue size in KB
    drs.redo_queue_size                                  -- Redo queue size in KB
FROM sys.availability_groups ag
JOIN sys.availability_replicas ar 
    ON ag.group_id = ar.group_id
JOIN sys.dm_hadr_availability_replica_states rcs 
    ON ar.replica_id = rcs.replica_id
JOIN sys.dm_hadr_database_replica_states drs 
    ON rcs.replica_id = drs.replica_id
JOIN sys.databases db 
    ON drs.database_id = db.database_id;

-- ============================================
-- Step 3 (Optional): Send Email Alert If Issues Detected
-- ============================================
-- Alerts DBAs via Database Mail if any replica or database is unhealthy or suspended
IF EXISTS (
    SELECT 1 
    FROM sys.dm_hadr_database_replica_states
    WHERE synchronization_health_desc != 'HEALTHY'
       OR is_suspended = 1
)
BEGIN
    -- Send alert using Database Mail
    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'YourMailProfile',  -- Replace with the actual DB Mail profile name
        @recipients = 'dba-team@example.com', -- Replace with actual recipient email(s)
        @subject = 'ALERT: SQL AG Synchronization Issue Detected',
        @body = 'One or more Availability Group replicas or databases are not healthy. Please check the AG Dashboard or AG_Health_Log table for details.',
        @body_format = 'HTML';
END
