#!/usr/bin/perl

# ----------------------------------------------------------------------------------- #
# mit diesem Programm werden die benoetigten Dateien                                  #
# generiert die fuer den PSM-Regressionstest gebraucht                                #
# werden.                                                                             #
# Autor:   Koehler, Jens OSEV                                                         #
# Version: 1.0.2                                                                      #
# Datum:   13.11.2007                                                                 #
# Info:                                                                               #
# -------------------------------- Version 1.0.0 ------------------------------------ #
# 13.11.2007 schreiben der Version 1.0.0                                              #
# -------------------------------- Version 1.0.1 ------------------------------------ #
# 05.12.2007 schreiben der Version 1.0.1                                              #
# -------------------------------- Version 1.0.2 ------------------------------------ #
# 19.10.2017 schreiben der Version 1.0.2                                              #
# -------------------------------- Version 1.0.3 ------------------------------------ #
# 18.02.2019 schreiben der Version 1.0.3 Aktualisierung                               #
# -------------------------------- Version 1.0.3 ------------------------------------ #
# 29.01.2020 Aktualisierung und Fehlerbehebung beim Schreiben der Kundendatei         #
# ----------------------------------------------------------------------------------- #

# -------------------------------- Deklarationsanfang ------------------------------- #
# --------------------------------------- Pragmas ----------------------------------- #
# ----------------------------------------------------------------------------------- #
use strict  ;
#use warnings ;
# --------------------------------- special variables ------------------------------- #
# ----------------------------------------------------------------------------------- #
use English ;
# --------------------------------------- Modules ----------------------------------- #
# ----------------------------------------------------------------------------------- #
use Getopt::Long ;
use File::Find ;
use File::Copy ;
use File::Basename ;
use File::Path ;
use File::Glob ;
use Net::FTP ;
use Text::Wrap  qw(wrap) ;
use DBI ;
use lib $ENV{'SCRIPTS'} . "/util" ;
use Utils ;
use Shell ;
use Env ;
use Cwd;
use Fcntl;
use Config;
# ---------------------------------- lokale Variablen ------------------------------- #
# ----------------------------------------------------------------------------------- #
my $target_db=$ENV{'DB'} ;
my $target_db_user=$ENV{'DB_USER'} ;
my $target_db_password=$ENV{'DB_PASSWORD'} ;
my $modus="" ;
my $target="" ;
my $paket="" ;
my $pcam="" ;
my $pcamnr="" ;
my $cdr="" ;
my $dbh="" ;
my $current_base="" ;
my $base_ccb20b="" ;
my $kunden="" ;
my $result="" ;
my $input="" ;
my $format;
my $output;
my $help;
my $line;
my $baseDir = cwd;
my $str;
my $i;
my $j;
my $k;
# ---------------------- Benutzer definierbare lokale Variablen --------------------- #
# ----------------------------------------------------------------------------------- #
my $env_UC=$ENVIRONMENT;
my $env_LC=$ENVIRONMENT_LC;
my $AMAin="GEN_6196186870_18687_11";
my $AMAINin="GEN_6196186870_18687_11";
my $IN2AMA13in="";
my $CISCOIPin="CISCOIP_17708_NeuerPortfolio";
my $GENERICin="GEN_1731234567_17432_06";
my $FKTOin="";
my $FSMSin="";
my $AMAout="AMA_6196186870_18687_11";
my $AMAINout="AMAIN_6196186870_18687_11";
my $IN2AMA13out="";
my $CISCOIPout="CHU.IP-2007.06.08_12:00";
my $GENERICout="GENERIC_1731234567_17432_06";
my $FKTOout="";
my $FSMSout="";
my $AuftragsNr="";
my $pattern;
my $pattern1;
my $verzeichnis;

# -------------------------------------- @Arrays ------------------------------------ #
# ----------------------------------------------------------------------------------- #
my @cdrs=();
my @arr;
my @array3;

# -------------------------------------- %Hashes ------------------------------------ #
# ----------------------------------------------------------------------------------- #
my %functions_modus=() ;
my %modus_allowed;
my %formats;

# --------------------------------------- $Keys ------------------------------------- #
# ----------------------------------- modus_allowed --------------------------------- #
# ----------------------------------------------------------------------------------- #
$modus_allowed{'PSM_SHOW'}=1;
$modus_allowed{'PSM_REGRESSION'}=1;

# ----------------------------------- function_modus -------------------------------- #
# ----------------------------------------------------------------------------------- #
$functions_modus{"PSM_SHOW"}=[\&getPsmShow];
#$functions_modus{"PSM_REGRESSION"}=[\&getPsmRegression,\&createPutFile,\&getCdrs,\&doReplace,\&createGenerate,\&Generate,\&doTar,\&doPut,\&doErase];  # <- aktuelle Version
$functions_modus{"PSM_REGRESSION"}=[\&getPsmRegression,\&createPutFile,\&getCdrs,\&doReplace2,\&createGenerate,\&doTar];  # <- zu Testzwecken

# --------------------------------------- formats ----------------------------------- #
# ----------------------------------------------------------------------------------- #
$formats{AMA}=3;
$formats{AMAIN}=3;
$formats{IN2AMA13}=3;
$formats{CISCOIP}=6;
$formats{FKTO}=2;
$formats{FSMS}=2;
$formats{GENERIC}=2;
$formats{GENERIC03}=2;
# ---------------------------------- Deklarationsende ------------------------------- #
# ----------------------------------------------------------------------------------- #

# ----------------------------- Ausgabe des Programmnamen --------------------------- #
# ----------------------------------------------------------------------------------- #

print "\n". __FILE__ ." wird ausgefuehrt!\n" ;
print $baseDir."\n";

# ------------------------- Ueberpruefung des Eingabeformates ----------------------- #
# ----------------------------------------------------------------------------------- #

