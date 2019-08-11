#setwd('./AppliedStats_Proj2')
kobe_data <- read.csv('./model_KobeData.csv')

library('ggplot2')
attach(kobe_data)
qplot(shot_distance, shot_id, color=shot_made_flag, shape=kobe_data$playoffs)

qplot(shot_distance, shot_id,  color=kobe_data$shot_type)

qplot(loc_x, loc_y,  color=shot_made_flag)

qplot(avgnoisedb,shot_id, color=shot_made_flag)

qplot(lon ,lat, color=shot_made_flag)

qplot(lat, attendance, color=shot_made_flag)
qplot(shot_id, seconds_remaining, color=shot_made_flag)
qplot(lon, loc_y)

qplot(opponent, shot_id, color=shot_made_flag)
hist(opponent, shot_idhist)

plot(avgnoisedb, attendance)



qplot(shot_distance, shot_id,  color=shot_made_flag )

qplot(shot_id, arena_temp,color=shot_made_flag)

qplot(kobe_data$shot_zone_range, kobe_data$minutes_remaining, color=kobe_data$shot_made_flag)

qplot(kobe_data$shot_distance,)


