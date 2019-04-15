
use Mebius::RegistCheck;
use Mebius::AuthAccount;
use Mebius::History;
#use Mebius::AuthServerMove;
use Mebius::SNS::Password;
use Mebius::Auth::AllAccount;
package main;
use strict;
package Mebius::Auth;

#-------------------------------------------------
# 新規登録・ログインフォーム
#-------------------------------------------------
sub Index{

my $type = shift;
Mebius::Login->login_form_view({ SNS_TOP => 1 },@_);

}


1;

