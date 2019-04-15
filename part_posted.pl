
use strict;
use Mebius::BBS;
use Mebius::Handle;
use Mebius::Paint;

#-----------------------------------------------------------
# 投稿後の画面 - strict
#-----------------------------------------------------------
sub regist_posted{

# 宣言
my($type,$i_postnumber,$i_resnumber,$i_sub,$i_com) = @_;
my($my_cookie) = Mebius::my_cookie_main_logined();
my($init_bbs) = Mebius::BBS::init_bbs_parmanent_auto();
my($my_use_device) = Mebius::my_use_device();
my($posted_line,$getgold_line,$nextcharge_line,$newposted_line,$results_line,$kiriban_line,$join_line,$message_line,$cermail_line,$error_cermail,$cermail_message,$tell_deleted_line,$print,$setted_cookie);
our(%in,$realmoto,$moto,$int_dir,$i_res,$new,$sub_title,$head_link3,$head_link4);
our($nextcharge_time,$jump_sec,$jump_url,$server_domain,$moto,$css_text,$i_nam);
our($i_handle,$smlength,$csilver,$kflag,$alocal_mode,$pmfile,$mebicheck_line,$head_title);
our($m_max,$agent,$smlength,$minus_length);
our($door_url,$home,$norank_wait);
our($cookie,$head_javascript);
our($xclose,$agent,$kborder_bottom_in);
my $bbs_path = Mebius::BBS::Path->new($realmoto,$i_postnumber,$i_resnumber);
my $time = time;
my $thread_url = $bbs_path->thread_url_adjusted();

# 記事のトップデータを取得
my($thread) = Mebius::BBS::thread_state($i_postnumber,$realmoto);

# 汚染チェック
$i_postnumber =~ s/\D//g;
$i_resnumber =~ s/\D//g;

# タイトル定義
$sub_title = "投稿画面 | $head_title";
$head_link3 = qq( &gt; <a href="$thread_url">$i_sub</a>);
$head_link4 = " &gt; 投稿成功";

# メビリンチェックを取得
#my($mebicheck_line) = get_mebicheck("",$moto,$i_postnumber,$i_resnumber,$i_sub);
my($mebicheck_line);

# 金貨の増減を計算
require "${int_dir}part_waitcheck.pl";
my($getgold) = getgold_from_comment("",$in{'comment'},$thread->{'concept'});

	# お知らせメールを”登録”
	if($main::in{'email'} && $main::in{'email_tell'} eq "tell"){
		require "${main::int_dir}part_cermail.pl";
		($error_cermail,$cermail_message) = Mebius::Email::SendCermail("BBS-thread Post-regist",$main::in{'email'},$main::moto,$i_postnumber);
		#$main::cemail = $main::in{'email'};
	}

	# 管理者削除のお知らせ
	my(%penalty) = Mebius::penalty_file("Select-auto-file Get-hash-only");
	if($penalty{'tell_flag'}){
		$tell_deleted_line .= qq(<div class="tell_deleted" style="background:#fee;$main::kborder_bottom_in">\n);
		$tell_deleted_line .= qq(<span style="color:#f00;">お知らせ：</span>\n);
		$tell_deleted_line .= qq(　 $penalty{'deleted_link'} で管理者削除がありました。\n);
			if($penalty{'deleted_reason'}){ $tell_deleted_line .= qq(<br$main::xclose><span style="color:#f00;">削除理由：</span>　 $penalty{'deleted_reason'} \n); }
			if($penalty{'deleted_comment'}){
					if($main::kflag){ $penalty{'deleted_comment'} =~ s/<br>/<br$main::xclose>/g; }
				$tell_deleted_line .= qq(<br$main::xclose><span style="color:#f00;">本文：</span>);
				$tell_deleted_line .= qq(<div class="tell_deleted_comment line-height">$penalty{'deleted_comment'}</div>\n);
			}
		$tell_deleted_line .= qq(</div>\n);
	}


	# ●メインの Cookie をセットする
	{
		# セットするクッキーの定義
		my(%set_cookie);

			# ▼一般ユーザー向け
			if(!Mebius::Admin::admin_mode_judge()){
				my($id_history_level) = Mebius::BBS::id_history_level_judge({ from_encoding => "sjis" });
					if($id_history_level->{'set_cookie_value'}){ $set_cookie{'use_id_history'}  = $id_history_level->{'set_cookie_value'}; }
				$set_cookie{'name'} = $i_nam;
				$set_cookie{'+'}{'regist_all_length'} = $smlength;
				$set_cookie{'+'}{'regist_count'} = 1;
				$set_cookie{'last_res_time'} = $time;
				$set_cookie{'wait_second_res'} =  $nextcharge_time;
				$set_cookie{'+'}{'gold'} = $getgold;
			}
			
			# ▼ 管理ユーザー / 一般ユーザー共通
			{
					if($main::in{'email'} ne 'example@ne.jp'){ $set_cookie{'email'} = $main::in{'email'}; }
					if($in{'thread_up'} eq "") { $set_cookie{'thread_up'} = 2; } else { $set_cookie{'thread_up'} = 1; }
					#if($in{'news'} eq "" || $in{'news'} eq "2") { $set_cookie{'bbs_news'} = 2; } else { $set_cookie{'bbs_news'} = 1; }
					if($pmfile){
							if($in{'account_link'} eq "" || $in{'account_link'} eq "2") { $set_cookie{'account_link'} = 2; } else { $set_cookie{'account_link'} = 1; }
							if($in{'account_link'} eq "") { $set_cookie{'account_link'} = 2; } else { $set_cookie{'account_link'} = 1; }
					}
				$set_cookie{'font_color'} = $in{'color'};

			}

		($setted_cookie) = Mebius::Cookie::set_main(\%set_cookie,{ SaveToFile => 1 });

	}

	# ●ユーザー向け処理	
	if(!Mebius::Admin::admin_mode_judge()){

		# 掲示板用のCookieをセット
		Mebius::Cookie::set("bbs",{ last_regist_bbs_kind => $realmoto , last_regist_thread_number => $i_postnumber , last_regist_res_number => $i_resnumber , last_regist_words_length => $smlength , last_get_gold_num => $getgold , last_regist_time => time });

			# 金貨ランキングを更新
			if($my_cookie->{'call_save_data_flag'}){
				require "${main::int_dir}part_newlist.pl";
				Mebius::Newlist::goldranking("RENEW GOLD","","","$setted_cookie->{'gold'}<>$main::pmfile<>$main::i_handle<>$main::encid<>$main::kaccess_one<>$main::k_access");
			}

		# お絵かき画像を確定させる
		Mebius::Paint::Image("Rename-justy Renew-logfile-justy",$in{'image_session'},undef,$server_domain,$realmoto,$i_postnumber,$i_resnumber);
		Mebius::Paint::Image("Posted Renew-logfile-buffer",$in{'image_session'});

		# 筆名ランキングファイルを更新
		Mebius::BBS::Handle("New-count Renew",$main::i_handle,$main::enctrip,$main::thisyear,$main::thismonthf,$main::moto,$main::realmoto,$i_postnumber,$i_resnumber,$i_sub);

	}

	# 国外ドメインでなければ記録
	if($main::host !~ /(\.jp|\.net)$/){
		Mebius::AccessLog(undef,"Foreign-posted");
	}

	# 質問板ではアクセスログを記録
	if($main::realmoto eq "qst"){
		Mebius::AccessLog(undef,"Qst-boad-posted");
	}

	# リダイレクト
	if(!$my_use_device->{'mobile_flag'}){
		Mebius::redirect("$thread_url#S$i_resnumber");

		# レス投稿でお知らせメールを送信
			if($in{'res'}){ thread_sendmail_res("",$moto,$i_postnumber,$i_resnumber,$i_sub,$i_handle,$i_com); }

		exit;
	}


# これまでの成績を取得
($results_line) = &get_results();

# キリ番ゲット
($kiriban_line) = &posted_get_kiriban("",$i_resnumber,$m_max);

# カウントダウンを取得
require "${int_dir}part_timer.pl";
my($head_javascript) = &get_timer("",$nextcharge_time,"posted");

# ○○文字を書き込みました
$posted_line = qq(<strong class="bignum">$smlength文字</strong> を書き込みました。);

# 次回チャージ時間の表示
my($nextcharge_minute,$nextcharge_sec) = &minsec("",$nextcharge_time);
$nextcharge_line .= qq(
<form name="posted" class="nextcharge_line">
<div style="display:inline;vertical-align:bottom;">
次回チャージは
<script type="text/javascript">
<!--
document.write('<input type="text" name="waitsecond" value="" class="wait_input" readonly>');
//-->
</script>
<noscript><p class="noscript">
<span class="nextcharge">次回チャージは $nextcharge_minute分$nextcharge_sec秒 です。</span>
</p></noscript>
です。);

	if($norank_wait){ $nextcharge_line .= qq(（一律）); }
	#else{ $nextcharge_line .= qq(（<a href="/_waitlist/">?</a>）); }
$nextcharge_line .= qq(</div></form>　);

	if($kflag || $agent =~ /Nintendo Wii/){
$nextcharge_line = qq(次回チャージは $nextcharge_minute分$nextcharge_sec秒 です。　);
	}

	# 金貨の増減
	if($cookie){
		if($getgold > 0){ $getgold_line .= qq(たくさん書いたので、金貨が <strong class="plus_gold">$getgold枚</strong> 増えました。); }
		elsif($getgold < 0){
			my $gold = $getgold;
			$gold =~ s/^\-//g;
			$getgold_line .= qq(あまり書かなかったので、金貨が <strong class="minus_gold">$gold枚</strong> 減りました。);
		} else{ $getgold_line .= qq(金貨の増減はありません。); }
		if($setted_cookie->{'gold'} >= 0){ $getgold_line .= qq( <a href="${main::main_url}rankgold-p-1.html"><img src="/pct/icon/gold2.gif" alt="金貨" title="金貨" class="noborder"></a> $setted_cookie->{'gold'}); }
		else{ $getgold_line .= qq( <a href="${main::main_url}rankgold-p-1.html"><img src="/pct/icon/gold2.gif" alt="金貨" title="金貨" class="noborder"></a> <span class="blue">$setted_cookie->{'gold'} (借金)</span>); }
	}
	if($getgold_line){ $getgold_line = qq(<span class="getgold_line">$getgold_line</span>　); }

# キリバンなど
if($kiriban_line){ $posted_line = $kiriban_line; }

	# プレゼントなどメッセージ
	#if($cmessage){
	#	if($kflag){ $message_line = qq(<hr$main::xclose>$cmessage <a href="${main::mainscript}?mode=my&amp;k=1&amp;message_check=1#MESSAGE">?</a>); }
	#	else{ $message_line = qq(<div class="message">$cmessage <a href="${main::mainscript}?mode=my&amp;message_check=1#MESSAGE">?</a></div>); }
	#}

	# 新規投稿の場合
	if($in{'res'} eq ""){
		$newposted_line = qq(<strong class="bignum">$head_title</strong>にまたひとつ、新たな記事が生まれました。);
		($nextcharge_line,$getgold_line) = undef;
	}

	# お知らせメールメッセージ
	if($error_cermail){
		$cermail_line .= qq(次の理由で、お知らせメール登録は出来ませんでした。$error_cermail);
	}
	if($cermail_message){
		$cermail_line .= qq($cermail_message);
	}
	if($cermail_line){
		$cermail_line = qq(<div class="cermail page-width line-height">$cermail_line</div>);
	}

# 携帯設定を再取得
if($kflag){ &kget_items(); }

	# インデックスを取りこんで表示 ( 携帯版 )
	if($kflag){
		$join_line .=  qq(<div style="font-size:small;">);
		$join_line .=  qq(<div style="background:#eee;$main::kborder_bottom_in">$posted_line $newposted_line);
		$join_line .=  qq($nextcharge_line);
		$join_line .= qq((<a href="$i_postnumber.html#S$i_resnumber">→元記事</a> / <a href="./">→掲示板へ</a>) </div>);
		$join_line .= qq($tell_deleted_line);
		$join_line .=  qq($message_line);
		#$join_line .=  qq($line_invite);
		$join_line .=  qq($cermail_line);
		$join_line .=  qq($results_line);
		$join_line .=  qq(</div>);

		$print .= $join_line;

		#require "${int_dir}k_indexview.pl";
		#&view_kindexview("JOIN",$join_line);
	}


	# HTML ( デスクトップ版 )
	else{

		#my($sorcial_line) .= Mebius::Gaget::tweet_button({ url => $thread->{'url'} , title => $thread->{'sub'} });
		my $gaget = new Mebius::Gaget;
		my $sorcial_line = qq( │ ). $gaget->tweet_button({ url => $thread->{'url'} , text => "$thread->{'sub'} | $init_bbs->{'head_title'}" });

		$print .= qq(
		<div class="posted page-width">
		<div class="posted_linetop">$posted_line</div>
		<div class="posted_line">$newposted_line $getgold_line $nextcharge_line $message_line $tell_deleted_line</div>
		<div class="back_links">
		<a href="$door_url">扉</a> &gt; 
		<a href="$home">ＴＯＰページ</a> &gt;
		<a href="/_$moto/">掲示板に戻る</a> &gt; 
		<a href="/_$realmoto/$i_postnumber.html">記事に戻る</a> <a href="/_$realmoto/$i_postnumber.html#S$i_resnumber">( ▼ )</a>
		$sorcial_line
		</div>
		</div>
		$cermail_line
		<div class="left_right page-width">
		$results_line
		$mebicheck_line
		<div class="clear"></div>
		</div>
		);
	}

Mebius::Template::gzip_and_print_all({ head_javascript => $head_javascript },$print);

	if($my_use_device->{'mobile_flag'}){
			if($in{'res'}){ thread_sendmail_res("",$moto,$i_postnumber,$i_resnumber,$i_sub,$i_handle,$i_com); }
	}

exit;

}


