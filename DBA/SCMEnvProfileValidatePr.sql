/* P r o p r i e t a r y  N o t i c e */
/* Unpublished © 2001 - 2013 Allscripts Healthcare, LLC.  and/or its affiliates. All Rights Reserved.
*
* P r o p r i e t a r y  N o t i c e: This software has been provided pursuant to a License Agreement, with
Allscripts Healthcare, LLC.  and/or its affiliates, containing restrictions on its use. This software contains
valuable trade secrets and proprietary information of Allscripts Healthcare, LLC.  and/or its affiliates and is
protected by trade secret and copyright law. This software may not be copied or distributed in any form or medium,
disclosed to any third parties, or used in any manner not provided for in said License Agreement except with prior
written authorization from Allscripts Healthcare, LLC.  and/or its affiliates. Notice to U.S. Government Users:
This software is “Commercial Computer Software.”

All product names are the trademarks or registered trademarks of Allscripts Healthcare, LLC.  and/or its affiliates.

*
**/
/* P r o p r i e t a r y  N o t i c e */

--drop  proc SCMEnvProfileValidatePr
CREATE PROC SCMEnvProfileValidatePr
(
    @HierarchyCode  varchar(255),
    @Code  varchar(50),
    @HVCValue  varchar(255),
    @Value  varchar(255),
    @WorkstationProfile bit = 0,
    @WorkstationName varchar(255) = NULL
)
AS
--===================================================================
-- Stored procedure : 	SCMEnvProfileValidatePr		 Tier 1 Stored Proc
-- Function :
-- Inputs:
--	@HierarchyCode: Hierarchy code of entry to be validated
--	@Code: ICode of entry to be validated
--	@Value: value to be validated
-- Returns : an error if one occurs
--	 
-- 
---------------------------------------------------------------------
-- Date         | Author        |Description        |
---------------------------------------------------------------------
-- 12/21/2001   |Kathy Kennedy   |  Create           |
-- 01/May/02	 Terri Haverty	  Cleaned up.
-- 19/Feb/04     Sue Watkins      Port to SXA 3.5
-- 16/Mar/04     Matt Shanaman    Added work 'Display' to some Registration profiles
-- 26/Oct/04	 Matt Shanaman	  Added rules for the new SXA AM 4.0 Env Profiles
-- 16/Nov/04	 Catie Ladd		  Added more rules for SXA AM 4.0 Env Profiles
-- 23/MAy/06     Greg Eiler       Added rules for Docuemnts|Spell Checker profiles
-- 26/May/06     Vijay Verma      Added rules for Documents|Structured Notes profiles
-- 26/Oct/06     Doug Hayes       Added rules for Notification Server
-- 09/Aug/07     Richard Leong    Added rules for Connect|Network Packet Size
-- 04/Oct/07     StephenLui       Added rules for Date-Time profile entries in Connect
-- 13/Mar/09     Suchi Patil      Added rules for Documents|DeleteTimeColumn
-- 04/10/09      Ng, Thomas		  Updated with Registration|ForeignSearch condition for error messages
-- 04/10/09      S Gandikota 	  Added rules for Registration|TemporaryIDConfiguration condition for error messages
-- 19 Jun 2009	 P Folena		  5.5 Allergies dev changes
-- 31 JULY 2009  vmulik           V131011
-- 1/Feb/2010	 G. Hughen		  Added validation for Sunrise XA Patient Financials keys
-- 21 Feb 2010	J.Levine	Added validation for ClientInfo/HeaderAgeDisplayCutoffMethod
-- 3 Jan 2012	 ashivgan		  Added Validation for Client Info/Health Issue Mandatory Reason -'HealthIssueReactivate'		
-- 20 Feb 2012	 D. Krecker		  Added Validation for Documents/Observations/InboundObsTimeFrame -'AmountTimeInFuture' & 'AmountTimeInPast'
-- 5 Mar 2012	 D. Krecker		  Added Validation for Documents/Observations/InboundObsPurgeTimeInterval
-- 3 Apr 2012	 mpatel6		  Added validation for Multum/Enable ICD Codeset
-- 4 Apr 2012	 mpatel6		  Enhanced error message when value is null
-- 10 Sept 2012	 gvajrashetti	  [MU2 - US-398267] Added validation for EP "Health Issue Favorites Map-To Coding Scheme"
-- 03 Oct 2012	 gvajrashetti	  [MU2 - BUG-417760] Split the where condition in "Health Issue Favorites Map-To Coding Scheme".
-- 14 Dec 2012   PKandale         [MU-2][449438] SCT US Config - new EP to indicate SNOMED CT Extension content
-- 19 Dec 2012   PKaplay	  [MU-2][449438] Allow the blank value for EP "Health Issue Extension to SNOMED CT".
-- 24 Jan 2013   PKaplay	  [MU-2][460135] DEV: Code changes for EP "Allow Sharing for Any Info Vendor".
-- 4th Feb 2013  vmulik       bug 461673: Inbound Interface -   Warning:Error processing IN1 segment for SetId[1] : 'SetId is required and must be unique'. Continuing with any other IN1 segments.  Updates dont happen when applicsource=CV
-- 4th Mar 2013  awalker      Add new EP for worklist -> Display Overdue Maximum
-- 17th May 2013 VMulik       bug 482238 When a patient is transferred to a new location while the viasit type is not Inpatient, that transfer is not processed by the Patient Transfer Service
-- 5th June 2013 tpatel				User Story 479449, 479450 : Added check for Prescription for EP Health Issue Allow Attach Outdated Code
--===================================================================


SET NOCOUNT ON

DECLARE @ReturnStatus int,
	@DisplayHeirarchyCode varchar(255), 
	@ErrorText varchar(2000),
	@ValidValues varchar (1000)

-- save original hirarchy code
SET @DisplayHeirarchyCode = @HierarchyCode

-- if called from workstation profile validation, add the HVC Global Workstation so same validations occur
-- as would in env profile
IF @WorkstationProfile = 1
BEGIN
	SET @HierarchyCode = 'HVC Global Workstation|' + @HierarchyCode
	SET @DisplayHeirarchyCode = @WorkstationName + '|' + @DisplayHeirarchyCode
END


IF @HierarchyCode = 'ADT Default Location'
BEGIN
	IF @Code IN ('Inpatient', 'Outpatient') OR @Code IN (Select Code  from Cv3VisitType)
	BEGIN
		DECLARE @ValueStripped varchar(255)
		SET @ValueStripped = Replace(@Value, ' ', '')
		SET @ValueStripped = @ValueStripped + '|'
		
		SET @ValidValues = 'a valid Location'
		IF @Value IS NULL OR @Value = @HVCValue OR (@ValueStripped IN ( SELECT Replace(Code, ' ', '') FROM CV3Location ))
			RETURN (0)
		ELSE
			Goto InvalidValue
	END
	ELSE
		RAISERROR('Invalid Code - must be entry in Visit Type Dictionary',16,1)
END
ELSE IF @HierarchyCode = 'CDS' OR @HierarchyCode = 'CDS|Multum' OR @HierarchyCode = 'CDS|Drug Interaction Alerts'
BEGIN
	IF @CODE = 'Drug Severity Level'
	BEGIN
		SET @ValidValues = '1,2 or 3 only'
		IF ISNUMERIC(@Value)=1 AND ( @Value >= 1 AND @Value <= 3 )
			Return (0)
		ELSE
			Goto InvalidValue
	END
	ELSE IF @Code IN ('CacheReloadInterval', 'MLMReloadInterval')
	BEGIN
		SET @ValidValues = 'a number 0 or greater'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 0
			Return(0)
		Else
			Goto InvalidValue
	
	END
	ELSE IF @Code IN ('DisplayBulkLoadAlerts', 'DisplayInterfacesLiteAlerts', 'SaveToRepository', 'Enable Expert Dosing',
	                  'Alert Drug Food','EnableCDSActivateApplicationTrigger')
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value IN ('TRUE', 'FALSE')
			Return(0)
		ELSE
			Goto InvalidValue
	END
	ELSE IF @Code IN ('Youngest Age For Expert Dosing')
	BEGIN
		SET @ValidValues = 'a number between 0 and 17 inclusive'
		IF ISNUMERIC(@Value)= 1 AND ( @Value >= 0 AND @Value <= 17 )
			Return(0)
		Else
			Goto InvalidValue
	END
	ELSE IF @Code in ('DefaultToViewActionsButton')
	BEGIN
	SET @ValidValues = 'Y, Yes, N, or No'
		IF @Value in ('Y', 'Yes', 'N', 'No')
			Return 0
		ELSE
			GOTO InvalidValue
	END	
END
ELSE IF @HierarchyCode = 'Chart Access Override'
BEGIN
	IF @Code = 'TimeLimit'
	BEGIN
		SET @ValidValues = 'a number 0 or greater'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 0
			Return(0)
		Else
			Goto InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Client Info'
BEGIN
	IF @Code in ('DrugAllergiesNotRecordedReason')
	BEGIN			
        SET @ValidValues = 'Yes, No, or blank where blank = No'
		IF ISNULL(@Value,'') IN ('','Yes','No')
			Return 0
		ELSE 
			GOTO InvalidValue
	END
	IF @Code in ('DrugAllergiesNotRecorded', 'NoKnownAllergies', 'AllergyStatusUnknown', 'NoKnownDrugAllergies')
	BEGIN			
		SET @ValidValues = '60 characters or less in length'
		IF @Value IS NULL OR Len(@Value) < 61
			Return 0
		ELSE
			GOTO InvalidValue
	END
	IF @Code in ( 'AllergyCommentType', 'DeceasedCommentType', 'FinancialCommentType', 'ProviderCommentType')
	BEGIN
		SET @ValidValues = 'an entry in Comment Type dictionary'
        
		IF @Value = @HVCValue OR @Value IN (Select Code From CV3CommentType) 
           OR NOT EXISTS ( SELECT * FROM CV3CommentType )
			Return(0)
		ELSE
			Goto InvalidValue
		
	END
	IF @Code in ('AlternateClientPhoneType', 'BusinessClientPhoneType', 'HomeClientPhoneType', 'PrimaryClientPhoneType', 'ProviderPhoneType')
	BEGIN
		SET @ValidValues = 'an entry in Phone Type dictionary'
		IF @Value = @HVCValue OR @Value in (Select Code From CV3PhoneType)
          OR NOT EXISTS ( SELECT * FROM CV3PhoneType )
			Return(0)
		ELSE
			Goto InvalidValue
	END
	IF @Code = 'AttachmentUnlinkReasonIsMandatory'
	BEGIN
		SET @ValidValues = 'Suppress Dialog, Optional or Mandataory'
		IF @Value IN ('Suppress Dialog', 'Optional', 'Mandatory')
			Return (0)
		Else 
			Goto InvalidValue
	END
	IF @Code IN ('DocumentAllergyReview', 'MandatoryAllergyReview', 'Include Intolerances in Patient Banner', 'Use Adverse Events')
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value IN ('TRUE', 'FALSE')
			Return(0)
		ELSE
			Goto InvalidValue
	END
	IF @Code = 'BSAFormula'
	BEGIN
		SET @ValidValues = 'Standard or Pediatric'
		IF @Value in ('Standard' ,'Pediatric')
			Return (0)
		ELSE
			Goto InvalidValue
	END
	IF @Code in ( 'DefaultAllergenType', 'DefaultAllergenTypeForAllergyDialog' )
	BEGIN   -- no HVCValue for these
		SET @ValidValues = 'an entry in Allergen Type dictionary'
        	IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' ) 
	  	   OR @Value IN ( Select Code From CV3AllergenType ) 
          	   OR NOT EXISTS ( SELECT * FROM CV3AllergenType )
			Return(0)
		ELSE
			Goto InvalidValue	
	END
	IF @Code = 'DefaultGenderCode'
	BEGIN
		SET @ValidValues = 'an entry in Gender dictionary'
		IF @Value = @HVCValue OR @Value IN (Select Code From Cv3Gender)
          OR NOT EXISTS ( SELECT * FROM CV3FRP )
			Return (0)
		ELSE
			Goto InvalidValue
	END
	IF @Code = 'Gender/Sex Label'
	BEGIN
		SET @ValidValues = 'Gender or Sex'
		IF @Value in ('Gender','Sex')
			Return (0)
		ELSE
			Goto InvalidValue
	END
	IF @Code in ('GuarantorCode', 'MedicareCode')
	BEGIN
		SET @ValidValues = 'an entry in FRP dictionary'
		IF @Value = @HVCValue OR @Value in (Select Code from CV3FRP)
          OR NOT EXISTS ( SELECT * FROM CV3FRP )
			Return (0)
		ELSE
			Goto InvalidValue
	END
	IF @Code = 'HeaderAgeCalculationMethod'
	BEGIN
		SET @ValidValues = 'Visit Date or Current Date'
		IF @Value in ('Visit Date' , 'Current Date')
			Return (0)
		ELSE
			Goto InvalidValue
	END
	IF @Code = 'HeaderAgeDisplayCutoffMethod'
	BEGIN
		SET @ValidValues = 'Method1 or Method2'
		IF @Value in ('Method1' , 'Method2')
			Return (0)
		ELSE
			Goto InvalidValue
	END
	IF @Code in ( 'HealthIssue IMO ICD9 Coded Health Issue Type Code',
				  'HealthIssue IMO ICD10 Coded Health Issue Type Code',
				  'HealthIssue ICD9 Coded Health Issue Type Code',
				  'HealthIssue ICD10 Coded Health Issue Type Code')
	BEGIN   -- no HVCValue for these since HI Type codes are loaded after Env. Profile entries
		SET @ValidValues = 'an entry in the Coded Health Issue Type dictionary'
        	IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' ) 
			   OR ( @Code in ('HealthIssue IMO ICD9 Coded Health Issue Type Code',
							  'HealthIssue IMO ICD10 Coded Health Issue Type Code')
					AND ISNULL( @Value, '' ) = '' )
	  		   OR @Value IN ( Select Code From CV3CodedHealthIssueType ) 
          	   OR NOT EXISTS ( SELECT * FROM CV3CodedHealthIssueType )
			Return(0)
		ELSE
			Goto InvalidValue	
	END
	IF @Code = 'MedicareIDType'
	BEGIN
		SET @ValidValues = 'an entry in Client ID Type dictionary'
		IF @Value = @HVCValue OR @Value in (Select Code from CV3ClientIDType)
          OR NOT EXISTS ( SELECT * FROM CV3ClientIDType )
			Return (0)
		ELSE
			Goto InvalidValue
	END
	IF @Code = 'PrimaryClientAddressType'
	BEGIN
		SET @ValidValues = 'an entry in Address Type dictionary'
		IF @Value = @HVCValue OR @Value in (Select Code from CV3AddressType)
          OR NOT EXISTS ( SELECT * FROM CV3AddressType )
			Return (0)
		ELSE
			Goto InvalidValue
	END
	IF @Code = 'PrimaryClientContactType'
	BEGIN
		SET @ValidValues = 'an entry in Contact Type dictionary'
		IF @Value = @HVCValue OR @Value in (Select Code from CV3ContactType)
          OR NOT EXISTS ( SELECT * FROM CV3ContactType )
			Return (0)
		ELSE
			Goto InvalidValue
	END
	IF @Code = 'ReasonType'
	BEGIN
		SET @ValidValues = 'an entry in Health Issue Type dictionary'
		IF @Value = @HVCValue OR @Value in (Select Code from CV3HealthIssueType)
          OR NOT EXISTS ( SELECT * FROM CV3HealthIssueType )
			Return (0)
		ELSE
			Goto InvalidValue
	END
	IF @Code = 'Health Issue Allow Attach Outdated Code'
	BEGIN

		SET @ValidValues = 'Order, Prescription'

		Declare @tbValidValuesOutCode table (Value varchar(max))
		insert into @tbValidValuesOutCode (Value)	values  ('Order') 
		insert into @tbValidValuesOutCode (Value)	values  ('Prescription')
		-- The remaining value list is empty, or it matches the default value
		IF EXISTS (
				SELECT t.* FROM dbo.SXAGNSplitDelimitedStringTblFn(@value, ',') AS t
				WHERE NOT EXISTS (SELECT Value FROM @tbValidValuesOutCode WHERE Value = t.item )
			)
        BEGIN
			Goto InvalidValue;
        END

	END
	IF @Code = 'Health Issue POA Display'
	BEGIN
		SET @ValidValues = 'Yes or No'
		IF @Value in ('Yes', 'No')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	IF @Code = 'Health Issue Allow Discontinue Outdated Code'
	BEGIN
		SET @ValidValues = 'Yes or No'
		IF @Value in ('Yes', 'No')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	IF @Code = 'Health Issue Code Display'
	BEGIN
		SET @ValidValues = 'Valid Combination of ICD-9, ICD-10, SNOMEDCT'
						
		   IF @Value IS NULL
				Return (0)
		   Else IF @Value =''
				Return (0)
		   Else IF @Value IN('ICD-9,ICD-10,SNOMEDCT',
						'ICD-9,SNOMEDCT,ICD-10',
						'ICD-10,ICD-9,SNOMEDCT',
						'ICD-10,SNOMEDCT,ICD-9',
						'SNOMEDCT,ICD-10,ICD-9',
						'SNOMEDCT,ICD-9,ICD-10',
						'ICD-9,ICD-10',
						'ICD-10,ICD-9',
						'ICD-9,SNOMEDCT',
						'SNOMEDCT,ICD-9',
						'ICD-10,SNOMEDCT',
						'SNOMEDCT,ICD-10',
						'ICD-9',
						'ICD-10',
						'SNOMEDCT'
						)
			Return (0)
		Else 
			Goto InvalidValue
	END
	IF @Code = 'Health Issue ICD-9 Display'
	BEGIN
		SET @ValidValues = 'Show or Hide'
		IF @Value IN ('Show', 'Hide')
			Return (0)
		Else 
			Goto InvalidValue
	END
    IF @Code = 'Health Issue Extension to SNOMED CT'
	BEGIN
		SET @ValidValues = 'US or blank'
		IF (@Value = 'US') OR (@Value IS NULL)
			Return (0)
		Else 
			Goto InvalidValue
	END
	IF @Code = 'Health Issue Favorites Map-To Coding Scheme'
	BEGIN
		SET @ValidValues = 'ICD-10 [except ICD-10-PCS] or SNOMEDCT standard terminology'
		IF (@Value IS NULL) OR (@Value ='')
			Return (0)
		ELSE IF ((select count(*) from CV3CodedHealthIssueType where code = @Value and active = 1 and VMLinkCode in  ('ICD-10-AM', 'ICD-10-Billable', 'ICD-10-CA', 'ICD-10-CM', 'SNOMEDCT')) > 0)
			Return (0)
		Else 
			Goto InvalidValue
	END
    IF @Code = 'Health Issue Code for DSM-IV'
	BEGIN
		SET @ValidValues = 'ICD-9 or ICD-10'
		IF @Value IN ('ICD-9', 'ICD-10')
			Return (0)
		Else 
			Goto InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Client Info|Allergy Mandatory Reason'
