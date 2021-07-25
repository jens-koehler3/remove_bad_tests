#!/usr//bin/perl

use strict;
require $ENV{SCRIPTS}.'/util_psm/holliday.pl';

sub getNewDate(){# Übergabeparameter Tag, Monat, Jahr; Rückgabe Tag.Monat.jahr+14
  my $now_day=$_[0];
  my $now_month=$_[1];
  my $now_year=$_[2];
  my $new_year=$now_year+14;
  
  my $key=isFeiertag(int($now_day),int($now_month),$now_year);
  if($key ne ""){ 	#Day is a holliday
    my %holliday=getFeiertage($new_year);
    return $holliday{$key}.$new_year;
  }else{			#Day is no holliday
  
    my $current_weekday=estimateWeekday($now_day,$now_month,$now_year);
    my $future_weekday=estimateWeekday($now_day,$now_month,$new_year);
  
    if($current_weekday-$future_weekday != 0){
      $now_day=getNewDay($now_day,$current_weekday,$future_weekday);
      $future_weekday=estimateWeekday($now_day,$now_month,$new_year);
    }
  }
  if(isFeiertag(int($now_day),int($now_month),$new_year) ne ""){ #alter Tag war kein Feiertag, neuer wäre aber einer
   if($now_day-7 >= 1){ #Monat soll nicht geändert werden
      $now_day-=7; #Wochentag-7 ergibt den selbigen wieder
   }else{
      $now_day+=7; #Wochentag+7 ergibt den selbigen wieder
   }
  }
  if($now_day < 10){
    $now_day="0".$now_day;
  }
  return $now_day.".".$now_month.".".$new_year;
}

sub estimateWeekday(){
  my $day=$_[0];
  my $month=$_[1];
  my $century=substr($_[2],0,2);
  my $year=substr($_[2],2,2);
  
  if($month <= 2){
    $month=12+$month;
    $year-=1;
  } 

  return ($day+int((($month+1)*26)/10)+$year+int($year/4)+int($century/4)-2*$century)%7;
}

sub getNewDay(){
  my $now=$_[0];
  my $current=$_[1];
  my $future=$_[2];
  my $difference=$current-$future;
  if($difference == 0){
    return $now;
  }
  if($difference < 0){
    if($now + $difference > 0){
       $now=$now + $difference;
    }else{
       $now=$now+7+$difference;
    }
  }else{
    if($now + $difference < 28){
       $now=$now + $difference;
    }else{
     $now=$now-7+$difference;
    }
  }
  return $now;
}
