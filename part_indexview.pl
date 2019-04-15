
use strict;
use Mebius::BBS;
use Mebius::BBS::Index;
package Mebius::BBS;

use strict;

#-----------------------------------------------------------
# サブインデックスを取得
#-----------------------------------------------------------
sub sub_index_state{

my $target_bbs = shift;

# Near State （呼び出し） 2.30
my $HereName1 = "sub_index_hash_state";
my $StateKey1 = "normal";
my($state) = Mebius::State::Call(__PACKAGE__,$HereName1,$StateKey1);
	if(defined $state){ return($state); }
	#else{ Mebius::State::ElseCount(__PACKAGE__,$HereName1,$StateKey1); }

my($self) = Mebius::BBS::index_file({ SubIndex => 1 },$target_bbs);

	# Near State （保存） 2.30
	if($HereName1){ Mebius::State::Save(__PACKAGE__,$HereName1,$StateKey1,$self); }

$self;

}

package main;
use Mebius::Export;

#-----------------------------------------------------------
# アクセス振り分け
#-----------------------------------------------------------
sub bbs_view_indexview{

my($my_use_device) = Mebius::my_use_device();
my($param) = Mebius::query_single_param();

	if(exists $param->{'single_reason_report_mode'} || exists $param->{'report'}){
		my $bbs_url = Mebius::BBS::bbs_url($param->{'moto'});
		Mebius::redirect($bbs_url);
	}

	# アクセス振り分け
	if($my_use_device->{'type'} eq "Mobile" && our $submode1 ne "all"){	# $submode1 => 暫定処置
		my($init_directory) = Mebius::BaseInitDirectory();
		require "${init_directory}k_indexview.pl";
		&bbs_view_indexview_mobile(@_);
	}
	else{
		&bbs_view_indexview_desktop(@_);
	}

}

