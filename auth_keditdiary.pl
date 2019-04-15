
use Mebius::Auth;
use Mebius::SNS::Crap;
use Mebius::Penalty;

#-----------------------------------------------------------
# SNS 日記本体を操作
#-----------------------------------------------------------
sub auth_keditdiary{

# 局所化
my($type);
my($file,$open,$line,$indexline,$pastline,$flag,$top1,$yearfile,$monthfile,$newkey);
my($diary_handler,$diary_index_handler,$penalty_flag,$repair_flag,@renew_diary,%renew_account,%renew);
our($backurl,$backurl_jak_flag);

	# 変更するキー値を定義
	# ロックする場合
	if($in{'decide'} eq "lock"){ $newkey = "0"; }
	# 削除する場合
	elsif($in{'decide'} eq "delete"){
		$type .= qq( Delete-diary);
	if($myadmin_flag){ $newkey = "4"; } else { $newkey = "2"; }
	}
	elsif($in{'decide'} eq "revive"){
		$type .= qq( Revive-diary);
		$newkey = "1";
	}
	else{ &error("値を正しく指定してください。"); }



# 汚染チェック１
Mebius::Auth::AccountName("Error-view",$in{'account'});
$file = $in{'account'};

# 汚染チェック１
$open = $in{'num'};
$open =~ s/\D//g;
	if($open eq ""){ &error("値を正しく指定してください。"); }

	# ログインしていない場合
	if(!$idcheck){ &error("日記を削除するには、ログインしてください。"); }

	# 本人でも管理者でもない場合
	if(!$myadmin_flag && $file ne $pmfile){ &error("日記は本人しか削除できません。"); }

	# プロフィールを開く
	my(%account) = Mebius::Auth::File("Get-hash Option File-check-error",$file);

	# プレビューの場合
	if($in{'preview'} eq "on"){ &auth_keditdiary_preview("",$file,$open); }

# ロック開始
&lock("auth$file") if $lockkey;

# 日記単体ファイルを開く
my($diary) = Mebius::Auth::diary("File-check-error",$file,$open);

	# 削除済みの場合、管理者以外は変更できないように
	if( ($diary->{'key'} eq "4" || $diary->{'key'} eq "2") && !$myadmin_flag){
		Mebius::AccessLog(undef,"Account-diary-delete-missed");
		&error("実行できませんでした。");
	}
	else{
		Mebius::AccessLog(undef,"Account-diary-delete-successed");
	}

# 引き継ぎ？部分
$yearfile = $diary->{'year'};
$monthfile = $diary->{'month'};

# 更新部分
$renew{'key'} = $newkey;
$renew{'control_datas'} = qq($pmfile=$pmname=$date);
$renew{'concept'} = $diary->{'concept'};

	# ペナルティと復活権限フラグを立てる
	# 削除する場合
	if($myadmin_flag && $in{'decide'} eq "delete" && $in{'penalty'}){
		$penalty_flag = 1;
		$renew{'concept'} .= qq( Penalty-done);
	}
	# 復活する場合
	if($myadmin_flag && $in{'decide'} eq "revive" && $diary->{'concept'} =~ /Penalty-done/){
		$renew{'concept'} =~ s/Penalty-done//g;
		$repair_flag = 1;
	}

# 日記を更新
Mebius::Auth::diary("Renew",$file,$open,\%renew);

	# 管理者削除の場合、ペナルティを生成
	if($penalty_flag){

		# 一般ペナルティ
		Mebius::Authpenalty("Penalty",$file,$diary->{'comment'},"SNSの日記 - $diary->{'subject'}","${auth_url}$file/d-$open");

		# SNSペナルティ
		Mebius::AuthPenaltyOption("Penalty",$file,3*24*60*60);

	}

	# 管理者復活の場合、ペナルティを解除
	if($repair_flag){

		# 一般ペナルティ
		Mebius::Authpenalty("Repair",$file);

		# SNSペナルティ
		Mebius::AuthPenaltyOption("Penalty",$file,-3*24*60*60);

	}

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# 現行インデックスを開く
open($diary_index_handler,"<","${account_directory}diary/${file}_diary_index.cgi");
flock($diary_index_handler,1);
my $nowtop1 = <$diary_index_handler>;
$indexline .= $nowtop1;

	# ファイルを展開
	while(<$diary_index_handler>){
		chomp $_;
		my($key,$num,$sub,$res,$dates,$newtime) = split(/<>/,$_);
			if($open eq $num){
				$key = $newkey;
				$indexline .= qq($key<>$num<>$sub<>$res<>$dates<>$newtime<>\n);
				my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);
			}
			else{ $indexline .= qq($_\n); }
	}
