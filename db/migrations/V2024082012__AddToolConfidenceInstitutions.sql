-- Drop table if it exists

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[confidenceInstitutionAverageTool]') AND type in (N'U'))
BEGIN
  DROP TABLE confidenceInstitutionAverageTool;
END;

-- Create table

CREATE TABLE confidenceInstitutionAverageTool (
  [institutionId] [INT] IDENTITY(1,1) PRIMARY KEY,
  [institutionName] VARCHAR(256) NOT NULL,
  [averageToolConfidence] [BIT] NOT NULL DEFAULT(0)
);


-- Insert into table

IF EXISTS(
        SELECT 1 FROM sys.columns 
            WHERE Name = N'averageToolConfidence'
            AND Object_ID = Object_ID(N'dbo.confidenceInstitutionAverageTool')
        )
BEGIN
                
-- Populate 
INSERT INTO confidenceInstitutionAverageTool(
    institutionName, averageToolConfidence
)
VALUES
    ('University of Limpopo', 1),
    ('North-West University', 1),
    ('Rhodes University', 1),
    ('Stellenbosch University', 1),
    ('University of Cape Town', 1),
    ('University of the Free State', 1),
    ('University of KwaZulu-Natal', 1),
    ('University of South Africa', 1),
    ('University of Pretoria', 1),
    ('University of the Witwatersrand', 1),
    ('University of the Western Cape', 0),
    ('Walter Sisulu University', 0),
    ('University of Venda', 0),
    ('Nelson Mandela University', 0)
END;