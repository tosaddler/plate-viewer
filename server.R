library(shiny)
library(heatmaply)
library(data.table)
library(stringr)
library(tidyverse)

shinyServer(function(input, output) {
    
    # Sample file download
    output$downloadData <- downloadHandler(
        filename <- function() {
            paste("093016_2D_RG_Plat1_cor.csv")
        },
        content <- function(file) {
            file.copy("data/093016_2D_RG_Plat1_cor.csv", file)
        },    
        contentType = "text/csv"
    )
    
    # Imports selected dataset
    datasetInput <- reactive({
        validate(
            need(input$file1 != 0, "Please select a dataset")
        )
        inFile <- input$file1
        if (is.null(inFile)) return(NULL)
        df <- fread(inFile$datapath)
        
        # Add total read count row
        df_trc <- df %>%
                    select(-V1) %>%
                    summarize_all(funs(sum))
        df <- bind_rows(df, df_trc)
        df$V1[nrow(df)] <- "Total Read Counts"
        
        output$geneOutput <- renderUI({
            selectInput("geneInput", "Select a gene",
            sort(df$V1),
            selected = df[1,1])
        })
            
        df
    })
    
    # Takes a plate and a gene and reformats the data frame to resemble a 384-well plate
    plate.parse <- function(plate, gene) {
        names(plate) <- str_extract(names(plate), "...$")
        names(plate)[1] <- "V1"

        plate <- filter(plate, V1 == gene)

        for (i in LETTERS[1:16]) {
            temp <- select(plate, contains(i))
            names(temp) <- str_extract(names(temp), "[:digit:][:digit:]")
            row.names(temp) <- i

            if (!exists("master")) {
                master <- temp
            } else {
                master <- bind_rows(master, temp)
            }
        }
        
        master <- select_(master, "01", "02", "03", "04", "05", "06",
                                 "07", "08", "09", "10", "11", "12",
                                 "13", "14", "15", "16", "17", "18",
                                 "19", "20", "21", "22", "23", "24")
        row.names(master) <- LETTERS[1:16]
        return(master)
    }
    
    # Waits for a gene to be input then calls plate.parse
    gene.parse <- reactive({
        df <- datasetInput()        
        df <- plate.parse(df, input$geneInput)
        df
    })
    
    # Creates a list of available genes based on the data frame
    
        
    # Renders the heatmap
    output$heatmap <- renderPlotly({
        df <- gene.parse()        
        heatmaply(df, dendrogram = FALSE, margins = c(50, 50, NA, 0), limits = c(0, input$upperLimit), colors = cool_warm)
    })
})
