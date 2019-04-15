
use strict;
use Mebius::SNS::Friend;
use Mebius::SNS::Message;
use Mebius::SNS::Diary;
package main;
use Mebius::Export;

#-------------------------------------------------
# プロフィール表示
#-------------------------------------------------
sub auth_prof{

# 局所化
my($file,$ads1,$star,$member_mark,$print);
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
my(%account,$profile_line,$myform,$newcomment,$newdiary_index,$message_news,$friend_diary,$addata,$error_text,%res_news,$news_link,$friendlink,$pri_ppencid,$pri_ppenctrip,$question_history);
our($css_text,$kflag,$kfontsize_h2,$hername,%box,%in,$adir,$xclose,$friend_tag,$script,$kfontsize_h1,$title);


	# アクセス振り分け ( デスクトップ版→モバイル版 )
	if(our $submode1 eq ""){
		our $divide_url = "$basic_init->{'auth_url'}$in{'account'}/iview";
	}

	# アクセス振り分け ( モバイル版→デスクトップ版 )
	if(our $submode1 eq "iview"){
		our $divide_url = "$basic_init->{'auth_url'}$in{'account'}/";
		#if($device_type eq "desktop"){ &divide($divide_url,"desktop"); }

		# 携帯版のURLをまとめる
		Mebius::Redirect(undef,"$basic_init->{'auth_url'}$in{'account'}/",301);

	}

# 携帯版マイページの戻り先
our $mybackurl = "$basic_init->{'auth_url'}$in{'account'}/";

	# 広告の定義
#	if(!Mebius::alocal_judge()){
#$ads1 = '
#<hr>
#<script type="text/javascript"><!--
#google_ad_client = "pub-7808967024392082";
#/* ＳＮＳ */
#google_ad_slot = "2938623053";
#google_ad_width = 300;
#google_ad_height = 250;
#//-->
#</script>
#<script type="text/javascript"
#src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
#</script>';
#	}

#汚染チェック
my $account = $file = $in{'account'};

	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$in{'account'})){ main::error("アカウント名の指定が変です。"); }
	if($file eq ""){ main::error("アカウントを指定してください。"); }

