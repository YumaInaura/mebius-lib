
use strict;
use Mebius::History;
use Mebius::Time;
use Mebius::AuthAccount;
#use Mebius::AuthServerMove;
use Mebius::Query;
package main;
use Mebius::Export;

#-------------------------------------------------
# 編集を実行 - マイアカウント
#-------------------------------------------------
sub auth_editprof{

# 局所化
my($change_name_flag,$redirect_flag,%account);
my($enctrip,%renew,$myurl_title,$get_urltitle_flag,$error_flag_sendmail,$cermail_message);
our($file) = undef;
our($e_com,$fook_error,$head_link3,$i_trip,%in,$postflag,$alocal_mode,$auth_domain);
our($int_dir,$jump_sec,$jump_url,$idcheck,$myadmin_flag,$server_domain);
our($pmfile,$sendcermail_flag,$date,$pmname,$auth_url,%ch);

	# メール記載の解除用ＵＲＬから、配信メールを解除する
	if($in{'type'} eq "cancel_mail"){
		require "${main::int_dir}part_cermail.pl";
		Mebius::Email::CancelMailSNSAccount(undef,$main::in{'account'},$main::in{'char'});
	}

# アクセス制限
&axscheck("NOLOCK");

	# SNS停止中
	if($main::stop_mode =~ /SNS/){
		main::error("現在、SNSは停止中のため、プロフィールは更新できません。");
	}

	# ファイル定義
	if($in{'account'} && $myadmin_flag){ $file = $in{'account'}; }
	else{ $file = $pmfile; }
$file =~ s/[^0-9a-z]//;
	if($file eq ""){ $e_com .= qq(▼プロフィールを編集するには、アカウントにログインしてください。<br>); }

# タイトルなど定義
$head_link3 = "&gt; 編集";

	# ドメインブロック
	if(!$postflag){ $e_com .= qq(ＧＥＴ送信は出来ません。); }
	if("http://$server_domain/" ne $auth_url && !$alocal_mode){ main::error("サーバーが違います。"); }

# アカウントを開く
(%account) = Mebius::Auth::File("Hash",$file);

# ID、トリップ付与
($enctrip) = &trip($in{'name'});

# 各種チェック
require "${int_dir}regist_allcheck.pl";
my($i_handle) = shift_jis(Mebius::Regist::name_check($in{'name'}));
($in{'prof'}) = &all_check("Edit-profile",$in{'prof'});

	# おすすめＵＲＬを処理 ( URL内容が変わった場合のみ、チェックする )
	if($in{'myurl'} eq "http://"){ $in{'myurl'} = ""; }
	if($in{'myurl'}){
			if($in{'myurl'} =~ /$auth_url/){ $e_com .= qq(▼SNS内のＵＲＬ ( $in{'myurl'} ) は使えません。掲示板等から選んでください。<br>); }
			elsif($account{'myurl'} ne $in{'myurl'}){
				&url_check("Status Grammar Limited",$in{'myurl'});
				#$get_urltitle_flag = 1;
			}
	}


# 編集内容の処理
my $length = int(length($in{'prof'}));
if($length > 5000*2){ $e_com .= qq(▼プロフィールが長すぎます。( $length文字 / 5000文字 )<br>); }
if($in{'prof'} =~ /前略/ && $in{'prof'} =~ /([0-9]{8,})/){ $e_com .= qq(▼前略プロフィールのＩＤを書き込まないでください。<br>); }
if($main::myaccount{'key'} eq "2" && $in{'prof'} ne ""){ $e_com .= qq(▼アカウントがロックされている場合、プロフィールを完全に削除しなければ、設定変更できません。<br>); }

# リダイレクトする場合
#if($account{'orireki'} ne $in{'pporireki'}){ $redirect_flag = 1; }

	# 筆名変更をチェック
	if($i_handle ne $account{'name'}){ $change_name_flag = 1; }

	# 自分のアカウント以外は編集できない
	if(!$account{'myprof_flag'} && !$myadmin_flag){ main::error("自分のアカウント以外編集できません。"); }

	# アカウント名，パスが一致しない場合エラー
	if(!$idcheck){ $e_com .= qq("▼編集するにはログインしてください。<br>"); }

	# ●各種設定値の汚染チェック
	$in{'ppocomment'} =~ s/\D//g;
	if(length($in{'ppocomment'}) >= 4){ $e_com .= qq("▼設定値が変です。<br>"); }
	elsif($in{'ppocomment'} > 4){ $e_com .= qq("▼設定値が変です。<br>"); }

	$in{'ppodiary'} =~ s/\D//g;
	if(length($in{'ppodiary'}) >= 2){ $e_com .= qq("▼設定値が変です<br>。"); }
	elsif($in{'ppodiary'} > 2){ $e_com .= qq("▼設定値が変です。<br>"); }

	$in{'ppobbs'} =~ s/\D//g;
	if(length($in{'ppobbs'}) >= 2){ $e_com .= qq("▼設定値が変です。<br>"); }
	elsif($in{'ppobbs'} > 2){ $e_com .= qq("▼設定値が変です。<br>"); }

	$in{'pposdiary'} =~ s/\D//g;
	if(length($in{'pposdiary'}) >= 2){ $e_com .= qq("▼設定値が変です。<br>"); }
	elsif($in{'pposdiary'} > 2){ $e_com .= qq("▼設定値が変です。<br>"); }
	if($account{'level'} < 1){ $in{'pposdiary'} = ""; };

	$in{'pposbbs'} =~ s/\D//g;
	if(length($in{'pposbbs'}) >= 2){ $e_com .= qq("▼設定値が変です。<br>"); }
	elsif($in{'pposbbs'} > 2){ $e_com .= qq("▼設定値が変です。<br>"); }
	if($account{'level'} < 1){ $in{'pposbbs'} = ""; };

	$in{'pporireki'} =~ s/\D//g;
	if(length($in{'pporireki'}) >= 2){ $e_com .= qq("▼設定値が変です。<br>"); }
	elsif($in{'pporireki'} > 2){ $e_com .= qq("▼設定値が変です。<br>"); }


	$in{'ppcolor2'} =~ s/\W//g;
	if(length($in{'ppcolor2'}) > 3){ $e_com .= qq("▼設定値が変です。<br>"); }



	# メールパスが無い場合（未認証の場合）、未確認状態としてメールアドレスのみを記録する）
	# →逆に、既に認証済みの場合は、メールアドレスが入力されてもデータを変更しない（確認メール処理だけから変更可能）
	if($account{'mlpass'} eq ""){ $renew{'email'} = $in{'email'}; }

	# ユーザーの入力内容から、メールアドレス、メールパスを削除する
	if($in{'reset_email'}){ $renew{'email'} = ""; $renew{'mlpass'} = ""; }

# ●ファイル変更内容の定義 ( 未定義値を作らない )

	# プロフィール
	if($ch{'prof'}){
		if($in{'prof'} eq ""){ $renew{'prof'} = ""; }
		else{ $renew{'prof'} = $in{'prof'}; }
	}

	# 筆名
	if($ch{'name'}){
		$renew{'name'} = $i_handle;
		$renew{'mtrip'} = $i_trip;
		$renew{'enctrip'} = $enctrip;
		if($renew{'mtrip'} eq ""){ $renew{'mtrip'} = ""; }
		if($enctrip eq ""){ $renew{'enctrip'} = ""; }
	}

	# マイＵＲＬ
	if($ch{'myurl'}){
		if($in{'myurl'} eq ""){ $renew{'myurl'} = ""; }
		else{ $renew{'myurl'} = $in{'myurl'}; }
	}

	# マイＵＲＬのタイトル
	if($ch{'myurltitle'}){
			my($myurl_title) = &subject_check("Empty",$in{'myurltitle'});
			if($in{'myurltitle'} eq ""){ $renew{'myurltitle'} = ""; }
			else{ $renew{'myurltitle'} = $myurl_title; }
	}

	# 文字色
	if($ch{'ppcolor2'}){
		$in{'ppcolor2'} =~ s/\W//g;
		if(length($in{'ppcolor2'}) > 3){ $e_com .= qq("▼設定値が変です。<br>"); }
		$renew{'color2'} = $in{'ppcolor2'};
		($renew{'color2'}) = Mebius::Regist::color_check(undef,$renew{'color2'});
	}

	# 帯色
	if($ch{'ppcolor1'}){
		$in{'ppcolor1'} =~ s/\W//g;
		if(length($in{'ppcolor1'}) > 3){ $e_com .= qq("▼設定値が変です。<br>"); }
		$renew{'color1'} = $in{'ppcolor1'};
		#($renew{'color1'}) = Mebius::Regist::color_check(undef,$renew{'color1'});
	}

	# SNSの行動履歴
	if($ch{'ohistory'}){
		if($in{'ohistory'} =~ /^(use-open|use-close|not-use)$/){ $renew{'ohistory'} = $in{'ohistory'}; }
	}

	# 関連リンク
	if($ch{'okr'}){
		if($in{'okr'} =~ /^(use-open|use-close|not-use)$/){ $renew{'okr'} = $in{'okr'}; }
		#if($renew{'okr'} ne $account{'okr'} && $renew{'okr'} eq "not-use"){ &access_log("SNS-Notkr","関連リンクをオフに： $file"); }
	}

	# 猫の受け取り
	if($ch{'allow_vote'}){
		if($in{'allow_vote'} eq "not-use"){ $renew{'allow_vote'} = "not-use"; }
		else{ $renew{'allow_vote'} = "use-open"; }
	}


	# ●誕生日
	if($main::ch{'birthday_year'} || $main::ch{'birthday_month'} || $main::ch{'birthday_day'}){

			# 汚染チェック
			if($main::in{'birthday_year'} =~ /\D/ || $main::in{'birthday_month'} =~ /\D/ || $main::in{'birthday_day'} =~ /\D/){
				main::error("誕生日の年月日は整数で指定してください。");
			}

			# 未入力の値がある場合
			#if($main::in{'birthday_year'} eq "" || $main::in{'birthday_month'} eq "" || $main::in{'birthday_day'} eq ""){
			#	$main::e_com .= qq(▼誕生日を入力する場合は、年/月/日のすべてを指定してください。<br>);
			#}

			# 局所化
			my($error_text);

			# 年
			if($account{'birthday_year'} && !$main::myadmin_flag){ $renew{'birthday_year'} = $account{'birthday_year'}; }
			else{ $renew{'birthday_year'} = $main::in{'birthday_year'}; }
			# 月
			if($account{'birthday_month'} && !$main::myadmin_flag){ $renew{'birthday_month'} = $account{'birthday_month'}; }
			else{ $renew{'birthday_month'} = $main::in{'birthday_month'}; }
			# 日
			if($account{'birthday_day'} && !$main::myadmin_flag){ $renew{'birthday_day'} = $account{'birthday_day'}; }
			else{ $renew{'birthday_day'} = $main::in{'birthday_day'}; }

				# ▼ありえない年数はエラーを
				if($renew{'birthday_year'} && $renew{'birthday_year'} > $main::thisyear){ main::error("未来に生まれたのですか？"); }
				if($renew{'birthday_year'} && $renew{'birthday_year'} < $main::thisyear - 150){ main::error("そんなにご長寿なのですか？"); }

				# ▼はじめて各値を設定する場合、警告を表示する
				if($main::in{'birthday_year'} && !$account{'birthday_year'}
				|| $main::in{'birthday_month'} && !$account{'birthday_month'}
				|| $main::in{'birthday_day'} && !$account{'birthday_day'}){
					$main::a_com .= qq(<span style="color:#f00;">▼誕生日はいちど設定すると、あとから変更できませんが、よろしいですか？<br$main::xclose>);
					$main::a_com .= qq(　　年齢を偽っての登録はご遠慮下さい。（設定したくない場合は、空欄のままにしておいてください）<br$main::xclose>虚偽の登録があった場合、<strong>アカウントロックや利用禁止</strong>などの処置を取らせていただく場合があります。</span><br$main::xclose>);
				}

				# グリニッジ標準時を取得
				if($renew{'birthday_year'}){
					($renew{'birthday_time'},$error_text) = Mebius::TimeLocal(undef,$renew{'birthday_year'},$renew{'birthday_month'},$renew{'birthday_day'});
				}
				else{
					$renew{'birthday_time'} = "";
				}

			# エラー
			if($error_text){ main::error($error_text); }

	}

	# ●誕生日公開の設定
	if($main::ch{'birthday_concept_open'}){
			if($main::in{'birthday_concept_open'} =~ /^(Not-open|Friend-open)$/){
				$renew{'birthday_concept'} .= qq( $main::in{'birthday_concept_open'});
			}
	}

	# ● メッセージ機能の許可
	if($main::ch{'allow_message'}){


			# 管理者が利用禁止設定をしている場合、変更できないように
			if($account{'allow_message'} =~ /^(Deny-use)$/ && !$main::myadmin_flag){

			}

			# 更新内容を定義
			elsif($main::in{'allow_message'} =~ /^(Use|Not-use|Friend-only|Deny-use)$/){
				$renew{'allow_message'} = $main::in{'allow_message'};
			}

	}


	#● メールの受信設定
	if($main::ch{'catch_mail_message'}){
			if($main::in{'catch_mail_message'} =~ /^(Catch|Not-catch)$/){
				$renew{'catch_mail_message'} = $main::in{'catch_mail_message'};
			}
	}
	if($main::ch{'catch_mail_resdiary'}){
			if($main::in{'catch_mail_resdiary'} =~ /^(Catch|Not-catch)$/){
				$renew{'catch_mail_resdiary'} = $main::in{'catch_mail_resdiary'};
			}
	}
	if($main::ch{'catch_mail_comment'}){
			if($main::in{'catch_mail_comment'} =~ /^(Catch|Not-catch)$/){
				$renew{'catch_mail_comment'} = $main::in{'catch_mail_comment'};
			}
	}
	if($main::ch{'catch_mail_etc'}){
			if($main::in{'catch_mail_etc'} =~ /^(Catch|Not-catch)$/){
				$renew{'catch_mail_etc'} = $main::in{'catch_mail_etc'};
			}
	}

	# ログイン時間表示の許可設定
	if($main::ch{'allow_view_last_access'}){
			if($main::in{'allow_view_last_access'} =~ /^(Open|Login-user-only|Friend-only|Not-open)$/){
				$renew{'allow_view_last_access'} = $main::in{'allow_view_last_access'};
			}
	}

	# いいね！の受信設定
	if($main::ch{'allow_crap_diary'}){
			if($main::in{'allow_crap_diary'} =~ /^(Allow|Deny)$/){
				$renew{'allow_crap_diary'} = $main::in{'allow_crap_diary'};
			}
	}

	# ファイル変更内容の定義（ふつう未定義にはならない値）
	if($ch{'ppocomment'}){ $renew{'ocomment'} = $in{'ppocomment'}; }
	if($ch{'ppodiary'}){ $renew{'odiary'} = $in{'ppodiary'}; }
	if($ch{'pposdiary'}){ $renew{'osdiary'} = $in{'pposdiary'}; }
	if($ch{'pporireki'}){ $renew{'orireki'} = $in{'pporireki'}; }

	# 自分のプロフィール変更の場合
	if($account{'myprof_flag'}){
		$renew{'edittime'} = $main::time;
	}

	# 管理者がユーザーファイルを変更した場合
	if($myadmin_flag && !$account{'myprof_flag'}){
	
		# プロフィールの修正
		#if($account{'prof'} && $account{'prof'} ne $renew{'prof'}){
		#	$renew{'prof'} = qq(<em>管理者 ($pmname - $pmfile) により修正 ($date)</em><br>$renew{'prof'});
		#}
	}


# エラーとプレビュー
&error_view("AERROR Target","auth_editprof_error");

	# メールアドレスが認証されていて、エラーがなく編集実行する場合、確認用メールアドレスを配信する
	if($main::in{'email'} && $account{'myprof_flag'}){
		require "${main::int_dir}part_cermail.pl";
		($error_flag_sendmail,$cermail_message) = Mebius::Email::SendCermail("SNS-account",$main::in{'email'},$main::pmfile);
			if($error_flag_sendmail){ $main::e_com .= qq(▼$error_flag_sendmail<br$main::xclose>); }
			if($cermail_message){ $cermail_message = qq(<hr$main::xclose>$cermail_message); }
	}

	# プロフィールの変更を認識
	if(defined($renew{'prof'}) && $account{'prof'} ne $renew{'prof'}){
		$renew{'last_profile_edit_time'} = $main::time;
	}

# エラーとプレビュー
&error_view("AERROR Target","auth_editprof_error");

# 編集実行
Mebius::Auth::File("Renew Option",$file,\%renew);

# オプションファイルを更新 ( おそらく最終活動時刻を定義し、ホスト名などを更新している )
#Mebius::Auth::Optionfile("Renew",$file);

# 筆名履歴の更新
&auth_renew_namefile($file);

	# 筆名を変更した場合
	if($change_name_flag){
		Mebius::Auth::AccountListFile("Renew Edit-account Normal-file",$file,$i_handle);
		Mebius::Auth::AccountListFile("Renew Edit-account Search-file",$file,$i_handle);
	}

	# 管理者編集の場合など、反対側サーバーへリダイレクト（１）
	if($redirect_flag && !$alocal_mode){ Mebius::Redirect("","http://aurasoul.mb2.jp/_auth/?mode=editprof&type=get&pporireki=$in{'pporireki'}&account=$in{'account'}");
	}

	# メール配信をしなかった場合はリダイレクト
	if($in{'email'}){ }
	else{
		$jump_url = "${main::auth_url}$file/#EDIT";
		Mebius::Redirect("",$jump_url);
	}

# HTML
my $print = <<"EOM";
編集しました。(<a href="${main::auth_url}$file/#EDIT">→戻る</a>）<br>
$cermail_message
EOM

Mebius::Template::gzip_and_print_all({ BCL => [$head_link3] },$print);

# 処理終了
exit;

}


#-----------------------------------------------------------
# プレビューとエラー
#-----------------------------------------------------------
sub auth_editprof_error{

# 宣言
my($error) = @_;
my($myform,$error_line);
our($lockflag,%in,$int_dir,$file);

# エラー時アンロック
if($lockflag) { &unlock($lockflag); }

# エラー表示
if($error){
$error_line .= qq(
<h2 id="ERROR">エラー</h2>
<div class="error">$error</div>
);
}

$error_line = qq(
<h1>編集フォーム</h1>
$error_line
<h2 id="PREV">プレビュー</h2>
<div class="prev">$in{'prof'}</div>
$myform
);

# マイフォームを取り込み
require "${int_dir}auth_myform.pl";
if($in{'detail'}){ ($myform) = &auth_myform("Detail",$file,$error_line); }
else{ ($myform) = &auth_myform("",$file,$error_line); }

Mebius::Template::gzip_and_print_all({},$myform);


exit;

}

#-----------------------------------------------------------
# 筆名履歴ファイルの更新
#-----------------------------------------------------------
sub auth_renew_namefile{

# 局所化
my($file) = @_;
my($line,$flag,$i,$name_handler);
our($int_dir,%in);

# ファイル定義
$file =~ s/[^0-9a-z]//;
if($file eq ""){ return; }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

my $file = "${account_directory}${file}_name.cgi";

# ファイルを開く
open($name_handler,"<",$file);
	while(<$name_handler>){
		$i++;
		if($i > 5){ last; }
		chomp;
		my($name) = split(/<>/);
		if($name eq $in{'name'}){ $flag = 1; }
		$line .= qq($name<>\n);
	}
close($name_handler);

if(!$flag){ $line = qq($in{'name'}<>\n) . $line; }

# ファイルを書き込む
Mebius::Fileout("",$file,$line);

}


#-------------------------------------------------
# 編集を実行 (管理者用)
#-------------------------------------------------
sub auth_baseedit{

# 局所化
my($basic_init) = Mebius::basic_init();
my($line,$bkline,$max_bkup,$bki,%account,%renew);
our($myadmin_flag,$auth_domain,$idcheck,%in);

# 管理者のみ
if($main::myadmin_flag < 5){ main::error("不明な処理です。"); }

# アクセス制限
main::axscheck("");

# アカウント名判定
my $account = $main::in{'account'};
if(Mebius::Auth::AccountName(undef,$account)){ main::error("値を設定してください。"); }


# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ディレクトリ作成
Mebius::Mkdir("",$account_directory);

# タイトルなど定義
my $head_link3 = "&gt; 特殊編集";

	# アカウントファイルを開く
	(%account) = Mebius::Auth::File("Not-file-check",$account); 

# アカウント名，パスが一致しない場合エラー
if($myadmin_flag < 5){ &error("編集するにはログインしてください。"); }

	# アカウント停止の場合、コメント設定を変更
	if($in{'ppkey'} eq "0" || $in{'ppkey'} eq "2"){
		$renew{'obbs'} = "0";
		$renew{'odiary'} = "0";
		$renew{'ocomment'} = "0";
	}

	# 変更内容の定義
	if($in{'ppkey'} ne ""){
		$renew{'key'} = $in{'ppkey'};
		$renew{'key'} =~ s/\D//g;
	}

	if($in{'pplevel'} ne ""){
		$renew{'level'} = $in{'pplevel'};
		$renew{'level'} =~ s/\D//g;
	}

	if($in{'pplevel2'} ne ""){
		$renew{'level2'} = $in{'pplevel2'};
		$renew{'level2'} =~ s/\D//g;
	}

	if($in{'ppadmin'} ne ""){
		$renew{'admin'} = $in{'ppadmin'};
		$renew{'admin'} =~ s/\D//g;
	}

	if($in{'ppsurl'} ne ""){
		$renew{'surl'} = $in{'ppsurl'};
	}

	if($in{'ppchat'} ne ""){
	$renew{'chat'} = $in{'ppchat'};
			$renew{'chat'} =~ s/\D//g;
	}

	if($in{'ppblocktime'} ne ""){
		$renew{'blocktime'} = $in{'ppblocktime'};
		$renew{'blocktime'} =~ s/\D//g;
	}

	# 解除
	if($in{'ppblocktime'} eq "none"){
		$renew{'blocktime'} = "";
		$renew{'key'} = 1;
	}

	# 無期限
	if($in{'ppblocktime'} eq "forever"){
		$renew{'key'} = 2;
		$renew{'blocktime'} = "";
	}

$renew{'reason'} = $in{'ppreason'};
$renew{'reason'} =~ s/\D//g;
$renew{'adlasttime'} = time;


	# ブロック期限がある場合は、自動的にアカウントロック
	if($in{'ppblocktime'} > time){ $renew{'key'} = 2; }

	# アカウントロック（削除）の場合、新規アカウント作成をブロック
	if($renew{'key'} eq "0" || $renew{'key'} eq "2"){

	}

	# アカウントロックを解除
	if($account{'key'} eq "2" && $in{'ppblocktime'} eq ""){
		$renew{'key'} = 1;
	}

	# ●アカウントキーが変更された場合
	if($account{'key'} ne $renew{'key'}){

			# アカウントロックの解除
			if($renew{'key'} eq "1"){
				$renew{'blocktime'} = "";
				#$renew{'reason'} = "";

				$renew{'-'}{'account_locked_count'} = 1;
					if($account{'last_locked_period'}){ $renew{'last_locked_period'} = ""; }
					if($account{'all_locked_period'}){ $renew{'-'}{'all_locked_period'} = $account{'last_locked_period'}; }

			}

			# アカウントロック
			if($renew{'key'} eq "2"){
				#main::login_history("Deny-make-account",$account,0);
				#&auth_control_account_history("Renew New-history",$account,"Ok!");

				# 次回の新規作成を防止
				my $make_account_blocktime = $renew{'blocktime'};
					if(!$make_account_blocktime || $in{'ppblocktime'} eq "forever"){ $make_account_blocktime = time + 6*30*24*60*60; }
				Mebius::Login->login_history("Deny-make-account",$account,$make_account_blocktime);

				# ロックされた回数をカウント
				$renew{'+'}{'account_locked_count'} = 1;
				$renew{'last_locked_period'} = $renew{'blocktime'} - time;
				$renew{'all_locked_period'} = ($renew{'blocktime'} - time) + $account{'last_locked_period'};
			}

	}

	# 新しい警告
	if($account{'key'} eq "1" && $renew{'reason'} && $account{'allow_next_alert_flag'}){
		$renew{'alert_end_time'} = time + (7*24*60*60);
		$renew{'alert_decide_time'} = time;
		$renew{'+'}{'alert_count'} = 1;
	}

	# 警告の解除
	if($renew{'reason'} eq "" && $account{'alert_flag'}){
		$renew{'alert_end_time'} = "";
		$renew{'-'}{'alert_count'} = 1;
	}

# アカウントを更新
Mebius::Auth::File("Renew Admin-renew",$account,\%renew);

	# 処理回数の記録
	if(Mebius::alocal_judge()){
		Mebius::AccessLog(undef,"Auth-edited-admin");
	}

# 最終リダイレクト先
my $redirect_url_last = "$basic_init->{'auth_url'}${account}/";
	if($in{'backurl'}){ $redirect_url_last = $main::backurl; }

# サーバー間リダイレクトを実行
#Mebius::Auth::ServerMove("All-servers Direct-redirect Use-all-query Sns-base-edit",$main::server_domain,$redirect_url_last);

Mebius::redirect($redirect_url_last);

# 処理終了
exit;

}


#-----------------------------------------------------------
# 制限履歴 ( 現在は非使用 )
#-----------------------------------------------------------
sub auth_control_account_history{

# 宣言
my($type,$account) = @_;
my(undef,undef,$new_text) = @_ if($type =~ /New-history/);
my($i,@renew_line,%data,$file_handler);

	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ファイル定義
my $directory1 = $account_directory;
my $file1 = "${directory1}control_account_history_$account.log";

# 最大行を定義
my $max_line = 50;

	# ファイルを開く
	if($type =~ /File-check-error/){
		open($file_handler,"<$file1") || main::error("ファイルが存在しません。");
	}
	else{
		open($file_handler,"<$file1") && ($data{'f'} = 1);
	}

	# ファイルロック
	if($type =~ /Renew/){ flock($file_handler,1); }

# トップデータを分解
chomp(my $top1 = <$file_handler>);
($data{'key'}) = split(/<>/,$top1);

	# ファイルを展開
	while(<$file_handler>){

		# ラウンドカウンタ
		$i++;
		
		# この行を分解
		chomp;
		my($key2,$text2,$time2,$date2) = split(/<>/);

			# インデックス取得
			if($type =~ /Get-index/){
				$data{'index_line'} .= qq(<div>$text2 ( $date2 )</div>);
			}

			# 更新用
			if($type =~ /Renew/){

					# 最大行数に達した場合
					if($i > $max_line){ next; }

				# 行を追加
				push(@renew_line,"$key2<>$text2<>$time2<>$date2<>\n");
			}

	}

close($file_handler);

	# 新しい行を追加
	if($type =~ /New-history/){

		unshift(@renew_line,"<>$new_text<>$main::time<>$main::date<>\n");

	}

	# ファイル更新
	if($type =~ /Renew/){

		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory1);

		# トップデータを追加
		unshift(@renew_line,"$data{'key'}<>\n");

		# ファイル更新
		Mebius::Fileout(undef,$file1,@renew_line);

	}

return(%data);

}

1;