sub check_options()
{

# --------------------------------- Funktionalitaet : ------------------------------- #
# ----------------------------------------------------------------------------------- #
# ---------------------------- Ueberpruefung der Eingaben --------------------------- #
# ----------------------------------------------------------------------------------- #

&logging("Started") ;

# ------------------------------- moegliche Abfragemodi ----------------------------- #
# ----------------------------------------------------------------------------------- #

my $result  ;
$result=GetOptions(  "input=s"  => \$input ,
		                 "modus=s"  => \$modus ,
		                 "format=s" => \$format,
                     "paket=s"  => \$paket  );

#my $env_UC=system('echo $USER  | sed s/ccb20b//g | cut -d " " -f 1 | tr "[a-z]" "[A-Z]"');
#my $env_LC=system("echo $ENVIRONMENT | tr '[:upper:]' '[:lower:]'");
#my $packageShow=system(')psm_package.pl -modus SHOW | grep -v "^$" | tail -n 1 | cut -d_ -f2');

# -------------------- Ausgabe, wenn keine Modi angegeben werden -------------------- #
# ----------------------------------------------------------------------------------- #

if ( $modus eq "" )
  {
    printf "Es muss ein Modus mit -m angegeben werden.\n"  ;
    printf "Moegliche Werte fuer <MODUS> sind :\n\n" ;
    foreach ( keys %modus_allowed )
       {
	     printf "\t$_ \n" ;
	}
    printf "\n\n";
    exit ;
  }

# ------------- Ausgabe, wenn die Angabe des Paketes vergessen wurde ---------------- #
# ----------------------------------------------------------------------------------- #

if ( $paket eq "" && $modus eq "PSM_REGRESSION")
  {
    &error("Es muss eine Paketnummer mit -p angegeben werden") ;
    exit ;
  }

# ---------------- Ausgabe, wenn ein falscher Modus angegeben wird ------------------ #
# ----------------------------------------------------------------------------------- #

if ( ! exists ($modus_allowed{$modus} ))
  {
   printf "ERROR : Modus <$modus> nicht erlaubt \n" ;
   printf "Moegliche Werte fuer <MODUS> sind :\n\n" ;
   foreach ( keys %modus_allowed )
   {
      printf "\t$_ \n" ;
   }
   printf "\n" ;
   exit ;
  }
}

# -------------------------- das eigentliche Hauptprogramm -------------------------- #
# ----------------------------- 1. Abfrage beginnt hier ----------------------------- #
# ----------------------------------------------------------------------------------- #

sub getPsmRegression()
{
  $Utils::DbUser=$target_db_user;
  $Utils::DbPassword=$target_db_password;
  $Utils::Db=$target_db;
  my $dbh="";
  $dbh=&connect_db($dbh);
  
  chdir ("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket");
  my @current_packages= getcwd();
  #my $target = getcwd();
  #print "Aktuelles Verzeichnis: ", $target, "\n";
  #my $target="/ccb/ccb20b/sharereg/$env_UC/szenarios_batch";

  #my @current_packages=`ls -tr ${target}/pack$paket` ;

  foreach ( @current_packages )
  {
      my $paket=$_ ;
      $paket=~s/\n//g ;
      printf "\n\t$paket" ;
  }
  printf "\n\n";
  print "\nKunden: $kunden\n\n";
  my $sql=qq(select e.customer_number, e.name from entity e
		 where e.name like '\%(pack$paket)\%' order by e.customer_number);
  my $sth = $dbh->prepare($sql);
  $sth->execute() ;
  
  while ( my @found = $sth->fetchrow_array )
  {
    $kunden=$kunden."'".$found[0]."','".$found[1]."',\n";
  }
  $kunden=$kunden."\n";
  printf $kunden."\n";
}

# ------------------------- erzeugen der Kunden-Tesxtdatei -------------------------- #
# ----------------------------- 2. Abfrage beginnt hier ----------------------------- #
# ----------------------------------------------------------------------------------- #

sub createPutFile()
{
  $Utils::DbUser=$target_db_user;
  $Utils::DbPassword=$target_db_password;
  $Utils::Db=$target_db;
  my $dbh="";
  $dbh=&connect_db($dbh);

  my @verz=( "AMA" ,	      # 0
             "AMAIN" ,        # 1
		     "CISCOIP" ,      # 2
		     "GENERIC" ,      # 3
         	"GENERIC03" ,      # 4
		     "IN2AMA13" ,     # 5
		     "FKTO" ,         # 6
		     "FSMS"           # 7
         );
  my $verzzeiger = \@verz;
  
  my $i=0;  
  
  open(OUT, "> Kunden_PSM_$paket.$env_UC");
  #Kundennummer;Geaendert;PCAM-NUMMER;CDRs;Bem.
  print OUT "#Kundennummer;Geaendert;PCAM-NUMMER;CDRs;Bem.\n";
  my $count=qq(select count\(*\) from entity e
		 where e.name like '\%\(pack$paket\)\%');
  my $sql=qq(select e.customer_number, e.name from entity e
		 where e.name like '\%\(pack$paket\)\%' order by e.customer_number);
  my $sth = $dbh->prepare($sql);
  $sth->execute() ;
  while ( my @found = $sth->fetchrow_array )
  {
    my $pcam=$found[1];
	#my $regex = '/^[CU]*[0-9]*[_]*[0-9]*[ ]*/'; # neu
	#my $pcam1=~ /$regex/g; # neu
    my $pcamnr=substr($pcam,2,5);
	#my $pcamnr=re($pcam1,2,6); # neu
    my $target="/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket";
	my @current_packages=`ls -tr ${target}/CU-0000$pcamnr/test_control/configuration/cdrs/$verzzeiger->[$i]/ 2>/dev/null` ;
	for (my $i=0;$i<$count+1;$i++) {
	#for (my $i=0;$i<10;$i++) {
    #my @current_packages=`ls -tr ${target}/CU-0000$pcamnr/test_control/configuration/cdrs/$verzzeiger->[$i]/ 2>/dev/null` ;
	#print OUT $found[0].";N;".$pcamnr.";".$result.";".$found[1]."\n";
	
      foreach $result ( @current_packages )
      {
        #my $result=$_ ;
        $result=~s/\n//g ;
        print OUT $found[0].";N;".$pcamnr.";".$result.";".$found[1]."\n";
      }
	  
	  print OUT $found[0].";N;".$pcamnr.";".$result.";".$found[1]."\n";
	  
	}
	
  }
  print OUT "\n";
  close(OUT);
}


