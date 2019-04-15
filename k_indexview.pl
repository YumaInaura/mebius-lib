
package main;

#-----------------------------------------------------------
# 携帯版インデックス
#-----------------------------------------------------------
sub bbs_view_indexview_mobile{

# 宣言
my($type,$join_parts) = @_;
my($num,$sub,$res,$nam,$date,$na2,$key,$alarm,$i,$data,$top,$count);
my($file,$newrgt,$follow_link,$index_handler,$hit,$index_line,$hit,$kadsense_view,$prnt);
our($kfontsize_xsmall_in);

my(%emoji) = Mebius::Emoji;
my($emoji_shift_jis) = Mebius::Encoding::hash_to_shift_jis(\%emoji);

$time = time;

# サブ記事専用の場合、リダイレクト
if($subtopic_mode && $type =~ /VIEW/){ Mebius::Redirect("","http://$server_domain/_$moto/",301); }

	# 処理振り分け ( 検索モード )
	if($main::mode eq "find"){
		my($init_directory) = Mebius::BaseInitDirectory();
		require "${init_directory}k_find.pl";
		&bbs_find_mobile();
	}

$p = $in{'p'};

# マイページの戻り先
$mybackurl = "http://$server_domain/_$moto/";

# ナビゲーションリンクの設定
if($in{'p'} eq "" || $in{'p'} eq "0"){ $kboad_link = "now"; }

# 携帯設定
if(!$join_parts){ &kget_items(); }

# タイトル定義
&set_title_kindexview();

# 局所化
my($secret_links,$new_rgt);

# 新規投稿リンク
if($concept !~ /NOT-POST/) { $new_rgt = qq( <a href="kform.html"$sikibetu>新規</a>); }

# フォローリンク
if($cookie) { $follow_link = qq( <a href="$script?type=form_follow&amp;k=1">ﾌｫﾛｰ</a>); }

# 秘密板リンク
if($secret_mode){
$secret_links = qq(
<span style="font-size:x-small;">
<a href="member.html">メンバ</a>
<a href="$script?mode=member&amp;type=vedit"$main::utn2>設定</a>
<a href="./?mode=logoff"$main::utn2>ログオフ</a>
</span>
);
}

	# 広告
my($kadsense1,$kadsense2) = &kadsense("INDEX");

	if($kadsense1){
		$kadsense_view = qq(<hr$xclose>$kadsense1);
	}

	if($kadsense2){
		$main::kfooter_ads = $kadsense2;

	}


# HTML
$print .= qq(
$join_parts
<div style="${kfontsize_medium_in}background:#dee;text-align:center;">
$title$secret_links
</div>

<form action="$script" style="$kpadding_normal_in$kborder_top_in"><div style="$ktextalign_center_in">
(*)<input type="hidden" name="mode" value="find"$xclose><input type="text" name="word" value="" size="9" accesskey="*"$xclose><input type="submit" value="検索"$xclose>
</div>
</form>
$kadsense_view
);


# 調整
if($p eq "") { $p = 0; }
my($i);
$file = $nowfile;


# ファイル読み込み
open($index_handler,"<","$file");
$top = <$index_handler>;
my($newnum,$none) = split(/<>/,$top);

# 親記事数認識、ページ繰り越しリンク数の調整
if($newnum < $i_max){ $i_max = $newnum; }

$print .= qq(<div style="background:#eef;$ktextalign_center_in$kborder_top_in">ナビ</div>);
$print .= qq(<div style="padding:0.5em 0em;$ktextalign_center_in">\n);
$print .= qq($new_rgt$follow_link <a href="$newnum.html">$emoji_shift_jis->{'new'}記事</a>\n);
	if($main::bbs{'concept'} !~ /Not-handle-ranking/){
		$print .= qq(<a href="./ranking.html">参加者</a>\n);
	}
$print .= qq(</div>);

# メニュー上部の帯
$print .= qq(<div style="background:#eef;$ktextalign_center_in$kborder_top_in">$emoji_shift_jis->{'number5'}<a href="#MENU" id="MENU" accesskey="5">一覧</a></div>);

	# インデックスを展開
	while (<$index_handler>) {

		# 局所化
		my($background_color,$stopic,$link);
		
		# ラウンドカウンタ
		$i++;

			# 次回処理に回す場合
			if($_ eq ""){ next; }
			if($i < $p + 1){ next; }
			if($i > $p + $menu1){ next; }

		# ヒットカウンタ
		$hit++;

		# 行を分解
		chomp;
		my($num,$sub,$res,$nam,$date,$lasthandle,$key) = split(/<>/);
		
		require "${main::int_dir}part_indexview.pl";
		my $utf8_data = utf8_return($_);
		($index_line) .= shift_jis(main::indexline_set("Mobile-view",$utf8_data,$hit));

	}

close($index_handler);

$print .= qq($index_line);

$print .= qq(<hr$xclose>);

# ページめくりリンクを取得
my($page_links) = &get_pagelinks_kindexview("Round1",$i);
$print .= $page_links;

# ヘッダ
Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-----------------------------------------------------------
# ページめくりリンクを取得
#-----------------------------------------------------------
sub get_pagelinks_kindexview{

# 宣言
my($type,$thread_num) = @_;
my($page,$mile,$accesskey4,$accesskey6,$newpage,$oldpage);
our($i_max,$menu1,$p,$line,$mine,%in,$i_max,$pastfile);

	# アクセスキーを設定する場合
	if($type =~ /Round1/){
		$accesskey4 = qq( accesskey="4");
		$accesskey6 = qq( accesskey="6");
	}

	# ページめくりリンク（←）
	$newpage = $in{'p'} - $menu1;
	if($in{'p'} < $menu1){ $line .= qq(④新\n); }
	else{ $line .= qq(<a href="km${newpage}.html"$accesskey4>④新</a>\n); }

# ページめくりリンク
$page = $thread_num / $menu1;
$mile = 1;

	# 繰り返し処理
	while ($mile < $page + 1){
		$mine = ($mile - 1) * $menu1;
			if($p == $mine) { $line .= qq($mile\n); }
			else{ $line .= qq(<a href="km$mine.html">$mile</a>\n); }
		$mile++;
	}

	# ページめくりリンク（→）
	$oldpage = $in{'p'} + $menu1;
	if($in{'p'} + $menu1 >= $thread_num){ $line .= qq(⑥古\n); }
	else{ $line .= qq(<a href="km${oldpage}.html"$accesskey6>⑥古</a>\n); }

	if(-f $main::newpastfile){
		$line .= qq( <a href="past.html">過</a>);
	}

# 整形
$line = qq(<div style="font-size:small;">$line</div>);

# リターン
return($line);


}

no strict;

#-----------------------------------------------------------
# タイトル定義
#-----------------------------------------------------------
sub set_title_kindexview{

# ページ数判定
if($in{'p'} ne "" && ($in{'p'} =~ /([^0-9])/) ){ &error("ページ数の指定が変です。"); }

# タイトル定義
if($menu1){ $plus_idx = int(($in{'p'} + $menu1) / $menu1); }

	# トップ
	if(!$in{'p'}) {
		$sub_title .= "$head_title";
		$divide_url = "http://$server_domain/_$moto/";
	} 

	# ２ページ目以降
	else{
		$sub_title .= "$plus_idx頁 | $head_title";
		$divide_url = "http://$server_domain/_$moto/m$in{'p'}.html";
	}

	# リダイレクトで振り分け
	#if($device_type eq "desktop" && $divide_url){ &divide($divide_url,"desktop"); }

}


1;
