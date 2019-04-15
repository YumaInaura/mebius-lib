
use Mebius::Auth;
use Mebius::SNS::Friend;
use Mebius::Newlist;
use Mebius::SNS::Feed;
package main;
use Mebius::Export;
use strict;

#-----------------------------------------------------------
# SNS 日記の新規投稿
#-----------------------------------------------------------
sub auth_fdiary{

# 宣言
my($maxmsg,$minmsg) = (3000,20);
my($my_account) = Mebius::my_account();
my($param) = Mebius::query_single_param();
our($auth_url,$pmname,$birdflag,$title,$css_text);

# タイトル定義
our $sub_title = qq(新しい日記 | $title);
our $head_link3 = qq(&gt; <a href="$auth_url$my_account->{'id'}/">$my_account->{'name'}</a>);
our $head_link4 = qq(&gt; 新しい日記);

# CSS定義
$css_text .= qq(
div.error{line-height:1.6em;background:#fee;padding:1em;color:#f00;}
textarea{width:95%;height:300px;}
.edit{margin-top:1em;background-color:#cdf;padding:0em 1em 1em 1em;border:solid 1px #99f;}
.pinput{width:95%;}
.maxmsg{color:#080;font-size:90%;}
h1{color:#080;}
h2{margin:0em;}
.alert{color:#f00;}
ul.alert_area{padding:1em 2.0em 1em 2.5em;font-size:90%;border:solid 1px #f00;}
li{line-height:2.0em;}
.nomargin{margin:0em;}
input.sub{width:50%;}
.big{font-size:150%;}
);

	if($ENV{'HTTP_USER_AGENT'} =~ /MSIE 8.0/){ $css_text .= qq(textarea{width:700px;}); }

	# ログインしていない場合
	if(!$my_account->{'login_flag'}){ &auth_fdiary_preview("このページを利用するには、ログインしてください。"); }

	# アクセス制限
	if($ENV{'REQUEST_METHOD'} eq "POST"){ 
		main::axscheck("ACCOUNT");
	}

	# 投稿時間
	if(time < $my_account->{'next_diary_post_time'} && !$main::myadmin_flag && !Mebius::alocal_judge()){
		my($left_date) = Mebius::SplitTime("Get-top-unit",$main::myaccount{'next_diary_post_time'} - time);
		&auth_fdiary_preview("新規投稿はあと$left_date待ってください。");
	}

	# 筆名がない場合
	if($birdflag){ &auth_fdiary_preview("日記を書くには、あなたの筆名を設定してください。"); }

	# モード振り分け
	if($param->{'action'} eq "new"){ &auth_fdiary_post("",$maxmsg,$minmsg); } else { &auth_fdiary_form("",$maxmsg,$minmsg); }

}


#-----------------------------------------------------------
# 日記の新規投稿処理
#-----------------------------------------------------------

sub auth_fdiary_post{

# 局所化
my($type,$maxmsg,$minmsg) = @_;
my($line,$indexline,$pastline,$waitline,$lastman,$i1,$allline,$lastpost,$waitline,$month_index_handler,$diary_index_handler);
my($newkey_newsdiary,%renew_myaccount,$redun_subject_flag,$new_concept,$pastline2,$diary_thread_file,$index_ok_flag);
my $sns_diary = new Mebius::SNS::Diary;
my($my_account) = Mebius::my_account();
my($now_date) = Mebius::now_date_multi();
my($basic_init) = Mebius::basic_init();
my($param) = Mebius::query_single_param();
my $time = time;
our(%in,$e_com,$smlength,$bglength,$xip,$fook_error);


# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($my_account->{'id'});
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# 新着一覧の最大行数
my $max_newdiary = 2000;

# フォーム取得
my($form) = auth_fdiary_getform();

# エラー時のフック内容
$fook_error = qq(<h1>日記の修正</h1>$form);

	# ＧＥＴ送信を禁止
	if($ENV{'REQUEST_METHOD'} ne "POST"){ &auth_fdiary_preview("ＧＥＴ送信は出来ません。"); }

	# 各種エラー
	if($in{'sub'} eq "" || $in{'sub'} =~ /^(\x81\x40|\s|<br>)+$/){ $in{'sub'} = "無題 ($now_date->{'year'}年$now_date->{'month'}月$now_date->{'day'}日 $now_date->{'hour'}時$now_date->{'minute'}分)"; }
	if($in{'comment'} eq "" || $in{'comment'} =~ /^(\x81\x40|\s|<br>)+$/){ $e_com .= qq(▼本文がありません。<br>); }

# 各種チェック
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}regist_allcheck.pl";
Mebius::Regist::name_check($my_account->{'name'});
my($new_comment) = &all_check(undef,$in{'comment'});
my($new_subject) = &subject_check("",$in{'sub'});

	if(!Mebius::alocal_judge()){
			if($bglength > $maxmsg){ $e_com .= qq(▼本文は全角$maxmsg文字以内に抑えてください。（現在 $bglength 文字）<br>); }
			if($smlength < $minmsg){ $e_com .= qq(▼本文は全角$minmsg文字以上を書いてください。（現在 $smlength 文字）<br>); }
	}

&error_view("AERROR Target","auth_fdiary_preview");

# プレビュー
if($in{'preview'}){ &auth_fdiary_preview(); }

# ロック開始
&lock("auth$my_account->{'id'}");

# 日記現行インデックスの最大行
my $max_nowindex = 1000;

# 共通の時刻フォーマットを定義
my $time_data_line = "$now_date->{'year'},$now_date->{'month'},$now_date->{'day'},$now_date->{'hour'},$now_date->{'minute'},$now_date->{'second'}";

# 現行インデックスを読み込み
my($now_index) = Mebius::SNS::Diary::index_file_per_account({ file_type => "now" },$my_account->{'id'});
my $newnum = $now_index->{'newest_diary_number'};

	# タイトルの重複チェック
	foreach my $data (@{$now_index->{'data_line'}}){
			if($data->{'subject'} eq $new_subject && $new_subject ne ""){
				auth_fdiary_preview("「$new_subject」という題名は、過去の日記と重複しています。");
			}
	}

	# 日記ファイルを定義
	for(1..100){ # ファイルを１つずつ開くのではなく、ディレクトリの一覧から取得するようにしたい
		$newnum++;
		$diary_thread_file = "${account_directory}diary/$my_account->{'id'}_diary_${newnum}.cgi";
			if(!-f $diary_thread_file){
				$index_ok_flag = 1;
				last;
			}
	}

	if(!$index_ok_flag){
		auth_fdiary_preview("データが壊れているため、書き込めません。（重複書き込み）$newnum");
	}

	# ●現行インデックスを更新
	{
		my %renew_top_data;
		$renew_top_data{'newest_diary_number'} = $newnum;
		my $new_line_diary_index = qq(1<>$newnum<>$new_subject<>0<>$time_data_line<>$time<>\n);

		Mebius::SNS::Diary::index_file_per_account({ Renew => 1 , file_type => "now" , new_line => $new_line_diary_index , renew_top_data => \%renew_top_data },$my_account->{'id'});
	}


	# 新しいコンセプトを設定
	if(!$in{'newlist'}){ $new_concept .= qq( Not-ranking-crap); }

# 追加する行（日記単体ファイル）

	# 日記単体ファイル生成
	#if(Mebius::alocal_judge()){
	#	$line .= qq(1<>$newnum<>$new_subject<>0<>$time_data_line<>$time<><><><><><><>$new_concept<>\n);
	#	$line .= qq(1<>0<>$my_account->{'id'}<>$my_account->{'name'}<>$my_account->{'enctrip'}<>$my_account->{'encid'}<>$new_comment<>$time_data_line<>$my_account->{'color2'}<>$xip<>\n);
	#	Mebius::Fileout("","$diary_thread_file.bk",$line);
	#}

	# ●日記本体ファイルを新規作成
	{
		my %post;
		$post{'key'} = 1;
		$post{'number'} = $newnum;
		$post{'subject'} = $new_subject;
		$post{'res'} = 0;
		$post{'concept'} = $new_concept;
		$post{'postdates'} = $time_data_line;
		$post{'posttime'} = time;
		$post{'hidden_from_list'} = 1 if(!$param->{'newlist'});

		$post{'owner_handle'} = $my_account->{'name'};
		my $push_line .= qq(1<>0<>$my_account->{'id'}<>$my_account->{'name'}<>$my_account->{'enctrip'}<>$my_account->{'encid'}<>$new_comment<>$time_data_line<>$my_account->{'color2'}<>$xip<>\n);

		Mebius::Fileout("Allow-empty",$diary_thread_file); # ファイル自体を新規作成
		Mebius::Auth::diary({ Renew => 1 , Post => 1 , push_line => $push_line },$my_account->{'id'},$newnum,undef,\%post);
	}

# 過去（月別）インデックス読み込み
open($month_index_handler,"<","${account_directory}diary/$my_account->{'id'}_diary_$now_date->{'year'}_$now_date->{'month'}.cgi");
	while(<$month_index_handler>){ $pastline2 .= $_; }
close($month_index_handler);

	# 今月の過去インデックスがない場合、全インデックスに追加する
	if($pastline2 eq ""){

		# 全インデックスを読み込み
		$allline = qq(1<>$now_date->{'year'}<>$now_date->{'month'}<>\n);
		open(ALL_INDEX_IN,"<","${account_directory}diary/$my_account->{'id'}_diary_allindex.cgi");
			while(<ALL_INDEX_IN>){
				my($key,$year,$month) = split(/<>/,$_);
				unless($year eq $now_date->{'year'} && $month eq $now_date->{'month'}){ $allline .= $_; }
			}
		close(ALL_INDEX_IN);

		# 全期間の日記インデックスを更新
		Mebius::Fileout("","${account_directory}diary/$my_account->{'id'}_diary_allindex.cgi",$allline);

	}

		# 過去（月別）インデックス更新
		$pastline = qq(1<>$newnum<>$new_subject<>0<>$time_data_line<>$time<><><>\n);
		$pastline .= $pastline2;
		Mebius::Fileout("","${account_directory}diary/$my_account->{'id'}_diary_$now_date->{'year'}_$now_date->{'month'}.cgi",$pastline);


	# ●新着インデックスの生成（全メンバー分）
	if($my_account->{'osdiary'} ne "0" && $my_account->{'osdiary'} ne "2"){

		# 判定
		my($plustype_alldiary);
				if(!$main::in{'newlist'}){ $plustype_alldiary .= qq( Hidden-diary); }

			# 新着リストに載せるか否か
			foreach(split/<br>/,$new_comment){
					#if($_ =~ /(釣|吊)られた人)/){ $plustype_alldiary .= qq( Hidden-diary); }
					if($_ =~ /地雷/ && $_ =~ /(バトン|です)/){ $plustype_alldiary .= qq( Hidden-diary); }
			}

			# 題名チェック
			if($new_subject =~ /(金貨|猫|いいね！)(.{0,30})(欲しい|ほしい|ゆずって|譲って|恵んで|(くだ|クダ|下)(さい|サイ)|ちょうだい|頂戴|\Qちょーだい\E)/){ $plustype_alldiary .= qq( Hidden-diary); }

				# 注意投稿ファイルを更新
				#Mebius::Auth::all_members_diary("New-file New-line Renew $plustype_alldiary",$my_account->{'id'},$newnum,$new_subject,$new_comment,$my_account->{'name'});

					# 注意投稿ファイルを更新
					#if($main::a_com){
						#Mebius::Auth::all_members_diary("Alert-file New-line Renew $plustype_alldiary",$my_account->{'id'},$newnum,$new_subject,$new_comment,$my_account->{'name'});
					#}
			}

# ロック解除
&unlock("auth$my_account->{'id'}");

# 人数分×マイメビ更新のインデックスの作成
Mebius::Auth::FriendIndex("New-diary",$my_account->{'file'},$newnum,$new_subject,$my_account->{'name'});

# 総レス数を更新
Mebius::Newlist::Daily("Renew Postdiary-auth");

	# 自ファイルの【新規投稿待ち時間】を更新
	if($my_account->{'level2'} >= 1){
		$renew_myaccount{'next_diary_post_time'} = time + 6*60;
	}
	else{
		$renew_myaccount{'next_diary_post_time'} = time + 10*60;
	}


# 自分のオプションファイルを更新
#Mebius::Auth::Optionfile("Renew",$my_account->{'file'},%renew_myaccount);

# 自ファイルを更新
Mebius::Auth::File("Renew Option",$my_account->{'file'},\%renew_myaccount);

# 自分の基本投稿履歴ファイルを更新
Mebius::HistoryAll("Renew My-file");

# フィード用のメモリテーブルを更新
my $feed = new Mebius::SNS::Feed;
#my $sns_url = new Mebius::SNS::URL;
#my $diary_url = $sns_url->diary_url($my_account->{'id'},$newnum);
my $hidden_flag = 1 if(!$param->{'newlist'});
my $update_all_members_news = hash_to_utf8({ content_type => "sns_diary" , data1 => $newnum , post_time => time , subject => $new_subject , account => $my_account->{'id'} , handle => $my_account->{'handle'} , hidden_flag => $hidden_flag });
$feed->insert_main_table($update_all_members_news);

my $subject_utf8 = utf8_return($new_subject);
my $handle_utf8 = utf8_return($my_account->{'name'});
$sns_diary->create_common_history_on_post({ content_targetA => $my_account->{'id'} , content_targetB => $newnum , subject => $subject_utf8 , handle => $handle_utf8 , content_create_time => time  });

#Mebius::Redirect("","$basic_init->{'auth_url'}$my_account->{'id'}/#DIARY");
Mebius::redirect("$my_account->{'profile_url'}d-$newnum");

# 処理終了
exit;

}


#-----------------------------------------------------------
# プレビュー
#-----------------------------------------------------------
sub auth_fdiary_preview{

# 宣言
my($msg) = @_;
my($submit,$com_value,$newlist_checked);
our(%in,$lockflag,$footer_link,$footer_link2,$sikibetu,$action);

	# エラー時アンロック
	if ($lockflag) { &unlock($lockflag); }

	# チェック
	if($in{'newlist'}){ $newlist_checked = " checked"; }

$com_value = qq(\n$in{'comment'});
$com_value =~ s/<br>/\n/g;

if($msg){
$msg = qq(<div class="error">エラー：<br$main::xclose> $msg</div><br><br>);
}
else{ $msg = qq(<span class="blue">▼プレビュー中です。まだ書き込まれていません。</span><br><br>); }

my $print = qq(
$footer_link
<form action="$action" method="post"$sikibetu>
<div>
$msg
<h1>$in{'sub'}</h1>

<span style="color:#$main::myaccount{'color2'};">$in{'comment'}</span><br><br>

);

#<h2>修正フォーム</h2><br>

$print .= sns_diary_new_form_core($in{'sub'},$com_value);


$print .= $footer_link2;


Mebius::Template::gzip_and_print_all({},$print);

exit;

}



#-----------------------------------------------------------
# 日記投稿フォームの表示
#-----------------------------------------------------------

sub auth_fdiary_form{

my($type,$maxmsg,$minmsg) = @_;
our($sns_rule,$title,$guide_url,$footer_link,$footer_link2);

# フォーム取得
my($form) = auth_fdiary_getform();

my $text2 = qq(
<ul class="alert_area">
<li>「日記本体」や「日記へのコメント」は、あなたが管理する必要があります。<strong class="red">個人情報、マナー違反、悪意のある投稿、荒らし、迷惑投稿などは必ず削除してください。</strong>管理されていないアカウントは\予\告\なしにロック（削除）させていただく場合があります。
<li><a href="$sns_rule">$titleのルール</a>を守って書き込んでください。「性的な内容が含まれるもの」は一括禁止です。（題名で性的なものを連想させるものや、ネタ・ジョークも削除となる場合があります）
<li><a href="${guide_url}%A5%EB%A1%BC%A5%EB%A3%D1%A1%F5%A3%C1">まったく同じ文章（または、ほとんど同じ文章）を無限に増やしてゆく「チェーン投稿・コピペ投稿」は禁止です。</a>
<li>特に<strong class="red">「マナーを欠いたグチ」や「バッシング目的の日記」「暴\言日記・暴\言バトン」「（チャット化としての）落ち報告の日記」「短文宣伝日記」</strong>など作らないよう、注意をお願いします。 
<li>個人（他のユーザー様など）に対しての批判や意見募集はご遠慮ください。意見がある場合は、丁寧にその方自身と話し合ってください。
<li><strong class="red">「電話番号交換」「メールアドレス交換」「住所掲載」などの個人情報掲載は、絶対にやめてください（直接、間接を問わず）</strong>。即時アカウントロック、投稿制限させていただく可\能\性があります。
<li>ＳＮＳについてのご提案、ご要望は<a href="http://aurasoul.mb2.jp/_qst/2245.html">質問運営板</a>までお願いします。
<li>「暴\言」「激しいグチ」などでどうしても我慢できない場合は 【 <a href="http://mb2.jp/_main/hole.html" target="_blank" class="blank big">王様の穴</a> 】をご利用ください。</li>
</ul>
<br>
);

my $print = <<"EOM";
$footer_link
<h1>新しい日記の投稿</h1>
$text2
$form
EOM

Mebius::Template::gzip_and_print_all({ NotMebiusDiaryButton => 1 },$print);

exit;

}

#-----------------------------------------------------------
# 日記投稿フォームの表示
#-----------------------------------------------------------
sub auth_fdiary_getform{

my($sub,$comment,$form);
my($type,$maxmsg,$minmsg,$text2) = @_;
my($q) = Mebius::query_state();
my($my_account) = Mebius::my_account();
my($form);
our(%in,$sikibetu,$ipalert,$action,$footer_link,$footer_link2);

	# ストップモード
	if($main::stop_mode =~ /SNS/){ return("現在、SNS全体で投稿停止中です。"); }

	# 初期入力内容を定義
	if($ENV{'REQUEST_METHOD'} eq "POST"	|| ($q->param('account') eq $my_account->{'id'} && $my_account->{'login_flag'})){
		$sub = $in{'sub'} if($q->param('sub'));
		$sub = $in{'subject'} if($q->param('subject'));
		$sub =~ s/<br>//g;
		$comment = $in{'comment'};
		$comment =~ s/<br>/\n/g;
	}


$form .= $text2;
$form .= sns_diary_new_form_core($sub,$comment);

return($form);

}

#-----------------------------------------------------------
# 
#-----------------------------------------------------------
sub sns_diary_new_form_core{

my $use = shift if(ref $_[0] eq "HASH");
my $sub = shift;
my $comment = shift;
my $html = new Mebius::HTML;
my($form);
my($param) = Mebius::query_single_param();
our($sikibetu,$action);


#題： <input type="text" name="sub" value="$in{'sub'}" class="sub"><br><br>
#<textarea name="comment" class="textarea" cols="25" rows="5">$com_value</textarea>
#<br><br><input type="submit" name="preview" value="この内容でプレビューする" class="ipreview">
#<input type="submit" value="この内容で送信する" class="isubmit">
#<input type="checkbox" name="newlist" value="1" id="check_newlist"$newlist_checked> <label for="check_newlist">全メンバーの新着一覧に載せる</label>
#<input type="hidden" name="mode" value="fdiary">
#<input type="hidden" name="action" value="new">
#</div>
#</form>



$form .= qq(
<form action="$action" method="post"$sikibetu>
<div>
<h2>題名</h2>
<input type="text" name="sub" value=").e($sub).qq(" class="pinput"><br>
<h2>本文</h2>
<textarea name="comment" class="textarea" cols="25" rows="5">).e($comment).qq(</textarea>

<br><input type="submit" name="preview" value="プレビュー" class="ipreview">
<input type="submit" value="送信する" class="isubmit">);

$form .= $html->input("radio","on_feed","1",{ text => "新着に載せる" , default_checked => 1  });
$form .= $html->input("radio","on_feed","0",{ text => "新着に載せない" });

$form .= qq(
<input type="hidden" name="mode" value="fdiary">
<input type="hidden" name="action" value="new">
</div>
</form>
);

$form;

}


1;