# --------- die CDR Ordner werden in den ausgewaehlten Paketordner kopiert ----------- #
# ----------------------------- 3. Abfrage beginnt hier ----------------------------- #
# ----------------------------------------------------------------------------------- #

sub getCdrs()
{
  $Utils::DbUser=$target_db_user;
  $Utils::DbPassword=$target_db_password;
  $Utils::Db=$target_db;
  my $dbh="";
  $dbh=&connect_db($dbh);


  my $sql=qq(select e.customer_number, e.name from entity e
		 where e.name like '\%\(pack$paket\)\%');
  my $sth = $dbh->prepare($sql);
  $sth->execute() ;
  while ( my @found = $sth->fetchrow_array )
  {
    my $pcam=$found[1];
    my $pcamnr=substr($pcam,2,5);

    my $target="/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/CU-0000$pcamnr";
    my @current_packages=`ls -tr ${target}/test_control/configuration/cdrs/` ;

    printf "\n\nCU-0000$pcamnr :";
    foreach ( @current_packages )
    {
      my $result=$_ ;
      $result=~s/\n//g ;
      printf "\n\t" . $result;
      $base_ccb20b=qq(/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket);
      $current_base=qq(/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/CU-0000$pcamnr/test_control/configuration/cdrs/) ;
      system("cp -R $current_base/* $base_ccb20b" ) ;
	    if (-d "AMA.src") {
		  print "\n";
          system("rm $base_ccb20b/AMA.src/generate*");
		  print "\n";
          system("rm $base_ccb20b/AMA.src/AMA*");
		  print "\n";
	    }
	    if (-d "AMAIN.src") {
		  print "\n";
          system("rm $base_ccb20b/AMAIN.src/generate*");
		  print "\n";
          system("rm $base_ccb20b/AMAIN.src/AMA*");
		  print "\n";
	    }
	    if (-d "IN2AMA13.src") {
          system("rm $base_ccb20b/IN2AMA13.src/generate*");
          system("rm $base_ccb20b/IN2AMA13.src/AMA*");
	    }
	    if (-d "GENERIC.src") {
          system("rm $base_ccb20b/GENERIC.src/generate*");
          system("rm $base_ccb20b/GENERIC.src/GENERIC*");
	    }
      if (-d "GENERIC03.src") {
          system("rm $base_ccb20b/GENERIC03.src/generate*");
          system("rm $base_ccb20b/GENERIC03.src/*");
	    }
	    if (-d "CISCOIP.src") {
          system("rm $base_ccb20b/CISCOIP.src/generate*");
          system("rm $base_ccb20b/CISCOIP.src/CHU*");
	    }
	    if (-d "FKTO.src") {
          system("rm $base_ccb20b/FKTO.src/generate*");
          system("rm $base_ccb20b/FKTO.src/AMA*");
	    }
	    if (-d "FSMS.src") {
          system("rm $base_ccb20b/FSMS.src/generate*");
          system("rm $base_ccb20b/FSMS.src/AMA*");
	    }
    }
    printf "\n";
  }
  system("cd $base_ccb20b") ;
  #&doReplace;
  #&createGenerate;
  #&doTar;
}

#  generate.ksh-Skript der Ordner AMA, GENERIC, CISCOIP, etc. erzeugen und ausfuehren  #
# ----------------------------- 5. Abfrage beginnt hier ----------------------------- #
# ----------------------------------------------------------------------------------- #

sub createGenerate()
{
my @verz=( "AMA.src" ,		# 0
           "AMAIN.src" ,    # 1
		   "CISCOIP.src" ,  # 2
		   "GENERIC.src" ,  # 3
       "GENERIC03.src" ,  # 4
		   "IN2AMA13" ,     # 5
		   "FKTO" ,         # 6
		   "FSMS"           # 7
         );
my $verzzeiger = \@verz;

my $i=0;

chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket");

do {
	    if (-d "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/AMA.src"){
		  &AMA;
		  };
		if (-d "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/AMAIN.src"){
		  &AMAIN;
		  };
		if (-d "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/CISCOIP.src"){
		  &CISCOIP;
		  };
		if (-d "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/GENERIC.src"){
		  &GENERIC;
		  };
    if (-d "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/GENERIC03.src"){
		  &GENERIC03;
		  };
		if (-d "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/IN2AM13.src"){
		  &IN2AMA13;
		  };
		if (-d "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/FKTO.src"){
		  &FKTO;
		  };
		if (-d "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/FSMS.src"){
		  &FSMS;
		  };
		};
        print "Kein weiteren Verzeichnisse vorhanden!\n";
		print "\n";
	return;
};	

# -------------- hier wir das erzeugte generate.ksh Skript ausgefuehrt --------------- #
# ----------------------------- 6. Abfrage beginnt hier ----------------------------- #
# ----------------------------------------------------------------------------------- #

sub Generate()
{
  printf "Bitte warten die CDRs werden generiert ...\n";
    if (-e "generate.ksh") {
      system("generate.ksh");
    } else {
	  print "generate.ksh Skript existiert nicht!\n";
	}
  #system("rm GEN_*");	
  printf "Generierung beendet! :-)\n";
}

# ----------------- generate.ksh-Skript erzeugen fuer den Ordner AMA ----------------- #
# ----------------------------------------------------------------------------------- #

