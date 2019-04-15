package main;

#-----------------------------------------------------------
# 新規投稿の待ち時間を計算
#-----------------------------------------------------------
sub sum_newwait{

# 宣言
my($type) = @_;
my($flag,$lefttime,$leftday,$lefthour,$leftmin,$ip_new_time,$bonusform_flag,$next_newwait_day,$next_newwait_hour);
my($threadnum,$none);
our($nowfile,$newwait,$time,$cnewtime,$no_xip_action,$idcheck,$cgold,$cnew_time,$xip_enc,$fastpost_mode);
my($share_directory) = Mebius::share_directory_path();

# クッキーから現在のチャージ時間を算出
if($cnew_time && $time < $cnew_time) { $lefttime = ($cnew_time - $time) / 60; $newwait_flag = 1; } 

my $file = "${share_directory}_ip/_ip_new/${xip_enc}.cgi";

# ＸＩＰから現在のチャージ時間を算出
open(IP_NEW_IN,"<",$file);
$ip_new_time = <IP_NEW_IN>;
close(IP_NEW_IN);
if(!$no_xip_action && $time < $ip_new_time) { $lefttime = ($ip_new_time - $time) / 60; $newwait_flag = 1; }

# ファイルを削除する場合
	if($type =~ /UNLINK/){
		if(!$newwait_flag){ return(0); }
		else{ unlink($file); return(1); }
	}

# ＦＡＳＴモード
#if($fastpost_mode || $alocal_mode){ $new_wait = 1; $newwait_flag = undef; $lefttime = 0; }
if($fastpost_mode){ $new_wait = 1; $newwait_flag = undef; $lefttime = 0; }

# ローカルで制限解除
#if($alocal_mode && $i_com =~ /ブレイク/){ $flag = ""; }

# 現在の残りチャージ時間を計算
my($leftdate) = Mebius::SplitTime("Not-get-second",$lefttime*60);

# 現在の記事数を調べ、ボーナスモードを発動
open(NOWFILE,"$nowfile");
$none = <NOWFILE>;
while(<NOWFILE>){ $threadnum++; }
close(NOWFILE);

# 記事数が少ない場合、簡易投稿フォームを解放し、次の待ち時間を減らす
if($threadnum < $new_wait){
$new_wait = int($threadnum * 0.25);
$bonusform_flag = 1;
}


# 金貨が多いと優遇
if($idcheck && $cgold > 500){ $new_wait = int($new_wait*0.5); }

# 次回のチャージ時間（予測）を算出
$next_newwait_day = int($new_wait / 24);
$next_newwait_hour = int $new_wait - ($next_newwait_day*24);

return($newwait_flag,$leftdate,"$next_newwait_day日$next_newwait_hour時間",$bonusform_flag);

}

#-----------------------------------------------------------
# 新規投稿のペナルティ時間を取得
#-----------------------------------------------------------
sub sum_newwait_penalty{

# 宣言
our($cnumber,$agent,$host,$k_access,$postflag);

	# ホスト名がない場合は取得する
	if($host eq ""){
		($host) = Mebius::GetHostWithFile();
	}

if($cnumber){ &sum_newwait_penalty_do($cnumber); }
if($k_access && $postflag){ &sum_newwait_penalty_do($agent); }
elsif(!$k_access){ &sum_newwait_penalty_do($host); }

}

#-----------------------------------------------------------
# 新規投稿、各種ペナルティ時間を計算
#-----------------------------------------------------------
sub sum_newwait_penalty_do{

# 宣言
my($file) = @_;
my($top,$text1);
my($share_directory) = Mebius::share_directory_path();
our($time,$css_text);

# CSS定義
$css_text .= qq(
.your{font-size:140%;}
);

# ファイル定義
($file) = Mebius::Encode("",$file);
if($file eq ""){ return; }

# ファイルを開く
open(DTIME_IN,"<","${share_directory}_ip/_ip_delnew/$file.cgi");
$top = <DTIME_IN>; chomp $top;
my($oktime,$bbs,$no) = split(/<>/,$top);
close(DTIME_IN);

# 待ち時間を計算
my ($leftdate) = Mebius::SplitTime("Not-get-second",$oktime - $time);

# エラー文章
if($bbs && $no){ $text1 = qq(<a href="/$bbs/$no.html" class="your">あなたの作った記事</a>); }
else{ $text1 = qq(あなたの作った記事); }

my $text = qq(管理者によって $text1 が削除されたため、しばらく新規投稿できません。<br$xclose>
申\し訳ありませんが、あと $leftdate ほどお待ちください。
<br$xclose>
<br$xclose>○重複記事、似ている記事を作りませんでしたか？
<br$xclose>○記事のテーマはひとつに絞り、適切なタイトルをつけましたか？
<br$xclose>○ローカルルールに反する内容はありませんでしたか？
<br$xclose>○参加者の制限や、個人的な記事を作りませんでしたか？
<br$xclose>○記事を作るカテゴリは適切でしたか？

<br$xclose>
<br$xclose><a href="${guide_url}">総合ガイドライン</a>やローカルルールを再度ご確認ください。
<a href="http://aurasoul.mb2.jp/_qst/1980.html">ご質問はこちらまでどうぞ</a>。<br$xclose>
);

# ペナルティ時間がある場合、エラー
if($oktime && $time < $oktime){ &error($text); }

}

1;