# CSS定義
$css_text .= qq(
h1{display:inline;}
.ptextarea{width:95%;height:300px;}
.max_msg{color:#f00;font-size:90%;}
.date{text-align:right;}
.lock{color:#080;}
.emergency{color:#f00;font-size:90%;font-weight:normal;}
.lim{margin-bottom:0.3em;line-height:1.25;}
.deleted{font-size:90%;color:#f00;}
.cbottun{margin-top:0.5em;}
.clog{font-size:90%;}
a.me:link{color:#f00;}
a.me:visited{color:#f40;}
.tag{margin-top:0.6em;word-spacing:0.3em;font-size:90%;line-height:2.0;}
.myfriend{font-size:90%;margin-top:0.6em;word-spacing:0.3em;}
.navilink{margin-top:0.6em;word-spacing:0.3em;}
.vrireki{word-spacing:0.2em;line-height:1.5;margin:0em;}
.sml{font-size:80%;color:#080;}
.andmore{color:#080;font-style:ltalic;}
.news{font-size:90%;}
.prof_next{font-size:140%;}
.cut_prof1{font-size:90%;line-height:1.4;}
.cut_prof2{font-size:80%;line-height:1.4;}
div.prof{line-height:1.4;}
.news_link{font-size:90%;}
);

# ファイルオープン
(%account) = Mebius::Auth::File("Option Kr-submit Kr-oneline Get-friend-status",$file,%$my_account);

	# ユーザー色指定
	if($account{'color1'}){ $css_text .= qq(h2{background-color:#$account{'color1'};border-color:#$account{'color1'};}); }

	# 自分のプロフィールページの場合、編集フォームを出す
	if($my_account->{'admin_flag'}){
			require "${init_directory}auth_myform.pl";
				if(our $submode1 eq "edit" && our $submode2 eq "detail"){ ($myform) = &auth_myform("Detail",$file); }
				else{ ($myform) = &auth_myform("",$file); }
	}
	elsif($account{'myprof_flag'}){ $myform = qq(<h2$kfontsize_h2>設定変更</h2><a href="./edit#EDIT">→設定変更フォームへ</a>); }

	# トリップ
	if($account{'enctrip'}){ $pri_ppenctrip = "☆$account{'enctrip'}"; }

	# プロフ表示名の調整
my $viewaccount = $account{'file'};
	if($account{'name'} eq "none"){ $viewaccount = "****"; }
	if($account{'name'} eq ""){ $hername = qq($viewaccount); }
	else{
		my($account);
		$account = $viewaccount;
		$hername = qq($account{'name'}$pri_ppenctrip <span class="green">).e("\@$file").qq(</span>);
	}

# タイトル決定
our $sub_title = "$account{'name'} \@$file | メビリンＳＮＳ";
#if($account{'myprof_flag'}){ our $head_link2 = qq(&gt; $title); }
our $head_link3 = qq(&gt; $account{'name'});

	# マイメビ申請リンク
	if($my_account->{'file'}){
			if($account{'friend_status_to'} eq "me"){ $friendlink = qq(<span style="color:#080;">自分</span>); }
			elsif($account{'friend_status_from'} eq "deny"){ $friendlink = qq(<span style="color:#f00;">あなたが禁止設定中</span>); }
			elsif($account{'friend_status_to'} eq "deny"){ $friendlink = qq(); }
			#elsif($account{'friend_status_to'} eq "apply"){ $friendlink = qq(<span style="color:#080;">あなたに$main::friend_tag申\請しています</span>); }
			elsif($account{'friend_status_from'} eq "apply"){ $friendlink = qq(<span style="color:#080;">$main::friend_tag申\請中</span>); }
			elsif($account{'friend_status_to'} eq "friend"){ $friendlink = qq( <span style="color:#080;">マイメビ</span> ); }
			elsif($account{'herbirdflag'}){ $friendlink = qq( 筆名未設定 ); }
			elsif(our $birdflag){ $friendlink = qq( $friend_tag申\請するには<a href="$basic_init->{'auth_url'}#EDIT">あなたの筆名を作成</a>してください。 ); }
			else{ $friendlink = qq( <a href="$script?mode=befriend&amp;account=$file">マイメビ申\請</a> ); } 
	}
	else{
		my($request_url_encoded) = Mebius::request_url_encoded();
		$friendlink = qq(マイメビ申\請するには<a href="$basic_init->{'auth_url'}?backurl=$request_url_encoded">ログイン（または新規登録）</a>してください。 );
	}


	# 禁止設定リンク
	if($my_account->{'file'} && !$account{'myprof_flag'}){
		$friendlink .= qq( <a href="./?mode=befriend&amp;decide=deny">禁止設定</a> );
	}

	# メッセージフォームへのリンク
	if($account{'editor_flag'}){
		#(%box) = Mebius::Auth::MessageBox("Get-new-status",$account{'file'},"catch");
	}
	if($account{'myprof_flag'} && $account{'allow_message_flag'}){
		$friendlink .= qq( <a href="./?mode=message">メッセージ</a>\n);
	}
	elsif($account{'allow_message_flag'} && $my_account->{'allow_message_flag'}){
		$friendlink .= qq(<a href="${main::adir}$my_account->{'file'}/?mode=message&amp;to=$file">メッセージ</a>\n);
	}


	# 猫
	if(!$my_account->{'login_flag'} && !$account{'votepoint'}){ }
	elsif($my_account->{'allow_vote'} eq "not-use"){ }
	else{
		my $cat = $account{'votepoint'} || 0;
		$friendlink .= qq( <a href="./vote">猫\($cat\)</a> );
	}


# プロフィールを取得
($profile_line) = &auth_viewprof("",$file,%account);

	# ＩＤ、トリップの整形
	if($account{'encid'}){ $pri_ppencid = "　<i>★$account{'encid'}</i>"; }

	# アカウント作成時期により、BBSを作れない
	if($my_account->{'firsttime'} && $my_account->{'firsttime'} > 1234530536){ our $notbbs_flag = 1; }

# 日記、コメントフォームなどのログ読み込み
my($friend_list,$friend_list2) = friendlist_prof_auth("",$file,%account);
my($diary_index,$diary_allindex,$diary_tag) = diary_prof_auth("",$file,%account);
my($bbs_index) = bbs_prof_auth("",$file,\%account);
my($line_comments) = auth_prof_comment("",$file,\%account);

my($tagline) = auth_prof_tag("",$file,%account);

# アカウントロック理由、警告を取得
my($alert_text) = auth_prof_get_alert("",%account);

# ナビ
my $clink = "$adir$file/viewcomment";

my $navilink .= qq(<a href="#PROF" class="move">▼プロフィール</a>);
if(our $prof_flow_flag){ $navilink .= qq((<a href="./aview-prof">全</a>)); }
$navilink .= qq( );

if($diary_tag || $account{'myprof_flag'}){ $navilink .= qq(<a href="#DIARY" class="move">▼日記</a>); }

if($account{'myprof_flag'}){ $navilink .= qq(（<a href="$script?mode=fdiary">新規</a>）); }
$navilink .= qq( );

	# マイメビページへのリンク
	if($friend_list){
		$navilink .= qq(<a href="./aview-friend">$main::friend_tag($account{'friend_num'})</a> );
	}


	if($account{'ocomment'} ne "3"){ $navilink .= qq(<a href="#COMMENT" class="move">▼伝言板</a> ); }
	#if($account{'myprof_flag'} || $my_account->{'admin_flag'}){ $navilink .= qq(<a href="./edit">設定変更</a> ); }

	if($account{'rireki_flag'}){
		my $style = qq( style="color:#aaa;") if($account{'orireki'} eq "0");
		$navilink .= qq(<a href="aview-history"$style>SNS履歴</a> );
	}

	if($account{'myprof_flag'} && !$account{'level2'}){
		my $link = qq($adir$my_account->{'id'}/spform);
		$navilink .= qq( <a href="$link" class="red">★SP会員登録</a>);
	}

	# 各種履歴
	if($my_account->{'admin_flag'} || $account{'myprof_flag'}){
		$navilink .= qq( <a href="${adir}aview-login-$file.html" class="red">各種履歴</a>);
	}

	# ●最終ログイン時間の表示
	if($account{'last_access_time'}){

		# 局所化
		my($allow_flag,$allow_view);

			# 表示権限チェック ( 表示しない場合を判定 )
			if($main::myadmin_flag){ $allow_view = 1; }
					elsif($account{'allow_view_last_access'} eq "Not-open"){ }
					elsif($account{'allow_view_last_access'} eq "Friend-only"){
					if($account{'friend_status_to'} eq "friend" || $account{'myprof_flag'}){ $allow_view = 1; }
					else{ }
			}
			else{
					if($my_account->{'file'}){ $allow_view = 1; }
			}

			# 表示権限がある場合
			if($allow_view){
				my($access_time) = Mebius::SplitTime("Get-top-unit Color-view Plus-text-前",$main::time - $account{'last_access_time'});
					if($access_time){ $navilink .= qq( 最終ログイン： $access_time); }
			}

	}

# 管理者の場合、各種データ取得
if($my_account->{'admin_flag'}){ ($addata) = get_addata("",$file,%account); $navilink .= $addata; }


	# エラー文
	if($account{'key'} eq "2"){
		$error_text .= qq(このアカウントはロック中です ($account{'account_locked_count'}回目) );
			if($account{'blocktime'}){
				my $unblock_date = int( ($account{'blocktime'} - time) / (24*60*60) ) + 1;
				$error_text .= qq(解除日は$unblock_date日後です。);
			}
			else{
				$error_text .= qq( [ 無期限 ] );
			}
				$error_text .= qq(（<a href="$basic_init->{'guide_url'}%A5%A2%A5%AB%A5%A6%A5%F3%A5%C8%A5%ED%A5%C3%A5%AF">→Ｑ＆Ａ</a>）);
			}
		if($error_text){ $error_text = qq(<strong class="red">$error_text</strong> ); } 

	# 管理者の場合
	if($account{'admin'}){
		$member_mark .= qq(　<a href="http://mb2.jp/_main/admins.html" class="red" title="管理者">◎管理者</a>);
	}

	# SP会員の証
	if($account{'level2'} >= 1){
			if($my_account->{'login_flag'}){
				$member_mark .= qq(　<a href="$adir$my_account->{'id'}/spform" class="blue" title="SPメンバー">★SP会員</a>);
			}
			else{
				$member_mark .= qq(　<span class="blue" title="SPメンバー">★SP会員</span>);
			}
	}

	# おすすめＵＲＬ
	#if($account{'myurl'}){
	#	$member_mark .= qq(　<a href="$account{'myurl'}" title="$account{'myurl'}">○$account{'myurltitle'}</a>);
	#}

	# マーク整形
	if($member_mark){
		$member_mark = qq(<span class="member_mark">$member_mark</span>);
	}


	# 携帯広告
	if($kflag){
		my($kadsense) = kadsense("OTHER");
		$print .= qq($kadsense<hr$xclose>);
	}

	# ニュースフィード
	my($news);


	if($account{'question_last_post_time'}){
		$question_history = Mebius::Question::View->one_account_question(10,$account);
			if($question_history){
				$question_history = qq(<h2 id="QUESTION">くえすちょん?</h2>) . shift_jis($question_history);
			}
	}

# HTML
$print .= our $footer_link;

$print .= qq(
<h1$kfontsize_h1>$hername</h1>
$pri_ppencid $member_mark
$error_text
<div class="navilink">$friendlink$navilink</div>
$alert_text);

	# CCC 2012/8/21 (火) - 1week
	my($q) = Mebius::query_state();
	if(time < 1345553915 + 7*24*60*60 && $my_account->{'login_flag'} && $my_account->{'file'} eq $q->param('account')){
		$print .= qq(<div class="red padding">※お知らせ…新着情報は<a href="./feed" class="red">フィードページ</a>に移動しました。</div>);
	}


$print .= qq($profile_line
<div class="upmenu">$tagline</div>
$diary_tag
$diary_index
$diary_allindex
$bbs_index
$question_history
$friend_list2
$line_comments
);

# 編集フォーム表示
$print .= $myform;

$print .= our $footer_link2;

# フッタ
Mebius::Template::gzip_and_print_all({},$print);

# 処理終了
exit;
}


#-----------------------------------------------------------
# 新着マイメビのトピックス（自分用）
#-----------------------------------------------------------
sub defined_befriend_list{

# 宣言
my($type,$file) = @_;
my($befriend_handler);
my($i,$text1,$h3,$befriend_link,$flowflag,$new_apply_num,$applty_time,$most_new_applied_time);
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();

	# ファイル定義
	if(Mebius::Auth::AccountName(undef,$file)){ return(); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ファイルを開く
open($befriend_handler,"<","${account_directory}${file}_befriend.cgi");

# ファイルを展開
	while(<$befriend_handler>){

		$i++;

		$new_apply_num++;


			if($i >= 5){ next; }

		chomp;
		my($account2,$name,$applty_time2) = split(/<>/);
	
			#if(time < $applty_time2 + (3*24*60*60)){
				#$new_apply_num++;
			#	$applty_time = $applty_time2;
			#}

			# 最も最近の申請時間を記憶
			if($applty_time2 > $most_new_applied_time){
				$most_new_applied_time = $applty_time2;
			}

		$befriend_link .= qq(<li><a href="$basic_init->{'auth_url'}$account2/">$name - ${account2}</a> ： );
		$befriend_link .= qq(<a href="$main::script?mode=befriend&amp;decide=ok&amp;account=${account2}">許可</a> | );
		$befriend_link .= qq(<a href="$main::script?mode=befriend&amp;decide=no&amp;account=${account2}">拒否</a></li>);
			if($i >= 3){ $flowflag = 1; next; }
	}

close($befriend_handler);

	# 見出し定義
	if($befriend_link) {

		$h3 = qq(<a href="./aview-befriend">新着マイメビ申\請</a>);

		$befriend_link = qq(
		<h3$main::kstyle_h3>$h3</h3>
		<ul>$befriend_link</ul>
		);

	}

return($befriend_link,$new_apply_num,$most_new_applied_time);

}


#-----------------------------------------------------------
# アラートがある場合
#-----------------------------------------------------------
sub auth_prof_get_alert{

# 宣言
my($type,%account) = @_;
my($alert_text,$alert_text_return);
my($init_directory) = Mebius::BaseInitDirectory();
our($css_text);

# リターン

# 制限時間が終わっている場合
if($account{'reason'} eq ""){ return(); }


# CSS定義
$css_text .= qq(div.alert3{background-color:#f55;color:#fff;font-weight:bold;padding:0.3em 0.5em;margin-top:1em;});

# 警告理由
require "${init_directory}part_delreason.pl";
($alert_text) = &delreason($account{'reason'},"ONLY");
my $alert_count = qq(（警告：$account{'alert_count'}回目）) if($account{'alert_count'});

	# 警告文がある場合
	if($alert_text){

			# 警告内容
			if($account{'alert_flag'}){
					if($account{'editor_flag'}){
						$alert_text_return = qq(管理者からメッセージ $alert_count (内容はあなただけに見えます)： $alert_text);
					}
					else{
						$alert_text_return = qq(このアカウントには、管理者から警告が送られています。$alert_count);
					}
			}

			# アカウントロック中は、全員にロック理由を表示
			elsif($account{'key'} eq "2"){

					# ロック理由を表示しない場合
					if($account{'reason'} eq "8" || $account{'reason'} eq "11"){

						if($account{'editor_flag'}){
							$alert_text_return = qq(ロック理由： $alert_text (理由はあなたにだけ表\示されています));
						}
						else{
							$alert_text_return = qq(ロック理由の種類は本人に表\示されます);
						}
					}
					# ロック理由を表示する場合
					#if($account{'blocktime'} >= time || !$account{'blocktime'}){
					else{
						$alert_text_return = qq(ロック理由： $alert_text);
					}
					#}
					

			}

	}

	# 整形
	if($alert_text_return){

			if($account{'editor_flag'}){
				$alert_text_return .= qq(<br$main::xclose><span class="size80">※ご注意 ： あなたの全ての投稿の中で、ガイドに反すると思われる箇所は、ご自身でも削除をお願いします。 不適切な部分が残ったままの場合、アカウントの状態が重くなる場合があります。</span>);
			}
			#else{
			#	$alert_text_return .= qq(<br$main::xclose><span class="size80">※全ての投稿の中から、ガイドに反すると思われる箇所は、ご自身でも削除をお願いしています。 不適切な部分が残ったままの場合、アカウントの状態が重くなる場合があります。</span>);
			#}

		$alert_text_return = qq(<div class="alert3 line-height">$alert_text_return</div>);

	}

return($alert_text_return);

}

#──────────────────────────────
# マイメビの一覧
#──────────────────────────────
sub friendlist_prof_auth{

# 局所化
my($type,$file,%account) = @_;
my($flow,$i,$text,$friend_num,$h2_text);
our($kfontsize_h2,$friend_tag,$adir);

# マイメビ リストの最大表示数
my $max_viewfriend = 10;

my(%friend_index) = Mebius::Auth::FriendIndex("Get-all-index",$file);

my $friend_list = $friend_index{'topics_line'};
my $friend_list2 = $friend_index{'index_line'};

#リンク
my $link = "$adir$file/aview-friend";

	# 整形１
	if($i){
		$h2_text = qq(<a href="$link">$friend_tag</a>);
	}	else {
		$h2_text = qq(<a href="$link">$friend_tag</a>);
	}

	if($account{'friend_num'}){ $friend_num = qq(($account{'friend_num'})); }

	# 整形２
	if($flow){ $friend_list .= qq(<a href="$link" class="andmore">…他のメンバー</a> ); }
	else{$friend_list .= qq(<a href="$link" class="andmore">→紹介文</a>); }
	if($friend_list ne "") { $friend_list = qq(<div class="myfriend"><a href="$link">◎$friend_tag</a> … $friend_list</div>); }

	if($friend_list2 ne "") { $friend_list2 = qq(<h2 id="FRIEND"$kfontsize_h2><a href="$link">$friend_tag$friend_num</a></h2><div class="line-height-large">$friend_list2</div>); }


$friend_list,$friend_list2;

}


#-----------------------------------------------------------
# プロフィール処理
#-----------------------------------------------------------
sub auth_viewprof{

my($type,$file,%account) = @_;
my($i,$flag,$prof1,$prof2,$pri_prof);
my($kr_line,$kr_flow_flag,$birthday_text,$max1);
my($my_use_device) = Mebius::my_use_device();
our($kflag,$kfontsize_h2,$xclose);

	if($my_use_device->{'narrow_flag'}){
		$max1 = 50;
	} else {
		$max1 = 150;
	}

	# プロフィールがない場合
	if($account{'prof'} eq ""){
		$pri_prof = qq(<h2 id="PROF"$kfontsize_h2>プロフィール</h2>プロフィールはまだありません。);
			if($account{'editor_flag'}){ $pri_prof .= qq(　<a href="./edit">設定変更フォーム</a>であなたのプロフィールを書いてください。); }
		return($pri_prof);
	}


# プロフある場合
$pri_prof .= qq(\n);

	# ●誕生日の表示
	if($account{'birthday'}){
		$main::css_text .= qq(div.birthday{padding:0.3em 0.5em;});

			if($account{'birthday_concept'} !~ /Not-open/ && ($account{'friend_status_to'} eq "friend" || $account{'myprof_flag'})){
				$birthday_text = qq($account{'birthday'} <span style="color:#080;"> [ $main::friend_tag だけに表\示しています ] </span>);
			}
			elsif($main::myadmin_flag){
				$birthday_text = qq($account{'birthday'} <span style="color:#f00;"> [ 管理者だけに表\示しています ] </span>);
			}
			if($birthday_text){
				$birthday_text = qq(<div class="birthday" style="background:#dee;">誕生日： $birthday_text</div><br$main::xclose>);
			}
		$pri_prof .= qq($birthday_text);
	}

# プロフィールを行数で区切る
foreach( split(/<br>/,$account{'prof'}) ){
$i++;
if($i > $max1){ $flag = 1; next; }
$_ = &auth_auto_link($_);
$pri_prof .= qq($_<br$xclose>);
}

$pri_prof .= qq(\n);

#my $zan = $i - $max;
my $zan = $i - $max1;

my($cut);
if($i > 75){ $cut = qq( class="cut_prof1"); }
else{ $cut = qq( class="prof"); }

	if($flag){
		our $prof_flow_flag = 1;
		$pri_prof .= qq(<br$xclose><a href="./aview-prof" class="prof_next">…$max1行以上は省略されます</a> <a href="./aview-prof#AVIEW" class="prof_next">▽</a>);
		$pri_prof = qq(<h2 id="PROF"$kfontsize_h2><a href="./aview-prof">プロフィール</a></h2><div$cut>$pri_prof</div>);
	}
	else{
		$pri_prof = qq(<h2 id="PROF"$kfontsize_h2>プロフィール</h2><div$cut>$pri_prof</div>);
	}

# 曖昧関連をプラス
if($account{'kr_flag'}){ $pri_prof .= qq($account{'kr_oneline'}); }

# 関連リンクがオフの場合は広告を表示
#elsif(!$kflag && length($account{'prof'}) >= 2*50 && !$main::alocal_mode){
#$pri_prof .= qq(
#<br$main::xclose><br$main::xclose>
#<script type="text/javascript"><!--
#google_ad_client = "pub-7808967024392082";
#/* ＳＮＳ２ */
#google_ad_slot = "4618975314";
#google_ad_width = 468;
#google_ad_height = 60;
#//-->
#</script>
#<script type="text/javascript"
#src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
#</script>
#);
#}

# プロフィール下部エリア

$pri_prof .= qq(<div class="size90 right margin-top">);

	# プロフィールの最終編集時間
	if($account{'last_profile_edit_time'}){
		my($how_before) = Mebius::SplitTime("Color-view Plus-text-前 Get-top-unit",$main::time - $account{'last_profile_edit_time'});
		$pri_prof .= qq( 編集： $how_before );
	}

	# 編集リンク
	if($account{'editor_flag'}){
		$pri_prof .= qq(　<a href="./edit#EDIT">→プロフィールを編集</a>);
	}

$pri_prof .= qq(</div>);

return($pri_prof);

}


#──────────────────────────────
# 日記インデックス
#──────────────────────────────
sub diary_prof_auth{

# 宣言
my($type,$file,%account) = @_;
my($text1,$text2,$alldiary_num,$diary_index,$diary_allindex,$onlyflag,$diary_tag);
my($my_account) = Mebius::my_account();
my($init_directory) = Mebius::BaseInitDirectory();
our($kfontsize_h2,$xclose,$adir,$script);

	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$file)){ return(); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

	# コメント許可設定の表示
	if($account{'odiary'} eq "0"){ $text1 = qq(<em class="red">▼アカウント主だけがコメントできます</em>); }
	elsif($account{'odiary'} eq "2"){ $text1 = qq(<em class="green">▼マイメビだけがコメントできます</em>); }
	else{ $text1 = qq(<em>▼全メンバーがコメントできます</em>); }

	# 表示制限
	if($account{'level'} >= 1){
		if($account{'osdiary'} eq "2"){
		if($account{'friend_status_to'} ne "friend" && !$account{'myprof_flag'} && !$my_account->{'admin_flag'}){ return; }
		$text2 = qq(　<em class="green">●$マイメビだけに日記公開中です</em>);
		$onlyflag = 1;
	}
	elsif($account{'osdiary'} eq "0"){
		if(!$account{'myprof_flag'} && !$my_account->{'admin_flag'}){ return; }
		$text2 = qq(　<em class="red">●自分だけに日記公開中です</em>);
		$onlyflag = 1;
		}
	}

# 現行インデックスを開く
#my($index) = Mebius::SNS::Diary::index_file_per_account({ file_type => "now" } , $file);
my($now_diary_index,$diary_index_data) = Mebius::SNS::Diary::view_index_per_account({ NotControlForm => 1 , max_view_line => 10  } , "now",$file);
shift_jis($now_diary_index);
	if($now_diary_index){ $diary_index = qq($text1$text2<br$xclose><br$xclose>$now_diary_index); }

require "${init_directory}auth_diax.pl";
$diary_allindex = main::auth_all_diary_month_index(undef,$account{'id'});

	# 今までの日記の個数
	if($diary_index_data->{'newest_diary_number'}){ $alldiary_num = qq( ($diary_index_data->{'newest_diary_number'})); }

	if($diary_allindex){ $diary_allindex = qq(<div class="scroll margin-top"><div class="scroll-element"><a href="./diax-all-new">ログ</a> ： $diary_allindex</div></div>); }

	if($diary_index eq "" && $diary_allindex eq "" && $account{'myprof_flag'}) {
		$diary_tag = qq(<h2 id="DIARY"$kfontsize_h2><a href="./diax-all-new">日記</a></h2>);
		$diary_index = qq(日記はまだありません<br$xclose>);
	}

	if($diary_index ne "" || $account{'myprof_flag'}){ $diary_tag = qq(<h2 id="DIARY"$kfontsize_h2><a href="./diax-all-new">日記$alldiary_num</a></h2>); }

	if($account{'myprof_flag'}){ $diary_tag .= qq(<a href="$script?mode=fdiary">→新しい日記を書く</a><br$xclose><br$xclose>); }

$diary_index,$diary_allindex,$diary_tag;

}

#──────────────────────────────
# ＢＢＳインデックス
#──────────────────────────────
sub bbs_prof_auth{

# 宣言
my($type,$file,$account) = @_;
my($onlyflag,$bbs_index);
my($my_account) = Mebius::my_account();
our($kfontsize_h2,$notbbs_flag,$xclose,$adir,$yetfriend,$friend_tag);

	# ファイル定義
	if(Mebius::Auth::AccountName(undef,$file)){ return(); }
	
	# BBSフラグが立っていない場合は、ファイルを開かずに負荷軽減する
	if(time >= 1333597014 + 30*24*60*60 && !$account->{'use_bbs'}){
		return();
	}

	# アカウント作成時期により、BBSを作れない
	if($notbbs_flag && $account->{'myprof_flag'}){ return; }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# 局所化
my($text1,$text2);

	# コメント許可設定の表示
	if($account->{'obbs'} eq "0"){ $text1 = qq(<em class="red">▼アカウント主だけがコメントできます</em>); }
	elsif($account->{'obbs'} eq "2"){ $text1 = qq(<em class="green">▼$friend_tagだけがコメントできます</em>); }
	else{ $text1 = qq(<em>▼全メンバーがコメントできます</em>); }

	# 表示制限
	if($account->{'level'} >= 1){
			if($account->{'osbbs'} eq "2"){
			if(!$yetfriend && !$account->{'myprof_flag'} && !$my_account->{'admin_flag'}){ return; }
		$text2 = qq(　<em class="green">●$friend_tagだけにBBS公開中です</em>);
		$onlyflag = 1;
	}
	elsif($account->{'osbbs'} eq "0"){
			if(!$account->{'myprof_flag'} && !$my_account->{'admin_flag'}){ return; }
				$text2 = qq(　<em class="red">●自分だけにBBS公開中です</em>);
				$onlyflag = 1;
			}
	}

# 現行インデックスを読み込み
my $open = open(INDEX_IN,"<","${account_directory}bbs/${file}_bbs_index.cgi");
my $top = <INDEX_IN>;
	while(<INDEX_IN>){
		my($key,$num,$sub,$res,$dates,$newtime,$restime,$resaccount,$resname) = split(/<>/,$_);
		my($year,$month,$day,$hour,$min) = split(/,/,$dates);
		my($link,$mark,$line);

		$link = qq($adir${file}/b-$num);

			if($key eq "0"){ $mark .= qq(<span class="lock"> - ロック中</span> ); }

		# 普通に表示する
			if($key eq "0" || $key eq "1"){
			if($resaccount){ $mark .= qq( - <a href="$link#S$res">Re: $resname - $resaccount</a>); }
		#if(time < $newtime + 3*24*60*60){ $mark .= qq( - <span class="red">new!</span>); }
			if(time < $restime + 3*24*60*60){ $mark .= qq( - <span class="red">res!</span>); }
				$bbs_index .= qq(<li><a href="$link">$sub</a> ($res)$mark</li>);
			}

		# 削除済みの場合
		else{
			my($text);
				if($key eq "2"){ next; $text .= qq( アカウントにより削除); }
				elsif($key eq "4"){ $text .= qq( 管理者により削除); }
				if($my_account->{'admin_flag'}){ $text .= qq( <a href="$link" class="red">$sub</a>); }
			$bbs_index .= qq(<li>$text</li>);
		}


	}
close(INDEX_IN);

	# CCC 2012/4/5 (木)
	if($open && !$account->{'use_bbs'}){
		my %renew;
		$renew{'use_bbs'} = 1;
		Mebius::Auth::File("Renew",$account->{'id'},\%renew);
		Mebius::AccessLog(undef,"SNS-BBS-flag-stand","$account->{'id'}");
	}

	if($bbs_index){ $bbs_index = qq(<h3 id="BBS_NEW">記事一覧</h3>$text1$text2<br$xclose><br$xclose><ul>$bbs_index</ul>); }

# ラベル
#my $bbs_tag = qq(<h2 id="BBS"$kfontsize_h2>BBS</h2>);
	#if($bbs_index eq "") { $bbs_tag = ""; }

	if($bbs_index) {
		$bbs_index = qq(<h2 id="BBS"$kfontsize_h2>BBS</h2>$bbs_index);
	}

$bbs_index;

}



#──────────────────────────────
# 伝言板
#──────────────────────────────
sub auth_prof_comment{

# 宣言
my($type,$file,$account) = @_;
my($i,$index,$stop,$form,$max,$flag,$line,$text);
my($init_directory) = Mebius::BaseInitDirectory();
my($my_account) = Mebius::my_account();

# ファイル定義
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ return(); }

# CSS定義
$main::css_text .= qq(
div.comment{width:40em;word-wrap:breal-word;line-height:1.2;}
td{padding:0.3em 0em 0.3em 0.5em;vertical-align:top;vertical-align:top;}
);

require "${init_directory}auth_comment.pl";
my($comments,$form) = view_auth_comment("PROF Get-index",$file,"",5,%$account);

# 非表示設定の場合
if($account->{'ocomment'} eq "3" && !$my_account->{'admin_flag'}){ return; }

$line = qq($comments<br$main::xclose>$form);

return($line);

}



#-----------------------------------------------------------
# マイタグ取得
#-----------------------------------------------------------
sub auth_prof_tag{

# 局所化
my($type,$file,%account) = @_;
my($init_directory) = Mebius::BaseInitDirectory();
my($my_use_device) = Mebius::my_use_device();
my($tagline,$max_view_tag_num,$nextlink,$i);
our($adir);

	# タグの最大表示数
	if($my_use_device->{'smart_flag'}){
		$max_view_tag_num = 16;
	} else {
		$max_view_tag_num = 16;
	}

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# マイタグファイルを開く
open(MYTAG_IN,"<","${account_directory}${file}_tag.cgi");
	while(<MYTAG_IN>){
		my($key,$tag) = split(/<>/,$_);
		if($key ne "1"){ next; }
		$i++;
		if($i > $max_view_tag_num){ $nextlink = qq(<a href="$adir$file/tag-view" class="andmore">…続きを見る</a>); last; }
		if($i > 1){ $tagline .= qq(); }
		my $enctag2 = $tag;
		$enctag2 =~ s/([^\w])/'%' . unpack("H2" , $1)/eg;
		$enctag2 =~ tr/ /+/;
		$tagline .= qq(<a href="${adir}tag-word-${enctag2}.html">$tag</a> );
	}
close(MYTAG_IN);

	# 整形
	if($tagline eq ""){
		$tagline = qq(●タグはまだありません。);
			if($account{'myprof_flag'}){ $tagline .= qq(（<a href="$adir$file/tag-view">→タグを登録する</a>）); }
	}
	else{
		$tagline .= $nextlink;
	}

$tagline = qq(<div class="tag scroll"><div class="scroll-element">タグ ： $tagline</div></div>);

$tagline;

}

#-----------------------------------------------------------
# 管理者にだけ見えるデータ取得
#-----------------------------------------------------------

sub get_addata{

# 宣言
my($type,$file,%account) = @_;
my($top,$login_date,$addata);
my($my_account) = Mebius::my_account();
our($css_text);

	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$file)){ return(); }

# CSS定義
our $css_text .= qq(\ndiv.addata{background-color:#ff0;margin-top:1em;padding:0.4em 0.9em;line-height:1.4;});

# ログイン履歴を開く
my(%login) = Mebius::Login->login_history("Onedata Admin",$file);
($login_date) = Mebius::Getdate("",$login{'lasttime'});

# 初期データを開く
#open(FIRST_IN,"${account_directory}${file}_first.cgi");
#$top = <FIRST_IN>; chomp $top;
#my($time2,$date2,$xip2,$host2,$age2,$cnumber2) = split(/<>/,$top);
#close(FIRST_IN);

# 登録日
my($first_date) = Mebius::Getdate("",$account{'firsttime'});

# リーダー以上に表示
my($enccnumber) = Mebius::Encode("",$login{'cnumber'});

$addata .= qq(<div class="addata">);

$addata .= qq(登録日： $first_date 最終ログイン： $login_date );
$addata .= Mebius::Admin::user_control_link_cookie($login{'cnumber'}) . " - ";

	# マスターに表示
	if($my_account->{'admin_flag'} >= 5){
		$addata .= Mebius::Admin::user_control_link_host($login{'host'}) . " - " ;
		$addata .= Mebius::Admin::user_control_link_user_agent($login{'agent'});
	}

$addata .= qq(</div>);

$addata;

}

1;

