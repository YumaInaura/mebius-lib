
use strict;
use Mebius::SNS::Crap;
package Mebius::Auth;

#-----------------------------------------------------------
# いいね！モード
#-----------------------------------------------------------
sub CrapStart{

# 宣言
my($type) = @_;
my $select_account = shift;
my $diary_number = shift;
my($redirect_url,$plustype_crap,$not_renew_ranking_flag);


	# ログインチェック
	Mebius::LoginedCheck("Error-view");

	# アクセス制限
	main::axscheck("ACCOUNT");

	# 相手のファイルを開く
	my(%account) = Mebius::Auth::File("File-check-error",$select_account);

	# いいね！の拒否設定をチェック
	if(!$account{'allow_crap_diary_flag'}){ main::error("このメンバーはいいね！を許可していません。"); }

	# 自分のアカウントのCharチェック
	Mebius::Auth::CharCheck("Error-view");

	# 日記を開く
	my($diary) = Mebius::Auth::diary("Level-check-error Crap-check",$account{'file'},$diary_number);

	# いいね！ランキングに登録禁止している場合
	if($diary->{'not_crap_ranking_flag'}){ $not_renew_ranking_flag = 1; }

	# お互いのマイメビ状態 / 禁止状態をチェック
	my($friend_status1) = Mebius::Auth::FriendStatus("Deny-check-error",$account{'file'},$main::myaccount{'file'});
	my($friend_status2) = Mebius::Auth::FriendStatus("Deny-check-error",$main::myaccount{'file'},$account{'file'});

	# マイメビだけに日記を公開している場合 ( ランキングに登録しない)
	if($account{'osdiary'} eq "2" && $friend_status1 ne "friend"){ main::error("$main::friend_tag以外はいいね！できません。"); }
	if($account{'osdiary'} eq "2"){ $not_renew_ranking_flag = 1; }

	# 対象ファイル
	if($main::in{'target'} eq "diary"){
		$plustype_crap .= qq( Diary-file); 
		$redirect_url = "${main::auth_url}$account{'file'}/d-$diary_number";
	}
	else{
		main::error("いいね！タイプを選んでください。");
	}

	# 実行タイプ

	# 新規いいね！
	if($main::in{'action_type'} eq "new_crap"){
		$plustype_crap .= qq( New-crap); 
			if($select_account eq $main::myaccount{'file'} && !$main::alocal_mode){ main::error("自分にはいいね！できません。"); }
	}
	# いいね！の削除
	elsif($main::in{'action_type'} eq "delete_crap"){

		$plustype_crap .= qq( Delete-crap); 

			# 各種エラー
			if($main::in{'target_account'} eq ""){ main::error("削除対象となるアカウントを選んでください。"); }

			# 削除権限チェック
			if($main::in{'target_account'} ne $main::myaccount{'file'} && $account{'file'} ne $main::myaccount{'file'} && !$main::myadmin_flag){
				main::error("このいいね！を削除する権限がありません。");
			}

	}
	# それ以外
	else{
		main::error("実行タイプを選んでください。");
	}

	# いいね！を実行
	my(%crap) = Mebius::Auth::Crap("Renew $plustype_crap",$account{'file'},$diary_number,$main::in{'target_account'});

	# 新着情報
	if($main::in{'action_type'} eq "new_crap"){
		Mebius::Auth::News("Renew Log-type-crap",$account{'file'},$main::myaccount{'file'},$main::myaccount{'handle'},qq(<a href="${main::auth_url}$account{'file'}/d-$diary_number">$diary->{'subject'}</a> へのいいね！ ($crap{'count'})));
	}

	# 日記の日付を算出
	my(%time) = Mebius::Getdate("Get-hash",$diary->{'posttime'});

		# 今日の日記じゃない場合は、ランキング登録しない
		#if($time{'ymdf'} ne $main::ymdf){ $not_renew_ranking_flag = 1; }

	# いいね！ランキングを更新
	if($main::in{'action_type'} eq "new_crap" && !$not_renew_ranking_flag){
		Mebius::Auth::CrapRankingDay("New-crap Renew",$time{'yearf'},$time{'monthf'},$time{'dayf'},$crap{'count'},$account{'file'},$diary_number,$diary->{'subject'});
	}

	# いいね！ランキングを更新 ( いいね！を削除した時 )
	if($main::in{'action_type'} eq "delete_crap" && !$not_renew_ranking_flag){
		Mebius::Auth::CrapRankingDay("Delete-crap Renew",$time{'yearf'},$time{'monthf'},$time{'dayf'},$crap{'count'},$account{'file'},$diary_number,$diary->{'subject'});
	}

	# 自分のオプションファイルを更新 ( おそらく最終活動時刻を記録している )
	#Mebius::Auth::Optionfile("Renew My-file",$main::myaccount{'file'});
	Mebius::Auth::File("Renew My-file Option",$main::myaccount{'file'});

	# リダイレクト
	Mebius::Redirect(undef,$redirect_url);


exit;

}

#-----------------------------------------------------------
# いいね！一覧を表示
#-----------------------------------------------------------
sub CrapIndexViewStart{

# 宣言
my($type,$yearf,$monthf,$dayf) = @_;
my(%crap_ranking,%crap_ranking_month,$h1_title);

	# 各種エラー
	if($yearf =~ /\D/ || $yearf eq ""){ main::error("年を指定してください。"); }
	if($monthf =~ /\D/ || $monthf eq ""){ main::error("月を指定してください"); }
	if($dayf =~ /\D/){ main::error("日の指定が変です。"); }
	if($main::submode_num > 3){ main::error("このモードは存在しません。"); }

	# いいね！ランキングの日毎ログを取得
	if($dayf){
		(%crap_ranking) = Mebius::Auth::CrapRankingDay("Diary-file Get-topics File-check-error",$yearf,$monthf,$dayf,10);

		# タイトル定義
		$main::sub_title = qq($yearf年$monthf月$dayf日のいいね！ランキング | $main::title);
		$main::head_link3 .= qq(&gt; いいね！ランキング);
		$main::head_link4 .= qq(&gt; $yearf年$monthf月$dayf日);
		$h1_title = qq($yearf年$monthf月$dayf日のいいね！ランキング);

	}

	# いいね！ランキングの月別メニューを取得
	else{
		(%crap_ranking_month) = Mebius::Auth::CrapRankingMonth("Get-index File-check-error",$yearf,$monthf);

		# タイトル定義
		$main::sub_title = qq($yearf年$monthf月のいいね！ランキング | $main::title);
		$main::head_link3 .= qq(&gt; いいね！ランキング);
		$main::head_link4 .= qq(&gt; $yearf年$monthf月);
		$h1_title = qq($yearf年$monthf月のいいね！ランキング);

	}

	# 現在の日付をグリニッジ標準時に変換
my($time_local) = Mebius::TimeLocal(undef,$main::submode2,$main::submode3,$main::submode4);

# 次の日付と前の日付を取得
#my(%tomorrow) = Mebius::Getdate("Get-hash",$time_local + (24*60*60));
#my(%yesterday) = Mebius::Getdate("Get-hash",$time_local - (24*60*60));
#<a href="./crapview-$yesterday{'ymdf'}.html">←前の日</a>
#<a href="./crapview-$tomorrow{'ymdf'}.html">次の日→</a>



# HTML書き出し
my $print = qq(
<h1$main::kstyle_h1>$h1_title</h1>

<h2$main::kstyle_h1>一覧</h2>
<div>
$crap_ranking{'topics_line'}
$crap_ranking_month{'index_line'}
</div>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


1;
