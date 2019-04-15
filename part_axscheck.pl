
use strict;
use Mebius::Access;
use Mebius::Text;
package main;

#-------------------------------------------------
# 投稿制限
#-------------------------------------------------
sub do_axscheck{

# 局所化
my($basic_init) = Mebius::basic_init();
my($my_cookie) = Mebius::my_cookie_main();
my($my_real_device) = Mebius::my_real_device();
my($my_access) = Mebius::my_access();

my($type) = @_;
my($message_nohost,$leftday,$leftday_view);
my($deny_flag,$block,$reason,$blocktime,$delcount,$alldelcount,$type_guide,$block_type);
my($alert_domain_flag,$alert_domain_flag_decide);
my($env_deny_flag,$i_forwarded,$forwarded_split1,$forwarded_split2,%penalty,$second_domain);
our($pmfile,$device_type,$agent,$addr,$server_domain,$strong_emd,$cgold);
our($agent,$e_access,$cookie,$guide_url,$cnumber);
our($k_access,$kaccess_one,$concept,$int_dir,$time,$postflag,$alocal_mode);

# 重複クッキーセットを回避
$main::no_headerset = 1;

# アクセス情報を取得
my($access) = Mebius::my_access();

	# GET送信を禁止
	if($type =~ /Post(-)?only/ && $ENV{'REQUEST_METHOD'} ne "POST"){
		Mebius::AccessLog(undef,"Request-method-is-strange","\$ENV{'REQUEST_METHOD'} : $ENV{'REQUEST_METHOD'}");
		main::error("送信方法が変です。");
	}

	# プロクシを禁止
	#my($error_flag_proxy) = Mebius::ProxyJudge();

	# ボットは原則禁止
	if($type !~ /Allow-bot/){
		my($bot_flag) = Mebius::Device::bot_judge();
			if($bot_flag){
				Mebius::AccessLog(undef,"Bot-axscheck-deny");
				main::error("Botからはこの操作はできません。");
			}
	}

	# 妙なアクセスは記録
	#if(!$ENV{'HTTP_REFERER'}){ Mebius::AccessLog(undef,"No-referer-post"); }
	#if(!$ENV{'HTTP_COOKIE'}){ Mebius::AccessLog(undef,"No-cookie-post"); }
	if(!$ENV{'HTTP_COOKIE'} && !$my_access->{'mobile_flag'}){
	#if(!$my_cookie->{'char'} && !$my_access->{'mobile_flag'}){
		Mebius::AccessLog(undef,"No-cookie-post-without-mobile"); 
		main::error("書き込むにはCookieをオンにしてください。");
	}


	if($ENV{'HTTP_REFERER'} && $ENV{'HTTP_REFERER'} !~ m!^https?://([a-z0-9\.]+\.)?mb2.jp/! && !$main::alocal_mode){
		Mebius::AccessLog(undef,"Strange-referer-regist","Referer: $ENV{'HTTP_REFERER'}");
	}
	
	# ログインチェックをする場合
	if($type =~ /Login-check/){
			if(!$main::myaccount{'file'}){ $e_access .= qq(▼この操作をするには、アカウントに<a href="${main::auth_url}">ログイン</a>してから再度お試しください。<br$main::xclose>); }
	}

# ホスト名を取得する ( IP から逆引き )
my($gethost_multi) = Mebius::GetHostWithFileMulti();
our $host = $gethost_multi->{'host'};
my($alert_domain_flag) = Mebius::HostCheck(undef,$gethost_multi->{'host'},$addr,$gethost_multi->{'isp'},$gethost_multi->{'second_domain'});
	if($alert_domain_flag){ $alert_domain_flag_decide = 1; }

	# ●プロクシのIPアドレスを展開
	foreach $forwarded_split1 (split(/,/,$ENV{'HTTP_X_FORWARDED_FOR'},-1)){

		# 局所化
		my($plustype_hostcheck_forwarded);

		# ラウンドカウンタ
		$i_forwarded++;


			if($addr eq $forwarded_split1){
				$env_deny_flag = 1;
				Mebius::AccessLog(undef,"Deny-axscheck","\$ENV{'HTTP_X_FORWARDED_FOR'} IP重複 : $main::addr / $ENV{'HTTP_X_FORWARDED_FOR'}");
				Mebius::AccessLog(undef,"Deny-forwarded","\$ENV{'HTTP_X_FORWARDED_FOR'} IP重複 : $main::addr / $ENV{'HTTP_X_FORWARDED_FOR'}");
			}

			# リレーが多すぎる場合はエラーに
			if($i_forwarded >= 3){
				$env_deny_flag = 1;
				Mebius::AccessLog(undef,"Deny-axscheck","\$ENV{'HTTP_X_FORWARDED_FOR'} リレー数超過 : $ENV{'HTTP_X_FORWARDED_FOR'}");
				Mebius::AccessLog(undef,"Deny-forwarded","\$ENV{'HTTP_X_FORWARDED_FOR'} リレー数超過 : $ENV{'HTTP_X_FORWARDED_FOR'}");
				last;	# 処理しすぎないように終了させておく
			}

		# IPからホスト名を取得
		my($gethost_forwarded) = Mebius::GetHostMulti({ Addr => $forwarded_split1 , TypeWithFile => 1 });

		# ホストチェックのタイプを定義 ( 本ホストが jp ドメインの場合は、空白チェックをしない )
		if(!$alert_domain_flag){ $plustype_hostcheck_forwarded .= qq( Not-empty-check); }
		# ホストチェック
		my($alert_domain_flag_forwarded) = Mebius::HostCheck("$plustype_hostcheck_forwarded",$gethost_forwarded->{'host'},$forwarded_split1,$gethost_forwarded->{'isp'},$gethost_forwarded->{'second_domain'});

			if($alert_domain_flag){ $alert_domain_flag_decide = 1; }

			# 投稿制限/アカウント禁止状態をチェック(プロクシのホスト)
			(%penalty) = Mebius::penalty_file("Axscheck Host Renew Relay-hash",$gethost_forwarded->{'host'},$type,%penalty);

	}

	# プロクシ変数を記録
	#if($main::env{'num'} >= 1 && !$main::bot_access){ Mebius::AccessLog(undef,"Proxy-about"); }

	# 無制限許可ドメインではなく、Cookieなしの場合は、スパムとして投稿を禁止 ( ホスト名判定 )
	if(!$cookie && !$k_access && $alert_domain_flag_decide){
		$env_deny_flag = 1;
			Mebius::AccessLog(undef,"Deny-axscheck","クッキーなし&ドメイン制限： $gethost_multi->{'host'}");
			Mebius::AccessLog(undef,"Deny-not-cookie","クッキーなし&ドメイン制限： $gethost_multi->{'host'}");
	}

	if(!$my_cookie->{'char'} && $host =~ /\.(panda-world\.ne\.jp)$/){
		$env_deny_flag = 1;
	}

	# DOCOMOで固体識別番号がない場合
	if($k_access eq "DOCOMO" && ($device_type eq "mobile" || !$agent) && $postflag && !$kaccess_one){
		$e_access .= "▼荒らし防止のため<a href=\"$guide_url%B8%C7%C2%CE%BC%B1%CA%CC%C8%D6%B9%E6\">固体識別番号</a>を送信してください。（$basic_init->{'mailform_link'}）<br>";
		Mebius::AccessLog(undef,"Docomo-utn-error");
	}

	# 変なUA/プロクシのUAを制限
	if($ENV{'HTTP_USER_AGENT'} eq "" || length($agent) > 500 || $ENV{'HTTP_USER_AGENT'} =~ /(Gateway|Proxy|\(http)/i){
		$env_deny_flag = 1;
		Mebius::AccessLog(undef,"Deny-axscheck","ユーザーエージェント制限： $ENV{'HTTP_USER_AGENT'}"); 
		Mebius::AccessLog(undef,"Deny-user-agent","ユーザーエージェント制限： $ENV{'HTTP_USER_AGENT'}"); 
	}

	# 変なUAをチェック
	if($ENV{'HTTP_USER_AGENT'} !~ /(^Mozilla|^Opera|^KDDI|^DoCoMo|^SoftBank|^Vodafone|^J-PHONE|^Nokia|^SAMSUNG)/){
		Mebius::AccessLog(undef,"Strange-user-agent","変なユーザーエージェント： $ENV{'HTTP_USER_AGENT'}"); 
	}

	# サイト外部からのリファラを禁止する
	if($ENV{'HTTP_REFERER'}){
		my($hit_flag);
			foreach(@{$basic_init->{'all_domains'}}){
				if($ENV{'HTTP_REFERER'} =~ m!http://$_/!){ $hit_flag = 1; }
			}
			if(!$hit_flag){
				# $env_deny_flag = 1;
				#Mebius::AccessLog(undef,"Deny-axscheck","リファラ制限： $ENV{'HTTP_REFERER'}"); 
				#Mebius::AccessLog(undef,"Deny-referer","リファラ制限： $ENV{'HTTP_REFERER'}"); 
			}
	}

	# 接続環境に制限がある場合、ここでエラーを追加（エラー文を重複表示しないように）
	if($env_deny_flag){ $e_access = qq(▼この環境からは送信できません。（ $basic_init->{'mailform_link'} ）<br>); }

	# アカウントキーでロック
	if($main::myaccount{'key'} eq "2" && $type =~ /ACCOUNT/ && $type !~ /NOLOCK/){
		&error("あなたのアカウントはロック中です。");
		Mebius::AccessLog(undef,"Accout-lock-axscheck","$main::myaccount{'file'}");
	}


# 投稿履歴ファイルから投稿制限
my($history_access) = Mebius::History::AccessCheck();
	if($history_access->{'error_flag'}){ main::error("$history_access->{'error_flag'}"); }


	# 投稿制限/ペナルティ状態をチェック
	my(%penalty) = Mebius::penalty_file("Axscheck Check-penalty Cnumber Relay-hash",$main::cnumber,$type,%penalty);
	my(%penalty) = Mebius::penalty_file("Axscheck Check-penalty Agent Relay-hash",$agent,$type,%penalty);
	my(%penalty) = Mebius::penalty_file("Axscheck Check-penalty Account Relay-hash",$pmfile,$type,%penalty);
	my(%penalty) = Mebius::penalty_file("Axscheck Check-penalty Isp Relay-hash",$gethost_multi->{'isp'},$type,%penalty);
	my(%penalty) = Mebius::penalty_file("Axscheck Check-penalty Addr Relay-hash",$addr,$type,%penalty);
	my(%penalty) = Mebius::penalty_file("Axscheck Check-penalty Host Relay-hash",$gethost_multi->{'host'},$type,%penalty);

	# 自分のペナルティデータ ( ホスト名データ )を、グローバル変数に代入
	%main::mypenalty = %penalty;

	# ●外部サイトからのユーザー判定
	if($main::mypenalty{'Hash->from_other_site_time'}){
		my(%other_site) = Mebius::FromOtherSite("Get-hash");
			if($other_site{'error_flag'}){ main::error($other_site{'error_flag'}); }
		#if($main::alocal_mode){ main::error("$penalty{'Hash->from_other_site_url'}"); }
	}

	# ●投稿制限されておらず、削除ペナルティが存在する場合
	if(time < 1373525416 + 24*60*60 && $ENV{'HTTP_HOST'} =~ /sns|aurasoul/){
		0;
	} elsif(!$penalty{'Block->block_flag'} && $penalty{'Penalty->penalty_flag'} && $main::bbs{'concept'} !~ /NOT-PENALTY/){

		my(%set_cookie);
		my($my_cookie) = Mebius::my_cookie_main_logined();

			# 新しいペナルティの場合、金貨枚数を減らす
			if(($penalty{'Penalty->new_penalty_flag'} || $main::alocal_mode) && $main::cgold ne ""){
					# 金貨がもともとプラスの場合
					if($my_cookie->{'gold'} >= 1){
						$set_cookie{'-'}{'gold'} = $penalty{'Penalty->count'}*10;
						$set_cookie{'>='}{'gold'} = -10;
					}
					# 金貨がもともとマイナスかゼロの場合
					else{ $set_cookie{'-'}{'gold'} = $penalty{'Penalty->count'}*5; }
			}

				# クッキーをセット
				if($penalty{'Penalty->set_cdelres_time'} > $my_cookie->{'deleted_time'}){
					$set_cookie{'deleted_time'} = $penalty{'Penalty->set_cdelres_time'};
				}
			Mebius::Cookie::set_main(\%set_cookie,{ SaveToFile => 1 });

			# ペナルティ画面を表示する
			Mebius::TellPenaltyView(undef,\%penalty);

	}

	# 投稿制限が回避される場合
	if($penalty{'Block->exclusion_block_flag'}){
		0;
	}

	# ●投稿制限中の場合
	elsif($penalty{'Block->block_flag'}){
		$e_access .= qq($penalty{'Block->block_message'});
		$main::strong_emd++;
			if($penalty{'Block->block_reason'} eq "98"){ Mebius::AccessLog(undef,"Open-proxy-auto-block","公開プロクシ： $addr / $host "); }
	}

	# アカウント作成制限
	if($type =~ /Make-account/){
			if($access->{'low_level_flag'}){ main::error("この環境ではアカウントを作成できません。"); }
			if($penalty{'Block->block_make_account_flag'}){ main::error("現在、アカウントを作成できません。"); }
	}

	# すぐにエラー表示に移動する場合
	if($e_access){ Mebius::AccessLog(undef,"Deny-axscheck"); }
	if($type !~ /LAG/ && $e_access){ main::error("$e_access"); }

# リターン
return($host,$deny_flag);

}

package Mebius::History;

#-----------------------------------------------------------
# 投稿履歴ファイルを使って、投稿制限チェック # SSS => 動作確認？
#-----------------------------------------------------------
sub AccessCheck{

# 宣言
my($use) = @_;
my(%data);

# モジュール読み込み
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}part_history.pl";

# 相応アクセス情報
my($access) = Mebius::my_access();

# ホスト情報
my($multi_host) = Mebius::GetHostWithFileMulti();

	# CCC 不具合確認
	if($multi_host->{'addr_to_host_flag'}){ Mebius::AccessLog(undef,"Addr-to-host","$multi_host->{'host'}"); }

# 投稿履歴 ( ホスト / マルチ )
my(%history_host) = main::get_reshistory("TOPDATA My-file HOST",$multi_host->{'host'});
my($history_multi) = Mebius::my_history_include_host();

	# １時間あたりの投稿文字数が多すぎる場合 (記録)
	if($history_host{'all_length_per'} >= 2*10000 || $history_multi->{'all_length_per'} >= 2*10000){
		$data{'error_flag'} .= qq(▼[ 1時間 ] に [ 10000文字 ] より多くは書き込めません。しばらくお待ちください。<br>);
		#Mebius::Echeck::Record(undef,"All-Error");
		#Mebius::Echeck::Record(undef,"Per-length-error");
		Mebius::AccessLog(undef,"Per-length-error","$history_host{'all_length_per'}文字");
	}

	# １時間あたりの投稿文字数が多すぎる場合 (エラー)
	elsif($history_host{'all_length_per'} >= 2*5000 || $history_multi->{'all_length_per'} >= 2*5000){
		#$data{'error_flag'} .= qq(▼[ 1時間 ] に [ 10000文字 ] より多くは書き込めません。しばらくお待ちください。<br$main::xclose>);
		#Mebius::Echeck::Record(undef,"All-Error");
		#Mebius::Echeck::Record(undef,"Per-length-error");
		Mebius::AccessLog(undef,"Per-length-check","$history_host{'all_length_per'}文字");
	}

	# 特定のアクセス環境で、1時間あたりの投稿数を制限する ( ホスト名の投稿履歴ファイルでだけ判定 )
	my $max_regist_per = 20;
	if($access->{'low_level_flag'}){
			if($history_host{'regist_count_per'} >= $max_regist_per || $history_multi->{'regist_count_per'} >= $max_regist_per){
				Mebius::AccessLog(undef,"Low-level-max-regist-per-hour","判定タイプ： $access->{'low_level_error_type_message'}");
				$data{'error_flag'} .= qq(▼この環境では、書き込める回数に制限があります。しばらく経ってからまたお試しください。<br>);
			}
	}

return(\%data);

}

package main;

#-----------------------------------------------------------
# トリップ機能
#-----------------------------------------------------------
sub get_trip{

# 宣言
my($name) = @_;
my($trip_key) = ('x6');
my($max_sharp);
my $text = new Mebius::Text;
our($e_com,$enctrip,$i_name,$i_handle,$i_trip,$trip_concept);

# 値のチェック/変換
$name =~ s/★/？/g;
$name =~ s/☆/？/g;
$name =~ s/&amp;([#a-zA-Z0-9]+);/□/g;

	if($text->match_shift_jis($name,"＃")){
		$e_com .= qq(▼名前に全角のハッシュ \(＃\) は使えません。<br>); 
	}
#$name = $text->replace_shift_jis_text($name,"＃","#");

	# ハンドルとトリップ、特殊キーを分離
	my($handle,$trip,$tripconcept_text) = split(/#/,$name);

	# ●特殊キーによる動作を定義
	if($tripconcept_text =~ /IdChange/){
		$trip_concept .= qq( Id-change);
	}
	if($tripconcept_text =~ /(履歴|りれき)オフ|history-off/i){
		$trip_concept .= qq( Not-history);
	}
	if(length($tripconcept_text) > 20) {
		$e_com .= qq(▼筆名の特殊キー ( $tripconcept_text ) が長すぎます。半角 20文字以内で指定してください。<br$main::xclose>);
	}

	# 半角シャープの個数
	if($trip_concept){ $max_sharp = 2; } else{ $max_sharp = 2; }
	if(($name =~ s/#/$&/g) > $max_sharp){
		$e_com .= qq(▼筆名の中の # ( 半角シャープ/イゲタ ) が多すぎます。# はトリップ素の文字列としては認識されません。 <br$main::xclose>);
	}

	# ●トリップありの場合
	if($trip ne ""){

		# グローバル変数を代入
		$i_handle = $handle;
		$i_trip = $trip;

		# トリップの素チェック
		my $trip_length = length($i_trip);
		if($i_handle eq $i_trip){
			$e_com .= qq(▼筆名 ( $i_handle ) と、トリップの素 ( #$trip ) を全く同じものには出来ません。トリップの素には、推測されにくい文字列を使ってください。<br>);
		}
		if($trip_length > 20) { $e_com .= qq(▼トリップの素 ( #$trip ) が長すぎます。半角 20文字以内にしてください。<br>); }
		if($trip_length < 2) { $e_com .= qq(▼トリップの素 ( #$trip ) が短すぎます。半角 2文字以上にしてください。<br>); }

			# MD5暗号化
			if($trip_length > 8) {
				($enctrip) = Mebius::Crypt::crypt_text("MD5","$i_trip",$trip_key,12);
			}

			# CRYPT 暗号化
			else{
				($enctrip) = crypt($i_trip, $trip_key) || crypt ($i_trip, '$1$' . $trip_key);
				$enctrip =~ s/^..//;
			}

		$main::handle_and_enctrip = "$i_handle☆$enctrip";
		if($i_trip eq "MebiHost"){ $enctrip = ""; }

	}

	# ●トリップなしの場合
	else {
		$i_handle = $name;
		$main::handle_and_enctrip = "$i_handle";
	}

# 元の入力を再定義
$i_name = undef;
$i_name .= $i_handle;
if($trip){ $i_name .= qq(#$trip); }
if($tripconcept_text){ $i_name .= qq(#$tripconcept_text); }

return($enctrip,$i_handle,$i_name,$i_trip,$trip_concept);

}


1;
