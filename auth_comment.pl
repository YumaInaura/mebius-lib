
use strict;
use Mebius::SNS::CommentBoad;
use Mebius::SNS::Account;

use Mebius::AllComments;
use Mebius::Newlist;
use Mebius::Report;
use Mebius::Query;

package main;

#-----------------------------------------------------------
# 伝言板を閲覧
#-----------------------------------------------------------
sub auth_view_comment{

# 宣言
my($select_year,$index,$account,$multi_flag,%account,$index_line,$fookyear);
my($comments_line,$resform,$navi,$h1_line,$year_title,$print);

Mebius::Report::report_mode_junction({ });

# CSS定義
$main::css_text .= qq(
.ctextarea{width:95%;height:35px;}
.cbottun{margin-top:0.5em;}
.clog{font-size:90%;}
.lic{margin-bottom:0.3em;line-height:1.25;}
.deleted{font-size:90%;color:#f00;}
th{text-align:left;padding:0.5em 1.0em 0.5em 0.0em;}
td{padding:0.2em 1.0em 0.5em 0.0em;line-height:1.4;vertical-align:top;}
input.comment{width:12em;}
);

	# マルチアカウントの判定
	if($main::submode2 eq "multi"){
		$multi_flag = 1;
			# アカウントは～個までしか選べない
			if((split(/,/,$main::submode3)) > 5){ main::error("アカウントを選べる上限を超えているため、表\示できません。"); }
	}

	# アカウントを開く
	if(!$multi_flag){

		(%account) = Mebius::Auth::File("Option Get-friend-status",$main::in{'account'},%main::myaccount);

			# 非表示設定の場合
			if($account{'ocomment'} eq "3" && !$main::myaccount{'admin_flag'}){
				&error("このメンバーの伝言板は非表\示設定されています。","401 Unauthorized");
			}

	}

# ユーザー色指定
#if($account{'color1'}){ $css_text .= qq(h2{background-color:#$account{'color1'};border-color:#$account{'color1'};}); }

	# ナビゲーションリンク
	if(!$multi_flag){
		my $link2 = "${main::auth_url}$account{'file'}/";
			if($main::aurl_mode){ ($link2) = &aurl($link2); }
		$navi .= qq(<a href="$link2">プロフィールへ</a>);
	}

	# 年度切り替えリンク
	if(!$multi_flag){
		($index_line,$fookyear) = auth_viewcomment_get_yearlinks("",$account{'file'},%account);
	}

# 検索フォーム
my($searchform) = auth_viewcomment_get_form(undef,$account{'file'});

# 伝言内容を取得
	if($multi_flag){
		($comments_line) = view_auth_comment("Get-index Index-view Multi-accounts",$main::submode3);
	}
	else{
		($comments_line,$resform) = view_auth_comment("Get-index Index-view",$account{'file'},$fookyear,undef,%account);
	}

	# タイトル定義 ( マルチアカウント )
	if($multi_flag){
		$main::sub_title = "伝言板 コメント履歴 - $main::submode3";
	}
	# タイトル定義 ( 普通 )
	else{
		$year_title = qq( ( $fookyear年 ) ) if($main::submode2);
		$main::sub_title = "$account{'name'}の伝言板 $year_title";
		$main::head_link3 = qq(&gt; <a href="$main::auth_url$account{'file'}/">$account{'name'}</a>);
		$main::head_link4 = qq(&gt; 伝言板);
			if($main::in{'word'} ne ""){ $main::sub_title = "”$main::in{'word'}で検索 - $account{'name'}の伝言板 $year_title"; }
	}


$print .= qq($main::footer_link);

	# 見出しタグ
	if($multi_flag){
		$h1_line = qq(伝言板 ： コメント履歴 - $main::submode3</h1>\n);
	}
	else{
		$h1_line = qq(伝言板 $year_title : $account{'name'} - $account{'file'}\n);
	}

$print .= qq(<h1$main::kstyle_h1>$h1_line</h1>\n$navi$index_line\n);

# 違反報告への移動ボタン
my($move_to_report_mode_button) = shift_jis(Mebius::Report::move_to_report_mode_button({ url_hash => "#a" , ViewResReportButton => 1 , NotThread => 1  }));
$print .= $move_to_report_mode_button;

	# 投稿フォーム
	if(!$multi_flag){
		$print .= qq($searchform);
		$print .= qq(<h2 id="COMMENT-INPUT"$main::kstyle_h2>投稿</h2>$resform\n);
	}

$print .= qq(
$comments_line
<br$main::xclose>
$main::footer_link2
);





Mebius::Template::gzip_and_print_all({},$print);

exit;

}

no strict;

#-----------------------------------------------------------
# 年度切り替えリンクを取得
#-----------------------------------------------------------
sub auth_viewcomment_get_yearlinks{

my($type,$file,%account) = @_;
my($index,$file_handler);
our($xclose);

# 整形
if($submode2){ $index .= qq( <a href="$main::auth_url$file/viewcomment">最近</a> );}
else{ $index .= qq( <span class="red">最近</span> ); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# コメントインデックスを開く
open($file_handler,"<","${account_directory}comments/${file}_index_comment.cgi");
	while(<$file_handler>){
	chomp;
	my($year,$month) = split(/<>/);

	my $link = qq($main::auth_url$file/viewcomment-$year);

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
close($file_handler);

# インデックス整形
if($index ne ""){ $index = qq(　　期間 ： $index); }

return($index,$fookyear);

}


#-----------------------------------------------------------
# 検索フォーム
#-----------------------------------------------------------
sub auth_viewcomment_get_form{

# 宣言
my($type,$account) = @_;
my($line);
our($xclose,$kfontsize_h2);

my $checked1 = $main::parts{'checked'} if(!$fookyear);

$line = qq(
<h2 id="COMMENT-SEARCH"$kfontsize_h2>検索</h2>
<form action="$script">
<div>
<input type="hidden" name="account" value="$account"$xclose>
<input type="text" name="word" value="$in{'word'}" class="comment"$xclose>
<input type="submit" value="伝言板から検索する"$xclose>
<input type="radio" name="mode" value="viewcomment"$checked1$xclose>最近
$select_year
<span class="guide">※「筆名」「アカウント名」「コメント内容」から検索します。</span>
</div>
</form>

);

# リターン
return($line);

}



use strict;

#──────────────────────────────
# 伝言板
#──────────────────────────────
sub view_auth_comment{

# 局所化
my($type,$accounts,$year,$maxview,%account) = @_;
my($my_account) = Mebius::my_account();
my($i,$hit,$file,$stop,$form,$flow_flag,@years,$input_years,$control_flag,$text,@index_line,$i_foreach);
my($comments,$del,$account,@accounts,%multi_account,$i_multi_accounts,%multi_background_class,$multi_flag);
my($param) = Mebius::query_single_param();
my($basic_init) = Mebius::basic_init();
my($my_use_device) = Mebius::my_use_device();
my $query = new Mebius::Query;
my $sns_account = new Mebius::SNS::Account;
our($idcheck,$kflag,$xclose,$kfontsize_h2);

	# 設定
	if(!$maxview){ $maxview = 500; }
	if($main::submode3 eq "all"){ $maxview = 5000; }

# CSS定義
#h2#COMMENT,h2#COMMENT-INPUT,#COMMENT-SEARCH{background:#ff9;border-color:#fc7;}
$main::css_text .= qq(
strong.alert{font-size:90%;color:#f00;}
div.shadow{background:#eee;}
div.deleted{background:#fee;color:#999;}
div.comment-next{margin-top:0.5em;text-align:right;}
div.control{text-align:right;}
div.control_submit{text-align:right;margin:0.5em 0em;}
div.dcm{padding:0.5em 0.5em;line-height:1.4;border-bottom:solid 1px #000;}
);

my $comment_boad_url = "$basic_init->{'auth_url'}$account{'id'}/viewcomment#COMMENT";

	# CSS定義 ( 2 )
	if($type =~ /Multi-accounts/){
		$main::css_text .= qq(.multi1{background:#fff;}\n);
		$main::css_text .= qq(.multi2{background:#eef;}\n);
		$main::css_text .= qq(.multi3{background:#afa;}\n);
		$main::css_text .= qq(.multi4{background:#ff8;}\n);
		$main::css_text .= qq(.multi5{background:#ddd;}\n);
		$multi_flag = 1;
	}


	# ハッシュ定義
	foreach (split(/,/,$accounts)){
		$i_multi_accounts++;
		$multi_account{$_} = 1;
		$multi_background_class{$_} = "multi$i_multi_accounts";
	}


	# ●対象アカウントを展開
	foreach $account (split(/,/,$accounts)){

		# 局所化
		my($file,$comment_handler,%account2);

			# ▼マルチアカウントを開く
			if($type =~ /Multi-accounts/){

				(%account2) = Mebius::Auth::File("Option Get-friend-status",$account,%main::myaccount);

					# 伝言板が非表示設定になっている場合
					if($account2{'ocomment'} eq "3" && !$my_account->{'admin_flag'}){ next; }

			}

			# アカウント名判定
			if(Mebius::Auth::AccountName(undef,$account)){ next; }

		# ディレクトリ定義
		my($account_directory) = Mebius::Auth::account_directory($account);
			if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

			# ファイル切り替え
			if($year){ $file = "${account_directory}comments/${account}_${year}_comment.cgi"; }
			else{ $file = "${account_directory}comments/${account}_comment.cgi"; }

		# アカウント
		push(@accounts,$account);

		my($comment_boad) = Mebius::SNS::CommentBoad::log_file({ year => $year },$account);

		# コメントを開く
		#open($comment_handler,"<",$file);
		#my $top = <$comment_handler> if(!$year); chomp $top;

			# ▼開くアカウントの個数分だけ、ファイルを展開
		#	while(<$comment_handler>){

				# 局所化
		#		my($viewres,$control_box,$trclass,$class);

				chomp;
		#		my($key,$rgtime,$account2,$name,$trip,$id,$comment,$dates,$xip,$res,$deleter,$control_handle2,$res_concept2,$text_color2) = split(/<>/,$_);



		#	}

		#close($comment_handler);
		push @index_line , @{$comment_boad->{'res_data'}} if $comment_boad->{'res_data'};

					# 配列に追加
					#if($type =~ /Get-index/){
					#		foreach(@{$comment_boad->{'res_data'}}){
					#			push(@index_line,[$account,$key,$rgtime,$account2,$name,$trip,$id,$comment,$dates,$xip,$res,$deleter,$control_handle2,$res_concept2,$text_color2]);
					#		}
					#}

	}

	# 配列を時系列にソート
	if($type =~ /Multi-accounts/){
		@index_line = sort { $b->{'regist_time'} <=> $a->{'regist_time'} } @index_line;
	}

my @index_line_adjusted = @{$sns_account->add_handle_to_data_group(\@index_line)};

	# 配列を展開
	if($type =~ /Get-index/){

			# ●配列を展開
			foreach(@index_line_adjusted){

				# ラウンドカウンタ
				$i_foreach++;
				$i++;

					# 表示数をオーバーした場合
					if($i > $maxview && $type !~ /Multi-account/){ $flow_flag = 1; last; }

						# マルチ表示用
						if($type =~ /Multi-account/){
								# 選択されたアカウントで、なおかつ、相手のアカウントの伝言のみ選択する ( 自分の伝言板への、自分の伝言は選ばない )
								if($multi_account{$_->{'account'}} && $_->{'main_account'} ne $_->{'account'}){
									1;
								} else {
									next;
								}
						}

					# ワード検索
					if($param->{'word'} ne "" && ($_->{'account'} !~ /\Q$param->{'word'}\E/ && $_->{'comment'} !~ /\Q$param->{'word'}\E/ && $_->{'name'} !~ /\Q$param->{'word'}\E/) ){ next; }

				# ヒットカウンタ
				$hit++;

					# 水平線
					if($my_use_device->{'mobile_flag'} && $hit >= 2){ $comments .= qq(<hr>); }

					my $css_class_in = qq( $multi_background_class{$account}) if($type =~ /Multi-accounts/);

					($comments) .= auth_view_comment_core({ multi_flag => $multi_flag , css_class_in => $css_class_in } , $_);

			}
	}



# 見出し定義
my $h2 .= qq(<h2 id="COMMENT"$kfontsize_h2>);
	if($type =~ /PROF/ && $flow_flag){ $h2 .= qq(<a href="$comment_boad_url">); }
$h2 .= qq($account{'handle'}への伝言);
	if($type =~ /PROF/ && $flow_flag){ $h2 .= qq(</a>); }
$h2 .= qq(</h2>);

	# コメント部分整形
	if($comments){
		if($kflag){
			$comments = qq($h2\n$comments);
		}
		else{
			$comments = qq(
			$h2
			<div>
			$comments
			</div>
			);
		}
	}
	else{ $comments = $h2; }

	# 続き
	if($year && $type !~ /PROF/ && $flow_flag){ $comments = qq($comments<a href="./viewcomment-$year-all">続き</a>); }


	# コメント可否の判定
	if($account{'key'} eq "2"){ $form .= qq(▼アカウントがロック中のため書き込めません<br>); $stop = 1; }
	elsif($account{'let_flag'}){ $form .= qq(▼$account{'let_flag'}); $stop = 1; }
	elsif($account{'friend_status_to'} eq "deny"){ $form .= qq(▼禁止設定中のためコメントできません<br$xclose>); $stop = 1; }
	elsif($account{'ocomment'} eq "0"){ $form .= qq(▼アカウント主 ( $accounts[0] ) だけがコメントできます<br>); if(!$account{'myprof_flag'}){ $stop = 1; } }
	elsif($account{'ocomment'} eq "2"){
		$form .= qq(▼$main::friend_tagだけがコメントできます<br>);
			if($account{'friend_status_to'} ne "friend" && !$account{'myprof_flag'}){ $stop = 1; }
	}

	# ログイン関係
	if(!$idcheck){ $form = qq(▼コメントするには<a href="$main::auth_url?backurl=$main::selfurl_enc">ログイン（または新規登録）</a>してください。<br>); $stop = 1; }
	elsif($main::birdflag){ $form = qq(▼コメントするには<a href="$main::auth_url$my_account->{'file'}/#EDIT">あなたの筆名</a>を設定してください。<br$xclose>); $stop = 1; }

# ＨＴＭＬ最終出力定義
$form .= qq(▼非公開 - あなた以外には見えません ) if($account{'ocomment'} eq "3");


	# 待ち時間表示
	if(time < $my_account->{'next_comment_time'}){
		my($next_splittime) = Mebius::SplitTime(undef,$my_account->{'next_comment_time'}-$main::time);
		$form .= qq( ▼現在チャージ時間中です。あと$next_splittimeで書き込めます。);
		#$stop = 1;
	}


	# 管理者の場合
	if($my_account->{'admin_flag'}){ $stop = ""; }

	# コメントフォームを通常表示
	if($main::stop_mode =~ /SNS/){
		$form .= qq(<div><br$main::xclose><span class="alert">現在、SNS全体で投稿停止中です。</span></div>);
	}
	elsif(!$stop){
		my($select_line) = Mebius::Init::Color("Get-select-tags",$my_account->{'comment_font_color'});

		$form .= qq(<form action="$main::action" method="post" class="pform"$main::sikibetu>\n);

			if($type =~ /UTF-8/){
				$form .= $query->input_hidden_encode();
			}
		$form .= qq(<div>\n);
		$form .= qq(<textarea name="comment" class="ctextarea" cols="25" rows="5"></textarea>\n);
		$form .= qq(<br$xclose>\n); 
		$form .= qq(<input type="submit" value="この内容で伝言する"$xclose>\n);
		$form .= qq(<select name="color">\n$select_line</select>\n);
			if($type =~ /Back-url/){ $form .= Mebius::back_url_hidden(); }
		$form .= qq(<input type="hidden" name="mode" value="comment"$xclose>\n);
		$form .= qq(<input type="hidden" name="account" value="$accounts[0]"$xclose>\n);
		#$form .= qq(<strong class="alert">書き込むと 接続データ ( $main::addr ) がサーバー内部に記録され、 <a href="${main::adir}aview-allcomment.html" class="blank" target="_blank">新着伝言</a> も更新されます。 　</strong>\n);
		#$form .= qq(<span class="guide">（全角$main::max_msg_comment文字まで）。</span>\n);
		$form .= qq(</div>\n);
		$form .= qq(</form>\n);

	}

	# ●削除依頼モードの場合、フォームを追加
	if(Mebius::Report::report_mode_judge()){
		($comments) = Mebius::Report::around_report_form($comments);

	# ●コメント操作ボタン
	#} elsif($control_flag){
	} elsif($my_account->{'login_flag'}){

		# 局所化
		my($method);
		our($backurl_input);

		# メソッド定義
		#if($alocal_mode){ $method = "get"; }
		#else{ $method = "post"; }
		$method = "post";

		$comments = qq(
		<form action="$main::auth_url" method="$method"$main::sikibetu>
		<div>
		$comments
		<input type="hidden" name="mode" value="comdel"$xclose>
		<input type="hidden" name="account" value="$accounts[0]"$xclose>
		<input type="hidden" name="year" value="$main::submode2"$xclose>
		<input type="hidden" name="thismode" value="$main::mode"$xclose>
		$input_years 
		$backurl_input
		<div class="control_submit">
		<input type="submit" value="コメント操作を実行する"$xclose>
		</div>
		</div>
		</form>
		);
	} 


	# 自分のコメント履歴を取得
	if($type !~ /Low-load/){
		#my(%comment_history) = Mebius::Auth::CommentBoadHistory("Get-oneline",$my_account->{'file'});
		#	if($comment_history{'oneline_line'}){
		#		$form .= qq(<div class="right word-spacing">あなたの伝言履歴： );
		#		$form.= qq($comment_history{'oneline_line'});
		#		$form .= qq(<a href="${main::auth_url}$my_account->{'file'}/aview-history#COMMENT_HISTORY">…もっと見る</a>);
		#		$form .= qq(</div>\n);
		#	}
	}

	# 整形
	if($type =~ /PROF/){
		$comments = 
		qq($comments) .
		qq(<div class="comment-next">).
		qq(<a href="$comment_boad_url">→メッセージの続きを見る</a>) .
		qq(</div>);
	}

	# フォームを消す
	if($type =~ /Multi-accounts/){
		$form = "";
	}

return($comments,$form);

}


#-----------------------------------------------------------
# 表示内容 ( コア処理 )
#-----------------------------------------------------------
sub auth_view_comment_core{

my($use,$data) = @_;
my $fillter = new Mebius::Fillter;
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
my($my_use_device) = Mebius::my_use_device();
my($account,$key,$rgtime,$account2,$trip,$id,$comment,$dates,$xip,$res,$deleter,$control_handle2,$res_concept2,$text_color2) = 
($data->{'main_account'},$data->{'key'},$data->{'regist_time'},$data->{'account'},$data->{'trip'},$data->{'id'},$data->{'comment'},$data->{'dates'},$data->{'xip'},$data->{'res_number'},$data->{'deleter'},$data->{'control_account'},$data->{'concept'},$data->{'text_color'});
my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);
my($viewdate) = sprintf("%04d/%02d/%02d %02d:%02d", $year,$month,$day,$hour,$min);
my($control_box,$comments,$viewres,$trclass_in,$class,$handle_style,$report_check_box,$control_flag,$name);
our($del,$xclose);

	if( my $target = $data->{'handle'}){
		$name = shift_jis_return($target);
	} else {
		$name = $data->{'name'};
	}

my $link = qq($basic_init->{'auth_url'}$account2/);

	$comment =~ s/<br>/ /g;

	if( my $message = $fillter->each_comment_fillter_on_shift_jis($comment)){
		$comment = $message;
	}

($comment) = Mebius::auto_link($comment);

	# 文字色
	if($text_color2){
		$comment = qq(<span style="color:$text_color2;">$comment</span>);
		$handle_style = qq( style="color:$text_color2;");
	}

	if($res && $res !~ /\D/){ $viewres = qq(No.$res); }

	# ▼違反報告ボックス
	if(Mebius::Report::report_mode_judge() && $res ne ""){
		my $comment_deleted_flag = 1 if($key ne "1");
		my $year_select_name = "_${year}";
		($report_check_box) = shift_jis(Mebius::Report::report_check_box_per_res({ comment_deleted_flag => $comment_deleted_flag },"sns_comment_boad_${account}_${res}$year_select_name"));
		# handle => $handle_utf8 , handle_deleted_flag => $res_concept{'Deleted-handle'} 
		#$res_number
	# ▼コメント操作ボックスを定義
	} elsif($my_account->{'login_flag'} && ($my_account->{'admin_flag'} || $main::submode1 eq "viewcomment")){

		my $input_name;

			if($res ne ""){
				$input_name = qq(sns-comment-delete-by-res_number-$account-$res);
			} else {
				$input_name = qq(sns-comment-delete-by-regist_time-$account-$rgtime);
			}
			if($year){
				$input_name .= qq(-).e($year);
			}

			# 削除ボックス ( 一般用 )
			if($key eq "1" && ($account eq $my_account->{'file'} || $account2 eq $my_account->{'file'}) && !$my_account->{'admin_flag'}){ # $accounts[0] eq
				$control_box .= qq( <input type="checkbox" name=").e($input_name).qq(" value="delete"$xclose>削除);
			}


			# 罰削除ボックス ( 管理用 )
			if($my_account->{'admin_flag'} || Mebius::Admin::admin_mode_judge()){

					# 操作ボックスの整形（管理用）
					if($control_box){
						$control_box = qq( <label><input type="radio" name=").e($input_name).qq(" value="").e($main::parts{'checked'}).qq(><span>未選択</span></label>$control_box);
					}

				$control_box .= qq( <label><input type="radio" name=").e($input_name).qq(" value="no-reaction"><span>対応しない</span></label>);

					if($key eq "1"){
						$control_box .= qq( <label><input type="radio" name=").e($input_name).qq(" value="penalty"><span class="red">罰削除</span>);
					}

					# 削除ボックス ( 管理用 )
					if($key eq "1"){
						$control_box .= qq( <label><input type="radio" name=").e($input_name).qq(" value="delete"><span>削除</span></label>);
					}

					# 復活ボックス
					if($key ne "1"){
						$control_box .= qq( <label><input type="radio" name=").e($input_name).qq(" value="revive"><span class="blue">復活</span></label>);
					}

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
		
			if($my_account->{'admin_flag'}){ $comment = qq(<span class="deleted">$comment $deleted_text $res_concept2</span>); }
			else{ $comment = qq(<span class="deleted">$deleted_text</span>); }

		$name = "";

	}

	# 行の表示スタイルを定義
	if($key ne "1" && $my_account->{'admin_flag'}){ $trclass_in = qq( deleted); }
	elsif($use->{'css_class_in'}){ $trclass_in = $use->{'css_class_in'}; }

#	elsif($type =~ /Multi-accounts/){ $trclass_in = qq( $multi_background_class{$account}); }
#	elsif($i_foreach % 2 == 0){ $trclass_in = qq( shadow); }

	# 表示行を定義（携帯）
	if($my_use_device->{'mobile_flag'}){
		$comments .= qq(<div id="C$res"><a href="$link"$class>$name - $account2</a>);
		$comments .= qq( ( <a href="$link#COMMENT">返信</a> )<br$main::xclose>$comment $del);
		$comments .= qq( $viewdate - $viewres$control_box);
		$comments .= $report_check_box;
		$comments .= qq(</div>);
	}

	# 表示行を定義（ＰＣ）
	else{
		$comments .= qq(<div class="dcm $trclass_in" id="C$res">);
		$comments .= qq(<a href=").e($link).qq("$class$handle_style>$name \@$account2</a>);
		$comments .= qq( &gt; $comment $del);

			#if($account2 ne $account){
			if($use->{'multi_flag'}){
				$comments .= qq( ( <a href="$basic_init->{'auth_url'}${account}/viewcomment#C$res">発言</a> ));
			}
			else{
				$comments .= qq( ( <a href="${link}viewcomment#COMMENT-INPUT">返信</a> ));
			}
			#}
			if($my_account->{'file'} && $account ne $account2 && !$use->{'multi_flag'} && $my_account->{'file'}){
				$comments .= qq( ( <a href="/viewcomment-multi-$account,$account2.html">履歴</a> ) ); 
			}

		$comments .= qq(<div class="right">$viewdate - $viewres$control_box</div>);
			if($my_account->{'master_flag'}){
				$comments .= qq(<div class="right">$xip</div>);
			}
		$comments .= $report_check_box;
		$comments .= qq(</div>\n);
	}

$comments;

}

package Mebius::Auth;

#-----------------------------------------------------------
# 伝言板へのコメント履歴
#-----------------------------------------------------------
sub CommentBoadHistory{

# 宣言
my($type,$account) = @_;
my(undef,undef,$new_account,$new_res_number,$new_handle) = @_ if($type =~ /New-comment/);
my($file_handler,$i,%comment_history,@renew_line,$oneline_line,$index_line,@new_res_number);

# アカウント名判定
if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ファイル定義
my $directory1 = "${account_directory}comments/";
my $file = "${directory1}commentboad_history.log";

# ファイルを開く
open($file_handler,"<$file");

	# ファイルロック
	if($type =~ /Renew/){ flock($file_handler,1); }

# トップデータを分解
chomp(my $top1 = <$file_handler>);
($comment_history{'concept'}) = split(/<>/,$top1);

	# ファイルを展開
	while(<$file_handler>){

		# 局所化
		my($res_number_counts2,@res_number2);

		# ラウンドカウンタ
		$i++;
		
		# この行を分解
		chomp;
		my($key2,$account2,$res_number2,$handle2,$lasttime2,$date2) = split(/<>/);

			# 変数調整
			foreach(split(/\s/,$res_number2)){
				push(@res_number2,$_);
				$res_number_counts2++;
			}
			my $first_res_number2 = $res_number2[0];

			# 新規登録の場合
			if($type =~ /New-comment/){
					# 重複はエスケープ
					if($account2 eq $new_account){
						@new_res_number = @res_number2;
						next;
					}
			}

			# 更新行を追加
			if($type =~ /Renew/){

					# 最大行数に達した場合
					if($i >= 100){ last; }

				push(@renew_line,"$key2<>$account2<>@res_number2<>$handle2<>$lasttime2<>$date2<>\n");
			}


			# インデックス取得用
			if($type =~ /Get-index/){

					# 最大行数に達した場合
					if($i >= 30){ last; }

				$index_line .= qq(<tr>\n);
				$index_line .= qq(<td>);
				$index_line .= qq(<a href="${main::auth_url}$account2/">$handle2 - $account2</a>);
				$index_line .= qq(</td>);
				$index_line .= qq(<td>);
				$index_line .= qq(( <a href="${main::auth_url}$account2/viewcomment">伝言板</a> ));
				$index_line .= qq(</td>);
				$index_line .= qq(<td>);
				$index_line .= qq(<a href="${main::auth_url}$account2/viewcomment#C$first_res_number2">&gt;&gt;$first_res_number2</a>);
				$index_line .= qq(</td>);
				$index_line .= qq(<td>);
				$index_line .= qq($res_number_counts2);
				$index_line .= qq(</td>);
				$index_line .= qq(<td>);
				$index_line .= qq($date2);
				$index_line .= qq(</td>);

				$index_line .= qq(</tr>\n);

			}

			# トピックス取得用
			if($type =~ /Get-oneline/ && $i <= 5){
				$oneline_line .= qq(<a href="${main::auth_url}$account2/#COMMENT">$handle2</a>\n);
			}

	}

close($file_handler);

	# インデックス整形
	if($type =~ /Get-index/){

		
	}

	# 新しくコメントした場合
	if($type =~ /New-comment/){
		unshift(@new_res_number,$new_res_number);
		unshift(@renew_line,"<>$new_account<>@new_res_number<>$new_handle<>$main::time<>$main::date<>\n");
	}

	# ファイル更新
	if($type =~ /Renew/){

		# トップデータを追加
		unshift(@renew_line,"$comment_history{'concept'}<>\n");

		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory1);

		# ファイル更新
		Mebius::Fileout(undef,$file,@renew_line);
	}
	

# ハッシュ調整
$comment_history{'oneline_line'} = $oneline_line;

	# インデックス整形
	if($type =~ /Get-index/){
		$comment_history{'index_line'} .= qq(<table>);
		$comment_history{'index_line'} .= qq(<tr>);
		$comment_history{'index_line'} .= qq(<th>アカウント</th><th>伝言板</th><th>レス番</th><th>投稿数</th><th>日付</th>);
		$comment_history{'index_line'} .= qq(</tr>);
		$comment_history{'index_line'} .= qq($index_line);
		$comment_history{'index_line'} .= qq(</table>);

	}




return(%comment_history);

}

package main;

#-----------------------------------------------------------
# コメント実行
#-----------------------------------------------------------
sub auth_comment{

my $all_comments = new Mebius::AllComments
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my($file,$line,$i,$timeline,$pastline,$indexline,$waittop1,$add_pastline,$i,$newresnumer);
my($init_directory) = Mebius::BaseInitDirectory();
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;
my $time = time;
my $param_sjis = Mebius::Query->single_param_shift_jis();
my $query = new Mebius::Query;
my $param  = $query->param();our($thisyear,$thismonth,$today,$thishour,$thismin,$thissec,$date,$xip);
my %in = our %in;

# 最大ログ数（現行）
my $maxcomment = 1000;

# １コメントの待ち秒数
my $next_wait_comment = 30;

# エラー時のフック内容
$main::fook_error = qq(入力内容： $in{'comment'});

# 汚染チェック
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

my $comment_utf8 = utf8_return($param->{'comment'});
	if($all_comments->dupulication_error($comment_utf8)){
		main::error("▼重複投稿です。");
	}

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ログイン中のみコメント可能
	if(!$my_account->{'login_flag'}){ &error("コメントするにはログインしてください。"); }

# アクセス制限
main::axscheck("ACCOUNT Post-only");

	# チャージ時間チェック
	if(time < $my_account->{'next_comment_time'} && !$my_account->{'admin_flag'} && !Mebius::alocal_judge()){
		my($left_charge) = Mebius::SplitTime(undef,$my_account->{'next_comment_time'} - time);
		main::error("チャージ時間中です。あと $left_charge お待ちください。");
	}

# 相手のプロフィールを開く
my(%account) = Mebius::Auth::File("Hash File-check-error Key-check-error Lock-check-error Option",$file);

# 各種チェック
require "${init_directory}regist_allcheck.pl";
Mebius::Regist::name_check($my_account->{'name'});
($in{'comment'}) = &all_check(undef,$in{'comment'});
my($new_text_color) = Mebius::Regist::color_check(undef,$main::in{'color'});
&error_view("View-break-button AERROR");

# 文字数チェック
if(length($in{'comment'}) > $main::max_msg_comment*2){
my $length = int(length($in{'comment'}) / 2);
&error("コメントが長すぎます。全角$main::max_msg_comment文字に収めてください。（現在$length文字）");
}

# 本文がない場合
if (($in{'comment'} eq "")||($in{'comment'} =~ /^(\x81\x40|\s|<br>)+$/)) { &error("コメント内容がありません。"); }
if($in{'comment'} =~ /(文通|手紙)/){ &error("「文通」「手紙」のキーワードは使えません。文通相手募集など、個人情報の交換は絶対にしないでください。本サイトの利用を永遠にお断りさせていただく場合があります。"); }

# お互いの禁止状態をチェック
my($friend_status1) = Mebius::Auth::FriendStatus("Deny-check-error",$account{'file'},$my_account->{'file'});
my($friend_status2) = Mebius::Auth::FriendStatus("Deny-check-error",$my_account->{'file'},$account{'file'});

	# アカウント休眠中の場合
	if($account{'let_flag'} && !$my_account->{'admin_flag'}){ main::error("$account{'let_flag'}"); }

	# コメント可否を判定
	if(!$account{'myprof_flag'} && !$my_account->{'admin_flag'}){
			if($account{'ocomment'} eq "0"){ &error("アカウント主以外はコメントできません。"); }
			elsif($account{'ocomment'} eq "2" && $friend_status1 ne "friend"){ &error("$main::friend_tag以外はコメントできません。"); }
			elsif($account{'ocomment'} eq "3"){ &error("伝言版は非公開になっています。"); }
	}
	if($main::birdflag){ &error("コメントするにはあなたの筆名を設定してください。"); }


# ロック開始
&lock("auth${file}");

my $pfcdate = "$thisyear,$thismonth,$today,$thishour,$thismin,$thissec";

# コメントファイル読み込み
open(COMMENT_IN,"<","${account_directory}comments/${file}_comment.cgi");
chomp(my $top_comment = <COMMENT_IN>);
my($res,$lasttime) = split(/<>/,$top_comment);
$res++;
$line .= qq($res<>\n);
my $newresnumber = $res;
$line .= qq(1<>$time<>$my_account->{'id'}<>$my_account->{'name'}<>$my_account->{'enctrip'}<>$my_account->{'encid'}<>$in{'comment'}<>$pfcdate<>$xip<>$res<><><><>$new_text_color<>\n);

# システム変更時の調整（１行分）
if($lasttime){ $line .= qq($top_comment\n); }
	while(<COMMENT_IN>){
		if($i < $maxcomment-1){ $line .= $_; }
		$i++;
	}
close(COMMENT_IN);

# コメントファイル書き出し
Mebius::Fileout(undef,"${account_directory}comments/${file}_comment.cgi",$line);

# 過去ログ、コメントファイルを読み込み
open(COMMENT_PAST_IN,"<","${account_directory}comments/${file}_${thisyear}_comment.cgi");
	while(<COMMENT_PAST_IN>){
		$pastline .= $_;
	}
close(COMMENT_PAST_IN);

	# 今月の過去ログがなければ、コメントのインデックスに行を追加
	if($pastline eq ""){

		# インデックスに追加する行
		$indexline .= qq(${thisyear}<>\n);

		# コメントインデックスを読み込み
		open(INDEX_PAST_IN,"<","${account_directory}comments/${file}_index_comment.cgi");
		while(<INDEX_PAST_IN>){
			my($year) = split(/<>/,$_);
			if($year ne $thisyear){ $indexline .= $_; }
		}
		close(COMMENT_PAST_IN);

		# コメントインデックスに書き込み
		Mebius::Fileout(undef,"${account_directory}comments/${file}_index_comment.cgi",$indexline);

	}

# 過去ログに追加する行
$add_pastline .= qq(1<>$time<>$my_account->{'id'}<>$my_account->{'name'}<>$my_account->{'enctrip'}<>$my_account->{'encid'}<>$in{'comment'}<>$pfcdate<>$xip<>$res<><><><>$new_text_color<>\n);

# ディレクトリ作成
Mebius::mkdir("${account_directory}comments/");

# 過去ログ、コメントファイルを書き出し
my $past_file_line = $add_pastline . $pastline;
Mebius::Fileout(undef,"${account_directory}comments/${file}_${thisyear}_comment.cgi",$past_file_line);

# 新着インデックスを開く
my $line_allcomment .= qq(1<>$file<>$account{'name'}<>$my_account->{'id'}<>$my_account->{'name'}<>$in{'comment'}<>$date<>$res<>\n);
my($iallcomment);
open(ALLCOMMENT_IN,"<","${auth_log_directory}newcomment.cgi");
	while(<ALLCOMMENT_IN>){
		$iallcomment++;
			if($iallcomment < 500) { $line_allcomment .= $_; }
	}
close(ALLCOMMENT_IN);

# 新着インデックスを書き込む
Mebius::Fileout(undef,"${auth_log_directory}newcomment.cgi",$line_allcomment);

# ロック解除
&unlock("auth${file}");

# 自分のオプションファイルを更新
my(%renew_myoption);
$renew_myoption{'next_comment_time'} = time + 15;
$renew_myoption{'comment_font_color'} = $new_text_color;
#Mebius::Auth::Optionfile("Renew",$my_account->{'file'},%renew_myoption);
Mebius::Auth::File("Renew Option",$my_account->{'file'},\%renew_myoption);



	# 相手アカウントの 「最近の更新」ファイルを更新
	if(!$account{'myprof_flag'} || Mebius::alocal_judge()){
		Mebius::Auth::News("Renew Hidden-from-index Log-type-comment",$file,$my_account->{'id'},$my_account->{'handle'},qq(<a href="$main::auth_url$file/viewcomment#C$newresnumber">伝言板</a>へのレス\(No.$newresnumber\)));
	}

# 総レス数を更新
Mebius::Newlist::Daily("Renew Comment-auth");

# 相手アカウントにメールを送信
my %mail;
$mail{'url'} = "$account{'file'}/viewcomment#COMMENT";
$mail{'comment'} = $main::in{'comment'};
$mail{'subject'} = qq($my_account->{'name'}さんが伝言板に書き込みました。);
Mebius::Auth::SendEmail(" Type-comment",\%account,\%main::myaccount,\%mail);

# 伝言板へのコメント履歴を更新
Mebius::Auth::CommentBoadHistory("New-comment Renew",$my_account->{'file'},$file,$res,$account{'name'});

# 自分の基本投稿履歴ファイルを更新
Mebius::HistoryAll("Renew My-file");

$all_comments->submit_new_comment($comment_utf8);

# ジャンプ先$jump_sec = $auth_jump;
my $jump_url = "$main::auth_url${file}/#COMMENT";

# クッキーをセット
#Mebius::Cookie::set_main({ font_color => $new_text_color },{ SaveToFile => 1 });

# リダイレクト
	if($param->{'backurl'}){
		Mebius::Redirect("",$param->{'backurl'}."#COMMENT");
	} else {
		Mebius::Redirect("",$jump_url);
	}
# 処理終了
exit;

}

1;
