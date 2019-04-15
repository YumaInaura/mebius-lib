
# 宣言
package Mebius::Goldcenter;
use Mebius::Auth;
use Mebius::Jump;
use strict;

#-----------------------------------------------------------
# 新規投稿のキャンセルフォーム
#-----------------------------------------------------------
sub form_cancel_newwait{

# 宣言
my($script_mode,$gold_url,$title) = &init();
my(%price) = &get_price();
my($line,$newwait_flag,$newwait_hour,$disabled,$alert);

# 新規投稿の待ち時間を取得
require "${main::int_dir}part_newwaitcheck.pl";
($newwait_flag,$newwait_hour) = main::sum_newwait();

# HTML部分を定義
$line .= qq(
<h3>新規投稿の待ち時間をなくす</h3>
<ul>
<li>必要な金貨: <strong class="red">$price{'cancel_newwait'}枚</strong> / 現在 $main::cgold 枚</li>
<li>現在の待ち時間： $newwait_hour</li>
</ul>
<form action="./" method="post"$main::sikibetu>
<div>
<input type="hidden" name="mode" value="cancel_newwait"$main::xclose>);

	# 実行できない環境の場合
	if(!$main::callsave_flag){ $alert = qq(※この環境では実行できません。); }
	# 新規待ち時間がない場合
	elsif($main::cgold < $price{'cancel_newwait'}){ $alert = qq(※金貨が足りません。); }
	# 金貨が足りない場合
	elsif(!$newwait_flag){ $alert = qq(※待ち時間がありません。); }
	#アラート分の整形
	if($alert && $script_mode !~ /TEST/){ $alert = qq(<span class="alert">$alert</span>); $disabled = $main::parts{'disabled'}; }

# 整形
$line .= qq(
<input type="submit" value="実行する"$disabled$main::xclose>
$main::backurl_input
$alert
</div>
</form>
);

# リターン
return($line);

}





#-----------------------------------------------------------
# 新規投稿の待ち時間をなくす
#-----------------------------------------------------------
sub cancel_newwait{

# 宣言
my($script_mode,$gold_url,$title) = &init();
my(%price) = &get_price();
my($successed);

# 金貨枚数をチェック
&cash_check("REGIST","$price{cancel_newwait}");

# 新規投稿の待ち時間をなくす 
require "${main::int_dir}part_newwaitcheck.pl";
($successed) = main::sum_newwait("UNLINK");

# 成功した場合、金貨を減して、Cookieをセットする
if($successed == 1 ||  $script_mode =~ /TEST/){
$main::cnew_time = undef;
$main::cgold -= $price{cancel_newwait};
Mebius::set_cookie();
&record_spend("RENEW","新規待ち時間を減らしました。");
}

# 失敗した場合、エラーを表示する
else{
main::error("新規投稿の待ち時間がありません。");
}
# ページジャンプ
Mebius::Jump("","$gold_url?$main::backurl_query_enc#SPEND_GOLD","1","新規投稿の待ち時間を減らしました。");

# 終了
exit;

}


#-----------------------------------------------------------
# 金貨のプレゼントフォーム
#-----------------------------------------------------------
sub form_present_gold{

# 宣言
my($type) = @_;
my($line,$value_account,$select_gold,$gave_gold_submit_admin,@piece_of_gold);

# アラート
my($alert,$disabled1) = &cash_check("VIEW",1);

# 初期入力値
$value_account = $main::pmfile;
if($main::in{'account'}){ $value_account = $main::in{'account'}; }

#<input type="text" name="present_gold" value="1" size="5"$disabled1$main::xclose>

# 金貨枚数の選択
@piece_of_gold = (1,2,3,4,5,6,7,8,9,10,20,30);
$select_gold .= qq(<select name="present_gold"$disabled1>);
foreach(@piece_of_gold){
$select_gold .= qq(<option value="$_">$_枚</option>\n);
}
$select_gold .= qq(</select>);

# 金貨の授与ボタン（管理者専用）
if($main::myadmin_flag >= 1){
$gave_gold_submit_admin = qq(
<input type="submit" name="gave_gold" value="授与">
<span class="alert">*授与は管理者専用です。ユーザーへのお礼などに使ってください。自分の金貨は減りませんが、無差別な配布や、自分のアカウントへの配布はやめましょう。</span>
);

}

# HTML部分を定義
#$line .= qq(
#<h3 id="PRESENT_GOLD">金貨をプレゼントする</h3>
#<span style="color:#f00;">*この機能\は停止中です。（<a href="http://mb2.jp/_auth/aurayuma/d-21">詳細</a>）</span>
#<ul>
#<li>他の人(のアカウント)に、金貨をプレゼントできます。金貨が届くと、相手のマイページにお知らせが表\示されます。</li>
#<li>相手のアカウント名が分からない場合は <a href="${main::auth_url}aview-newac-1.html" class="blank" target="_blank">メンバー検索</a> してください。</li>
#<li>必要な金貨: <strong class="red">任意</strong> / 現在 $main::cgold 枚</li>
#</ul>
#<form action="./" method="post"$main::sikibetu>
#<div>
#<input type="hidden" name="mode" value="present_gold"$main::xclose>
#<input type="text" name="account" value="$value_account" size="12"$disabled1$main::xclose> さんに
#$select_gold
#<input type="submit" name="chaise_gold" value="をプレゼント"$disabled1$main::xclose>
#$gave_gold_submit_admin
#$main::backurl_input
#<span class="guide">※アカウント名を半角英数字で、枚数を半角数字で入力してください。</span>
#$alert
#</div>
#</form>
#);



# リターン
return($line);



}

