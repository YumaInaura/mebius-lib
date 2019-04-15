
package main;
use strict;

#-------------------------------------------------
# マイメビ状況をチェック
#-------------------------------------------------
sub do_auth_checkfriend{

# 局所化
my($account,$deny) = @_;
my($top,$yetfriend_flag);
our($yetfriend,$denyfriend,$myadmin_flag);

# 自分のアカウントを取得
my($my_account) = Mebius::my_account();

	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

	# ログイン中のみ処理実行
	if($my_account->{'file'}){

		# アカウント名判定
		if(Mebius::Auth::AccountName(undef,$my_account->{'file'})){ return(); }

		# マイメビ登録済みの場合、フラグを立てる
		open(SFRIEND_IN,"<","${account_directory}friend/$my_account->{'file'}_f.cgi"); # $pmfile は間違いではないはず
		$top = <SFRIEND_IN>;
		my($key) = split(/<>/,$top);
		if($key eq "1"){ $yetfriend = $yetfriend_flag = 1; }
		elsif($key eq "0" && !$myadmin_flag){ $denyfriend = 1; }
		close(SFRIEND_IN);
	}

return($yetfriend_flag);

}

1;