BEGIN
	IF @Code IN ('AdverseEventDelete', 'AdverseEventDiscontinue', 'AdverseEventModify')
	BEGIN
		SET @ValidValues = 'Suppress Dialog, Optional or Mandataory'
		IF @Value IN ('Suppress Dialog', 'Optional', 'Mandatory')
			Return (0)
		Else 
			Goto InvalidValue
	END
	IF @Code IN ('AllergyDelete', 'AllergyDiscontinue', 'AllergyModify')
	BEGIN
		SET @ValidValues = 'Suppress Dialog, Optional or Mandataory'
		IF @Value IN ('Suppress Dialog', 'Optional', 'Mandatory')
			Return (0)
		Else 
			Goto InvalidValue
	END
	IF @Code = 'AllergyStatusUnknown'
	BEGIN
		SET @ValidValues = 'Optional or Mandatory'
		IF @Value IN ('Optional', 'Mandatory')
			Return (0)
		Else 
			Goto InvalidValue
	END
	IF @Code IN ('IntoleranceDelete', 'IntoleranceDiscontinue', 'IntoleranceModify')
	BEGIN
		SET @ValidValues = 'Suppress Dialog, Optional or Mandataory'
		IF @Value IN ('Suppress Dialog', 'Optional', 'Mandatory')
			Return (0)
		Else 
			Goto InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Client List Flags'
BEGIN
	If @Code = 'FlagNewStartTime'
	BEGIN
		SET @ValidValues = 'a number -1 or higher'
		IF ISNUMERIC(@Value)= 1 AND @Value >= -1
			Return (0)
		Else 
			Goto InvalidValue
	END
	IF @Code = 'PollingInterval'
	BEGIN
		SET @ValidValues = '0 or a number 1800 or higher'
		IF ISNUMERIC(@Value)= 1 AND (@Value = 0 or @Value >= 1800)
			Return (0)
		Else 
			Goto InvalidValue
	END
END
ELSE IF @HierarchyCode LIKE 'Config Tools Report Categories%'
BEGIN
	SET @ValidValues = 'a valid report'
	IF @Value IS NULL OR @Value = @HVCValue OR @Value in (Select Name from HVCReportFile)
		Return (0)
	ELSE
		Goto InvalidValue
END
ELSE IF @HierarchyCode = 'Connect|LogOnAudit'
BEGIN
	IF @Code = 'AuditLogonAttemptCategory'
	BEGIN
		SET @ValidValues = 'a number between 0 and 4'
		IF (ISNUMERIC(@Value)= 1 AND @Value BETWEEN 0 and 4)
			Return 0
		ELSE
			Goto InvalidValue
	END

	ELSE IF @Code in ('FailedLogOnAttemptsValidUser' , 'FailedLogOnAttemptsValidUserTimeFrame', 
		'LogOnAttemptsNonValidUser', 'LogOnAttemptsNonValidUserTimeFrame')
	BEGIN
		SET @ValidValues = 'a number 0 or greater'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 0
			Return 0
		ELSE
			Goto InvalidValue
	END
	ELSE IF @Code = 'UserAccountInactivationTimeLimit'
	BEGIN
		SET @ValidValues = 'a number -1 or greater'
		IF ISNUMERIC(@Value)= 1 AND @Value >= -1
			Return 0
		ELSE
			Goto InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Connect'
BEGIN
	IF @Code IN ('LOSHourMinuteDays', 'HVCIDIncrement', 'MaximumVisits', 'MaximumVisitsForSpecialList', 'Time Search/DelayTime')
	BEGIN
		SET @ValidValues = 'a number 1 or greater'
		IF ISNUMERIC(@Value)= 1 AND @Value > 0
			Return 0
		ELSE
			Goto InvalidValue
	END
	ELSE IF @Code = 'LOSRoundDirection'
	BEGIN
		SET @ValidValues = 'UP or DOWN'
		IF @Value in ('UP', 'DOWN')
			Return 0
		ELSE
			Goto InvalidValue
	END
	ELSE IF @Code in ('WebHelpAvailableForDocumentCatalog', 'WebHelpAvailableForOrderitemCatalog','PatientListByOrderExcludeOrderComponents')
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('TRUE', 'FALSE')
			Return 0
		ELSE 
			Goto InvalidValue
	END
	ELSE IF @Code = 'MaximumNumberFindPatientResults'
	BEGIN
		SET @ValidValues = 'a number from 1 to 500'
		IF ISNUMERIC(@Value) = 1 AND @Value >= 1 AND @Value <= 500
			Return 0
		ELSE
			Goto InvalidValue
	END
	ELSE IF @Code = 'TimeFormat'
	BEGIN
		SET @ValidValues = 'must contain ":" character'
		DECLARE @CharPos numeric
		SELECT @CharPos = CHARINDEX(':', @Value)
		IF @CharPos <> 0
			Return 0
		ELSE
			Goto InvalidValue
	END
	ELSE IF @Code IN ('CompositeDateFormat', 'DateEntryFormat', 'DateFormat', 
					  'DateStampFormat', 'PartialCompositeDateFormat')
	BEGIN
		SET @ValidValues = 'it must contain the exact 4 digit year "yyyy" in lower case.'

		DECLARE @YearSubString varchar(4)
		DECLARE @bIsFound bit

		SET @bIsFound = 0
		SET @YearSubString = SUBSTRING ( @Value, PATINDEX('%yyyy%', @Value), 4 )

		IF (LEN(@YearSubString) = 4) AND (PATINDEX('%yyyyy%', @Value) = 0)
		BEGIN
			-- successfully found a 'yyyy' substring and ensured that no 
			-- 'yyyyy' or longer 'y' strings exist.  Now, must confirm
			-- substring is in lower-case via collation.  We need to do this because 
			-- PATINDEX() doesn't consider letter-casing when retrieving the 'yyyy' sub-string.
			SELECT @bIsFound = 1 WHERE @YearSubString = 'yyyy' collate SQL_Latin1_General_CP1_CS_AS 
		END			

		IF (@bIsFound = 1)
			RETURN 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'SQL NET Packet Size'
	BEGIN
		SET @ValidValues = 'a number from 4096 to 32764'
		IF ISNUMERIC(@Value) = 1 AND @Value >= 4096 AND @Value <= 32764
			Return 0
		ELSE
			Goto InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Conversion'
BEGIN
	IF @Code =  'Measure'
	BEGIN
		SET @ValidValues = '0 or 1'
		IF ISNUMERIC(@Value)= 1 AND @Value BETWEEN 0 AND 1
			Return 0
		ELSE
			Goto InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Default Provider Type'
BEGIN
	SET @ValidValues = 'an entry in Provider Type dictionary'
	IF @Value = @HVCValue OR @Value IN (Select Code from Cv3ProviderType)
          OR NOT EXISTS ( SELECT * FROM CV3ProviderType )
		Return 0
	ELSE
		Goto InvalidValue
END
ELSE IF @HierarchyCode = 'Documents|Continuity of Care'
BEGIN
	IF @Code =  'C-CDA_BatchSave_Document_Name'
	BEGIN
		SET @ValidValues = 'a valid document catalog entry configured as an exchange document'
		IF (@Value IS NULL) OR @Value in (Select Name From CV3PatientCareDocument WHERE EntryType = 10)
			Return 0
		ELSE
			Goto InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Documents|Observations'
BEGIN
	IF @Code =  'Start of Day'
	BEGIN
		SET @ValidValues = 'a number between 0 and 2400'
		IF ISNUMERIC(@Value)= 1 AND @Value BETWEEN 0 AND 2400
			Return 0
		ELSE
			Goto InvalidValue
	END
	IF @Code =  'InboundObsPurgeTimeInterval'
	BEGIN
		SET @ValidValues = 'a number between 1 and 30'
		IF ISNUMERIC(@Value)= 1 AND @Value BETWEEN 1 AND 30
			Return 0
		ELSE
			Goto InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Documents|Observations|InboundObsTimeFrame'
BEGIN
	IF @Code =  'AmountTimeInFuture'
	BEGIN
		SET @ValidValues = 'a number between 1 and 99999'
		IF ISNUMERIC(@Value)= 1 AND @Value BETWEEN 1 AND 99999
			Return 0
		ELSE
			Goto InvalidValue
	END
	IF @Code =  'AmountTimeInPast'
	BEGIN
		SET @ValidValues = 'a number between 1 and 99999'
		IF ISNUMERIC(@Value)= 1 AND @Value BETWEEN 1 AND 99999
			Return 0
		ELSE
			Goto InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Documents|Structured Notes'
BEGIN
	IF @Code in ('AdditionalInformation', 'DocumentTopic', 'ChartedDataIndicator', 'ModifyAcronyms','OverrideIncompleteCheckbox')
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('TRUE', 'FALSE')
			Return 0
		Else 
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Documents|DeleteTimeColumn'  
BEGIN  
	IF @Code in ('DisplayReasonCode')  
	BEGIN  
		SET @ValidValues = 'None, Delete, ChangeTime or Both'  
		IF @Value in ('NONE', 'BOTH','DELETE', 'CHANGETIME')  
			Return 0  
		Else   
		GOTO InvalidValue  
	END
	IF @Code in ('DeleteTimeColumnMandatoryReason')  
    BEGIN  
		SET @ValidValues = 'Yes or No'  
		IF @Value in ('YES', 'NO')  
			Return 0  
		Else   
			GOTO InvalidValue  
	END   
