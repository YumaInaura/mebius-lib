
use strict;
package main;
use Mebius::Export;
use Mebius::Penalty;
use Mebius::BBS::Wait;
use Mebius::Email;

#-----------------------------------------------------------
# 現在のチャージ時間を取得 ( レス ) - strict
#-----------------------------------------------------------
sub get_nowcharge_res{

# 宣言
my($type,$comment) = @_;
my $penalty = new Mebius::Penalty;
my $email = new Mebius::Email;
my $bbs_wait = new Mebius::BBS::Wait;
my($my_cookie) = Mebius::my_cookie_main_logined();
my($share_directory) = Mebius::share_directory_path();
my($liberation_time,$nowcharge_time,$allcharge_time,$line_errorview);
my($long_length,$short_length,$javascript_value,$bonus_time,$allow_bonus_flag,$maxbonus_second);
my($lastrestime,$lastwaitsecond,$waitguide_link,$isp_data,$data);
my $time = time;

our($kflag,$xclose,$head_javascript,$line_noscript,$css_text,$agent,$cookie);
our($cres_time,$cres_waitsecond,$int_dir,$xip_enc,$xip,$no_xip_action,$alocal_mode);


	if($ENV{'REQUEST_METHOD'} eq "POST"){
		$isp_data = $penalty->my_isp_data();
	}

	if($isp_data->{'must_compare_xip_flag'}){

		my $message = "ISP $isp_data->{'file'} / フラグ $isp_data->{'must_compare_xip_flag'} / 前回のレス時間 $lastrestime / 待ち秒数 $lastwaitsecond / 現在時刻 $time";
		Mebius::access_log("BBS-wait-res",$message);
		$email->send_email_to_master("怪訝なISP",$message);
	}

	# リターン
	if($type =~ /REGIST/ && $comment !~ /wait/ && (Mebius::alocal_judge() || $main::bbs{'concept'} =~ /Local-mode/)){ return; }

	
	if( my $cookie_data = $bbs_wait->fetchrow_main_table_desc({ cnumber => $my_cookie->{'char'} },"create_time")->[0] ){
		$data = $cookie_data
	} else{
		$data = $bbs_wait->fetchrow_main_table_desc({ xip => $xip },"create_time")->[0];
	}

$lastrestime = $data->{'submit_time'};
$lastwaitsecond = $data->{'wait_second'};

# 現チャージ時間を最終計算 ( 共通処理 )
$liberation_time = $lastrestime + $lastwaitsecond;	# 解放時間
$nowcharge_time = $liberation_time - $time;			# 現在のチャージ時間
$allcharge_time = $liberation_time - $lastrestime;	# チャージ時間の長さすべて

	# ボーナス時間適用を許可する
	if($type =~ /REGIST/ && $cookie){ $allow_bonus_flag = 1; }
	if($my_cookie->{'call_save_data_flag'}){ $maxbonus_second = 30; }
	else{ $maxbonus_second = 45; }


	# 現在の文字数に応じて、チャージ時間を短くする ( ボーナス時間算出 )
	if($allow_bonus_flag){
		require "${int_dir}regist_allcheck.pl";
		($long_length,$short_length) = &get_length("",$comment);
		$bonus_time = int($short_length / 5);
		if($bonus_time >= $allcharge_time - $maxbonus_second){ $bonus_time = $allcharge_time - $maxbonus_second; } # ～秒以上は短くしない
		$nowcharge_time -= $bonus_time;
	}


# CSSを定義
$css_text .= qq(
div.charge{border:1px #000 solid;padding:1em;background-color:#eee;line-height:1.6;}
);
	#if(Mebius::alocal_judge() && $ENV{'REQUEST_METHOD'} eq "POST"){ Mebius::Debug::Error(qq($lastrestime / $time )); }

	# チャージ時間が0の場合、リターン
	if($nowcharge_time <= 0){ return; }

# ガイドリンクを定義
$waitguide_link = qq( ( <a href="${main::guide_url}%A5%C1%A5%E3%A1%BC%A5%B8%BB%FE%B4%D6" target="_blank" class="blank">→詳細</a> ));


		$javascript_value = "RESFORM";

	# タイマーを定義
	require "${int_dir}part_timer.pl";
	($head_javascript,$line_noscript) = &get_timer("",$nowcharge_time,"$javascript_value");
	shift_jis($head_javascript,$line_noscript);


	# 携帯版のエラー表示
	if($kflag || $agent =~ /Nintendo Wii/){
		$line_errorview .= qq(▼チャージ中です。あと $line_noscript で書き込めます。);
	}

	# ＰＣ版のエラー表示
	else{

		# エラー表示
		$line_errorview .= qq(
		▼チャージ中です。
		<script type="text/javascript">
		<!--
		document.write('あと <input type="text" name="waitsecond" value="" class="wait_input" readonly> で書き込めます。$waitguide_link');
		//-->
		</script>
		<noscript><p class="noscript">
		あと <strong class="red">$line_noscript</strong> で書き込めます。$waitguide_link
		</p></noscript>
		);
	}

	# ボーナス時間のお知らせ
	if($allow_bonus_flag){
		$line_errorview .= qq(<br$xclose>　 たくさん書けば、現在のチャージ時間も短く出来ます。（文字数稼ぎは禁止です）<br$xclose>);
	}



return($line_errorview);

}

#-----------------------------------------------------------
# 文字数に応じて、次回のチャージ時間を計算 - strict
#-----------------------------------------------------------
sub get_nextcharge_res{

# 宣言
my($type,$comment) = @_;
my($wait_minute,$bonus,$under_second,$lefttime,@waitlist,@kwaitlist,$top_second);
our($plus_bonus,$device_type,$k_access,$norank_wait);
our($idcheck,$plus_bonus,$csoutoukou,$int_dir,$deconum);

	# チャージ時間一律の場合
	if($norank_wait){
		$lefttime = $norank_wait*60;
			if($lefttime > 30){ $lefttime = 30; }
		return($lefttime);
	}

# ＰＣ版チャージ時間の設定 ( 金貨なしの場合、金貨マイナスの場合 )
@waitlist = (
'200=0.5',
'150=1.0',
'100=1.5',
'75=2.0',
'50=3.0',
'30=3.5',
'0=4.0'
);

	# 携帯チャージ時間の設定 ( 金貨なしの場合、金貨マイナスの場合 )
	if($device_type eq "mobile" || $k_access || $main::device{'type'} eq "Portable-game-player"){
		@waitlist = (
		'150=0.5',
		'125=0.75',
		'100=1.0',
		'75=1.25',
		'50=1.5',
		'40=1.75',
		'30=2.0',
		'20=2.25',
		'10=2.5',
		'0=5.0'
		);
	}


# 文字数の判定
require "${int_dir}regist_allcheck.pl";
my($long_length,$short_length) = &get_length("",$comment,$deconum);

# 文字数によって次回チャージ時間を計算
my($hlength,$hnext);
	foreach(@waitlist){
		my($length,$next) = split(/=/,$_);
			if($short_length >= $length){
				$wait_minute = $next;
				last;
			}
		($hlength,$hnext) = ($length,$next);
	}

# 分数を秒数に変換
$lefttime = $wait_minute*60;

# 掲示板ボーナスを加算
$lefttime -= $plus_bonus;

	# スペシャル会員ボーナスを追加
	if($idcheck && $main::myaccount{'level2'} >= 1 && $main::myaccount{'key'} eq "1"){ $lefttime -= 15; }

	# 次回チャージの下限値を決める
	$under_second = 60;												# 普通の上限
	if($main::cgold >= 10){ $under_second = 45; }					# 金貨判定
	if($main::cgold >= 25){ $under_second = 30; }					# 金貨判定
	if($device_type eq "mobile"){ $under_second = 30; }				# 携帯では無条件に下限を最短に
	if($lefttime < $under_second){ $lefttime = $under_second; }		# 適用

	# 次回チャージの上限値を決める
	$top_second = 5*60;
	if($main::cgold eq ""){ $top_second = 3.0*60; }
	if($main::cgold >= 1){ $top_second = 3.0*60; }
	if($main::cgold >= 10){ $top_second = 2.5*60; }
	if($main::cgold >= 25){ $top_second = 2.0*60; }
	if($main::cgold >= 50){ $top_second = 1.5*60; }
	if($main::cgold >= 100){ $top_second = 1.0*60; }
	if($top_second && $lefttime > $top_second){ $lefttime = $top_second; }					# チャージ時間に上限を適用

	# 金貨が少ない場合はチャージ時間を長くする (携帯からの投稿は除外)
	if($device_type eq "mobile" || $k_access || $main::device{'type'} eq "Portable-game-player"){	}
	else{
			if($main::cgold <= -150){ $lefttime += 3.0*60; }
			elsif($main::cgold <= -100){ $lefttime += 2.0*60; }
			elsif($main::cgold <= -50){ $lefttime += 1.0*60; }
			elsif($main::cgold <= -25){ $lefttime += 0.5*60; }
	}

# リターン
return($lefttime);

}


#-----------------------------------------------------------
# 次回のチャージ時間ファイルを作成 - strict
#-----------------------------------------------------------
sub renew_nextcharge_res{

# 宣言
my($type,$nextcharge_time) = @_;
my $bbs_wait = new Mebius::BBS::Wait;
my($share_directory) = Mebius::share_directory_path();
my($my_cookie) = Mebius::my_cookie_main();
my(@line,%insert);
our($xip);

$insert{'target'} = $bbs_wait->new_target();
$insert{'cnumber'} = $my_cookie->{'char'};
$insert{'xip'} = $xip;
$insert{'submit_time'} = time;
$insert{'wait_second'} = $nextcharge_time;

$bbs_wait->delete_record_from_main_table({ cnumber => $my_cookie->{'char'} });
$bbs_wait->delete_record_from_main_table({ xip => $xip });
$bbs_wait->insert_main_table(\%insert);

}



#-----------------------------------------------------------
# 文字数に応じて金貨の枚数を計算 - strict
#-----------------------------------------------------------
sub getgold_from_comment{

# 宣言
my($type,$comment,$thread_concept) = @_;
my($getgold,@gold,$bonusday_flag);
our($norank_wait,$concept);

# 金貨対文字数の設定
@gold = (
"500=6",
"400=4",
"300=3",
"200=2",
"100=1",
"35=0",
"0=-1"
);

# コメント文字数の計算
my($long_length,$short_length) = &get_length("",$comment);

	# 金貨の増減
	foreach(@gold){
		my($length,$gold) = split(/=/);
			if($short_length >= $length){ $getgold = $gold; last; }
	}

	# 記事の設定によっては金貨を増やさない
	if($thread_concept =~ /Not-gold/){ $getgold = 0; }

	# 掲示板の設定によっては金貨を増やさない、もしくは半減させる
	if($concept =~ /Not-gold/){ $getgold = 0; }
	if($concept =~ /Get-gold-over-([0-9\.]+)/ && $getgold >= 1){ $getgold = int($getgold*$1); }

	# コメント内容によっては金貨を増やさない
	if($getgold >= 1 && $comment =~ /(経験値を)/){ $getgold = 0; }

	# モードによって金貨を減らさない
	if($getgold < 0 && $norank_wait){ $getgold = 0; }

	# 金貨ボーナスDAY
	if($main::wday eq "火" && $getgold >= 1){ $getgold *= 2; $bonusday_flag = 1; }

return($getgold,$bonusday_flag);

}

1;
