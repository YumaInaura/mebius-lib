
use strict;

#-----------------------------------------------------------
# 投稿判定
#-----------------------------------------------------------
sub check_regist_allcheck{

# 宣言
my($filehandle1,$viewfile,$file_selects,$line,$line2);
my($file,$i,$page_list,$dirhandle1,@filelist1,@filelist2);
my($open_directory);

# 開くディレクトリを定義
if($main::in{'directory'} =~ /echeck([0-9]+)/){ $open_directory = "${main::int_dir}_echeck/${1}_echeck/"; }
else{ $open_directory = "./"; }

	# 現在のファイル選択内容を定義
	if($main::in{'file'}){ $viewfile = $main::in{'file'}; }
	else{ $viewfile = $main::in{'viewfile'}; }

	# ファイル一覧を取得 ( .log 拡張子 )
	opendir($dirhandle1,$open_directory);
	@filelist1 = grep(/([a-zA-Z0-9_\-]+)\.log/,readdir($dirhandle1));
	close $dirhandle1;

	# ファイル一覧を取得 ( .cgi 拡張子 )
	opendir($dirhandle1,$open_directory);
	@filelist2 = grep(/([0-9]+)\.cgi/,readdir($dirhandle1));
	close $dirhandle1;
	push(@filelist1,@filelist2);

	# リストを展開
	foreach $file (@filelist1){

		# 汚染チェック、開かないファイル名を定義
		if($file !~ /^([0-9a-zA-Z_\-]+)\.(log|cgi)$/){ next; }

		# セレクトボックスを定義
		if($file =~ /\.log$/){
			my($file_selects_selected);
			if($viewfile eq $file){ $file_selects_selected = $main::selected; }
			$file_selects .= qq(<option value="$file"$file_selects_selected>$file</option>\n);
		}

		# ページ切り替えリンクを定義
		my($style_page_list);
		if($file =~ /\.cgi$/){ $style_page_list = qq( style="color:#080";); }
		if($file eq $viewfile){ $page_list .= qq(<span$style_page_list>$file</span> ); }
		else{ $page_list .= qq(<a href="?viewfile=$file&amp;directory=$main::in{'directory'}"$style_page_list>$file</a> ); }

	}

# スレッドを開く		
my($line) = &get_thread_allregist_check("",$open_directory,$viewfile);

# セレクトボックスの整形
$file_selects = qq(<select name="file">$file_selects</select>);

	# 変換行の整形
	if($line2){
	$line2 =~ s/</&lt;/g;
	$line2 =~ s/>/&gt;/g;
	$line2 =~ s/\n/<br>/g;
	$line2 = qq(<hr>&lt;&gt;&lt;&gt;&lt;&gt;$i&lt;&gt;<br>$line2<hr>);
	}

# HTML
print "Content-type:text/html\n\n";

print qq(<html lang="ja">
<meta http-equiv="content-type" content="text/html; charset=shift_jis"> 
<head>
<style type="text/css">
<!--
table{font-size:100%;margin:1em 0em 0em 0em;border:solid 1px #555;padding:0.5em 1em;color:#333;}
body{margin:1em 1em;}
h3{font-size:160%;padding:0.15em 0.3em;background:#fd0;}
-->
</style>
<title>一斉判定</title>
</head>);

print qq(
<body>
<h1>一斉判定</h1>

<h2>フォーム</h2>
<form action="allregistcheck.cgi" method="post">
筆名 <input type="text" name="handle" value=""><br>
<textarea name="comment" style="width:50%;height:75px;"></textarea>
<br>
ファイルタイプ：
$file_selects
<!-- <input type="checkbox" name="post_place" value="top" checked> 行頭に追加 -->
　
判定タイプ：
<input type="radio" name="comment_type" value="bad" checked> 悪(行頭に追加)
<input type="radio" name="comment_type" value="good"> 良(行末に追加)
<input type="hidden" name="mode" value="put_comment">
　
<input type="submit" value="この内容で送信する">
</form>

<h2>リスト</h2>
<div style="font-size:120%;line-height:1.2em;word-spacing:0.5em;">
$page_list
</div>
$line2

$line
</body>);


}


#-----------------------------------------------------------
# スレッドを開く
#-----------------------------------------------------------
sub get_thread_allregist_check{

# 宣言
my($type,$directory,$file) = @_;
my($line,$line2,$i,$filehandle1,$time,$error_num,$alert_num,$allow_num,$allallow_num);
my($error_type_num,$allow_type_num);
($time) = (time);

# ファイル定義
$file =~ s/[^a-zA-Z0-9\.]//g;
if($file eq ""){ return; }

	# ファイルを開く
	open($filehandle1,"$directory$file");

	# トップデータを分解
	my $top1 = <$filehandle1>; chomp $top1;
	my(undef,undef,undef,$tres) = split(/<>/,$top1);

		# ファイルを展開
		while(<$filehandle1>){

		# 局所化
		my($error_flag,$alert_flag,$style1,$style2,$h4);

		# ラウンドカウンタ
		$i++;

		# この行を分解
		chomp;
	my($num2,$number2,$handle2,$enctrip2,$comment2,$date2,$host2,$encid2,$color2,$agent2,$user2,$deleted2,$account2,$comment_type2,$key2,$time2) = split(/<>/);

		# 旧データ変換
		if($handle2 =~ /^([0-9]+)$/){
		my($key3,$comment3,$time3,$comment_type3,$handle3) = split(/<>/);
		$line2 .= qq($i<><>$handle3<><>$comment3<><><><><><><><><>$comment_type3<>$key3<>$time3<>\n);
		}

		# キーが無い場合は回避
		if($key2 eq "0"){ next; }

		# 基本変換
		($comment2) = &base_change($comment2);
		($handle2) = &base_change($handle2);

		# 性的内容の判定
		my($error_flag_sex,$sexnum,$sex_max) = &sex_check("Localtest",$comment2);
		if($error_flag_sex){ $sexnum = qq(<strong style="color:#f00;">$sexnum</strong>); $error_flag = 1; }

		# マナー違反の判定
		my($error_flag_evil,$evilnum,$evil_max) = &evil_check("Localtest",$comment2);
		if($error_flag_evil){ $evilnum = qq(<strong style="color:#f00;">$evilnum</strong>); $error_flag = 1; }

		# チェーン判定
		my($error_flag_chain,$chainnum,$chain_max) = &chain_check("Localtest",$comment2);
		if($error_flag_chain){ $chainnum = qq(<strong style="color:#f00;">$chainnum</strong>); $error_flag = 1; }

		# デコレーション判定
		my($error_flag_deco,$deconum,$decoper,$deco_max) = &deco_check("Localtest",$comment2);
		if($error_flag_deco){ $decoper = qq(<strong style="color:#f00;">$decoper</strong>); $error_flag = 1; }

		# スペース判定
		my($error_flag_space,$spacenum,$space_max) = &space_check("Localtest",$comment2);
		if($error_flag_space){ $spacenum = qq(<strong style="color:#f00;">$spacenum</strong>); $error_flag = 1; }

		# 個人情報判定
		my($error_flag_private) = &private_check("Localtest",$comment2);
		if($error_flag_private){ $error_flag_private = qq(<strong style="color:#f00;">$error_flag_private</span>); $alert_flag = 1; }

		# 筆名判定
		my($error_flag_handle);
		if($handle2){
			($handle2,$error_flag_handle) = &name_check($handle2);
			if($error_flag_handle){ $error_flag_handle = qq(<strong style="color:#f00;">$error_flag_handle</strong>); $error_flag = 1; }
		}
		if($handle2){ $handle2 = qq(筆名： $handle2 <br>); }

		# 投稿タイプ”悪”の場合
		if($comment_type2 eq "bad"){
			$h4 = qq(<h4 id="S$num2" style="background:#fbb;padding:0.5em;">悪 ( $num2 )</h4>);
			$style2 = qq( style="background:#fee;");
			$error_type_num++;
		}

		# 投稿タイプ”良”の場合
		elsif($comment_type2 eq "good"){
			$h4 = qq(<h4 id="S$num2"style="background:#bbf;padding:0.5em;">良 ( $num2 )</h4>);
			$style2 = qq( style="background:#eef;");
			$allow_type_num++;
		}

		# 投稿タイプ”普通”の場合
		else{
			$h4 = qq(<h4 id="S$num2"style="background:#fe0;padding:0.5em;">普通 ( $num2 )</h4>);
		}

		# エラーがあれば背景色を変える
		if($error_flag){ $style1 = qq( style="color:#f00;"); $error_num++; }
		elsif($alert_flag){ $style1 = qq( style="color:#070;"); $alert_num++; $allallow_num++; }
		else{ $allow_num++; $allallow_num++; }
		
		# 表示行を定義
		$line .= qq(
		$h4
		<div$style2><div$style1>$handle2$comment2</div>
		<table>
		<tr><td>Sex</td><td style="text-align:right;">$sexnum / $sex_max</td></tr>
		<tr><td>Evil</td><td style="text-align:right;">$evilnum / $evil_max</td></tr>
		<tr><td>Chain</td><td style="text-align:right;">$chainnum / $chain_max</td></tr>
		<tr><td>Space</td><td style="text-align:right;">$spacenum % / $space_max %</td></tr>
		<tr><td>Deco</td><td style="text-align:right;">$decoper % / $deco_max %</td></tr>
		<tr><td>Private</td><td>$error_flag_private</td></tr>
		<tr><td>Handle</td><td>$error_flag_handle</td></tr>
		</table>
		<div style="text-align:right;">
		<a href="?viewfile=$file&amp;time=$time#S$num2">更新</a>
		<a href="?mode=delete_comment&amp;file=$file&amp;delete_time=$time2&amp;delete_num=$num2">削除</a>
		</div>
		</div>
		);

		}

		# ファイルを閉じる
		close($filehandle1);

# 表示行を整形する
if($line){
$line = qq(
<h3>$file</h3>
<ul>
<li>拒否： <span style="color:#f00;">$error_num</span> / $error_type_num</li>
<li>許可： <span style="color:#00f;">$allallow_num</span> / $allow_type_num</li>
<li>警告： <span style="color:#070;">$alert_num</span></li>
</ul>
$line
);
}

# リターン
return($line);

}

#-----------------------------------------------------------
# コメントの登録
#-----------------------------------------------------------
sub renew_comment_data_all{

# 宣言
my($type,$file,$newcomment,$newhandle,$delete_num) = @_;
my($delete_time,$newline);
if($type =~ /Delete/){ ($delete_time) = @_[2]; } 
my($time,@line) = (time);
my($filehandle1,$bkupfile,$new_comment_type);

# ファイル定義
$file =~ s/[^a-zA-z0-9\.]//g;
if($file eq ""){ &main::error("ファイル名が不正です。"); }
$bkupfile = "./backup_allregist/$file.$time";

	# コメントタイプを定義
	if($main::in{'comment_type'} eq "bad"){ $new_comment_type = "bad"; }
	elsif($main::in{'comment_type'} eq "good"){ $new_comment_type = "good"; }
	else{ $new_comment_type = "normal"; }

	# ファイルを開く
	open($filehandle1,"<$file");

		# ファイルロック
		flock($filehandle1,1);
		
		# トップデータを分解、追加
		my $top1 = <$filehandle1>; chomp $top1;
		my(undef,undef,undef,$tres) = split(/<>/,$top1);
		if($type =~ /Renew/){ $tres++; }

		# ファイルを展開
		while(<$filehandle1>){
		chomp;
		my($num2,$number2,$handle2,$enctrip2,$comment2,$date2,$host2,$encid2,$color2,$agent2,$user2,$deleted2,$account2,$comment_type2,$key2,$time2) = split(/<>/);
			if($type =~ /Delete/ && $time2 && $time2 eq $delete_time){ $key2 = "0"; }
			if($type =~ /Delete/ && $num2 ne "" && !$time2 &&  $num2 eq $delete_num){ $key2 = "0"; }
	push(@line,"$num2<>$number2<>$handle2<>$enctrip2<>$comment2<>$date2<>$host2<>$encid2<>$color2<>$agent2<>$user2<>$deleted2<>$account2<>$comment_type2<>$key2<>$time2<>\n");
		}
	close($filehandle1);

	# 新しく追加する行
	$newline .= qq($tres<><>$newhandle<><>$newcomment<>$main::date<>$main::host<><><>$main::agent<><><>$main::pmfile<>$new_comment_type<>1<>$main::time<>\n);

	# 新しく追加する行 （行頭に追加）
	if($type =~ /Renew/ && $main::in{'comment_type'} eq "bad"){ unshift(@line,$newline); }

	# 新しく追加する行 （行末に追加)
	elsif($type =~ /Renew/ && $main::in{'comment_type'} eq "good"){ push(@line,$newline); }
	
	# トップデータを追加
	if($type =~ /(Renew|Delete)/){ unshift(@line,"<><><>$tres<>\n"); }

# ファイルを追記
&Mebius::Fileout("Can-Zero",$file,@line);

# バックアップ
if(rand(10) < 1){ &Mebius::Fileout("Can-Zero",$bkupfile,@line); }

# HTMLを表示
&check_regist_allcheck();

}

1;

