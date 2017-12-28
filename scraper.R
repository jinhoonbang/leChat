library(XML)
library(plyr)

#Setting an empty data frame
output <- {}

#see how many iterations are needed
url <- "http://www.playdb.co.kr/artistdb/list_iframe.asp?Page=1&code=013003&NameSort=Y&Country=Y"
web_data <- readLines(url, warn=FALSE)
web_data <- paste(web_data, collapse = ' ')
pages <- as.numeric(substr(web_data, regexpr("total 1/", web_data)[[1]]+8, regexpr("]</span>", web_data)[[1]]-1))

#scrape
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
		#get id
		id <- substr(web_data, id_starting_indices[i*2], id_ending_indices[i*2])
		
		#get name
		name <- substr(web_data, name_starting_indices[i*2], name_ending_indices[i*2])
		name <- substr(name, 1, regexpr("<", name)-1)
		
		#get works
		url <- paste0("http://www.playdb.co.kr/artistdb/Detail_Content_new.asp?TabKind=3&ManNo=", id)
		history <- iconv(paste0(readLines(url, encoding="CP949"), collapse="\n"), to="UTF-8")
		musicals <- xpathSApply(htmlParse(history, isHTML=T, asText=T, encoding="UTF-8"), "//td[@class='ptitle']", xmlValue)
		dates <- xpathSApply(htmlParse(history, isHTML=T, asText=T, encoding="UTF-8"), "//td[@class='time']", xmlValue)

		#get workcodes
		work_data <- readLines(url, warn=FALSE)
		work_data <- paste(work_data, collapse = ' ')
		code_starting_indices <- as.vector(gregexpr("dbDetail.asp?", work_data)[[1]])+24 #even only
		code_ending_indices <- as.vector(gregexpr("target=\"_parent\"><", work_data)[[1]])-3
		codes <- {}
		scores <- {}
		for (k in 1:(length(code_starting_indices)/2))
		{
			code <- substr(work_data, code_starting_indices[k*2-1], code_ending_indices[k])
			codes <- append(codes, code)
			
			#get scores
			url <- paste0("http://www.playdb.co.kr/playdb/playdbDetail.asp?sReqPlayno=", code)
			score <- iconv(paste0(readLines(url, encoding="CP949", warn=FALSE), collapse="\n"), to="UTF-8")
			score <- xpathSApply(htmlParse(score, isHTML=T, asText=T, encoding="UTF-8"), "//dd[@class='score']", xmlValue)
			scores <- append(scores, score[1])
		}

		#format data
		block <- cbind(id, name, musicals, codes, dates, scores)
		
		#append
		output <- rbind.fill(as.data.frame(output), as.data.frame(block))
  }
}

#save the output
write.csv(output, "data.csv")