#-----------------------------------------------------------
# PC版インデックスを表示 - strict
#-----------------------------------------------------------
sub bbs_view_indexview_desktop{

# 宣言
my($type,$sub_title,$index_line,$mode_line,$plusform_line,$logtype,$input_logtype,$threadnum,$plus_title);
my($top,$menu_line,$logmenu_line,$history_line,$category_news_line,$guide1,$guide2,$i,$page,$p,$print,$bbstop_flag,$second_title);
my($newnum,$newres_time,$newpost_time,$th_res,$th_last,$thblock_poster,$ranking_directory_flag,$search_option_line);
my($search_option_line2,$hit_index,$BCL,$table);
my($my_use_device) = Mebius::my_use_device();
my $time = time;
my $query = new Mebius::Query;
my($init_directory) = Mebius::BaseInitDirectory();
my $bbs_object = Mebius::BBS->new();
my %bbs = our %bbs;
my $bbs = hash_to_utf8(\%bbs);
my($param) = Mebius::query_single_param();
my $param_utf8 = Mebius::Query->single_param_utf8();

# グローバル変数
our(%in,%tag,$moto,$mode,$submode1,$submode2,$submode3,$subtopic_mode,$subtopic_link,$secret_mode,$freepost_mode,$category_mode,$css_text,$category);
our($nowfile,$device_type,$followed_flag,$cookie,$home,$body_javascript);
our($guide_url,$base_url,$jak_url,$script,$server_domain,$new_wait,$rule_text);
our($scad_name,$concept,$kflag,%ch);

# カテゴリ設定を取得
my($init_category) = Mebius::BBS::init_category_parmanent($main::category);
$init_category = hash_to_utf8($init_category);

# ページ数_
$page = $in{'p'};
	if($mode eq "oldpast"){ ($page,$logtype) = split(/-/,$page); }

# CSS定義
#push(@main::css_files,"bbs_all");

	# スマフォ版
	if($my_use_device->{'smart_flag'}){
		$main::css_text .= qq(.page{font-size:120%;}\n);
		$main::css_text .= qq(.body1{width:100%;}\n);
		$main::css_text .= qq(.index_links{font-size:110%;word-spacing:0em;}\n);
		$main::css_text .= qq(.ads_index{margin:0.5em auto 0.0em auto;padding:0.75em 0em 0.5em 0em;text-align:center;}\n);
		$main::css_text .= qq(.page{margin:0em;padding:0.5em 0.2em 0em 0.2em;});

	}


	# モード振り分け
	if($in{'type'} eq "form_follow"){ require "${init_directory}part_follow.pl"; &form_follow("bbs"); }
	elsif($in{'type'} eq "follow"){ require "${init_directory}part_follow.pl"; &do_follow("bbs"); }
	elsif($main::ch{'word'} && $main::in{'allsearch'}){
		my($encword) = Mebius::Encode("","$in{'word'}");
		Mebius::Redirect("","${main::main_url}?mode=allsearch-p-1&word=$encword");
	}

	# 掲示板データを別ファイルに記録
	#if(rand (250) < 1){ require "${init_directory}part_autoinit.cgi"; &push_autoinit($moto); }

	# モードエラー
	if($mode && $mode ne "find" && $mode ne "oldpast" && ($submode1 ne "all") ){
		&error("このモード ( $mode ) は存在しません。","","","Repair");
	}

	# ページ０、サブ記事専用の場合、リダイレクト
	if($subtopic_mode){ Mebius::Redirect("","http://$server_domain/_$moto/",301); }
	if(($page eq "0" && $mode eq "") || $ch{'regist'}){ Mebius::Redirect("","http://$server_domain/_$moto/",301); }
	if($page eq "") { $page = 0; }

	# タイトル定義
	($sub_title,$bbstop_flag,$second_title,$BCL) = &index_set_title("",$page,$logtype);
	if($mode eq "oldpast"){ $plus_title = qq( ( 過去ログ$logtype )); }
	#if($main::bbs{'concept'} =~ /Souko-mode/){ $plus_title .= qq( - 倉庫); }


# カテゴリ毎の新着レスを取得
#if(rand(2) < 1){ ($line_news) = &get_news("support"); }
	if(!$main::ch{'word'}){
		($category_news_line) = &index_get_news("res",%$init_category) if(ref $init_category eq "HASH");
	}

# インデックスのトップデータを開く
my($index) = Mebius::BBS::index_file({ Flock1 => 1 },$moto);
($newnum,$newres_time,$newpost_time) = split(/<>/,$index->{'all_line'}->[0]);
our $hit_index_num = $index->{'hit_index'};

	# インデックスが消えていたら自動復元
	if($newnum eq ""){
		Mebius::return_backup($nowfile);
	}

	# モードに応じてインデックスを取得
	if($mode eq "find"){ ($index_line,$mode_line,$search_option_line2) = index_findmenu_set("Desktop-view",150); }
	elsif($mode eq "oldpast"){ ($index_line,$mode_line,$plusform_line,$hit_index) = index_pastmenu_set($page,$logtype); }
	elsif($submode1 eq "all" && $submode2 eq "deleted"){ ($index_line) = index_deletedmenu_set(); }
	elsif($submode1 eq "all" && $submode2 eq "maxres"){ ($index_line) = index_maxresmenu_set(); }
	elsif($submode1 eq "all" && $submode2 eq "pvall"){ ($index_line) = index_pvallmenu_set(); }
	elsif($submode1 eq "all") { ($index_line) = index_allmenu_set($index); }
	else{ ($index_line) = index_nowmenu_set($index,$nowfile,$newnum,$newres_time,$newpost_time); }

# HTMLを開始
($guide1) = qq(<a href="rule.html">…ルール</a>);
#($guide2) = qq(<a href="${guide_url}IP%A5%A2%A5%C9%A5%EC%A5%B9" class="red">…IPの保存について</a>);
	if($secret_mode){
		utf8($scad_name);
		($guide1) = qq(<a href="member.html">…メンバーリスト</a>);
		($guide2) = qq(<a href="scmail.html" class="red">…管理者 ( $scad_name ) にメール</a>);
	}


	# 過去ログの検索
	if($logtype){ $input_logtype = qq(<input type="hidden" name="log" value="1">); }

# HTML
$print .= qq(<div class="bbs_navigation">\n);

if($bbstop_flag){ $print .= qq(<h1 class="bbs_title inline">$bbs->{'title'}$plus_title</h1>\n); }
else{ $print .= qq(<h1 class="bbs_title inline"><a href="./">$bbs->{'title'}</a>$plus_title</h1>\n); }

$print .= qq(<br><div class="setumei">$bbs->{'setumei'} $guide1 $guide2</div>
<form action="./" name="find" class="nomargin"><div>
<input type="hidden" name="mode" value="find">);

$print .= $query->input_hidden_encode();
$print .= qq(<input type="search" name="word" size="13" class="find_bar" value=").e($param_utf8->{'word'}).qq(" placeholder="検索キーワード">
$input_logtype
<input type="submit" value="スレッド検索">
);

	# 検索オプション
	if(exists $param->{'word'}){
		$print .= qq(<div class="size90 search_option">\n);
		$print .= qq($search_option_line2);
		$print .= qq(</div>\n);
	}


# メニュー部分
$print .= qq(
$plusform_line
$mode_line
</div></form>);


$print .= qq(<div class="index_links">);


	# スマフォ版
	if($my_use_device->{'smart_flag'}){
		$print .= qq( <a href="$home" accesskey="0">ＴＯＰ</a>);
	}
	# デスクトップ版
	else{
		$print .= qq( <a href="$home" accesskey="0">ＴＯＰページ</a>);
	}

	# スマフォ版
	#if($my_use_device->{'smart_flag'}){
	#}
	# デスクトップ版
	#else{
	#	$print .= qq( <a href="$guide_url" class="red">総合ガイド(必読)</a>);
	#}

	# リンク集
	if($my_use_device->{'smart_flag'}){
	}
	# デスクトップ版
	else{
		$print .= qq( <a href="${base_url}pmlink/link2.html">リンク集</a>\n);
	}

	# 携帯版
	#if($device_type eq "both"){ $print .= qq( <a href="./">携帯版</a> ); }

	# マイページ
	#if($cookie && !$my_use_device->{'smart_flag'}){ $print .= qq(<a href="/_main/?mode=my">マイページ</a>\n); }

	# ランキング
	if($main::bbs{'concept'} !~ /Not-handle-ranking/){ $ranking_directory_flag = 1; }
	if($ranking_directory_flag){
		my($link_title);
			# スマフォ版
			if($my_use_device->{'smart_flag'}){
				$link_title = qq(ランク);	
			}
			else{
				$link_title = qq(ランキング);
			}
		$print .= qq( <a href="ranking.html">$link_title</a>\n);
	}

	# フォロー
	if($my_use_device->{'narrow_flag'}){ $print .= qq( <a href="$script?type=form_follow">フォロー</a> ); }
	elsif($followed_flag){ $print .= qq( <a href="$script?type=form_follow">フォロー解除</a> ); }
	elsif($cookie){ $print .= qq( <a href="$script?type=form_follow">フォロー開始</a> ); }

	# 新規投稿リンクを定義
	if ($concept !~ /NOT-POST/){
		my($mark);
			if($newnum < $new_wait){ $mark = qq(<span class="red">(優遇中)</span> ); }
			if($freepost_mode){ $mark = qq(<span class="red">(待ち時間なし)</span> ); }
			# スマフォ版
			if($my_use_device->{'smart_flag'}){
				$print .= qq(<a href="form.html"$tag{'sikibetu'}>新規</a>$mark);
			}
			# デスクトップ版
			else{
				$print .= qq(<a href="form.html"$tag{'sikibetu'}>新規投稿</a>$mark);
			}
			# ローカル
			if(Mebius::alocal_judge()){
				$print .= qq( <a href="./?mode=form&amp;newform_check=2&amp;newcheck_p1=1&amp;newcheck_p2=1&amp;newcheck_p3=1&amp;newcheck_p4=1">*</a>);
			}
	}

	# ガジェット
	if(!Mebius::BBS::secret_judge()){
		my $gaget = new Mebius::Gaget;
		$print .= qq( ) . $gaget->tweet_button();

		$print .= qq( <a href="$script?mode=feed"><img src="/pct/rss2.gif" alt="RSS1.0" class="rss"></a>);

	}

# 整形
$print .= qq(</div>);
$print .= qq(</div>);

	# 新着レスニュース
	if($category_news_line){
		if(!$my_use_device->{'smart_flag'}){
			$print .= qq(<div class="category_news">$category_news_line</div>);
		}
	}

# ナビゲーションメニューを取得
if($hit_index){ $threadnum = $hit_index; }
if(!$threadnum){ $threadnum = $newnum; }
#if(!$threadnum){ $threadnum = our $hit_index; }

($menu_line,$logmenu_line,$history_line) = &index_menu_set($threadnum,$page,$logtype);

	if(!$main::ch{'word'} && !$my_use_device->{'smart_flag'}){
		$print .= qq(<div class="page bbs_border" id="M">$menu_line$history_line</div>);
	}
	else{
		$print .= qq(<div id="M"></div>);
	}

	# ルールリンクを表示
	if($mode eq "" || $secret_mode || $concept =~ /Mode-login/){
		my($rule_link);
		my $bnum = $newnum + 1;

			# スマフォ以外
			if(!$my_use_device->{'smart_flag'}){

				$table .= qq(<tr>);
				$table .= qq(<td><a href="$script?mode=tmove&amp;no=$bnum">新</a></td>);
				$table .= qq(<td>);
				$table .= qq(<div class="float-left">);
				$table .= qq(<a href="rule.html" class="rule_link">$bbs->{'title'}のルール</a> <span class="red">《 必読 》</span>);
					#if($newnum >= 1){ $table .= qq( / <a href="$script?mode=tmove&amp;no=$bnum">最新記事</a>); }
				if($ranking_directory_flag){ $table .= qq( / <a href="./ranking-news.html">参加者</a>); }
				$table .= qq(</div>);


					# 秘密板
					if($secret_mode || $concept =~ /Mode-login/){
						$table .= qq(<div>);
						$table .= qq( / <a href="member.html" class="red">メンバーリスト</a> );
						$table .= qq( / <a href="$script?mode=member&amp;type=vedit" class="red">メンバー設定</a> );
						$table .= qq( / <a href="./?mode=logoff" class="red">ログオフ</a>);
						$table .= qq(</div>);
					}

				$table .= qq(<td colspan="3">);

					# 参照先の掲示板がある場合 ( 詩人掲示板など ) 最新のレスを表示
					if($init_category->{'refer_bbs'}){
						my(%nowfile) = Mebius::BBS::NowFile("Get-hash",$init_category->{'refer_bbs'});
						my(%thread) = Mebius::BBS::thread({},$init_category->{'refer_bbs'},$nowfile{'last_resed_postnumber'});
							if($thread{'keylevel'} >= 1){
								$table .= qq( <div class="refer_bbs bgkcolor bdbcolor size80 center"> 交流： );
								$table .= qq( <a href="/_$init_category->{'refer_bbs'}/$nowfile{'last_resed_postnumber'}.html">$thread{'subject'}</a>);
								$table .= qq( ( <a href="/_$init_category->{'refer_bbs'}/$nowfile{'last_resed_postnumber'}.html#S$thread{'res'}">$thread{'lasthandle'}</a> ));
								$table .= qq(　( <a href="/_$init_category->{'refer_bbs'}/" class="green">$nowfile{'title'}</a> ));
								$table .= qq(</div>);
							}
					}

				$table .= qq(</td></tr>\n);

			}

	}


$print .= Mebius::BBS::Index->round_menu($table,$index_line,{ no_ads_flag => our $noads_mode });

# 下段ナビゲーションリンク
$print .= qq(<div class="page bbs_border">$menu_line$logmenu_line</div>);

	# 新着レスニュース
	if($category_news_line){
		if($my_use_device->{'smart_flag'}){
			$print .= qq(<div class="category_news">$category_news_line</div>);
		}
	}

# HTMLを出力
my $bbs_top_flag = 1 	if(ref $BCL eq "ARRAY" && @$BCL <= 0);
$bbs_object->print_html_all($print,{ Title => $sub_title , bbs_top_flag => $bbs_top_flag , BCL => $BCL , source => "utf8" });

# 終了
exit;

}

