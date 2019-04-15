
use Mebius::History;
use Mebius::BBS::Crap;
use Mebius::BBS::Thread;
package main;
use Mebius::Export;

#-----------------------------------------------------------
# 記事のいいね！ - no strict;
#-----------------------------------------------------------
sub bbs_support{

our(%in);

	# 携帯フラグ
	if($mode eq "kview" || $in{'k'}){ $kflag = 1; }

# 設定
our $not_repair_url_flag = 1;

# コメント登録の最大/最小文字数
local $support_commment_max = 100;
local $support_commment_min = 3;

# キャンセルの制限時間
local $cancel_maxsec = 30;

# CSS定義
our $css_text .= qq(
table,th,tr,td{border-style:none;}
td,th{padding:0.1em 0em 0.1em 0.5em;}
.td_count{text-align:right;padding-right:1em;}
input.comment{width:20em;}
div.alert{padding:1em;border:solid 1px #f00;margin:1em 0em;}
);

	# 普通表示の場合、モードより記事ナンバーを取得
	if($in{'no'} eq "" && $ENV{'REQUEST_METHOD'} eq "GET"){ $in{'no'} = $submode2; }

# 汚染チェック
$in{'no'} =~ s/\D//g;

# 局所化
local($action);

# 元の記事を開く
my($thread) = Mebius::BBS::thread_state($in{'no'},$realmoto);
local $sub = $thread->{'sub'};
local $key = $thread->{'key'};
local $sexvio = $thread->{'sexvio'};

	# 元記事のキーでエラー処理
	#if($key ne "1" && $key ne "2" && $key ne "3" && $key ne "5"){ &error("元の記事が存在しないか、削除済み、またはロック中です。","","","Not-repair");}
	if($thread->{'keylevel'} < 0.5){ &error("元の記事が存在しないか、削除済み、またはロック中です。","","","Not-repair");}

# ファイル定義
local $counter_file = "$main::bbs{'data_directory'}_crap_count_${moto}/$in{'no'}_cnt.cgi";

# カウントファイルを開く
open(CNT_IN,"<",$counter_file);
my $support_top = <CNT_IN>; chomp $support_top;
my $support_top2 = <CNT_IN>; chomp $support_top2;
local ($count) = split (/<>/,$support_top);
close(CNT_IN);

	# カウント数がない場合、数値ゼロを代入
	if(!$count) { $count = "0"; }

# ヘッダリンクなどの定義
$sub_title = "”$sub”へのいいね！";
$head_link3 = qq(&gt; <a href="$in{'no'}.html">$sub</a>);
$head_link4 = qq(&gt; いいね！);

	# 投稿先の定義
	if($alocal_mode) { $action = $script; } else { $action = "./"; }

	# モード振り分け
	if($in{'type'} eq "comment"){
			if($thread->{'keylevel'} < 1){ &error("過去ログにはコメントできません。");}
		&support_comment();
	}
	#elsif($in{'type'} eq "cancel"){ &support_cancel(); }
	elsif($mode eq "view" || $mode eq "kview" || $mode eq "support"){
			if($main::in{'thread_check'}){ &thread_check_do("",$main::realmoto,$main::in{'no'},$i_handle); }
			else{ &support_do("",$main::realmoto,$main::in{'no'},$i_handle); }
	}
	else{ &error("ページが存在しません。( サポート１ )"); }

exit;

}

use strict;

#-----------------------------------------------------------
# 記事のいいね！を実行
#-----------------------------------------------------------
sub support_do{

# 局所化
my($type,$realmoto,$thread_number,$i_handle) = @_;
my($hitflag,@line,$count_handler,$topics_only_flag,$craped);
my($my_use_device) = Mebius::my_use_device();
my($my_connection) = Mebius::my_connection();
my($init_directory) = Mebius::BaseInitDirectory();
my $time = time;
our($concept,$enctrip);

	# 汚染チェック
	if($thread_number eq "" || $thread_number =~ /\D/){ main::error("記事の指定が変です。"); }
	if($realmoto eq "" || $realmoto =~ /\W/){ main::error("掲示板の指定が変です。"); }

	# エラー
	if($my_use_device->{'bot_flag'}){ main::error("この環境からはいいね！できません。"); }

	# 「最近のレス」への登録だけをおこなう場合
	#if($main::in{'thread_check'}){ $topics_only_flag = 1; }

# 二重 Cookie Set を禁止
#$no_headerset = 1;

# IDと管理番号をセット
our($encid) = &id();

# 元記事をゲット
my($thread) = Mebius::BBS::thread({ ReturnRef => 1 },$realmoto,$thread_number);

	# 掲示板が投稿停止モードの場合
	if(Mebius::Switch::stop_bbs()){ main::error("掲示板全体で、更新を停止中です。"); }

	# いいね！が禁止されている掲示板
	if($concept =~ /NOT-SUPPORT/){ main::error("この掲示板ではいいね！が出来ません。","","","Not-repair"); }

# アクセス制限
main::axscheck("Post-only");

	# 環境によってはエラー
	if($my_use_device->{'level'} < 2){ &error("この環境からはいいね！が出来ません。","","","Not-repair"); }

	# いいね！ファイルで、連続いいね！を制限
	#if(!$topics_only_flag){
	#	($double_flag) = &support_check_double("deny");
	#}

	# 連続いいね！を制限
	#if($double_flag && !$alocal_mode){ &error("同じ記事に連続していいね！は出来ません。","","","Not-repair"); }

# カウント増加
#$count += 1;

	# いいね！ファイルを更新
	if(!$topics_only_flag){

		my %select_renew;
		my $new_line = "<>$i_handle<>$encid<>$enctrip<><>$my_connection->{'account'}<>$my_connection->{'host'}<>$my_connection->{'cookie'}<>$my_connection->{'user_agent'}<>$time<><><><>$ENV{'REMOTE_ADDR'}<>\n";
		$select_renew{'+'}{'count'} = 1;
		($craped) = Mebius::BBS::crap_file({ NewCrap => 1 , Renew => 1 , select_renew => \%select_renew , new_line => $new_line },$realmoto,$thread_number);
			if($craped->{'done_flag'} && !Mebius::alocal_judge()){ main::error("この記事にはまだいいね！出来ません。","","","Not-repair"); }

	}

	# カテゴリ毎の新着いいね！を更新
	if(!$topics_only_flag){
		&category_newsupport("make");
	}

	# いいね！ランキング更新
	if(!$topics_only_flag){
		&rank_support();
	}

	# 投稿履歴ファイルを更新
	if(!$topics_only_flag){
		Mebius::HistoryAll("Renew My-file");
	}

# 投稿履歴に記録する内容
my $postdata_history = "$thread->{'subject'}<>$thread_number<><>$realmoto<>$main::head_title<>$main::server_domain<><><><><><><>";

# いいね！履歴を更新
require "${init_directory}part_history.pl";
main::get_reshistory("ACCOUNT RENEW Crap-file New-crap My-file",undef,undef,$postdata_history);
main::get_reshistory("CNUMBER RENEW Crap-file New-crap My-file",undef,undef,$postdata_history);
#main::get_reshistory("KACCESS_ONE RENEW Crap-file New-crap My-file",undef,undef,$postdata_history);

# 元記事を更新
my(%renew_thread);
$renew_thread{'s/g'}{'concept'} = $renew_thread{'.'}{'concept'} = qq( Crap-done);
#$renew_thread{'s/g'}{'concept'} = qq( Crap-not-done);
$renew_thread{'crap_count'} = $craped->{'count'};
Mebius::BBS::thread({ Renew => 1 , select_renew => \%renew_thread },$realmoto,$thread_number);

	# 権限がない場合、元記事にリダイレクトする ( Botのクロール対策? )
	if($my_use_device->{'level'} < 2){
		Mebius::Redirect("","$thread->{'url'}","301");
	}

	# コメントフォームを表示する
	#elsif($in{'type'} eq "form"){
	#	&support_page("support",$craped->{'count'});
	#}

	# すぐ元記事に戻る
	else{

		if($my_use_device->{'type'} eq "Mobile"){
			require "${init_directory}k_view.pl";
			bbs_view_thread_mobile({ CrapDone => 1 });
		}
		else{
			require "${init_directory}part_view.pl";
			bbs_view_thread_desktop({ CrapDone => 1 });
		}
	}

exit;

}


#-----------------------------------------------------------
# 記事のチェックを実行
#-----------------------------------------------------------
sub thread_check_do{

# 宣言
my($type,$realmoto,$thread_number) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # 処理タイプを展開
my($my_use_device) = Mebius::my_use_device();
my($init_directory) = Mebius::BaseInitDirectory();
my $bbs_thread = new Mebius::BBS::Thread;

	# 汚染チェック
	if($thread_number eq "" || $thread_number =~ /\D/){ main::error("記事の指定が変です。"); }
	if($realmoto eq "" || $realmoto =~ /\W/){ main::error("掲示板の指定が変です。"); }

	# エラーチェック
	if(!$ENV{'HTTP_COOKIE'} || $my_use_device->{'bot_flag'}){ main::error("この環境ではチェックできません。"); }

# アクセス制限
&axscheck("Post-only");

# 元記事をゲット
my($thread) = Mebius::BBS::thread({ ReturnRef => 1 },$realmoto,$thread_number);

# 投稿履歴に記録する内容
my $postdata_history = "$thread->{'subject'}<>$thread_number<><>$realmoto<>$main::head_title<>$main::server_domain<><><><><><><>";

# いいね！/チェック履歴を更新
require "${init_directory}part_history.pl";
main::get_reshistory("ACCOUNT RENEW Check-file New-check My-file",undef,undef,$postdata_history);
main::get_reshistory("CNUMBER RENEW Check-file New-check My-file",undef,undef,$postdata_history);
#main::get_reshistory("KACCESS_ONE RENEW Check-file New-check My-file",undef,undef,$postdata_history);

my $subject_utf8 = utf8_return($thread->{'subject'});
my %insert_for_history = ( bbs_kind => $realmoto , thread_number => $thread_number , subject => $subject_utf8 , last_response_num => $thread->{'res'} , last_response_target => $thread->{'res'} , create_content_time => $thread->{'posttime'} , last_modified => $thread->{'lastrestime'} );
#	if(Mebius::alocal_judge()){ Mebius::Debug::print_hash(\%insert_for_history); }

$bbs_thread->create_common_history(\%insert_for_history,{  },{ Check => 1 });

		if($main::kflag){
			require "${init_directory}k_view.pl";
			&bbs_view_thread_mobile("Thread-check-done");
		}
		else{
			require "${init_directory}part_view.pl";
			&bbs_view_thread_desktop({ ThreadCheckDone => 1 });
		}

exit;


}


#-----------------------------------------------------------
# チェック完了メッセージ
#-----------------------------------------------------------
sub thread_check_done_message{

# 宣言
my($type) = @_;

# CSS定義
$main::css_text .= qq(
div.thread_checked{background:#cef;padding:0.3em 1.5em;margin:1em 0em 1em 0em;font-size:90%;color:#333;}
);

my $message = qq(<div class="thread_checked"><p>記事をチェックしました！　更新があると「最近のレス」に表\示されます。<p> 削除する場合は<a href="/_main/?mode=my">マイページ</a>をご利用ください。</div>);

return($message);

}


#-----------------------------------------------------------
# いいね！した後のコメントフォーム
#-----------------------------------------------------------
sub thread_support_comment_form{

# 宣言
my($type) = @_;
my($line,$form);
our($sikibetu,%in,$realmoto,$cnam,$kflag,$css_text,$body_javascript,$xclose,$kborder_bottom_in,$script);

# BODY Javascript 定義
$body_javascript = qq( onload="document.support.comment.focus()");

$css_text .= qq(
div.supported{background:#fee;padding:0.3em 1.5em;margin:1em 0em 1em 0em;font-size:90%;color:#333;}
);

$line .= qq(<form action="$script" method="post" name="support" style="$kborder_bottom_in"$sikibetu>);
$line .= qq(<div class="supported">);


	# コメントを送った場合
	if($in{'type'} eq "comment"){ 
		$line .= qq(コメントを送りました！　);
		$line .= qq(( <a href="./$in{'no'}_data.html">記事データ</a> に掲載されました )<br$main::xclose>);

		}

	# いいね！をした場合
	else{
		$line .= qq(いいね！を送りました。　);
		#$line .= qq(よろしければ応援コメントをどうぞ。( <a href="./$in{'no'}_data.html" target="_blank" class="blank">記事データ</a> のページで公開されます )<br$main::xclose>);
		#$line .= qq(<input type="hidden" name="mode" value="support"$xclose>);
		#$line .= qq(<input type="hidden" name="moto" value="$realmoto"$xclose>);
		#$line .= qq(<input type="hidden" name="no" value="$in{'no'}"$xclose>);
		#	if($kflag){ $line .= qq(<input type="hidden" name="k" value="1"$xclose>); }
		#$line .= qq(<input type="hidden" name="type" value="comment"$xclose>);
		#$line .= qq(筆名： <input type="text" name="name" value="$cnam" class="name"$xclose>);
		#	if($kflag){ $line .= qq(<br$main::xclose>); }
		#$line .= qq( コメント： <input type="text" name="comment" value=""$xclose>);
		#$line .= qq(<input type="submit" value="送信"$xclose>);
	}

$line .= qq(</div>);

$line .= qq(</form>);

return($line);
}

no strict;

#-----------------------------------------------------------
# コメント処理を実行 - no strict - 
#-----------------------------------------------------------
sub support_comment{

# 宣言
my(@line,$myflag);
my($my_use_device) = Mebius::my_use_device();
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
our($host,%in);

# 連続コメントを禁止する時間
my $waithour = 24;

	# 投稿者判定
	if($my_use_device->{'level'} < 2){ &error("この環境ではコメントできません。","","","Not-repair"); }

# 連続いいね！コメントを制限
Mebius::Redun(undef,"Support-comment",60);

# アクセス制限
our($host) = main::axscheck("Postonly");

# IDを付与
&id();

# トリップを付与
my($enctrip,$i_handle) = main::trip($in{'name'});

# 各種エラー
require "${init_directory}regist_allcheck.pl";
($i_handle) = shift_jis(Mebius::Regist::name_check($i_handle));
main::length_check($in{'comment'},"コメント",$support_commment_max,$support_commment_min);
my($comment) = &all_check(undef,$in{'comment'});
main::error_view();

# ＵＡの記録
my $put_age = $age;
	if(!$k_access){ $put_age = ""; }

	#my($crap) = Mebius::BBS::crap_file({ Flock2 => 1 }, $realmoto,$in{'no'});
	my($crap) = Mebius::BBS::crap_file($realmoto,$in{'no'});

# 登録者かどうかを判定
my %select_renew;
$select_renew{'+'}{'res'} = 1;
my $new_resnum = $crap->{'res'} + 1;
my $new_line = "1<>$i_handle<>$encid<>$enctrip<>$comment<>$pmfile<>$host<>$cnumber<>$put_age<>$time<>$date<>$new_resnum<><>\n";
	my($craped) = Mebius::BBS::crap_file({ NewComment => 1 , Renew => 1 , new_line => $new_line , select_renew => \%select_renew },$realmoto,$in{'no'});
		if(!$craped->{'done_flag'}){ &error("いいね！した後でしかコメント登録は出来ません。","","","Not-repair"); }
		if($craped->{'comment_done_flag'}){ &error("連続していいね！コメントは送れません。"); }

	#($flag) = &support_check_double();
	#if(!$flag){ &error("いいね！した後でしかコメント登録は出来ません。","","","Not-repair"); }

# ロック開始
#&lock("$in{'no'}");

# カウントファイルを開く
#open(COUNT_IN,"<",$counter_file);
#flock(COUNT_IN,1);
#my $top1 = <COUNT_IN>; chomp $top1;
#my($count,$lasttime,$xips,$numbers,$res) = split(/<>/,$top1);
#$res++;

#my $top2 = <COUNT_IN>; chomp $top2;
#	while(<COUNT_IN>){
#		chomp;
#		my($key,$handle,$id,$trip,$comment,$account,$host2,$number,$age2,$lasttime,$date2,$res,$deleter) = split(/<>/);
#			if($lasttime + $waithour*60*60 > time){
#					if($account ne "" && $account eq $pmfile){ $myflag = 1; }
#					if($number ne "" && $number eq $cnumber){ $myflag = 1;}
#					if($k_access && $age2 && $age2 eq $age){ $myflag = 1; }
#					if(!$k_access && $host2 eq $host){ $myflag = 1; }
#			}
#		push(@line,"$key<>$handle<>$id<>$trip<>$comment<>$account<>$host2<>$number<>$age2<>$lasttime<>$date2<>$res<>$deleter<>\n");
#	}
#close(COUNT_IN);

# いいね！から時間が経ちすぎている場合
#my($count,$lasttime) = split(/<>/,$top1);
#if(time >= $lasttime + 1*24*60*60){ &error("前回のいいね！から時間が経ちすぎています。","","","Not-repair"); }

# 重複登録の場合
#if($myflag && !$alocal_mode){ &error("連続コメントは出来ません。","","","Not-repair"); }



# 追加する行
#unshift(@line,"1<>$i_handle<>$encid<>$enctrip<>$comment<>$pmfile<>$host<>$cnumber<>$put_age<>$time<>$date<>$res<><>\n");

# ＴＯＰデータを追加
#unshift(@line,"$top2\n");
#unshift(@line,"$count<>$lasttime<>$xips<>$numbers<>$res<>\n");

# カウントファイルを更新
#Mebius::Fileout(undef,$counter_file,@line);

# ロック解除
#&unlock("$in{'no'}");

# サイト全体の新着いいね！を更新
&all_newsupport($i_handle,$comment);

# リダイレクト
#Mebius::Redirect("","http://$server_domain/_$realmoto/$in{'no'}_data.html");
#Mebius::Redirect("","http://$server_domain/_$realmoto/$in{'no'}.html");

	# 元記事を表示
	if($kflag){
			require "${init_directory}k_view.pl";
			&bbs_view_thread_mobile();
	}
	else{
			require "${init_directory}part_view.pl";
			&bbs_view_thread_desktop();
	}


# ジャンプ先
$jump_url = "$in{'no'}_data.html";
$jump_sec = 0;


# HTML
my $print = qq(コメントしました。（<a href="$jump_url">→戻る</a>）);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



#-----------------------------------------------------------
# サイト全体の新着いいね！を更新
#-----------------------------------------------------------
sub all_newsupport{

# 局所化
my($line,$i,$key);
my($handle,$comment) = @_;
my($init_directory) = Mebius::BaseInitDirectory();
our($concept);

	# リターン
	if($secret_mode){ return; }

# 初期キー
$key = 1;

	# 非表示にする場合
	if($sexvio){ $key = 2; }
	if($sub =~ /(性|暴\|グロ|BL|GL|ＢＬ|ＧＬ)/){ $key = 2; }
	if($main::bbs{'concept'} =~ /Sousaku-mode/ && $sub =~ /(イジメ|いじめ|虐め|苛め|残酷)/){ $key = 2; }

# 追加する行
$line .= qq($key<>$moto<>$title<>$in{'no'}<>$sub<>$handle<>$comment<><>$time<>$date<>\n);

# ファイル読み込み
open(IN,"<","${init_directory}_sinnchaku/all_newsupport.cgi");
flock(IN,1);
	while(<IN>){
		$i++;
			if($i <= 500){ $line .= $_; }
	}
close(IN);

# ファイル更新
Mebius::Fileout(undef,"${init_directory}_sinnchaku/all_newsupport.cgi",$line);

}



#-----------------------------------------------------------
# カテゴリ毎の新着いいね！を更新
#-----------------------------------------------------------

sub category_newsupport{

# 局所化
my($line,$i,$key,$flag);
my($type,$select_time) = @_;
my($init_directory) = Mebius::BaseInitDirectory();

	# リターン
	if($secret_mode){ return; }

# 初期キー
$key = 1;

	# 非表示にする場合
	if($sexvio){ $key = 2; }
	if($sub =~ /(性|暴\|グロ|BL|GL|ＢＬ|ＧＬ)/){ $key = 2; }
	if($main::bbs{'concept'} =~ /Sousaku-mode/ && $sub =~ /(イジメ|いじめ|虐め|苛め|残酷)/){ $key = 2; }

	# 追加する行
	if($type eq "make"){
		$line .= qq($key<>$moto<>$title<>$in{'no'}<>$sub<>$handle<>$comment<><>$time<>$date<>\n);
	}

# ファイル読み込み
open(IN,"<","${init_directory}_sinnchaku/_category/${category}_newsupport.cgi");
flock(IN,1);

	while(<IN>){
		chomp;
		my($key,$moto2,$title2,$no2,$sub,$handle,$comment,$res,$lasttime,$date2) = split(/<>/);
		$i++;
			if($type eq "make" && ($no2 eq $in{'no'} && $moto2 eq $moto) ){ next; }
			if($type eq "cancel" && $select_time eq $lasttime){ $flag = 1; next; }
			if($i <= 10){ $line .= qq($key<>$moto2<>$title2<>$no2<>$sub<>$handle<>$comment<>$res<>$lasttime<>$date2<>\n); }
	}
close(IN);

# リターン
if($type eq "cancel" && !$flag){ return; }

# ファイル更新
Mebius::Fileout(undef,"${init_directory}_sinnchaku/_category/${category}_newsupport.cgi",$line);

}


#-----------------------------------------------------------
# いいね！数ランキングを更新
#-----------------------------------------------------------
sub rank_support{

my($init_directory) = Mebius::BaseInitDirectory();

	# リターン
	if($secret_mode){ return; }
	if($count < 25){ return; }

# 局所化
my($line,$i);
my($init_bbs) = Mebius::BBS::init_bbs_parmanent_auto();

	# 非表示にする場合
	if($sexvio){ $key = 2; }
	if($sub =~ /(性|暴\|グロ|BL|GL|ＢＬ|ＧＬ)/){ $key = 2; }
	if($init_bbs->{'concept'} =~ /Sousaku-mode/ && $sub =~ /(イジメ|いじめ|虐め|苛め|残酷)/){ $key = 2; }

# 追加する行
$line .= qq(1<>$count<>$moto<>$title<>$in{'no'}<>$sub<>\n);

# ロック開始
&lock("supportranking");

# ファイル読み込み
open(IN,"<","${init_directory}_sinnchaku/rank_support.cgi");
	while(<IN>){
	$i++;
	my($key2,$count2,$moto2,$title2,$no2,$sub2) = split(/<>/,$_);
		if($moto2 eq $moto && $no2 eq $in{'no'}){ next; }
		if($i <= 500){ $line .= $_; }
	}
close(IN);

# ファイル更新
Mebius::Fileout(undef,"${init_directory}_sinnchaku/rank_support.cgi",$line);

# ロック解除
&unlock("supportranking");

}




1;
