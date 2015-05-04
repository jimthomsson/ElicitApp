

inv.logit=function(x){exp(x)/(1+exp(x))}

ppres=function(min,max,mean,beta.l,beta.r,vals=c(0:10)){
  range=min:max
  #beta.r=20-beta.r
  grad=ifelse(vals>=min & vals<=max,vals-mean,1000)
  grad=ifelse(grad!=1000,ifelse(grad<0,grad/(mean-min),grad/(max-mean)),grad)
  beta=ifelse(grad==1000,1,ifelse(grad<0,beta.l,beta.r))/5
  p=inv.logit(-beta*abs(grad))
  p/max(p)
  #return(c(p,min,max,mean,beta.l,beta.r))
}

#read scenario file
scenarios=read.csv("scenarios.csv",row.names=1,stringsAsFactors=F)

# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {
  output$barplot <- renderPlot({
    x=c(0:10)
    y=ppres(input$range[1],input$range[2],input$mean,input$beta.l,input$beta.r,x)
    # draw the histogram with the specified number of bins
    barplot(y[1:length(x)],names.arg=x,ylab="relative likelihood",yaxt="n",xlab="sites occupied",cex.lab=1.5)
    axis(2,labels=F)
  })
  
  output$mapit <- renderLeaflet({
    m=leaflet() %>% addTiles() %>% addTiles(urlTemplate = "http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",attribution="Tiles &copy Esri") 
    m%>% setView(lng=144.3, lat=-36.7, 6)
  })
  
  m=data.frame(matrix(ncol=nrow(scenarios),nrow=16));names(m)=rownames(scenarios)
  m[12:16,]=c(5,0,10,10,10)
  values=reactiveValues()
  values$df <- m
  
  index1=reactiveValues()
  index1$prevs=rep(NA,1000)
  
  
  #names(values$df)=paste0("s",1:5)
  newEntry <- observe({
    if(input$gonext > 0){
      goba1=input$goback1
      index=input$gonext-input$goback #
      clicknum=input$gonext+input$goback
      #index1<-index
      #output$progressBox <- renderValueBox({valueBox("no.", index1$prevs[clicknum-1])})
      #output$progressBox2 <- renderValueBox({valueBox("name", goba1)})
      if(index>nrow(scenarios)){index=nrow(scenarios)}
      sc.name=rownames(scenarios)[index]
      index1$prevs[clicknum]=sc.name
      
      newcol<- isolate(ppres(input$range[1],input$range[2],input$mean,input$beta.l,input$beta.r))
      slidervals<-isolate(c(input$mean,input$range[1],input$range[2],input$beta.l,input$beta.r))
      isolate(values$df[index1$prevs[clicknum-1]] <- c(newcol,slidervals))
      write.csv(values$df,file="results.csv")
      
      updateNumericInput(session, "mean", value = isolate(values$df[12,sc.name]))
      updateNumericInput(session, "range", value = isolate(values$df[13:14,sc.name]))
      updateNumericInput(session, "beta.l", value = isolate(values$df[15,sc.name]))
      updateNumericInput(session, "beta.r", value = isolate(values$df[16,sc.name]))
      
      
      sc.html=scenarios[sc.name,"description"]
      getPage<-function() {
        return(includeHTML(sc.html))
      }
      output$inc<-renderUI({getPage()})
      
      sc.lng=scenarios[sc.name,"long"]; sc.lat=scenarios[sc.name,"lat"];sc.radius=scenarios[sc.name,"radius.m"]
      output$mapit <- renderLeaflet({
        m=leaflet() %>% addTiles() %>% addTiles(urlTemplate = "http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",attribution="Tiles &copy Esri") 
        m%>% setView(lng=sc.lng, lat=sc.lat, 13)%>%addCircles(lng=sc.lng, lat=sc.lat,radius=sc.radius,fillColor="NULL")
      })
    }
    
  })  
  output$results=renderTable(values$df)
  
})
