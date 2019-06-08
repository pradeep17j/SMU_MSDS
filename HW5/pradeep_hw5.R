df <- read.table('yob2016.txt', sep=";")
colnames(df) <- c('Name','Sex','Count')
summary(df)
structure(df)
row_num <- grep('yyy$', df$Name)
y2016 <- df[-c(row_num),]

y2015 <- read.table('yob2015.txt', sep=",")
colnames(y2015) <- c('Name','Sex','Count')
tail(y2015,10)

# It is surprising to see that the count of kids 
# who got these last 10 names are exactly 5 for each name in Year 2015


final <- merge(y2016, y2015, by=c('Name','Sex'))


# Remove any rows with NA

na_count <- length(which(is.na(final)))
if (na_count > 0){
  final[-c(which(is.na(final))),]

}

Total<- c(final$Count.x + final$Count.y)

final <- cbind(final, Total)

final <- final[order(final$Total),]

tail(final)

girls <- final[final$Sex == 'F',]

most_popular <- tail(girls,10)

write.csv(most_popular, file='most_popular_girls.txt')


new_df <- data.frame()
for (name in unique(final$Name)){
  tmp <- final[final$Name == name,]
  for (sex in unique(tmp$Sex)){
    #print (sex)
    tmp1 <- tmp[tmp$Sex == sex,]
    count_sum <- sum(tmp1$Count)
    tmp_df <- tmp1[1,]
    tmp_df[,3] <- count_sum
    new_df <- rbind(new_df, tmp_df)
    #print (new_df)
    #Sys.sleep(3)
    
  }
}