END
ELSE IF @HierarchyCode = 'Documents'
BEGIN
	IF @Code in ('Admitting Physician Role', 'Attending Physician Role', 'Referring Physician Role')
	BEGIN
 		SET @ValidValues = 'an entry in Provider Role dictionary'
		IF @Value = @HVCValue OR @Value in (SELECT Code from CV3ProviderRole)
          OR NOT EXISTS ( SELECT * FROM CV3ProviderRole )
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code in ('Admitting Physician Type', 'Attending Physician Type', 'Referring Physician Type')
	BEGIN
		SET @ValidValues = 'an entry in Provider Type dictionary'
		IF @Value = @HVCValue OR @Value in (SELECT Code from CV3ProviderType)
          OR NOT EXISTS ( SELECT * FROM CV3ProviderType )
			Return 0
		Else IF @Value in (Select TypeCode from CV3CareProviderroletype)
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code  in ('Cancel Interface Doc', 'Edit Interface Doc')
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		If @Value in ('TRUE', 'FALSE')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'CancelMandatoryReasonText'
	BEGIN
		SET @ValidValues = 'Yes or No'
		IF @Value in ('Yes', 'No')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'FinalizedDocEditInterval'
	BEGIN
		SET @ValidValues = 'a number of minutes; 0 or greater'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 0
			Return(0)
		Else
			Goto InvalidValue
	END
	ELSE IF @Code = 'CompleteTaskInPastTime'
	BEGIN
		SET @ValidValues = 'a number of minutes; 0 to 999'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 0 AND @Value <= 999
			Return(0)
		Else
			Goto InvalidValue
	END
	ELSE IF @Code = 'CompleteTaskInFutureTime'
	BEGIN
		SET @ValidValues = 'a number of minutes; 0 to 999'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 0 AND @Value <= 999
			Return(0)
		Else
			Goto InvalidValue
	
	END
	ELSE IF @Code = 'DisplayMostRecentDocuments'
	BEGIN
		SET @ValidValues = 'a number between 0 and 50'
		IF ISNUMERIC(@Value)= 1 AND (@Value >= 0 and @Value <= 50)
			Return 0
		Else 
			GOTO InvalidValue
	END
	ELSE IF @Code = 'RTF1stColumnWidth'
	BEGIN
		SET @ValidValues = 'a number between 2 and 6'
		IF ISNUMERIC(@Value)= 1 AND (@Value >= 2 and @Value <= 6)
			Return 0
		Else 
			GOTO InvalidValue
	END
	-- and need to add check for 'Observations' which is a 24 hour clock entry
END
ELSE IF @HierarchyCode = 'Documents|Spell Checker'
BEGIN
	IF @Code in ('Free Text Documents','Structured Notes')
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('TRUE', 'FALSE')
			Return 0
		Else 
			GOTO InvalidValue
	END
END	
ELSE IF @HierarchyCode = 'EMI Defaults'
BEGIN
	IF @Code in ('PhoneTypeFax', 'PhoneTypeOffice', 'PhoneTypePager')
	BEGIN
		SET @ValidValues = 'an entry in Phone Type dictionary'
		IF @Value = @HVCValue OR @Value in (SELECT Code from CV3PhoneType)
          OR NOT EXISTS ( SELECT * FROM CV3PhoneType )
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'SelfRelationshipCode'
	BEGIN
		SET @ValidValues = 'an entry in Relationship dictionary'
		IF @Value = @HVCValue OR @Value in (Select Code from CV3Relationship)
          OR NOT EXISTS ( SELECT * FROM CV3Relationship )
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'EMI ID Types'
BEGIN
	SET @ValidValues = 'an entry in Client ID Type dictionary'
	IF @Value = @HVCValue OR @Value in (Select Code from CV3ClientIDType)
          OR NOT EXISTS ( SELECT * FROM CV3ClientIDType )
		Return 0
	ELSE
		GOTO InvalidValue
END
ELSE IF @HierarchyCode = 'Facility'
BEGIN
	IF @Code = 'DefaultAddressType'
	BEGIN
		SET @ValidValues = 'an entry in Address Type dictionary'
		IF @Value = @HVCValue OR @Value in (Select Code from CV3AddressType)
          OR NOT EXISTS ( SELECT * FROM CV3AddressType )
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'DisableFirstTimeExpiry'
	BEGIN
	SET @ValidValues = 'Y, Yes, N, or No'
		IF @Value in ('Y', 'Yes', 'N', 'No')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'UsingContextServer'
	BEGIN
		SET @ValidValues = 'Y or N'
		IF @Value in ('Y', 'N')
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'HL7 Interfaces'
BEGIN
	IF @Code IN ( 'CancelAndPreadmit', 'CreateSpecimenForSCMOrder', 'SetSpecimenCollectedStatus', 'Send Pending Location PV1-42 In Non-ADT During PTR' )
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		If @Value in ('TRUE', 'FALSE')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'ProcessingID'
	BEGIN
		SET @ValidValues = 'D, P, or T'
		IF @Value in ('D' , 'P' , 'T')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'SendOrders'
	BEGIN
		SET @ValidValues = 'Y or N'
		IF @Value in ('Y', 'N')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'SendADTwtUOM'
	BEGIN
		SET @ValidValues = 'KG or GM'
		IF @Value in ('KG', 'GM')
			Return 0
		ELSE
			goto InvalidValue
	END
	ELSE IF @Code in ('ConnectionTimeout', 'ExecPollInt', 'MSMQTimeOutRetry', 'StatusUpdateInterval', 'UnacknowledgedOrderTimeOut', 'UndispatchedOrderTimeOut')
	BEGIN
		SET @ValidValues = 'a number 0 or greater'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 0
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'DefaultOrderPriority'
	BEGIN
		SET @ValidValues = 'an entry in Order Priority dictionary'
		IF @Value = @HVCValue OR @Value in (Select Code  from CV3OrderPriority)
          OR NOT EXISTS ( SELECT * FROM CV3OrderPriority )
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'DefaultResultPriority'
	BEGIN
		SET @ValidValues = 'an entry in Result Priority dictionary'
		IF @Value = @HVCValue OR @Value in (Select Code  from CV3ResultPriority)
          OR NOT EXISTS ( SELECT * FROM CV3ResultPriority )
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'UseDefaultImmunizationSendingFacility'
	BEGIN
		SET @ValidValues = 'Yes or No'
		IF @Value = @HVCValue OR @Value in ('Yes','No')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code IN ( 'Local Coding Standard','LOINC Coding Standard')
	BEGIN
		Set @ValidValues = 'an entry in the Ancillary Coding Standard Dictionary'
		IF ( @Value is null ) OR EXISTS( Select Code from CV3AncillaryCodingStd WHERE Code = @Value )
		  OR NOT Exists ( SELECT * FROM CV3AncillaryCodingStd )
		  Return 0
		ELSE
		   GOTO InvalidValue
	END
	----
	ELSE IF @Code = 'ProcessAllReceivedInsUpdates'
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value = @HVCValue OR @Value in ('TRUE','FALSE')
			Return 0
		ELSE
			GOTO InvalidValue
	END	
	----
END
ELSE IF @HierarchyCode IN  ('HL7 Interfaces|Reportable Results','HL7 Interfaces|Biosurveillance','HL7 Interfaces|Case Notification')
BEGIN
	IF @Code in ( 'ReceivingApplication', 'ORUReceivingApplication' )
	BEGIN
		Set @ValidValues = 'an entry in the Application Dictionary'
		IF ( @Value is null ) OR EXISTS( Select Code from CV3Application WHERE Code = @Value )
		  OR NOT Exists ( SELECT * FROM CV3Application )
		  Return 0
		ELSE
		   GOTO InvalidValue
	END
    ELSE IF @Code IN ( 'Observation Coding Standard','Specimen Preferred Standard','Specimen Alternate Standard')
	BEGIN
		Set @ValidValues = 'an entry in the Ancillary Coding Standard Dictionary'
		IF ( @Value is null ) OR EXISTS( Select Code from CV3AncillaryCodingStd WHERE Code = @Value )
		  OR NOT Exists ( SELECT * FROM CV3AncillaryCodingStd )
		  Return 0
		ELSE
		   GOTO InvalidValue
	END
	ELSE IF @Code = 'UseDefaultSendingFacility'
	BEGIN
		SET @ValidValues = 'Yes or No'
		IF @Value = @HVCValue OR @Value in ('Yes','No')
			Return 0
		ELSE
			GOTO InvalidValue
	END
END

ELSE IF @HierarchyCode = 'HVC Global Workstation|Authentication Configuration'
BEGIN
	IF @Code = 'WideAreaCitrixModeEnabled'
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('TRUE', 'FALSE')
			RETURN 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'UserCanSelectAuthentication'
    BEGIN
	  	SET @ValidValues = 'TRUE or FALSE'
	   	IF @Value in ('TRUE', 'FALSE')
		   	RETURN 0
		   ELSE
			   GOTO InvalidValue
	END
	ELSE IF @Code = 'DefaultToUsernamePasswordOnEPError'
    BEGIN
		SET @ValidValues = 'TRUE or FALSE'
	   	IF @Value in ('TRUE', 'FALSE')
		   	RETURN 0
		   ELSE
			   GOTO InvalidValue
	END
	ELSE IF @Code = 'Authentication Option'
	BEGIN
		SET @ValidValues = 'a number between 1 and 4'
		IF ISNUMERIC(@Value)= 1 AND (@Value >= 1 and @Value <= 4)
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code = 'Alternate Authentication Options'
	BEGIN
		SET @ValidValues = 'Comma delimited list of option from 1-4 example 1,2,3,4'
		IF @Value in  ('1','2','3','4','1,2','1,3','1,4','1,2,3','1,2,4',
		               '1,3,4','2,3','2,4','2,3,4','3,4','1,2,3,4')
			Return 0
		ELSE 
			GOTO InvalidValue
	END
	ELSE IF @Code = 'Re-Authentication Option'
	BEGIN
		SET @ValidValues = 'a number between 1 and 4'
		IF ISNUMERIC(@Value)= 1 AND (@Value >= 1 and @Value <= 4)
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code = 'Alternate Re-Authentication Options'
	BEGIN
		SET @ValidValues = 'Comma delimited list of option from 1-4 example 1,2,3,4'
		IF @Value in  ('1','2','3','4','1,2','1,3','1,4','1,2,3','1,2,4',
		               '1,3,4','2,3','2,4','2,3,4','3,4','1,2,3,4')
			Return 0
		ELSE 
			GOTO InvalidValue
	END