#-----------------------------------------------------------
# 金貨をプレゼント / 授与 ( 管理者チェック処理は bas_gold.pl にあり )
#-----------------------------------------------------------
sub present_gold{

# 宣言
my($type,$account,$present_gold) = @_;
my($script_mode,$gold_url,$title,$gave_gold_type) = &init();
my($message,$message2,$myhandle,%option_renew,%option,$maxgive_perday);

# １日の金貨プレゼントの上限数
if($main::myadmin_flag){ $maxgive_perday = 1000; }
else{ $maxgive_perday = 50; }

# アカウントデータを取得
#(%option) = Mebius::Auth::Optionfile("",$main::pmfile,%option);
(%option) = Mebius::Auth::File("Option",$main::pmfile);

# 日にちが更新されている場合は、金貨プレゼントの上限をリセットする
if($option{'lastpresentgold'} ne "$main::thisyear-$main::thismonthf-$main::todayf"){ $option{'todaypresentgold'} = 0; }

# １日の上限を越えている場合
if($option{'todaypresentgold'} >= $maxgive_perday){ main::error("今日はもう金貨をプレゼントできません ($option{'todaypresentgold'}枚/$maxgive_perday枚) 。明日までお待ちください。"); }

# 金額を定義
if($present_gold =~ /^-/){ main::error("金貨を奪うなんてとんでもないことです。"); }
$present_gold =~ s/\D//g;
$present_gold = int($present_gold);
if($present_gold eq ""){ main::error("金額を指定してください。"); }
if($present_gold > 50){ main::error("枚数が多すぎます。"); }
if($present_gold <= 0){ main::error("枚数を指定してください。"); }

# 汚染チェック
lc $account;
if($account =~ /[^a-z0-9]/){ main::error("相手のアカウント名は半角英数字で指定してください。( 0-9 a-z )"); }
$account =~ s/[^a-z0-9]//g;
if($account eq ""){ main::error("相手のアカウントを指定してください。"); }
if($account eq $main::pmfile && !$main::alocal_mode){ main::error("自分にはプレゼントできません。"); }

# 金額をチェック、アクセス制限
if($type =~ /PRESENT/){ &cash_check("REGIST",$present_gold); }

# 相手のアカウントデータを更新
($myhandle) = &get_handle();
if($type =~ /PRESENT/){ $message2 = qq($myhandle さんから金貨のプレゼントがありました($present_gold枚)。); }
elsif($type =~ /GAVE/){ $message2 = qq($myhandle から金貨の授与がありました($present_gold枚)。); }
main::call_savedata($account,"ACCOUNT RENEW MESSAGE","","$present_gold<>$message2<>");

# 金額を支払い
if($type =~ /PRESENT/){ $main::cgold -= $present_gold; }

# 自分のクッキーをセット
Mebius::set_cookie();

# メッセージを定義
if($type =~ /PRESENT/){ $message = qq(<a href="${main::auth_url}$account/">$account</a> さんに金貨を $present_gold枚プレゼントしました。); }
elsif($type =~ /GAVE/){ $message = qq(<a href="${main::auth_url}$account/">$account</a> さんに金貨を $present_gold枚授与しました。); }

# アカウントの金貨上限数を更新
#$option_renew{'lastpresentgold'} = "$main::thisyear-$main::thismonthf-$main::todayf";
#$option_renew{'todaypresentgold'} = $option{'todaypresentgold'} + $present_gold;
#Mebius::Auth::Optionfile("Renew",$main::pmfile,%option_renew);
$option_renew{'lastpresentgold'} = "$main::thisyear-$main::thismonthf-$main::todayf";
$option_renew{'todaypresentgold'} = $option{'todaypresentgold'} + $present_gold;
Mebius::Auth::File("Renew Option",$main::pmfile,\%option_renew);

# 金貨の使用記録
&record_spend("RENEW","$message");

# ページジャンプ
Mebius::Jump("","$gold_url?$main::backurl_query_enc#PRESENT_GOLD","3","$message");

# 終了
exit;

}