sub AMA()
{
  print "Subroutine AMA\n";
  chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/AMA.src");
  open(IN,"+>generate.ksh");
  chmod(0755,"generate.ksh");
  my $target = "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket";
  my @current_packages = `ls -tr ${target}/AMA.src`;
  foreach ( @current_packages )
  {
    my $result=$_ ;
    $result=~s/generate.ksh//g;
    $result=~s/^\n$//g;
    if ($result=~m/GEN1[_a-zA-Z0-9]*/){
      chomp ($result);
      $line = "template16_ama.ksh -I $result -o $result\n";
      $line=~s/-o GEN1/-o AMA/g;
      printf IN $line;
    }
  }
  printf IN "cp AMA* ../AMA\n";
  close(IN);
  &Generate;
}

# ---------------- generate.ksh-Skript erzeugen fuer den Ordner AMAIN ---------------- #
# ----------------------------------------------------------------------------------- #

sub AMAIN()
{
  print "Subroutine AMAIN\n";
  chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/AMAIN.src");
  open(IN,"+>generate.ksh");
  chmod(0755,"generate.ksh");
  my $target = "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket";
  my @current_packages = `ls -tr ${target}/AMAIN.src`;
  foreach ( @current_packages )
  {
    my $result=$_ ;
    $result=~s/generate.ksh//g;
    $result=~s/^\n$//g;
    if ($result=~m/GEN[_a-zA-Z0-9]*/){
      chomp ($result);
	  $line = "template16_amain_phonebox.ksh -I $result -o $result\n";
      #$line = "template16_amain.ksh -I $result -o $result\n";
      $line=~s/-o GEN1/-o AMAIN/g;
      printf IN $line;
    }
  }
  printf IN "cp AMAIN* ../AMAIN\n";
  close(IN);
  &Generate;
}

# -------------- generate.ksh-Skript erzeugen fuer den Ordner AIN2AMA13 -------------- #
# ----------------------------------------------------------------------------------- #

sub IN2AMA13()
{
  print "Subroutine IN2AMA13\n";
  chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/IN2AMA13.src");
  open(IN,"+>generate.ksh");
  chmod(0755,"generate.ksh");
  my $target = "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket";
  my @current_packages = `ls -tr ${target}/IN2AMA13.src`;
  foreach ( @current_packages )
  {
    my $result=$_ ;
    $result=~s/generate.ksh//g;
    $result=~s/^\n$//g;
    if ($result=~m/GEN[_a-zA-Z0-9]*/){
      chomp ($result);
      $line = "template16_amain.ksh -I $result -o $result\n";
      $line=~s/-o GEN/-o IN2AMA13/g;
      printf IN $line;
    }
  }
  printf IN "cp IN2AMA13* ../IN2AMA13\n";
  close(IN);
}

# --------------- generate.ksh-Skript erzeugen fuer den Ordner GENERIC --------------- #
# ----------------------------------------------------------------------------------- #

sub GENERIC()
{
  print "Subroutine GENERIC\n";
  chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/GENERIC.src");
  open(IN,"+>generate.ksh");
  chmod(0755,"generate.ksh");
  my $target = "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket";
  my @current_packages = `ls -tr ${target}/GENERIC.src`;
  foreach ( @current_packages )
  {
    my $result=$_ ;
    $result=~s/generate.ksh//g;
    $result=~s/^\n$//g;
    if ($result=~m/GEN[_a-zA-Z0-9]*/){
      chomp ($result);
      $line = "generate_generic2.ksh -I $result -o $result\n";
      $line=~s/-o GEN/-o GENERIC/g;
      printf IN $line;
    }
  }
  printf IN "cp GENERIC* ../GENERIC\n";
  close(IN);
  &Generic
}

# --------------- generate.ksh-Skript erzeugen fuer den Ordner GENERIC03 --------------- #
# -------------------------------------------------------------------------------------- #

sub GENERIC03()
{
  print "Subroutine GENERIC03\n";
  chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/GENERIC03.src");
  open(IN,"+>generate.ksh");
  chmod(0755,"generate.ksh");
  my $target = "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket";
  my @current_packages = `ls -tr ${target}/GENERIC03.src`;
  foreach ( @current_packages )
  {
    my $result=$_ ;
    $result=~s/generate.ksh//g;
    $result=~s/^\n$//g;
    if ($result=~m/GEN[_a-zA-Z0-9]*/){
      chomp ($result);
      $line = "generate_generic2.ksh -I $result -o $result\n";
      $line=~s/-o GEN/-o GENERIC/g;
      printf IN $line;
    }
  }
  printf IN "cp GENERIC03* ../GENERIC03\n";
  close(IN);
  &Generic
}

# --------------- generate.ksh-Skript erzeugen fuer den Ordner CISCOIP --------------- #
# ----------------------------------------------------------------------------------- #

sub CISCOIP()
{
  print "Subroutine CISCOIP\n";
  chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/CISCOIP.src");
  open(IN,"+>generate.ksh");
  chmod(0755,"generate.ksh");
  my $target = "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket";
  my @current_packages = `ls -tr ${target}/CISCOIP.src`;
  foreach ( @current_packages )
  {
    my $result=$_ ;
    $result=~s/generate.ksh//g;
    $result=~s/^\n$//g;
    if ($result=~m/GEN[_a-zA-Z0-9]*/){
      chomp ($result);
      $line = "generate_ip -I $result\n";
      #$line=~s/-o GEN/-o CISCOIP/g;
      printf IN $line;
    }
  }
  printf IN "cp CHU* ../CISCOIP\n";
  close(IN);
  &Generate;
}

# ----------------- generate.ksh-Skript erzeugen fuer den Ordner FKTO ---------------- #
# ----------------------------------------------------------------------------------- #

