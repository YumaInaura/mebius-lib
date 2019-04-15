
use strict;
use Mebius::Penalty;
package main;

#-----------------------------------------------------------
# SNS 日記のレス操作
#-----------------------------------------------------------
sub auth_skeditdiary{

# 宣言
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
my($param) = Mebius::query_single_param();
our($backurl);

	# 送信タイプチェック
	if(!Mebius::Query::post_method_judge() && !Mebius::alocal_judge()){ main::error("GET送信は出来ません。"); }

	# ログインしていない場合
	if(!$my_account->{'login_flag'}){ &error("日記を削除するには、ログインしてください。"); }

# 該当行がない場合
#if(!$flag){ &error("実行できませんでした。既に操作済みか、適切なチェックが入っていません。"); }
my($controled) = Mebius::SNS::Diary::query_to_control();

	# リダイレクト
	if(!Mebius::redirect_to_back_url()){
		Mebius::redirect("$basic_init->{'auth_url'}$controled->{'controled_account'}->[-1]");
	}

	#if($controled->{'thread_delete_flag'}){
	#	Mebius::redirect("$basic_init->{'auth_url'}$controled->{'controled_account'}->[-1]/#DIARY");
	#} else {
	#	Mebius::redirect("$basic_init->{'auth_url'}$controled->{'controled_account'}->[-1]/d-$controled->{'controled_thread'}->[0]#S$controled->{'control_reses'}->[0]");
	#}

# 終了
exit;

}

1;