#-----------------------------------------------------------
# 賭け金貨フォーム
#-----------------------------------------------------------
sub form_gyamble1{

# 宣言
my($type,$getgold,$chaise_gold,$viewplus_html) = @_;
my($script_mode,$gold_url,$title) = &init();
my($line,$doubleup_input,$winlose_renew_line,$winlose_handle,$top_winlose,$wingold_all,$losegold_all);
my($winlose_line,$h3,$domain_links);

# アラートを取得
my($alert,$disabled1) = &cash_check("VIEW",1);
my($alert,$disabled2) = &cash_check("VIEW",3);
my($alert,$disabled3) = &cash_check("VIEW",5);

	# ダブルアップ
	if($type =~ /Doubleup/){
	$doubleup_input = qq(
	<input type="submit" name="chaise_gold" value="獲得金貨 ( $getgold枚 )をダブルアップする">
	);
	}

	# 当たり外れ枚数ファイルを開く
	if($type =~ /Winlose-get/){
	open($winlose_handle,"${main::int_dir}_goldcenter/winlose_goldcenter.log");
	flock($winlose_handle,1);
	($top_winlose) = <$winlose_handle>; chomp $top_winlose;
	($wingold_all,$losegold_all) = split(/<>/,$top_winlose);
	close($winlose_handle);
	}

	# 当たり外れ枚数を更新する
	if($type =~ /Winlose-renew/){
		if($type =~ /Result-win/){ $wingold_all += $chaise_gold; }
		else{ $losegold_all += $chaise_gold; }
	$winlose_renew_line = qq($wingold_all<>$losegold_all<>\n);
	Mebius::Fileout("","${main::int_dir}_goldcenter/winlose_goldcenter.log",$winlose_renew_line);
	}

	# 当たり外れ表示を整形
	if($type =~ /Winlose-get/){
	$winlose_line = qq(<h3>全員の成績</h3>
	<ul>
	<li>勝ち： <strong class="red">$wingold_all</strong> 枚</li>
	<li>負け： <strong class="blue">$losegold_all</strong> 枚</li>
	</ul>
	);
	}

	# H3 のリンク定義
	if($type =~ /Page-me/){ $h3 = qq(金貨を賭ける); }
	else{ $h3 = qq(<a href="gyamble1.html">金貨を賭ける</a>); }

# HTML部分を定義
$line .= qq(
$viewplus_html
<h3 id="GYAMBLE1">$h3</h3>
半分の確率で、掛け金(金貨)を倍に出来ます。
<ul>
<li>必要な金貨: <strong class="red">1～10枚</strong> / 現在 $main::cgold 枚</li>
</ul>
<form action="./gyamble1.html" method="post"$main::sikibetu>
<div>
<input type="hidden" name="mode" value="gyamble1"$main::xclose>
<input type="submit" name="chaise_gold" value="1枚賭け"$disabled1$main::xclose>
<input type="submit" name="chaise_gold" value="3枚賭け"$disabled2$main::xclose>
<input type="submit" name="chaise_gold" value="5枚賭け"$disabled3$main::xclose>
$doubleup_input
$main::backurl_input
$alert
</div>
</form>
$winlose_line
);

	# ページとして表示する場合
	if($type =~ /Indexview/){
	
		($domain_links) = Mebius::Domainlinks("","$main::server_domain","_gold/gyamble1.html");

		$main::head_link4 = qq( &gt; 賭け金貨 );
		my $print = qq(<h1>賭け金貨</h1><a href="$gold_url">$titleに戻る</a> 　/　 	$domain_links$line);
		Mebius::Template::gzip_and_print_all({},$print);
	}

# リターン
return($line);

}

