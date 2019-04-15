
use strict;
package main;

#-----------------------------------------------------------
# セーブデータの呼び出し
#-----------------------------------------------------------
#sub call_savedata{

	# データがない場合、バックアップから開く
	#if($savedata_count < 1 && $soutoukou < 10 && $open){
	#	open(ACDATA_BAKUP_IN,"<",$backfile);
	#	my $top1 = <ACDATA_BAKUP_IN>; chomp $top1;
	#	my $top2 = <ACDATA_BAKUP_IN>; chomp $top2;
	#	if($top1){
	#	 ($nam,$gold,$soutoukou,$soumoji,$email,$follow,$up,$count,$color,$old,$posted,$news,$fontsize,$cut,$secret,$account,$pass,$image_link,$fillter_id,$fillter_account) = split(/<>/,$top1);
	#	($savedata_count,$none,$silver) = split(/<>/,$top2);
	#	}
	#	close(ACDATA_BAKUP_IN);
	#}



	# そのままファイルを更新する場合 ( 他の処理からデータ内容を変更 )
	#if($type =~ /RENEW/){
	#		if(!$open){ main::error("この相手は存在しません。"); }
	#	my(@line);
	#	my($pgold,$pmessage) = split(/<>/,$renewdata);
	#	$gold += $pgold;
	#		if($pmessage){ $message = $pmessage; }
	#	push(@line,"$nam<>$gold<>$soutoukou<>$soumoji<>$email<>$follow<>$up<>$count<>$color<>$old<>$posted<>$news<>$fontsize<>$cut<>$secret<>$account<>$pass<>$image_link<>$fillter_id<>\n");
	#	push(@line,"$savedata_count<><>$silver<>\n");
	#	Mebius::Fileout("",$savefile,@line);
			#if($type =~ /MESSAGE/){
			#	&call_savedata_message("$type RENEW MESSAGE",$file,$k_access,$pmessage); # メッセージファイルを更新
			#}
	#	return(1);
	#}

	# メッセージファイルを取得、$cmessageにメッセージを代入(1行)
	#if($type =~ /MYDATA/){
	#	our($cmessage) = &call_savedata_message("$type ONELINE",$file,$k_access,$pmessage);
	#}

	# 管理モードではリターン
	#if($admin_mode){ return($top1,$nam,$gold,$soutoukou,$soumoji,$email,$follow,$up,$count,$color,$old,$posted,$news,$fontsize,$cut,$secret,$account,$pass,$image_link,$fillter_id,$fillter_account);
	#}

	# 元クッキーをフック
	#if($type =~ /MYDATA/){
	#	if(!$callsave_flag){
	#		our($recgold,$recsoumoji,$recsoutoukou,$recfollow) = ($cgold,$csoumoji,$csoutoukou,$cfollow);
	#	}
	#}

	# 普通のクッキーが空の場合、セーブデータから代入
	#if($type =~ /MYDATA/){
	#		if($cnam eq ""){ $cnam = $nam; }
	#		if($cemail eq ""){ $cemail = $email; }
	#		if($cup eq ""){ $cup = $up; }
	#		if($ccolor eq ""){ $ccolor = $color; }
	#		if($cage eq ""){ $cage = $old; }
	#		if($cposted eq ""){ $cposted = $posted; }
	#		if($cnews eq ""){ $cnews = $news; }
	#		if($cfontsize eq ""){ $cfontsize = $fontsize; }
	#		if($csecret eq ""){ $csecret = $secret; }
	#		if($ccut eq ""){ $ccut = $cut; }
	#		if($cfillter_id eq ""){ $cfillter_id = $fillter_id; }
	#		if($cfillter_account eq ""){ $cfillter_account = $fillter_account; }
	#}

	# セーブデータ独自の擬似クッキー(セッション内部のデータ)を定義
	#if($type =~ /MYDATA/){ $csavedata_count = $savedata_count; }

	# モバイルのログイン状態を取得
	#if($type =~ /MYDATA/){
	#	if($type =~ /MOBILE/){
	#		if($caccount eq ""){ $caccount = $account; }
	#		if($cpass eq ""){ $cpass = $pass; }
	#	$ccount = $count;
	#	}
	#}

# フォローの引継ぎと代入
	#if($type =~ /MYDATA/){
	#		if($follow eq "" && $cfollow){
	#			my(@keep_follow);
	#				foreach(split(/ /,$cfollow)){
	#					my($type,$value) = split(/=/);
	#					if($type eq "bbs" && $value !~ /^sc/){ push(@keep_follow,$_); }
	#				}
	#			$cfollow = "@keep_follow";
	#		}
	#		else{ $cfollow = $follow; }
	#}

# 金貨 / 投稿回数 の引継ぎと代入
	#if($type =~ /MYDATA/){
	#		if($soutoukou eq "" && $csoutoukou){
	#				if(!$callsave_mobile_flag && $type =~ /ACCOUNT/){
	#				if($cgold > 100){ $cgold = 100; }
	#				if($csoutoukou > 1000){ $csoutoukou = 1000; }
	#				if($csoumoji > 100000){ $csoumoji = 100000; }
	#		}
	#		}
	#		else{
	#			$cgold = $gold;
	#			$csoutoukou = $soutoukou;
	#			$csoumoji = $soumoji;
	#		}
	#}

	# 銀貨を代入 ( N 金貨代入の後 )
	#if($silver eq ""){ $csilver = $cgold; }
	#else{ $csilver = $silver; }

# フラグを立てる
	#if($type =~ /MYDATA/){
	#	$callsave_flag = 1;
	#		if($type =~ /ACCOUNT/){ $callsave_account_flag = 1; }
	#		elsif($type =~ /MOBILE/){ $callsave_mobile_flag = 1; }
	#}