sub FKTO()
{
  print "Subroutine FKTO\n";
  chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/FKTO.src");
  open(IN,"+>generate.ksh");
  chmod(0755,"generate.ksh");
  my $target = "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket";
  my @current_packages = `ls -dtr ${target}/FKTO.src`;
  foreach ( @current_packages )
  {
    my $result=$_ ;
    $result=~s/generate.ksh//g;
    $result=~s/^\n$//g;
    if ($result=~m/GEN[_a-zA-Z0-9]*/){
      chomp ($result);
      $line = "template16_amain.ksh -I $result -o $result\n";
      $line=~s/-o GEN/-o AMAIN/g;
      printf IN $line;
    }
  }
  printf IN "cp FKTO* ../FKTO\n";
  close(IN);

}

# ----------------- generate.ksh-Skript erzeugen fuer den Ordner FSMS ---------------- #
# ----------------------------------------------------------------------------------- #

sub FSMS()
{
  print "Subroutine FSMS\n";
  chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/FSMS.src");
  open(IN,"+>generate.ksh");
  chmod(0755,"generate.ksh");
  my $target = "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket";
  my @current_packages = `ls -dtr ${target}/AMA.src`;
  foreach ( @current_packages )
  {
    my $result=$_ ;
    $result=~s/generate.ksh//g;
    $result=~s/^\n$//g;
    if ($result=~m/GEN[_a-zA-Z0-9]*/){
      chomp ($result);
      $line = "template16_amain.ksh -I $result -o $result\n";
      $line=~s/-o GEN/-o AMAIN/g;
      printf IN $line;
    }
  }
  printf IN "cp AMAIN* ../AMAIN\n";
  close(IN);
}

# -------------------- generate.ksh-Skript erzeugen und ausfuehren ------------------- #
# ----------------------------------------------------------------------------------- #

sub createGenerate1()
{
  chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/AMA.src");
  open(IN,"+>generate.ksh");
  chmod(0755,"generate.ksh");
  my $target = "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket";
  my @current_packages = `ls -dtr ${target}/AMA.src`;
  foreach ( @current_packages )
  {
    my $result=$_ ;
    $result=~s/generate.ksh//g;
    $result=~s/^\n$//g;
    if ($result=~m/GEN[_a-zA-Z0-9]*/){
      chomp ($result);
      $line = "template16_ama.ksh -I $result -o $result\n";
      $line=~s/-o GEN/-o AMA/g;
      printf IN $line;
    }
  }
  printf IN "cp AMA* ../AMA\n";
  close(IN);
  printf "Bitte warten die CDRs werden generiert ...\n";
  system("generate.ksh");
  printf "Generierung beendet! :-)\n";
}

# ------------------- die Ordner im Paket Ordner werden kompriemiert ---------------- #
# ----------------------------- 7. Abfrage beginnt hier ----------------------------- #
# ----------------------------------------------------------------------------------- #

sub doTar()
{
  chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket");
  &existierenVerzeichnisse;
  system("tar -cvf CDRS_PSM_$paket\_$env_UC.tar @cdrs");
  #&doPut;
}

# -------------- Ueberpruefung ob bestimmte CDR Verzeichnisse existieren -------------- #
# ------------------------------------------------------------------------------------- #

sub existierenVerzeichnisse()
{
  if (-d "AMA") {
    push (@cdrs, "AMA", "AMA.src");
  }
  if (-d "GENERIC") {
    push (@cdrs, "GENERIC", "GENERIC.src");
  }
  if (-d "GENERIC03") {
    push (@cdrs, "GENERIC03", "GENERIC03.src");
  }
  if (-d "AMAIN") {
    push (@cdrs, "AMAIN", "AMAIN.src");
  }
  if (-d "IN2AMA13") {
    push (@cdrs, "IN2AMA13", "IN2AMA13.src");
  }
  if (-d "CISCOIP") {
    push (@cdrs, "CISCOIP", "CISCOIP.src");
  }
  if (-d "FKTO") {
    push (@cdrs, "FKTO", "FKTO.src");
  }
  if (-d "FSMS") {
    push (@cdrs, "FSMS", "FSMS.src");
  }
  return @cdrs;
}

# -------------------------- Uebergabe der generierten Dateien ----------------------- #
# ----------------------------- 8. Abfrage beginnt hier ------------------------------ #
# ------------------------------------------------------------------------------------ #

sub doPut()
{
  my $ftp;
  chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket");
  $ftp = Net::FTP->new("as04r03", Debug => 0) or die "Kann keine Verbindung zum Server aufbauen: $@";
  $ftp->login("ccb20btl","toll5000") or die "Kann mich nicht einloggen ", $ftp->message;
  $ftp->cwd("/ccb/ccb20b/share/TESTSRC/ccb/E2/regression_test/Uebergabe_PSM") or die "Kann nicht in angegebenes Verzeichnis wechseln ", $ftp->message;
  $ftp->put('CDRS_PSM_' . $paket . '_' . $env_UC . '.tar') or die "PUT fehlgeschlagen ", $ftp->message;
  $ftp->put('Kunden_PSM_' . $paket . '.' . $env_UC) or die "PUT fehlgeschlagen ", $ftp->message;
  $ftp->quit; 
  #my $BaseRegression = qq("/ccb/ccb20/pkgbata4/pkgbate2/regression_test/Uebergabe_PSM/");
  #system("cp CDRS* Kunden* $BaseRegression");
  &existierenVerzeichnisse;
  system("rm -rf CDRS* Kunden* @cdrs");
}

# ------------- zu Testzwecken soll dieses Unterprogram eingesetzt werden ----------- #
# ----------------------------- 9. Abfrage beginnt hier ----------------------------- #
# ----------------------------------------------------------------------------------- #

sub doErase()
{
  chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket");
  &existierenVerzeichnisse;
  system("rm -rf CDRS* Kunden* @cdrs");  
}


# ----------------- das Datum wird um 28 Jahre in die Zukunft gesetzt --------------- #
# ----------------------------- 4. Abfrage beginnt hier ----------------------------- #
# ----------------------------------------------------------------------------------- #