#-----------------------------------------------------------
# 金貨を賭ける
#-----------------------------------------------------------
sub gyamble1{

# 宣言
my($type,$in_chaise_gold) = @_;
my($script_mode,$gold_url,$title) = &init();
my($chaise_gold,$getgold,$message,$result,$doubleup_file,$i_double_up,@doubleup_line,$doubleup_gold,$rand);
my($filehandle1,$i_doubleup,$retry_form,$viewplus_html);

# GET送信を禁止
if(!$main::postflag){ main::error("GET送信は出来ません。"); }


	# ダブルアップファイルを定義
	$doubleup_file = "${main::int_dir}_goldcenter/doubleup.log";

		# ダブルアップファイルを開いて掛け金を取得
		open($filehandle1,"<$doubleup_file");
			while(<$filehandle1>){
			$i_doubleup++;
			chomp;
			my($hitflag);
			my($lastgold2,$account2,$k_accesses2,$time2) = split(/<>/,$_);
				if($account2 && $account2 eq $main::pmfile){ $hitflag = 1; }
				if($k_accesses2 && $k_accesses2 eq $main::device{'k_accesses'}){ $hitflag = 1; }
				if($hitflag && $lastgold2){ $doubleup_gold = $lastgold2; }
				if(!$hitflag){ push(@doubleup_line,"$lastgold2<>$account2<>$k_accesses2<>$time2<>\n"); }
				if($i_doubleup >= 50){ next; }
			}
		close($filehandle1);

	# ダブルアップの場合
	if($in_chaise_gold =~ /ダブルアップ/){
	$chaise_gold = $doubleup_gold;
	}

	# 掛け金を選択する場合
	else{
		if($in_chaise_gold =~ /1枚/){ $chaise_gold = 1; }
		elsif($in_chaise_gold =~ /3枚/){ $chaise_gold = 3; }
		elsif($in_chaise_gold =~ /5枚/){ $chaise_gold = 5; }

	# 連続送信を禁止
	#main::redun("Goldcenter","1");

	}

	# 掛け金をチェック、アクセス制限
	&cash_check("REGIST",$chaise_gold);

# まずは掛け金を支払い
$main::cgold -= $chaise_gold;

# 当たり判定
$rand = int rand(100);

# あたりの場合
	if($rand >= 50){
	$getgold = $chaise_gold*2;
	$main::cgold += $getgold;
	$message = qq(当りです！ 金貨 <strong class="red">$getgold</strong> 枚が払い戻されました。 ( <a href="$gold_url">→戻る</a> ) );
	if($chaise_gold >= 50){ &record_spend("RENEW","金貨 $chaise_gold枚を当てました。 "); }
	$result = "win";
	$main::css_text .= qq(ul.result{background:#fdd;padding:1em 2.5em;width:50%;});	
	}

	# 外れの場合
	else{
	$message = qq(外れです。 金貨 <strong class="blue">$chaise_gold</strong> 枚は没収されました。( <a href="$gold_url">→戻る</a> ) );
	$result = "lose";
	$main::css_text .= qq(ul.result{background:#ddf;padding:1em 2.5em;width:50%;});	
}



# クッキーをセット
Mebius::set_cookie();

# ダブルアップファイルに追加する行
if($result eq "win"){
unshift(@doubleup_line,"$getgold<>$main::pmfile<>$main::device{'k_accesses'}<>$main::time<>\n");
}

# ダブルアップ記録ファイルを更新
Mebius::Fileout("Can-Zero",$doubleup_file,@doubleup_line);

# <h3 class="result">結果</h3>
# 引き継ぐHTML
$viewplus_html = qq(
<ul class="result">
<li>$message</li>
<li>判定 ： $rand\p / 50p </li>
</ul>
);

	# 勝った場合、ダブルアップのチャンスを
	if($result eq "win"){
	($retry_form) = &form_gyamble1("Doubleup Winlose-get Winlose-renew Result-win Indexview Page-me","$getgold",$chaise_gold,$viewplus_html);
	}
	else{
	($retry_form) = &form_gyamble1("Winlose-get Winlose-renew Result-lose Indexview Page-me","",$chaise_gold,$viewplus_html);
	}


# 終了
exit;

}



1;
