ui <- fluidPage(
  titlePanel("Volcano Plot for Gene Expression"),
  sidebarLayout(
    sidebarPanel(
      fileInput("countData", "Upload count data:", accept = c(".txt")),
      fileInput("sampleData", "Upload sample data:", accept = c(".txt")),
      
      radioButtons("contrastType", "Select Contrast Type:", 
                   choices = c("Simple", "Difference Between Differences"), selected = "Simple"),
      radioButtons("pvalType", "Select P-value Type:", choices = c("P.Value", "adj.P.Val"), selected = "P.Value"),
      
      downloadButton("downloadResults", "Download Results"),
      
      conditionalPanel(condition = "input.contrastType == 'Simple'",
                       uiOutput("Contrasts1_UI_Simple"), 
                       uiOutput("Contrasts2_UI_Simple")),
      conditionalPanel(condition = "input.contrastType == 'Difference Between Differences'",
                       uiOutput("Contrasts1_UI_Diff"), 
                       uiOutput("Contrasts2_UI_Diff"),
                       uiOutput("Contrasts3_UI_Diff"), 
                       uiOutput("Contrasts4_UI_Diff")),
      
      # uiOutput("Choose_Batch"),
      sliderInput("fcThreshold", "Log2 Fold change threshold:",
                  min = 0, max = 2, value = 1, step = 0.1),
      sliderInput("pThreshold", "-Log10 p-value threshold:",
                  min = 0, max = 2, value = 0.2, step = 0.1),
      
      checkboxInput("show_pvalue_threshold", "Show -Log10 P-value Threshold Line", value = TRUE),
      checkboxInput("show_logfc_threshold", "Show Log2 Fold Change Threshold Line", value = TRUE),
      checkboxInput("show_most_significant_genes", "Show Most Significant Genes Based on P-Value", value = TRUE)
    ),
    mainPanel(
      plotOutput("volcanoPlot"),
      verbatimTextOutput("printContrastMatrix"),
      verbatimTextOutput("printSignificantGenes")
    )      
  )
)