##################################################################
# Name: Create_Clin_Metadata.R
# Author: Ryan Johnson
# Date Created: 6 July, 2018
# Purpose: Extract data from the Merged TrEAT DB and compile into 
#          clean tidy format that can be appended to data files
##################################################################

library(tidyverse)
library(readxl)

## Read in TrEAT and Clean ----------------------------------------------

# Read in TrEAT DB
treat <- read_excel("data/raw/TrEAT_Merge_2018.06.27.XLSX")

# Import data that explains treat column names
treat_explain <- read_excel("data/raw/TrEAT_Merge_DataDictionary_2018.06.27.XLSX")

# Remove spaces from truncated study ID
treat_explain <- treat_explain %>% 
  mutate(`Truncated Study ID` = gsub(" ", "_", `Truncated Study ID`)) %>% 
  mutate(`Truncated Study ID` = gsub("\\/", "_", `Truncated Study ID`)) %>%
  mutate(`Truncated Study ID` = gsub("\\(", "", `Truncated Study ID`)) %>%
  mutate(`Truncated Study ID` = gsub("\\)", "", `Truncated Study ID`))

# Ensure all colnames in treat match the values in treat_explain
foo <- tibble(STUDY_ID_TRUNC = colnames(treat[-1])) %>% 
  full_join(., treat_explain, by = "STUDY_ID_TRUNC")

# Check if labels match
ifelse(nrow(foo) == ncol(treat[,-1]), "Clear", stop("labels don't match"))

# Assign explanations to columns
colnames(treat) <- c("STUDY_ID", foo$`Truncated Study ID`)

# Clean
rm(treat_explain, foo)




## Create Clinical Metadata Table ------------------------------

################################################
# As more clinical data becomes relevant, must 
# add it to the treat_clin
# tibble, then recode it below (if necessary)
################################################

# Extract relevant columns from treat DB
treat_clin <- treat %>% 
  select(STUDY_ID, 
         
         # Diarrhea and Fever
         Diarrhea_classification,
         Fever_present_at_presentation,
         
         # Stool
         Maximum_number_of_loose_liquid_stools_in_any_24_hours_prior_to_presentation, 
         Number_of_loose_liquid_stools_in_last_8_hours_prior_to_presentation, 
         Number_of_loose_liquid_stools_since_the_start_of_symptoms_prior_to_presentation,
         
         # Impact on activity
         Impact_of_illness_on_activity_level, 
         
         # Vomit
         Vomiting_present, 
         Number_of_vomiting_episodes,
         
         # Ab Cramps and Gas
         Abdominal_cramps_present_at_presentation, 
         Excesssive_gas_flatulence_present_at_presentation,
         
         # Nausea
         Nausea_present_at_presentation, 
         
         # Stool passing pain
         Ineffective_and_or_paiful_straining_to_pass_a_stool_at_presentation,
         
         # Tenesmus
         Tenesmus_present_at_presentation,
         
         # Malaise
         Malaise_present_at_presentation,
         
         # Incontenent / Constipation
         Fecal_incontinence_present_at_presentation,
         Constipation_present_at_presentation,
         
         # Other Symptoms
         Other_symptom_present_at_presentation,
         
         # Time from admittance to last unformed stool
         Time_to_last_unformed_stool,
         
         # Treatment
         Treatment,
         
         # Time to cure
         Time_to_cure,
         
         # Gross blood in stool
         Gross_blood_in_stool,
         
         # Occult blood test
         Occult_blood_result)




# Recode to make more legible
treat_clin <- treat_clin %>% 
  
  mutate(Diarrhea_classification = 
           ifelse(Diarrhea_classification == 1, "AWD", "Febrile")) %>%
  
  mutate(Fever_present_at_presentation = 
           ifelse(Fever_present_at_presentation == 0, "No", 
                  ifelse(Fever_present_at_presentation == 1, "Yes", NA))) %>%
  
  mutate(Vomiting_present =
           ifelse(Vomiting_present == 0, "No", 
                  ifelse(Vomiting_present == 1, "Yes", NA))) %>%
  
  mutate(Abdominal_cramps_present_at_presentation = 
           ifelse(Abdominal_cramps_present_at_presentation == 0, "No",
                  ifelse(Abdominal_cramps_present_at_presentation == 1, "Yes", NA))) %>%
  
  mutate(Excesssive_gas_flatulence_present_at_presentation = 
           ifelse(Excesssive_gas_flatulence_present_at_presentation == 0, "No",
                  ifelse(Excesssive_gas_flatulence_present_at_presentation == 1, "Yes", NA))) %>%
  
  mutate(Nausea_present_at_presentation =
           ifelse(Nausea_present_at_presentation == 0, "No", 
                  ifelse(Nausea_present_at_presentation == 1, "Yes", NA))) %>%
  
  mutate(Ineffective_and_or_paiful_straining_to_pass_a_stool_at_presentation = 
           ifelse(Ineffective_and_or_paiful_straining_to_pass_a_stool_at_presentation == 0, "No",
                  ifelse(Ineffective_and_or_paiful_straining_to_pass_a_stool_at_presentation == 1, "Yes", NA))) %>%
  
  mutate(Tenesmus_present_at_presentation =
           ifelse(Tenesmus_present_at_presentation == 0, "No",
                  ifelse(Tenesmus_present_at_presentation == 1, "Yes", NA))) %>%
  
  mutate(Malaise_present_at_presentation = 
           ifelse(Malaise_present_at_presentation == 0, "No", 
                  ifelse(Malaise_present_at_presentation == 1, "Yes", NA))) %>%
  
  mutate(Fecal_incontinence_present_at_presentation = 
           ifelse(Fecal_incontinence_present_at_presentation == 0, "No",
                  ifelse(Fecal_incontinence_present_at_presentation == 1, "Yes", NA))) %>%
  
  mutate(Constipation_present_at_presentation =
           ifelse(Constipation_present_at_presentation == 0, "No", 
                  ifelse(Constipation_present_at_presentation == 1, "Yes", NA))) %>%
  
  mutate(Other_symptom_present_at_presentation = 
           ifelse(Other_symptom_present_at_presentation == 0, "No", 
                  ifelse(Other_symptom_present_at_presentation == 1, "Yes", NA))) %>%
  
  mutate(Occult_blood_result =
           ifelse(Occult_blood_result == "N/A", NA, Occult_blood_result))




## Write to processed data ---------------------------------
write_csv(treat_clin, "data/processed/TrEAT_Clinical_Metadata_tidy.csv")
