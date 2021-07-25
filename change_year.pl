#!/usr/bin/perl  -w

use strict;
use Getopt::Long;
require $ENV{SCRIPTS}.'/util_psm/estimate_date_in_future.pl';


my $input;
my $format;
my $output;
my $help;
my %formats;
   $formats{AMA}{YEAR}=2;
   $formats{AMA}{MONTH}=3;
   $formats{AMA}{DAY}=4;
   $formats{AMAIN}{YEAR}=3;
   $formats{AMAIN}{MONTH}=4;
   $formats{AMAIN}{DAY}=5;
   $formats{AMAIN_PHONEBOX}{YEAR}=3;
   $formats{AMAIN_PHONEBOX}{MONTH}=4;
   $formats{AMAIN_PHONEBOX}{DAY}=5;
   $formats{IN2AMA13}{YEAR}=3;
   $formats{IN2AMA13}{MONTH}=4;
   $formats{IN2AMA13}{DAY}=5;
   $formats{IN2AMA13_PHONEBOX}{YEAR}=3;
   $formats{IN2AMA13_PHONEBOX}{MONTH}=4;
   $formats{IN2AMA13_PHONEBOX}{DAY}=5;
   $formats{CISCOIP}{YEAR}=6;
   $formats{CISCOIP}{MONTH}=7;
   $formats{CISCOIP}{DAY}=8;
   $formats{FKTO}{YEAR}=2;
   $formats{FKTO}{MONTH}=3;
   $formats{FKTO}{DAY}=4;
   $formats{GENERIC}{YEAR}=2;
   $formats{GENERIC}{MONTH}=3;
   $formats{GENERIC}{DAY}=4;
   $formats{GENERIC2}{YEAR}=2;
   $formats{GENERIC2}{MONTH}=3;
   $formats{GENERIC2}{DAY}=4;
   $formats{M2D}=1;
   $formats{M2D_S}=1;
   $formats{M2D_K}=1;
   $formats{IPTV}=3;
   $formats{IVR}{YEAR}=0;
   $formats{IVR}{MONTH}=1;
   $formats{IVR}{DAY}=2;
   $formats{MABEZ1_INA}{YEAR}=3;
   $formats{MABEZ1_INA}{MONTH}=4;
   $formats{MABEZ1_INA}{DAY}=5;

sub check_options()
{

# Funktionalitaet :
#-------------------
# Ueberpruefung der Eingaben

my $result  ;
$result=GetOptions(  "input=s"  => \$input  ,
	 	    "format=s"  => \$format ,
                    "output=s"  => \$output ,
		      "help=s"  => \$help  );

if ( defined($help) )
  {
    print "Aufruf: change_year.pl -i <INPUT> -f <CDR_FORMAT> [-o <OUTPUT>] [-h <HELP>]\n" ;
    exit ;
  }

if ( ! defined($format) )
  {
    print "Es muss mit -f ein cdr-format angegeben werden\n" ;
    exit ;
  }

if ( ! defined($input) )
  {
    print "Es muss ein Input-File mit -i angegeben werden\n" ;
    exit 1;
  }

if ( ! defined($formats{$format}) )
  {
    print "Das Format $format wird nicht unterstuetzt\n" ;
    exit 1;
  }

if ( ! defined($output) )
  {
    $output="${input}.$$";
  }
}

check_options();

####lesen der eingabedatei####
open (FILE,"<$input") or die "Cannot open $input: $!\n";
open (OUTGOING, "+>$output") or die "Cannot open $output: $!\n";
my @array=<FILE>;
my @date;
foreach (@array){
  my @tmp=split(" ",$_);
     if(($format eq "M2D") || ($format eq "M2D_S") || ($format eq "M2D_K")){
       if($_ =~m/^DETAIL/){
         my $year=substr($tmp[$formats{$format}],0,4);
	 my $month=substr($tmp[$formats{$format}],4,2);
	 my $day=substr($tmp[$formats{$format}],6,2);
	 my $time=substr($tmp[$formats{$format}],8,length($tmp[$formats{$format}])-6);
         @date=split(/\./,getNewDate($day, $month, $year));
         $tmp[$formats{$format}]=$date[2].$date[1].$date[0].$time;
       }
      }elsif(($format eq "IVR")){
       if($_ =~m/^[0-9]/){
         if($tmp[$formats{$format}{YEAR}] < 100){
	   $tmp[$formats{$format}{YEAR}]+=2000;
	  }
         @date=split(/\./,getNewDate($tmp[$formats{$format}{DAY}], $tmp[$formats{$format}{MONTH}], $tmp[$formats{$format}{YEAR}]));
       $tmp[$formats{$format}{DAY}]=$date[0];
       $tmp[$formats{$format}{MONTH}]=$date[1];
       $tmp[$formats{$format}{YEAR}]=$date[2];
       }
     }elsif($format eq "IPTV"){
       if($tmp[0] eq "ROW"){
	 @date=split("/",$tmp[$formats{$format}]);
	 my $day=$date[0];
	 my $month=$date[1];
	 my @tmp_array=split(" ",$date[2]);
         my $year=$tmp_array[0];
	 my $time=$tmp_array[1];
         @date=split(/\./,getNewDate($day, $month, $year));
         $tmp[$formats{$format}]=$date[1]."/".$date[0]."/".$date[2]." ".$time;
       }
     }else{
       if($tmp[$formats{$format}{YEAR}] < 100){
	 $tmp[$formats{$format}{YEAR}]+=2000;
	}
       @date=split(/\./,getNewDate($tmp[$formats{$format}{DAY}], $tmp[$formats{$format}{MONTH}], $tmp[$formats{$format}{YEAR}]));
       $tmp[$formats{$format}{DAY}]=$date[0];
       $tmp[$formats{$format}{MONTH}]=$date[1];
       $tmp[$formats{$format}{YEAR}]=$date[2];
     }
     if(($format eq "M2D") || ($format eq "M2D_S") || ($format eq "M2D_K")){
       if($_ =~m/^DETAIL/){
       for(my $i=0;$i<scalar(@tmp);$i++){
         chomp($tmp[$i]);
         print OUTGOING "$tmp[$i]";
         if($i < scalar(@tmp)-1){
  	   print OUTGOING "\t";
         }
       }
       print OUTGOING "\n";
       }else{
	 print OUTGOING "$_";
       }
     }elsif(($format eq "IVR")){
       if($_ =~m/^[0-9]/){
         for(my $i=0;$i<scalar(@tmp);$i++){
           chomp($tmp[$i]);
           print OUTGOING "$tmp[$i]";
           if($i < scalar(@tmp)-1){
  	     print OUTGOING "\t";
           }
         }
         print OUTGOING "\n";
       }else{
	 print OUTGOING "$_";
       }
     }else{
       for(my $i=0;$i<scalar(@tmp);$i++){
         chomp($tmp[$i]);
         print OUTGOING "$tmp[$i]";
         if($i < scalar(@tmp)-1){
  	   print OUTGOING "\t";
         }
       }
       print OUTGOING "\n";
     }
}
close(FILE) or die "Cannot close $input: $!";
close(OUTGOING) or die "Cannot close $output: $!";