sub doReplace1()
{
  my $verzeichnis;
  my @verz=( "AMA.src" ,		# 0
             "AMAIN.src" ,  # 1
		     "CISCOIP.src" ,    # 2
		     "GENERIC.src" ,    # 3
         "GENERIC03.src" ,    # 4
		     "IN2AMA13" ,       # 5
		     "FKTO" ,           # 6
		     "FSMS"             # 7
           );
  my $verzzeiger = \@verz;
  my $base_ccb20b=qq(/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket);
  my $i=0;
  
  #print "Bin im doReplace1\n";
  chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket");
  
  until($i==7){
   SWITCH: {
     ($i==0) && do {
	   if (-d "AMA.src"){
	   my $verzeichnis = "AMA.src";
	   my $pattern = getDate();
	   my $pattern1 = $pattern + 28;
	   print "Im Verzeichnis AMA.src\n";
	   &current_packages($verzeichnis, $pattern, $pattern1);
	   #last SWITCH;
	   };
	 };
	 ($i==1) && do {
	   if (-d "AMAIN.src"){
	   my $verzeichnis = "AMAIN.src";
	   my $pattern = getDate();
	   my $pattern1 = ($pattern - 2000) + 28;
	   my $newpattern = $pattern - 2000;
	   if ($newpattern < 10) {
	     $pattern = "0" . $newpattern;
	     };
		 print "Im Verzeichnis AMAIN.src\n";
	   &current_packages($verzeichnis, $pattern, $pattern1); 
	   #last SWITCH;
	    };
	   };
	 ($i==2) && do {
	   if (-d "CISCOIP.src"){
	   my $verzeichnis = "CISCOIP.src";
	   my $pattern = getDate();
	   my $pattern1 = $pattern + 28;
	   &current_packages($verzeichnis, $pattern, $pattern1);
	   #last SWITCH;
	   };
	 };
	 ($i==3) && do {
	   if (-d "GENERIC.src"){
	   my $verzeichnis = "GENERIC.src";
	   my $pattern = getDate();
	   my $pattern1 = $pattern + 28;
	   &current_packages($verzeichnis, $pattern, $pattern1);
	   #last SWITCH;
	   };
	 };
	 ($i==4) && do {
	   if (-d "GENERIC03.src"){
	   my $verzeichnis = "GENERIC03.src";
	   my $pattern = getDate();
	   my $pattern1 = $pattern + 28;
	   &current_packages($verzeichnis, $pattern, $pattern1);
	   #last SWITCH;
	   };
	 };

	 ($i==5) && do {
	   if (-d "IN2AMA13"){
	   my $verzeichnis = "IN2AMA13";
	   my $pattern = getDate();
	   my $pattern1 = $pattern + 28;
	   &current_packages($verzeichnis, $pattern, $pattern1);
	   #last SWITCH;
	   };
	 };
	 ($i==6) && do {
	   if (-d "FKTO"){
	   my $verzeichnis = "FKTO";
	   my $pattern = getDate();
	   my $pattern1 = $pattern + 28;
	   &current_packages($verzeichnis, $pattern, $pattern1);
	   last SWITCH;};
	 };
	 ($i==7) && do {
	   if (-d "FSMS"){
	   my $verzeichnis = "FSMS";
	   my $pattern = getDate();
	   my $pattern1 = $pattern + 28;
	   &current_packages($verzeichnis, $pattern, $pattern1);
	   #last SWITCH;
	   };
	 };
     };
     $i++;	 
	 print $verzeichnis . "\n";
  }
}

sub doReplace2()
#require $ENV{SCRIPTS}.'/util_psm/change_year.pl';
{
  my $verzeichnis;
  my @verz=( "AMA.src" ,		# 0
             "AMAIN.src" ,      # 1
		     "CISCOIP.src" ,    # 2
		     "GENERIC.src" ,    # 3
         "GENERIC03.src" ,    # 4
		     "IN2AMA13" ,       # 5
		     "FKTO" ,           # 6
		     "FSMS"             # 7
           );
  my $verzzeiger = \@verz;
  my $base_ccb20b=qq(/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket);
  my $i=0;
  
  #print "Bin im doReplace2\n";
  until($i==7){
   SWITCH: {
     ($i==0) && do {
	   if (-d "AMA.src"){
	   chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/AMA.src");
       open(IN,"+>changeyear.ksh");
       chmod(0755,"changeyear.ksh");
       my $target = "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket";
       my @current_packages = `ls -tr ${target}/AMA.src`;
       foreach ( @current_packages )
	   {
	     my $result=$_;
         $result=~s/generate.ksh//g;
         $result=~s/^\n$//g;
		 if ($result=~m/GEN[_a-zA-Z0-9]*/){
		   chomp ($result);
		   $line = "change_year.pl -f AMA -i $result -o $result\n";
		   $line=~s/-o GEN/-o GEN1/g;
		   printf IN $line;
		 };
		};
		close(IN);
	  };
	 };
	 ($i==1) && do {
	   if (-d "AMAIN.src"){
	   chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/AMAIN.src");
       open(IN,"+>changeyear.ksh");
       chmod(0755,"changeyear.ksh");
       my $target = "/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket";
       my @current_packages = `ls -tr ${target}/AMAIN.src`;
       foreach ( @current_packages )
	   {
	     my $result=$_;
         $result=~s/generate.ksh//g;
         $result=~s/^\n$//g;
		 if ($result=~m/GEN[_a-zA-Z0-9]*/){
		   chomp ($result);
		   $line = "change_year.pl -f AMAIN -i $result -o $result\n";
		   $line=~s/-o GEN/-o GEN1/g;
		   printf IN $line;
		 };
		};
		close(IN);
	  };
	 }; 
	 ($i==2) && do {
	   if (-d "CISCOIP.src"){
	   my $verzeichnis = "CISCOIP.src";
	   my $pattern = getDate();
	   my $pattern1 = $pattern + 28;
	   &current_packages($verzeichnis, $pattern, $pattern1);
	   #last SWITCH;
	   };
	 };
	 ($i==3) && do {
	   if (-d "GENERIC.src"){
	   my $verzeichnis = "GENERIC.src";
	   my $pattern = getDate();
	   my $pattern1 = $pattern + 28;
	   &current_packages($verzeichnis, $pattern, $pattern1);
	   #last SWITCH;
	   };
	 };
	 ($i==4) && do {
	   if (-d "GENERIC03.src"){
	   my $verzeichnis = "GENERIC03.src";
	   my $pattern = getDate();
	   my $pattern1 = $pattern + 28;
	   &current_packages($verzeichnis, $pattern, $pattern1);
	   #last SWITCH;
	   };
	 };

	 ($i==5) && do {
	   if (-d "IN2AMA13"){
	   my $verzeichnis = "IN2AMA13";
	   my $pattern = getDate();
	   my $pattern1 = $pattern + 28;
	   &current_packages($verzeichnis, $pattern, $pattern1);
	   #last SWITCH;
	   };
	 };
	 ($i==6) && do {
	   if (-d "FKTO"){
	   my $verzeichnis = "FKTO";
	   my $pattern = getDate();
	   my $pattern1 = $pattern + 28;
	   &current_packages($verzeichnis, $pattern, $pattern1);
	   last SWITCH;};
	 };
	 ($i==7) && do {
	   if (-d "FSMS"){
	   my $verzeichnis = "FSMS";
	   my $pattern = getDate();
	   my $pattern1 = $pattern + 28;
	   &current_packages($verzeichnis, $pattern, $pattern1);
	   #last SWITCH;
	   };
	 };
     };
     $i++;	 
	 print $verzeichnis . "\n";
  }
  system("changeyear.ksh")
}

