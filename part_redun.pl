package main;

#-----------------------------------------------------------
# 連続送信チェック
#-----------------------------------------------------------
sub do_redun{

# 局所化
my($file,$block_second,$maxline,$routin) = @_;
my($type,$error_subroutin);
my($block_flag,$i,$next_time,$next_second,@line,$redun_handle);

# エラーサブルーチンを定義
if($routin){ $error_subroutin = $routin; } else { $error_subroutin = "error"; }

# ファイル定義
if($file =~ /Not-error/){ $type .= qq( Get-only); }
if($file =~ /Get-only/){ $type .= qq( Get-only); }
$file =~ s/Not-error//g;
$file =~ s/Get-only//g;
$file =~ s/[^0-9a-zA-Z\-_]//g;
if($file eq ""){ return; }

# 保存する行数を定義
if(!$maxline){ $maxline = 50; }

# 連続送信を禁止する秒
if($alocal_mode || $redun_flag eq "0"){ $block_second = 3; }

# 追加する行
push(@line,"$time<>$date<>$addr<>$agent<>$cnumber<>$pmfile<>\n");

# ファイルを開く
open($redun_handle,"${int_dir}_backup/_redun/${file}_redun.log");
	while(<$redun_handle>){
		chomp;
		my($lasttime,$date2,$addr2,$age2,$number2,$account2) = split(/<>/);
		my($flag);
			if($time < $lasttime + $block_second){
				if($addr2 && $addr2 eq $addr){ $flag = 1; }
				if($age2 && $age2 eq $agent && ($kaccess_one || $k_access)){ $flag = 2; }
				if($number2 && $number2 eq $cnumber){ $flag = 3; }
				if($account2 && $pmfile eq $account2){ $flag = 4; }
				if($flag){ $next_second = $lasttime + $block_second - $time; $block_flag = $flag; }
			}
		$i++;
		if($i < $maxline){ push(@line,"$_\n"); }
	}
close($redun_handle);

	# 残り秒数を計算
	if($next_second){
		if($next_second >= 1*60){ $next_time = int($next_second/60)+1 . qq(分); }
		else{ $next_time = $next_second . qq(秒); }
	}

	# データ取得のみで帰る場合
	if($type =~ /Get-only/){ return($next_time); }

	# エラーを表示する
	if($block_flag){
		&$error_subroutin("連続送信は出来ません($block_flag)。あと $next_time ほど間隔をあけて送信してください。");
	}

# ファイルを更新
Mebius::Fileout("","${int_dir}_backup/_redun/${file}_redun.log",@line);

# リターン
return($block_flag);

}

1;
