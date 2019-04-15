package main;


#-------------------------------------------------
# マイメビ状況をチェック
#-------------------------------------------------
sub do_auth_checkbefriend{

# 局所化
my($file,$deny) = @_;

# 汚染チェック
$file =~ s/[^0-9a-z]//g;

# ログイン中のみ処理実行
if($idcheck){ 
# 申請済みの場合、フラグを立てる
open(BEFRIEND_IN,"${int_dir}_id/$file/${file}_befriend.cgi");
while(<BEFRIEND_IN>){
my($account) = split(/<>/,$_);
if($pmfile eq $account){ $yetplz = 1; }
}
close(BEFRIEND_IN);
}

}

1;
