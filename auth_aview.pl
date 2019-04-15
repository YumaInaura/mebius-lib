use strict;
package main;


#-----------------------------------------------------------
# SNS 一覧ページ各種
#-----------------------------------------------------------
sub auth_aview{

# 宣言
our($submode1,$submode2);
my($init_directory) = Mebius::BaseInitDirectory();

# モード振り分け
if($submode1 eq "iview"){
if($submode2 eq ""){ require "${init_directory}auth_prof.pl"; &auth_prof(); }
}

# 他のモード
if($submode2 eq "friend"){ require "${init_directory}auth_avfriend.pl"; &auth_avfriend(); }
elsif($submode2 eq "befriend"){ require "${init_directory}auth_avbefriend.pl"; &auth_avbefriend(); }
elsif($submode2 eq "prof"){ require "${init_directory}auth_avprof.pl"; &auth_avprof(); }
elsif($submode2 eq "rireki"){ require "${init_directory}auth_avrireki.pl"; &auth_avrireki(); }
elsif($submode2 eq "history"){ require "${init_directory}auth_avhistory.pl"; &auth_avhistory(); }
elsif($submode2 eq "alldiary"){ require "${init_directory}auth_avalldiary.pl"; &auth_avalldiary(); }
elsif($submode2 eq "allcomment"){ require "${init_directory}auth_avallcomment.pl"; &auth_avallcomment(); }
elsif($submode2 eq "allresdiary"){ require "${init_directory}auth_avallresdiary.pl"; &auth_avallresdiary(); }
elsif($submode2 eq "newform"){ Mebius::SNS::NewAccount->mode_junction(); }
elsif($submode2 eq "newac"){ require "${init_directory}auth_view_new_account.pl"; &auth_avnewac(); }
elsif($submode2 eq "login"){ require "${init_directory}auth_avlogin.pl"; &auth_avlogin(); }
else{ &error("ページが存在しません。[aav]"); }

# 廃止モード
#elsif($submode2 eq "allbbs"){ require "${init_directory}auth_avallbbs.cgi"; }

exit;

}

1;
