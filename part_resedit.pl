
package main;
use strict;

#-----------------------------------------------------------
# 処理開始
#-----------------------------------------------------------
sub thread_resedit{

my($error) = @_;
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
my($set_name,$set_comment,$set_color,$set_trip,$error_text,$zero_flag,$pri_vw,%inputed,$edit_guide_line);
our(%in,$resedit_mode,$subtopic_mode,$css_text,$realmoto);

$main::not_repair_url_flag = 1;

#トリップ付与
main::trip($in{'name'});

# ID付与
main::id();

# アクセス制限
main::axscheck();

	# モード判定
	if(!$resedit_mode || $subtopic_mode){ &error("この掲示板ではレス修正できません。"); }

	# ログイン判定
	if(!$my_account->{'login_flag'}){ &error("ログインしてください。"); }

# 関数定義
my $i_nam = $in{'name'};
my $i_sub = $in{'sub'};
my $i_com = $in{'comment'};
my $i_res = $in{'res'};
my $res_number = $in{'res'};

# No.0 の場合
if($i_res eq "0"){ $zero_flag = 1; }

# CSS定義
$css_text .= qq(
.inline{display:inline;padding:0em;margin:0em;}
td.alert,td.alert2{font-size:90%;border-style:none;color:#f00;padding:0em 0em 0.5em 0em;}
td.alert2{font-size:130%;}
.green{color:#080;}
.ryaku{border-color:#0a0;padding:0.4em;}
textarea{background-color:#f3fff3;border:solid 1px #99b;}
.d_ryaku{padding:0.25em 1.5em 0.75em 1.5em;}
.ryaku{font-size:95%;padding:0.30em 0.6em;border:dashed 2px #f00;line-height:1.8em;}
);

# 汚染チェック
$in{'no'} =~ s/\D//g;
$in{'res'} =~ s/\D//g;
	if($in{'no'} eq ""){ &error("記事を指定してください。"); }
	if($in{'res'} eq ""){ &error("レスを指定してください。"); }

my($thread) = Mebius::BBS::thread({ ReturnRef => 1 , FileCheckError => 1 , GetAllLine => 1 },$realmoto,$in{'no'});
our($no,$sub) = split(/<>/, $thread->{'all_line'}->[0]);

my $edit_guide_line = qq(
<div class="d_ryaku"><span class="ryaku">
<a href="$in{'no'}.html" class="blank" target="_blank">”$thread->{'sub'}”</a> の <strong class="green">No.$in{'res'}</strong> を修正します。履歴は<a href="$basic_init->{'main_url'}vresedit-1.html" target="_blank" class="blank">一時公開</a>されます。</span>
</div>
);

# ヘッダ読み込み＆タイトル決め
our $sub_title = "レス修正 - $thread->{'sub'}";
our $head_link3 = qq(&gt; <a href="$in{'no'}.html">$thread->{'sub'}</a>);
our $head_link4 = qq(&gt; <a href="$in{'no'}.html-$in{'res'}#a">No.$in{'res'}</a>);
our $head_link5 = qq(&gt; 修正);

	# キー判定
	if($thread->{'keylevel'} < 1){ &error("この記事では修正できません。"); }

	# 修正・プレビューの場合
	if($in{'action'} && $ENV{'REQUEST_METHOD'} eq "POST"){

		edit_action($edit_guide_line);

	# 普通表示の場合
	} else {

		# 修正可能かどうかを判定
		my($deny_flag) = res_edit_deny_judge($in{'res'},$resedit_mode,$thread);
			if($deny_flag){ main::error("$deny_flag"); }


					my $nam = $thread->{'res_data'}->{$res_number}->{'handle'};
					my $id = $thread->{'res_data'}->{$res_number}->{'id'};
					my $color = $thread->{'res_data'}->{$res_number}->{'color'};

				$inputed{'name'} = $nam;
				$inputed{'color'} = $color;
				$inputed{'comment'} = $thread->{'res_data'}->{$res_number}->{'comment'};
				#$inputed{'trip'} = $trip;

				my($com) = bbs_thread_resedit_auto_link($thread->{'res_data'}->{$res_number}->{'comment'}, $in{'no'});

					if($thread->{'res_data'}->{$res_number}->{'trip'}){ $nam = "$nam☆$thread->{'res_data'}->{$res_number}->{'trip'}"; }
					if($thread->{'res_data'}->{$res_number}->{'account'}){ $nam = qq(<a href="$basic_init->{'auth_url'}$thread->{'res_data'}->{$res_number}->{'account'}/">$nam</a>); }

			$pri_vw .= qq(<div class="d" style="color:$color;" id="S${no}"><p class="name"><b>$nam</b> <i>★$id</i></p><p>$com</p><div class="date">$thread->{'res_data'}->{$res_number}->{'date'} No.$res_number</div></div>);

	}


# HTML
my $preview_line .= qq(<div class="thread_body bbs_border">$edit_guide_line);

$preview_line .= $pri_vw;
$preview_line .= qq(</div>\n);
my $print = $preview_line;

require "${init_directory}part_resform.pl";
my($res_form) = main::bbs_thread_form({ EditMode => 1 , inputed => \%inputed });
$print .= $res_form;

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



#-------------------------------------------------
# リンク処理
#-------------------------------------------------
sub bbs_thread_resedit_auto_link {

my($msg) = @_;
our(%in);

($msg) = Mebius::auto_link($msg);

$msg =~ s/No\.([0-9,-]+)/<a href=\"$in{'no'}.html-$1#NUM\">&gt;&gt;$1<\/a>/g;
#if($subtopic_link){ $msg =~ s/Sb\.([0-9,-]+)/<a href=\"\/_sub$moto\/$in{'no'}.html-$1#NUM\">&lt;&lt;$1<\/a>/g; }
#$msg =~ s/&gt;&gt;([0-9,-]+)/<a href=\"$in{'no'}.html-$1\">&gt;&gt;$1<\/a>/g;

$msg;

}


#-----------------------------------------------------------
# 修正実行
#-----------------------------------------------------------
sub edit_action{

# 局所化
my($edit_guide_line) = @_;
my($i,$nam,$com,$bkupline,$line,$put_trip,$trip,$flag,$THREAD);
my($init_directory) = Mebius::BaseInitDirectory();
my($now_date) = Mebius::now_date();
our(%in,$realmoto,$cnumber,$enctrip,$e_com,$resedit_mode,$i_com,$host);

	# GET送信を禁止
	main::axscheck("Post-only");

# IDとトリップを付与
my($encid) = main::id();
main::trip($in{'name'});

# 基本エラーチェック
base_error_check("Not-duplication-check");

my $res_number = $in{'res'};
	if($res_number eq "" || $res_number =~ /\D/){ main::error("修正するレス番を指定してください。"); }

# 記事を取得
my($thread) = Mebius::BBS::thread({ Flock1 => 1 , ReturnRef => 1 , GetAllLine => 1 , FileCheckError => 1 },$realmoto,$in{'no'});

# 修正可能かどうかを判定
my($deny_flag) = res_edit_deny_judge($in{'res'},$resedit_mode,$thread);
	if($deny_flag){ main::error("$deny_flag"); }

	# エラー・プレビューの場合リターン
	if($e_com || $in{'preview'}){
		my %inputed;
		require "${init_directory}part_resform.pl";
		my($error_line) = rerror_set_error($e_com);
		my($preview_line) = preview_area_resform();
		my($res_form) = main::bbs_thread_form({ Preview => 1 , EditMode => 1 , inputed => \%inputed });
		my $print = qq(<div class="thread_body bbs_border">);
		$print .= qq($edit_guide_line);
		$print .= qq(<div class="d">);
		$print .= qq($error_line);
		$print .= qq($preview_line</div>);
		$print .= qq(</div>);
		$print .= $res_form;
		Mebius::Template::gzip_and_print_all({},$print);
		exit;
	}

# 修正内容を定義して、レス修正を実行
my %res_edit;
$res_edit{$res_number}{'comment'} = $i_com;
$res_edit{$res_number}{'id'} = $encid;
$res_edit{$res_number}{'host'} = $host;
$res_edit{$res_number}{'color'} = $in{'color'};
$res_edit{$res_number}{'cookie_char'} = $cnumber;
	if($enctrip){ $res_edit{$res_number}{'trip'} = $enctrip; }
	if($in{'res'} ne "0"){ $res_edit{$res_number}{'cookie_char'} = $now_date; }
Mebius::BBS::thread({ Renew => 1 , res_edit => \%res_edit },$realmoto,$in{'no'});


# 戻り先
our $jump_url = "$in{'no'}.html#S$in{'res'}";

my $print = qq(修正しました。<a href="$jump_url">戻る</a>);

Mebius::Template::gzip_and_print_all({ RefreshURL => $jump_url , RefreshSecond => 1 },$print);

exit;


}


#-----------------------------------------------------------
# レス習性が可能かどうかを判定
#-----------------------------------------------------------
sub res_edit_deny_judge{

my $res_number = shift;
my $resedit_allow_time = shift;
my $thread = shift;

my($my_account) = Mebius::my_account();
my($error_flag);

# 連続修正制限（秒）
my $waitsec = 60*1.5;

	#if($res_number eq "0"){
	#	$error_flag = qq(最初の書き込みは修正できません。);
	#}

	if(!$thread->{'res_data'}->{$res_number}){
		$error_flag = qq(修正先のレスが存在しません。);
	}

	if(!$my_account->{'login_flag'}){
		$error_flag = qq(アカウントにログインしていません。);
	}

	if(time > $thread->{'res_data'}->{$res_number}->{'regist_time'} + ($resedit_allow_time+2)*60*60){
		$error_flag = qq(レスを修正できるのは${resedit_allow_time}時間以内です。);
	}

	#if(!Mebius::alocal_judge() && time < $thread->{'res_data'}->{$res_number}->{'regist_time'} + $waitsec){
	#	$error_flag = qq(前回の投稿後、あまりすぐには修正できません。);
		#（残り$leftsec秒）
	#}

	if($thread->{'res_data'}->{$res_number}->{'deleted'} ne "" && $thread->{'res_data'}->{$res_number}->{'deleted'} ne "<Re>"){
		$error_flag = qq(削除済みのレスです。);
	}

	if(!$thread->{'res_data'}->{$res_number}->{'account'}){
		$error_flag = qq(該当のレスにアカウントが設定されていません。);
	}

	if($thread->{'res_data'}->{$res_number}->{'account'} ne $my_account->{'id'}){
		$error_flag = qq(アカウントが一致しません。);
	}



$error_flag;

}


1;