#-----------------------------------------------------
# メニューリスト - strict
#-----------------------------------------------------
sub index_menu_set{

# 宣言
my($threadnum,$page,$logtype) = @_;
my($history_line,$line1,$line2,$linknum,$linkpage,$page_period,$allpagenum,$logtypelink);
my $html = new Mebius::HTML;
my($param) = Mebius::query_single_param();
our($mode,$submode1,$submode2,$menu1,$menu2,$past_num,$pn,$p,$i_max,%in,$realmoto,$pastfile,$concept);

# 投稿履歴を取得
($history_line) = utf8_return(index_get_rireki());

# ページ区切り値を定義
if($mode eq "oldpast"){ $page_period = $menu2; } else { $page_period = $menu1; }
if($mode ne "oldpast" && $threadnum > $i_max){ $threadnum = $i_max; }
if($logtype){ $logtypelink = "-$logtype"; }

# 整形
$line1 .= qq(<strong class="size3">ページ：</strong> );
$line1 .= qq(<span class="page_move_links">);

	# ページ繰り越しリスト
	if($mode eq "oldpast"){
			if($page ne "0"){ $line1 .= qq(<a href="./p0$logtypelink.html#M">1</a>\n); }
			else{ $line1 .= qq(<strong class="red">1</strong>\n); }
	}
	else{
			if($page ne "0" || $mode ne ""){ $line1 .= qq(<a href="./#M">1</a>\n); }
			else{ $line1 .= qq(<strong class="red">1</strong>\n); }
	}

#$allpagenum = $threadnum / $page_period;	# 全スレッド個数を計算
$allpagenum = our $hit_index_num / $page_period;	# 全スレッド個数を計算
$linknum = 2;	# 処理を始めるページ数

	# ページ数羅列リンク
	while ($linknum < $allpagenum + 1){
		$linkpage = ($linknum - 1) * $page_period;	# リンク先の値を定義
			if($page == $linkpage) { $line1 .= qq(<strong class="red">$linknum</strong>\n); }
			elsif($mode eq "oldpast") { $line1 .= qq(<a href="p$linkpage$logtypelink.html#M">$linknum</a>\n); }	# 過去ログの場合
			else{ $line1 .= qq(<a href="m$linkpage.html#M">$linknum</a>\n); }									# 現行ログの場合
		$linknum++;
	}

	# 「全て表示」のリンク
	if($param->{'mode'} eq "all-res"){
		$line1 .= $html->span("全て表示",{ class => "size90" });
	} else {
		$line1 .= $html->href("all-res.html#M","全て表示",{ class => "size90" });
	}

$line1 .= qq(</span>);


	if($mode ne "oldpast"){
		$line1 .= qq(<span class="size3 spacing">　<strong>並べ替え：</strong> );


			if($submode2 eq "res"){ $line1 .= qq(<strong class="red">更新</strong> ); }
			else{ $line1 .= qq(<a href="all-res.html#M">更新</a> ); }

			if($submode2 eq "new"){ $line1 .= qq(<strong class="red">新規</strong> ); }
			else{ $line1 .= qq(<a href="all-new.html#M">新規</a> ); }

			#if(-f "${init_directory}_maxres/${realmoto}_maxres.log"){
					if($submode2 eq "maxres"){ $line1 .= qq(<strong class="red">最大</strong> ); }
					else{ $line1 .= qq( <a href="all-maxres.html#M">最大</a> ); }
			#}

			# PVリンク
			if($concept !~ /NOT-PV/ && !$main::secret_mode){ 
					if($submode2 eq "pvall"){ $line1 .= qq(<strong class="red">PV</strong> ); }
					else{ $line1 .= qq( <a href="all-pvall.html#M">PV</a> ); }
			}

			if($submode1 eq "all"){
					if($submode2 eq "title"){ $line1 .= qq(<strong class="red">題名</strong> ); }
					else{ $line1 .= qq(<a href="all-title.html#M">題名</a> ); }
			}

			if($submode1 eq "all"){
					if($submode2 eq "rescnt"){ $line1 .= qq(<strong class="red">レス数</strong> ); }
					else{ $line1 .= qq(<a href="all-rescnt.html#M">レス数</a> ); }
			}


			if($submode2 eq "deleted"){ $line1 .= qq(<strong class="red">削除済</strong> ); }



		$line1 .= qq(</span>);
	}

# メニュー上部　１
$line2 .= qq(<hr><span class="size3"><strong>ログ：</strong>);


if($mode eq ""){ $line2 .= qq(<strong class="red">現行</strong>\n); }
else{ $line2 .= qq(<a href="./">現行</a>\n); }


	# 新過去ログ
	#if(-f $main::newpastfile){
		$line2 .= qq(<a href="past.html">過去ログ</a>\n);
	#}

	# 旧過去ログ
	#if(-f $pastfile){
			#if($mode eq "oldpast" && $logtype eq ""){ $line2 .= qq(<strong class="red">旧過去ログ</strong>\n); }
			#else{ $line2 .= qq(<a href="p0.html">旧過去ログ</a>\n); }
	#}

	# 旧大過去ログへのリンク
	#if($past_num){
	#	$pn = $past_num;
	#		while($pn > 0){
	#				if($logtype == $pn){ $line2 .= qq(<strong class="red">過去$pn</strong>\n); }
	#				else{ $line2 .= qq(<a href="p0-${pn}.html">過去$pn</a>\n); }
	#			$pn--;
	#		}
	#}

$line2 .= qq(</span>);


return($line1,$line2,$history_line);

}

