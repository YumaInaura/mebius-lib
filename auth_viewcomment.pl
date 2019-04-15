
package main;

#-----------------------------------------------------------
# 伝言板を閲覧
#-----------------------------------------------------------
sub auth_view_comment{

# 宣言
my($select_year,$index,$account);
local($file);

# CSS定義
$css_text .= qq(
.ctextarea{width:95%;height:35px;}
.cbottun{margin-top:0.5em;}
.clog{font-size:90%;}
.lic{margin-bottom:0.3em;line-height:1.25em;}
.deleted{font-size:90%;color:#f00;}
a.me:link{color:#f00;}
a.me:visited{color:#f40;}
th{text-align:left;padding:0.5em 1.0em 0.5em 0.0em;}
td{padding:0.2em 1.0em 0.5em 0.0em;line-height:1.4em;vertical-align:top;}
input.comment{width:12em;}
);


# 汚染チェック
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# アカウントを開く
(%account) = &Mebius::Auth::File("Option",$file);

# アカウント名
my $viewaccount = $account{'file'};
if($account{'file'} eq "none"){ $viewaccount = "****"; }

# 非表示設定の場合
if($account{'ocomment'} eq "3" && !$myadmin_flag){ &error("このメンバーの伝言板は非表\示設定されています。","401 Unauthorized"); }

# ユーザー色指定
#if($account{'color1'}){ $css_text .= qq(h2{background-color:#$account{'color1'};border-color:#$account{'color1'};}); }

# ナビ
my $link2 = "${auth_url}${file}/";
if($aurl_mode){ ($link2) = &aurl($link2); }
$navi .= qq(<a href="$link2">このメンバーのプロフィールへ戻る</a>);

# 年度切り替えリンク
my($index) .= &auth_viewcomment_get_yearlinks("",$file,%account);

# 検索フォーム
my($searchform) = &auth_viewcomment_get_form();

# マイメビ状態を取得

# 伝言内容を取得
my($comments_line,$resform) = &view_auth_comment("Index-view",$file,$fookyear,undef,%account);

# タイトル定義
$year_title = qq( ( $fookyear年 ) ) if($submode2);
$sub_title = "$account{'name'}の伝言板 $year_title";
$head_link3 = qq(&gt; <a href="$auth_url$account{'file'}/">$account{'name'}</a>);
$head_link4 = qq(&gt; 伝言板);

if($in{'word'} ne ""){ $sub_title = "”$in{'word'}で検索 - $account{'name'}の伝言板 $year_title"; }


#HTML
&header();

print qq(
<div class="body1">
$footer_link
<h1$kfontsize_h1>伝言板 $year_title : $account{'name'} - $viewaccount</h1>
$navi
$index	
$searchform
<h2 id="COMMENT-INPUT"$kfontsize_h2>投稿</h2>
$resform
$comments_line
<br$xclose>
$footer_link2
</div>
);

# フッタ
&footer();

}

#-----------------------------------------------------------
# 年度切り替えリンクを取得
#-----------------------------------------------------------
sub auth_viewcomment_get_yearlinks{

my($type,$file,%account) = @_;
my($index);
our($xclose);

# 整形
if($submode2){ $index .= qq( <a href="$auth_url$file/viewcomment">最近</a> );}
else{ $index .= qq( <span class="red">最近</span> ); }

# コメントインデックスを開く
open(COMMENT_INDEX_IN,"${int_dir}_id/$file/comments/${file}_index_comment.cgi");
	while(<COMMENT_INDEX_IN>){
	chomp;
	my($year,$month) = split(/<>/);

	my $link = qq($auth_url$file/viewcomment-$year);
	if($aurl_mode){ ($link) = &aurl($link); }

	if($year eq $submode2){
		$fookyear = $year;
		$index .= qq( <span class="red">$year年</span> );
		$select_year .= qq( <input type="radio" name="mode" value="viewcomment-$year" checked$xclose>$year年);
	}
	else{
		$index .= qq( <a href="$link">$year年</a> );
		$select_year .= qq( <input type="radio" name="mode" value="viewcomment-$year"$xclose>$year年);
	}


	}
close(COMMENT_INDEX_IN);

# インデックス整形
if($index ne ""){ $index = qq(　　期間 ： $index); }

return($index);

}


#-----------------------------------------------------------
# 検索フォーム
#-----------------------------------------------------------
sub auth_viewcomment_get_form{

# 宣言
my($line);
our($xclose,$kfontsize_h2);

my $checked1 = qq( checked) if(!$fookyear);

$line = qq(
<h2 id="COMMENT-SEARCH"$kfontsize_h2>検索</h2>
<form action="$script">
<div>
<input type="hidden" name="account" value="$file"$xclose>
<input type="text" name="word" value="$in{'word'}" class="comment"$xclose>
<input type="submit" value="伝言板から検索する"$xclose>
<input type="radio" name="mode" value="viewcomment"$checked1$xclose>最近
$select_year
<span class="guide">※筆名、アカウント名、コメント内容から検索します。</span>
</div>
</form>

);

# リターン
return($line);

}



#──────────────────────────────
# 伝言板
#──────────────────────────────
sub view_auth_comment{

# 局所化
my($type,$file,$year,$maxview,%account) = @_;
my($i,$hit,$file,$stop,$form,$flow_flag,$comment_handler,@years,$input_years,$control_flag,$text);
our($idcheck,$kflag,$xclose,$kfontsize_h2);

# 設定
if(!$maxview){ $maxview = 500; }
if($submode3 eq "all"){ $maxview = 5000; }

# CSS定義
$css_text .= qq(
h2#COMMENT,h2#COMMENT-INPUT,#COMMENT-SEARCH{background:#ff9;border-color:#fc7;}
strong.alert{font-size:90%;color:#f00;}
div.dcm{word-break:break-word;width:40em;}
table.comment{font-size:95%;width:100%;}
th.comment-date{width:20em;text-align:left;color:#f00;}
th.comment-name{width:25em;text-align:left;}
th.comment-comment{text-align:left;}
th.comment-no{text-align:left;}
tr.shadow{background:#eee;}
tr.deleted{background:#fee;color:#999;}
div.comment-next{margin-top:0.5em;text-align:right;}
div.control{text-align:right;}
div.control_submit{text-align:right;margin:0.5em 0em;}
);
if($psp_access){ $css_text .= qq(div.dcm{width:20em !important;}); }

# 汚染チェック
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# ファイル切り替え
my $open = "${int_dir}_id/$file/comments/${file}_comment.cgi";
if($year){ $open = "${int_dir}_id/$file/comments/${file}_${year}_comment.cgi"; }

# コメントを開く
open($comment_handler,"$open");
my $top = <$comment_handler> if(!$year); chomp $top;

	# ファイルを展開
	while(<$comment_handler>){

		# 局所化
		my($viewres,$control_box,$trclass,$class);

		# ラウンドカウンタ
		$i++;

		if($hit >= $maxview){ $flow_flag = 1; last; }
		my($key,$rgtime,$account,$name,$trip,$id,$comment,$dates,$xip,$res,$deleter,$control_handle2,$res_concept2) = split(/<>/,$_);
		my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);

		# 時刻表示を整形
		my($viewdate) = sprintf("%04d/%02d/%02d %02d:%02d", $year,$month,$day,$hour,$min);

		# ワード検索
		if($in{'word'} ne "" && ($account !~ /\Q$in{'word'}\E/ && $comment !~ /\Q$in{'word'}\E/ && $name !~ /\Q$in{'word'}\E/) ){ next; }

		my $link = qq(/_auth/$account/);
		if($aurl_mode){ ($link) = &aurl($link); }

		if($type =~ /Index-view/){ $comment =~ s/(<br>){2,}/<br>/g; }
		else{ $comment =~ s/<br>/ /g; }

		($comment) = &auth_auto_link($comment);
		if($res && $res !~ /\D/){ $viewres = qq(No.$res); }

				# ▼コメント操作ボックスを定義
				if($idcheck && ($myadmin_flag || $submode1 eq "viewcomment")){

						# 削除ボックス ( 一般用 )
						if($key eq "1" && ($file eq $pmfile || $account eq $pmfile) && !$myadmin_flag){
							$control_box .= qq( <input type="checkbox" name="rgtime$rgtime" value="delete"$xclose> コメントを削除);
						}

						# 罰削除ボックス ( 管理用 )
						if($key eq "1" && $myadmin_flag){
							$control_box .= qq( <input type="radio" name="rgtime$rgtime" value="penalty" id="penalty$res"$xclose><label for="penalty$res" class="red">罰削除</label>);
						}

						# 削除ボックス ( 管理用 )
						if($key eq "1" && $myadmin_flag){
							$control_box .= qq( <input type="radio" name="rgtime$rgtime" value="delete" id="delete$res"$xclose><label for="delete$res">削除</label>);
						}

						# 復活ボックス
						if($key ne "1" && $myadmin_flag){
							$control_box .= qq( <input type="radio" name="rgtime$rgtime" value="revive" id="revive$res"$xclose><label for="revive$res" class="blue">復活</label>);
						}

						# 操作ボックスの整形（管理用）
						if($control_box && $myadmin_flag){
							$control_box = qq( <input type="radio" name="rgtime$rgtime" value="" id="none$res"$main::checked$xclose><label for="none$res">未選択</label>$control_box);
						}

						# 操作ボックスの整形（共通）
						if($control_box){
							$control_flag = 1;
							$control_box = qq(<br$main::xclose><div class="control">$control_box</div>);
						}

				}

			# 削除済みの場合
			if($key ne "1"){
				my($deleted_text);
				if($key eq "2"){ $deleted_text = qq(【アカウント主削除】); }
				elsif($key eq "3"){ $deleted_text = qq(【投稿主削除】); }
				elsif($key eq "4"){ $deleted_text = qq(【管理者削除】 $deleter); }

				if($myadmin_flag){ $comment = qq(<span class="deleted">$comment $deleted_text $res_concept2</span>); }
				else{ $comment = qq(<span class="deleted">$deleted_text</span>); }

			}

				# 行の表示スタイルを定義
				if($account eq $file){ $class = qq( class="me"); }
				if($key ne "1" && $myadmin_flag){ $trclass = qq( class="deleted"); }
				elsif($i % 2 == 0){ $trclass = qq( class="shadow"); }

				# 表示行を定義（携帯）
				if($kflag || $psp_access){
					$comments .= qq(<li id="C$res"$trclass><a href="$link"$class>$name - $account</a>);
					$comments .= qq( ( <a href="$link#COMMENT">返信</a> ) $comment $del);
					$comments .= qq( $viewdate - $viewres$control_box</li>);
				}

				# 表示行を定義（ＰＣ）
				else{
					$comments .= qq(<tr id="C$res"$trclass><td><a href="$link"$class>$name - $account</a>);
					$comments .= qq( ( <a href="$link#COMMENT">返信</a> )</td><td><div class="dcm">$comment $del</div></td>);
					$comments .= qq(<td>$viewdate - $viewres$control_box</td></tr>);
				}

		# ヒットカウンタ
		$hit++;

	}

close($comment_handler);

# 見出し定義
my $h2 = qq(<h2 id="COMMENT"$kfontsize_h2>伝言板</h2>);
if($type =~ /PROF/ && $flow_flag){ $h2 = qq(<h2 id="COMMENT"$kfontsize_h2><a href="viewcomment#COMMENT">伝言板</a></h2>); }

	# コメント部分整形
	if($comments){
		if($kflag){
			$comments = qq($h2\n<ul>$comments</ul>);
		}
		else{
$comments = qq(
$h2
<table summary="伝言一覧" class="comment">
<tr><th class="comment-name">筆名</th><th class="comment-comment">伝言</th><th class="comment-date">時刻</th></tr>\n
$comments
</table>
);
		}
	}
	else{ $comments = $h2; }

	# 続き
	if($year && $type !~ /PROF/ && $flow_flag){ $comments = qq($comments<a href="./viewcomment-$year-all">続き</a>); }

	# コメント可否の判定
	if($account{'let_flag'}){ $form .= qq(▼$account{'let_flag'}); $stop = 1; }
	elsif($account{'key'} eq "2"){ $form .= qq(▼アカウントがロック中のため書き込めません<br$xclose>); $stop = 1; }
	elsif($account{'friend_status_to'} eq "deny"){ $form .= qq(▼禁止設定中のためコメントできません<br$xclose>); $stop = 1; }
	elsif($account{'ocomment'} eq "0"){ $form .= qq(▼アカウント主 ( $file ) だけがコメントできます<br$xclose>); if(!$account{'myprof_flag'}){ $stop = 1; } }
	elsif($account{'ocomment'} eq "2"){ $form .= qq(▼$friend_tagだけがコメントできます<br$xclose>); if($account{'friend_status_to'} ne "friend" && !$account{'myprof_flag'}){ $stop = 1; }  }

	# ログイン関係
	if(!$idcheck){ $form = qq(▼コメントするには<a href="$auth_url?backurl=$selfurl_enc">ログイン（または新規登録）</a>してください。<br$xclose>); $stop = 1; }
	elsif($birdflag){ $form = qq(▼コメントするには<a href="$auth_url$pmfile/#EDIT">あなたの筆名</a>を設定してください。<br$xclose>); $stop = 1; }

# ＨＴＭＬ最終出力定義
$form .= qq(▼非公開 - あなた以外には見えません ) if($account{'ocomment'} eq "3");


	# 待ち時間表示
	if($main::time < $main::myaccount{'next_comment_time'}){
		my($next_splittime) = &Mebius::SplitTime(undef,$main::myaccount{'next_comment_time'}-$main::time);
		$form .= qq( ▼現在チャージ時間中です。あと$next_splittimeで書き込めます。);
	}

	# 管理者の場合
	if($myadmin_flag){ $stop = ""; }

	# コメントフォームを通常表示
	if($main::stop_mode =~ /SNS/){
		$form .= qq(<div><br$main::xclose><span class="alert">現在、SNS全体で投稿停止中です。</span></div>);
	}
	elsif(!$stop){
$form .= <<"EOM";
<form action="$action" method="post" class="pform"$sikibetu>
<div>
<textarea name="comment" class="ctextarea" cols="25" rows="5"></textarea>
<br$xclose><input type="submit" value="この内容で伝言する"$xclose>
<input type="hidden" name="mode" value="comment"$xclose>
<input type="hidden" name="account" value="$file"$xclose>
<strong class="alert">書き込むと 接続データ ( $addr ) がサーバー内部に記録され、 <a href="${adir}aview-allcomment.html">新着伝言</a> も更新されます。 　</strong>
<span class="guide">（全角$max_msg_comment文字まで）。</span>
</div>
</form>
EOM
	}

	# コメント操作ボタン
	if($control_flag){

		# 局所化
		my($method);
		our($backurl_input);

		# メソッド定義
		#if($alocal_mode){ $method = "get"; }
		#else{ $method = "post"; }
		$method = "post";

		$comments = qq(
		<form action="$auth_url" method="$method"$sikibetu>
		<div>
		$comments
		<input type="hidden" name="mode" value="comdel"$xclose>
		<input type="hidden" name="account" value="$file"$xclose>
		<input type="hidden" name="year" value="$submode2"$xclose>
		<input type="hidden" name="thismode" value="$mode"$xclose>
		$input_years 
		$backurl_input
		<div class="control_submit">
		<input type="submit" value="コメント操作を実行する"$xclose>
		</div>
		</div>
		</form>
		);
	}

	# 整形
	if($type =~ /PROF/){
$comments = qq(
$comments
<div class="comment-next">
<a href="viewcomment#COMMENT">→続きのメッセージ</a>
</div>
);
	}

return($comments,$form);

}

1;
