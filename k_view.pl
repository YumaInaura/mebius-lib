
use Mebius::Paint;
use Mebius::BBS;
use Mebius::Text;
package main;

#-----------------------------------------------------------
# 携帯版の記事閲覧
#-----------------------------------------------------------
sub bbs_view_thread_mobile{

# 局所化
local($no,$sub,$res,$key,$no2,$nam,$trip,$com,$dat,$ho,$id,$color,$pno);
local($job) = @_;
my($type) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # 処理タイプを展開
my($zero_line,$use_thread,$main_thread,$sub_thread);

# 携帯設定を取得
&kget_items();

# 設定
$k_maxlink = 2;


# 携帯フラグ
$kflag = 1;

# いいね！数を取得
#&thread_viewsupport_mobile();

# 汚染チェック
if($in{'no'} =~ /\D/){ &error("記事ナンバーの指定が変です。数字のみを指定してください。"); }
$in{'no'} =~ s/\D//g;

# マイページの戻り先
$mybackurl = "http://$server_domain/_$moto/$in{'no'}.html";

	# 記事データを読み込み （サブ記事）
	if($subtopic_mode){
		require "${int_dir}part_subview.pl";
		($main_thread,$sub_thread) = thread_sub_base();
		$use_thread = $sub_thread;

	# 記事データを読み込み (普通記事）
	} else {
		($main_thread) = Mebius::BBS::thread_state($in{'no'},$realmoto);
		$use_thread = $main_thread;
		chomp($top1 = $use_thread->{'all_line'}->[0]);
		chomp($top2 = $use_thread->{'all_line'}->[1]);
		($no,$sub,$res,$key,$res_pwd,$t_res,$d_delman,$d_password,$dd1,$sexvio,$dd3,$dd4,$dd5,$memo_body,$dd7,$lock_end_time,$juufuku_com,$dd10) = split(/<>/, $top1);
		#close(IN);
	}

	# いいね！数を取得
	if(!Mebius::BBS::sub_bbs_judge_auto()){
		my($count) = Mebius::BBS::get_crap_count($_[0],$use_thread);
		our $pri_count = "($count)";
	}


# スレッドキー
our $thread_key = $no;

# サブ記事データを読み込み
if($subtopic_link){ ($subkey,$subres,$sub_nofollow) = &thread_get_subdata_mobile(); }

# レス番を認識
($No_start,$No_end) = thread_check_resnumber($res);

# タイトル定義
&thread_set_title_mobile();

	# 性表現、暴力表現がある場合
	if($sexvio){ require "${int_dir}part_sexvio.pl"; &sexvio_check($sexvio); }

# 内容によって広告消去
require "${int_dir}part_adscheck.pl";
my($none,$none,$none,$none,$zero_com) = split(/<>/,$top2);
&adscheck($sub,$zero_com);
	Mebius::Fillter::fillter_and_error(utf8_return($sub));
if($key eq "7"){ $noads_mode = 1; require "${int_dir}part_thread_status.pl"; &thread_get_deletelock("LIGHT MOBILE",{ delete_data => $d_delman }); }
if($sub eq ""){ $noads_mode = 1; $sub = "消失ページ"; }

# 予約削除されている場合、時刻を過ぎると削除済みに
if( ($key eq "7" && $time >= $dd4) || $key eq "6"){ $key = 4; }

# 記事が無い場合、404を返す
if($key eq ""){ main::error("記事$in{'no'}は存在しません","404 NotFound"); }

# 記事名エリアを取得
my($sub_line) = &bbs_get_subline_mobile();

# 検索ワードの処理
local($badword_flag);
if($ch{'word'}){
require "${int_dir}part_tsearch.pl";
($badword_flag) = &tsearch_check_keyword($in{'word'});
}

# レス取得
my($res_line) = &thread_nres_mobile($use_thread);

# No.0を取得
if(!$subtopic_mode){ ($zero_line) = &thread_get_zero_mobile(); }

# ページへ分割リンクを取得
my($page_links_top) = &thread_get_pagelinks_mobile("Top",$in{'r'},$res,$kpage,$kfirst_page);
my($page_links_bottom) = &thread_get_pagelinks_mobile("Bottom",$in{'r'},$res,$kpage,$kfirst_page);

# 最後のレス
if($last_res eq ""){ $last_res = 0; }

# ゼロ記事への移動リンク
my $movezero = qq(<a href="#RES" id="TOP2">▽</a>);
if(!$ch{'No'} && !$ch{'word'}){ $movezero = qq(<a href="#S0" id="TOP2">▽</a>); }
#my $middle_link = qq(<a href="#RESFORM" accesskey="5">⑤返信</a>);

# ヘッダ

# 削除依頼モードの場合、フォームを追加
($res_line) = Mebius::Report::around_report_form($res_line,"bbs_thread_$use_thread->{'bbs_kind'}_$use_thread->{'number'}");


# 報告ボタン
my($move_to_report_mode_button) = Mebius::Report::move_to_report_mode_button({ url_hash => "#a" , ViewResReportButton => our $res }); # $use_thread->{'res'}
shift_jis($move_to_report_mode_button);

# HTML
my $print = qq(
$sub_line
$delete_link
$pv_view
$resnavi_links1
$zero_line
$cutlink
$page_links_top

$res_line

$resnavi_links2
$page_links_bottom
<hr>
$move_to_report_mode_button
);



# 投稿フォーム
	if(!Mebius::Report::report_mode_judge()){
		$print .= kform2();
	}

Mebius::Template::gzip_and_print_all({},$print);


exit;

}