sub current_packages($verzeichnis, $pattern, $pattern1)
{
  my $verzeichnis=$_[0];
  my $pattern=$_[1];
  my $pattern1=$_[2];
  print $verzeichnis . "\n" . $pattern . "\n" . $pattern1 . "\n";
  $base_ccb20b=qq(/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket);
  my @current_packages=`ls -dtr ${base_ccb20b}/$verzeichnis/*` ;

  foreach ( @current_packages )
  {
    my $result=$_;
    print "\n\t".$result;
 
    open (FILE,"$result") or die "Konnte Datei ${base_ccb20b}/${verzeichnis}/${input} nicht oeffnen: $!\n";
    open (OUT, "+<$result");
    while (my $line=<FILE>){   
           $line=~s/$pattern/$pattern1/g;
           printf OUT $line;
           }
  close(FILE) or die "Konnte Datei $input nicht schliessen: $!";
  close(OUT);
  }
}

sub doReplace()
{
  chdir("/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket/AMA.src");
# Jahr:
  my $pattern=getDate();
  my $pattern1=$pattern+28;
# Folgejahr:
  # my $pattern=getDate()+1;
  # my $pattern1=$pattern+28;
  print $pattern;

$base_ccb20b=qq(/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket);
my @current_packages=`ls -tr ${base_ccb20b}/AMA.src/` ;

foreach ( @current_packages )
{
  my $result=$_;
  print "\n\t".$result;
 
  open (FILE,"$result") or die "Konnte Datei ${base_ccb20b}/AMA.src/${input} nicht oeffnen: $!\n";
  open (OUT, "+<$result");
  while (my $line=<FILE>){   
         $line=~s/$pattern/$pattern1/g;
         printf OUT $line;
  }
  close(FILE) or die "Konnte Datei $input nicht schliessen: $!";
  close(OUT);
}
}

# ------------------------ das Jahr (vierstellig) wird gesetzt ---------------------- #
# ----------------------------------------------------------------------------------- #

sub getDate()
{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$ydat,$isdst)=localtime();
  return $year+1900
}

# -------- die Namen der AMA Dateien fuer Uebergabe Skript werden aufgelistet --------- #
# ----------------------------------------------------------------------------------- #

sub getCdrFiles()
{
  $Utils::DbUser=$target_db_user;
  $Utils::DbPassword=$target_db_password;
  $Utils::Db=$target_db;
  my $dbh="";
  $dbh=&connect_db($dbh);


  my $sql=qq(select e.customer_number, e.name from entity e
		 where e.name like '\%\(pack$paket\)\%');
  my $sth = $dbh->prepare($sql);
  $sth->execute() ;
  while ( my @found = $sth->fetchrow_array )
  {
    my $pcam=$found[1];
    my $pcamnr=substr($pcam,0,5);
    my $target="/ccb/ccb20b/sharereg/$env_UC/szenarios_batch/pack$paket";
    print $pcamnr."\n";
    my @current_packages=`ls -tr ${target}/CU-0000$pcamnr/test_control/configuration/cdrs/AMA/` ;

    foreach ( @current_packages )
    {
      my $result=$_ ;
      printf "\n\t$result" ;
    }
  }
  printf "\n\n";
  my $cdr=$result;
  return $cdr;
}

# ------------------------- Funktion zur Anzeige der Pakete ------------------------- #
# ----------------------------------------------------------------------------------- #

sub getPsmShow()
{
  my $target="/ccb/ccb20b/sharereg/$env_UC/szenarios_batch" ;

  my  @current_packages=`ls -tr ${target}/pack*` ;

  foreach (  @current_packages )
  {
       my $paket=$_ ;
       printf "$paket\n" ;
  }
}

# ------------------------------- Datenbankverbindung ------------------------------- #
# ----------------------------------------------------------------------------------- #

sub callDB()
{
  $Utils::DbUser=$target_db_user;
  $Utils::DbPassword=$target_db_password;
  $Utils::Db=$target_db;
  my $dbh="";
  $dbh=&connect_db($dbh);
}