--  Old options used form SXA R1  
	IF @Code = 'Logon Options'
	BEGIN
		SET @ValidValues = 'a number between 1 and 3'
		IF ISNUMERIC(@Value)= 1 AND @Value BETWEEN 1 AND 3
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'Re-authentication Options'
	BEGIN
		SET @ValidValues = 'a number between 1 and 3'
		IF ISNUMERIC(@Value)= 1 AND @Value BETWEEN 1 AND 3
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'DoesDomainIDEqualSunriseXALogonID'
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('TRUE', 'FALSE')
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'HVC Global WorkStation|Client Info|Allergies'
BEGIN
	IF @Code = 'AllowMultipleAllergyReviews'
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('TRUE', 'FALSE')
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'HVC Global WorkStation|Client Info'
BEGIN
	IF @Code = 'DisplayCareProviderID'
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('TRUE', 'FALSE')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'DisplayCareProviderIDType'
	BEGIN
		SET @ValidValues = 'an entry in Care provider ID dictionary'
		IF @Value = @HVCValue OR @Value IS NULL OR @Value in (SELECT CODE FROM CV3ProviderIDType) OR NOT EXISTS (SELECT * FROM CV3ProviderIDType)
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'HVC Global Workstation|Connect'
BEGIN
	IF @Code = 'AllowSuspendSession'
	BEGIN
		SET @ValidValues = 'Yes or No'
		IF @Value in ('Yes', 'No')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code in ('FunctionKeyLogoff' , 'FunctionKeySuspendSession')
	BEGIN
		SET @ValidValues = 'None or F2 to F12'
		IF @Value IS NULL OR @Value IN ('None', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12')
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code in ('LogonTimeOut', 'SuspendSessionTimeOut', 'MaximumEntriesOnAutoRefreshPatientList')
	BEGIN
		SET @ValidValues = 'a number between 0 and 999'
		IF ISNUMERIC(@Value)= 1 AND @Value BETWEEN 0 AND 999
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code = 'LogonWarning'
	BEGIN
		SET @ValidValues = 'a number 0 or greater'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 0
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code = 'EDWorkstation'
	BEGIN	
		SET @ValidValues = 'FALSE'
		IF @Value = 'False'
			Return 0
		Else
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'HVC Global Workstation|Connect|PatientList'
BEGIN
    IF @Code = 'Clear Context if Pt Not on List'
    BEGIN
        SET @ValidValues = 'Yes or No'
		IF @Value in ('Yes', 'No')
			Return 0
		ELSE
			GOTO InvalidValue
    END
END
ELSE IF @HierarchyCode = 'HVC Global Workstation|Documents Control Bar'
BEGIN
	IF @Code = 'DefaultChart'
	BEGIN
		SET @ValidValues = '0 or 1'
		IF (ISNUMERIC(@Value)= 1 AND @Value BETWEEN 0 AND 1)
			Return 0
		Else
			GOTO InvalidValue
	END
	IF @Code in ('DefaultSinceAllChart', 'DefaultSinceThisChart')
	BEGIN
		SET @ValidValues = 'a number 0 or greater'
		IF (ISNUMERIC(@Value)= 1 AND @Value >= 0)
			Return 0
		Else
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode Like  'HVC Global Workstation|Documents%'
BEGIN
	IF @Code = 'Flowsheet Authored Time Count'
	BEGIN
		SET @ValidValues = 'a number between 4 and 12'
		IF (ISNUMERIC(@Value)= 1 AND @Value BETWEEN 4 AND 12)
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code in ('Flowsheet Authored Time Descending', 'NewDocument', 'Sign')
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('True', 'False')
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code = 'Flowsheet Authored Time Interval'
	BEGIN
		SET @ValidValues = 'a number between 1 and 60'
		IF (ISNUMERIC(@Value)= 1 AND @Value BETWEEN 1 AND 60)
			Return 0
		Else
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'HVC Global Workstation|Health Management|Web Link'
BEGIN
	IF @Code = 'ButtonLabel'
	BEGIN
		SET @ValidValues = '20 characters or less in length'
		IF @Value IS NULL OR Len(@Value) < 21
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode in ( 'HVC Global Workstation|Health Management|Immunization|Authentication',
						    'HVC Global Workstation|Health Management|Wellness|Authentication' )
BEGIN
	IF @Code like '%MarkAs%Done'
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value IN ( 'True','False')
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF ( @HierarchyCode ='Health Management|Immunization' AND @Code = 'MinSeasonalOccurrenceGap')
BEGIN
	SET @ValidValues = 'a number between 1 and 999'
	IF ISNUMERIC(@Value)= 1 AND (charindex('.', @Value) = 0) AND @Value BETWEEN 1 AND 999
		Return 0
	ELSE
		GOTO InvalidValue
END
ELSE IF ( @HierarchyCode ='Health Management|Immunization' AND @Code = 'DisplayLotSourceInLotInformation')
BEGIN
	SET @ValidValues = 'TRUE or FALSE'
	IF @Value IN ( 'True','False')
		Return 0
	ELSE
		GOTO InvalidValue
END
ELSE IF ( @HierarchyCode ='Health Management|Immunization' AND @Code = 'UnknownVaccineEventName')
BEGIN
	SET @ValidValues = 'a valid immunization event defined in the Health Management Configuration tool'
	IF ( @Value is null ) or ( not exists( select * from SXAHMEvent ))
		or ( exists ( select * FROM SXAHMEvent where Name = @Value and Active=1 and Type = 0))
		Return 0
	ELSE
		GOTO InvalidValue
END
ELSE IF ( @HierarchyCode = 'Health Management|Immunization|Reconciliation' and @Code = 'MaxDaysSameOccurrence')
BEGIN
		SET @ValidValues = 'a whole number zero or greater'
		IF ISNUMERIC(@Value)= 1 and ( charindex( '.', @Value) = 0 )AND @Value >= 0
			Return 0
		Else
			GOTO InvalidValue
END
ELSE IF ( @HierarchyCode ='Health Management|Reports|Default Reminder Letter Schedule' AND @Code like 'Schedule[0..9]')
BEGIN
	SET @ValidValues = 'an active enterprise schedule defined in the Health Management Configuration Tool'
	IF ( @Value is null ) or ( not exists( select * from SXAHMSchedule ))
	   or ( exists ( select * from SXAHMSchedule where Name = @Value and Active=1 ))
		Return 0
	ELSE
		GOTO InvalidValue
END
ELSE IF @HierarchyCode Like 'HVC Global Workstation|Orders%'
BEGIN
	IF @Code in ('Display Master Repeat Order', 'Display Master Complex Order', 'CancelDiscontinue', 'Modify', 'NewOrder', 
	             'ReleaseHold', 'Sign', 'Suspend', 'Unsuspend', 'Verify', 
	             'DisplaySetModificationDateAtOrderEntry', 'Use Bold For Inactive Order Name', 'Use Italic For Inactive Orders', 'DischargeOrdersInBackground')
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('TRUE', 'FALSE')
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code in ('DefaultSinceAllChart', 'DefaultSinceThisChart')
	BEGIN
		SET @ValidValues = 'a number 0 or greater'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 0
			Return 0
		Else
			GOTO InvalidValue
	END

END
ELSE IF @HierarchyCode Like 'HVC Global Workstation|OrderTabControlBar'
BEGIN
	IF @Code in ('DefaultSinceDate')
	BEGIN
		SET @ValidValues = 'a number 0 or greater'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 0
			Return 0
		Else
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode Like 'HVC Global Workstation|Results'
BEGIN
	IF @Code IN ('MaximumDisplayLines','MinimumDisplayLines')
	BEGIN
		SET @ValidValues = 'a number between 1 and 15'
		IF ISNUMERIC(@Value)= 1 AND @Value BETWEEN 1 AND 15 
			Return 0
		Else
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode Like 'HVC Global Workstation|Results|AdditionalResultInfoDialogLabels'
BEGIN
	IF @Code = 'AnalysisDateTime'
	BEGIN
		SET @ValidValues = '35 characters or less in length'
		IF Len(@Value) <= 35
			Return 0
		ELSE
			GOTO InvalidValue
	END
	IF @Code = 'ResponsibleObserver'
	BEGIN
		SET @ValidValues = '35 characters or less in length'
		IF Len(@Value) <= 35
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'PerformingOrganization'
	BEGIN
		SET @ValidValues = '50 characters or less in length'
		IF Len(@Value) <= 50
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode Like 'HVC Global Workstation|ResultsControlBar'
BEGIN
	IF @Code in ('DefaultSinceAllChart', 'DefaultSinceThisChart')
	BEGIN
		SET @ValidValues = 'a number 0 or greater'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 0
			Return 0
		Else
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'HVC Global Workstation|Summary Panel Codes'
BEGIN
	SET @ValidValues = 'a number between 1 and 8'
	IF ISNUMERIC(@Value)= 1 AND @Value BETWEEN 1 AND 8
		Return 0
	Else
		GOTO InvalidValue
END
ELSE IF @HierarchyCode = 'HVC Global Workstation|Tasks|SignOnSubmit'
BEGIN
	IF @Code = 'Sign'
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		If @Value in ('TRUE', 'FALSE')
			Return 0
		Else
			GOTO InvalidValue
	END
END 
ELSE IF @HierarchyCode = 'HVC Global Workstation|Tools'
BEGIN
	IF @Code = 'HVCAppCount'
	BEGIN
		SET @ValidValues = 'a number 0 or greater'
		If ISNUMERIC(@Value)= 1 AND @Value >= 0
			Return 0
		Else
			GOTO InvalidValue
	END
END 

ELSE IF @HierarchyCode Like 'Health Management|Schedule'
BEGIN
	IF @Code = 'Enable Auto Assignment'
	BEGIN
		SET @ValidValues = 'Yes or No'
		IF @Value in ('Yes', 'No')
			Return 0
		ELSE
			GOTO InvalidValue
	END
END

ELSE IF @HierarchyCode Like 'HVC Global Workstation|Health Management'
BEGIN
	IF @Code IN ( 'Display Health Mgr Status on Header', 'Show Near Due Reminder' )
	BEGIN
		SET @ValidValues = 'Yes or No'
		IF @Value in ('Yes', 'No')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	IF @Code = 'Default Display View'
	BEGIN
		SET @ValidValues = '1 or 2'
		IF @Value in ('1','2')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	
END

ELSE IF @HierarchyCode in  ('HVC Global Workstation|Health Management|Summary View','HVC Global Workstation|Health Management|Working View')
BEGIN
	IF @Code IN ( 'Max Rows in Cell' ) and @HierarchyCode = 'HVC Global Workstation|Health Management|Summary View'
	BEGIN
		SET @ValidValues = 'a number 0 or greater'
		If  (ISNUMERIC(@Value)= 1 AND @Value >= 0) or ( @Value is null )
			Return 0
		Else
			GOTO InvalidValue
	END
	IF @Code = 'Default Sort by'
	BEGIN
		SET @ValidValues = '1,2 or 3'
		IF @Value in ('1','2','3')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	
END



ELSE IF @HierarchyCode = 'Location'
BEGIN
	SET @ValidValues = 'an entry in Location Type dictionary'
	IF @Value = @HVCValue OR @Value in (Select Code from CV3LocationType)
          OR NOT EXISTS ( SELECT * FROM CV3LocationType )
		Return 0
	ELSE
		GOTO InvalidValue
END 
ELSE IF @HierarchyCode = 'Multum'
BEGIN
	IF @Code = 'Enable ICD Codeset'
	BEGIN
		SET @ValidValues = '"ICD9" "ICD10" "ICD9, ICD10" or "ICD10, ICD9"'
		IF @Value in  ('ICD9','ICD10','ICD9, ICD10','ICD10, ICD9')
			Return 0
		ELSE 
			GOTO InvalidValue
	END
END 
ELSE IF @HierarchyCode = 'Orders'
BEGIN
	IF @Code = 'AUC Status for Completed Session'
	BEGIN
		SET @ValidValues = 'AUC 1 - 10 or COMP'
		IF @Value in  ('AUC1','AUC2','AUC3','AUC4','AUC5','AUC6','AUC7','AUC8',
		               'AUC9','AUC10','COMP')
			Return 0
		ELSE 
			GOTO InvalidValue
	END
	ELSE IF @Code in ('AllowOrderEntryOnCanceledVisitsTime', 'AllowOrderEntryOnClosedVisitsTime', 
			'AllowOrderEntryOnDischargedVisitsTime', 'NumberOfSpecimenLabels', 'MinValueThousandSeparator', 
			'AutoStatusOrderOnTransferDelayTime')
	BEGIN
		SET @ValidValues = 'a number 0 or greater'
		If ISNUMERIC(@Value)= 1 AND @Value >= 0
			Return 0
		Else
			GOTO InvalidValue
	END 
	ELSE IF @Code = 'BackdateMaxDays'
	BEGIN
		SET @ValidValues = 'a number between 0 and 32767'
		IF ISNUMERIC(@Value)= 1 AND @Value BETWEEN 0 AND 32767
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code = 'Review Orders Days in Advance'
	BEGIN
		SET @ValidValues = 'a number from 0 to 99'
		IF ISNUMERIC(@Value)= 1 AND ( ( @Value >= 0 ) AND ( @Value <= 99 ))
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code in ('CancelDiscontinueMandatoryReasonText', 'CheckDuplicate', 'ClearRequestedByProviderOnSubmit',
	             'Display Health Issue Summary on Order Entry', 'Display separator after order name', 
	             'DisplayWarningIfAllAdditivesZero', 'MergeComponents', 'ReinstateMandatoryReasonText', 
	             'Source Required', 'SuspendMandatoryReasonText','UnsuspendMandatoryReasonText', 
                 'UseDiscontinueStatus', 'TreatReorderedItemAsNew', 'AutomaticallyDiscontinueAllOrdersOnDischarge',
                 'TriggerFlagsWhenOrderVerified', 'DefaultCollectionDateTime', 'HideDateTimeOnOrderEntryWorksheet',
                 'BlankDateWhenReorderToHoldSession', 'ReplaceCaretSeparatorCharacterInSummaryLine','AllowSelectAllButtonForUn/Suspend',
                 'AcknowledgeNewChildDosingOptionOrders', 'AllowSelectAllButtonForReleaseHold', 'SelectAllTextInFormField',
                 'MedHxUnknownReasonTextIsMandatory')
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('TRUE', 'FALSE')
			RETURN 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code = 'Discontinue Orders/Tasks On Discharge'

	BEGIN
		SET @ValidValues = 'a number -1 or greater'
		IF ISNUMERIC(@Value)= 1 AND @Value >= -1
			RETURN 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code = 'Discontinue Orders/Tasks On Visit Close'

	BEGIN
		SET @ValidValues = 'a number -1 or greater'
		IF ISNUMERIC(@Value)= 1 AND @Value >= -1
			RETURN 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code = 'DC/CancelOrderStatus'
	BEGIN
		SET @ValidValues = '55, 60 or 69'
		IF ISNUMERIC(@Value)= 1 AND @Value in (55, 60, 69)
			RETURN 0
		Else
			GOTO InvalidValue
	END	
	ELSE IF @Code = 'PendingVerifyStatusForAdditionalVerifier'
	BEGIN
		SET @ValidValues = 'PDVR 1 - 9 or PDVR'
		IF @Value in  ('PDVR','PDVR1', 'PDVR2','PDVR3','PDVR4','PDVR5','PDVR6','PDVR7','PDVR8',
		               'PDVR9')
			Return 0
		ELSE 
			GOTO InvalidValue
	END
	ELSE IF @Code = 'OrderReconciliationConcurrencyWarningTimeOut'
	BEGIN
		SET @ValidValues = 'a number between 1 and 9999'
		IF ISNUMERIC(@Value)= 1 AND (@Value >= 1 and @Value <= 9999)
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code = 'OrderReconciliationOrderStatusGroupHeadings'
	BEGIN
		SET @ValidValues = 'a list of seven comma delimited values'
		DECLARE @CommaPos int
		DECLARE @nCount int

		SET @nCount = 0
		SET @CommaPos = 0

		SELECT @CommaPos = CHARINDEX(',', @Value, @CommaPos )
		WHILE ( @CommaPos <> 0 )
		BEGIN
			SET @nCount = @nCount + 1
			SELECT @CommaPos = CHARINDEX(',', @Value, @CommaPos+1 )
		END

		IF @nCount = 6 
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code in ('OrderReconciliationLabel_AutoReconcile', 'OrderReconciliationLabel_HistoricalMeds', 'OrderReconciliationLabel_HistoricalOrders' )
	BEGIN
		SET @ValidValues = '30 characters or less in length'
		IF Len(@Value) < 31
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode  = 'Patient Info Summary Views'
BEGIN
	IF @Code = 'DefaultSummaryViewIndex'
	BEGIN
		SET @ValidValues = 'a number between 0 and 9'
		IF ISNUMERIC(@Value)= 1 AND @Value BETWEEN 0 and 9
			RETURN 0
		Else
			GOTO InvalidValue

	END
    ELSE IF @Code = 'Demographics Language Label'
	BEGIN
		SET @ValidValues = '20 characters or less in length' 
		IF Len(ISNULL(Ltrim(@Value),'')) < 21 AND @Value IS NOT NULL
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Orders|Order Reconciliation Reports'
BEGIN
	IF ( @Code in ('Admit Doc Proc', 'Transfer Doc Proc','Discharge Doc Proc' ) and @Value is not null )
	BEGIN
		IF @Value = @HVCValue 
			return 0
		ELSE
		BEGIN
			IF NOT EXISTS ( SELECT * FROM Information_schema.Routines 
							WHERE Routine_name = @Value and Routine_Type = 'Procedure' )
			BEGIN
				SET @ValidValues = 'a stored procedure name which exists in the database'
				GOTO InvalidValue
			END
		END
	END
END
ELSE IF @HierarchyCode Like 'Orders|Order Reconciliation Types%'
BEGIN
    IF @Code in ('HideHomeOrdersPanel', 'IgnoreAutoStatusOrderOnTransferPolicy', 'BestMatchIsTheSingleMMDCMappedItem', 'AutomaticallyCreateDischargeOrdersForMeds')
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('TRUE', 'FALSE')
			RETURN 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code in ( 'MarkAllRemainingAsReviewedLabel', 'MarkAllRemainingAsReviewedLabelSuffix', 'OrderReconciliationLabel_ReplaceWithNewHomeMed', 'OrderReconciliationLabel_ReplaceWithNewRx', 'OrderReconciliationLabel_OtherMedications')
	BEGIN
		SET @ValidValues = '40 characters or less in length'
		IF Len(@Value) <= 40
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'IncludeDcCancelCompleteOrdersTimeframe'
	BEGIN
		SET @ValidValues = 'a number between -1 and 1440 inclusive'
		IF ISNUMERIC(@Value)= 1 AND (@Value >= -1 AND @Value <= 1440)
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'AcceptableProductRoutesToOverrideInjectableRoute'
	BEGIN
	    SET @ValidValues = 'a comma separated list of drug catalog keys for acceptable product routes: 2412,2414,2420 and 2431'
		
		Declare @tbValidRouteValues table (Value varchar(255))
		insert into @tbValidRouteValues (Value)	values  ('2412') , ('2414'), ('2420'), ('2431')
		-- The remaining value list is empty, or it matches the default value
		IF EXISTS (
				SELECT t.* FROM dbo.SXAGNSplitDelimitedStringTblFn(@value, ',') AS t
				WHERE NOT EXISTS (SELECT Value FROM @tbValidRouteValues WHERE Value = t.item )
			)
			Goto InvalidValue;
	END

END
ELSE IF @HierarchyCode = 'Orders|PrescriptionToOrderFieldMapping'
BEGIN
	IF ( @Code in ('QuantityAmount', 'Instructions','Comments','Memo','IsDAW' ) and @Value is not null )
	BEGIN
		IF @Value = @HVCValue 
			return 0
		ELSE
		BEGIN
			SET @ValidValues = 'the name of an appropriate UDDI form field that is configured for "Medication" or "Other" type orders'

			DECLARE @DataTypeCode varchar(30)
			IF EXISTS ( SELECT *
						FROM CV3DataItem 
						WHERE Code = @Value 
							AND IsHVCField = 0 
							AND ( OrderTypeCode = 'Medication' OR OrderTypeCode = 'Other' ) )
			BEGIN
				SELECT @DataTypeCode = DataTypeCode FROM CV3DataItem WHERE Code = @Value 
				IF ( ( @Code in ('Instructions','Comments','Memo' ) AND @DataTypeCode <> 'Free Format Text' ) OR
				     ( @Code = 'QuantityAmount' AND @DataTypeCode <> 'Numeric' ) OR 
				     ( @Code = 'IsDAW' AND @DataTypeCode <> 'Checkbox' ) )
				BEGIN
					GOTO InvalidValue
				END
			END
			ELSE
			BEGIN
				GOTO InvalidValue
			END
		END
	END
END
ELSE IF @HierarchyCode = 'Provider'
BEGIN
	IF @Code in ('AdmittingRole', 'AttendingRole', 'ConsultingRole',  'ReferringRole')
	BEGIN
		SET @ValidValues = 'an entry in Provider Role dictionary'
		IF @Value = @HVCValue OR @Value in  (Select Code from CV3ProviderRole)
          OR NOT EXISTS ( SELECT * FROM CV3ProviderRole )
			Return 0
		ELSE 
			GOTO InvalidValue
	END
	ELSE IF @Code in ( 'DefaultType')
	BEGIN
		SET @ValidValues = 'an entry in Provider Type dictionary'
		IF @Value = @HVCValue OR @Value in  (Select Code from CV3ProviderType)
          OR NOT EXISTS ( SELECT * FROM CV3ProviderType )
			Return 0
		ELSE 
			GOTO InvalidValue
	END
	ELSE IF @Code in( 'DefaultAddressType','SuffixDegreePrefixAddrType')
	BEGIN
		SET @ValidValues = 'an entry in Address Type dictionary'
		IF isnull(@Value,'') = isnull(@HVCValue,'') OR @Value in (Select Code from Cv3AddressType)
          OR NOT EXISTS ( SELECT * FROM CV3AddressType )
			Return 0
		ELSE 
			GOTO InvalidValue
	END
	ELSE IF @Code = 'UPIN' OR @Code = 'DEA' or @Code = 'NPI' or @Code = 'TaxID' or @Code = 'CLIA'
	BEGIN
		SET @ValidValues = 'an entry in Provider Type dictionary'
		IF @Value IS NULL OR @Value = @HVCValue 
			OR EXISTS (Select 1 From CV3ProviderIDType Where Code = @Value)
	       	 	OR NOT EXISTS ( SELECT 1 FROM CV3ProviderIDType )
			Return 0
		ELSE 
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Sunrise XA Patient Financials'
BEGIN
	IF @Code IN ('Change Reason Note Ins Plan')
	BEGIN
		SET @ValidValues = 'Yes or No'
		IF @Value in ('Yes', 'No')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code in ('IsSunriseXAPatientFinancialsInstalled')
	BEGIN	
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('True', 'False')
			Return 0
		Else
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Registration'
BEGIN
	--  M.Shanaman - Restored with checking to see if any records exist in specified table before raising error
                          ---Temporarily commented out to prevent build breakage 
	IF @Code = 'PrimaryAddress'
	BEGIN
		SET @ValidValues = 'a valid Address Type that is general and not multiple'
		IF @Value IS NULL OR @Value in (SELECT code FROM CV3AddressType WHERE IsMultiple = 0 AND IsGeneralType = 1)
		OR NOT EXISTS ( SELECT 1 FROM CV3AddressType )
			Return 0
		Else
			Goto InvalidValue
	END
	ELSE IF @Code = 'PrimaryEmail'
	BEGIN
		--
		-- TODO: Add check for "e-mail" type (no column in DB for this, yet)
		--
		SET @ValidValues = 'an e-mail Address Type that is general and not multiple'
		IF @Value IS NULL OR @Value in (SELECT code FROM CV3AddressType WHERE IsMultiple = 0 AND IsGeneralType = 1)
		OR NOT EXISTS ( SELECT 1 FROM CV3AddressType )
			Return 0
		Else
			Goto InvalidValue
	END 
	ELSE IF @Code = 'TemporaryIDConfiguration'
	BEGIN
		SET @ValidValues = 'An integer in the range 1 to 3, inclusive.'
		IF ISNUMERIC(@Value) = 1 AND @Value >= 1 AND @Value <= 3
			Return 0
		Else
			GOTO InvalidValue
	END 
	ELSE IF @Code IN ('PrimaryPhone', 'SecondaryPhone')
	BEGIN
		SET @ValidValues = 'a valid Phone Type that is general and not multiple'
		IF @Value IS NULL OR @Value IN (SELECT code FROM CV3PhoneType WHERE IsMultiple = 0 AND IsGeneralType = 1)
		OR NOT EXISTS ( SELECT 1 FROM CV3PhoneType )
		BEGIN
			IF @Code = 'PrimaryPhone' AND @Value IN (SELECT [Value] FROM HVCEnvProfile WHERE HierarchyCode = 'Registration' AND Code = 'SecondaryPhone')
			OR NOT EXISTS ( SELECT 1 FROM HVCEnvProfile )
			BEGIN
				SET @ValidValues = 'a Phone Type that is different than the Secondary Phone Type'
				Goto InvalidValue
			END
			ELSE IF @Code = 'SecondaryPhone' AND @Value IN (SELECT [Value] FROM HVCEnvProfile WHERE HierarchyCode = 'Registration' AND Code = 'PrimaryPhone')
			OR NOT EXISTS ( SELECT 1 FROM HVCEnvProfile )
			BEGIN
				SET @ValidValues = 'a Phone Type that is different than the Primary Phone Type'
				Goto InvalidValue
			END
			ELSE
				Return 0
		END
		ELSE
			Goto InvalidValue
	END 
	
	IF @Code = 'Patient Receipt'
	BEGIN
		SET @ValidValues = '1-99999999'
		IF ISNUMERIC(@Value) = 1 AND @Value >= 1 AND @Value <= 99999999
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code IN ('MaxLocations', 'MaxVisitsInfoDesk')
	BEGIN
		SET @ValidValues = '1-99999'
		IF ISNUMERIC(@Value) = 1 AND @Value >= 1 AND @Value <= 99999
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'RelationshipForSelf'
	BEGIN
		---- Added for V131011
		SET @ValidValues = 'an active entry in the Relationship Dictionary and not used as Relationship For Newborn Guarantor.  Please select a valid relationship to self'
		IF EXISTS (SELECT Code FROM HVCEnvProfile WHERE [Value] = @Value AND Code = 'RelationshipForNewbornGuarantor' AND HierarchyCode = 'Registration')
			GOTO InvalidValue
		----
		SET @ValidValues = 'an entry in Relationship dictionary'
		IF @Value = @HVCValue OR @Value in (Select Code from CV3Relationship)
          OR NOT EXISTS ( SELECT * FROM CV3Relationship )
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'AdvanceDirectiveForm'
	BEGIN
		--
		-- TODO: Confirm that "Type" is 16 for Advance Directive forms
		--
		SET @ValidValues = 'a valid Advance Directive form'
		IF @Value IS NULL OR @Value IN (SELECT Name FROM CV3OrderEntryForm WHERE Type = 16 AND IsCurrent = 1)
			Return 0
		ELSE
			Goto InvalidValue
	END
	ELSE IF @Code = 'EmergencyAdmitType'
	BEGIN
		SET @ValidValues = 'Admit type used to indicate an Emergency.  Must be in the AdmitType Dictionary.'
		IF @Value = @HVCValue OR @Value in (Select Code from SXAAMAdmitType)
          OR NOT EXISTS ( SELECT * FROM SXAAMAdmitType )
			Return 0
		ELSE
			GOTO InvalidValue
	END

	ELSE IF @Code = 'IDTypeSSNum'
	BEGIN
		SET @ValidValues = 'an empty string, "NONE", or "UNKNOWN"'
		IF @Value IS NULL OR UPPER(@Value) in ('', 'NONE', 'UNKNOWN') 
			Return 0
		ELSE
			Goto InvalidValue
	END
	ELSE IF @Code = 'InitialLocationStatus'
	BEGIN
		SET @ValidValues = 'a valid Location Status value'
		--
		-- TODO: Uncomment the following lines when the SXAAMLocationStatus table is approved
		--
		-- IF @Value IS NULL OR @Value IN (SELECT Code FROM SXAAMLocationStatus WHERE Active = 1)
			Return 0
		-- ELSE
		--	Goto InvalidValue
		
	END
	ELSE IF @Code = 'HL7DefaultInsuranceCompany'
	BEGIN
		SET @ValidValues = 'an insurance company filed in the system'
		--
		-- TODO: Finish this once the database is complete and approved
		--
		-- IF @Value IS NULL OR @Value IN (SELECT xxx FROM SXAAMxxx WHERE xxx)
			Return 0
		-- ELSE
		--	Goto InvalidValue
	END
	ELSE IF @Code = 'ContactTypeForGuarantors'
	BEGIN
		SET @ValidValues = 'any contact type in the configuration.'
		IF @Value IS NULL OR @Value IN (SELECT Code FROM CV3ContactType WHERE Active = 1)
          OR NOT EXISTS ( SELECT * FROM CV3ContactType )
			Return 0
		ELSE
			Goto InvalidValue
	END
	ELSE IF @CODE = 'DischargeInstructions'
	BEGIN
		SET @ValidValues = 'Null, Yes, or No'
		IF @Value IS NULL OR @Value in ('Yes', 'No')
			Return 0
		ELSE
			Goto InvalidValue
	END
	ELSE IF @Code IN ('DisplayLanguage', 'DisplayEthnicity', 'DisplayHispanic', 'DisplayReligion',
				'DisplayPlaceOfWorship', 'DisplayVeteranStatus', 'Canada',
				'DischargeProviderRequired', 'DischargeCondition',
				'SecureHealthMessagingSetup', 'SHMFlag', 'IsMigratingViaADTInterface',
				'VisitLevelInsuranceDefault', 'MedicareSecondaryPayer', 'EnableFacilityTransfer',
				'EnableDischarge/Re-admit')
	BEGIN
		SET @ValidValues = 'Yes or No'
		IF @Value in ('Yes', 'No')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'ApplyIDConfigToReserveNumbers'
	BEGIN
		Set @ValidValues = 'TRUE or FALSE'
		if @Value in ('TRUE', 'FALSE')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	---- Added for V131011
	-- Default Guarantor for a newborn
	IF @Code = 'RelationshipForNewbornGuarantor'
	BEGIN
		IF @Value IS NULL 
			RETURN 0
		SET @ValidValues = ' an active entry in the Relationship Dictionary'
		IF NOT EXISTS (SELECT Code FROM CV3Relationship WHERE Active = 1 and Code = @Value)
			GOTO InvalidValue
		SET @ValidValues = 'an active entry in the Relationship Dictionary and not used as Relationship for Self.  Please select a valid relationship to newborn'
		IF EXISTS (SELECT Code FROM HVCEnvProfile WHERE [Value] = @Value AND [Code] = 'RelationshipForSelf' AND HierarchyCode = 'Registration')
			GOTO InvalidValue
		RETURN 0
	END
	----
	---- Added for V482238	
	IF @Code = 'SendOPTransfersToPharmacy'
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('True', 'False')
			Return 0
		Else
			GOTO InvalidValue
	END
	----

END
ELSE IF @HierarchyCode = 'Registration|ContinuityOfCare'
BEGIN
	IF @Code IN ('CCDAOrganizationInfoInternalID', 'CCDAOrganizationInfoSiteID')
	BEGIN
		SET @ValidValues = '0-2147483642'
		IF ISNUMERIC(@Value) = 1 AND @Value >= 0 AND @Value <= 2147483642
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Registration|EPISearches'
BEGIN
	IF @Code = 'IsUsingEPIForPatientSearches'
	BEGIN	
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('True', 'False')
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code = 'EPIServerAddress'
	BEGIN	
		-- CKL Come back to this
		SET @ValidValues = '(NNN.NNN.NNN.NNN), where NNN is an integer in the range: 0-255'
		DECLARE @IPAddressLen int
		DECLARE @inFirstDot int
		DECLARE @inSecondDot int
		DECLARE @inThirdDot int
		DECLARE @ValidIPAddress bigint


		SET @Value = LTRIM(RTRIM(@Value))
		SET @IPAddressLen = LEN(@Value)
		SET @ValidIPAddress = 0

		IF (@Value IS NULL OR @IPAddressLen = 0) 
		BEGIN
			SET @ValidIPAddress = 0
		--RETURN
		END
		   
		SELECT @inFirstDot = CHARINDEX('.',@Value)
		SELECT @inSecondDot = CHARINDEX('.',@Value,@inFirstDot+1)
		SELECT @inThirdDot = CHARINDEX('.',@Value,@inSecondDot+1)

		SELECT @ValidIPAddress = 1 WHERE
				-- Make sure the number is valid
				CAST(SUBSTRING(@Value,1,@inFirstDot-1) as int) <= 255
				AND CAST(SUBSTRING(@Value,@inFirstDot+1,@inSecondDot-@inFirstDot-1) as int) <= 255
				AND CAST(SUBSTRING(@Value,@inSecondDot+1,@inThirdDot-@inSecondDot-1) as int) <= 255
				AND CAST(SUBSTRING(@Value,@inThirdDot+1,@IPAddressLen-@inThirdDot) as int) <= 255
				-- Make sure each one has a value
				AND LEN(SUBSTRING(@Value,1,@inFirstDot-1)) BETWEEN 1 AND 3
				AND LEN(SUBSTRING(@Value,@inFirstDot+1,@inSecondDot-@inFirstDot-1)) BETWEEN 1 AND 3
				AND LEN(SUBSTRING(@Value,@inSecondDot+1,@inThirdDot-@inSecondDot-1)) BETWEEN 1 AND 3
				AND LEN(SUBSTRING(@Value,@inThirdDot+1,(@IPAddressLen -@inThirdDot))) BETWEEN 1 AND 3

		    
		IF @@Error <> 0
		BEGIN
			SET @ValidIPAddress = 0
			--RETURN
		END
		IF @ValidIPAddress = 1
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code = 'EPIStartingPortNumber'
	BEGIN	
		SET @ValidValues = '(0-65535), for example: 49152'
		IF ISNUMERIC(@Value) = 1 AND @Value >= 0 AND @Value <= 65535
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code = 'EPINumberOfPorts'
	BEGIN	
		SET @ValidValues = 'An integer greater than one, for example: 2'
		IF ISNUMERIC(@Value) = 1 AND @Value > 1
			Return 0
		Else
			GOTO InvalidValue
	END
ELSE IF @Code = 'EPIRequestTimeOut'
	BEGIN	
		SET @ValidValues = 'An integer in the range 1 to 9999, inclusive.'
		IF ISNUMERIC(@Value) = 1 AND @Value >= 1 AND @Value <= 9999
			Return 0
		Else
			GOTO InvalidValue
	END

END
ELSE IF @HierarchyCode = 'Registration|ForeignSearch'
BEGIN
	IF @Code = 'ForeignID'
	BEGIN
	
		SET @ValidValues = 'Only active values from the Patient ID Type dictionary are accepted.'
		IF	@Value IS NULL OR @Value = '' OR @Value = @HVCValue OR 
			  @Value in (SELECT Code FROM CV3ClientIDType WHERE Active = 1)
			BEGIN
				SET @ValidValues = 'The Patient ID Type cannot have a Code Class of "Prime" or "MRN"'
				IF @Value in (SELECT Code FROM CV3ClientIDType WHERE Active = 1 AND (Class = 'Prime' OR Class = 'MRN'))
					GOTO InvalidValue
				ELSE
					return 0
			END			
		ELSE
			GOTO InvalidValue
						
						
						
	END
END
ELSE IF @HierarchyCode = 'Report Cleanup'
BEGIN
	IF @Code IN ('HistoryRemovalTime', 'RemovalTime')
	BEGIN
		SET @ValidValues = 'a number 0 or greater'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 0 
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Report Printing'
BEGIN
	IF @Code IN ('Replication Wait Time')
	BEGIN
        SET @ValidValues ='an integer in the range 30 to 600, inclusive.'
		IF ISNUMERIC(@Value)= 1 AND (@Value >= 30 and @Value <= 600)
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'HTTP Request Timeout'
	BEGIN	
		SET @ValidValues = 'An integer in the range of 100 to 7200, inclusive.'
		IF ISNUMERIC(@Value) = 1 AND @Value >= 100 AND @Value <= 7200
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code IN ('Max Retries')
	BEGIN
		SET @ValidValues = 'a number from 0 to 5'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 0 AND @Value <= 5 
			Return 0
		ELSE
			GOTO InvalidValue
	END	
	ELSE IF @Code IN ('Render DPI')
	BEGIN
		SET @ValidValues = 'a number greater than or equal to 96'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 96 
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code IN ('Print First Page Timeout')
	BEGIN
		SET @ValidValues = 'a number greater than or equal to 30'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 30
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code IN ('Print Next Page Timeout')
	BEGIN
		SET @ValidValues = 'a number greater than or equal to 10'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 10 
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code IN ('Num Jobs To Restart Report Spooler')
	BEGIN
		SET @ValidValues = 'a number is either 0 or greater than or equal to 100'
		IF ISNUMERIC(@Value)= 1 AND (@Value = 0 OR @Value >= 100)
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code IN ('Logging Debug Info')
	BEGIN
		SET @ValidValues = 'a number is either 0 or 1'
		IF ISNUMERIC(@Value)= 1 AND (@Value = 0 OR @Value = 1)
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code IN ('Maximum Print Jobs For Report Mgr')
	BEGIN
		SET @ValidValues = 'a number from 100 to 10000'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 100 AND @Value <= 10000
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Results'
BEGIN
	IF @Code in ('DisplayOrderStatus', 'DisplayResultStatus', 'EnableBulkLoad')
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('TRUE', 'FALSE')
			Return 0
		ELSE
			GOTO InvalidValue
	END		
END
ELSE IF @HierarchyCode = 'Signature Completion'
BEGIN
	IF @Code = 'DisplayDocumentDetailsBeforeSigning'
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('TRUE', 'FALSE')
			Return 0
		ELSE
			GOTO InvalidValue
	END		
	ELSE IF @Code = 'MaximumItemsOnSignatureCompletionDisplay'
	BEGIN
		SET @ValidValues = 'a number between 0 and 450'
		IF ISNUMERIC(@Value)= 1 AND (@Value >= 0 and @Value <= 450)
			Return 0
		Else
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'User'
BEGIN
	IF @Code = 'DefaultOccupation'
	BEGIN
		SET @ValidValues = 'an entry in Occupation dictionary'
		IF @Value = 'Physician' OR @Value = @HVCValue OR @Value in (Select Code from CV3Occupation)
			Return 0
		ELSE
			GOTO InvalidValue
	END
	IF @Code = 'DefaultSecurityGroup'
	BEGIN
		SET @ValidValues = 'a valid Security Group'
		IF @Value = 'CareVISIONAll' OR @Value = @HVCValue OR @Value in (Select Code from CV3SecurityGroup)
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Worklists'
BEGIN
	IF @Code = 'AdmitVia Task Start Date Time'
	BEGIN
		SET @ValidValues = 'ADMIT or TRANSACTION'
		IF @Value in ('ADMIT' , 'TRANSACTION')
			Return 0
		Else 
			GOTO InvalidValue
	END
	ELSE IF @Code in ('Allowable Document Task Early Time', 'Allowable Document Task Early Time at Order Entry', 
                      'Allowable Reset To Pending Time','Maximum Queue Entry Inactivated Count')
	BEGIN
		SET @ValidValues = 'a number 0 or greater'
		IF ISNUMERIC(@Value)= 1 AND @Value >= 0
			Return 0
		Else 
			GOTO InvalidValue
	END
	ELSE IF @Code = 'Backdate Task Generation'
	BEGIN
		SET @ValidValues = 'a number between 0 and 200'
		IF ISNUMERIC(@Value)= 1 AND (@Value >= 0 and @Value <= 200)
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code = 'Remove Task Completion After Stop'
	BEGIN
		SET @ValidValues = 'a number between 1 and 999'
		IF ISNUMERIC(@Value)= 1 AND (@Value >= 1 and @Value <= 999)
			Return 0
		Else
			GOTO InvalidValue
	END
	ELSE IF @Code in ('Default Task Performed Time to Current Date/Time', 'GenerateConditionalTask', 
	                  'Show Birth Date on Worklist', 'Using Task Generation')
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('TRUE', 'FALSE')
			RETURN 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code in ('Use Order''s Is LVP Flag to Determine Task Dose','Sign Tasks')
	BEGIN
		SET @ValidValues = 'YES or NO'
		IF @Value in ('YES', 'NO')
			RETURN 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'Worklist Birth Date Label Text'
	BEGIN
		SET @ValidValues = 'must contain ''<d>'' to indicate the date''s position.'
		DECLARE @Parameter int
		SELECT @Parameter = PATINDEX('%<d>%', @Value) 
		IF @Parameter <> 0
		BEGIN
			SET @ValidValues = 'must use ''~'' to indicate a space''s position.'
			SELECT @Parameter = PATINDEX('% %', @Value)
			IF @Parameter = 0
				RETURN 0
			ELSE
				GOTO InvalidValue
		END
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'Task Update Retries'
	BEGIN
		SET @ValidValues = 'a number between -1 and 10'
		IF ISNUMERIC(@Value)= 1 AND (@Value >= -1 and @Value <= 10)
			Return 0
		Else
			GOTO InvalidValue
	END

	ELSE IF @Code in ('UnackAlertPriorityLevelDone', 'UnackAlertPriorityLevelNotDone')
	BEGIN
		SET @ValidValues = 'HIGH, MEDIUM, LOW, or NONE'
		IF @Value in ('HIGH', 'MEDIUM', 'LOW', 'NONE')
			Return 0
		ELSE
			GOTO InvalidValue
	END	

    ELSE IF @Code in ('Task Complete Timeout','Flag Overdue Timeout' )
    BEGIN
        SET @ValidValues = 'a number between 0 and 999'
        IF IsNumeric(@Value)=1 AND @Value between 0 and 999
            return 0
        ELSE
            goto InvalidValue
    END

    ELSE IF @Code in ( 'UpdateTaskDescriptionForPastPendingTasks' )
    BEGIN
        SET @ValidValues = 'a number between 0 and 9999'
        IF IsNumeric(@Value)=1 AND @Value between 0 and 9999
            return 0
        ELSE
            goto InvalidValue
    END

    ELSE IF @Code = 'Task Queue Entry Timeout'
    BEGIN
        SET @ValidValues = 'a number greater than or equal to 30'
        IF IsNumeric(@Value)=1 and @Value >= 30
            return 0
        ELSE
            goto InvalidValue
    END
    
    ELSE IF @Code = 'Maximum Queue Entry Processed Count'
    BEGIN
        SET @ValidValues = 'a number greater than 1'
        IF IsNumeric(@Value)=1 and @Value > 1
            return 0
        ELSE
            goto InvalidValue
    END

    ELSE IF (@Code = 'Display Overdue Maximum') 
	BEGIN
		SET @ValidValues = 'a number between 1 and 999'
		IF ISNUMERIC(@Value)= 1 AND (@Value >= 1 and @Value <= 999)
			Return 0
		Else
			GOTO InvalidValue
	END

    ELSE IF (@Code = 'ExcludeDischargedClosedVisits') And ( @Value is not null )
	BEGIN
		SET @ValidValues = 'a number between 1 and 999 or blank'
		IF ISNUMERIC(@Value)= 1 AND (@Value >= 1 and @Value <= 999)
			Return 0
		Else
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Worklists|Occurrence Queue Entry Process Limit'
BEGIN
	-- The code entries under this branch represent the name of task generators
	-- Ensure the value is numeric and -1 or greater
	IF ISNUMERIC(@Value) = 1 AND @Value >= -1
		Return 0
	ELSE
	BEGIN
		SET @validValues = 'a number greater than or equal to -1'
		GOTO InvalidValue
	END

END
ELSE IF @HierarchyCode = 'Barcode Verification'
BEGIN
	IF @Code = 'DisplayTimePeriod'
	BEGIN
		SET @ValidValues = 'a number between 0 and 1440'
		IF ISNUMERIC(@Value)= 1 AND (@Value >= 0 and @Value <= 1440)
			Return 0
		Else 
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Barcode Verification|Warnings|Dose Warnings'
BEGIN
	IF @Code in ('IsDoseWarningEnabled')
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('TRUE', 'FALSE')
			Return 0
		Else 
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Barcode Verification|Warnings|Drug Warnings'
BEGIN
	IF @Code in ('IsDrugWarningEnabled','IsDrugOverrideAllowed','IsDrugOverrideReasonRequired')
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('TRUE', 'FALSE')
			Return 0
		Else 
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Barcode Verification|Warnings|Admin Time Warnings'
BEGIN
	IF @Code in ('IsAdminTimeWarningEnabled','IsAdminTimeOverrideAllowed','IsAdminTimeOverrideReasonRequired')
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value in ('TRUE', 'FALSE')
			Return 0
		Else 
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'Medical Necessity Checking'
BEGIN
	IF @Code = 'ICD9CodedHealthIssueType'
	BEGIN
		SET @ValidValues = 'an entry in Coded Health Issue Type dictionary'	
		IF @Value = @HVCValue OR EXISTS (Select 1 from CV3CodedHealthIssueType WHERE Code = @Value)
          OR NOT EXISTS ( SELECT top 1 * FROM CV3CodedHealthIssueType )
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'EnvMedChecking'
	BEGIN
	SET @ValidValues = 'Y or N'
		IF @Value in ('Y','N')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'MedicareProviderNumber'
	BEGIN
	SET @ValidValues = '16 characters in length'
		IF Len(@Value) < 17
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'IncludeEmergencyVisits'
	BEGIN
	SET @ValidValues = 'Y or N'
		IF @Value in ('Y','N')
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF @Code = 'IncludeObservationVisits'
	BEGIN
	SET @ValidValues = 'Y or N'
		IF @Value in ('Y','N')
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF @HierarchyCode = 'KBA'
BEGIN
		IF @Code = 'Operation Mode'
	BEGIN
		SET @ValidValues = 'INTERFACED or INTEGRATED'
		IF @Value in ('INTERFACED' , 'INTEGRATED')
			Return 0
		Else 
			GOTO InvalidValue
	END
	
END
ELSE IF @HierarchyCode = 'Pharmacy'
BEGIN
	IF @Code = 'IgnoreModificationByUserForAcknowledgeOrders'
	BEGIN
		Set @ValidValues = 'a valid Username as entered in User Configuration.'
		IF nullif(@Value,'') is null or EXISTS ( SELECT * FROM CV3User where IDCode = @Value ) OR NOT EXISTS (SELECT * FROM CV3User)
			RETURN 0
		ELSE 
			GOTO InvalidValue
		
	END
	ELSE IF @Code = 'AckOrdersFlagForRxVerifiedMeds'
	BEGIN
		SET @ValidValues = 'ForNewOrders, AfterRxVerify, or NewAndAfterRxVerify'
		IF @Value in  ('ForNewOrders','AfterRxVerify', 'NewAndAfterRxVerify')
			Return 0
		ELSE 
			GOTO InvalidValue
	END	
END

ELSE IF @HierarchyCode like 'Notification Server|Transports|%'
BEGIN
    IF @Code = 'Assembly'
    begin
        set @ValidValues = 'a valid .NET assembly'
        if @Value is null OR @Value = ''
            GOTO InvalidValue
        else
            return 0
    end
    else if @Code = 'HeartBeatInterval'
    begin
        if ISNUMERIC(@Value)= 1 AND @Value > 0
        begin 
        
            declare @PollingInterval int
            select @PollingInterval=value from HVCEnvProfile
            where HierarchyCode = @HierarchyCode and Code='PollingInterval'
            if @PollingInterval is not null AND @PollingInterval >= @Value
            begin
                set @ValidValues = 'greater than PollingInterval of ' + cast(@PollingInterval as varchar(10))
                GOTO InvalidValue
            end
            else
                return 0
        end
        else
        begin
            set @ValidValues = 'numeric and greater than 0'
            GOTO InvalidValue
        end       
    end
    else if @Code = 'PollingInterval'
    begin
        if ISNUMERIC(@Value)= 1 AND @Value > 0
        begin 
            declare @HeartBeat int
            select @HeartBeat=value from HVCEnvProfile
            where HierarchyCode = @HierarchyCode and Code='HeartBeatInterval'
            if @HeartBeat is not null AND @HeartBeat <= @value
            begin
                set @ValidValues = 'less than HeartBeatInterval of ' + cast(@HeartBeat as varchar(10))
                GOTO InvalidValue
            end
            else
                return 0
        end
        else
        begin
            set @ValidValues = 'numeric and greater than 0'
            GOTO InvalidValue
        end 
    end
    else if @Code in ('AttemptsBeforeFail','FailuresBeforeReject','TimeToRetry','StopOnFailure','RetryAfterStop','PurgeAfter')
    begin
        if ISNUMERIC(@Value)= 1 AND @Value >= 0 
            return 0
        else
        begin
            set @ValidValues = 'numeric and greater than or equal to 0'
            GOTO InvalidValue
        end 
    end
END
ELSE IF ( @HierarchyCode = 'Client Info|Health Issue Mandatory Reason' )
BEGIN
	IF ( @Code in ( 'HealthIssueModify','HealthIssueDelete','HealthIssueDiscontinue','HealthIssueReactivate'))
	BEGIN
		IF ( @Value IN ( 'Suppress Dialog','Mandatory','Optional'))
			RETURN 0
		ELSE
		BEGIN
			Set @ValidValues = 'Suppress Dialog, Mandatory or Optional'
			GOTO InvalidValue
		END
	END
END
ELSE IF ( @HierarchyCode = 'Orders|Order Reconciliation Manager' )
BEGIN
	IF ( @Code in ( 'MaximumItemsInOrderReconciliationMenus'))
	BEGIN
		SET @ValidValues = 'a number between 1 and 50 inclusive'
		IF ISNUMERIC(@Value)= 1 AND ( @Value >= 1 AND @Value <= 50 )
			Return(0)
		Else
			Goto InvalidValue
    END
	ELSE IF ( @Code in ('IncludeVisitsWithDischargeOrdersTimeframe' ) and @Value is not null )
	BEGIN
		IF @Value = @HVCValue 
			return 0
		ELSE
		BEGIN
			SET @ValidValues = 'a number between 1 and 10 inclusive, or -1'
			IF ISNUMERIC(@Value)= 1 AND ((@Value >= 1 and @Value <= 10) OR @Value = -1)
				Return 0
			Else
				GOTO InvalidValue
		END
	END
	ELSE IF ( @Code in ( 'OrderReconciliationLabel_AutoReconcile' ) )
	BEGIN
		SET @ValidValues = '30 characters or less in length'
		IF Len(@Value) < 31
			Return 0
		ELSE
			GOTO InvalidValue
	END
	ELSE IF ( @Code in ( 'OrderReconciliationLabel_Alternatives', 'OrderReconciliationLabel_HomeMedications', 'OrderReconciliationLabel_RelatedItems', 'OrderReconciliationLabel_RelatedOrderSets', 'OrderReconciliationLabel_ReviewAndReconcile', 'OrderReconciliationLabel_NeedsFurtherReview' )  )
	BEGIN
		SET @ValidValues = '40 characters or less in length'
		IF Len(@Value) < 41
			Return 0
		ELSE
			GOTO InvalidValue
	END

END
ELSE IF ( @HierarchyCode = 'Patient Portal' )
BEGIN
	IF ( @Code in ( 'ReleaseResultsAutomaticallyOnSignUpTimeFrame'))
	BEGIN
		SET @ValidValues = 'a number between -1 and 99 inclusive'
		IF ISNUMERIC(@Value)= 1 AND ( @Value >= -1 AND @Value <= 99 )
			Return(0)
		Else
			Goto InvalidValue
	END
END
-- for Surgery Procedure Ancillary Codes
ELSE IF @HierarchyCode = 'Surgery|Procedure Ancillary Coding Schemes'
BEGIN
	IF @Code = 'Free Text'
	BEGIN
		SET @ValidValues = 'the names of code in Ancillary Coding Standard.'
		DECLARE @ancode varchar(50) 
		DECLARE @intPosition int 
		 
		SET @Value = LTRIM(RTRIM(@Value)) + ',' 
		SET @intPosition = CHARINDEX(',', @Value, 1) 
		 
		IF REPLACE(@Value, ',', '') <> '' 
		BEGIN 
			WHILE @intPosition > 0 
			BEGIN 
				SET @ancode = LTRIM(RTRIM(LEFT(@Value, @intPosition - 1))) 
				IF @ancode <> '' 
				BEGIN 
				    IF NOT EXISTS (SELECT 1 FROM [CV3AncillaryCodingStd] WHERE Code = @ancode)
					BEGIN
						SET @Value = @ancode
						GOTO InvalidValue
					END
				END 
				SET @Value = RIGHT(@Value, LEN(@Value) - @intPosition) 
				SET @intPosition = CHARINDEX(',', @Value, 1) 
			END 
		END 
	END
END
ELSE IF @HierarchyCode = 'Surgery|Case Details'
BEGIN
   IF @Code = 'AutoSave Interval Minutes'
   BEGIN
      SET @ValidValues = 'a number between 0 and 60'
      IF ISNUMERIC(@Value)= 1 AND (@Value >= 0 and @Value <= 60)
         RETURN 0
      ELSE
         GOTO InvalidValue   
   END
   ELSE IF @Code = 'Mandatory Delay Reason Minimum Minutes'
   BEGIN
      SET @ValidValues = 'a number between 0 and 120'
      IF ISNUMERIC(@Value)= 1 AND (@Value >= 0 and @Value <= 120)
         RETURN 0
      ELSE
         GOTO InvalidValue  
   END
END
ELSE IF @HierarchyCode = 'Surgery|Scheduling'
BEGIN
   IF @Code = 'Generic Surgical Procedure Name'
   BEGIN
      SET @ValidValues = 'an active procedure in the Procedures dictionary'
      IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' ) OR EXISTS (SELECT 1 FROM SXASRGProcedure WHERE Name = @Value AND Active = 1)        
         Return(0)
      ELSE
         Goto InvalidValue 
   END
   ELSE IF @Code = 'Procedure Info MLM Name'
   BEGIN
      SET @ValidValues = 'the name of an MLM that has a status of production'
      IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' ) OR EXISTS (SELECT 1 FROM CV3MLM WHERE Name = @Value AND Active = 1 AND Status = 4)        
         Return(0)
      ELSE
         Goto InvalidValue  
   END
END

-- for validate ICD10 Effective date
Else if @HierarchyCode = 'RevenueCycleMgmt'
begin
	if @Code ='ICD10EffectiveDate'
			  
	begin
			if @Value='' or @Value is null
			return 0
			else
			begin
			 if ISDATE (@value)=1
			 begin
				 if CONVERT (datetime,@Value) < CONVERT (date,GETDATE())
				 begin
					set @ValidValues ='ICD10 Effective date should be greater than or equal to current date.'
					GOTO InvalidValue
				 end
				 else 
					 return 0
			 end
			 else
			 begin
				set @ValidValues ='enter valid ICD10 Effective date.'
				goto InvalidValue
			 end
			 end

	end
end

ELSE IF (@HierarchyCode = 'DataXchg' )
BEGIN
    IF ( @Code in ( 'EnableAutoReconciliation' ))
    BEGIN
        SET @ValidValues = 'Yes or No'
		IF @Value in ('Yes', 'No')
            RETURN 0
        ELSE
            GOTO InvalidValue
    END
    IF ( @Code in ( 'PurgeAfterDays'))
	BEGIN
		SET @ValidValues = 'a number between 30 and 999 inclusive'
		IF ISNUMERIC(@Value)= 1 AND ( @Value >= 30 AND @Value <= 999 )
			Return(0)
		Else
			Goto InvalidValue
	END
END
ELSE IF (@HierarchyCode = 'DataXchg|Labels' )
BEGIN
    IF ( @Code in ( 'LabelCurrentInfoList' ))
    BEGIN
		SET @ValidValues = '25 characters or less in length'
		IF @Value IS NULL OR Len(@Value) < 26
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF (@HierarchyCode = 'DataXchg|Health Issue|Inbound' )
BEGIN
    IF ( @Code in ( 'ValidPrimaryCodingSystem' ))
    BEGIN
		SET @ValidValues = 'all types must be valid in coded health issue types dictionary'
        IF ((Select Count(*)
            From SXAGNSplitDelimitedStringTblFn(@Value, ',') s
            Left Join (Select Code from CV3CodedHealthIssueType) c on s.item = c.Code
            Where Code is null) <= 0)
            Return(0)
		ELSE
			Goto InvalidValue
    END
    IF ( @Code in ( 'UseResolvedStatus' ))
    BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value IN ('TRUE', 'FALSE')
			Return(0)
		ELSE
			Goto InvalidValue
    END
    IF ( @Code in ( 'DefaultCurrentStatus' ))
    BEGIN
        SET @ValidValues = 'an active entry in the health issue status dictionary that is not a closed status'
        IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' )
            OR @Value IN (SELECT Code from CV3HealthIssueStatus WHERE Active = 1 and IsClosed = 0)
            OR NOT EXISTS (SELECT * FROM CV3HealthIssueStatus WHERE Active = 1 and IsClosed = 0)
            Return(0)
        ELSE
            Goto InvalidValue
    END
    IF ( @Code in ( 'DefaultResolvedStatus' ))
    BEGIN
        SET @ValidValues = 'an active entry in the health issue status dictionary that is a closed status'
        IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' )
            OR @Value IN (SELECT Code from CV3HealthIssueStatus WHERE Active = 1 and IsClosed = 1)
            OR NOT EXISTS (SELECT * FROM CV3HealthIssueStatus WHERE Active = 1 and IsClosed = 1)
            Return(0)
        ELSE
            Goto InvalidValue
    END
    IF ( @Code in ( 'DefaultCodingScheme' ))
    BEGIN
        SET @ValidValues = 'an active entry in the coded health issue dictionary'
        IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' )
            OR @Value IN (SELECT Code from CV3CodedHealthIssueType WHERE Active = 1)
            OR NOT EXISTS (SELECT * FROM CV3CodedHealthIssueType WHERE Active = 1)
            Return(0)
        ELSE
            Goto InvalidValue
    END
    IF ( @Code in ( 'DefaultHealthIssueType', 'DefaultResolvedHealthIssueType', 'ActiveSocialHealthIssueType', 'ClosedSocialHealthIssueType' ))
    BEGIN
        SET @ValidValues = 'an active entry in the health issue type dictionary'
        IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' )
            OR @Value IN (SELECT Code from CV3HealthIssueType WHERE Active = 1)
            OR NOT EXISTS (SELECT * FROM CV3HealthIssueType WHERE Active = 1)
            Return(0)
        ELSE
            Goto InvalidValue
    END
END
ELSE IF (@HierarchyCode = 'DataXchg|Exchange Documents|Outbound' )
BEGIN
    IF ( @Code in ( 'ExcludeNonCoded' ))
    BEGIN
        SET @ValidValues = 'a comma separated list of valid values: Problems, Allergies, Medications'
		
		Declare @tbValidValues table (Value varchar(max))
		insert into @tbValidValues (Value)	values  ('Problems') , ('Allergies'), ('Medications')
		-- The remaining value list is empty, or it matches the default value
		IF EXISTS (
				SELECT t.* FROM dbo.SXAGNSplitDelimitedStringTblFn(@value, ',') AS t
				WHERE NOT EXISTS (SELECT Value FROM @tbValidValues WHERE Value = t.item )
			)
			Goto InvalidValue;
    END
END
ELSE IF (@HierarchyCode = 'DataXchg|Allergy' )
BEGIN
    IF ( @Code in ( 'DefaultAllergenType' ))
    BEGIN
		SET @ValidValues = 'an active entry in Allergen Type dictionary'
        IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' )
            OR @Value IN ( Select Code From CV3AllergenType WHERE Active = 1) 
          	OR NOT EXISTS ( SELECT * FROM CV3AllergenType WHERE Active = 1)
			Return(0)
		ELSE
			Goto InvalidValue	
    END
    IF ( @Code in ( 'DefaultSeverityValue' ))
    BEGIN
        SET @ValidValues = 'an active Allergy Reaction Severity code'
        IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' )
            OR @Value IN (SELECT Code from CV3AllergyReactionSeverity WHERE Active = 1)
            OR NOT EXISTS (SELECT * FROM CV3AllergyReactionSeverity WHERE Active = 1)
            Return(0)
        ELSE
            Goto InvalidValue
    END
END
ELSE IF (@HierarchyCode = 'DataXchg|Allergy|Outbound' )
BEGIN
    IF ( @Code in ( 'IncludeAdverseEvents', 'IncludeIntollerances' ))
    BEGIN
        SET @ValidValues = 'Yes or No'
		IF @Value in ('Yes', 'No')
            RETURN 0
        ELSE
            GOTO InvalidValue
    END
END
ELSE IF (@HierarchyCode = 'DataXchg|Medication|Inbound' )
BEGIN
    IF ( @Code in ( 'ImportPotentialDuplicates' ))
    BEGIN
        SET @ValidValues = 'Yes or No'
		IF @Value in ('Yes', 'No')
            RETURN 0
        ELSE
            GOTO InvalidValue
    END  
END
ELSE IF (@HierarchyCode = 'DataXchg|Patient' )
BEGIN
    IF ( @Code in ( 'SocialSecurityIDType', 'PatientIDType' ))
    BEGIN
        SET @ValidValues = 'an active valid Patient ID Type'
        IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' )
            OR @Value IN (SELECT Code FROM CV3ClientIDType WHERE Active = 1)
            OR NOT EXISTS (SELECT * FROM CV3ClientIDType WHERE Active = 1)
            Return(0)
        ELSE
            Goto InvalidValue
    END
    IF ( @Code in ( 'PatientIDFillChar' ))
    BEGIN
        SET @ValidValues = 'a single aphanumeric character'
        IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' )
            OR LEN( @VALUE ) = 1
            RETURN 0
        ELSE
            GOTO InvalidValue
    END
    IF ( @Code in ( 'PatientIDFillLength' ))
  BEGIN
        SET @ValidValues = '0 to 20'
        IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' )
            OR ISNUMERIC(@VALUE)= 1 AND (@Value >= 0) AND (@Value <= 20)
            RETURN 0
        ELSE
            GOTO InvalidValue
    END
END
ELSE IF (@HierarchyCode = 'DataXchg|Documents' )
BEGIN
    IF ( @Code in ( 'CategoryCodingStandard' ))
    BEGIN
        SET @ValidValues = 'an active Ancillary Coding Standard'
        IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' )
            OR @Value IN (SELECT Code from CV3AncillaryCodingStd WHERE Active = 1)
            OR NOT EXISTS (SELECT * FROM CV3AncillaryCodingStd WHERE Active = 1)
            Return(0)
        ELSE
            Goto InvalidValue
    END
    IF ( @Code in ( 'DefaultRequestDuration' ))
    BEGIN
        SET @ValidValues = 'a number greater than zero'
        IF ISNUMERIC(@VALUE)= 1 AND (@Value > 0)
            RETURN 0
        ELSE
            GOTO InvalidValue
    END
END
ELSE IF (@HierarchyCode = 'HL7 Interfaces|Send Lab Results' )
BEGIN
    IF ( @Code in ( 'RecvProviderIDType' ))
    BEGIN
        SET @ValidValues = 'an active valid Provider ID Type'
        IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' )
            OR @Value IN (SELECT Code FROM CV3ProviderIDType WHERE Active = 1)
            OR NOT EXISTS (SELECT * FROM CV3ProviderIDType WHERE Active = 1)
            Return(0)
        ELSE
            Goto InvalidValue
    END
	ELSE IF @Code = 'SendSingleNTESegment'
	BEGIN
		SET @ValidValues = 'Yes or No'
		IF @Value = @HVCValue OR @Value in ('Yes','No')
			Return 0
		ELSE
			GOTO InvalidValue
	END
END
ELSE IF (@HierarchyCode = 'HL7 Interfaces|Health Issue' )
BEGIN
    IF ( @Code = 'Inbound Auto Code Mapping' )
    BEGIN
		SET @ValidValues = 'a comma-delimited list of health issue type'

		IF @Value IS NULL
				Return (0)
		Else IF @Value =''
				Return (0)
		Else IF ((Select Count(*)
				From SXAGNSplitDelimitedStringTblFn(@Value, ',') s
				Left Join (Select Code from CV3HealthIssueType) c on s.item = c.Code
				Where Code is null) <= 0)
				Return (0)
		Else 
			Goto InvalidValue
    END
END
ELSE IF (@HierarchyCode = 'InfoButton|Ancillary Code Type' )
BEGIN
    IF ( @Code in ( 'Lab Tests', 'Vital Signs' ))
    BEGIN
		-- CodeType
		-- When there are more code types, SNOMEDCT, 
		-- Add more code type variables, 
		-- 
		
		DECLARE @codeTypeTbl TABLE
		(
			ind int identity,
			Code varchar(50),
			CodeType varchar(50) 
		);


		INSERT INTO @codeTypeTbl (Code, CodeType)
		VALUES 
			-- Add more code types for each code in the (@Code, @CodeType)
			('Lab Tests', 'LOINC'),
			('Vital Signs', 'LOINC') ,
			('Vital Signs', 'SNOMEDCT')
			;

        SET @ValidValues = 'a comma separated list of valid code in Ancillary Coding Standard^CodeType ' +
			'where CodeType is one of the following: ' +
			(SELECT CodeType + '; ' AS [text()] FROM @codeTypeTbl WHERE Code=@Code FOR XML PATH('')  )		
		
		DECLARE @AncCoPair varchar(80);
		DECLARE @AncillaryCode varchar(30);
		DECLARE @CodeType varchar(50);
		DECLARE @CaretPos int;
		DECLARE @ValueList varchar(255);


		SET @ValueList = @Value;
		SET @CaretPos = PATINDEX('%^%', @ValueList);

		WHILE @CaretPos <> 0
		BEGIN
			SET @AncillaryCode = LEFT(@ValueList, @CaretPos - 1);			
			SET @CommaPos = CHARINDEX(',', @ValueList);

			IF @CommaPos <> 0
			BEGIN
				SET @CodeType = SUBSTRING(@ValueList, @CaretPos + 1, @CommaPos - 1 - @CaretPos);
				SET @ValueList = RIGHT(@ValueList, LEN(@ValueList) - @CommaPos)
			END
			ELSE
			BEGIN
				SET @CodeType = SUBSTRING(@ValueList, @CaretPos + 1, LEN(@ValueList) - @CaretPos);
				SET	@ValueList = '';		
			END

			IF NOT EXISTS (
							SELECT 1 
							FROM CV3AncillaryCodingStd a
								INNER JOIN @codeTypeTbl c ON c.Code = @Code -- filter the table based on Environment Profile Code Entry
							WHERE	a.Code = LTRIM(RTRIM(@AncillaryCode)) AND
									c.CodeType = LTRIM(RTRIM(@CodeType)))
				Goto InvalidValue;

			SET @CaretPos = PATINDEX('%^%', @ValueList);
		END

		IF @CaretPos = 0
		BEGIN
			-- The remaining value list is empty, or it matches the default value
			IF ISNULL( LTRIM(RTRIM(@ValueList)), '' ) in ('', ISNULL( @HVCValue, '' ))
				RETURN (0);
			ELSE
				Goto InvalidValue;
		END

    END
END
ELSE IF (@HierarchyCode = 'InfoButton' )
BEGIN
	IF @Code = 'Allow Sharing for Any Info Vendor'
	BEGIN
		SET @ValidValues = 'TRUE or FALSE'
		IF @Value IN ('TRUE', 'FALSE')
			Return (0)
		ElSE 
			Goto InvalidValue
	END
END
ELSE IF (@HierarchyCode = 'DataXchg|Exchange Documents|Outbound|Orders' )
BEGIN
    IF ( @Code in ( 'PrimaryCodeStandard', 'AlternateCodeStandard' ))
    BEGIN
        SET @ValidValues = 'an active Ancillary Coding Standard'
        IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' )
            OR @Value IN (SELECT Code from CV3AncillaryCodingStd WHERE Active = 1)
            OR NOT EXISTS (SELECT * FROM CV3AncillaryCodingStd WHERE Active = 1)
            Return(0)
        ELSE
            Goto InvalidValue
    END
     
	IF ( @Code in ( 'IncludePendingStatus', 'IncludeCompletedStatus' ))
    BEGIN
        IF (@Code = 'IncludePendingStatus')
           SET @ValidValues = 'a comma-delimited list of order status level numbers that are < 55.'
        ELSE
           SET @ValidValues = 'a comma-delimited list of order status level numbers that are >= 55.'

        IF (LEN(RTRIM(@Value)) > 0)
        BEGIN
            DECLARE @VaildLevelNumbers TABLE(LevelNumber varchar(10))

            INSERT INTO @VaildLevelNumbers(LevelNumber)
            SELECT DISTINCT CAST(levelnumber as varchar(25)) FROM CV3OrderStatus
   
            DECLARE @SpecifiedLevelNumbers TABLE(LevelNumber varchar(25)) 
            INSERT INTO @SpecifiedLevelNumbers(LevelNumber)
            SELECT Item FROM dbo.SXAGNSplitDelimitedStringTblFn(@Value, ',')

            IF NOT EXISTS (SELECT 1 FROM @SpecifiedLevelNumbers)
         		 GOTO InvalidValue

            IF EXISTS (
               SELECT sln.LevelNumber FROM @SpecifiedLevelNumbers sln
               WHERE NOT EXISTS (SELECT vln.LevelNumber FROM @VaildLevelNumbers vln WHERE sln.LevelNumber = vln.LevelNumber )
            )	        	
               GOTO InvalidValue         
            ELSE
            BEGIN	
               IF (@Code = 'IncludePendingStatus')	 
               BEGIN
		          IF EXISTS (SELECT 1 FROM @SpecifiedLevelNumbers WHERE CAST(LevelNumber as int) >= 55)
                     GOTO InvalidValue		  
               END
               ELSE
               BEGIN
                  IF EXISTS (SELECT 1 FROM @SpecifiedLevelNumbers WHERE CAST(LevelNumber as int) < 55)
                     GOTO InvalidValue		  
               END
              
               IF EXISTS (SELECT 1 FROM @SpecifiedLevelNumbers GROUP BY LevelNumber HAVING (COUNT(LevelNumber) > 1))
               BEGIN    
                  SET @ValidValues = @ValidValues + ' Duplicate level numbers have been entered.'
                  GOTO InvalidValue	   
               END
            END
        END
    END
	IF ( @Code in ( 'BodySiteUserDefinedDataItems1', 'BodySiteUserDefinedDataItems2', 'BodySiteUserDefinedDataItems3', 'BodySiteUserDefinedDataItems4', 'BodySiteUserDefinedDataItems5' ))
    BEGIN
        SET @ValidValues = 'a comma-delimited list of user defined data items'

        DECLARE @ValidDataItemCodes TABLE(DataItemCode varchar(40))

        INSERT INTO @ValidDataItemCodes(DataItemCode)
        SELECT DISTINCT Code FROM CV3DataItem
         		 
		IF EXISTS (
              SELECT dataItemCodes.* FROM dbo.SXAGNSplitDelimitedStringTblFn(@Value, ',') AS dataItemCodes
              WHERE NOT EXISTS (SELECT DataItemCode FROM @ValidDataItemCodes WHERE DataItemCode = dataItemCodes.item )
           )
           Goto InvalidValue
    END
END
ELSE IF (@HierarchyCode = 'DataXchg|Exchange Documents|Outbound|Results' )
BEGIN
    IF ( @Code in ( 'PrimaryCodeStandard', 'AlternateCodeStandard' ))
    BEGIN
        SET @ValidValues = 'an active Ancillary Coding Standard'
        IF ISNULL( @Value, '' ) = ISNULL( @HVCValue, '' )
            OR @Value IN (SELECT Code from CV3AncillaryCodingStd WHERE Active = 1)
            OR NOT EXISTS (SELECT * FROM CV3AncillaryCodingStd WHERE Active = 1)
            Return(0)
        ELSE
            Goto InvalidValue
    END     
END
ELSE IF (@HierarchyCode = 'DataXchg|Exchange Documents|Outbound|Medications' )
BEGIN
    IF (@Code = 'AppendMemo')
    BEGIN
      SET @ValidValues = '0=Do not append, 1=Append for PRN Only, 2=Always append'
		IF @Value IN ('0', '1', '2')
         RETURN(0)
      ELSE
         GOTO InvalidValue        
    END 
    IF (@Code = 'IncludeMedicationStatus')
    BEGIN
      SET @ValidValues = 'a comma-delimited list of medication statuses. Valid values: Active, Inactive, Discontinued, Cancelled, Unapproved, EnteredInError, NoLongerTaking, Completed.'
      IF EXISTS (
         SELECT s.* FROM dbo.SXAGNSplitDelimitedStringTblFn(@value, ',') AS s
         WHERE NOT EXISTS (SELECT 1 FROM CV3EnumReference 
                           WHERE TableName = 'SXAAMBClientPrescription' 
                              AND ColumnName = 'StatusType' 
                              AND ReferenceString = s.item )
         )
         GOTO InvalidValue;		       
    END            
END
ELSE IF (@HierarchyCode = 'DataXchg|Exchange Documents|Outbound|Immunizations' )
BEGIN
    IF (@Code = 'IncludeImmunizationStatus')
    BEGIN
      SET @ValidValues = 'a comma-delimited list of immunizations statuses. Valid values: Completed, Invalid, Not Completed.'
      IF LEN(RTRIM(@Value)) > 0 AND EXISTS (
         SELECT s.* FROM dbo.SXAGNSplitDelimitedStringTblFn(@value, ',') AS s
         WHERE NOT EXISTS (SELECT 1 FROM CV3EnumReference 
                           WHERE TableName = 'SXAHMScheduledEventOccurrence' 
                              AND ColumnName = 'OccurrenceStatusType' 
                              AND ReferenceString = s.item )
         )
         GOTO InvalidValue;		       
    END            
END
ELSE IF (@HierarchyCode = 'DataXchg|Exchange Documents|Outbound|VisitMedications' )
BEGIN    
	IF ( @Code in ( 'IncludeAdministeredStatus', 'IncludeNotAdministeredStatus' ))
    BEGIN
        SET @ValidValues = 'a comma-delimited list of order status level numbers.'

        IF (LEN(RTRIM(@Value)) > 0)
        BEGIN
            --DECLARE @VaildLevelNumbers TABLE(LevelNumber varchar(10))

            INSERT INTO @VaildLevelNumbers(LevelNumber)
            SELECT DISTINCT CAST(levelnumber as varchar(25)) FROM CV3OrderStatus
   
            --DECLARE @SpecifiedLevelNumbers TABLE(LevelNumber varchar(25)) 
            INSERT INTO @SpecifiedLevelNumbers(LevelNumber)
            SELECT Item FROM dbo.SXAGNSplitDelimitedStringTblFn(@Value, ',')

            IF NOT EXISTS (SELECT 1 FROM @SpecifiedLevelNumbers)
         		 GOTO InvalidValue

            IF EXISTS (
               SELECT sln.LevelNumber FROM @SpecifiedLevelNumbers sln
               WHERE NOT EXISTS (SELECT vln.LevelNumber FROM @VaildLevelNumbers vln WHERE sln.LevelNumber = vln.LevelNumber )
            )	        	
               GOTO InvalidValue         
            ELSE
            BEGIN	              
               IF EXISTS (SELECT 1 FROM @SpecifiedLevelNumbers GROUP BY LevelNumber HAVING (COUNT(LevelNumber) > 1))
               BEGIN    
                  SET @ValidValues = @ValidValues + ' Duplicate level numbers have been entered.'
                  GOTO InvalidValue	   
               END
            END
        END
    END
END
ELSE IF @HierarchyCode = 'Client Info|NKDA Upgrade'
BEGIN
	IF @Code = 'Upgrade Patient Chart'
	BEGIN
		SET @ValidValues = 'Yes or No'
		IF ISNULL(@Value,'') IN ('','Yes','No')
			Return (0)
		Else 
			Goto InvalidValue
	END	
END

Return 0
	
InvalidValue:
	SET @ErrorText = 'Value of "' + ISNULL(@Value,'') + '" is invalid for ' + @Code  + ' in ' + @DisplayHeirarchyCode 
    IF @ValidValues is NOT NULL 
	BEGIN
		IF ( @HierarchyCode = 'Connect' 
				AND @Code IN ('TimeFormat', 'CompositeDateFormat', 'DateEntryFormat', 'DateFormat', 
							  'DateStampFormat', 'PartialCompositeDateFormat') )
			OR ( @HierarchyCode = 'Worklists' AND @Code = 'Worklist Birth Date Label Text' )
		BEGIN
			SET @ErrorText = @ErrorText + ' - ' + @ValidValues
		END
		ELSE IF (@HierarchyCode = 'Registration|ForeignSearch' AND @Code = 'ForeignID')
			BEGIN
				SET @ErrorText = 'Value of "' + @Value + '" is an invalid entry. ' + @ValidValues
			END
		ELSE
		BEGIN
			SET @ErrorText = @ErrorText + ' - must be ' + @ValidValues
		END
	END
	RAISERROR (@ErrorText,16,1)

GO
/* P r o p r i e t a r y  N o t i c e */
/*
Confidential and proprietary information of Allscripts Healthcare, LLC.  and/or its affiliates. Authorized users
only. Notice to U.S. Government Users: This software is “Commercial Computer Software.” Subject to full notice set
forth herein.
*/
/* P r o p r i e t a r y  N o t i c e */
