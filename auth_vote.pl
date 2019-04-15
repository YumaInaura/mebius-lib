
use strict;
package Mebius::Auth::Vote;
use Mebius::Export;

#-----------------------------------------------------------
# 基本設定
#-----------------------------------------------------------
sub Init{

my($comments);

# 日付を取得
my($multi_date) = Mebius::now_date_multi();

	if($multi_date->{'ymdf'} =~ /^(\d+)-01-(01|02|03)$/){ $comments .= qq( あけましておめでとう ); }
	if($multi_date->{'ymdf'} =~ /^(\d+)-02-03$/){ $comments .= qq( まめまき ); }
	if($multi_date->{'ymdf'} =~ /^(\d+)-02-14$/){ $comments .= qq( ちょこれーと ); }
	if($multi_date->{'ymdf'} =~ /^(\d+)-03-03$/){ $comments .= qq( ひなだん ); }
	if($multi_date->{'ymdf'} =~ /^(\d+)-03-14$/){ $comments .= qq( ほわいとちょこ ); }
	if($multi_date->{'ymdf'} =~ /^(\d+)-07-07$/){ $comments .= qq( ささのはさらさら ); }
	if($multi_date->{'ymdf'} =~ /^(\d+)-10-31$/){ $comments .= qq( かぼちゃ ); }
	if($multi_date->{'ymdf'} =~ /^(\d+)-12-(24|25)$/){ $comments .= qq( めりくりすます ); }
	if($multi_date->{'ymdf'} =~ /^(\d+)-12-31$/){ $comments .= qq( いちねんおつかれさま ); }

$comments .= 'にゃー ありがとう おめでとう にっきよかった ふぁいと おつかれさま ごめんなさい おやすみ おはよう おなかすいた';
return(
maxvote=>3,
comments=>$comments,
);
}

#-----------------------------------------------------------
# アカウントの関連記事を表示
#-----------------------------------------------------------
sub Mode{

# 宣言
my($type,$submode2,%in) = @_;
my(%account);

# アカウントを開く
(%account) = Mebius::Auth::File("Option",$in{'account'});

	# タイプ定義
	if($submode2 eq ""){ &Index("",%account); }
	elsif($submode2 eq "plus"){
		main::axscheck("Postonly ACCOUNT");
		&Data("Renew Plus",$account{'file'});
	}
	else{ main::error("実行タイプを指定してください。"); }

# 例外エラー
main::error("何かが足りません。");

exit;

}

