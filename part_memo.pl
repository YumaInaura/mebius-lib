
package main;

use Mebius::BBS;
use Mebius::History;
use Mebius::BBS::Index;
use Mebius::Penalty;

#-----------------------------------------------------------
# 記事メモ
#-----------------------------------------------------------
sub bbs_memo{

# 宣言
our($mode,$css_text,$ngbr,$memo_wait,$memo_author_wait,$memo_maxmsg,$memo_history_max);
our(%in,$i_com,$i_nam,$sub_title);

# 最大文字数、待ち時間など設定
$ngbr = 200;
$memo_wait = 15;
$memo_author_wait = 5;
$memo_maxmsg = 5000;
$memo_history_max = 1000;

# ファイル定義
local $file = $in{'no'};
$file =~ s/\D//g;
if($file eq ""){ &error("記事を指定してください。"); }

# 変数定義
$i_nam = $in{'name'};
$i_com = $in{'comment'};

# 携帯モード
if($mode eq "kview"){ &kget_items(); }

# タイトル、上部メニュー定義
$sub_title = "メモ";
$head_link4 = qq(&gt; メモ);

	# モード振り分け
	if($in{'type'} eq "action"){ &memo_write("",$file); }
	elsif($in{'type'} eq "delete" && $admin_mode){ &memo_delete_history(); }
	elsif($in{'type'} eq "oview"){ &memo_oview($memo_body); }
	elsif($in{'type'} eq ""){ &memo_view("VIEW",$file); }
	else{ &error("処理タイプを選んでください。"); }

}

