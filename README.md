This is a Shiny app that provides an interactive analysis of RNA-seq data. It uses Limma-Voom for differential expression analysis and produces a volcano plot highlighting significant DE genes.

Given count and sample datasets, the app first conducts batch correction based on the 'Experiment' column in the sample dataset. After ensuring the data is free from batch effects, it applies the voom transformation to adjust the count data for linear modeling. Following this, a linear model is fitted using defined contrasts. The empirical Bayes (eBayes) method is then utilized to compute moderated statistics. Based on these results, the app identifies genes that are significantly differentially expressed.

To use the app, fetch it from Docker Hub and type the given commands in your terminal:

1. docker pull lizhiruijerry/limma_voom_app_repo:limma_voom_app_complex
2. docker run -d --rm -p 3838:3838 lizhiruijerry/limma_voom_app_repo:limma_voom_app_complex 
3. Open a browser and go to: http://localhost:3838

Example datasets are included. When launching the app, please upload the counts_mat.txt file to the "Upload count data" section and the samplesheet.txt file to the "Upload sample data" section. Inside the "more_datasets" folder, you'll find additional example datasets named sub_sample.txt and sub_count.txt.

Please note that while the app is running, you may encounter error warnings. However, rest assured that the app is fully functional and may take some time to produce the output plot.

To utilize the app effectively, please ensure the following:
1. Both the counts matrix and the sample sheet datasets are in .txt format.
2. The first column of the count dataset contains gene names.
3. Subsequent columns of the count dataset represent samples. 
4. The first column of the sample dataset contains sample names.
5. Each row in the first column of the sample dataset corresponds to the column names in the count dataset, starting from the second column.
6. The second column of the sample dataset indicates the batch or experiment group to which the sample belongs.
7. The sample dataset has three columns named "Treatment", "Condition", and "DaysPostInfection".

Here is an example of the count dataset:
<img width="966" alt="Screenshot 2023-09-13 at 2 57 36 AM" src="https://github.com/compbiocore/Shiny_App_Zhirui/assets/90368869/5ed3d30d-0c18-4b0b-afc0-e8f11373057f">

Here is an example of the sample dataset:
<img width="956" alt="Screenshot 2023-09-13 at 2 57 47 AM" src="https://github.com/compbiocore/Shiny_App_Zhirui/assets/90368869/fa83fdec-d43a-4d39-9d52-f0b15a1c1eae">

After successfully running the app (Shiny_All_Contrasts.Rmd), you will get results like this:

<img width="2550" alt="Screenshot 2023-12-02 at 4 33 32 AM" src="https://github.com/ZhiruiLi1/Limma_Voom_Shiny_CCV/assets/90368869/494c237a-e88a-43f7-9934-3b0d1a667e10">


There is another version of the app (Shiny_Customize_Contrasts.Rmd) where you can upload all the valid contrasts as a Txt file:

<img width="2553" alt="Screenshot 2023-12-02 at 4 35 27 AM" src="https://github.com/ZhiruiLi1/Limma_Voom_Shiny_CCV/assets/90368869/3bdfc197-00ed-4409-b02b-8a7c94a5606e">