#}

#-----------------------------------------------------------
# セーブデータの更新 ( 現在は 非使用)
#-----------------------------------------------------------
sub push_savedata{

# 宣言
my($file,$type,$k_access,$cnam,$cposted,$cpwd,$ccolor,$cup,$ccount,$cnew_time,$cres_time,$cgold,$csoumoji,$csoutoukou,$cfontsize,$cfollow,$cview,$cnumber,$crireki,$ccut,$cmemo_time,$caccount,$cpass,$cdelres,$cnews,$cage,$cemail,$csecret,$cres_waitsecond,$caccount_link,$cimage_link,$cfillter_id,$cfillter_account) = @_;
my($line,$savefile,$backfile);
our($csavedata_count,$csilver,$int_dir);

# 汚染チェック
$file =~ s/\W//;
if($file eq ""){ return; }

# カウント回数を増やす
$csavedata_count++;

# 更新する行
$line .= qq($cnam<>$cgold<>$csoutoukou<>$csoumoji<>$cemail<>$cfollow<>$cup<>$ccount<>$ccolor<>$cage<>$cposted<>$cnews<>$cfontsize<>$ccut<>$csecret<>$caccount<>$cpass<>$cimage_link<>$cfillter_id<>$cfillter_account<>\n);
$line .= qq($csavedata_count<><>$csilver<>\n);

	# ファイル定義 と 追加する行 ( アカウント )
	if($type =~ /ACCOUNT/){
		$savefile = "${int_dir}_save_account/${file}_save_account.cgi";
		#$backfile = "${int_dir}_backup/_save_account/${file}_save_account.cgi";
	}

	# ファイル定義 と 追加する行 ( モバイル )
	elsif($type =~ /MOBILE/ && $k_access){
		$savefile = "${int_dir}_save_mobile/${file}_save_${k_access}.cgi"; 
		#$backfile = "${int_dir}_backup/_save_mobile/${file}_save_account.cgi";
	}
	else{ return; }

# ファイルを作成
Mebius::Fileout("",$savefile,$line);

	# バックアップを作成
	#if(rand(25) < 1){ Mebius::Fileout("",$backfile,$line); }

}

#-----------------------------------------------------------
# メッセージ記録ファイルを取得 / 更新 ( 現在は未使用 => 金貨の受け渡し用? )
#-----------------------------------------------------------
sub call_savedata_message{

# 宣言
my($type,$file,$k_access,$message,$maxview_index) = @_;
my($savefile,$filehandle1,$filehandle2,$top,@line,$i,$oneline_message,$index_line);
my($derenew_flag,$index_flow,$max_message);
my($time) = (time);

# 汚染チェック
$file =~ s/\W//;
if($file eq ""){ return; }

# 最大メッセージ数
$max_message = 10;

# 設定
if(!$maxview_index){ $maxview_index = 5; }	# インデックスの最大表示行数

	# ファイル定義 （ アカウント ）
	if($type =~ /ACCOUNT/){
$savefile = "${main::int_dir}_save_account_message/${file}_message_account.log";
	}

	# ファイル定義 （ モバイル ）
	elsif($type =~ /MOBILE/ && $k_access){
$savefile = "${main::int_dir}_save_mobile_message/${file}_message_${k_access}.log";
	}

	# タイプ定義がない場合
	else{ return; }

# 追加する行
	if($type =~ /RENEW/ && $type =~ /MESSAGE/){
push(@line,"1<>$message<>$main::pmfile<>$main::date<>$main::time<>\n");
	}

# ファイルを開く
open($filehandle1,"<$savefile");
if($type =~ /RENEW/){ flock($filehandle1,1); }

# トップデータを分解
$top = <$filehandle1>; chomp $top;
my($tkey,$tlasttime,$tchecktime) = split(/<>/,$top);
if($tkey eq ""){ $tkey = 1; }

# チェック時間が最近の場合や、～日以上のメッセージはリターン
	if($type =~ /ONELINE/){
		if($tchecktime && $tchecktime >= $tlasttime){ return(); }
		if($main::time > $tlasttime + 2*24*60*60){ return(); }
	}

# チェック時間を更新する場合 / しない場合
	if($type =~ /CHECK/ && $type =~ /RENEW/){
		if($tchecktime >= $tlasttime){ $derenew_flag = 1; }
		$tchecktime = $main::time;
	}

# メッセージ更新の場合
	if($type =~ /MESSAGE/ && $type =~ /RENEW/){
		$tlasttime = $main::time;
	}

# トップデータを追加
unshift(@line,"$tkey<>$tlasttime<>$tchecktime<>\n");

# ファイルを展開
while(<$filehandle1>){
$i++;
chomp;
	if($i > $max_message){ $index_flow = 1; next; }
my($key2,$message2,$account2,$date2,$time2) = split(/<>/,$_);

	# 一定時間以上が経過している場合、表示/記録しない
	if($time > $time2 + 7*24*60*60){ next; }

	# 閲覧行
	if($type =~ /INDEX/ && $i <= $maxview_index){
$index_line .= qq(<tr><td>$message2</td><td>$date2</td></tr>);
	}

	# １行更新
	if($type =~ /ONELINE/ && !$oneline_message){ $oneline_message = $message2; }

	# 更新行を追加
	if($type =~ /RENEW/){ push(@line,"$_\n"); }
}
close($filehandle1);

	# ファイルを更新
	if($type =~ /RENEW/ && !$derenew_flag){
		Mebius::Fileout("",$savefile,@line);
	}

# インデックス表示を整形
	if($type =~ /INDEX/ && $index_line){
$index_line = qq(<table summary="メッセージ一覧">$index_line</table>);
return($index_line,$index_flow);
	}

# リターン
return($oneline_message);

}

1;


