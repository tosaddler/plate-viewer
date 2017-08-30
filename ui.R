library(shiny)
library(data.table)
library(shinyHeatmaply)

fluidPage(

  titlePanel("384 Well Read Count Heatmap"),

  sidebarLayout(
    sidebarPanel(
        downloadButton("downloadData", label = "Download Sample Input File"),
        fileInput("file1", "Choose Data File",
                  multiple = FALSE,
                  accept = c(
                      "text/csv",
                      "text/comma-separated-values,text/plain",
                      ".csv"
                      )),
        
        # Gene input scans leftmost column in the dataset to render this list
        uiOutput("geneOutput"),
        numericInput("upperLimit", "Scale Upper Limit", value = 500, min = 0)
    ),
    mainPanel(
        plotlyOutput("heatmap")
    )
  ))
