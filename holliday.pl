#!/usr//bin/perl

use strict;
use Time::Local;

sub isFeiertag(){
my $day=$_[0].".".$_[1].".";
my %holliday=getFeiertage($_[2]);
foreach my $key (keys %holliday){
   if ($day eq "$holliday{$key}"){
     return $key;
   }
}
return "";
}  


sub getFeiertage{
my $eintag=86400; #Sekunden des Tages
my $jahr=shift;
my ($i,$j,$c,$h,$g,$l,$day,$mday,$mon,$wert);
my %feiertage=();
#
 $g = $jahr % 19;
 $c = int($jahr/100);
 $h = ($c - int($c/4)-int((8*$c+13)/25)+ 19*$g + 15) % 30;
 $i = $h - int($h/28)*(1 -int($h/28)*int(29/($h+1))*int((21 - $g)/11));
 $j = ($jahr + int($jahr/4) + $i + 2 - $c + int($c/4));
 $j = $j % 7;


$l = $i - $j;
$mon = 3 + int(($l+40)/44);
$mday = $l + 28 - 31*int($mon/4);

my $epoche=&maketime($mday,$mon,$jahr);
my $datum=&getdays($epoche); # Das wäre der Ostersonntag, denn danach richten
							 # sich alle religiösen Feiertage wie Ostern,
							 # Pfingsten, Fronleichnam, Himmelfahrt oder auch
							 # "Rosenmontag", der 7 Wochen vor Ostermontag ist
### Feste Feiertage
$feiertage{'Neujahr'}="1.1.";
$feiertage{'Tag der Arbeit'}="1.5.";
$feiertage{'Tag der deutschen Einheit'}="3.10.";
$feiertage{'1. Weihnachtstag'}="25.12.";
$feiertage{'2. Weihnachtstag'}="26.12";

my $owert=$epoche;

###
$wert=$owert-2*$eintag;
$datum=&getdays($wert);
$feiertage{'Karfreitag'}=$datum;
###
$wert=$owert+$eintag;
$datum=&getdays($wert);
$feiertage{'Ostermontag'}=$datum;
###
$wert=$owert+49*$eintag;
$datum=&getdays($wert);
$feiertage{'Pfingstsonntag'}=$datum;
###
$wert=$owert+50*$eintag;
$datum=&getdays($wert);
$feiertage{'Pfingstmontag'}=$datum;
###
$wert=$owert+39*$eintag;
$datum=&getdays($wert);
$feiertage{'Christi Himmelfahrt'}=$datum;

return %feiertage;
}

###formatiert das Datum, wird von getFeiertag aufgerufen###

sub getdays{
my $wert=shift;
(my $sec,my $min,my$ hour,my $mday,my $mon,my $yr,my $wday,my $yday,my $isdst) = localtime($wert);
$mon++;
$yr+=1900;
my $datum=$mday.'.'.$mon.'.';
return $datum;
}

###Datumsstempel erzeugen###
sub maketime{
	my $mday=shift;
	my $mon=shift;
	my $jahr=shift;
    return timelocal(0,0,0,$mday,$mon-1,$jahr-1900);
}

return 1;
