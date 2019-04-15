
package main;
use strict;
use Mebius::SNS::CommentBoad;


#-----------------------------------------------------------
# 伝言版のコメント削除
#-----------------------------------------------------------
sub auth_comdel{

# 局所化
my($file,$line,$past,$pastline,$deleted_flag);
my($delete_url,@years,%account,$jump_url,$select_year,$yearfile);
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
my($param) = Mebius::query_single_param();
our($postflag,$backurl_jak_flag,$backurl);

	# 送信タイプチェック
	if(!$postflag && !Mebius::alocal_judge()){ main::error("GET送信は出来ません。"); }

	# ログインしていない場合
	if(!$my_account->{'login_flag'}){ main::error("コメントを削除するには、ログインしてください。"); }

# 汚染チェック
my $account = $param->{'account'};
$account =~ s/[^0-9a-z]//g;
	if(Mebius::Auth::AccountName(undef,$account)){ main::error("アカウント名の指定が変です。"); }

#	if($file eq ""){ &error("対象アカウントを指定してください。。"); }

# 年度の定義
$select_year = $param->{'year'};
$select_year =~ s/\D//g;

Mebius::SNS::CommentBoad::query_to_control();

# プロフィールを開く
#Mebius::Auth::File("",$file);

# ロック開始
#&lock("auth$file");

# 現行ログを更新
#($deleted_flag,@years) = file_authcomdel("Nowfile",$file);

	# ●現行ログから年度指定を取り出せなかった場合は、引数から年度を定義
	#if(@years <= 0 && $select_year){
	#	push(@years,$select_year);
	#}
	#if(@years <= 0){ main::error("実行できませんでした。削除できる内容がないか、対象の年度が指定されていません。"); }

	# ●「現行コメント削除」で記憶した年度をすべて展開
	#foreach $yearfile (@years){

		# 年毎の過去ログを更新
	#	if(file_authcomdel("Pastfile",$file,$yearfile)){ $deleted_flag = 1; }
	#}

	# 削除した中身がない場合
	#if(!$deleted_flag){ &error("実行できませんでした。操作できるコメントが存在しないか、既に操作済みです。"); }

# ロック解除
#&unlock("auth$file");


	# リダイレクト（管理モードへ戻る）
	if($backurl_jak_flag && $my_account->{'admin_flag'}){
		Mebius::Redirect("","$backurl&jump=newres");
	}
	# リダイレクト（伝言板へ戻る）
	else{
		Mebius::Redirect("","$basic_init->{'auth_url'}${account}/$param->{'thismode'}#COMMENT");
	}

# 終了
exit;

}



1;
