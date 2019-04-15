
use Mebius::BBS;
package main;

#-----------------------------------------------------------
# 記事データを閲覧
#-----------------------------------------------------------
sub bbs_view_data{

# いいね！理由
@support_reason = (
'19=良いコミュニケーション',
'2=面白い、興味をそそられる',
'13=優れたマナー',
'17=落ち着く、安らぐ',
'9=知的、価値が高い',
'12=配慮がある、やさしい',
'3=役立つ情報',
'6=秀逸、卓越している',
'7=刺激的、スリルがある',
'1=真剣、真面目',
'16=熱い、情熱的',
'10=奇妙、個性的',
'15=内容への共感',
'18=独自の哲学、ポリシー',
'11=優れた日本語',
'5=優れた議論',
'4=優れた作品',
'20=親しき仲にも身内いいね！',
'8=更新を希望する',
'14=その他'
);

# 汚染チェック
$in{'no'} =~ s/\D//g;

# 携帯版の場合
if($mode eq "kview" || $in{'k'}){ &kget_items(); }


# アクセス振り分け ( デスクトップ版→モバイル版 )
if($mode eq "view"){
#if($device_type eq "mobile"){ &divide($divide_url,"mobile"); }
}

# アクセス振り分け ( モバイル版→デスクトップ版 )
if($mode eq "kview"){
#if($device_type eq "desktop"){ &divide($divide_url,"desktop"); }
}


# 広告 (現在は未使用)
$ads_data = qq(
<h2 class="bgbcolor"$kstyle_h2>スポンサードリンク</h2>
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
if($alocal_mode || $admin_mode || $kflag){ $ads_data = ""; }

	# URL定義
	if($admin_mode){
		$topic_url = "$script?mode=$submode1&amp;no=$in{'no'}";
		$data_url = "${jak_url}$script?mode=$submode1&no=$in{'no'}&r=data";}
	else{
		$topic_url = "$in{'no'}.html";
		$data_url = "http://$server_domain/_$moto/$in{'no'}_data.html";
	}

# モード振り分け
&viewdata_editform();

}

#-----------------------------------------------------------
# 編集ページ
#-----------------------------------------------------------

sub viewdata_editform{

# 局所化
my($alert,$line_data,$tag_line,$kr_line);
my($use_paint_checked,%edit_history,$print,@BCL);
our($concept,$css_text,$admin_mode,$postflag);

# CSS定義
my $css_text .= qq(
h1{margin-top:0em;}
h2{padding:0.3em 0.6em;font-size:120%;}
li{line-height:1.5em;}
ul{margin:1em 0em;}
i{font-size:80%;margin-right:0.3em;}
input.subject{width:20em;}
td{padding:0.3em 0.5em 0.3em 0.3em;font-size:90%;}
span.del{color:#f00;font-size:90%;}
table,th,tr,td{border-style:none;text-align:left;}
table{margin:1em 0em;}
div.comment{width:30em;word-wrap;break-word;}
h2.tag{background:#bdd;}
h2.support{background:#fbb;}
h2.kr{background:#bbf;}
);

#table,th,tr,td{border-style:none;}

# 汚染チェック
$in{'no'} =~ s/\D//g;
if($in{'no'} eq ""){ &error("記事を指定してください。"); }

my($thread) = Mebius::BBS::thread({ ReturnRef => 1 , FileCheckError => 1  },$realmoto,$in{'no'});
chomp(my $top1 = $thread->{'all_line'}->[0]);
our($no,$sub,$res,$key,$res_pwd,$t_res,$d_delman,$d_password,$dd1,$sexvio,$dd3,$dd4,$memo_editor,$memo_body,$dd7,$dd8,$juufuku_com,$posttime) = split(/<>/, $top1);

	# 削除済み、ロック中の記事
	#if($key eq "4" || $key eq "6" || $key eq "7"){ &error("削除済み、またはロック中の記事です。"); }
	if($thread->{'keylevel'} <= 0){ &error("削除済み、またはロック中の記事です。"); }

chomp(my $top2 = $thread->{'all_line'}->[1]);
my($no2,$ranum,$nam,$eml,$com,$dat,$ho,$pw,$url,$mvw,$none,$none,$account) = split(/<>/, $top2);

# 記事主チェック
if($admin_mode || ($pmfile eq $account && $account ne "")) { $mytopic_flag = 1; }

	# 関連記事の編集
	if($in{'type'} eq "kr_edit"){

		# GET送信を禁止
		if(!$postflag){ main::error("GET送信は出来ません。"); }

		# 編集を実行
		require "${int_dir}part_kr.pl";
		my($success_flag) = related_thread("Edit-data",$moto,$in{'no'});

		# 編集エラーの場合
		#if(!$success_flag){ main::error("編集に失敗しました。値は半角数字で正しく入力してください。 ","","","Not-repair"); }

		# リダイレクト
		Mebius::Redirect("","$data_url#KR");

	}

# 関連記事の削除
if($in{'type'} eq "support_delete"){ &viewdata_support_delete(undef,$main::moto,$in{'no'}); }

# 記事名を変更
if($in{'type'} eq "subject_edit"){ &viewdata_subject_edit(undef,$main::moto,$in{'no'}); }

# 関連記事を取得
require "${int_dir}part_kr.pl";
	if($mytopic_flag){ ($kr_line) = related_thread("Index Editor",$moto,$in{'no'}); }
	else{ ($kr_line) = related_thread("Index",$moto,$in{'no'}); }

	# 関連記事を整形
	my ($mytopic_text);
		if($mytopic_flag){ $mytopic_text = qq(記事主はポイントを操作できます。); }

	# 編集用
	if($mytopic_flag && $kr_line){
		$kr_line = qq(
		<form action="$script" method="post"$sikibetu>
		<div>
		$kr_line
		<input type="hidden" name="mode" value="view"$xclose>	
		<input type="hidden" name="moto" value="$moto"$xclose>	
		<input type="hidden" name="no" value="$in{'no'}"$xclose>	
		<input type="hidden" name="r" value="data"$xclose>	
		<input type="hidden" name="type" value="kr_edit"$xclose>	
		<input type="submit" value="ポイントを編集する"$xclose>	
		</div>
		</form>
		);
	}


	# 表示
	if($kr_line){
		$kr_line = qq(
		<h2 class="kr" id="KR"$kstyle_h2>関連リンク</h2>
		<span class="guide">
		$mytopic_text
		ポイントが高いほど優先して表\示され、マイナスだと非表\示になります。
		また、ポイントは利用状況に応じて上下します。
		</span>
		$kr_line);
	}

	if($main::mytopic_flag){
		(%edit_history) = Mebius::BBS::ThreadEditHistory("Get-index",$moto,$in{'no'});
	}

# タグを取得
if($concept !~ /NOT-TAG/){
($tag_line) = &viewdata_get_tags($key,$sub);
}

# いいね！データを取得
my($line_support,$line2_support) = &viewdata_get_support();

# 広告を消す場合
if($res < 10 || $kr_line eq "" || $noads_mode){ $ads_data = ""; }

# 各種データ
$line_data .= qq(レス： $res回 |);
if($t_res && $posttime && $res && $t_res != $posttime){
my($speed) = int( ($res) / ( ($t_res - $posttime) / (24*60*60) ) * 10 ) / 10;
$line_data .= qq( 速度： $speedレス/日 | );
}

# 所属
$line_data .= qq( 所属： <a href="/_$moto/">$title</a> |
ＵＲＬ： <a href="http://$server_domain/_$moto/$in{'no'}.html">http://$server_domain/_$moto/$in{'no'}.html</a>
);

	#if($cnumber && !$admin_mode){ $line_data .= qq( | <a href="$script?mode=mylist&amp;no=$in{'no'}">お気に入り登録</a> ); }

# タイトル定義
my $sub_title = "データ | $sub";
push @BCL , { url => "$in{'no'}.html" , title => $sub };
push @BCL , "データ";

	# 記事名変更フォーム
	if($mytopic_flag && ($key eq "1" || $key eq "5" || $key eq "2" || Mebius->common_admin_judge())){

		# 局所化
		my($sex_input,$vio_input,$sex_checked,$vio_checked);

			# 15禁
			if($chowold >= 15 || $admin_mode){
			if($sexvio eq "1" || $sexvio eq "3"){ $vio_checked = $main::parts{'checked'}; }
				$vio_input = qq(<input type="checkbox" name="vio" value="1" id="vio"$vio_checked$main::xclose><label for="vio">15禁</label>);
			}

			# 18禁
			if($chowold >= 18 || $admin_mode){
			if($sexvio eq "2" || $sexvio eq "3"){ $sex_checked = $main::parts{'checked'}; }
				$sex_input = qq(<input type="checkbox" name="sex" value="1" id="sex"$sex_checked$main::xclose><label for="sex">18禁</label>);
			}

			# おえかき機能のオン/オフ
		#	if($thread_key =~ /Not-use-paint/){ }
		#	else{ $use_paint_checked = $main::parts{'checked'}; }
		#my $use_paint_input = qq(<input type="checkbox" name="use_paint" value="1" id="use_paint"$use_paint_checked$main::xclose><label for="use_paint">お絵かき機\能\を使う</label>);

		# 題名変更フォーム
		$subject_form = qq(
		<h2 class="bgbcolor"$kstyle_h2>記事の編集</h2>
		<form action="$script" method="post"$sikibetu>
		<div>
		<input type="hidden" name="mode" value="view"$xclose>
		<input type="hidden" name="moto" value="$realmoto"$xclose>
		<input type="hidden" name="no" value="$in{'no'}"$xclose>
		<input type="hidden" name="r" value="data"$xclose>
		<input type="hidden" name="type" value="subject_edit"$xclose>
		<label for="sub">題名</label> <input type="text" name="sub" value="$sub" class="subject" id="sub"$xclose>
		$vio_input
		$sex_input
		$use_paint_input
		<input type="submit" value="この内容で変更する"$xclose> <span class="guide">*変更履歴は保存されます。</span>
		</div>
		</form>
		);
	}

# 管理者の場合
if($admin_mode){ $alert = qq(<strong class="red">＊管理者として設定します。</strong><br$xclose><br$xclose>); }


	# HTML （携帯版）
	if($kflag){
		$print = qq(
		<h1$kstyle_h1><a href="$topic_url">$sub</a> | データ</h1>
		$alert
		$line_data
		$subject_form
		$edit_history{'index_line'}
		$tag_line
		$line_support
		$kr_line
		);
	}

	# HTML （デスクトップ版）
	else{
		$print = qq(
		<h1><a href="$topic_url">$sub</a> - データ</h1>
		$alert
		$line_data
		$subject_form
		$edit_history{'index_line'}
		$tag_line
		$line_support
		$line2_support
		$kr_line
		);
	}

Mebius::BBS->print_html_all($print,{ inline_css => $css_text , BCL => \@BCL , Title => $sub_title });

exit;

}



#-----------------------------------------------------------
# いいね！データを取得
#-----------------------------------------------------------
sub viewdata_get_support{

my($line,$i,$ii,$allnum,$line2);

# カテゴリ設定を読み込み
my($init_bbs) = Mebius::BBS::init_bbs_parmanent($moto);

# カウントファイルを開く
open(COUNT_IN,"<","$main::bbs{'data_directory'}_crap_count_${moto}/$in{'no'}_cnt.cgi");
my $top1 = <COUNT_IN>; chomp $top1;
my($count) = split(/<>/,$top1);
if(!$count){ $count = "0"; }
my $top2 = <COUNT_IN>; chomp $top2;

# 旧いいね！データの有無をチェック
foreach(@support_reason){
$i++;
my($num,$reason) = split(/=/,$_);
foreach ( split(/<>/,$top2) ) {
$ii++;
if($ii == $num && $_) {
$line2 .= qq($reason($_回)\n);
$allnum += $_;
}
}
$ii = 0;
}

# 旧データが存在する場合
if($line2 ne ""){
$line2 = qq(
<br$xclose><br$xclose>
<div>
<strong>いいね！理由 (旧)：</strong>
$line2
</div>
);
}

# データを展開
while(<COUNT_IN>){
chomp;
my($key,$handle,$id,$trip,$comment,$account,$host2,$number,$age2,$lasttime,$date2,$res,$deleter) = split(/<>/);

	if($key eq ""){ next; }
	
	if($key eq "0"){
		if($admin_mode){
				my($deleter,$deldate) = split(/>/,$deleter);
				$comment = qq(<span class="del">削除済み by $deleter $deldate： <del>$comment</del></span>);
		}
		else{ next; }
	}
my $viewname = $handle;
if($trip){ $viewname = "$viewname☆$trip"; }
if($account){ $viewname = qq(<a href="${auth_url}$account/">$viewname</a>); }

if($kflag){ $line .= qq(<li>$viewname ★$id &gt; $comment ( $date2 ) - No.$res); }
else{ $line .= qq(<tr><td>$viewname <i>★$id</i></td><td><div class="comment">$comment</div></td><td>$date2</td><td>No.$res); }

if($key ne "0" && $admin_mode){
$line .= qq( ( <a href="$script?mode=view&amp;no=$in{'no'}&amp;r=data&amp;type=support_delete&amp;res=$res">削除</a> ));
$line .= qq( ( <a href="$script?mode=view&amp;no=$in{'no'}&amp;r=data&amp;type=support_delete&amp;res=$res&amp;penalty=1">罰削除</a> ));
}

	# 投稿情報
	if($admin_mode){
		$line .= qq( / <strong>管理番号： <a href="$mainscript?mode=cdl&amp;file=$number&amp;filetype=number" class="red">$number</strong></a>);

			if($main::admy{'master_flag'}){
					if($age2){ $line .= qq( / <strong>ＵＡ： <a href="$mainscript?mode=cdl&amp;file=$age2&amp;filetype=agent" class="red">$age2</a></strong>); }
				$line .= qq( / <strong>ホスト： <a href="$mainscript?mode=cdl&amp;file=$host2&amp;filetype=host" class="red">$host2</a></strong>);
			}
	}

if($kflag){ $line .= qq(</li>\n); }
else{ $line .= qq(</td></tr>); }

}
close(COUNT_IN);

	# 整形
	if($line eq ""){ $line = qq(コメントはまだありません。<br$xclose><br$xclose>); }
	else{

	if($kflag){ $line = qq(<ul>$line</ul>); }
	else{ $line = qq(<table summary="いいね！コメント">$line</table>); }
	$line .= qq(<span class="guide">※コメントに問題がある場合は<a href="http://mb2.jp/_delete/158.html">削除依頼</a>をお願いします。</span>);
	}



$line = qq(
<h2 class="support"$kstyle_h2>いいね！ ($count)</h2>
$line
);

	# いいね！リンク
	if($main::device{'level'} >= 2){
		$line .= qq(<span class="guide">※コメントを書くには<a href="./$in{'no'}.html">記事</a>に戻っていいね！ボタンを押してください。</span> );
	}

my($tag);
if($kflag){ $tag = "k"; } else{ $tag = "p"; }

$line .= qq( <span class="guide">※<a href="/_main/newsupport-$tag-1.html">いいね！コメントの一覧</a>もあります。</span>);

return($line,$line2);

}

#-----------------------------------------------------------
# タグを取得
#-----------------------------------------------------------
sub viewdata_get_tags{

# 局所化
my($key,$sub) = @_;
my($line,$action,$type);
our($selfurl_enc);

# リターン
if(!$alocal_mode && ($secret_mode || $test_mode)){ return; }

# CSS定義
$css_text .= qq(.tagform{margin:1em 0em;});

# タイプ定義
if($in{'k'}){ $type = " MOBILE"; }

# タグ記事ファイルを開く
require "${int_dir}main_tag.pl";
my($flag,$hit,$tag_line,$tagnum,$tagkey) =  &open_threadtag("VIEW FORM","","",$moto,$in{'no'});

# カテゴリ設定を取り込み
my($init_bbs) = Mebius::BBS::init_bbs_parmanent($moto);

# タグがない場合
if($line eq ""){ $line = qq(タグはまだありません。); }

# タグの表示
$line = qq(
<h2 class="tag" id="TAG"$kstyle_h2>タグ</h2>
<div class="tags">$tag_line</div>
);

# 送信先を定義
$action = $main_url;

# タグ登録フォーム
if($key eq "1" || $key eq "2" || $key eq "3" || $key eq "5" || $admin_mode){

# ログインしている場合
if($idcheck || $adminmode || $main::device{'level'} >= 2){
$line .= qq(
<form action="$action" method="post" class="tagform"$sikibetu>
<div>
<input type="hidden" name="mode" value="tag-make"$xclose>
<input type="hidden" name="bbs-no" value="$moto-$in{'no'}"$xclose>
<input type="text" name="tagname" value=""$xclose>
<input type="submit" value="このタグ名を登録する"$xclose>
 ( <a href="/_main/newtag-p-1.html">→新着タグ</a> )
</div>
</form>
);

if($kflag){ $line .= qq(<div style="font-size:small;">); }

$line .= qq(
<span class="guide">※「$sub」に関連するキーワード（単語）を登録してください。たとえば<strong>「柔道の記事」</strong>であれば<strong>「投げ」「寝技」</strong>などの単語を登録します。 </span><br$xclose>
<span class="alert">※アカウント / 接続データ ( <a href="${auth_url}$pmfile/">$pmfile</a> / $addr ) は記録されます。無関係なタグの登録、嫌がらせ登録、迷惑な登録などはご遠慮ください。\( <a href="http://mb2.jp/_delete/158.html">削除依頼はこちらまで、URLとタグ名を</a> \)</span>
);

if($kflag){ $line .= qq(</div>); }

}
# ログインしていない場合
else{
my($backurl) = "http://$server_domain/_$moto/$in{'no'}_data.html#TAG";
my($backurl_enc) = Mebius::Encode("",$backurl);
$line .= qq(<br$xclose><div>タグを登録するには<a href="${auth_url}?backurl=$selfurl_enc">アカウントにログイン（または新規登録）</a>してください。</div>);
}

}

return($line);

}


use strict;

#-----------------------------------------------------------
# 記事の変更
#-----------------------------------------------------------
sub viewdata_subject_edit{

# 局所化
my($type,$moto,$thread_number) = @_;
my($line,$line_index,$line_backup,$i,$filehandle2,$index_sexvio,$thread_handler);
my(%renew_thread,$allow_edit_flag,$edit_history_text);
our($admin_mode,%in);

# アクセス制限
main::axscheck("Post-only");

# バックアップの最大行数
my $max = 100;

# 各種エラー
if(($in{'sub'} =~ /^(\x81\x40|\s)+$/)||($in{'sub'} eq "")) { &error("題名がありません。"); }
if($in{'sub'} =~ /(<br>|&shy|&nbsp)/) { &error("題名に空白要素があります。"); }
if(length($in{'sub'}) > 25*2 && !$admin_mode) { &error("題名が長すぎます。"); }

# 連続送信を禁止
Mebius::Redun(undef,"Thread-edit",15);

# 記事読み込み
my(%thread) = Mebius::BBS::thread({},$moto,$thread_number);

	# キー判定
	if(!$thread{'mythread_flag'} && !$admin_mode){ main::error("自分の記事ではないため、編集できません。"); }
	if($thread{'keylevel'} < 1 && !$admin_mode){ &error("過去ログ、ロック記事、削除済み記事のタイトルは変更できません。"); }

	# 15禁/18禁チェック状態を変更
	if($in{'vio'} && $in{'sex'}){
		$renew_thread{'sexvio'} = 3;
		$index_sexvio = 9;
	}
	elsif($in{'vio'}){
		$renew_thread{'sexvio'} = 1;
		$index_sexvio = 8;

	}
	elsif($in{'sex'}){
		$renew_thread{'sexvio'} = 2;
	}
	else{
		$renew_thread{'sexvio'} = "";
		$index_sexvio = 1;
	}

	# 変更チェック
	if($thread{'sexvio'} ne $renew_thread{'sexvio'}){
			if($renew_thread{'sexvio'} eq "3" || $renew_thread{'sexvio'} eq "2"){ $edit_history_text .= qq(18禁状態にしました。); }
			elsif($renew_thread{'sexvio'} eq "1"){ $edit_history_text .= qq(15禁状態にしました。); }
			else{ $edit_history_text .= qq(18禁/15禁チェックを解除しました); }
		$allow_edit_flag = 1;
	}

	#if(Mebius::Fillter::basic(u$in{'sub'}))

	# 新しい題名
	$renew_thread{'sub'} = $in{'sub'};
	if($thread{'subject'} ne $renew_thread{'sub'}){
		$allow_edit_flag = 1;
		$edit_history_text .= qq(題名を 【$renew_thread{'sub'}】 に変更しました。);
	}

	# お絵かき機能のオン/オフを変更
	#$thread{'concept'} =~ s/ Not-use-paint//g;
	#if($in{'use_paint'}){ }
	#else{ $renew_thread{'concept'} = qq($thread{'concept'} Not-use-paint); }

	# ロック開始
	if($allow_edit_flag){
		main::lock($moto);
	}

	# スレッド更新
	if($allow_edit_flag){
		Mebius::BBS::thread({ Renew => 1 , select_renew => \%renew_thread },$moto,$thread_number);
	}

	# インデックスを更新
	if($allow_edit_flag){
		open($filehandle2,"+<$main::nowfile") || &error("インデックスが開けません。");
		flock($filehandle2,2);
		my $top_index = <$filehandle2>;
		$line_index .= $top_index;
			while(<$filehandle2>){
				chomp;
				my($no,$sub,$res,$name,$date,$lastname,$key) = split(/<>/);
				if($no eq $thread_number){
					$sub = $renew_thread{'sub'};
					$key = $index_sexvio;
				}
				$line_index .= qq($no<>$sub<>$res<>$name<>$date<>$lastname<>$key<>\n);
			}
		seek($filehandle2,0,0);
		truncate($filehandle2,tell($filehandle2));
		print $filehandle2 $line_index;

		close($filehandle2);

		# パーミッション更新
		Mebius::Chmod(undef,$main::nowfile)
	}


	# バックアップを更新
	if($allow_edit_flag){
		Mebius::Fileout(undef,"${main::int_dir}_backup/subedit_backup.cgi",$line_backup);
	}

	# ロック解除
	if($allow_edit_flag){
		main::unlock($moto);
	}

	# 編集履歴を更新
	if($allow_edit_flag){
		Mebius::BBS::ThreadEditHistory("Renew New-edit",$moto,$thread_number,$edit_history_text);
	}

	# リダイレクト
	Mebius::Redirect("",$main::data_url);

exit;

}


#-----------------------------------------------------------
# いいね！コメントの削除
#-----------------------------------------------------------
sub viewdata_support_delete{

# 局所化
my($type,$moto,$thread_number) = @_;
my(@line,$flag,$top2_flag);

	# 各種エラー
	if($moto =~ /\W/){ main::error("掲示板の指定が正しくありません。"); }
	if($thread_number =~ /\D/){ main::error("記事番号の指定が正しくありません。"); }
	if(!$main::admin_mode){ &error("ページが存在しません。"); }

# ロック開始
main::lock("$thread_number");

# カウントファイルを開く
open(COUNT_IN,"<$main::bbs{'data_directory'}_crap_count_${moto}/${thread_number}_cnt.cgi");

my $top1 = <COUNT_IN>; chomp $top1;
my $top2 = <COUNT_IN>; chomp $top2;

	# ファイルを展開
	while(<COUNT_IN>){

		# 行を分解
		chomp;
		my($key,$handle,$id,$trip,$comment,$account2,$host2,$number2,$age2,$lasttime,$date2,$res,$deleter) = split(/<>/);
		if($key ne "0" && $res eq $main::in{'res'}){

				# ペナルティを与える場合
				if($main::in{'penalty'}){
					Mebius::penalty_file("Cnumber Renew Penalty",$number2,"”$main::sub”のデータ",$comment,"/_$moto/${thread_number}_data.html");
					Mebius::penalty_file("Account Renew Penalty",$account2,"”$main::sub”のデータ",$comment,"/_$moto/${thread_number}_data.html");
					Mebius::penalty_file("Host Renew Penalty",$host2,"”$main::sub”のデータ",$comment,"/_$moto/${thread_number}_data.html");
				}

			$key = 0;
			$deleter = "$main::admy_name>$main::date";
			$flag = 1;
		}
		push(@line,"$key<>$handle<>$id<>$trip<>$comment<>$account2<>$host2<>$number2<>$age2<>$lasttime<>$date2<>$res<>$deleter<>\n");
	}
close(COUNT_IN);

# トップデータ
unshift(@line,"$top2\n");
unshift(@line,"$top1\n");

# 内容がない場合
if(!$flag){ &error("削除する内容がありません。"); }

# カウントファイルを更新
Mebius::Fileout(undef,"$main::bbs{'data_directory'}_crap_count_${moto}/${thread_number}_cnt.cgi",@line);

# ロック解除
main::unlock("$thread_number");

# リダイレクト
Mebius::Redirect("","$main::data_url");

exit;
}

use strict;
package Mebius::BBS;

#-----------------------------------------------------------
# 記事の変更履歴
#-----------------------------------------------------------
sub ThreadEditHistory{

# 線源
my($type,$realmoto,$thread_number) = @_;
my(undef,undef,undef,$new_text,$new_handle) = @_ if($type =~ /New-edit/);
my($edit_handler,@renew_line,%edit,$i,$index_line);

# 汚染チェック
if($realmoto eq "" || $realmoto =~ /\W/){ return(); }
if($thread_number eq "" || $thread_number =~ /\D/){ return(); }

# ファイル/ディレクトリ定義
my $directory1 = "$main::bbs{'data_directory'}_thread_edit_history_${realmoto}/";
my $file = "${directory1}${thread_number}_thread_edit.log";

# ファイルを開く
open($edit_handler,"<$file");

	# ファイルロック
	if($type =~ /Renew/){ flock($edit_handler,1); }

# トップデータを分解
chomp(my $top1 = <$edit_handler>);
($edit{'key'}) = split(/<>/,$top1);

	# 新規編集の場合、ラウンドカウンタを増やす
	if($type =~ /New-edit/){
		$i++;
	}

	# ファイルを展開
	while(<$edit_handler>){

		# ラウンドカウンタ
		$i++;

		# この行を分解
		chomp;
		my($key2,$text2,$account2,$handle2,$cnumber2,$encid2,$host2,$lasttime2,$date2) = split(/<>/);

			# ファイル更新用
			if($type =~ /Renew/ && $i <= 5){
				push(@renew_line,"$key2<>$text2<>$account2<>$handle2<>$cnumber2<>$encid2<>$host2<>$lasttime2<>$date2<>\n");
			}

			# インデックス取得用
			if($type =~ /Get-index/){
				$index_line .= qq(<div class="line-height">\n);
				$index_line .= qq($text2\n);
				$index_line .= qq( ( $date2 ) );
				$index_line .= qq( ｜ 編集者 - );

					if($account2){ $index_line .= qq(<a href="${main::auth_url}$account2/">\@$account2</a>\n); }
					if($encid2){ $index_line .= qq( <i>★$encid2</i>); }
				$index_line .= qq(</div>\n);
			}

	}

	# 新規編集
	if($type =~ /New-edit/){
		my($encid) = main::id();
		unshift(@renew_line,"<>$new_text<>$main::myaccount{'file'}<>$new_handle<>$main::cnumber<>$encid<>$main::host<>$main::time<>$main::date<>\n");
	}


close($edit_handler);

	# ファイル更新
	if($type =~ /Renew/){
		unshift(@renew_line,"$edit{'key'}<>\n");
		Mebius::Mkdir(undef,$directory1);
		Mebius::Fileout(undef,$file,@renew_line);
	}

	# インデックス整形
	if($type =~ /Get-index/){
		$edit{'index_line'} .= qq(<div><h3$main::kstyle_h3>変更履歴</h3>);
		$edit{'index_line'} .= qq($index_line);
		$edit{'index_line'} .= qq(</div>);

	}


return(%edit);

}

1;
