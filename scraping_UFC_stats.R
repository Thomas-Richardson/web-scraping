
# scraping UFC.com

data = data.frame() # make a blank dataframe to store data in

for (letter in letters){ # go through each letter of the alphabet
  print(letter) # print out the letter so we know how far along we are
  link = paste0('http://ufcstats.com/statistics/fighters?char=',letter) # the link is ufcstats.com/statistics..etc PLUS the letter of the alphabet. So we paste our letter onto the end of it
  link %>% 
    read_html() %>% # read the HTML at the link
    html_nodes('.b-statistics__table') %>% # extract the elements that make up the table and nothing else
    html_table(fill=T) %>% # use html table function to convert the table on the website into a format we can convert to dataframe. fill = T means fill in empty table elements with NAs
    data.frame-> # turn it into a dataframe
    temp_data # save it as temp_data
  temp_data[2:nrow(temp_data),] # get rid of first row with seem to be all NAs for some reason
  data = rbind(data, temp_data) # add temp_data to our overall dataframe
}

data %>% View

# Facile!

