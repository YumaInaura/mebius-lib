
package main;

use Mebius::RegistCheck;
use Mebius::Access;
use Mebius::Encoding;


use Mebius::Export;

use strict;

#-----------------------------------------------------------
# 処理スタート
#-----------------------------------------------------------
sub bbs_regist{

# 宣言
our(%in,$no_headerset,$mode,$category,$s_min_msg,$i_nam2);
my($kback_link_tell);
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}regist_allcheck.pl";

# ロボットよけなど
$no_headerset = 1;

	# 掲示板全体で投稿停止中の場合
	if(Mebius::Switch::stop_bbs()){ main::error("掲示板全体で投稿停止中です。"); }

	# 創作モード設定
	if($main::bbs{'concept'} =~ /Sousaku-mode/) {
			if($category eq "poemer"){ our $min_msg = $s_min_msg; our $norank_wait = 1.0; }
			if($category eq "novel"){ our $norank_wait = 1.0; }
		our $new_min_msg = 50;
		our $ngbr = 400;
	}

	# チャットモード設定
	if($main::bbs{'concept'} =~ /Chat-mode/){
		our $wait = 0.5;
		our $max_msg = 80;
		our $min_msg = 2;
		our $new_min_msg = 50;
		our $norank_wait = 0.5;
	}

# 携帯版の場合
#if($in{'res'}){ $kback_link_tell = "$main::in{'res'}.html"; }
if($in{'k'}){ kget_items(); }

	# 記録内容の定義 (管理モード)
	if(Mebius::Admin::admin_mode_judge()){
		my($my_admin) = Mebius::my_admin();

		#$pwd = '管理者';
		#if($in{'normal_user'} && $my_admin->{'master_flag'}){ $pwd = "＠"; }
		# 筆名を定義
		$i_nam2 = $my_admin->{'name'};
		#if($in{'name'} && $my_admin->{'master_flag'}){ $i_nam2 = $in{'name'}; }
		if($in{'normal_user'} && $my_admin->{'master_flag'}){ $i_nam2 = qq(あうらゆうま); }
		else{
			our $new_res_concept .= qq(Admin-regist);
		}
		if($in{'nameplus'}){ $i_nam2 = "$i_nam2($in{'nameplus'})"; }	

	# 記録内容の定義 (通常モード)
	} else {

		# 入力内容を定義
			if($in{'other_name'}){ our $i_nam = $in{'other_name'}; }
			else{ our $i_nam = $in{'name'}; }

	}

# 記録内容の定義 ( 共通 )
our $i_com = $in{'comment'};
	if(Mebius::Admin::admin_mode_judge()){
		($i_com) = Mebius::Fixurl("Admin-to-normal",$i_com);
	}

	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($i_com)); }

our $i_res = $in{'res'};
$i_res =~ s/\D//g;
our $i_sub = $in{'sub'};


	# サイト全体の新着レスから、重複投稿のチェック ( すべての文章変換が終わった後に判定 )
	if(!Mebius::Admin::admin_mode_judge()){
		regist_double_check("",$i_com);
	}

	# モード切替え
	if($mode eq "regist_resedit") { require "${init_directory}part_resedit.pl"; &thread_resedit(); }
	elsif($mode eq "regist") { &regist_bbs(); }

exit;

}