#-----------------------------------------------------------
# これまでの成績を取得 - strict
#-----------------------------------------------------------
sub get_results{

# 宣言
my($line,$heikin,$hyouka,$point,$viewgold,$text_comesns,$backurl_gold_query_enc);
our($cookie,$cgold,$csoutoukou,$csoumoji,$idcheck,$guide_url,$server_domain,$css_text);
our($kflag,$xclose,$moto,$server_domain);

# CSS定義
$css_text .= qq(
div.results_body{float:left;width:45%;background-color:#def;border:solid 1px #67f;line-height:1.2em;padding:1.3em 2%;margin:1em 0em 0.5em 0em;}
.seiseki{color:#24f;font-size:110%;}
table,th,tr,td{color:#333;border-style:none;color:#22d;}
table{margin-top:1em;}
td{padding:0.2em 2.0em 0.2em 0.0em;font-size:100%;}
div.results{line-height:1.6em;}
.hyouka{color:#f00;font-size:130%;}
.seiseki_plusgold{font-size:150%;}
.seiseki_minusgold{font-size:140%;color:#00f;}
);

# 金貨リンクの戻り先URLを定義 (携帯版)
$backurl_gold_query_enc = Mebius::Encode("","http://$server_domain/_$moto/");

	# 成績表示 ( 携帯版 )
	if($kflag && $cgold ne "" && $cookie){
		my($average);
			if($csoutoukou && $csoumoji){ $average = int($csoumoji / $csoutoukou); }
			# <a href="$main::gold_url?k=1&amp;backurl=$backurl_gold_query_enc"$main::sikibetu><img src="/pct/icon/gold2.gif" alt="金貨"$xclose></a>
		$line .= qq(
		<span style="color:#f00;">●金貨 $cgold枚 <img src="/pct/icon/gold2.gif" alt="金貨"$xclose> / 投稿 $csoutoukou回 / 平均 $average文字</span> 
		( <a href="http://$server_domain/">$server_domain</a> ) <br$main::xclose>
		);
			$line .= qq(<a href="${main::main_url}rankgold-k-1.html">→金貨ランキング</a>);
			if($main::bbs{'concept'} !~ /Not-handle-ranking/){ $line .= qq( / <a href="./ranking.html">→参加ランキング</a>); }
		return($line);
	}

#<a href="${guide_url}%B6%E2%B2%DF">?</a>

# Cookieが無い場合、リターン
if(!$csoumoji || !$csoutoukou || !$cookie){
$line = qq(
<div class="results_body">
この環境では、成績の記録はありません。
</div>
);
return($line);
}

$heikin = int($csoumoji / $csoutoukou);
$point  = int($heikin + ($cgold*0.5));

# 評価内容を定義

if($csoutoukou >= 250){
if($point >= 2000){$hyouka='あなたこそ聖なるメビラーです！';}
elsif($point >= 1500){$hyouka='全知全能になれそうです！';}
elsif($point >= 1000){$hyouka='全てが手に入りそうです！';}
elsif($point >= 900){$hyouka='無敵艦隊が出動しました！';}
elsif($point >= 800){$hyouka='右脳と左脳がつながりそうです！';}
elsif($point >= 700){$hyouka='言語機関がスパークしそうです';}
elsif($point >= 600){$hyouka='止めるものは何もありません！';}
}

if(!$hyouka && $csoutoukou >= 100){
if($point >= 500){$hyouka='波に乗っています！';}
elsif($point >= 450){$hyouka='スーパーグレートッ！';}
elsif($point >= 400){$hyouka='グ、グレートッ！';}
elsif($point >= 350){$hyouka='グレート！';}
elsif($point >= 300){$hyouka='スーパーエクセレント！';}
elsif($point >= 250){$hyouka='エクセレント！';}
elsif($point >= 200){$hyouka='最高に良く出来ました';}
elsif($point >= 175){$hyouka='素晴らしく良く出来ました';}
elsif($point >= 150){$hyouka='たいへん良く出来ました';}
elsif($point >= 125){$hyouka='とても良く出来ました';}
}

if(!$hyouka){
if($point >= 100){$hyouka='良く出来ました';}
elsif($point >= 75){$hyouka='あと一息です';}
elsif($point >= 50){$hyouka='普通です';}
elsif($point >= 40){$hyouka='まあこんなもんです';}
elsif($point >= 30){$hyouka='頑張りましょう';}
elsif($point >= 20){$hyouka='真面目にやりましょう';}
elsif($point >= 10){$hyouka='あまり良くありません';}
elsif($point >= 5){$hyouka='あんまりです';}
else{$hyouka='評価対象外'}
}

# 金貨枚数の表示を定義
my($txt_gold) = ($cgold);
if($cgold == 0){ $txt_gold = "0"; }
if($cgold >= 0){ $viewgold = qq(<strong class="seiseki_plusgold">$txt_gold枚</strong>); }
else{ $viewgold = qq(<strong class="seiseki_minusgold">$txt_gold枚 (借金)</strong>); }

# ガイドテキスト
if(!$idcheck){ $text_comesns = qq(<tr><td colspan="3"><span class="comesns">※<a href="http://mb2.jp/_auth/">メビリンＳＮＳ</a>に登録/ログインすると、金貨やこれまでの成績が消えにくくなります。</span></td></tr>);  }

$line .= qq(
<div class="results_body">
<strong class="seiseki">●これまでの成績</strong>　( <a href="http://$server_domain/">$server_domain</a> )
<table class="results" summary="これまでの成績">
<tr><td>投稿</td><td>$csoutoukou回</td><td>);

if($main::bbs{'concept'} !~ /Not-handle-ranking/){ $line .= qq(<a href="./ranking.html">→ランキング</a>); }

$line .= qq(</td></tr>
<tr><td>合計</td><td>$csoumoji文字</td><td></td></tr>
<tr><td>平均</td><td>$heikin文字</td><td><a href="/_main/allpost-p-1.html">→サイト全体</a></td></tr>
<tr><td>評価</td><td>$hyouka</td><td></td></tr>
$text_comesns
</table>
</div>
);

return($line);

}


#-----------------------------------------------------------
# メビリンチェックの取得 - strict
#-----------------------------------------------------------
sub get_mebicheck{

# 宣言
my($type,$moto,$i_postnumber,$i_resnumber,$i_sub) = @_;
my($rand_check,$check_print,$after_check_text,$check_title,$kr_view);
my($checked1,$checked2,$check_folder);
our($script,$sikibetu,$int_dir,$sikibetu,$time);
our(%in,$server_domain,$kflag,$checked,$xclose);
our($thisyear,$thismonth,$today,$guide_url,$title,$cemail,$concept);

# 汚染チェック
$moto =~ s/\W//g;
$i_postnumber =~ s/\D//g;
$i_resnumber =~ s/\D//g;

# 投稿後テキストの確率設定
my $rand_m_check = 67;
my $rand_a_check = 24;
my $rand_h_check = 66;

# 今日の絶対日付値を算出(日本時刻)
my $today_time = int( ($time + 9*60*60) / (24*60*60) );

	# メビリンスター
	if(rand(100) < 1){ require "${int_dir}part_star.pl"; ($check_print,$check_title) = &posted_get_star(); }

	# ミッション・チェック
	elsif(rand(3) < 1){

	# 絶対日付でチェックを決定
	$rand_check = $today_time % $rand_m_check;
	if(!$rand_check){ $rand_check = $rand_m_check; }

	$check_title="●ミッションです！ - $thisyear年$thismonth月$today日";
	$check_folder="_check_m";

	($check_print) .= &check_open($check_folder,$rand_check);

	$check_print .= qq(<br>→報告は<a href="http://aurasoul.mb2.jp/_qst/2741.html">報告記事</a>、新提案は<a href="http://aurasoul.mb2.jp/_qst/1989.html">メビ質問板</a>まで。<br>);

	}

	# 関連記事
	elsif(rand(2) < 1 && $concept !~ /NOT-KR/ && -e "${int_dir}_kr/$moto/${i_postnumber}_kr.cgi"){

		# 局所化
		my($maxview);

			# 関連記事の最大表示数
			if($kflag){ $maxview = 3; } else{ $maxview = 5; }

		# 関連記事を取得
		require "${int_dir}part_kr.pl";
		my($kr_line) = related_thread("Index",$moto,$i_postnumber,$maxview); 

		$check_title="●こちらもどうぞ ( 関連リンク )";
		$check_print = qq($kr_line);

	}

	# まりもの一言
	else{

		# 絶対日付でチェックを決定
		$rand_check = $today_time % $rand_h_check;
		if(!$rand_check){ $rand_check = $rand_h_check; }

		$check_title="●まりもの一言 - $thisyear年$thismonth月$today日";
		$check_print .= qq(<div class="dmaricon"><a href="${guide_url}%A4%DE%A4%EA%A4%E2"><img src="/pct/maricon.GIF" alt="まりもアイコン" class="maricon"></a></div>);
		$check_folder="_check_h";
		($check_print) .= &check_open($check_folder,$rand_check);
	}


# 自動リンク
$check_print = &bbs_regist_auto_link($check_print);

$check_print = qq(
<div class="mebi_check">
<strong class="check">$check_title</strong><br$xclose><br$xclose>
$check_print
$after_check_text
</div>
);

	# 携帯版での整形
	if($kflag){
		$check_print =~ s/<br>/<br$xclose>/g;
		$check_print =~ s/<img (.+?)>/<img $1$xclose>/g;
		$check_print =~ s/<input (.+?)>/<input $1$xclose>/g;
		$check_print =~ s/<br$xclose><br$xclose>/<br$xclose>/g;
		$check_print =~ s/<br$xclose>\n<br$xclose>/<br$xclose>/g;
	}

return($check_print);


}

#-----------------------------------------------------------
# メビリンチェックのデータ開く(サブルーチン）
#-----------------------------------------------------------
sub check_open{

# 宣言
my($check_folder,$rand_check) = @_;
my($line);
our($int_dir);

$rand_check =~ s/\D//g;
open(MEBICHECK_IN,"<","${int_dir}$check_folder/$rand_check\.cgi");
while(<MEBICHECK_IN>){ $line .= "$_<br>"; }
close(MEBICHECK_IN);

return($line);

}

#-------------------------------------------------
# キリバン投稿、おめでとうの文章を定義 - stricg
#------------------------------------------------
sub posted_get_kiriban{

# 宣言
my($type,$res,$m_max) = @_;
my($txt_ban,$omedetou_text);
our($m_max,$kflag);

# リターン
if($res <= 0){ return; }

my $res_amari100 = $res % 100;
my $res_amari1000 = $res % 1000;

if($kflag){ $txt_ban = qq($res番目); }
else{ $txt_ban = qq(<strong class="ome">$res番目</strong>); }

if($res =~ /111$/ || $res =~ /222$/ || $res =~ /333$/ || $res =~ /444$/ || $res =~ /555$/ || $res =~ /666$/ || $res =~ /777$/ || $res =~ /888$/ || $res =~ /999$/)
{ $omedetou_text = "$txt_ban（ゾロ）の投稿です。今日は吉日！"; }

if($res_amari100 == 0 && $res){ $omedetou_text = "$txt_banの投稿です。おめでとう！"; }
if($res_amari1000 == 0 && $res){ $omedetou_text = "なんと$txt_banの投稿です。グレート！"; }
if($res == $m_max && $m_max){ $omedetou_text = "うわー！　な、なんと$txt_ban、<br>この記事で最後の書き込みです。本当におめでとう！<br>"; }

return($omedetou_text);

}

1;
