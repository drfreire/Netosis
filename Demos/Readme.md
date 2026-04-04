

======================== DEMO
This is a simple demo of the data analysis pipeline 
for Celigo well-level data.


1. Open the Example_Conditions and Example_Dataset csv 
   files. Observe that the Celigo well tabular format 
   data export has 15 rows of metadata before the 
   actual measurements, and that both the dataset and 
   condition files contain a "Well" Column. Close the
   files without saving.

2. Run the script in Celigo_Demo_Step1.Rmd, this will
   create a platemap using the ggplate library. It
   prompts the user to select the conditions csv.

3. Run the script in Celigo_Demo_Step2.Rmd. This 
   prepares the dataset by trimming the metadata,
   creating "index" columns, creating a "Source"
   column, and matching the Condition names to the 
   appropriate wells.

4. Celigo_Demo_Step3.Rmd creates a heat map using the 
   data.

5. Celigo_Demo_Step4.Rmd creates a box plot with a
   Wilcoxon rank-sum test (without correction).