#-----------------------------------------------------
# 現行ログ - strict
#-----------------------------------------------------
sub index_nowmenu_set{

# 宣言
my($index,$file,$newnum,$newres_time,$newpost_time) = @_;
my($line,$i,$top);
my @index_line = @{$index->{'all_line_on_hash'}} if(ref $index->{'all_line_on_hash'} eq "ARRAY");

our(%in,$menu1,$p,$nowfile);

	foreach(@index_line){
		$i++;

		next if ($i < $in{'p'} + 1);
		last if ($i > $in{'p'} + $menu1);

		my $utf8_data = hash_to_utf8($_);

		# 書き出し
		($line) .= indexline_set("INDEX",$utf8_data,$i);
	}

#}

#close(INDEX_IN);

return($line);

}


#-----------------------------------------------------------
# 過去ログ - strict
#-----------------------------------------------------------
sub index_pastmenu_set{

# 宣言
my($page,$logtype) = @_;
my($line,$i,$file);
our($pastfile,$moto,$menu2);

# インデックスを展開
my $open = open(INDEX_IN,"<","$main::bbs{'data_directory'}_index_${moto}/${moto}_pst${logtype}.log");

if(!$open && $logtype ne ""){ &error("過去ログ${logtype}は存在しません。"); }

	while (<INDEX_IN>) {
		$i++;
		next if ($i < $page + 1);
		next if ($i > $page + $menu2);
		my $utf8_data = utf8_return($_);
		($line) .= indexline_set("PAST",$utf8_data,$i);
	}
close(INDEX_IN);

return($line,"","",$i);

}

