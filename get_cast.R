library(XML)
library(plyr)

#concatenate musical titles and dates
Musical <- paste0(as.character(output$musicals), "(", as.character(output$dates), ")")

#concatenate artist name and id
Artist <- paste0(as.character(output$name), "(", as.character(output$id), ")")

#combine the two vectors into a data frame.
sorted <- cbind(Musical, Artist)
sorted <- as.data.frame(sorted)

#sort the data frame by Musical
sorted <- sorted[order(sorted$Musical),]
result <- {}

i <- 1
while (i < dim(sorted)[1])
{
  j <- i+1
  
  #row = musical, actor1, actor2, actor3, ..., actorN
  row <- as.character(sorted[i,1])
  row <- append(row, as.character(sorted[i,2]))
  while (sorted[j,1] == sorted[i,1])
  {
    row <- append(row, as.character(sorted[j,2]))
    j <- j+1
  }
  i <- i + length(row)-1
  
  #save each row in result
  result <- rbind.fill(as.data.frame(result), as.data.frame(t(row)))
}

write.csv(result, "result.csv")