#-----------------------------------------------------------
# 記事名エリアを取得
#-----------------------------------------------------------
sub bbs_get_subline_mobile{

# 局所化
my($line,$datalinks,$form);
my($my_access) = Mebius::my_access();
my($pageview);
our($concept);

# カテゴリ設定を取り込み
my($init_bbs) = Mebius::BBS::init_bbs_parmanent($moto);

# 削除済みの場合
if($key eq "4") { require "${int_dir}part_thread_status.pl"; &thread_get_deletelock("HEAVY MOBILE",{ delete_data => $d_delman }); }

# ページビューの呼び出し、カウント
	if(!Mebius::Switch::light() && !Mebius::Switch::thread_light()){
		require "${int_dir}part_pv.pl";
		my($pageview) = &do_pv({ TypeRenew => 1 ,TypeAddRanking => 1 },$in{'no'},$moto);
	}

# ピン止め記事
if($key eq "2") { $line .= qq(ピン止め記事<hr$xclose>\n); }

# 親記事を表示 携帯

	# Ｎｏ区切りある場合、記事名を元の記事へリンク
	if($in{'No'} ne "" || $in{'r'} ne "" || $in{'word'} ne ""){
		$sub = qq(<a href="$in{'no'}.html" style="font-size:medium;">$sub</a>);
	}
	else{
		$sub = qq(<span style="font-size:medium;">$sub</span>);
	}


# 記事タイトル
$form = qq(
<form action="$script#FORM" id="FORM" style="text-align:center;margin:0.5em 0em;">
<div style="font-size:x-small;">
<input type="hidden" name="mode" value="kview"$xclose>
<input type="hidden" name="no" value="$in{'no'}"$xclose>
<input type="text" name="word" value="$in{'word'}" size="10"$xclose>
<input type="submit" value="検索"$xclose>
</div>
</form>
);



	if($in{'No'} eq "" && $concept !~ /NOT-SUPPORT/){
			if($my_access->{'level'} >= 2 && 1 == 0) {
				$datalinks .= qq( <a href="./?mode=support&amp;no=$in{'no'}&amp;k=1"$sikibetu>いいね！$pri_count</a>);
			} else { 
				$datalinks .= " いいね！$pri_count";
			}
	}

	if($my_access->{'level'} >= 2) {
		$datalinks .= qq( <a href="./?mode=cermail&amp;no=$in{'no'}">配信</a>);
	}

	if($key ne "0"){ $datalinks .= qq( <a href="$in{'no'}_data.html">データ</a>);  }

	# 削除依頼リンク
	my($delete_link);
	if($secret_mode){ $datalinks .= qq( <a href="scmail.html">管理者</a>); }
	#else{
	#	my $bbs_url = new Mebius::BBS::URL;
	#	$datalinks .= qq( <a href=").e($bbs_url->report_thread($init_bbs)).qq(" target="_blank" class="blank">削除依頼</a>);
	#}

	my($pc_link,$s0);
		if($device_type eq "both"){
			$datalinks .= qq( <a href="$in{'no'}.html">PC版</a>);
		}

# ＰＶ
if(defined($pageview)){ $datalinks .= qq( ｱｸｾｽ${pageview}); }

$line .= qq();

my($support_comment_form) = &thread_support_comment_form() if($mode eq "support");

# 記事内検索終わり
$line .= qq(
$sexvio_text
<div style="background:#dee;border-bottom:solid 1px #000;">

$sub

<span style="font-size:x-small;">$datalinks</span>
</div>
$support_comment_form
$form
);


return($line);

}

#-----------------------------------------------------------
# ゼロ記事を取得
#-----------------------------------------------------------
sub thread_get_zero_mobile{

# 局所化
my($line,$moves);
local($no,$ranum,$nam,$trip,$com,$dat,$ho,$id,$color,$agent,$user,$deleted,$account,$image_data,$res_concept,$regist_time2) = split(/<>/,$top2);
local($round,$mround,$last_flag,$tsearch_hit,$rescut_flag);

	# アカウント非表示の場合
	if($res_concept =~ /Hide-account/){ $account = undef; }

	my($comment_deleted_flag) = Mebius::BBS::comment_deleted_judge($res_concept,$deleted);

	# 筆名が削除されている場合
	if($res_concept =~ /Deleted-handle/ || $comment_deleted_flag){ $nam = qq(削除済み); $trip = undef; }

# リターン
if($ch{'No'} || $ch{'word'}){ return; }


$line .= qq($ktext_up);

# フォーマット
($line) .= &thread_getres_mobile("ZERO",$use_thread);

# サブ記事の場合
if($subtopic_mode){ ($line) = &thread_get_ksubzero(); }

	# ●携帯向け Adsense
	if(!Mebius::Report::report_mode_judge()){

		my($kadsense,$kadsense2) = &kadsense("VIEW");

			if($kadsense){
				$line .= qq(<hr$xclose>$kadsense);
			}

			if($kadsense2){
				$main::kfooter_ads = qq($kadsense2);
			}
	}

# 記事メモを取得
if(!$subtopic_mode){ ($line) .= &thread_get_memo_mobile(); }


return($line);

}