#-----------------------------------------------------------
# 投票の基本ページ
#-----------------------------------------------------------
sub Index{

# 宣言
my($type,%account) = @_;
my(%init) = &Init();
my(%data,$submit_button,$vote_form,%myaccount,$index_line,$history_line,$reason_select,$index_line_view,$disabled_flag);

# 自分の残り投票ポイントをチェック
#(%myaccount) = Mebius::Auth::Optionfile("Get",$main::pmfile);
my($my_account) = Mebius::my_account();

# 投票データのインデックスを取得
($index_line,$history_line) = &Data("Index",$account{'file'});

	# 残り投票ポイントが無い場合
	#if($main::cgold <= -1){
	#	$submit_button = qq(<span style="color:#f00;font-size:small;">※あなたの金貨がマイナスのため、猫を増やせません。</span>);
	#	$disabled_flag = 1;
	#}
	#els

	if($my_account->{'allow_vote'} eq "not-use"){
		$submit_button = qq(<span style="color:#f00;font-size:small;">※あなたが猫を受け取らない設定にしていると、猫をあげられません。</span>);
		$disabled_flag = 1;
	}
	elsif($my_account->{'todayvotepoint'} <= 0){
		$submit_button = qq(<span style="color:#f00;font-size:small;">※手持ちのポイントがありません、明日までお待ちください。</span>);
		$disabled_flag = 1;
	}
	elsif($account{'allow_vote'} eq "not-use"){
		$submit_button = qq(<span style="color:#f00;font-size:small;">※このメンバーは猫を受け取っていません。</span>);
		$disabled_flag = 1;
	}
	else{
		$submit_button = qq(<input type="submit" value="猫を増やす"$main::xclose>);
	}

# CSS定義
$main::css_text .= qq(
td,th{padding:0.2em 1em 0.2em 0em;}
div.about_sozai{text-align:right;}
img.nekoasi{width:20px;height:19px;}
table.vote th{text-align:left;}
);

	# 投票理由のセレクトボックス
	if(!$disabled_flag){
		$reason_select .= qq(<select name="reason">\n);
		#$reason_select .= qq(<option>気持ち</option>\n);
			foreach(split(/\s/,$init{'comments'})){
				if(!$_){ next; }
				$reason_select .= qq(<option>$_</option>\n);
			}
		$reason_select .= qq(</select>);
	}

# フォーム定義
$vote_form = qq(
<h2$main::kfontsize_h2>猫を増やす</h2>
<ul>
<li><a href="$main::auth_url$account{'file'}/">$account{'name'} - $account{'file'}</a> さんの猫を増やせます。</li>
<li>今日はあと <strong style="color:#f00;">$my_account->{'todayvotepoint'}回</strong> まで実行できます。</li>
</ul>
<form action="$main::auth_url" method="post"$main::sikibetu>
<div>
<input type="hidden" name="mode" value="vote-plus"$main::xclose>
<input type="hidden" name="account" value="$account{'file'}"$main::xclose>
<br$main::xclose>$submit_button
$reason_select
</div>
</form>
);

	
	# ログインしていない場合、フォームを消す
	if(!$main::idcheck){ $vote_form = ""; }

	# 自分の場合
	if($account{'myprof_flag'}){ $vote_form = ""; }
	
	# 猫をくれた人たち
	if($index_line){
		$index_line_view .= qq(<h2$main::kfontsize_h2>猫をくれた人たち</h2>);
			if($main::kflag){ $index_line_view .= qq($main::khrtag); }
			else{ $index_line_view .= qq(<table summary="猫履歴" class="width100 vote"><tr><th>何匹目？</th><th colspan="3">猫をくれた人</th><th>その時の気持ち</th><th>時刻</th></tr>); }
		$index_line_view .= qq($index_line);
			if(!$main::kflag){ $index_line_view .= qq(</table>); }

		# アイコン配布元を表示
		$index_line_view .= qq(<div class="about_sozai"><a href="${main::guide_url}%A5%E9%A5%A4%A5%BB%A5%F3%A5%B9#p2">アイコン素材について</a></div>);
	}

	# CSS定義
	if($account{'color1'}){
		$main::css_text .= qq(h2{background-color:#$account{'color1'};border-color:#$account{'color1'};});
	}

# HTML部分
my $print = qq(
$vote_form
$index_line_view
<h2$main::kfontsize_h2>猫帳簿(月別)</h2>
<ul>
$history_line
</ul>
);


# ヘッダ
main::auth_html_print($print,"猫",\%account);

exit;

}

#-----------------------------------------------------------
# 個別データファイル
#-----------------------------------------------------------
sub Data{

# 宣言
my($type,$file) = @_;
my(%init) = &Init();
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
my(undef,undef,$max_view) = @_ if($type =~ /Index/);
my($datafile,$vote_handler,@renewline,$i,$maxline,%account,%renew_option,%myaccount,%renew_myoption,$index_line);
my($same_yearmonth_flag,@thistory,$history_line,$newreason,$hit_index,$all_vote_count,$new_vote_point,$new_account2_vote_point);

# ファイル定義
$file =~ s/\W//g;
if($file eq ""){ return(); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

$datafile = "${account_directory}${file}_vote.log";

	# ■ファイル更新用の前処理
	if($type =~ /Renew/){

		# アクセス制限 # なぜここでアクセス制限を？
		#main::axscheck("Postonly ACCOUNT");

		# 相手のアカウントを開く
		(%account) = Mebius::Auth::File("Hash Option Lock-check",$file);

		# 自分のアカウントを開く
		(%myaccount) = Mebius::Auth::File("Hash Option",$main::pmfile);

			# 猫を増やす場合の各種エラー
			if($type =~ /Plus/){
					if($my_account->{'allow_vote'} eq "not-use"){ main::error("猫を受け取らない設定にしていると、猫をあげられません。"); }
					if($account{'allow_vote'} eq "not-use"){ main::error("このメンバーは猫を受け取っていません。"); }
					if($myaccount{'todayvotepoint'} <= 0){ main::error("手持ちの猫ポイントがありません。明日まで待ってください。"); }
					if($account{'myprof_flag'} && !Mebius::alocal_judge()){ main::error("自分の猫は増やせません。"); }
					if($account{'sameaccess_flag'} && !$main::myadmin_flag && !Mebius::alocal_judge()){ main::error("自分の猫は増やせません。"); }
					if(!$main::pmfile){ main::error("猫を増やすには、アカウントにログインしてください。"); }
					#if($main::cgold <= -1){ main::error("あなたの金貨がマイナスのため、猫を増やせません。"); }
			}
	}

# 最大行数
$maxline = 10;

# 最大表示行数
if(!$max_view){ $max_view = 10 ;}

# ファイルを開く
open($vote_handler,"<",$datafile);

	# ファイルロック
	if($type =~ /Renew/){ flock($vote_handler,1); }

#トップデータを分解する
chomp(my $top1 = <$vote_handler>);
my($tkey,$tlasttime,$thistory) = split(/<>/,$top1);

	# 得票数、投票ポイントの操作
	if($type =~ /Plus/){
		#main::axscheck("ACCOUNT");
		$renew_option{'+'}{'votepoint'} = 1;
		$new_vote_point = $account{'votepoint'} + 1;
		$renew_myoption{'lastvote'} = "$main::thisyear-$main::thismonthf-$main::todayf";
		$renew_myoption{'-'}{'todayvotepoint'} = 1;
	}

	# 投票理由
	if($type =~ /Plus/){
			foreach(split(/\s/,$init{'comments'})){
				if($main::in{'reason'} eq $_){ $newreason = $_; }
			}
	}

	# 得票数を月別に分解する
	foreach(split(/\s/,$thistory)){
		my($year2,$month2,$count2) = split(/=/,$_);
			if("$year2=$month2" eq "$main::thisyear=$main::thismonthf"){
					if($type =~ /Renew/){ $count2++; }
				#$thismonthcount = $count2;
				$same_yearmonth_flag = 1;
			}
		$all_vote_count += $count2;

			if($type =~ /Index/){ $history_line .= qq(<li>$year2/$month2 - $count2猫</li>); }
		push(@thistory,"$year2=$month2=$count2");
	}

	# 壊れてしまった当月データを元に戻す	# 2012/1/25 
	#if($all_vote_count > $account{'votepoint'}){
	#	$renew_option{'votepoint'} = $all_vote_count;
	#}

	# 得票履歴が無い場合、総得票数を代入して新規作成
	if(@thistory <= 0 && $type =~ /Plus/){ unshift(@thistory,"$main::thisyear=$main::thismonthf=$account{'votepoint'}"); }

	# 新しい月の場合
	elsif(!$same_yearmonth_flag && $type =~ /Plus/){
		unshift(@thistory,"$main::thisyear=$main::thismonthf=1");
	}

	# トップデータを取得してハッシュとして返す
	#if($type =~ /Topdata/){
	#	close($vote_handler);
	#}

	# ファイルを展開する
	while(<$vote_handler>){

		# ラウンドカウンタ
		$i++;

		# この行を分解
		chomp;
		my($key2,$account2,$handle2,$lasttime2,$date2,$votenum2,$comment2,$account2_vote_point2) = split(/<>/);

			# ●ファイル更新用の処理
			if($type =~ /Renew/){

				# 最大行数に達した場合
				if($i >= $maxline){ next; }
				
				# 更新行を追加
				push(@renewline,"$key2<>$account2<>$handle2<>$lasttime2<>$date2<>$votenum2<>$comment2<>$account2_vote_point2<>\n");

			}

			#● インデックス表示用の処理
			if($type =~ /Index/){

				# 局所化
				my($votelink2,$mylink2,$nekoasi_image,$nekoasi_number,%account2);

				# ヒットカウンタ
				$hit_index++;

					# 最大表示行数に達した場合
					if($hit_index > $max_view){ last; }

					# アカウントデータを取得
					if($type !~ /Not-get-account/){

						#(%account2) = Mebius::Auth::File("Hash Option",$account2);

							# 各アカウントの猫リンク
							#if($account2{'allow_vote'} eq "not-use"){ }
							#else{ $votelink2 = qq(<a href="$basic_init->{'auth_url'}$account2/vote">猫($account2{'votepoint'})</a>); }
							#if($account2_vote_point2 ne "not-use"){
								$votelink2 .= qq(<a href="$basic_init->{'auth_url'}$account2/vote">);
								$votelink2 .= qq(猫);
								$votelink2 .= qq/($account2_vote_point2)/ if $account2_vote_point2;
								$votelink2 .= qq(</a>);
							#}

					}

				# おすすめＵＲＬ
				if($account2{'mylink'}){
						if($main::kflag){ $mylink2 = qq(<a href="$account2{'myurl'}">URL</a>); }
						else{ $mylink2 = qq($account2{'mylink'}); }
				}
		
				# 何匹目の猫？
				if($votenum2 eq ""){ $votenum2 = "？"; }

				# 足跡画像
				$nekoasi_number = int((($votenum2 / 10) % 5)+1);
				$nekoasi_image = qq(<img src="/pct/nekoasi$nekoasi_number.png" alt="足跡" class="nekoasi">);
				
				my($howlong_stamp2) = shift_jis(Mebius::second_to_howlong({ ColorView => 1 , HowBefore => 1 , GetLevel => "top" },time - $lasttime2));

				# 携帯版
				if($main::kflag){
					$index_line .= qq($votenum2匹目 $comment2);
					$index_line .= qq(<br$main::xclose><a href="$basic_init->{'auth_url'}$account2/">$handle2 - $account2</a> $mylink2 );
					$index_line .= qq(<br$main::xclose>$howlong_stamp2);
					$index_line .= qq($main::khrtag);
				}

				# PC版
				else{
					$index_line .= qq(<tr>);
					$index_line .= qq(<td>$nekoasi_image $votenum2匹目</td>);
					$index_line .= qq(<td><a href="$basic_init->{'auth_url'}$account2/">$handle2 - $account2</a></td>);
					$index_line .= qq(<td>$votelink2</td>);
					$index_line .= qq(<td>$mylink2</td>);
					$index_line .= qq(<td>$comment2 </td>);
					$index_line .= qq(<td>$howlong_stamp2</td>);
					$index_line .= qq(</tr>\n);
				}
			}

	}

close($vote_handler);

	# ▼インデックス取得用の後処理
	if($type =~ /Index/){
			if($index_line eq ""){ $index_line = qq(データがありません。); }
		return($index_line,$history_line);
	}

	# ▼ファイル更新の後処理
	elsif($type =~ /Renew/){


		# お互いの禁止状態をチェック
		Mebius::Auth::FriendStatus("Deny-check-error",$account{'file'},$main::myaccount{'file'});
		Mebius::Auth::FriendStatus("Deny-check-error",$main::myaccount{'file'},$account{'file'});

		# 相手のオプションファイルを更新 
		#Mebius::Auth::Optionfile("Renew",$file,%renew_option);
		my(%renewed_target) = Mebius::Auth::File("Renew Option",$file,\%renew_option);

		# 自分のオプションファイルを更新 
		#Mebius::Auth::Optionfile("Renew",$main::pmfile,%renew_myoption);
		my(%renewed_my_account) = Mebius::Auth::File("Renew Option",$main::pmfile,\%renew_myoption);

		# 新しい行を追加する
		unshift(@renewline,"1<>$main::pmfile<>$main::pmname<>$main::time<>$main::date<>$new_vote_point<>$newreason<>$renewed_my_account{'votepoint'}<>\n");

		# トップデータを追加する
		if($tkey eq ""){ $tkey = 1; }
		unshift(@renewline,"$tkey<>$main::time<>@thistory<>\n");

		# ファイルを更新
		Mebius::Fileout("",$datafile,@renewline);

		# 自分の行動履歴を更新する
		Mebius::Auth::History("Renew",$main::pmfile,$file,qq(の<a href="$basic_init->{'auth_url'}$file/vote">猫</a>を増やしました。));

		# 基本投稿履歴を更新
		Mebius::HistoryAll("RENEW My-file");

		# 相手の新着情報を更新する
		Mebius::Auth::News("Renew Hidden-from-index Log-type-vote",$file,$main::pmfile,$main::myaccount{'handle'},qq(<a href="$basic_init->{'auth_url'}$file/vote">猫</a>をもらいました ($renewed_target{'votepoint'}匹目)));

		# リダイレクト
		Mebius::Redirect("","$basic_init->{'auth_url'}$file/vote");

	}

return();

}


1;