sub envSelection()
{
  my $ENVIRONMENT;
  my $env_UC=$ENVIRONMENT;
  
  SWITCH: {
    ($env_UC="TL") && do {
      print "Sie sind auf der $env_UC - Umgebung. Viel Spass beim Arbeiten! ;-)\n";
      last SWITCH;	
    };
    ($env_UC="N3") && do {
      print "Sie sind auf der $env_UC - Umgebung. Viel Spass beim Arbeiten! ;-)\n";
      last SWITCH;	
    };
    ($env_UC="O3") && do {
      print "Sie sind auf der $env_UC - Umgebung. Viel Spass beim Arbeiten! ;-)\n";
      last SWITCH;	
    };
    ($env_UC="TI") && do {
      print "Sie sind auf der $env_UC - Umgebung. Viel Spass beim Arbeiten! ;-)\n";
      last SWITCH;	
    };
    ($env_UC="TH") && do {
      print "Sie sind auf der $env_UC - Umgebung. Viel Spass beim Arbeiten! ;-)\n";
      last SWITCH;	
    };
    ($env_UC="TG") && do {
      print "Sie sind auf der $env_UC - Umgebung. Viel Spass beim Arbeiten! ;-)\n";
      last SWITCH;	
    };
    print "Sie verlassen die Auswahl! ;-)\n"; 	
  }
}




# ------------- Ueberpruefung des Eingabe- und Ausgabeformat der AMA CDRs ------------- #
# ----------------------------------------------------------------------------------- #

sub inputCdrAMA()
{

  my @x=();
  my @y=();
  my @array3=();

if ($AMAin =~ m/\.[a-z]*/) {
  chomp($AMAin);
  $AMAin =~ s/\./_\./;
} else {
  print "$AMAin\n";
}

if ($AMAout =~ m/\.[a-z]*/) {
  $AMAout =~ s/\./_\./g;
} else {
  print "$AMAout\n";
}

  my @array=split(/_/,$AMAin);
  my @array2=split(/_/,$AMAout);

  my $a = @array;
  my $b = @array2;

  for($i=0;$i<=$a-1;$i++) {
    for($j=0;$j<=$b-1;$j++) {
      if (@array[$i] eq @array2[$j]){
        $array3[$i][$j]="0";
	    print $i.":".$j.": ".@array[$i]. " " .@array2[$j]. "\n";
      } else {
        $array3[$i][$j]="1";
	    print $i.":".$j.": ".@array[$i]. " " .@array2[$j]. "\n";
	  }
    }
  }

$x[0]=$array3[0][0]&&$array3[0][1]&&$array3[0][2]&&$array3[0][3];  
$x[1]=$array3[1][0]&&$array3[1][1]&&$array3[1][2]&&$array3[1][3];
$x[2]=$array3[2][0]&&$array3[2][1]&&$array3[2][2]&&$array3[2][3];
$x[3]=$array3[3][0]&&$array3[3][1]&&$array3[3][2]&&$array3[3][3];

$y[0]=$array3[0][0]&&$array3[1][0]&&$array3[2][0]&&$array3[3][0];
$y[1]=$array3[0][1]&&$array3[1][1]&&$array3[2][1]&&$array3[3][1];
$y[2]=$array3[0][2]&&$array3[1][2]&&$array3[2][2]&&$array3[3][2];
$y[3]=$array3[0][3]&&$array3[1][3]&&$array3[2][3]&&$array3[3][3];

SWITCH: {
    ($x[0]==1) && do {
      print "$array[0]*\n";
      last SWITCH;	
    };
    ($x[1]==1) && do {
      print "*$array[1]*\n";
      last SWITCH;	
    };
    ($x[2]==1) && do {
      print "*$array[2]*\n";
      last SWITCH;	
    };
    ($x[3]==1) && do {
      print "*$array[3]\n";
      last SWITCH;	
    };
    print "Sie verlassen die Auswahl! ;-)\n"; 	
  } 

SWITCH2: {
    ($y[0]==1) && do {
      print "$array2[0]*\n";
      last SWITCH2;	
    };
    ($y[1]==1) && do {
      print "*$array2[1]*\n";
      last SWITCH2;	
    };
    ($y[2]==1) && do {
      print "*$array2[2]*\n";
      last SWITCH2;	
    };
    ($y[3]==1) && do {
      print "*$array2[3]\n";
      last SWITCH2;	
    };
    print "Sie verlassen die Auswahl! ;-)\n"; 	
  }   


}

# ------------------------------ Fehlerumleitung ------------------------------------ #
# ----------------------------------------------------------------------------------- #

sub Error()
{
  open (FILE,">fehler.txt") or die "Konnte Datei fehler.txt nicht oeffnen: $!\n";
  while (my $line=<FILE>){        
         printf FILE $line;
  }
  close(FILE) or die "Konnte Datei fehler.txt nicht schliessen: $!";
}

# --- Eingabe wird ueberprueft und die Funktionen ausgefuert --- #
&check_options();
foreach  my $function_todo (@{$functions_modus{$modus}})
{
   &{$function_todo} ;
}

# ------------------------------ Ablauf des Programms ------------------------------------ #
# 1) --- Uebergabeordner oeffnen                                                         --- #
# 2) --- Im Uebergabeordner die Datei "Kunden_PSM_$paket.$env_UC anlegen                --- #
# 3) --- Aus den Auftragsverzeichnissen alle CDR-Ordner in den Uebergabeordner kopieren --- #
# 4) --- In den CDRs die Jahreszahl um 28 Jahre in die Zukunft setzen                  --- #
# 5) --- Das Skript "generate.ksh" erzeugen und ausfuehren                              --- #
# 6) --- Alle CDR-Ordner in die Datei "CDRS_PSM_$paket_$env_UC.tar" packen             --- #
# 7) --- Die beiden generierten Dateien in den Ordner                                      #
#    --- "/ccb/ccb20/pkgbata4/pkgbate2/regression_test/Uebergabe_PSM/" uebergeben       --- #
# 8) --- alle neu generierten Ordner loeschen                                           --- #
# ---------------------------------------------------------------------------------------- #
