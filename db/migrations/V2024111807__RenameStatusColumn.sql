DECLARE @schemaName NVARCHAR(128) = 'dbo';
DECLARE @tableName NVARCHAR(128) = 'invitedUsers';
DECLARE @oldColumnName NVARCHAR(128) = 'invitedStatusHistoryId';
DECLARE @newColumnName NVARCHAR(128) = 'invitedStatusId';
DECLARE @sql NVARCHAR(MAX);

IF EXISTS (
    SELECT 1
    FROM sys.columns c
    INNER JOIN sys.tables t ON c.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE c.name = @oldColumnName
      AND t.name = @tableName
      AND s.name = @schemaName
)
BEGIN
    SET @sql = 'EXEC sp_rename ''' + @schemaName + '.' + @tableName + '.' + @oldColumnName + ''', ''' + @newColumnName + ''', ''COLUMN'';';
    EXEC sp_executesql @sql;
    PRINT 'Column renamed successfully.';
END
ELSE
BEGIN
    PRINT 'Column does not exist. No changes made.';
END