#-----------------------------------------------------------
# 記事検索 - strict
#-----------------------------------------------------------
sub index_findmenu_set{

# 宣言
my($basic_init) = Mebius::basic_init();
my($type,$find_max) = @_;
my($line,$linebuf,$hit,$mode_line,$top,$pn,$value_log,$plusform_line,$nowfile_checked,$pastfile_checked);
my($plustype_find,$all_checked,$i,$default_checked);
my($my_use_device) = Mebius::my_use_device();
my $param_utf8 = Mebius::Query->single_param_utf8();
our(%in,$moto,$server_domain,$head_title,$nowfile,$pastfile,$past_num,$checked);

# CSS定義
$main::css_text .= qq(
div.google_link{margin:1.3em 0em 0.5em 0em;font-size:90%;text-align:center;}
div.search_option{width:40em;margin:0.75em auto auto auto;padding:0.2em;text-align:center;background:#eee;}
);

# キーワード定義
#my $keyword_enced = Mebius::Encode("",$main::in{'word'});

	# 検索タイプを定義
	if($main::in{'strict'}){
		$plustype_find .= qq( Strict-search);
	}
	if($main::in{'subject'}){
		$plustype_find .= qq( Subject-search);
	}
	if($main::in{'handle'}){
		$plustype_find .= qq( Handle-search);
	}

	# 現行インデックスを開く場合
	if($in{'log'} eq "0" || $in{'log'} eq  "" || $in{'log'} eq "all"){
		my($line_buffer,$hit_buffer,$i_buffer) = Mebius::BBS::IndexFind("Now-file $plustype_find",$param_utf8->{'word'},$hit,$i,$find_max);
			if($line_buffer){
				$line .= $line_buffer;
				$hit += $hit_buffer;
			}
		$i += $i_buffer;
	}

	# 普通の過去ログを開く
	if($in{'log'} eq "1" || $in{'log'} eq  "" || $in{'log'} eq "all"){
		my($line_buffer,$hit_buffer,$i_buffer) = Mebius::BBS::IndexFind("Past-file $plustype_find",$param_utf8->{'word'},0,$i,$find_max);
			if($line_buffer){
				$hit += $hit_buffer;
				$line .= $line_buffer;
			}
		$i += $i_buffer;
	}

	# 昔の過去ログを指定して開く
	#if($in{'log'} =~ /^next([0-9]+)$/){
	#	my($line_buffer,$hit_buffer,$i_buffer) = Mebius::BBS::IndexFind("Past-file-$1 $plustype_find",$in{'word'},$hit,$i,$find_max);
	#	$line .= $line_buffer;
	#	$hit += $hit_buffer;
	#	$i += $i_buffer;
	#}

	# 昔の過去ログを一斉に開く
	if($hit < $find_max && $in{'log'} eq "all"){
			for(1 .. $main::bbs{'past_num'}){
					if($hit < $find_max){
						my($line_buffer,$hit_buffer) = Mebius::BBS::IndexFind("Past-file-$_ $plustype_find",$param_utf8->{'word'},0,$i,$find_max);
						$line .= $line_buffer;
						$hit += $hit_buffer;
					}
			}
	}

	# 検索結果表示
	if(!$hit){ $hit = 0; }

$mode_line .= qq(<div class="google_link">);


	if($type =~ /Desktop-view/){
		$mode_line .= qq(<a href="./">$head_title</a> を ”).e($param_utf8->{'word'}).qq(” で検索しました。( $hit 件 ) );
	}

	# 検索対象ボックス
	if($in{'log'} eq ""){ $default_checked = $checked; }
	elsif($in{'log'} eq "all"){ $all_checked = $checked; }
	elsif($in{'log'} eq "0" ){ $nowfile_checked = $checked; }
	elsif($in{'log'} eq "1"){ $pastfile_checked = $checked; }

	# 旧過去ログが存在する場合、検索対象を指定できるようにする
	if($main::bbs{'past_num'}){

		# 題目
		$mode_line .= qq(　対象：);

		# 過去ログ
		$mode_line .= qq(<input type="radio" name="log" value="" id="find_mixmenu"$default_checked$main::xclose>);
		$mode_line .= qq(<label for="find_mixmenu">現行+過去</label>);

	# 過去ログ
	#if(-f $pastfile){

	#	# 現行ログ
	#	$mode_line .= qq(<input type="radio" name="log" value="0" id="find_menu"$nowfile_checked$main::xclose>);
	#	$mode_line .= qq(<label for="find_menu">現行</label>);

	#	# 過去ログのみ
	#	$mode_line .= qq(<input type="radio" name="log" value="1" id="find_pastmenu"$pastfile_checked$main::xclose>);
	#	$mode_line .= qq(<label for="find_pastmenu">過去</label>);
	#}


	# 昔の過去ログ
	#if($main::bbs{'past_num'} >= 1){
	#	my $past_number = $main::bbs{'past_num'};
	#		while($past_number > 0){
	#			my($checked);
	#				if($main::in{'log'} =~ /^next$past_number$/){ $checked = $main::parts{'checked'}; }
	#			$mode_line .= qq(<input type="radio" name="log" value="1" id="find_pastmenu$past_number"$checked$main::xclose>);
	#			$mode_line .= qq(<label for="find_pastmenu$past_number">過去$past_number</label>);
	#			$past_number--;
	#		}
	#}


		$mode_line .= qq(<input type="radio" name="log" value="all_past" id="findmenu_all"$all_checked$main::xclose>);
		$mode_line .= qq(<label for="findmenu_all">過去1-$main::bbs{'past_num'}</label>);
	}

$mode_line .= qq(</div>);

# 検索オプション
my $checked_strict_search = $main::parts{'checked'} if($main::in{'strict'});
my $checked_handle_search = $main::parts{'checked'} if($main::in{'handle'});
my $checked_subject_search = $main::parts{'checked'} if($main::in{'subject'});
$plusform_line .= qq(絞り込み： \n);
$plusform_line .= qq(<input type="checkbox" name="subject" value="1" id="subject_search"$checked_subject_search$main::xclose>);
$plusform_line .= qq(<label for="subject_search">題名</label>\n);
$plusform_line .= qq(<input type="checkbox" name="handle" value="1" id="handle_search"$checked_handle_search$main::xclose>);
$plusform_line .= qq(<label for="handle_search">作成者</label>\n);
$plusform_line .= qq(<input type="checkbox" name="strict" value="1" id="strict_search"$checked_strict_search$main::xclose>);
$plusform_line .= qq(<label for="strict_search">曖昧さオフ</label>\n);

# リターン
return($line,$mode_line,$plusform_line);

}


package Mebius::BBS;

#-----------------------------------------------------------
# インデックスを開いて検索する
#-----------------------------------------------------------
sub IndexFind{


# 宣言
my($type,$search_keyword,$hit,$i,$maxview_index) = @_;
my($index_handler,$line,@index_line,$index_file,$plustype_index,$max_search);


		# 表示最大数
		if(!$maxview_index){ $maxview_index = 10; }

		# 引継ぎ値で、既に最大行数を達成している場合はリターン
		if($hit > $maxview_index){ return(undef,$hit,$i); }

		# 処理最大数
		my $max_search_line = 10000;
		if($i > $max_search_line){ return(undef,$hit,$i); }

		# ファイル定義
		if($type =~ /Now-file/){ $index_file = $main::nowfile; }
		elsif($type =~ /Past-file(-([0-9]+))?/){
			$index_file = "$main::bbs{'data_directory'}_index_${main::realmoto}/${main::realmoto}_pst$2.log";
			$plustype_index .= qq( PAST);
		}
		else{ return(); }

		# 検索オプションの指定がない場合、すべてを対象に検索
		if($type !~ /(Subject-search|Handle-search)/){
			$type .= qq( Subject-search Handle-search);
		}

		shift_jis($search_keyword);

# 現行インデックスを開く
open($index_handler,"<",$index_file) || return(undef,$hit);

	# 現行ログの場合、トップデータを除外
	if($type =~ /Now-file/){
		chomp(my $top = <$index_handler>);
	}

	# インデックスを展開
	while (<$index_handler>){

		# 局所化
		my($hit_point2);

		# ラウンドカウンタ ( 引継ぎ値アリ )
		$i++;

		# 処理最大数に達した場合
		if($i > $max_search_line){ last; }

		# インデックスの１行を分解
		chomp;
		my($thread_number2,$subject2,$resnum2,$handle2,$date2,$lasthandle2,$key2) = split(/<>/);

			#if($key2 eq "0"){
			#	next;
			#}

		# ●題名から検索
		if($type =~ /Subject-search/){

				# キーワードを検索 ( 厳密にヒット )
				if($type =~ /Strict-search/){
					($hit_point2) = Mebius::Text::SimilarJudge("Cut-keyword Strict-search",$subject2,$search_keyword);
				}
				# キーワードを検索 ( あいまい検索 )
				else{
					($hit_point2) = Mebius::Text::SimilarJudge("Cut-keyword",$subject2,$search_keyword);
				}
		}

		# ●記事主の筆名から検索
		if($type =~ /Handle-search/ && $handle2 =~ /\Q$search_keyword\E/){ $hit_point2 += 2; }

		# 配列に追加
		push(@index_line,"$hit_point2<>$thread_number2<>$subject2<>$resnum2<>$handle2<>$date2<>$lasthandle2<>$key2<>\n");


	}

close($index_handler);

# 配列をソート
@index_line = sort { (split(/<>/,$b))[0] <=> (split(/<>/,$a))[0] } @index_line;

	# 現行インデックス配列を展開
	foreach(@index_line){

		# 行を展開
		chomp;
		my $utf8_data = utf8_return($_);
		my($hit_point2,$thread_number2,$subject2,$resnum2,$handle2,$date2,$lasthandle2,$key2) = split(/<>/,$utf8_data);

			# 表示行を追加
			if($hit_point2 >= 1){

				my($linebuf) = main::indexline_set("$plustype_index","$thread_number2<>$subject2<>$resnum2<>$handle2<>$date2<>$lasthandle2<>$key2",$hit);

					if($linebuf){
						$line .= $linebuf;
						$hit++;
					}
			}

			# 表示最大数に達した場合
			if($hit > $maxview_index){ last; }

	}

return($line,$hit,$i);

}

package main;
use Mebius::Export;

#-----------------------------------------------------
# 全記事を表示 - strict
#-----------------------------------------------------
sub index_allmenu_set {

# 宣言
my $index = shift;
my($line,$top,@sortdata,$index_handler,$i);
our($submode2,$nowfile);
my @index_line = @{$index->{'all_line'}};
shift @index_line;

# 新規投稿順にソート
if($submode2 eq "new"){ @sortdata = sort { (split(/<>/,$b))[0] <=> (split(/<>/,$a))[0] } @index_line; }

# 返信順にソート
if($submode2 eq "res"){ @sortdata = sort { (split(/<>/,$b))[4] <=> (split(/<>/,$a))[4] } @index_line; }

# レス数にソート
if($submode2 eq "rescnt"){ @sortdata = sort { (split(/<>/,$b))[2] <=> (split(/<>/,$a))[2] } @index_line; }

# 題名順にソート
if($submode2 eq "title"){ @sortdata = sort { (split(/<>/,$b))[1] cmp (split(/<>/,$a))[1] } @index_line; }

#close($index_handler);

	# データを書き出し
	foreach(@sortdata){
		$i++;
		my $utf8_data = utf8_return($_);
		($line) .= &indexline_set("",$utf8_data,$i);
	}

return($line);

}

#-----------------------------------------------------
# 削除済みメニュー - strict
#-----------------------------------------------------
sub index_deletedmenu_set{

# 宣言
my($line,$delete_handler,$i);
our($realmoto);

# ファイル定義
my($directory) = Mebius::BBS::index_directory_path_per_bbs($realmoto);
my $file = "${directory}deleted_threads.log";

open($delete_handler,"<",$file);
$i++;
while (<$delete_handler>) {
	my $utf8_data = utf8_return($_);
	($line) .= &indexline_set("",$utf8_data,$i);
}
close($delete_handler);

return($line);

}

#-----------------------------------------------------
# 最大レス突破記事 
#-----------------------------------------------------
sub index_maxresmenu_set{

# 宣言
my($type) = @_;
my($line,$maxres_handler,$i);
our($realmoto);
my($index_directory) = Mebius::BBS::index_directory_path_per_bbs($realmoto);
my $file = "${index_directory}maxres_threads.log";

open($maxres_handler,"<",$file);
chomp(my $top1 = <$maxres_handler>);
	while (<$maxres_handler>) {
		$i++;
			my $utf8_data = utf8_return($_);
		($line) .= &indexline_set("",$utf8_data,$i);
	}
close($maxres_handler);

return($line);

}

#-----------------------------------------------------
# PV ランキング 
#-----------------------------------------------------
sub index_pvallmenu_set{

# 宣言
my($type) = @_;
my($line,$pv_handler,$i);
my($init_directory) = Mebius::BaseInitDirectory();
our($moto);

# ファイルを開く
open($pv_handler,"<","$main::bbs{'data_directory'}_other_${moto}/pvall_${moto}.log");

# トップデータ
chomp(my $top1 = <$pv_handler>);

	# ファイルを展開
	while (<$pv_handler>) {
		$i++;
		chomp;
		my $utf8_data = utf8_return($_);
		($line) .= &indexline_set("Pv-ranking",$utf8_data,$i);
	}

close($pv_handler);

return($line);

}

#-----------------------------------------------------------
# １行あたりの書き出し
#-----------------------------------------------------------
sub indexline_set{ Mebius::BBS::Index->view_line_core(@_); }

#-------------------------------------------------
# 投稿履歴 - strict
#-------------------------------------------------
sub index_get_rireki{

# 宣言
my($i,$top,$line);
my($view_rireki_max) = (5);
my($init_directory) = Mebius::BaseInitDirectory();
our($crireki);

# 投稿履歴を取得
require "${init_directory}part_history.pl";
my($none,$line) = &get_reshistory("ONELINE THREAD My-file",undef,undef,undef,undef,3,3);

# リターン
if(!$line){ return; }

# 整形
$line = qq(<hr><span class="size3">$line</span>);

# リターン
return($line);

}

#-----------------------------------------------------------
# カテゴリ毎の 新着いいね！ / 新着レス を取得 - strict
#-----------------------------------------------------------
sub index_get_news{

# 宣言
my($type,%category) = @_;
my($hit,$line,$file,$news_title,$max);
our($moto,$concept,$category,$concept);
my $time = time;
my($init_directory) = Mebius::BaseInitDirectory();

# カテゴリ設定を取得
my($init_category) = Mebius::BBS::init_category_parmanent($main::category) || return();
$init_category = hash_to_utf8($init_category);

if($concept =~ /MODE-PASIVE/ || $main::secret_mode){ return; }

	# ファイル定義
	if($type eq "support"){
		$news_title = "応援されている記事";
		$file = "${init_directory}_sinnchaku/_category/${category}_newsupport.cgi";
		$max = 2;
	}
	elsif($type eq "res"){
		$news_title = "$init_category->{'title'}カテゴリ";
		$file = "${init_directory}_sinnchaku/_category/${category}_newres.cgi";
		$max = 2;
	}
	else{ return; }

# ファイル読み込み
open(IN,"<","$file");
	while(<IN>){

		my($key,$moto2,$title2,$no,$sub,$handle,$comment,$res,$lasttime,$date2) = split(/<>/);
		utf8($title2,$sub,$handle);

			if($lasttime + 30 > $time){ next; }

			if($moto2 eq $moto && !Mebius::alocal_judge()){ next; }

			if($key eq "1"){
				my($class1,$move,$re,$viewhandle);
				$hit++;
					if($hit == 1){ $class1 = qq( class="first"); }
					if($hit >= 2){ $line .= qq( | ); }
					if($type eq "res"){ $move = "#S$res"; $re = "Re: "; }
				$line .= qq(<a href="/_$moto2/$no.html"$class1>$sub</a>);
					if($type eq "res"){ $line .= qq( ( <a href="/_$moto2/$no.html$move"$class1>$handle</a> ) ); }
					if($moto2 eq $moto){ $line .= qq( - $title2 ); }
					else{ $line .= qq( - <a href="/_$moto2/" class="bbs">$title2</a> ); }
			}

			if($hit >= $max){ last; }
	}
close(IN);

my($othrer_bbs_link_area) .= Mebius::BBS::Index::other_bbs_link_area($category,$moto);

# 整形
$line .= qq( | <a href="/_main/newres-p-${category}.html">…続き</a>);
$line = qq(<div class="category bdbcolor bgkcolor">$news_title： $line $othrer_bbs_link_area</div>);

# リターン
return($line);

}

#-----------------------------------------------------------
# タイトル定義 - strict
#-----------------------------------------------------------
sub index_set_title{

# 宣言
my($type,$page,$logtype) = @_;
my($sub_title,$plus_idx,$submode2_title,$word_enc,$log_divide,$logtypelink,$second_title,@BCL);
my($param) = Mebius::query_single_param();
my $param_utf8 = Mebius::Query->single_param_utf8();

our(%in,%im,$mode,$moto,$menu1,$menu2,$head_link3,$thisis_bbstop,$noindex_flag,$submode1,$submode2,$server_domain,$encword);
my $head_title = our $head_title;
utf8($head_title);

# ページ数判定
if($page ne "" && ($page =~ /([^0-9])/) ){ &error("ページ数の指定が変です。"); }

# エンコード
($encword) = Mebius::Encode("",$in{'word'});

	# 記事検索の場合
	if($mode eq "find"){
		$word_enc = Mebius::Encode("",$in{'word'});
		$sub_title = "”$param_utf8->{'word'}”の検索結果 | $head_title";
		push @BCL , e("”$param_utf8->{'word'}”の検索結果");
		my $postbuf_escaped = $main::postbuf;
		$postbuf_escaped =~ s/mode=find/mode=kfind/g;
		$postbuf_escaped =~ s/moto=(\w+)&?//g;
		#$divide_url = "http://$server_domain/_$moto/?$postbuf_escaped";
	}

	# 全記事を表示する場合
	elsif($submode1 eq "all"){
			if($submode2 eq "title"){ $submode2_title = "題名順"; }
			elsif($submode2 eq "res"){ $submode2_title = "レス順"; }
			elsif($submode2 eq "rescnt"){ $submode2_title = "レス数順"; }
			elsif($submode2 eq "new"){ $submode2_title = "作成日順"; }
			elsif($submode2 eq "maxres"){ $submode2_title = "最大レス達成"; }
			elsif($submode2 eq "pvall"){ $submode2_title = $second_title = "PVランキング"; }
			elsif($submode2 eq "deleted"){ $submode2_title = "削除済み"; $noindex_flag = 1; }
			else{ &error("このモード ( $mode ) は存在しません。"); }
		$sub_title .= "$submode2_title | $head_title";
		push @BCL , "並べ替え表\示（$submode2_title）";
	}

	# 過去ログ
	elsif($mode eq "oldpast"){
	$plus_idx = int(($page + $menu2) / $menu2);
	$sub_title = "$plus_idx頁 | $head_title | 過去ログ$logtype";
	if($logtype){ $logtypelink = "-$logtype"; }
	if($page eq "0"){ $head_link3 = qq(過去ログ$logtype); }
	else{
		push @BCL , { url => "p0$logtypelink.html" , title => "過去ログ$logtype" };
		push @BCL , qq(${plus_idx}頁);
	}
	}

	# 掲示板メニューＴＯＰ
	elsif(!$page){
		$sub_title .= $head_title;
		$thisis_bbstop = 1;
		#$divide_url = "http://$server_domain/_$moto/km0.html";
	}

	# 掲示板メニュー　２ページ目以降
	else{
		$plus_idx = int(($page + $menu1) / $menu1);
		$sub_title = "$plus_idx頁 | $head_title";
		push @BCL , "${plus_idx}頁";
		#$divide_url = "http://$server_domain/_$moto/km$page.html";
	}

# リダイレクトで振り分け
#if($device_type eq "mobile" && $divide_url){ &divide($divide_url,"mobile"); }


# リターン
return($sub_title,$thisis_bbstop,$second_title,\@BCL);

}



1;
