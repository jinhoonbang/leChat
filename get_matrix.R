artists <- unique(output_final$id)
musicals <- unique(output_final$codes)
mat <- matrix(0,length(musicals),length(artists))

colnames(mat) <- artists
rownames(mat) <- musicals

i <- 1
j <- 1
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
for (musical in musicals)
{
  i <- which(output_final$codes == musical)[1]
  score_mat <- append(score_mat, as.numeric(output_final$scores[i]))
  time_i_mat <- append(time_i_mat, as.character(output_final$time_i[i]))
  time_f_mat <- append(time_f_mat, as.character(output_final$time_f[i]))
}
mat <- cbind(mat, score_mat, time_i_mat, time_f_mat)