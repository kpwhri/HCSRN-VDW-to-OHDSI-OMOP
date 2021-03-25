# HCSRN-VDW-to-OHDSI-OMOP
This project translates data from an HCSRN-VDW into an OHDSI-OMOP common data model using SAS.


## Prerequisites
### An HCSRN VDW Common Data Model

### Membership in OHDSI
- Find information on how to become a member in [The Book of OHDSI](https://ohdsi.github.io/TheBookOfOhdsi/WhereToBegin.html).

### The ability to download the OHDSI OMOP Vocabulary files
- If you can connect with OHDSI OMOP Vocabulary by going to [Athena](https://athena.ohdsi.org/vocabulary/list) then you have the ability to get OHDSI OMOP Vocabulary data.

## Implementation Directions
1. Clone HCSRN-VDW-to-OHDSI-OMOP ... this project
2. Download OHDSI OMOP Vocabulary from Athena
   1. Unzip the CSV files into the omop_vocab folder
3. Edit Runtime Parameter Variables
   1. Save the file "./sas_etl/0-edit-run-main.sas" to "0-run-main.sas"
   2. Edit the file "./sas_etl/0-run-main.sas" to use your local settings
   3. Edit the file "./sas_etl/rcm_std_vars.sas" to point to local VDW
	  * If just trying to create the Research Code Management files then leave settings as they are and comment out the last two files (load OMOP and load OMOP Era).
4. Run the file "0-run-main.sas" that you have edited.