#-------------------------------------------------
# 記事投稿処理
#-------------------------------------------------
sub regist_bbs{

# 宣言
my($basic_init) = Mebius::basic_init();
my($init_directory) = Mebius::BaseInitDirectory();
my($i_resnumber,$i_postnumber,$i_sub,$image_data,$plustype_history_not_open);
my($my_account) = Mebius::my_account();
my $query = new CGI;
my $bbs_thread = new Mebius::BBS::Thread;
my $history = new Mebius::History;
my($content_create_time);
my($param) = Mebius::query_single_param();
my $encoding = new Mebius::Encoding;
my $all_comments = new Mebius::AllComments;

our($server_domain,$nextcharge_time,$time,%in,$host,$i_com,$i_sub,$i_nam,$i_res,$cnumber,$pmfile,$i_handle,$category,$moto,$realmoto,$secret_mode,$head_title,$crireki,$sexvio,$head_title,$e_com,$kaccess_one,$upload_file,$upload_flag,$new_res_concept,$rcevil_flag,$i_nam2,$encid);

# アクセス制限
($host) = main::axscheck();

#トリップ付与、ID付与
main::trip($i_nam);
if(Mebius::Admin::admin_mode_judge()){ $encid = "管理者"; }
else{ ($encid) = main::id(); }

	# 画像添付
	if($main::bbs{'concept'} =~ /Upload-mode/){
		if($upload_flag){ main::upload(); }
		main::upload_setup();
	}


	# スタンプの処理 ( 文字数稼ぎ防止の為、基本エラーチェック内の 文字数カウントを実行する前に処理する ) ( A-1 )
my($error_stamp) = Mebius::Stamp::regist_error({ FromEncoding => "sjis" },"comment");
	if($error_stamp){
			foreach(@$error_stamp){
				$e_com .= qq(▼$_<br>);
			}
	}

# 不正なスタンプを削除
($i_com) = Mebius::Stamp::erase_invalid_code($i_com);

# 基本エラーチェック (A-2)
main::base_error_check();

	# テンプレをそのまま投稿できないように
	if($main::bbs{'textarea_first_input'} && $main::bbs{'textarea_first_input'} eq $main::in{'comment'}){
		$main::e_com .= qq(▼投稿フォームのテンプレートをそのまま書きこむことは出来ません。必要な部分を追加、修正してください。<br$main::xclose>); 
	}

	# メルアドチェック
	if($main::in{'email'} && $main::in{'email_tell'} eq "tell"){
		my($error_format) = Mebius::mail_format(undef,$main::in{'email'});
			if($error_format){ $main::e_com .= qq(▼$error_format<br$main::xclose>); }
	}

	# 本文に画像を追加
	if($upload_file){ ($i_com) = main::upload_com($i_com); }


my $comment_utf8 = utf8_return($i_com);
	if($all_comments->dupulication_error($comment_utf8)){
		$e_com .= "▼重複投稿です。";
	}


	if($i_nam2){ $i_handle = $i_nam2; }

	# ●新規投稿
	if($i_res eq "") {
		require "${init_directory}part_post.pl";
		($i_postnumber,$i_resnumber,$i_sub) = regist_post("",$image_data);
		$content_create_time = time;
	}

	# ●レス投稿
	else{

		require "${init_directory}part_res.pl";
		($i_postnumber,$i_resnumber,$i_sub,$i_com,$new_res_concept,$content_create_time) =	regist_res("",$i_res,$i_handle,$i_com,$main::in{'color'},$encid,$main::myaccount{'file'},$new_res_concept,$image_data);
	}

	# レス監視
	if($main::bbs{'concept'} !~ /Sousaku-mode/){
		rcevil("$rcevil_flag","$i_com","$i_handle","http://$server_domain/_$moto/$in{'res'}.html-$i_resnumber","$i_sub");
	}

$all_comments->submit_new_comment($comment_utf8);

	# ●ユーザー向け処理
	if(!Mebius::Admin::admin_mode_judge()){

		# ▼関連記事を作成
		if(Mebius::alocal_judge() || $main::bbs{'concept'} =~ /Local-mode/ || ($crireki ne "off" && rand(3) < 1 && !$sexvio) ){
			require "${init_directory}part_kr.pl";
			open_kr("REGIST",$realmoto,$i_postnumber,$i_sub);
		}

		# ▼フォロー用ファイルを更新
		my $bbs_status = new Mebius::BBS::Status;
		require "${init_directory}part_follow.pl";
		my $follow_regist = { server_domain => $main::server_domain , real_bbs_kind => $realmoto , bbs_kind => $moto , res_number => $i_resnumber, thread_number => $i_postnumber, last_handle => $i_handle, cnumber => $main::cnumber , account => $main::myaccount{'file'}, subject => $i_sub , regist_time => time , bbs_title => $main::title , last_update_time => time , all_regist_count => ['+','1'] };
		my $follow_regist_utf8 = Mebius::Encoding::hash_to_utf8($follow_regist);
		$bbs_status->update_main_table($follow_regist_utf8);

		# 投稿履歴を記録
		require "${init_directory}part_history.pl";

			# 投稿履歴更新の、共通コンセプト ( ID / トリップ履歴以外 )
			if($main::crireki eq "off"){ $plustype_history_not_open .= qq( New-line-hidden); }

		# 投稿履歴に記録する内容
		my $postdata_history = "$i_sub<>$i_postnumber<>$i_resnumber<>$realmoto<>$head_title<>$server_domain<>$encid<>$in{'comment'}<>$nextcharge_time<><>$main::i_handle<>$main::encid<>";

			# 投稿履歴を記録（アカウント） 
			if($pmfile){
				get_reshistory("ACCOUNT RENEW REGIST My-file $plustype_history_not_open",$pmfile,undef,$postdata_history);
					if($query->param('account_link') && !Mebius::BBS::secret_judge()){
						get_reshistory("Open-account RENEW REGIST My-file",$pmfile,undef,$postdata_history);
					}
			}

			# 投稿履歴を記録（管理番号） - Cookieがオフの環境で、$cnumber がコロコロ変りそうな場合は記録しない
			if($cnumber){
				get_reshistory("CNUMBER RENEW REGIST My-file $plustype_history_not_open",$cnumber,undef,$postdata_history);
			}

			# 投稿履歴を記録（個体識別番号）
			if($kaccess_one){
				get_reshistory("KACCESS_ONE RENEW REGIST My-file $plustype_history_not_open",undef,undef,$postdata_history);
			}

			# 投稿履歴を記録（ホスト名）
			else{
				get_reshistory("HOST RENEW REGIST My-file HOST $plustype_history_not_open",$host,undef,$postdata_history);
			}

			# 投稿履歴を記録（トリップ）
			if($main::trip_history_flag){
				get_reshistory("TRIP RENEW REGIST My-file",$main::enctrip,undef,$postdata_history);
			}

			# 投稿履歴を記録（ID）
			my($id_history_judge) = Mebius::BBS::id_history_level_judge({ from_encoding => "sjis" });
			if($id_history_judge->{'record_flag'}){
				get_reshistory("ENCID RENEW REGIST My-file",$main::pure_encid,undef,$postdata_history);
			}

			# 
			if($my_account->{'login_flag'}){

			}

			# 投稿履歴を記録（筆名）
			{
				get_reshistory("HANDLE RENEW REGIST My-file $plustype_history_not_open",$main::i_handle,undef,$postdata_history);
			}


			# 投稿履歴を記録（ISP）
			{
				get_reshistory("ISP RENEW REGIST My-file $plustype_history_not_open",undef,undef,$postdata_history);
			}

			# 外部サイトを経由した場合
			if($main::mypenalty{'Hash->from_other_site_flag'}){
				Mebius::FromOtherSite("Renew New-regist");
				require "${init_directory}part_newlist.pl";
				Mebius::Newlist::threadres("RENEW From-other-site-file","","","","$realmoto<>$head_title<>$i_postnumber<>$i_resnumber<>$i_sub<>$i_handle<>$i_com<>$category<>$pmfile<>$encid<>");

			}

	}


	# お知らせメールを配信（秘密板）
	#if($in{'res'} && $secret_mode){ sendmail_scres("SECRET",$moto,$i_postnumber,$i_resnumber,$i_sub,$i_handle,$i_com); }

	# アラートを突破した場合、注意投稿を記録
	if($main::a_com && !Mebius::Admin::admin_mode_judge()){
		my($alert_type);
			foreach(@main::alert_type){
				$alert_type .= qq( $_);
			}
		require "${init_directory}part_newlist.pl";
		Mebius::Newlist::threadres("RENEW ECHECK","","","","$realmoto<>$head_title<>$i_postnumber<>$i_resnumber<>$i_sub<>$i_handle<>$i_com<>$category<>$pmfile<>$encid<>$alert_type");
	}
	
	# 全ての投稿を記録
	if(!Mebius::Admin::admin_mode_judge()){
		Mebius::BBS::ThreadStatus->update_table({ bbs_kind => $realmoto , thread_number => $i_postnumber , res_number => $i_resnumber , handle => utf8_return($i_handle) , subject => utf8_return($i_sub) , regist_time => time , category => $category });
	}

	{

		my $hidden_from_friends = $history->hidden_from_friends_judge_on_param();
 

		my $subject_utf8 = utf8_return($i_sub);
		my $handle_utf8 = utf8_return($i_handle);


	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($handle_utf8)); }

		my %insert_for_history = ( bbs_kind => $realmoto , thread_number => $i_postnumber , subject => $subject_utf8 , handle => $handle_utf8 , last_response_num => $i_resnumber , last_response_target => $i_resnumber , content_create_time => $content_create_time , hidden_from_friends_flag => $hidden_from_friends );
			if($i_res eq "") {
				$bbs_thread->create_common_history_on_post(\%insert_for_history);
			} else {
				$bbs_thread->create_common_history(\%insert_for_history);
			}
	}

