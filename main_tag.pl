
use Mebius::BBS;
use Mebius::History;
use Mebius::Tag;

#-----------------------------------------------------------
# タグの共通設定
#-----------------------------------------------------------
sub getinit_tag_base{
my($maxtag,$maxlength_tag) = (10,10);
$maxtag = 10;
$maxlength_tag = 10;
return($maxtag,$maxlength_tag);
}

#-----------------------------------------------------------
# モード振り分け
#-----------------------------------------------------------
sub do_tag{

# タイトルなど定義
$sub_title = "タグ";
$head_link2 = qq(&gt; <a href="http://$server_domain/">$server_domain</a>);
$head_link3 = qq( &gt; <a href="/_main/newtag-$submode2-1.html">タグ</a>);

# モード振り分け
if($submode2 eq "make" || $submode2 eq "delete" || $submode2 eq "edit"){ &edittag("$submode2"); }
elsif($submode3 eq "v"){ &view_tag($submode4); }
elsif($submode3 eq "all"){ &view_alltag(); }
else{ &error("このモードは存在しません。"); }
}

#-----------------------------------------------------------
# タグ単体ページを表示
#-----------------------------------------------------------
sub view_tag{

# 局所化
my($tagname) = @_;
my($enctagname,$line,$type,$adform,$keytext,$ads);

# タグの共通設定を取り込み
my($maxtag,$maxlength_tag) = &getinit_tag_base();

# CSS定義
$css_text .= qq(
table,th,tr,td{border-style:none;}
table{margin: 1em 0em;width:70%;}
td{padding:0.3em 0em;}
td.sub{width:20em;}
h2{background:#bdd;}
h2{padding:0.4em 0.7em;font-size:110%;}
);

# タイプ処理
if($submode2 eq "p"){ }
elsif($submode2 eq "k"){ &kget_items; $type .= " MOBILE"; }
else{ &error("この表\示モードは存在しません。"); }

# エンコード
($enctagname) = Mebius::Encode("",$tagname);

# タグ単体ファイルを取得
my($flag,$line,$tagnum,$tagkey) = &open_tag("VIEW$type",$tagname,$enctagname);

# タグファイルが存在しない場合
if(!$flag){ &error("このタグは存在しません。"); }

# 閉鎖、ロック中
if($tagkey eq "close"){
if($admin_mode){ $keytext = qq(<strong class="red">★このタグは閉鎖中です。</strong>); }
else{ &error("このタグは閉鎖中です。","410"); }
}
elsif($tagkey eq "lock"){ $keytext = qq(<strong class="red">★このタグはロックされています。</strong>); }

# 管理者フォーム
if($admin_mode){ 
$adform .= qq(<a href="$script?mode=tag-edit&amp;type=close&amp;tagname=$enctagname&amp;place=tag">閉鎖</a> );
$adform .= qq(<a href="$script?mode=tag-edit&amp;type=lock&amp;tagname=$enctagname&amp;place=tag">ロック</a> );
}

# 広告を定義
if($tagnum >= 1){
$ads = qq(
<h2>スポンサードリンク</h2>
<script type="text/javascript"><!--
google_ad_client = "pub-7808967024392082";
/* 記事データ */
google_ad_slot = "9966248153";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
);
if($alocal_mode || $admin_mode || $kflag){ $ads = ""; }
}

# タイトル定義
$sub_title = "$tagname | タグ";
$head_link4 = qq( &gt; $tagname );

# 検索フォームをゲット
my($tagsearch_form) = &get_tagsearch_form("FOCUS");


# HTML
my $print = qq(
<h1>$tagname - タグ</h1>
<a href="/">ＴＯＰページに戻る</a>　
<a href="/_main/newtag-$submode2-1.html">新着タグ</a>　
$tagsearch_form
$adform
$keytext
<h2>”$tagname”に関係する記事 ( $tagnum )</h2>
$line
$ads
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-----------------------------------------------------------
# タグの作成、編集、削除
#-----------------------------------------------------------
sub edittag{

# 局所化
my($type) = @_;
my($tagname,@line1,@line2,$title,$plustype,$flag_newtag,@line_newtag,$init_bbs);

# タグの共通設定を取り込み
my($maxtag,$maxlength_tag) = &getinit_tag_base();

# アクセス制限
&axscheck("ACCOUNT");

# IDと管理番号をセット
our($encid) = &id();

# 汚染チェック
my($tagname) = split(/\0/,$in{'tagname'});

# 権限チェック
if($submode2 eq "delete" && !$admin_mode){ &error("実行権限がありません。"); }
if($submode2 eq "edit" && !$admin_mode){ &error("実行権限がありません。"); }

# $in{'bbs-no'} を分割
my($fbbsno) = split(/\0/,$in{'bbs-no'});
my($fmoto,$fno) = split(/\-/,$fbbsno);


	# 掲示板のモードをチェック
	if($submode2 eq "make" || $submode2 eq "edit"){
		($init_bbs) = Mebius::BBS::init_bbs_parmanent($fmoto);
			if($init_bbs->{'concept'} =~ /(NOT-TAG|MODE-SECRET)/){ main::error("この掲示板にはタグを登録できません。"); }
	}

	# 各種チェック
	if(!$postflag && $submode2 eq "make"){ &error("GET送信は出来ません。"); }
	if(!$admin_mode && !$idcheck && $main::device{'level'} < 2){ &error("タグを登録するには、アカウントにログインしてください。"); }
	if($submode1 eq "make"){
		if($in{'bbs-no'} eq ""){ &error("記事、掲示板を指定してください。"); }
	}

	# 登録の場合、タグの入力内容をチェック
	if($submode2 eq "make"){
		require "${int_dir}regist_allcheck.pl";
			if(length($tagname) > $maxlength_tag*2){ &error("全角$maxlength_tag文字以内で登録してください。"); }
			if($tagname =~ /ttp/){ &error("ＵＲＬは登録できません。"); }
		&url_check("",$tagname);
		&badword_check($tagname);
		&error_view();
	}

	# タグの整形
	if($submode2 =~ /(make|delete|edit)/){
		($tagname) = Mebius::Tag::FixTag(undef,$tagname);
			if($tagname eq ""){ &error("タグの内容を入力してください。"); }
	}

# ロック開始
&lock("TAG") if($lockkey);

# エンコード
my($enctagname) = Mebius::Encode("",$tagname);

	# 記事タグファイルの処理から入る場合（削除）
	if($admin_mode && $submode2 eq "delete" && $in{'place'} eq "thread"){
		&open_threadtag("$submode2 RENEW",$tagname,$enctagname,$fmoto,$fno);
	}

	# タグ単体ファイルの処理から入る場合（登録他）
	else{
		($flag1,$line1,$tagnum) = &open_tag("$submode2",$tagname,$enctagname,$fmoto,$fno);
	}


# ロック解除
&unlock("TAG") if($lockkey);

# 新着タグファイルを更新
if($type =~ /make/){ $plustype = " NEWLIST"; }
require "${main::int_dir}part_newlist.pl";
Mebius::Newlist::tag("RENEW$plustype","","","$tagname<>$enctagname<>$tagnum");

	# ジャンプ先（記事データに戻る場合）
	if($admin_mode){ $jump_url = "${main::jak_url}$fmoto.cgi?mode=view&no=$fno&r=data"; }
	else{ $jump_url = "http://$server_domain/_$fmoto/${fno}_data.html"; }

	# リダイレクト先（タグに戻る場合）
	if($in{'place'} eq "tag"){
		if($admin_mode){ $jump_url = "$main::main_url?mode=tag-p-v-$enctagname"; }
		else{ $jump_url = "http://$server_domain${main_url}tag-p-v-$enctagname.html"; }
	}

	# クッキーをセット
	if(!$admin_mode){

		# クッキーをセット
		#&set_cookie();

		# 投稿履歴ファイルを更新
		Mebius::HistoryAll("Renew My-file");

	}

	# リダイレクト
	Mebius::Redirect("",$jump_url);


# HTML
my $print = qq(
実行しました。（<a href="$jump_url">→戻る</a>）
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# タグ単体ファイルの処理
#-----------------------------------------------------------
sub open_tag{


# 局所化
my($type,$tagname,$enctagname,$moto,$no) = @_;
my($line1,@line2,$i,$nextflag,$title,$sub,$delete_hit,$flag2,$posthandle,$hostagent,$open);
my($init_directory) = Mebius::BaseInitDirectory();
our(%in,$server_domain);

# タグの共通設定を取り込み
my($maxtag,$maxlength_tag) = &getinit_tag_base();

# 汚染チェック
$no =~ s/\D//g;
$moto =~ s/[^a-z0-9]//g;
	if($enctagname eq ""){ &error("タグを指定してください。"); }

	# CSS定義
	if($type =~ /VIEW/){
		$main::css_text .= qq(table.tag{width:100%;});
	}

# ファイル定義
my $file = "${init_directory}_tag/${enctagname}_tag.cgi";
my $move_from_file = "${init_directory}_tag_move_from/${enctagname}_tag.cgi";

# タグ単体ファイルを開く
$open = open(TAG_IN,"<",$file);

chomp(my $top = <TAG_IN>);
my($key,$res,$posttime,$lasttime,$concept) = split(/<>/,$top);


	# 編集、削除でタグファイルが存在しない場合
	if( ( ($type =~ /(delete)/ && $in{'place'} eq "tag") || ($type =~ /(edit)/) ) && !$open){
		close(TAG_IN);
		&error("このタグは存在しません。");
	}

	# キーチェック
	if(($key eq "close" || $key eq "lock") && ($type =~ /make/) && !$admin_mode){ &error("このタグは閉鎖（またはロック）されているため、登録できません。"); }

# ファイルを展開
	while(<TAG_IN>){
		chomp;
		my($moto2,$no2,$sub2,$title2,$account2,$posthandle2,$host2,$server_domain2,$cnumber2,$agent2) = split(/<>/);
		my($hit);

			if($server_domain2 eq ""){ $server_domain2 = $server_domain; }

			# 秘密板などをエスケープ
			if($moto2 =~ /^sc/){ next; }

			# 記事データへのタグ登録？
			#if($type =~ /make/){
			#		if("$moto-$no" eq "$moto2-$no2"){ next; }	# 重複登録の場合は次回処理へ
			#	if(-e "${init_directory}_tag/$enctagname\_tag.cgi"){ main::error(""); }
			#	main::error("${init_directory}_tag/$enctagname\_tag.cgi");
			#	&open_threadtag("$type RENEW",$tagname,$enctagname,$moto2,$no2);
			#}

			# 「タグ単体ファイル」の操作から、複数の「記事タグ」を一斉操作
			elsif($type =~ /(delete)/ && $admin_mode && $in{'place'} eq "tag"){
			my($flag,$hit);
			foreach(split(/\0/,$in{'bbs-no'})){
			if("$_" eq "$moto2-$no2"){
			($flag,$hit) = &open_threadtag("$type RENEW",$tagname,$enctagname,$moto2,$no2);
			if($admin_mode){ $hit = 1; }
			if($hit){ $delete_hit = 1; }
			}
			}
			if($hit){ next; }
			}

			# 「タグ単体ファイル」の中の「記事登録」を、普通に１個削除
			elsif($type =~ /(delete)/ && $admin_mode && $in{'place'} eq "thread"){
			if("$moto-$no" eq "$moto2-$no2"){ $delete_hit++; next; }
			}

		# 処理する行
		$i++;
		push(@line2,"$moto2<>$no2<>$sub2<>$title2<>$account2<>$posthandle2<>$host2<>$server_domain2<>$cnumber2<>$agent2<>\n");

			# タグリスト
			if($type =~ /VIEW/){
				my($link);
				$link = "/_$moto2/$no2.html";
				if($admin_mode){ $link = "$moto2.cgi?mode=view&amp;no=$no2"; }
				if($type =~ /MOBILE/){ $line1 .= qq(<li>); } else{ $line1 .= qq(<tr>); }
				if($admin_mode){ $line1 .= qq(<td><input type="checkbox" name="bbs-no" value="$moto2-$no2"></td>); }
				if($type =~ /MOBILE/){ $line1 .= qq(<a href="/_$moto2/$no2.html">$sub2</a> [ <a href="/_$moto2/$no2\_data.html#TAG">タグ</a> ] - <a href="/_$moto2/">$title2</a>); }
				else{ $line1 .= qq(<td class="sub"><a href="$link">$sub2</a></td><td><a href="/_$moto2/$no2\_data.html#TAG">タグ</a> </td><td><a href="/_$moto2/">$title2</a></td>); }
				if($idcheck || $admin_mode){
				if($type =~ /MOBILE/){ $line1 .= qq( - <a href="${auth_url}$account2/">$account2</a>); } 
				else{ $line1 .= qq(<td><a href="${auth_url}$account2/">$account2</a></td>); }
			}

			# ホスト名の表示
			if($admin_mode && $admy_rank >= $master_rank){
				$line1 .= qq(<td><a href="$mainscript?mode=cdl&amp;file=$host2&amp;filetype=host" class="manage">$host2</a></td>);
			}

			# 管理番号の表示
			if($admin_mode){
				$line1 .= qq(<td><a href="$mainscript?mode=cdl&amp;file=$cnumber2&amp;filetype=number" class="manage">$cnumber2</a></td>);
			}

			# ユーザーエージェントの表示
			if($admin_mode){
				$line1 .= qq(<td><a href="$mainscript?mode=cdl&amp;file=$agent2&amp;filetype=agent" class="manage">$agent2</a></td>);
			}


			if($type =~ /MOBILE/){ $line1 .= qq(</li>\n); }
			else{ $line1 .= qq(</tr>\n); }
		}
	}
close(TAG_IN);

	# リスト整形
	if($line1){
			if($type =~ /MOBILE/){ $line1 = qq(<ul>$line1</ul>); }
			else{
				$line1 = qq(<table summary="タグ一覧" class="tag">$line1</table>);
			}
	}

	# 連続送信制限
	if($submode2 eq "make" && !$pmfile){ &redun("TAG_MAKE",1*60,10); }
	#elsif($submode2 eq "delete"){ &redun("TAG_DELETE",1*60*3,10); }

	# 記事タグファイルを新規登録
	if($type =~ /make/){
		($none,$none,$none,$none,$sub,$posthandle) = &open_threadtag("$type RENEW",$tagname,$enctagname,$moto,$no);
	}

	# 掲示板名を取得
	if($type =~ /make/){
		#require "${init_directory}part_autoinit.cgi";
		#($title) = &get_autoinit($moto);
		my($init_bbs) = Mebius::BBS::init_bbs_parmanent($moto);
		($title) = $init_bbs->{'title'};
	}

# UA記録振り分け
my $record_agent = $agent if($main::k_access);

	# 追加する行
	if($type =~ /make/){ unshift(@line2,"$moto<>$no<>$sub<>$title<>$pmfile<>$posthandle<>$host<>$server_domain<>$cnumber<>$record_agent<>\n"); $i++; }

	# キーを変更
	if($type =~ /edit/){
			if($in{'type'} eq "lock" && $key ne "lock"){ $key = "lock"; }
			elsif($in{'type'} eq "close" && $key ne "close"){ $key = "close"; }
			else{ $key = "1"; }
	}

	# トップデータを追加（既存のタグの場合）
	if($top){ unshift(@line2,"$key<>$i<>$posttime<>$time<>$concept<>\n"); }

	# トップデータを追加（新規タグの場合）
	else{ unshift(@line2,"1<>$i<>$time<>$time<>\n"); }

	# タグ単体ファイルを更新
	if($type !~ /VIEW/){
		my $tag_file = "${init_directory}_tag/$enctagname\_tag.cgi";
			if($type =~ /(make|edit)/ || ($type =~ /delete/ && $delete_hit)){
				#Mebius::Fileout();	
				open(TAG_OUT,">","${init_directory}_tag/$enctagname\_tag.cgi");
				print TAG_OUT @line2;
				close(TAG_OUT);
				Mebius::Chmod(undef,$tag_file);
			}
	}

	# フォーム
	if($type =~ /VIEW/ && $admin_mode && $i >= 1){
		$line1 = qq(
		<form action="$script" method="post">
		<div>
		$line1
		<input type="hidden" name="mode" value="tag-delete"$xclose>
		<input type="hidden" name="tagname" value="$tagname"$xclose>
		<input type="hidden" name="place" value="tag"$xclose>
		<br$xclose><input type="submit" value="タグを削除する"$xclose>
		</div>
		</form>
		);
	}

	# タグ数整形
	if(!$i){ $i = 0; }

# リターン
return($top,$line1,$i,$key,$delete_hit);

}

#-----------------------------------------------------------
# 記事タグファイルを処理
#-----------------------------------------------------------
sub open_threadtag{

# 局所化
my($type,$tagname,$enctagname,$moto,$no,$thread_key) = @_;
my($flag,$line1,$line2,$i,$device,$put_count,$delete_hit);
my($none,$sub,$res,$key,$posthandle,$filehandle3);
our($concept);

	# 権限チェック
	if(!$admin_mode && $type =~ /vanish/){ &error("このアクションが出来るのは管理者のみです。"); }

# タグの共通設定を取り込み
my($maxtag,$maxlength_tag) = &getinit_tag_base();

# 汚染チェック
$no =~ s/\D//g;
$moto =~ s/[^a-z0-9]//g;
if($no eq "" || $moto eq ""){ &error("記事を指定してください。"); }

# 掲示板設定を取得
my($bbs_file) = Mebius::BBS::InitFileName(undef,$moto);

# ファイル定義
my $directory1 = "$bbs_file->{'data_directory'}_tag_${moto}/";
my $file1 = "${directory1}${no}_tag.cgi";

	# リターン
	if(!$admin_mode){
		if($moto =~ /^sc/ || $secret_mode || $concept =~ /NOT-TAG/){ return; }
	}

	# CSS定義
	if($type =~ /VIEW/){
		$css_text .= qq(div.tag{margin-top:0.5em;line-height:1.2;});
	}

	# 元記事を開く
	if($type =~ /(RENEW)/){
		my($thread) = Mebius::BBS::thread_state($no,$moto);
			if(!$thread->{'f'}){ &error("元の記事が存在しません。") ; }
		($sub,$res,$key) = ($thread->{'sub'},$thread->{'res'},$thread->{'key'});
		$posthandle = $thread->{'res'}; #謎の処理？
		close(THREAD_IN);
	}

	# 元記事のキー判定
	if($type =~ /make/ && !$admin_mode){
		if($key ne "1" && $key ne "2" && $key ne "3" && $key ne "5"){ &error("削除済み、ロック中記事のタグは編集できません。"); }
	}

	# 表示モード
	if($type =~ /MOBILE/){ $device = "k"; } else { $device = "p"; }


# ファイルを開く
open($filehandle3,"<$file1");
my $top = <$filehandle3>; chomp $top;
my($key,$res) = split(/<>/,$top);

	# ファイルを展開
	while(<$filehandle3>){
		chomp;
		my($count2,$tagname2,$server_domain2) = split(/<>/);
		my($enctagname2) = Mebius::Encode("",$tagname2);

			if($server_domain2 eq ""){ $server_domain2 = $server_domain; }

			# 記事に登録されている、全ての「タグ単体ファイル」を削除する処理へ移行
			if($type =~ /vanish/){
				($none,$none,$none,$none,$hit) = &open_tag("delete RENEW",$tagname2,$enctagname2,$moto,$no);
				$delete_hit++; next;
			}

			# 普通に削除
			elsif($type =~ /delete/ && $admin_mode && $in{'place'} eq "tag"){
				if($tagname2 eq $tagname){ $delete_hit++; next; }
			}

			# 複数のタグファイルも一斉に削除
			elsif($type =~ /delete/ && $admin_mode && $in{'place'} eq "thread"){
				my($none,$hit);
				foreach(split(/\0/,$in{'tagname'})){
						if($tagname2 eq $_){
							($none,$none,$none,$none,$hit) = &open_tag("$type RENEW",$tagname2,$enctagname2,$moto,$no);
								if($admin_mode){ $hit = 1; }
								if($hit){ $delete_hit = 1; }
						}
				}
					if($hit){ next; }
			}

		$i++;

			# 登録最大数オーバー
			if($i > $maxtag && $type =~ /make/){
				&error("ひとつの記事に、登録できるタグは$maxtag個までです。$in{'no'}\(現在 $i 個目 \) 記事");
			}

			if($tagname2 eq $tagname){ $flag = 1; }
			else{ $line2 .= qq($count2<>$tagname2<>$server_domain2<>\n); }
			if($admin_mode){ $line1 .= qq(<input type="checkbox" name="tagname" value="$tagname2">); }
			if($admin_mode){ $line1 .= qq(<a href="$mainscript?mode=tag-$device-v-$enctagname2">$tagname2</a> ); }
			else{ $line1 .= qq(<a href="/_main/tag-$device-v-$enctagname2.html">$tagname2</a> ); }

	}

close($filehandle3);

	# キーチェック
	if($key eq "close" || $key eq "lock"){ &error("この記事にはタグを登録できません。"); }

	# 追加する行
	if($type =~ /make/){ $line2 = qq(1<>$tagname<>$server_domain<>\n) . $line2; $i++; }

	# トップデータを追加（既存のタグの場合）
	if($top){ $line2 = qq($key<>$i<>\n) . $line2; }

	# トップデータを追加（新規登録の場合）
	else{ $line2 = qq(1<>$i<>\n) . $line2; }

	# 整形 ( 記事内のタグ )
	if($type =~ /VIEW/){

			if($type =~ /THREAD/){
	#if($line1 eq "" && $thread_key ne "3"){ $line1 = qq(タグはまだありません。<a href="$in{'no'}_data.html">記事データ</a>から登録してください。); } 
			}

			# 整形
			if($line1){
					if($admin_mode){ $taglink = qq(<a href="$script?mode=view&amp;no=$in{'no'}&amp;r=data">タグ</a> ： ); }
					else{ $taglink = qq(<a href="$in{'no'}_data.html">タグ</a> ： ); }
			}

			# 整形
			if($line1){
				my($tagsearch_form) = &get_tagsearch_form("THREAD");
					if($type =~ /THREAD/){ $line1 = qq($taglink$line1); }
			}
			else{
				my($tagsearch_form) = &get_tagsearch_form("THREAD");
					if($type =~ /THREAD/){ $line1 = qq($taglink); }
			}
	}

# フォーム整形
if($admin_mode && $line1 && $type =~ /FORM/){
$line1 = qq(
<form action="$mainscript" method="post"$sikibetu>
<div>
<input type="hidden" name="mode" value="tag-delete">
<input type="hidden" name="bbs-no" value="$moto-$no">
<input type="hidden" name="place" value="thread">
$line1
<input type="submit" name="submit" value="タグを削除する">
</div>
</form>
);
}

	# 「記事タグ」ファイルを更新
	if($type =~ /RENEW/ && ($type =~ /(make|edit)/ || ($type =~ /(delete)/ && $delete_hit)) ){
		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory1);
		# ファイル更新
		Mebius::Fileout(undef,$file1,$line2);
	}

# 「記事タグ」ファイルを削除
if($type =~ /vanish/){ unlink($file1); }

# リターン
return($top,$delete_hit,$line1,$i,$sub,$posthandle);

}


#-----------------------------------------------------------
# タグ検索フォーム
#-----------------------------------------------------------
sub get_tagsearch_form{

# 宣言
my($type) = @_;
my($line,$submode2);

	# 定義
	if($main::kflag){ $submode2 = "k"; }
	else{ $submode2 = "p"; }

	# フォーカスを当てる
	if($type =~ /FOCUS/){
$main::body_javascript = qq( onload="document.TAGSEARCH.word.focus()");
	}

	# CSS定義（スレッド表示）
	if($type =~ /THREAD/){
$main::css_text .= qq(
form.tagsearch{float:right;text-align:right;margin:auto;vertical-align:top;}
input.tagsearch_input{width:10em;border:color:#044;}
);
	}

# フォーム内容を定義
$line = qq(
<form action="$main::main_url" name="TAGSEARCH" id="TAGSEARCH" class="tagsearch inline">
<div class="inline">
<input type="hidden" name="mode" value="newtag-$submode2-1">
<input type="text" name="word" value="$main::in{'word'}" class="tagsearch_input">
<input type="submit" value="タグ検索">
</div>
</form>
);

# リターン
return($line);
}



1;