#-----------------------------------------------------------
# レス書き出し
#-----------------------------------------------------------
sub thread_nres_mobile{

# 局所化
my($use_thread) = @_;
local($round,$mround,$last_flag,$tsearch_hit,$rescut_flag);
my($line,$reads_hit_flag,$file);
my @thread_data = @{$use_thread->{'all_line'}};

	# 省略幅の設定
	#if($ccut ne "0" && $ccut){
	#	$k_maxgyou *= $ccut;
	#	$kmax_length *= $ccut;
	#}


# レス開始 / 終了位置を定義
$res_start = $res - $kfirst_page + 1;
$res_end = $res;
	if($in{'No'} ne ""){ ($res_start,$res_end) = ($No_start,$No_end); }
	elsif($in{'r'} ne ""){
		$res_start = $in{'r'};
		$res_end = $in{'r'} + $kpage - 1;
			if($in{'r'} >= $res - $kfirst_page - $kpage){ $res_end = $res - (($kfirst_page + 1 - 1)  % $kpage) + 1 - 1; }
	}
	elsif($in{'word'} ne ""){
		($res_start) = "";
	}

# レスを省略するかしないか
if($ch{'No'}){ $rescut_flag = 0; }

# レス開始前の部分
$line .= qq($deleted_text);
$line .= qq(<a id="RES"></a>);

	# 検索語が悪い場合
	if($badword_flag){ $line .= qq(検索できませんでした。全角１文字以上のキーワードを使ってください。); return($line); }

# レス番指定の場合、各種リンクを取得
($line) .= &resnumber_link("1",$No_start,$No_end);

	# レスを展開
	if($res_flag ne "0"){

		shift @thread_data ;
			if(!$ch{'No'} && !$ch{'word'}){ shift @thread_data; }

			foreach(@thread_data) { 

				# この行を分解
				chomp;
				local($no,$ranum,$nam,$trip,$com,$dat,$ho,$id,$color,$agent,$user,$deleted,$account,$image_data,$res_concept,$regist_time2) = split(/<>/);

				# アカウント非表示の場合
				if($res_concept =~ /Hide-account/){ $account = undef; }

				my($comment_deleted_flag) = Mebius::BBS::comment_deleted_judge($res_concept,$deleted);

				# 筆名が削除されている場合
				if($res_concept =~ /Deleted-handle/ || $comment_deleted_flag){ $nam = qq(削除済み); $trip = undef; }

				my($name_hit,$id_hit);

				# 次の処理へ進む
				if($no < $res_start && ($no != 0 || $ch{'No'})){ next; }
				if($no >= $res_end){ $last_flag = 1; }
				if($res_comma){
					my($flag);
						foreach (split(/,/, $in{'No'})) { if($no eq $_) { $flag = 1; } }
						if(!$flag){ next; }
				}
				if($ch{'word'}){
					my($hit);
					my($search) = &bbs_tsearch($in{'word'},"mobile/high-light","$nam☆$trip",$com,$id,$account);
					($hit,$name_hit,$id_hit) = ($search->{'hit'},$search->{'$name_hit'},$search->{'id_hit'});
						if($search->{'high_lighted_comment'}){ $com = $search->{'high_lighted_comment'}; }
					$tsearch_hit += $hit;
						if($tsearch_hit >= 30){ $res_end = $no; $last_flag = 1; }
						if(!$hit){ next; }
				}

				# 完全削除されている場合
				if($res_concept =~ /Vanished/){	}
				# 普通に書き出す場合
				else{
					($line) .= &thread_getres_mobile("",$use_thread);
				}

				$reshit_flag = 1;
				if($deleted eq ""){ $adshit_flag = 1; }

				if($last_flag){ $last_res = $no; last; }


			}

	}

# レス番指定の場合、各種リンクを取得
($line) .= &resnumber_link("2",$No_start,$No_end);

# 表示内容がない場合
if(!$reshit_flag && ($ch{'No'} || $ch{'r'}) ){ &error("表\示する内容がありません。","404 NotFound"); }

	# 広告を表示する場合
	if($adshit_flag && ($ch{'No'} || $ch{'word'}) ){
		my($kadsense,$kadsense2) = &kadsense("VIEW");
			if($kadsense){
				$line .= qq(<hr$xclose>$kadsense);
			}
			if($kadsense2){
				$main::kfooter_ads = qq($kadsense2);
			}
	}

# 検索でヒットしなかった場合
if($in{'word'} ne "" && !$reshit_flag){ $line .= qq(ヒットしませんでした。キーワードを変えて検索してください。); }


return($line);

}

