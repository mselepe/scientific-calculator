
IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'FK_applicationTiers') AND type in (N'F'))
BEGIN
  ALTER TABLE applicationTiers DROP CONSTRAINT FK_applicationTiers;
END;

IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'FK_applicationTiers_Tiers') AND type in (N'F'))
BEGIN
  ALTER TABLE applicationTiers DROP CONSTRAINT FK_applicationTiers_Tiers;
END;

DROP TABLE IF EXISTS tiers

DROP TABLE IF EXISTS applicationTiers

CREATE TABLE tiers (
    tierId INT IDENTITY(1,1) PRIMARY KEY,
    tier INT NOT NULL,
    [description] VARCHAR(500) NOT NULL
);

CREATE TABLE applicationTiers (
    tierId INT NOT NULL,
    applicationId INT NOT NULL,
);


ALTER TABLE applicationTiers
ADD CONSTRAINT FK_applicationTiers
FOREIGN KEY (applicationId)
REFERENCES universityApplications(applicationId)

ALTER TABLE applicationTiers
ADD CONSTRAINT FK_applicationTiers_Tiers
FOREIGN KEY (tierId)
REFERENCES tiers(tierId)


INSERT INTO tiers(tier, description)
VALUES(1,'Super smart individual, BBD bursary fit has the tech, academics etc'),
(2,'Smart but maybe not at level 1 yet, but there is a financial need to sponsor this person'),
(3,'Purely financial need for bursary, no view of potentially joining BBD, could even be studying a non-tech qualification'),
(4,'Ukukhula bursary tier')
