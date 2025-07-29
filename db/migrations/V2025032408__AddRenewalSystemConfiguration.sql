IF NOT EXISTS (SELECT 1 FROM systemConfigurations WHERE configType = 'Renewals')
BEGIN
INSERT INTO [systemConfigurations] (configType,config)
VALUES('Renewals',0);
END