#-----------------------------------------------------------
# レスのフォーマット
#-----------------------------------------------------------
sub thread_getres_mobile{

# 局所化
my($type,$use_thread) = @_;
my($line,$up_mk,$dw_mk,$up_move,$dw_move,$viewname,$view_no,$edit,$aname);
my($admin,$comview,$cut_round,$cut_round_bridge,$length,$cutflag,$cutlength);
my($plustype_kauto_link,$omit_flag,$omitlink,$image_view,$view_id,$account_link,$view_trip,$report_check_box);
my($basic_init) = Mebius::basic_init();	
my $fillter = new Mebius::Fillter;
our($resone,%ch,$cfillter_id,$cfillter_account);

	# 簡易フィルタ
	if($cfillter_id || $cfillter_account){
		use Mebius::BBS;
		my($filled_flag_id) = Mebius::BBS::Fillter_id("",$cfillter_id,$id);
		my($filled_flag_account) = Mebius::BBS::Fillter_account("",$cfillter_account,$account);
		if($filled_flag_id || $filled_flag_account){ next; }
	}


# 自動リンクのタイプ定義
if($ch{'No'}){ $plustype_kauto_link .= qq( Resone); }
if($main::bbs{'concept'} =~ /Sousaku-mode/){ $plustype_kauto_link .= qq( Loose); }
if($rescut_flag eq "0" || $main::ccut eq "0"){ $plustype_kauto_link .= qq(); }
else{ $plustype_kauto_link .= qq( Omit); }

# 自動リンク
($com,$omit_flag,$omitlink) = &kauto_link("Thread $plustype_kauto_link",$com,$main::in{'no'},$no);

# ▽△ 移動リンクを定義
$round++;
$up_move = $no + 1;
$dw_move = $no - 1;
$aname .= qq(<a id="S$no"></a><a id="D$no"></a>);
if($type =~ /ZERO/){ $aname = ""; }

	# 上下移動リンク（普通）
	if($in{'No'} eq "" && !$ch{'word'} && $type !~ /ZERO/){
		$mround++;
		$aname = "";
			if($last_flag) { $dw_mk = qq(<a href="#DBMENU" id="S$no">▽</a>); }
			else { $dw_mk = qq(<a href="#S$up_move" id="S$no">▽</a>); }
			if($mround == 1){ $up_mk = qq(<a href="#D0" id="D$no">△</a>); }
			else { $up_mk = qq(<a href="#D$dw_move" id="D$no">△</a>); }
	}

	# ゼロ番記事の移動リンク
	if($type =~ /ZERO/){
		my $moves = $in{'r'};
			if($moves eq ""){ $moves = $res - $kfirst_page + 1; }
			if($res <= $kfirst_page){ $moves = 1; } 
			if($res >= $moves){
				$dw_mk = qq(<a href="#S$moves" id="S0">▽</a>);
				$up_mk = qq(<a href="#TOP2" id="D0">△</a>);
			}
			else{
				$dw_mk = qq(<a href="#DBMENU" id="S0">▽</a>);
				$up_mk = qq(<a href="#TOP2" id="D0">△</a>);
			}
	}


	if($res_one && $no == $res_start){ $resone_cutflag = $cutflag; }
	if($res_one){ $cutflag = 0; }

	# 表示調整
	if($id){ $view_id = "★$id"; }
	if($id_hit){ $view_id = qq(<span style="background:#fc0;">$view_id</span>); }
	elsif($agent eq "<A>"){ $view_id = qq(<span style="color:#f00;">$view_id</span>); }

	# ID履歴リンク
	if($id && $res_concept =~ /Idory5/ && $res_concept !~ /Deleted-(comment|handle)/){
		my($devce_encid,$pure_encid,$option_encid) = Mebius::SplitEncid(undef,$id);
		my($id_encoded) = Mebius::Encode("Escape-slash",$pure_encid);
		$view_id = qq(<a href="${main::main_url}history-id-$id_encoded.html">$view_id</a>\n);
	}

	# 削除リンク
	if($candel_mode && $user eq $username && $deleted eq ""){
		$edit = qq( <a href="$script?mode=resdelete&amp;no=$in{'no'}&amp;type=delete&amp;res=$no&amp;k=1" style="font-size:small;">削除</a> );
	}

	# 筆名リンク
	#if($trip){ $viewname = "$nam☆$trip"; }
	#else{ $viewname = "$nam"; }

	{ $viewname = "$nam"; }

	# トリップ履歴リンク
	if($trip && $res_concept =~ /Tripory/ && $res_concept !~ /Deleted-(comment|handle)/){
		my($trip_encoded) = Mebius::Encode("Escape-slash",$trip);
		my($trip_style) = qq( style="background:#fc0;") if($name_hit);
		$view_trip = qq( <a href="${main::main_url}history-trip-$trip_encoded.html"$trip_style>☆$trip</a>\n);
	}
	# 名前がヒットした場合
	elsif($name_hit){ $viewname = qq(<span style="background:#fc0;">$viewname</span>); }

	# アカウントリンク
	if($account){

		$viewname = qq( <a href=") . esc("${auth_url}$account/") . qq(">$viewname</a> );

			if(Mebius::BBS::view_account_history_judge($res_concept)){
				$account_link .= qq( <a href=") . esc("$basic_init->{'main_url'}history-account-$account.html") . qq("$ac_style>\@$account</a> );
			} else {
				$account_link .= qq( \@${account});
			}

	}


# 日付調整
#my($year,$other_dates) = split(/\//,$dat,2);
#if($year eq $thisyear){ $dat = $other_dates; }

	# レス番表記を調整
	if($ch{'word'} || $res_comma || $res_between || $omit_flag eq "2"){
		$view_no = qq(<a href="$in{'no'}.html-$no#RES">#$no</a>);
	}
	else{ $view_no = qq(#$no); }

	# 省略リンク
	if($omitlink){
		$omitlink = qq($omitlink );
	}

	# 画像表示を定義
	if($image_data){
		my(%image) = Mebius::Paint::Image("Get-hash Justy",undef,undef,$server_domain,$realmoto,$in{'no'},$no);
			if($image{'image_ok'}){
				$image_view .= qq(<div>);
				if($image{'tail'} eq "png" && $main::device{'id'} eq "DOCOMO"){ $image_view .= qq( <a href="$image{'samnale_url'}">); }
				else{ $image_view .= qq( <a href="$image{'image_url'}">); }
				$image_view .= qq(画像);
				$image_view .= qq(</a>);
				$image_view .= qq(</div>);
			}
	}


	# ▼削除依頼のチェックボックス
	if(Mebius::Report::report_mode_judge_for_res()){
		($report_check_box) = shift_jis(Mebius::Report::report_check_box_per_res({ handle_deleted_flag => $res_concept{'Deleted-handle'} , comment_deleted_flag => $comment_deleted_flag },"bbs_thread_$use_thread->{'bbs_kind'}_$use_thread->{'number'}_$no"));
	}

	if( my $message = $fillter->each_comment_fillter_on_shift_jis($com)){
		$com = $message;
	}

	if( my $message = $fillter->each_comment_fillter_on_shift_jis($nam)){
		$viewname = $message	;
	}

# 実際の書き出し
$line .= qq(<div style="text-align:center;background:#ddf;border-top:solid 1px #000;">$aname$dw_mk $view_no $up_mk</div>);
$line .= qq(<div style="margin:6px 0px;">$viewname$account_link</div>);
$line .= qq(<div style="color:$color;">$com</div>);
$line .= qq(<div style="text-align:right;">$view_trip$view_id</div>);
$line .= qq(<div style="text-align:right;">$omitlink$image_view$tripory_link$edit$dat</div>);
	if($report_check_box && !$secret_mode){ $line .= qq(<div style="text-align:right;">$report_check_box</div>); }

#background:#def;

my($seal) = shift_jis_return(Mebius::BBS::Posted::last_regist_seal($use_thread->{'bbs_kind'},$use_thread->{'number'},$no));
$line .= $seal;

return($line);

}

use strict;

#-----------------------------------------------------------
# ページ分割リンク
#-----------------------------------------------------------
sub thread_get_pagelinks_mobile{

# 宣言
my($type,$inpage,$thread_resnum,$split_page,$first_page) = @_;
my($pagemove_links,$nowpage,$move,$prev_pagenum,$next_pagenum,$ryaku_cnt_mae,$after_rpage,$newpage_num);
my($nextpage_link,$prevpage_link,$newpage_link,$allpage_num,$nowrealpage_num,$moveid);
my($brandnewpage_link,$through_brandnewpage_flag,$through_firstpage_flag);
my($near_brandnewpage_flag,$near_firstpage_flag);
our(%in,$last_res);

# 現在のリターン
if($in{'No'} ne ""|| $in{'word'} ne ""){ return; }
if($thread_resnum <= $first_page && $type =~ /Top/){ return; }

	# リンク移動のためのIDを定義
	if($type =~ /Top/){ $moveid = qq(<a id="PAGES"></a>); }

	# 移動リンク
	elsif($type =~ /Bottom/){
		$moveid = qq(<a href="#RESFORM" id="SBMENU">▽</a><a href="#D$last_res" id="DBMENU">△</a> );
	}

# 移動リンク先
$move = qq(#PAGES);

# 最新ページのページ数を計算
#$newpage_num = $res - $first_page + 1

	# この記事の全てのページ数を計算
	# レス数が $first_page を越えていない場合、無条件にページ数は１に
	if($thread_resnum <= $first_page){ $allpage_num = 1; }
	# 最新ページ分をのぞいた全てのレス数（２ページ目の最後のレス番）をページ分割値で割り、それに最新１ページ分を足す)
	#$allpage_num = int(($thread_resnum-$first_page+$split_page) / $split_page);
	else{ $allpage_num = int(($thread_resnum-$first_page-1) / $split_page) + 1 + 1; }

	# 現在アクセスしているページ数を計算
	if($inpage){ $nowrealpage_num = int($inpage / $split_page) + 1; }
	else{ $nowrealpage_num = $allpage_num; }

# ▼前のページ、次のページ

# 現在の実質ページ位置を定義
$nowpage = $inpage;
	if(!$inpage) { $nowpage = $thread_resnum - $split_page + 1 + $first_page; }

	# レス数に応じて移動リンクを表示する
	if($thread_resnum > $first_page){

		# ひとつ前のページ数を計算
		$prev_pagenum = $nowpage - ($nowpage % $split_page) + 1;
			if($inpage){ $prev_pagenum -= $split_page; }
			if($inpage eq ""){
				my $firstres = ($thread_resnum - $first_page + 1);
				my $before_lastres = $firstres - 1;
				$prev_pagenum = ($before_lastres-1) - (($before_lastres-1) % $split_page) + 1;
			}

		# ひとつ後のページ数を計算
		if($inpage + $split_page > $thread_resnum - $first_page){ $next_pagenum = qq(); }	# 次のページが最新ページの場合
		else{ $next_pagenum = qq(_) . ($inpage + $split_page); }							# 普通は、現在のページ値＋１ページ分を指定

	# 省略されているレス数を計算
	$ryaku_cnt_mae = $nowpage - 1;

		# 前のページ ( より新しいページ ) へのリンク
		if(!$inpage){ $nextpage_link .= qq(④新\n); }
		else{ $nextpage_link = qq( <a href="$main::in{'no'}${next_pagenum}.html$move" accesskey="4"$main::utn2>④新</a>\n); }

		# 次のページ ( より古いページ ) へのリンク
		if($nowpage <= 1){ $prevpage_link = qq(⑥旧); }
		else{ $prevpage_link = qq( <a href="$main::in{'no'}_${prev_pagenum}.html$move" accesskey="6"$main::utn2>⑥旧</a>\n); }

	}

# ▼ページ切り替えリンク

# 局所化
my($page,$round,$second,$linkpage,$flag,$i,$count,$page_links);
my($pagemove_link,$cutlink);
my($maxlink_round) = (7);	# リンクの最大数

# 横につけるリンク数を計算
my($link_balaety) = int($maxlink_round/2);

# ラウンド回指数を定義
$round = $nowrealpage_num+$link_balaety;
	# ラウンド数が少なすぎる場合は、最低ページ数を代入
	if($round < $maxlink_round){ $round = $maxlink_round; }
	# すべてのページ数をより大きい値では始めない（新しい方のページで、存在しないページ数を表示しない）
	if($round > $allpage_num){ $round = $allpage_num; }

	if($round > 1000){
		die("Perl Die! Too many page rounds '$round'");
	}

	# ラウンドがなくなるまで繰り返し
	while($round > 0){

			# 最新ページのリンクを表示したかどうかを記憶
			if($round == $allpage_num){ $through_brandnewpage_flag = 1;  }
			if($round == $allpage_num - 1){ $near_brandnewpage_flag = 1;  }

			# １ページ目のリンクを表示したかどうかを記憶
			if($round == 1){ $through_firstpage_flag = 1; }
			if($round == 1 + 1){ $near_firstpage_flag = 1; }

			# リンクするページの内容値を定義
			if($round == $allpage_num){ }
			else{ $linkpage = qq(_) . ( ( ( $round * $split_page ) - $split_page ) + 1); }

			# リンク行を定義
			if($round == $nowrealpage_num){ $page_links .=  qq($round\n); }
			else{ $page_links .=  qq(<a href="$in{'no'}$linkpage.html$move"$main::utn2>$round</a>\n); }

		$count++;	# カウント数は増えていく
		$round--;	# ラウンド数は減っていく

			# 表示最大数を越えたら終了
			if($count >= $maxlink_round){ last; }

	}

	# 最新ページへのリンクがなければ追加
	if(!$through_brandnewpage_flag){
		$brandnewpage_link .=  qq(<a href="$in{'no'}.html$move"$main::utn2>$allpage_num</a>\n);
			if(!$near_brandnewpage_flag){ $brandnewpage_link .=  qq(.. ); }
	}

	# １ページ目へのリンクがなければ追加
	if(!$through_firstpage_flag){
		if(!$near_firstpage_flag){ $page_links .=  qq(.. ); }
		$page_links .=  qq(<a href="$in{'no'}_1.html$move"$main::utn2>1</a>\n);
	}



# リンク整形
$pagemove_links = qq(<hr$main::xclose><div style="font-size:x-small;">$moveid$nextpage_link$brandnewpage_link$page_links$cutlink$prevpage_link</div>);

# リターン
return($pagemove_links);

}

no strict;


#-----------------------------------------------------------
# レス番指定の場合、リンク表示
#-----------------------------------------------------------
sub resnumber_link{

# 局所化
my($round,$No_start,$No_end,$round_start) = @_;
my($line,$next,$before,$r_page,$start,$formar_move,$accesskey4,$accesskey5,$accesskey6);

# リターン
if(!$ch{'No'}){ return; }

# アクセスキー
if($round == 1){
$accesskey4 = qq( accesskey="4");
$accesskey6 = qq( accesskey="6");
}

$before = $No_start - 1;
$next =  $No_end + 1;

# 元ページへのリンク
if($round == 1){ $round_start = $No_start; }
if($round == 2){ $round_start = $No_end + 1; }
$r_page = qq(_) . ( ($round_start-1) - ( ($round_start-1) % $kpage) + 1);
if($round_start >= $res - $kfirst_page + 1){ $r_page = undef; }
if($round_start eq "0"){ $r_page = undef; }

# 元ページの移動リンク
$formar_move = qq(#S$round_start);
if($No_end >= $res && $round == 2){ $formar_move = qq(#C); }
if($round_start eq "0"){ $formar_move = qq(#S0); }

# 整形
#if($round == 2){ $line .= qq(<hr$xclose>); }

	# 下（新）
	if(!$main::bot_access){
			if($No_end >= $res){ $line .= qq( <a href="#RESFORM"$accesskey4>④↓</a>); }
			else{ $line .= qq( <a href="$in{'no'}.html-$next#RES"$accesskey4>④↓</a>); }
	}

	# 元
	if($round == 1){ $line .= qq( <a href="$in{'no'}$r_page.html$formar_move">⑤元</a>); }
	elsif($round == 2){ $line .= qq( <a href="$in{'no'}$r_page.html$formar_move">⑤元-次</a>); }

	# 上（古）
	if(!$main::bot_access){
			if($No_start <= 0){ $line .= qq( ⑥↑); }
			else{ $line .= qq( <a href="$in{'no'}.html-$before#RES"$accesskey6>⑥↑</a>); }
	}

# 新
$line .= qq( <a href="$in{'no'}.html#RES">最新</a>);

# 整形
#if($round == 1){ $line .= qq(<hr$xclose>); }

# 戻り先を定義
our $kback_url = "$in{'no'}$r_page.html$formar_move";

$line = qq(<div style="font-size:small;">$line</div>);

# 戻り先グローバル変数を設定
our $kback_url_tell = qq($in{'no'}$r_page.html$formar_move);

return($line);

}


#-----------------------------------------------------------
# いいね！ファイルを開く
#-----------------------------------------------------------
#sub thread_viewsupport_mobile{

#my($count);

# いいね！ファイルを開く
#open(SUPPORT_IN,"<","$main::bbs{'data_directory'}_crap_count_${moto}/$in{'no'}_cnt.cgi");
#my $cnt_top = <SUPPORT_IN>;
#($count) = split(/<>/,$cnt_top);
#$support_top2 = <SUPPORT_IN>;
#close(SUPPORT_IN);
#if($count){ $pri_count = "($count)"; }

#}



#-----------------------------------------------------------
# 記事メモを取得
#-----------------------------------------------------------
sub thread_get_memo_mobile{

# 局所化
my($line,$i,$return_line);
our($kborder_top_in);

# 記事メモを表示しない場合
if($key eq "3" || $in{'No'} ne ""){}

	# 記事メモを表示する場合
	elsif($memo_body ne ""){

			foreach(split(/<br>/,$memo_body)){

				# 改行を詰める
				if($_ eq ""){ next; }

					# コメントアウトでなければ、メモ本文として追加
					unless($_ =~ /^\/\//){
						($_) = &kauto_link("Memo",$_,$main::in{'no'});
						$line .= "$_<br$xclose>";
						$i++;
					}

				# ～行以上は省略
				if($i > 3){ $line .= qq(（<a href="$script?mode=kview&amp;no=$in{'no'}&amp;r=memo&amp;type=oview" rel="nofollow">…以下略</a>）); last; }
			}

			# 最終編集者のＩＤ，トリップをつける
			if($dd5){ ($dd5_name,$dd5_id,$dd5_eml2) = split(/=/,$dd5); }
			if($dd5_eml2){$dd5_trip = "☆$dd5_eml2";}

			# 整形
			if($in{'r'} ne ""){ $line = ""; }
			$return_line .= qq(<div style="text-align:center;background:#ddf;$kborder_top_in">);
			$return_line .= qq(<a href="$in{'no'}_memo.html" rel="nofollow">メモ</a></div>);
			$return_line .= qq(最終： $dd5_name$dd5_trip★$dd5_id<br$xclose>$line);

	}

	# 記事メモがない場合
	else{
		$return_line .= qq(<div style="text-align:center;background:#ddf;$kborder_top_in">);
		$return_line .= qq(<a href="$in{'no'}_memo.html" rel="nofollow">メモ</a></div>まだありません。);
	}

	# 最後の整形
	if($line){ $return_line = qq(<div style="$kfontsize_xsmall_in">$return_line</div>); }

return($return_line);


}

#-----------------------------------------------------------
# レス番判定
#-----------------------------------------------------------
#sub thread_check_resnumber_mobile{

# 局所化
#my($hit,$No_start,$No_end);
#my($res) = @_;

# No.0 の表示フラグ

	# ページ数判定
#	if($in{'r'} eq "all"){ }
#	elsif($in{'r'} ne "" && ($in{'r'} =~ /([^0-9])/ || $in{'r'} <= 0 || $in{'r'} > $res) ){ &error("ページ数の指定が変です。"); }
#	if($ch{'word'}){ $hit++; }
#	if($ch{'No'}){ $hit++; }
#	if($ch{'r'}){ $hit++; }
#	if($hit >= 2){ &error("モードは一つまでしか選べません。","404 NotFound"); }

	# レス番判定
#	if($in{'No'} eq ""){ return; }

	# 各種エラー
#	if($in{'No'} !~ /\d/){ &error("レス番の指定が変です。半角数字 ( 0-9 ) を必ず入れてください。 "); }
#	if($in{'No'} =~ /[^0-9\-,]/){ &error("レス番の指定が変です。半角数字 ( 0-9 ) 、 半角カンマ ( , ) 、 半角ハイフン ( - ) だけで指定してください。 "); }
#	if($in{'No'} =~ /\-/ && $in{'No'} =~ /\,/){ &error("レス番の指定が変です。半角カンマ ( , ) と 半角ハイフン ( - ) は一緒に使えません。"); }
#	if(($in{'No'} =~ s/\-/$&/g) >= 2){ &error("レス番の指定が変です。半角ハイフン ( - ) は１つだけしか使えません。"); }

	# ライン指定
#	if($in{'No'} =~ /-/) {
#		($No_start,$No_end) = split(/-/, $in{'No'}, 2);
#		if($No_start eq "" || $No_end eq ""){ &error("レス番はハイフンで区切って正しく入力してください。"); }
#		if($No_start > $No_end){ ($No_start,$No_end) = ($No_end,$No_start); }
#		if($No_end - $No_start > $p_page){ $No_end = $No_start + $p_page -1; }
#		$res_between = 1;
#	}

	# カンマ指定
#	elsif($in{'No'} =~ /,/){
#		$res_comma = 1;
#		$No_start = $res;
#		foreach ( split(/,/, $in{'No'}) ) {
#		if($_ < $No_start){ $No_start = $_; }
#		if($_ > $No_end){ $No_end = $_; }
#		}
#	}

	# 単一指定
#	elsif($in{'No'} ne ""){
#		$No_start = $No_end = $in{'No'};
#		$res_one = 1;
#	}

	# レス指定が大きすぎる場合
#	if($No_end > $res){ $No_end = $res; }

	# ０は最初に書けない
#	if($No_start =~ /^0([0-9+])/ || $No_end =~ /^0([0-9+])/){ &error("レス番の指定が変です。最初に 0 は書けません。"); }

#return($No_start,$No_end);

#}

#-----------------------------------------------------------
# タイトル定義
#-----------------------------------------------------------
sub thread_set_title_mobile{

# 宣言
our($realmoto);
my($server_domain) = Mebius::server_domain();

# タイトル定義
$sub_title = $sub;

	# ページ数
	if($in{'r'} ne ""){
		my $page = int($in{'r'} / $kpage) + 1;
		$sub_title= "$page頁 | $sub";
		my $pc_page = ($in{'r'} - 1) - ( ($in{'r'} - 1) % $p_page ) + 1;
		if($in{'r'} >= $res - $pfirst_page+1){ $divide_url = "http://$server_domain/_$realmoto/$in{'no'}.html"; }
		else{ $divide_url = "http://$server_domain/_$realmoto/$in{'no'}_${pc_page}.html"; }
	}

	# レス番表示
	elsif($in{'No'} ne ""){
		$sub_title= "$in{'No'} | $sub";
		$divide_url = "http://$server_domain/_$realmoto/$in{'no'}.html-$in{'No'}";
	}

	# 記事内検索
	elsif($ch{'word'}){
		$sub_title= "”$in{'word'}” - $sub";
		my($encword) = Mebius::Encode("",$in{'word'});
		$divide_url = "http://$server_domain/_$realmoto/?mode=view&no=$in{'no'}&word=$encword";
		$divide_url =~ s/mode=kview/mode=view/;
	}
	# 恒久的リダイレクト
	else{
		# タイトル定義
		$sub_title = $sub;
		$divide_url = "http://$server_domain/_$realmoto/$in{'no'}.html";
	}

	# リダイレクトで振り分け
	#if($device_type eq "desktop" && $divide_url){ &divide("$divide_url","desktop"); }

}

use strict;

#-----------------------------------------------------------
# メイン記事で「サブ記事データ」を取得
#-----------------------------------------------------------
sub thread_get_subdata_mobile{

my($line,$sub_nofollow);
our($moto,%in);

my($thread) = Mebius::BBS::thread_state($in{'no'},"sub${moto}");
my($subres,$subkey) = ($thread->{'res'},$thread->{'key'});



	if($subres <= 0){ $sub_nofollow = qq( rel="nofollow"); }

return($subkey,$subres,$sub_nofollow);

}

no strict;

#-------------------------------------------------
# フォームへ
#-------------------------------------------------
sub kform2 { require "${int_dir}k_form2.pl"; &bbs_thread_form_mobile(); }


1;
