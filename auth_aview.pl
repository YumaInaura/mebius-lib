use strict;
package main;


#-----------------------------------------------------------
# SNS �ꗗ�y�[�W�e��
#-----------------------------------------------------------
sub auth_aview{

# �錾
our($submode1,$submode2);
my($init_directory) = Mebius::BaseInitDirectory();

# ���[�h�U�蕪��
if($submode1 eq "iview"){
if($submode2 eq ""){ require "${init_directory}auth_prof.pl"; &auth_prof(); }
}

# ���̃��[�h
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
else{ &error("�y�[�W�����݂��܂���B[aav]"); }

# �p�~���[�h
#elsif($submode2 eq "allbbs"){ require "${init_directory}auth_avallbbs.cgi"; }

exit;

}

1;
