#vector of unique artists, by their ids
artists <- unique(output_final$id)

#vector of unique plays, by their ids
musicals <- unique(output_final$codes)

#matrix of plays by artists, again by their ids
mat <- matrix(0,length(musicals),length(artists))

#naming the cols and rows
colnames(mat) <- artists
rownames(mat) <- musicals

#start filling in the matrix
for (i in 1:length(musicals))
{
  for (j in 1:length(artists))
  {
    index <- which(output_final$codes == musicals[i])
    if (any(output_final$id[index]==artists[j]))
    {
      mat[i,j] <- mat[i,j] + 1
    }
  }
}

score_mat <- {}
time_i_mat <- {}
time_f_mat <- {}

#create three vectors, of scores, date of premiere, and date of the last perforrmance, respectively
for (musical in musicals)
{
  i <- which(output_final$codes == musical)[1]
  score_mat <- append(score_mat, as.numeric(output_final$scores[i]))
  time_i_mat <- append(time_i_mat, as.character(output_final$time_i[i]))
  time_f_mat <- append(time_f_mat, as.character(output_final$time_f[i]))
}
mat <- cbind(mat, score_mat, time_i_mat, time_f_mat)
