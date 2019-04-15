
use Mebius::Newlist;
use Mebius::SNS::Diary;
use Mebius::History;
use Mebius::AllComments;
use Mebius::Query;

package main;
use strict;

#-----------------------------------------------------------
# SNS 日記への返信
#-----------------------------------------------------------
sub auth_resdiary{

# 局所化
my $all_comments = new Mebius::AllComments
my $sns_diary = new Mebius::SNS::Diary;
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
my $time = time;
my $history = new Mebius::History;
my $query = new Mebius::Query;
my $param  = $query->param();
my($line,$indexline,$pastline,$flag,$top1,$yearfile,$monthfile,$stop,$timeline,$i,$newcomment_handler,$maxres,$month_index_handler,$diary_index_handler,$subject,$myadmin_flag,%renew);
our($sub_title,$css_text,$head_link3,$head_link4,$head_link5,$date,%in,$lockkey,$title,$xip,$birdflag,$rcevil_flag,$thisyear,$thismonth,$today,$thishour,$thismin,$thissec);

my $comment_utf8 = utf8_return($param->{'comment'});
	if($all_comments->dupulication_error($comment_utf8)){
		auth_resdiary_error("重複投稿です。");
	}


# レス上限の最大数
$maxres = 1000;

# タイトル定義
$sub_title = qq(日記へのレス | $title);

# CSS定義
$css_text .= qq(
.dtextarea{width:95%;height:300px;}
.alert{color:#f00;}
.please_text1{color:#080;font-size:120%;}
.wait{font-size:130%;color:#f00;}
div.error{line-height:1.4;padding:1em;border:solid 1px #f00;}
);

# 文字数上限、下限
my $maxmsg = 5000;
my $minmsg = 5;

# エラー時のフック内容
#$fook_error = qq(入力内容： $in{'comment'});

# アクセス制限
&axscheck("ACCOUNT Post-only");

# 汚染チェック１
my $account = $in{'account'};
$account =~ s/[^0-9a-z]//g;
	if($account eq ""){ &auth_resdiary_error("データ指定が変です。"); }

# 汚染チェック１
my $diary_number = $in{'num'};
$diary_number =~ s/\D//g;
	if($diary_number eq ""){ &auth_resdiary_error("データ指定が変です。"); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

	# ログインしていない場合
	if(!$my_account->{'login_flag'}){ &auth_resdiary_error("コメントするには、ログインしてください。"); }

	# チャージ時間チェック
	if($time < $main::myaccount{'next_comment_time'} && !$main::myaccount{'admin_flag'} && !Mebius::alocal_judge()){
		my($left_charge) = Mebius::SplitTime(undef, $main::myaccount{'next_comment_time'} - $main::time);
		&auth_resdiary_error("チャージ時間中です。あと $left_charge お待ちください。");
	}

# プロフィールを開く
my(%account) = Mebius::Auth::File("Option File-check-error Key-check-error Lock-check-error",$account);

# タイトル等定義
$head_link3 = qq(&gt; <a href="$basic_init->{'auth_url'}$account/">$account{'name'}</a> );
$head_link4 = qq(&gt; <a href="$basic_init->{'auth_url'}$account/diax-all-new">日記</a> );
$head_link5 = qq(&gt; レス投稿 );

# お互いのマイメビ状態 / 禁止状態をチェック
my($friend_status1) = Mebius::Auth::FriendStatus("Deny-check-error",$account{'file'},$main::myaccount{'file'});
my($friend_status2) = Mebius::Auth::FriendStatus("Deny-check-error",$main::myaccount{'file'},$account{'file'});

	# コメント可否を判定
	if($account{'let_flag'} && !$my_account->{'admin_flag'}){ &auth_resdiary_error("$account{'let_flag'}"); }
	if(!$account{'myprof_flag'} && !$my_account->{'admin_flag'}){
			if($account{'odiary'} eq "0"){ &auth_resdiary_error("アカウント主以外はコメントできません。"); }
			elsif($account{'odiary'} eq "2" && $friend_status1 ne "friend"){ &auth_resdiary_error("$main::friend_tag以外はコメントできません。"); }
	}
	if($birdflag){ &auth_resdiary_error("コメントするにはあなたの筆名を設定してください。"); }

# 投稿内容チェック
require "${init_directory}regist_allcheck.pl";

# 次の待ち時間を判定
Mebius::Regist::name_check($my_account->{'name'});
my($bglength,$smlength) = &get_length("",$in{'comment'});

	# 長さチェック
	if($bglength > $maxmsg){ &auth_resdiary_error("本文は全角$maxmsg文字以内に抑えてください。（現在 $bglength 文字）"); }
	if($smlength < $minmsg && !Mebius::alocal_judge()){ &auth_resdiary_error("本文は全角$minmsg文字以上を書いてください。（現在 $smlength 文字）"); }

# 各種チェック
($in{'comment'}) = &all_check(undef,$in{'comment'});
&error_view("AERROR Target","auth_resdiary_error");

# プレビュー
if($in{'preview'}){ &auth_resdiary_error(); }

# ロック開始
&lock("auth$account");

my($diary) = Mebius::Auth::diary( {} , $account,$diary_number);
	if(!$diary->{'f'}){
		main::error("この日記は存在しません。");
	}

$renew{'+'}{'res'} = 1;
$renew{'lastrestime'} = time;
$renew{'last_handle'} = $my_account->{'name'};
$renew{'last_account'} = $my_account->{'id'};

my $newres = $diary->{'res'} + 1;

	# レス上限
	if($diary->{'res'} >= $maxres){ &auth_resdiary_error("レス上限を超えています（$maxres件）。"); }

	# コメント可否の判定
	if(($diary->{'key'} eq "0" || $diary->{'key'} eq "2" || $diary->{'key'} eq "4") && !$my_account->{'admin_flag'}){
		&auth_resdiary_error("コメントできません。この日記は削除済み、またはロック中です。");
	}

	if($account{'myprof_flag'}){
		($renew{'owner_lastres_time'},$renew{'owner_lastres_number'}) = (time,$diary->{'res'}+1);
	}

# 追加する行 
$line .= qq(1<>$newres<>$my_account->{'id'}<>$my_account->{'name'}<>$main::myaccount{'enctrip'}<>$main::myaccount{'encid'}<>$in{'comment'}<>$thisyear,$thismonth,$today,$thishour,$thismin,$thissec<>$main::myaccount{'color2'}<>$xip<>\n);

my($renewed_diary) = Mebius::Auth::diary({ Renew => 1 , push_line => $line } , $account,$diary_number , undef, \%renew);


# アカウント毎の現行インデックスを更新
Mebius::SNS::Diary::index_file_per_account({ Renew => 1 , renew_line => { $diary_number => { res => $newres } } , file_type => "now" },$account);

# 汚染チェック３
my $yearfile = $diary->{'year'};
my $monthfile = $diary->{'month'};
$yearfile =~ s/\D//g;
$monthfile =~ s/\D//g;

# 単体ファイル取得した年/月データからファイル定義

	# ヒットした場合のみ、月別インデックスを開く
	if($yearfile && $monthfile){
		Mebius::SNS::Diary::index_file_per_account({ Renew => 1 , renew_line => { $diary_number => { res => $newres } } , file_type => "month" },$account,$yearfile,$monthfile);
	}

# 相手にメールを送信
my %mail;
$mail{'url'} = "$account{'file'}/d-$diary_number#S$newres";
$mail{'comment'} = $main::in{'comment'};
$mail{'subject'} = qq($main::myaccount{'name'}さんが「$diary->{'subject'}」に書き込みました。);
Mebius::Auth::SendEmail(" Type-res-diary",\%account,\%main::myaccount,\%mail);

	# 相手アカウントの 「最近の更新」ファイルを更新
	if(!$account{'myprof_flag'} || Mebius::alocal_judge()){
		Mebius::Auth::News("Renew Log-type-resdiary$diary_number",$account,$my_account->{'id'},$main::myaccount{'handle'},qq(<a href="$basic_init->{'auth_url'}$account/d-$diary_number#S$newres">$diary->{'subject'}</a> へのレス \(No.$newres\)));
	}


# 新着レス一覧を更新
&auth_renew_newres_diary("",$diary_number,$diary->{'subject'},$newres,%account);

	# 注意投稿ファイルを更新
	#if($main::a_com){
	#	Mebius::Auth::all_members_diary("Alert-res-file New-line Renew",$account,$diary_number,$diary->{'subject'},$in{'comment'},$my_account->{'name'},$newres);
	#}

# ロック解除
&unlock("auth$account") if $lockkey;

	# 「あなたのコメント履歴」を更新
	if(!$account{'myprof_flag'} || Mebius::alocal_judge()){
		Mebius::SNS::Diary::comment_history("Renew New-res",$main::myaccount{'file'},$account,$diary_number,$newres);
	}

# 自分のオプションファイルを更新
my(%renew_myoption);
#$renew_myoption{'next_comment_time'} = $main::time + 60;
#Mebius::Auth::Optionfile("Renew",$main::myaccount{'file'},%renew_myoption);
$renew_myoption{'next_comment_time'} = time + 15;
Mebius::Auth::File("Renew Option",$main::myaccount{'file'},\%renew_myoption);

# 相手のアカウント・オプションファイルを更新 ( 何故？ )
#Mebius::Auth::Optionfile("Renew",$account);
#Mebius::Auth::File("Renew Option",$account);

# 行動履歴を更新
#Mebius::Auth::History("Renew",$my_account->{'id'},$account,qq(の日記 ( <a href="$basic_init->{'auth_url'}$account/d-${diary_number}#S$newres">$subject</a> ) に書き込みました。));

# 総レス数を更新
Mebius::Newlist::Daily("Renew Resdiary-auth");

# レス監視
&rcevil($rcevil_flag,$in{'comment'},$my_account->{'name'},"$basic_init->{'auth_url'}$account/d-${diary_number}-$newres",$diary->{'subject'});

# 自分の基本投稿履歴ファイルを更新
Mebius::HistoryAll("Renew My-file");

my $hidden_from_friends = $history->hidden_from_friends_judge_on_param();

my $subject_utf8 = utf8_return($diary->{'subject'});
my $handle_utf8 = utf8_return($my_account->{'name'});
$sns_diary->create_common_history({ content_targetA => $account , content_targetB => $diary_number , last_response_num => $newres , last_response_target => $newres , subject => $subject_utf8 , handle => $handle_utf8 , content_create_time => $diary->{'posttime'} });

$all_comments->submit_new_comment($comment_utf8);

# リダイレクト
Mebius::Redirect("","$basic_init->{'auth_url'}$in{'account'}/d-$in{'num'}#S$newres");

# 終了
exit;


}

no strict;

#-----------------------------------------------------------
# 新着レス一覧を更新
#-----------------------------------------------------------
sub auth_renew_newres_diary{

# 局所化
my($type,$open,$fook_sub,$newres,%account) = @_;
my($i,$iforeach,$line,$one_comment,$plus_lengths);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;
my($my_account) = Mebius::my_account();

# 新着レス一覧の最大記録数
my $max_newresdiary = 1000;

my $file = "${auth_log_directory}newresdiary.cgi";

# リターンする場合
if($account{'osdiary'} eq "0" || $account{'osdiary'} eq "2"){ return; }

# コメントを１行だけ記録
my($lengths,$iforeach);
foreach(split(/<br>/,$in{'comment'})){
$iforeach++;
$_ =~ s/( |　)//g;
#if($iforeach >= 2){ $one_comment .= qq( / ); }
$plus_lengths += length($_);
$one_comment .= qq($_);
if($plus_lengths >= 2*100){ last; }
}

# 新着インデックスを開く
my $line .= qq(1<>$open<>$fook_sub<>$account{'file'}<>$account{'name'}<>$my_account->{'id'}<>$my_account->{'name'}<>$one_comment<>$date<>$newres<>\n);
open(ALLRES_DIARY_IN,"<",$file);
	while(<ALLRES_DIARY_IN>){
		$i++;
			if($i < $max_newresdiary) { $line .= $_; }
	}
close(ALLRES_DIARY_IN);

# 新着インデックスを書き込む
Mebius::Fileout("",$file,$line);


}


#-----------------------------------------------------------
# プレビュー
#-----------------------------------------------------------
sub auth_resdiary_error{

my($submit);
my($error) = @_;
my($init_directory) = Mebius::BaseInitDirectory();
our(%in,$lockflag);

require "${init_directory}auth_diary.pl";

	# エラー時アンロック
	if($lockflag) { &unlock($lockflag); }

my $com_value = qq(\n$in{'comment'});
$com_value =~ s/<br>/\n/g;

	if($error ne ""){ $error = qq(<div class="error"><strong class="alert">エラー：</strong><br><br>$error</div><br><br>); }

# HTML
my $print = qq(
$error
<h1>プレビュー</h1>
まだ書き込まれていません。<br>
<h2>プレビュー内容</h2>
<span style="color:#$main::myaccount{'color2'};">$in{'comment'}</span><br>
<h2>修正フォーム</h2>);

$print .= auth_diary_response_form_core($in{'account'},$in{'num'},$com_value);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



1;
