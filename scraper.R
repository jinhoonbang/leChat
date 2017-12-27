#Setting two vectors for actor names and their ManNo's
names <- "Name"
ids <- "ID"

#how many pages or iterations needed
url <- "http://www.playdb.co.kr/artistdb/list_iframe.asp?Page=1&code=013003&NameSort=Y&Country=Y"
web_data <- readLines(url, warn=FALSE)
web_data <- paste(web_data, collapse = ' ')
pages <- as.numeric(substr(web_data, regexpr("total 1/", web_data)[[1]]+8, regexpr("]</span>", web_data)[[1]]-1))

#scraping
for (page in 1:pages)
{
  url <- paste0("http://www.playdb.co.kr/artistdb/list_iframe.asp?Page=", page, "&code=013003&NameSort=Y&Country=Y")
  web_data <- readLines(url, warn=FALSE)
  web_data <- paste(web_data, collapse = ' ')
  id_starting_indices <- as.vector(gregexpr("./detail.asp?", web_data)[[1]])+19 #even only
  id_ending_indices <- as.vector(gregexpr("&part=013003", web_data)[[1]])-1 #even only
  name_starting_indices <- as.vector(gregexpr("top\">", web_data)[[1]])+5 #even only
  name_ending_indices <- name_starting_indices+10 #even only
  
  for (i in 1: (length(id_starting_indices)/2))
  {
    #get ManNo's
    id <- substr(web_data, id_starting_indices[i*2], id_ending_indices[i*2])
    
    #get names
    name <- substr(web_data, name_starting_indices[i*2], name_ending_indices[i*2])
    name <- substr(name, 1, regexpr("<", name)-1)
    
    #append
    ids <- append(ids, id)
    names <- append(names, name)
  }
}

#save the output
write.csv(as.data.frame(cbind(ids, names)), "data.csv")