# 投稿後の画面へ
require "${init_directory}part_posted.pl";
regist_posted("",$i_postnumber,$i_resnumber,$i_sub,$i_com);

exit;

}

#-----------------------------------------------------------
# 基本エラーチェック
#-----------------------------------------------------------
sub base_error_check{

# 宣言
my($type) = @_;
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my(%reshistory,$doubleflag);
our(%in,$emd,$xclose,$category,$new_res_concept,$i_com,$i_sub,$host,$min_msg,$e_com,$i_handle,$i_res,$concept,$moto,$pmfile,$max_msg,$e_access,$cookie,$ngbr,$postflag,$getflag,$k_access,$deconum,$brnum);

# カテゴリ設定を取得
my($init_category) = Mebius::BBS::init_category();

	# ホストがなければ取得
	if(!$host){
		our($host) = Mebius::GetHostWithFile();
	}

	# オーバーフローチェック
	Mebius::Regist::OverFlowCheck(undef,$main::in{'comment'});

	# 各種エラー
	if(!$postflag && !$getflag) { $e_access .= qq(▼不正なアクセスです。<br>); }

# 取り込み処理
require "${init_directory}regist_allcheck.pl";

# 基本変換
($i_com) = &base_change($i_com);

	# レスjコンセプトを定義 - フォントの種類
	if(($i_com =~ s/\[等幅\]//g) >= 1){ $new_res_concept .= qq( Fontfamily<'ＭＳ ゴシック'>); }

	# レスjコンセプトを定義 - トリップ投稿履歴
	if($main::enctrip && $main::trip_concept !~ /Not-history/ && !Mebius::BBS::secret_judge() && !Mebius::Admin::admin_mode_judge()){
		$new_res_concept .= qq( Tripory);
		$main::trip_history_flag = 1;
	}

	# レスjコンセプトを定義 - ID投稿履歴
	my($id_history_judge) = Mebius::BBS::id_history_level_judge({ from_encoding => "sjis" });

	if($id_history_judge->{'record_flag'} && !Mebius::SNS::admin_judge()){
		$new_res_concept .= qq( Idory5);
	}

	# レスjコンセプトを定義 - アカウント名の記録
	if($pmfile){ 
			if($in{'account_link'}){
					if(!Mebius::BBS::secret_judge()){	$new_res_concept .= qq( Accountory); }
			}	else{
				$new_res_concept .= qq( Hide-account);
			}
	}

	# レスコンセプトを定義 - 外部サイト経由のユーザー
	if($main::mypenalty{'Hash->from_other_site_flag'}){
		$new_res_concept .= qq( From-other-site-$main::mypenalty{'Hash->from_other_site_file_type'});
	}

	# スパム対策
	if(!$cookie && !$k_access && $host !~ /(\.jp$|\.com$|\.net$|^localhost$)/){
		$e_access = qq(▼国外からのスパムをブロック中です（テスト運用）。送信できない場合は<a href="http://aurasoul.mb2.jp/etc/mail.html">メールフォーム</a>からお知らせください。<br>);
	}


	# 改行制限
	if($brnum > $ngbr) {
		$e_com .= "▼改行が多すぎます。改行部分を減らしてください。（ 現在$brnum個 / 最大$ngbr個 ）<br>";
		Mebius::Echeck("","BR-OVER-ERROR",$i_com);
	}

# プラスモード
my($plustype_registcheck);
if($main::bbs{'concept'} =~ /Sousaku-mode/){ $plustype_registcheck .= qq( Sousaku); }

	# ローカル等で全チェックを回避
	if((Mebius::alocal_judge() && $main::in{'comment'} =~ /break/) || Mebius::Admin::admin_mode_judge()){ 

	# 普通に判定
	}else{

		# 各種チェック
		Mebius::Regist::private_check("$plustype_registcheck Sjis-to-utf8",$i_com,$category,$concept);

			# 雑談化/チャット化判定
			if(($main::bbs{'concept'} =~ /Block-convesation/ || $init_category->{'concept'} =~ /Block-convesation/) 
			&& $main::bbs{'concept'} !~ /Allow-convesation/){
				Mebius::Regist::ConvesationCheck("$plustype_registcheck",$i_com,$category,$concept);
			}

			#  && $i_res ne "" #新規投稿時は判定を避ける場合
			if($moto ne "btn"){ Mebius::Regist::ChainCheck("$plustype_registcheck",$i_com,$category,$concept); }
		&url_check("$plustype_registcheck",$i_com,$category,$concept);
		Mebius::Regist::sex_check("$plustype_registcheck Sjis-to-utf8",$i_com,$category,$concept);
		Mebius::Regist::EvilCheck("$plustype_registcheck",$i_com,$category,$concept);

		(undef,$deconum)  = &deco_check("$plustype_registcheck",$i_com,$category,$concept) if($moto ne "delete");
		space_check("$plustype_registcheck",$in{'comment'},$category,$concept);	# あえて $in{'comment'}
		shift_jis(($i_handle) = Mebius::Regist::name_check($i_handle));
	}

	# 題名の基本チェック
	if($i_res eq ""){ ($i_sub) = &subject_check("$plustype_registcheck",$i_sub,$category,$concept); }

# 文字数チェック
our($bglength,$smlength) = &get_length("Decoration-cut",$in{'comment'},$deconum);

# 文字色チェック
($in{'color'}) = Mebius::Regist::color_check(undef,$in{'color'});

	# レス投稿の文字数制限
	if($i_res && !Mebius::Admin::admin_mode_judge()) {
			if ($bglength > $max_msg) { $e_com .= "▼本文の文字数が多すぎます。（ 現在$bglength文字 / 最大$max_msg文字 ）<br>"; $emd = 1; }
			if ($smlength < $min_msg && $main::bbs{'concept'} !~ /Local-mode/) { $e_com  .= qq(▼本文の文字数が少なすぎます。（ 現在$smlength文字 / 最小$min_msg文字 ）<br>); $emd++; }
	}

	# 共通の判定
	if(($i_com eq "")||($i_com =~ /^(\x81\x40|\s|<br>)+$/)) { $e_com .= "▼本文がありません。何か書いてください。<br>"; $emd = 1; }

}

#-----------------------------------------------------------
# お知らせメールを送信 - strict
#-----------------------------------------------------------
sub thread_sendmail_res{

# 局所化
my($type,$moto,$i_postnumber,$i_resnumber,$i_sub,$i_handle,$i_com) = @_;
my($body1,$body2,$subject,$open,$text,$text_length,$timeout_flag,$sendmail_handler);
our($alocal_mode,$secret_mode,$int_dir,%in,$title,$server_domain,$myadmin_flag);
our($cemail,$thishour,$moto);

# URL
my $url = "_$moto";

# 汚染チェック
$moto =~ s/\W//g;
$i_postnumber =~ s/\D//g;
	if($moto eq "" || $i_postnumber eq ""){ return; }

	# 本文の省略
	foreach( split(/<br>/,$i_com) ){
			if($text_length < 50){ $text .= qq(${_} ); }
		$text_length += length $_;
	}

# 秘密板
if($secret_mode){ $text = qq(内容は掲示板で確認してください); }

# 件名
$subject = qq(「$i_sub」に $i_handleさん が投稿しました);

# ノーマルの文章
$body1 = qq(メビウスリングの【$title】に更新があったので、お知らせいたします。

▼$i_handle > $text …

▼$i_sub - $title
  http://$server_domain/_$moto/$i_postnumber.html

▼レスを表\示
  http://$server_domain/_$moto/$i_postnumber.html#S$i_resnumber
);

# シンプルな文章
$body2 = qq(URL:http://$server_domain/_$moto/${i_postnumber}.html#S$i_resnumber
);

# 配信用ファイルを開く
open($sendmail_handler,"<","$main::bbs{'data_directory'}_sendmail_${moto}/${i_postnumber}_s.cgi") || return();

	# ファイルを展開
	while(<$sendmail_handler>){

		# 分解
		chomp;
		my($body);
		my($address2) = split(/<>/,$_);
		my($address_encoded2) = Mebius::Encode(undef,$address2);

		# アドレス単体ファイルを取得
		my(%address) = Mebius::Email::address_file(undef,$address2);
		if($address{'deny_flag'}){ next; }

		if($address{'mail_type'} eq "mobile"){ $body = $body2; } else { $body = $body1; }

		my($flag,$mobile) = Mebius::mail_format(undef,$address2);

		$body .= qq(\n\n);
		$body .= qq(配信解除（１クリック）\n);
		$body .= qq(http://$server_domain/_$moto/?mode=cermail&type=cancel&moto=$moto&no=$i_postnumber&char=$address{'char'}&email=$address_encoded2);

		# 自分のレスの場合
		if($cemail && $address2 eq $cemail && $myadmin_flag < 5){ next; }
		 
		# メール送信
		if($address2){ Mebius::send_email("Edit-url-plus",$address2,$subject,$body); }

	}
close($sendmail_handler);

}

#-------------------------------------------------
# 投稿時のリンク処理 - strict
#-------------------------------------------------
sub bbs_regist_auto_link{

# 宣言
my($msg) = @_;
our(%in,$i_res);

# 自動リンク
($msg) = Mebius::auto_link({ BlankWindow => 1 },$msg);

	if(!$in{'k'}){ $msg =~ s/No\.([0-9]{1,5})(([,-])([0-9,]+)||$)/<a href=\"${i_res}.html-$1$2\">&gt;&gt;$1$2<\/a>/g; }

# リターン
return($msg);

}


#-------------------------------------------------
# エラー処理の振り分け - strict
#-------------------------------------------------
sub regist_error{

# 宣言
my($init_directory) = Mebius::BaseInitDirectory();
my($param) = Mebius::query_single_param();

	# 振り分け
	if($param->{'k'} == 1){ require "${init_directory}k_rerror.pl"; regist_mobile_rerror(@_); }
	else{ require "${init_directory}part_resform.pl"; regist_rerror(@_); }

}

1;