#-----------------------------------------------------------
# 記事メモの表示、編集フォーム - 無限ループ注意！
# サブルーチン内に &memo_error; の処理を置かない
#-----------------------------------------------------------
sub memo_view{

# 局所化
my($type,$file,$error_message) = @_;
my(%th,$intextarea,$history_line,$guide_line,$preview_line,$waittime,$waitmin,$name_input,$namevalue,%memo_history);
our(%in,$moto,$noindex_flag,$mode,$script,$memo_view_done);

# エラー時アンロック
if($lockflag) { &unlock($lockflag); }

# 二重処理を禁止
if($memo_view_done){ &error("二重処理は出来ません。"); }
$memo_view_done = 1;

# ファイル定義
$file =~ s/\D//g;
if($file eq ""){ &error("記事を指定してください。"); }

# 元記事のトップデータを取得
(%th) = Mebius::BBS::thread({},$moto,$file);

# 削除済み記事、管理者の記事、存在しない記事、過去ログは、メモを表示・編集できないように
if($th{'key'} eq "4" || $th{'key'} eq "3" ||  $th{'key'} eq "6" || $th{'key'} eq ""){ &error("▼この記事のメモは編集できません。<br>"); }

# タイトル定義
$head_link3 = qq(&gt; <a href="${file}.html">$th{'sub'}</a>);
$sub_title = qq(メモ | $th{'sub'});

# CSS定義
$css_text .= qq(
div.preview{padding:1.0em;line-height:1.4;border:solid 1px #00f;margin:1.0em 0.0em;}
div.error{padding:1.0em;line-height:1.4;border:solid 1px #f00;margin:1.0em 0.0em;color:#f00;}
ul{font-size:90%;}
li{line-height:1.5;}
i{font-size:70%;}
div.after{background-color:#dee;border:solid 1px #000;margin:0em 0em 1em 0em;width:47%;float:left;padding:0.5em;}
div.before{background-color:#ddd;border:solid 1px #000;margin:0em 0em 1em 0em;width:47%;float:right;padding:0.5em;}
div.after_text{padding:1em;word-wrap:break-word;overflow:hidden;line-height:1.4;}
div.before_text{padding:1em;word-wrap:break-word;overflow:hidden;line-height:1.4;}
div.after_title{padding:0.5em 0em 0em 0.5em;}
div.before_title{padding:0.5em 0em 0em 0.5em;}
hr.none{display:none;}
h2{background-color:#fda;border:solid 1px #000;padding:0.2em 0.4em;font-size:120%;}
h3{clear:both;}
h4{display:inline;}
strong.blue{color:#00f;}
textarea.memoarea{width:99%;height:300px;}
input.name{width:14em;}
div.clear{clear:both;}
);

# キャッシュさせない
$noindex_flag = 1;

# テキストエリア用に変換
if($type =~ /ERROR/){ $intextarea = $in{'comment'}; }
else{ $intextarea = $th{'memo_body'}; }
$intextarea =~ s/<br>/\n/g;
if($type =~ /VIEW/){ $intextarea =~ s/No\.([0-9]+)/&gt;&gt;$1/g; }

	# 差分を取得
	#if($type =~ /VIEW/ && $mode ne "kview"){ ($history_line) = &get_memo_history(); }
	if($type =~ /VIEW/ && $mode ne "kview"){

		(%memo_history) = &bbs_memo_history("Get-index",$main::moto,$file);


				if($main::admin_mode){

					# フォーム
					$history_line .= qq(<form action="" method="post"><div>);
					$history_line .= qq(<input type="hidden" name="mode" value="memo"$main::xclose>);
					$history_line .= qq(<input type="hidden" name="type" value="delete"$main::xclose>);
					$history_line .= qq(<input type="hidden" name="moto" value="$realmoto"$main::xclose>);
					$history_line .= qq(<input type="hidden" name="no" value="$main::in{'no'}"$main::xclose>);
					$history_line .= qq($memo_history{'index_line'});
					$history_line .= qq(<input type="submit" value="実行する"$main::xclose>);
					$history_line .= qq(</form></div>);

				}

				else{
					$history_line = $memo_history{'index_line'};
				}

		# 古い差分	
		#($history_line) = &get_memo_history();

	}

	# 記事メモのガイドを表示
	if($type =~ /VIEW/){
		$guide_line = qq(
		<h2 id="RULE">ルール</h2>
		<ul>
		<li><strong class="red">「後から決まった記事ルール」「注意書き」「大まかな記事の流れ（まとめ）」「Ｑ＆Ａ」「関連ＵＲＬ」</strong>など、記事進行に関してメモを取ってください。雑談や、個人的なやり取りの場所ではありません。</li>
		<li>誰でも閲覧・編集できる共有のメモです。基本的に<strong class="red">前の内容は消さず、文章を追加したり、編集するだけにしてください。</strong>（前のメモを消して、自分だけのメモを取るのは、間違った使い方です）</li>
		<li>メモ内容は変更されることがあるので、大事な情報は<a href="${guide_url}%A5%ED%A5%B0%CA%DD%C2%B8">ログ保存</a>するか、<a href="http://aurasoul.mb2.jp/_qst/2341.html">メモ置き場</a>を利用してください。（一定期間は <a href="#HISTORY">▼差分</a> に保存されます）。</li>
		<li>他、詳しいルールは<a href="${guide_url}%B5%AD%BB%F6%A5%E1%A5%E2">メモのガイドライン</a>をご覧ください。</li>
		$last_man
		</ul>
		);
	}

	# エラー表示
	if($e_com || $error_message){
		$error_line = qq(
		<div class="error"> エラー：
		<br$xclose><br$xclose> $error_message $e_access $e_sub $e_com</div>
	);
	}

	# プレビュー表示
	if($type =~ /ERROR/){
		$prev_text = $i_com;
		$prev_text = &memo_auto_link($prev_text);
		if($mode eq "kview"){ $prev_text =~ s/<br>/<br$xclose>/g; }
		$preview_line = qq(
		<div class="preview">
		<strong class="blue">プレビュー中です。まだ書き込まれていません。</strong><br$xclose><br$xclose>
		$prev_text</div>
		);
	}


# チャージ時間判定
($chargetime,$chargemin,$chargesec) = &get_memo_chargetime();

	# 筆名欄
	if($in{'name'}){ $namevalue = $in{'name'}; } else { $namevalue = $cnam; }
	if($admin_mode){
		$name_input = qq(筆名: <input type="text" name="name" value="$my_name" class="name"$disabled$xclose><br$xclose><br$xclose>);
	}
	else{
		$name_input = qq(筆名: <input type="text" name="name" value="$namevalue" class="name"$xclose>);
			if($chargetime > 0){ $name_input .= qq(　<strong class="red">＊チャージ時間中です。（残り$chargemin分$chargesec秒）</strong><br$xclose><br$xclose>); }
	}

# ＨＴＭＬ
$print .= qq(
<h1><a href="${file}.html">$th{'sub'}</a> のメモ</h1>
$guide_line
$error_line
$preview_line
<h2 id="EDIT">編集</h2>
<form action="$script" method="post"$sikibetu>
<div>
<input type="hidden" name="mode" value="$mode"$xclose>
<input type="hidden" name="moto" value="$realmoto"$xclose>
<input type="hidden" name="no" value="$file"$xclose>
<input type="hidden" name="r" value="memo"$xclose>
<input type="hidden" name="type" value="action"$xclose>
$name_input
<textarea name="comment" cols="25" rows="5" class="memoarea">$intextarea</textarea><br$xclose>
<input type="submit" name="preview" value="この内容でプレビューする" class="ipreview"$xclose>
<input type="submit" value="この内容で送信する" class="isubmit"$xclose>
);

# 調整
$print .= qq(<input type="hidden" name="up" value="$cup"$xclose>);

# フォーム終わり
$print .=  qq(
<br$xclose><br$xclose>
<ul>
<li><strong class="red">接続データ ( $addr ) は保存されます。「個人情報掲載」「荒らし」「罵倒、陰口」などのルール違反は禁止です。</strong></li>
<li>行数が多いと元の記事で省略されます。行頭を // （半角スラッシュ２個）にすると、元記事でコメントアウト（非表\示）にすることが出来ます。</li>
</ul>
</div></form>
<h2 id="HISTORY">差分</h2>
$history_line
<div class="clear"></div>
);



# 出力
Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#--------------------------------------------------
# 記事メモのエラー・プレビュー
#--------------------------------------------------
sub memo_error{
my($message,$file,$error) = @_;
our(%in);
&memo_view("ERROR",$in{'no'},$message);
}

#-----------------------------------------------------------
# 記事メモの中身だけを表示
#-----------------------------------------------------------
sub memo_oview{

# 局所化
my($print);
our(%th,%in,$moto);

# 元記事のトップデータを取得
(%th) = Mebius::BBS::thread({},$moto,$in{'no'});

# 自動リンク
($memo_text) = &memo_auto_link($th{'memo_body'});

	# 携帯用処理
	if($kflag){
		$memo_text =~ s/<br>/<br$xclose>/g;
		$print .= qq(<a href="$in{'no'}.html">元</a>$kboad_link$kindex_link);
	}

# ＨＴＭＬ
$print .= qq(
<hr$xclose>メモ ( <a href="${file}.html">$th{'sub'}</a> ) <hr$xclose>
$memo_text
<br$xclose>
);

# 編集リンク
if($main::device{'level'} >= 1){ $print .= qq(\(<a href="$script?mode=kview&amp;no=$in{'no'}&amp;r=memo" rel="nofollow">→編集する</a>\)); }

Mebius::Template::gzip_and_print_all({},$print);


exit;

}


use strict;

#-----------------------------------------------------------
# 記事メモの差分 (新 / 記事単位)
#-----------------------------------------------------------
sub bbs_memo_history{

# 宣言
my($type,$moto,$thread_number) = @_;
my(undef,undef,undef,$renew_new_line) = @_ if($type =~ /New-line/);
my(undef,undef,undef,%query) = @_ if($type =~ /Delete-line/);
my($new_before_text,$new_after_text,$new_handle,$new_encid,$new_enctrip) = split(/<>/,$renew_new_line) if($type =~ /New-line/);
my($i,@renew_line,%data,$file_handler,$hit_index);

	# 汚染チェック
	if($moto =~ /\W/ || $moto eq ""){ return(); }
	if($thread_number =~ /\D/ || $thread_number eq ""){ return(); }

# ファイル定義
my($base_directory_per_bbs) = Mebius::BBS::base_directory_path_per_bbs($moto);
	if(!$base_directory_per_bbs){
		return();
	}

#my $directory1 = "${main::int_dir}_bbs_memo_history/";
my $directory1 = "${base_directory_per_bbs}_memo/";
my $file1 = "${directory1}${thread_number}_memo_history.log";

# 最大行を定義
my $max_line = 100;
my $max_view_line = 10;

# 各差分の最大保存時間 ( １行ごと)
my $historty_max_save_time = 30*24*60*60;

	# ファイルを開く
	if($type =~ /File-check-error/){
		open($file_handler,"<$file1") || main::error("ファイルが存在しません。");
	}
	else{
		open($file_handler,"<$file1") && ($data{'f'} = 1);
	}

	# ファイルロック
	if($type =~ /Renew/){ flock($file_handler,1); }

# トップデータを分解
chomp(my $top1 = <$file_handler>);
($data{'key'},$data{'number_of_posts'}) = split(/<>/,$top1);

	# ファイルを展開
	while(<$file_handler>){

		# ラウンドカウンタ
		$i++;
		
		# この行を分解
		chomp;
		my($key2,$line_number2,$before_text2,$after_text2,$lasttime2,$handle2,$encid2,$enctrip2,$host2,$agent2,$cnumber2,$account2) = split(/<>/);

			# ●インデックス表示用 ---
			if($type =~ /Get-index/){

				# 局所化
				my($before_text_line2,$after_text_line2,$view_cnumber,$view_account,$deleted_flag,$delete_input,$deleted_flag);

					# 削除済みの行
					if($key2 =~ /Deleted-line/){

						# フラグを立てる
						$deleted_flag = 1;

							if($main::admin_mode){

							}
							else{
								next;
							}
					}


					# 日付を計算
					my($date2) = Mebius::Getdate(undef,$lasttime2);
					my($how_before_edited) = Mebius::SplitTime("Color-view Plus-text-前 Get-top-unit",$main::time-$lasttime2);

					# 処理を飛ばす場合
					if($key2 =~ /Deleted-line/){ $deleted_flag = 1; }
					if($deleted_flag && !$main::admin_mode){ next; }
					if($main::time > $lasttime2 + $historty_max_save_time){ next; }

				# ヒットカウンタ
				$hit_index++;

					# 表示最大数に達した場合
					if($hit_index > $max_view_line){ next; }

					# ▽差分を色づけ（追加分 - アフター)
					foreach (split/<br>/,$after_text2){

							if($_ eq ""){ $after_text_line2 .= qq(<br>); next; }

						my($text1) = $_;
						my($flag1);

							# ビフォーテキストと比較
							foreach(split/<br>/,$before_text2){
									if($_ eq $text1){ $flag1 = 1; }
							}

							if(!$flag1){ $text1 = qq(<strong class="red">$text1</strong>); }
						$after_text_line2 .= qq($text1<br>);

						# オートリンク
						($after_text_line2) = &memo_auto_link($after_text_line2);

					}


					# ▽差分を色づけ（ビフォー）
					foreach(split/<br>/,$before_text2){

							if($_ eq ""){ $before_text_line2 .= qq(<br>); next; }

						my($text2) = $_;
						my($flag2);

							# アフターテキストと比較
							foreach(split/<br>/,$after_text2){
									if($_ eq $text2){ $flag2 = 1; }
							}
	
							if(!$flag2){ $text2 = qq(<strong class="blue">$text2</strong>); }
						$before_text_line2 .= qq($text2<br>);
						($before_text_line2) = &memo_auto_link($before_text_line2);



					}

					# 表示調整
					if($lasttime2 <= 1321451532){} # 2011/11/16 (水) トリップの元がそのまま表示されてしまっていた不具合に対応
					elsif($enctrip2){ $handle2 = qq($handle2☆$enctrip2); }
					

					if($account2){ $view_account = qq(<a href="${main::auth_url}$account2/">\@$account2</a>); }
					if($main::admin_mode){ $view_cnumber = qq(<a href="$main::mainscript?mode=cdl&amp;file=$cnumber2&amp;filetype=number" class="red">$cnumber2</a>); }


				# 削除リンク
				if($main::admin_mode && !$deleted_flag){

						# 削除済みの場合
						if($deleted_flag){ $after_text_line2 = qq(<span class="red"></span>); }
						# 削除されていない場合
						else{
							my($checked_none);
							$checked_none = $main::parts{'checked'};

							$delete_input .= qq(<input type="radio" name="line_$line_number2" value="none" id="line_${line_number2}_none"$checked_none>);
							$delete_input .= qq(<label for="line_${line_number2}_none">未選択</label>\n);
							$delete_input .= qq(<input type="radio" name="line_$line_number2" value="delete" id="line_${line_number2}_delete">);
							$delete_input .= qq(<label for="line_${line_number2}_delete">削除</label>\n);
							$delete_input .= qq(<input type="radio" name="line_$line_number2" value="penalty" id="line_${line_number2}_penalty">);
							$delete_input .= qq(<label for="line_${line_number2}_penalty" class="red">罰削除</label>\n);
						}
						# 整形
						if($delete_input){ $delete_input = qq(<div class="right margin">$delete_input</div>); }
				}

				# アフター整形
				$after_text_line2 = qq(<h3>$line_number2回目の編集 - $handle2 $view_account<i>★$encid2</i> $view_cnumber</h3><div class="after"><div class="after_title"><h4>☆アフター </h4></div><div class="after_text">$after_text_line2</div><div class="right">編集： $how_before_edited ( $date2 ) No.$line_number2</div>$delete_input</div>);

				# ビフォー整形
				$before_text_line2 = qq(<div class="before"><div class="before_title"><h4>★ビフォー</h4></div><div class="before_text">$before_text_line2</div></div>\n);

				$data{'index_line'} .= qq($after_text_line2$before_text_line2);

			}

			# ●行削除用
			if($type =~ /Delete-line/){

					# 普通の削除
					if($main::in{"line_$line_number2"} eq "delete" || $main::in{"line_$line_number2"} eq "penalty"){
						$key2 =~ s/(\s)?Deleted-line//g;
						$key2 .= qq( Deleted-line);
					}

					# ペナルティ削除
					if($main::in{"line_$line_number2"} eq "penalty" && $key2 !~ /Penalty-done/){
						$key2 =~ s/(\s)?Penalty-done//g;
						$key2 .= qq( Penalty-done);
							if($cnumber2){ Mebius::penalty_file("Cnumber Renew Penalty",$cnumber2); }
							if($host2){ Mebius::penalty_file("Host Renew Penalty",$host2); }
							if($agent2 && $cnumber2 eq ""){ Mebius::penalty_file("Agent Renew Penalty",$agent2); }
							if($account2){ Mebius::penalty_file("Account Renew Penalty",$account2); }
					}

			}

			# ●ファイル更新用
			if($type =~ /Renew/){

					# 最大行数に達した場合
					if($i > $max_line){ next; }

					# ある程度以上、古い行は自動削除
					if($main::time > $lasttime2 + $historty_max_save_time){ next; }

				# 行を追加
			push(@renew_line,"$key2<>$line_number2<>$before_text2<>$after_text2<>$lasttime2<>$handle2<>$encid2<>$enctrip2<>$host2<>$agent2<>$cnumber2<>$account2<>\n");

			}


	}

close($file_handler);


	# 新しい行を追加
	if($type =~ /New-line/){

		$data{'number_of_posts'}++;

	unshift(@renew_line,"<>$data{'number_of_posts'}<>$new_before_text<>$new_after_text<>$main::time<>$new_handle<>$new_encid<>$new_enctrip<>$main::host<>$main::agent<>$main::cnumber<>$main::myaccount{'file'}<>\n");

	}

	# インデックス取得用 整形
	if($type =~ /Get-index/){

	}


	# ファイル更新
	if($type =~ /Renew/){

		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory1);
		#Mebius::Mkdir(undef,$directory2);

		# トップデータを追加
		unshift(@renew_line,"$data{'key'}<>$data{'number_of_posts'}<>\n");

		# ファイル更新
		Mebius::Fileout(undef,$file1,@renew_line);

	}

return(%data);

}



#-------------------------------------------------
# 自動リンク処理
#-------------------------------------------------
sub memo_auto_link {

# 宣言
my($msg) = @_;
our(%in,$kflag);

($msg) = Mebius::auto_link($msg);


if($kflag){ $msg =~ s/No\.([0-9]{1,5})(([,-])([0-9,]+)||$)/<a href=\"$in{'no'}.html-$1$2#RES\">#$1$2<\/a>/g; }
else{ $msg =~ s/No\.([0-9]{1,5})(([,-])([0-9,]+)||$)/<a href=\"$in{'no'}.html-$1$2#RES\">&gt;&gt;$1$2<\/a>/g; }


return($msg);
}

#--------------------------------------------------
# 記事メモを書き込む
#--------------------------------------------------
sub memo_write{

# 宣言
my($type,$thread_number) = @_;
my($line,$enctrip,$i_handle,$i_com,$chargetime,$chargemin,$chargesec);
my($backup_line,$put_agent,$file_handle1,%renew_thread);
our(%in,$moto,$int_dir,$log_dir,$moto,$head_link3,$head_link4,$head_link5,$admy_name,$date,$host);
my($share_directory) = Mebius::share_directory_path();
my $penalty = new Mebius::Penalty;

	# 汚染チェック
	if($thread_number eq "" || $thread_number =~/\D/){ main::error("記事を指定してください。"); }

# 元記事のトップデータを取得
my(%th) = Mebius::BBS::thread({},$moto,$in{'no'});
	if($th{'key'} eq "4" || $th{'key'} eq "3" ||  $th{'key'} eq "6" || $th{'key'} eq ""){
		$main::e_com .= qq(▼この記事のメモは編集できません。<br>);
	}

# タイトル定義
$head_link3 = qq(&gt; <a href="${thread_number}.html">$th{'sub'}</a>);
$head_link4 = qq(&gt; <a href="${thread_number}_memo.html">メモ</a>);
$head_link5 = qq(&gt; 編集);

	# 掲示板が投稿停止モードの場合
	if(Mebius::Switch::stop_bbs()){ main::error("掲示板全体で、更新を停止中です。"); }

# アクセス制限,ＩＤ付与、トリップ付与
if(!$main::admin_mode){ &axscheck(); }
our($encid) = &id();
($enctrip,$i_handle) = &trip($in{'name'});

my$isp_data = $penalty->my_isp_data();
	if($isp_data->{'must_compare_xip_flag'}){
		main::error("メモを更新できません。");
	}

# 各種エラー
if($main::admin_mode){ $i_handle = $admy_name; }
if($th{'memo_body'} eq $in{'comment'}){ $main::e_com .= "▼内容が変わっていません。<br>"; }
if(!$main::admin_mode){ &memo_base_error_check(); }

# チャージ時間
($chargetime,$chargemin,$chargesec) = &get_memo_chargetime();
if($chargetime > 0 && !$main::alocal_mode){ $main::e_com .= qq(▼チャージ時間中です。あと$chargemin分$chargesec秒待ってください。<br>); }

# コメント整形
$i_com = $in{'comment'};
$i_com =~ s/&gt;&gt;([0-9]+)/No\.$1/g;
if($main::admin_mode){ ($i_com) = Mebius::Fixurl("Admin-to-normal",$i_com); }

	# 存在しないレス番を修正
	#if(!$main::admin_mode){ ($i_com) = &checkres_number($i_com,$th{'res'}); }
	($i_com) = Mebius::Stamp::erase_invalid_code($i_com);

# エラーとプレビュー
if($in{'preview'} || $main::e_com){ &memo_view("ERROR",$thread_number); }

# ロック開始
&lock($moto);

# メモ本文を定義
$renew_thread{'memo_body'} = $i_com;

# メモの編集内容を定義
my($put_handle,$put_id,$put_xip) = ($i_handle,$encid,$main::xip);
$put_handle =~ s/=//g; $put_id =~ s/=/-/g; $put_xip =~ s/=//;
$renew_thread{'memo_editor'} = "$put_handle=$put_id=$enctrip=$main::time=$put_xip=$host=$main::cnumber=$main::myaccount{'file'}=$date";

# 記事を更新
my($thread) = Mebius::BBS::thread({ ReturnRef => 1 , Renew => 1 , TypeFileCheckError => 1 , select_renew => \%renew_thread },$main::moto,$thread_number);

# 記事ごとの差分を更新
my $history_renew_line = qq($main::host<>$main::agent<>$main::cnumber<>$main::myaccount{'file'}<>\n);
#qq($key2<>$memo_body<>$i_com<>$main::time<>$main::i_handle<>$main::encid<>$main::i_trip<>$main::host<>$main::agent<>$main::cnumber<>$main::myaccount{'file'}<>\n);
&bbs_memo_history("Renew New-line",$main::moto,$main::file,"$th{'memo_body'}<>$i_com<>$main::i_handle<>$main::encid<>$enctrip");

	# 掲示板インデックスを更新
	if($th{'key'} eq "1" || $th{'key'} eq "2" || $th{'key'} eq "5"){
		my(%index_line_control);
		require "${main::int_dir}part_res.pl";
		$index_line_control{$thread_number}{'last_handle'} = "メモ更新";
		Mebius::BBS::index_file({ Renew => 1 , RegistMemo => 1 , line_control => \%index_line_control },$main::moto);
		#&memo_indexsort("",$thread_number);
	}

	# XIPデータを書き込む
	if(!$main::admin_mode){
		Mebius::Fileout(undef,"${share_directory}_ip/_ip_memo/${main::xip_enc}.cgi","$main::time");
	}

	# 一定の確率で古いＸＩＰファイルを全削除
	if(rand(1000) < 1){
		&oldremove("","${share_directory}_ip/_ip_memo","30");
	}

# ロック解除
&unlock($moto);

	# 新着リストを更新
	if(!$main::secret_mode){
		my(%renew_list);
		my($init_directory) = Mebius::BaseInitDirectory();
		require "${init_directory}part_newlist.pl";
	main::EditMemoList({ TypeRenew => 1 , TypeNewLine => 1 , NewSubject => $th{'subject'} , NewTitle => $main::title , NewMoto => $moto , NewThreadNumber => $in{'no'} , NewBeforeText => $th{'memo_body'} , NewAfterText => $i_com , NewHandle => $main::i_handle , NewTrip => $main::i_trip });
	}

	# 管理モードのリダイレクト
	if($main::admin_mode){

		Mebius::Redirect(undef,$thread->{'admin_url'});

	# クッキーをセット
	} else {

		Mebius::Cookie::set_main({ last_memo_time => time , name => $main::in{'name'} },{ SaveToFile => 1 });
		# 投稿履歴ファイルを更新
		Mebius::HistoryAll("Renew My-file");

		# HTML
		Mebius::Redirect(undef,$thread->{'url'});


	}


exit;

}



#-----------------------------------------------------------
# 基本エラーチェック - strict
#-----------------------------------------------------------
sub memo_base_error_check{

# 宣言
my($brnum,$big_length);
our($int_dir,$postflag,$getflag,$i_com,$i_res,$e_com,$e_access);
our(%in,$moto,$ngbr,$memo_maxmsg,$guide_url);

# コメント
our($i_com) = ($in{'comment'});

	# 各種エラー
	if(!$postflag && !$getflag) { $e_access .= "▼不正なアクセスです。<br>"; }

# 取り込み処理
require "${int_dir}regist_allcheck.pl";

# 基本変換
($i_com) = &base_change($i_com);

# 各種エラー
my($big_length) = &get_length("",$i_com);
	if($big_length > $memo_maxmsg) { $e_com .= "▼本文の文字数が多すぎます。（ 現在$big_length文字 / 最大$memo_maxmsg文字 ）<br>";  }
($brnum) = ($i_com =~ s/<br>/<br>/g);
	if($brnum > $ngbr) { $e_com .= "▼改行が多すぎます。改行部分を減らしてください。（ 現在$brnum個 / 最大$ngbr個 ）<br>"; }
	if(($i_com eq "")||($i_com =~ /^(\x81\x40|\s|<br>)+$/)) { $e_com .= qq(▼本文がありません。何か書いてください。<br>); }

	# 連続改行の判定と制限
	if($i_com =~ /((<br>){10,})/){
	$e_com .= qq(▼<a href="${guide_url}%B2%FE%B9%D4">連続改行のしすぎです。改行の連続を減らしてください。</a><br>
	　記事が見づらくなるため、改行は１～３個ずつの範囲でおこなってください。<br>); 
	}

# 各種チェック
main::all_check(undef,$i_com,$in{'name'});

}



#-----------------------------------------------------------
# 差分の削除（新）
#-----------------------------------------------------------
sub memo_delete_history{

# 宣言
my($type) = @_;

	&bbs_memo_history("Delete-line Renew",$main::moto,$main::in{'no'});

Mebius::Redirect("","${main::jak_url}$main::moto.cgi?mode=memo&no=$main::in{'no'}");


}



#-----------------------------------------------------------
# 記事メモのチャージ時間 - strict
#-----------------------------------------------------------
sub get_memo_chargetime{

# 宣言
my($top,$chargetime,$chargemin,$chargesec,$lasttime);
our($time,$xip_enc,$admin_mode,$cmemo_time,$memo_wait);
my($share_directory) = Mebius::share_directory_path();

# XIPデータ開く
open(XIP_IN,"<","${share_directory}_ip/_ip_memo/${xip_enc}.cgi");
$top = <XIP_IN>; chomp $top;
close(XIP_IN);

# 待ち時間判定
$lasttime = $top;
$chargetime = $lasttime + $memo_wait*60 - $time;
if($chargetime <= 0){ $chargetime = $cmemo_time + $memo_wait*60 - $time; }

$chargemin = int($chargetime / 60);
if($chargemin){ $chargesec = $chargetime % ($chargemin*60); }
else{ $chargesec = $chargetime; }

# 管理者、ローカルで待ち時間をなくす
if($main::bbs{'concept'} =~ /Local-mode/ || $admin_mode){ $chargetime = undef; }

return($chargetime,$chargemin,$chargesec);

}


1;
