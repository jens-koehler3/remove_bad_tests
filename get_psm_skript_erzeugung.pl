#!/usr/bin/perl

# --------------------------------------------------- #
# mit diesem Programm werden die benötigten Dateien   #
# generiert die für den PSM-Regressionstest gebraucht #
# werden.                                             #
# Autor:   Koehler, Jens TZEV                         #
# Version: 1.0.1                                      #
# Datum:   22.01.2009                                 #
# Info:                                               #
# ---------------- Version 1.0.0 -------------------- #
# 22.01.2009 schreiben der Version 1.0.0              #
# ---------------- Version 1.0.1 -------------------- #

# --- Deklarationsanfang --- #
# --- Pragmas --- #
use strict  ;
#use warnings ;
# --- special variables --- #
use English ;
# --- Modules --- #
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
use Switch;


# --- lokale Variablen --- #
my $target_db=$ENV{'DB'} ;
my $target_db_user=$ENV{'DB_USER'} ;
my $target_db_password=$ENV{'DB_PASSWORD'} ;
my $kunden ;
my $baseDir = cwd;

# --- Benutzer definierbare lokale Variablen --- #


# --- @Arrays --- #


# --- %Hashes --- #


# --- $Keys --- #


# --- Deklarationsende --- #


# --- Ausgabe des Programmnamen --- #
print "\n". __FILE__ ." wird ausgeführt!\n" ;
print $baseDir."\n";

sub database_abfrage()
{
  $Utils::DbUser=$target_db_user;
  $Utils::DbPassword=$target_db_password;
  $Utils::Db=$target_db;
  my $dbh="";
  $dbh=&connect_db($dbh);
  my $sql=qq(select * from get_psm_package\@ccb20bo3);
  my $sth = $dbh->prepare($sql);
  $sth->execute() ;
  
  while ( my @found = $sth->fetchrow_array )
  {
    $kunden=$kunden."'".$found[0]."','".$found[1]."',\n";
  }
  $kunden=$kunden."\n";
  printf $kunden."\n";

}