server <- function(input, output) {
  count_data <- reactive({
    inFile <- input$countData
    if (is.null(inFile)) {
      return(NULL)
    }
    Cdata <- read.table(inFile$datapath, header = TRUE, row.names = NULL)
    colnames(Cdata)[1] = "genes"
    return(Cdata)
  })
  
  
  sample_data <- reactive({
    inFile <- input$sampleData
    if (is.null(inFile)) {
      return(NULL)
    }
    Sdata <- read.table(inFile$datapath, header = TRUE)
    colnames(Sdata)[1] = "sample"
    colnames(Sdata)[2] = "Experiment"
    return(Sdata)
  })
  
  # all_batchs <- reactive({
  # unique(sample_data()$Experiment)
  # })
  
  # output$Choose_Batch <- renderUI({
  # selectInput("Batch", "Choose Experimental Batch:", choices = all_batchs(), selected = all_batchs()[1])
  # })
  
  
  filtered_sample_data <- reactive({
    # sub_sample = subset(sample_data(), Experiment == input$Batch)
    sub_sample = sample_data()
    sub_sample$Group <- apply(sub_sample[,c('Treatment', 'Condition', 'DaysPostInfection')], 1, function(row) {
      paste(row, collapse = "_")
    })
    sub_sample$Group <- as.factor(sub_sample$Group)
    return(sub_sample)
  })
  
  filtered_count_data <- reactive({
    all_samples = unique(filtered_sample_data()$sample)
    count_data()[, c("genes", all_samples)]
  })
  
  
  all_levels <- reactive({
    levels(filtered_sample_data()$Group)
  })
  
  
  output$Contrasts1_UI_Simple <- renderUI({
    selectInput("Contrasts1", "Choose Contrasts One:", choices = all_levels(), selected = all_levels()[1])
  })
  
  output$Contrasts2_UI_Simple <- renderUI({
    selectInput("Contrasts2", "Choose Contrasts Two:", choices = all_levels(), selected = all_levels()[2])
  })
  
  output$Contrasts1_UI_Diff <- renderUI({
    selectInput("Contrasts1_Diff", "Choose First Contrast (Difference 1):", choices = all_levels(), selected = all_levels()[1])
  })
  
  output$Contrasts2_UI_Diff <- renderUI({
    selectInput("Contrasts2_Diff", "Choose Second Contrast (Difference 1):", choices = all_levels(), selected = all_levels()[2])
  })
  
  output$Contrasts3_UI_Diff <- renderUI({
    selectInput("Contrasts3_Diff", "Choose First Contrast (Difference 2):", choices = all_levels(), selected = all_levels()[3])
  })
  
  output$Contrasts4_UI_Diff <- renderUI({
    selectInput("Contrasts4_Diff", "Choose Second Contrast (Difference 2):", choices = all_levels(), selected = all_levels()[4])
  })
  
  design <- reactive({
    d <- model.matrix(~ 0 + Group, data = filtered_sample_data())
    colnames(d) = all_levels()
    return(d)
  })
  
  v <- reactive({
    count = as.matrix(filtered_count_data()[-1])
    batch = filtered_sample_data()$Experiment
    batch_corrected <- ComBat_seq(counts = count, batch = batch)
    dge <- DGEList(counts = batch_corrected, genes = filtered_count_data()[, 1]) 
    dge <- calcNormFactors(dge) 
    keep <- filterByExpr(dge, design()) 
    dge <- dge[keep, ]
    v <- voom(dge, design(), plot = FALSE)
  })
  
  contrast_matrix <- reactive({
    if (input$contrastType == "Simple") {
      contrasts <- makeContrasts(
        contrasts = paste(input$Contrasts1, "-", input$Contrasts2),
        levels = design())
    } else {
      first_difference <- paste(input$Contrasts1_Diff, "-", input$Contrasts2_Diff)
      second_difference <- paste(input$Contrasts3_Diff, "-", input$Contrasts4_Diff)
      final_contrast <- paste("(", first_difference, ")", "-", "(", second_difference, ")")
      contrasts <- makeContrasts(
        contrasts = final_contrast,
        levels = design())
    }
    return(contrasts)
  })
  
  output$printContrastMatrix <- renderPrint({
    contrast_matrix()
  })
  
  output$printSignificantGenes <- renderPrint({
    fit <- lmFit(v(), design())
    fit2 <- contrasts.fit(fit, contrast_matrix())
    fit2 <- eBayes(fit2)
    result = topTable(fit2, n = Inf)
    top_genes = head(result,50)
    cat("Top 50 Significant Genes:\n")
    print(top_genes$genes)
  })
  
  output$downloadResults <- downloadHandler(
    filename = function() {
      "Differential Gene Expression Analysis Results.xlsx"
    },
    content = function(file) {
      fit <- lmFit(v(), design())
      fit2 <- contrasts.fit(fit, contrast_matrix())
      fit2 <- eBayes(fit2)
      result = topTable(fit2, n = Inf)
      write_xlsx(result, path = file)
    },
    contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  )
  
  output$volcanoPlot <- renderPlot({
    fit <- lmFit(v(), design())
    fit2 <- contrasts.fit(fit, contrast_matrix())
    fit2 <- eBayes(fit2)
    result = topTable(fit2, n = Inf)
    
    selected_pval <- input$pvalType
    if (selected_pval == "P.Value"){
      volcano <- ggplot(result, aes(x = logFC, y = -log10(P.Value))) +
        geom_point(aes(color = ((logFC > input$fcThreshold) & (-log10(P.Value) > input$pThreshold)) | 
                         ((logFC < -input$fcThreshold) & (-log10(P.Value) > input$pThreshold)))) +
        scale_color_manual(values = c("TRUE" = "red", "FALSE" = "black"),
                           labels = c("TRUE" = "Significant", "FALSE" = "Not Significant"),
                           name = "") +
        xlab("Log2 fold change") +
        ylab("-Log10 P-value")
    } 
    if (selected_pval == "adj.P.Val"){
      volcano <- ggplot(result, aes(x = logFC, y = -log10(adj.P.Val))) +
        geom_point(aes(color = ((logFC > input$fcThreshold) & (-log10(adj.P.Val) > input$pThreshold)) | 
                         ((logFC < -input$fcThreshold) & (-log10(adj.P.Val) > input$pThreshold)))) +
        scale_color_manual(values = c("TRUE" = "red", "FALSE" = "black"),
                           labels = c("TRUE" = "Significant", "FALSE" = "Not Significant"),
                           name = "") +
        xlab("Log2 fold change") +
        ylab("-Log10 Adjusted P-value")
    }
    
    if (input$show_pvalue_threshold) { 
      volcano <- volcano + geom_hline(yintercept = input$pThreshold, linetype = "dashed", col = "grey", size = 1)
    }
    
    
    if (input$show_logfc_threshold) { 
      volcano <- volcano + geom_vline(xintercept = c(input$fcThreshold, -input$fcThreshold), linetype = "dashed", col = "grey", size = 1)
    }
    
    if (selected_pval == "P.Value"){
      if (input$show_most_significant_genes) { 
        volcano <- volcano + geom_text(data = result[1:50,], aes(x = logFC, y = -log10(P.Value), label = genes), vjust = -1, size = 3, check_overlap = TRUE)
      }
    } 
    
    if (selected_pval == "adj.P.Val"){
      if (input$show_most_significant_genes) { 
        volcano <- volcano + geom_text(data = result[1:50,], aes(x = logFC, y = -log10(adj.P.Val), label = genes), vjust = -1, size = 3, check_overlap = TRUE)
      }
    }
    
    return(volcano)
  })
}
