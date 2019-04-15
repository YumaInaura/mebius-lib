
package main;

#-------------------------------------------------
# プロフィール表示
#-------------------------------------------------
sub auth_vrireki{

my($file) = ($in{'account'});

$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("アカウント名を指定してください。"); }

# 新履歴ページにリダイレクト
Mebius::Redirect("","${auth_url}$file/aview-rireki");

}

1;