close($diary_index_handler);

# 現行インデックスを書き出し
Mebius::Fileout("","${account_directory}diary/${file}_diary_index.cgi",$indexline);

# 汚染チェック３
$yearfile =~ s/\D//g;
$monthfile =~ s/\D//g;

	# ヒットした場合のみ、月別インデックスを開く
	if($yearfile ne "" && $monthfile ne ""){
		open($month_index_handler,"<${account_directory}diary/${file}_diary_${yearfile}_${monthfile}.cgi");
		flock($month_index_handler,1);
			while(<$month_index_handler>){
				chomp $_;
				my($key,$num,$sub,$res,$dates) = split(/<>/,$_);
				if($open eq $num){
				$key = $newkey;
				$pastline .= qq($key<>$num<>$sub<>$res<>$dates<>\n);
				}
				else{ $pastline .= qq($_\n); }
			}
		close($month_index_handler);
	}

	# ヒットした場合のみ、月別インデックスを書き出し
	if($yearfile ne "" && $monthfile ne ""){
		Mebius::Fileout("","${account_directory}diary/${file}_diary_${yearfile}_${monthfile}.cgi",$pastline);
	}

	# 全メンバーの新着一覧から削除
	if($type =~ /Delete-diary/){
		Mebius::Auth::all_members_diary("Delete-diary New-file Renew",$file,$open);
		Mebius::Auth::all_members_diary("Delete-diary Alert-file Renew",$file,$open);
	}

	# 全メンバーの新着一覧から復活
	elsif($type =~ /Revive-diary/){
		Mebius::Auth::all_members_diary("Revive-diary New-file Renew",$file,$open);
		Mebius::Auth::all_members_diary("Revive-diary Alert-file Renew",$file,$open);
	}

	# 人数分×マイメビ新着日記のインデックスから削除
	if($type =~ /Delete-diary/){
		Mebius::Auth::FriendIndex("Delete-diary",$account{'file'},$open);
	}

	# いいね！ランキングから削除
	if($type =~ /Delete-diary/){
		my(%time) = Mebius::Getdate("Get-hash",$diary->{'posttime'});
		Mebius::Auth::CrapRankingDay("Delete-diary Renew",$time{'yearf'},$time{'monthf'},$time{'dayf'},undef,$account{'file'},$open);
	}

# ロック解除
&unlock("auth$file") if $lockkey;

	# リダイレクト（管理モードへ戻る）
	if($backurl_jak_flag && $myadmin_flag){
		Mebius::Redirect("","$backurl&jump=newres");
	}
	# リダイレクト（プロフィールへ戻る）
	else{
		Mebius::Redirect("","$auth_url${file}/#DIARY");
	}

# 終了
exit;

}



#-----------------------------------------------------------
# 削除前のプレビュー画面
#-----------------------------------------------------------

sub auth_keditdiary_preview{

my($type,$file,$open) = @_;
my($link,$adlink1);

# ヘッダ
&header();

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# 日記単体ファイルを開く
open(DIARY_IN,"${account_directory}diary/${file}_diary_${open}.cgi") || &error("日記が開けません。");
my $top1 = <DIARY_IN>;
my($key,$num,$sub,$res,$dates,$newtime,$restime) = split(/<>/,$top1);
close(DIARY_IN);


$link = "$file/d-$open";
if($aurl_mode){ ($link) = &aurl($link); }

if($myadmin_flag){ $adlink1 = qq( / <a href="$script?mode=keditdiary&amp;account=$file&amp;num=$open&amp;decide=delete&amp;penalty=1">→削除を実行する（ペナルティあり）</a>（復活不可）); }

# HTML
print <<"EOM";
<div class="body1">
$footer_link<hr><br>
日記（<a href="$link">$sub</a>）を削除しますが、よろしいですか？<br>
一度削除すると、この日記内の全コメントが見られなくなります。<br><br>

<a href="$script?mode=keditdiary&amp;account=$file&amp;num=$open&amp;decide=delete">→削除を実行する</a>（復活不可）
$adlink1
<br><br><hr>
$footer_link2
</div>
EOM

# フッタ
&footer();

# 終了
exit;

}






1;
