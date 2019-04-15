
use Mebius::Basic;
use Mebius::Utility;
use Mebius::Paint;
package main;

#---------------------------------------------------------------------------
# 処理スタート
#---------------------------------------------------------------------------
sub start{

my($init_directory) = Mebius::BaseInitDirectory();

# このスクリプト
$scripto = 'getpics.cgi';

# 共通の管理パスワード (必要なら、引数名は使うCGIによって変えればいい)
$mpass = 'dlh742ha';

# 1:置いてあるサーバ外からの投稿を禁止. (HTTP_REFERERがとれるサーバのみ)
$sotodame = 0;

# 1:アニメーションの送信データが限界($maxpch)を越えたとき、エラーをだす. 0:破棄して投稿.
$pchoveralert = 0;

# 1:サムネイル画像の送信データが限界($maxthm)を越えたとき、エラーをだす. 0:破棄して投稿.
$thmoveralert = 0;

# 1以上:データの内容が○byte以下だったときはエラーをだす. 0:使用しない
$errlength = 50;

# 限界サイズを超えたときのコメント. (→ ○○$overcom \nサイズ表示)
$overcom = "データの受信サイズが制限値を超えました。\n軽くするか管理者に緩和を求めるかしてください。";

# 再度投稿しなおす事を促すコメント
$resendcom = "\n再度投稿しなおしてみて下さい。";

# 1:これ単独で、簡易的にログや画像・PCHなどを保存したり表示させたりする. 0:しない.
$easysave = 0;

# 簡易的なログでいろいろさせるライブラリ.
$getpicslib = 'getpics/getpics.pl';

# 簡易的なログを書き出すフォルダ (パーミッション777. ログ名はgetpics.log)
$getpicsdir = 'getpics';

# CGIごとに 適 当 に設定してください.
$mode = 'getpics';	# モード(例えば)
require "${init_directory}relm.ini";

# データ取り出し
&getpics();

	# しぃペインタ本体からの投稿でない場合
	if($ENV{'HTTP_USER_AGENT'} && $ENV{'HTTP_USER_AGENT'} !~ /Shi-Painter/ && !$main::myadmin_flag){

		# アクセス制限
		my($none,$deny_flag) = &axscheck("LAG");
		if($deny_flag){ &alert_to("投稿制限中のため送信できません。"); }

	}

&saveimg();

# 画像の書き込み
&imgwrite();

	# しぃペインタ本体からの投稿でない場合
	if($ENV{'HTTP_USER_AGENT'} && $ENV{'HTTP_USER_AGENT'} !~ /Shi-Painter/ && !$main::myadmin_flag){

		# 連続投稿を制限
		if(!$exthead{'sasikae'}){
			my($redun_nexttime) = &redun("Paint-buffer Not-error",3*60,"","alert_to");
				if($redun_nexttime){ &alert_to("連続投稿は出来ません。あと$redun_nexttime待ってください。$main::agent"); }
		}
	}

# メモリ解放
undef $imgdata;
undef $pchdata;
undef $thmdata;
undef %ENV;

# バッファログ(個別ファイル）の書き出し
my(%image) = Mebius::Paint::Image("Image-post Renew-logfile-buffer Get-hash$plustype_image",$image_session,$image_id,%exthead);

# バッファ一覧を更新  「続きから描く」でログファイルを削除しない場合
require "${init_directory}part_newlist.pl";
Mebius::Newlist::Paint("Renew New Buffer",$image_session,$image_id,undef,$image{'super_id'});



# 完了
print "Content-type: text/plain\n\n";
print "ok";
exit;

}

#-----------------------------------------------------------
##--> メインスクリプト
#-----------------------------------------------------------

sub getpics {


	# method=POSTじゃなかった場合
	if($ENV{'REQUEST_METHOD'} !~ /^POST$/i){
		&alert_to('メソッド「POST」以外の送信はできません');
	}


	# STDIN をバイナリにする
	binmode STDIN;

	# 受信したデータの長さ
	local $c_length = $ENV{'CONTENT_LENGTH'};

	# $c_length から read() した長さ.
	local $r_length = 0;

	# データ最大値が設定されてないとき
	if($maximg eq ''){ $maximg = 200; }
	if($maxthm eq ''){ $maxthm =  50; }
	if($maxpch eq ''){ $maxpch = 200; }

	# format
	local ($first,$eh_length,$thm_length) = ();

	# ログが短いときエラー？
	if($errlength && $c_length < $errlength){
		&alert_to('不正な投稿です'.$resendcom);
	}

	# 外部URLからの投稿を禁止
	#{
	#	my $scr_url = $ENV{'SERVER_NAME'}.$ENV{'SCRIPT_NAME'};
	#	my $ref_url = $ENV{'HTTP_REFERER'};
	#	$scr_url =~ s/\/([^\/]*)$/\//;
	#	my $from = "\n('http://$scr_url' from '$ref_url')";
	#	if(!$scr_url && !$ref_url){
	#		&alert_to('サーバからリファラーURLが取得できません'.$from);
	#	}elsif($ref_url !~ /^http\:\/\/$scr_url/){
	#		&alert_to('外部からの投稿は禁止されています'."$ref_url - $scr_url");
	#	}
	#}
#read(STDIN,$first,100);
#alert_to($first);

	#--> チェック -------------------------------------------------------
	# 読み込めなかったとき
	if(read(STDIN,$first,1) != 1) {
		&alert_to('STDIN から読み込めませんでした');
	}

	$c_length--;
	$r_length++;

	# アプレットの判断
	if($first =~ /^P/i){ $appdata = 'PaintBBS'; }	 # PaintBBS
	elsif($first =~ /^S|^n/){ $appdata = 'ShiPainter'; }     # ShiPainter標準
	elsif($first =~ /^R|^s/){ $appdata = 'ShiPainterPro'; }  # ShiPainterプロ
	else{ &alert_to('アプレットの判断ができませんでした'); }	# しぃ以外

	#--> 拡張ヘッダ -----------------------------------------------------
	# 拡張ヘッダの長さ
	read(STDIN,$eh_length,8);
	$eh_length += 0;
	# 拡張ヘッダ
	if($eh_length > 0){
		read(STDIN,$exthead,$eh_length);
	}
	$c_length -= ($eh_length + 8);
	$r_length += 8 + length($exthead);
#		$ex=$exthead; $ex=~s/\&/\&\n/g; 	# exthead-check
#		$ex =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
#		&jcode'convert(*ex,'sjis'); &alert_to($ex);

	#--> 画像データ -----------------------------------------------------
	# 画像データの長さ
	read(STDIN,$imgsize,8);
	$imgsize += 0;

	# 画像データのサイズが最大値を超えてるとき. ないとき.
	if($imgsize > $maximg*1024){
		local $ximgsize = int($imgsize*10/1024)/10;
		&alert_to("画像$overcom\n$ximgsize / $maximg (send-kb / max-kb)");
	}elsif($imgsize <= 0){
		&alert_to("画像データがありません");
	}

	# \r\n (CR LF)
	read(STDIN,$thm_length,2);

	# 画像データ
	if($imgsize > 0){
		read(STDIN,$imgdata,$imgsize);
	}
	$c_length -= ($imgsize + 10);
	$r_length += 10 + length($imgdata);

	#--> サムネイル・PCHデータ ------------------------------------------
	# 後にまだ何かのデータがあるなら. その1
	if(read(STDIN,$thm_length,8)){
		$thm_length += 0;
	 	if($thm_length > 0){
			read(STDIN,$thm_data1,$thm_length);
	 	}
		$c_length -= ($thm_length + 8);
		$r_length += 8 + length($thm_data1);
	}
	# 後にまだ何かのデータがあるなら. その2
	if(read(STDIN,$thm_length,8)){
		$thm_length += 0;
	 	if($thm_length > 0){
			read(STDIN,$thm_data2,$thm_length);
	 	}
		$c_length -= ($thm_length + 8);
		$r_length += 8 + length($thm_data2);
	}

	# サムネイルがあるなら
	if($thm_data1){
		# $thm_data1 は サムネイルデータ なのか PCHデータなのか
		if($thm_data1 =~ /^\xff\xd8\xff/ || $thm_data1 =~ /^\x89PNG\r\n\x1a/){
			$thmdata = $thm_data1;	# サムネイル だった
			if($thm_data2){ $pchdata = $thm_data2; }	# $thm_data2はPCH
		}else{
			$pchdata = $thm_data1;	# PCH だった
			if($thm_data2){ $thmdata = $thm_data2; }	# $thm_data2はサムネイル
		}
		# メモリ解放
		undef $thm_data1;
		if($thm_data2){ undef $thm_data2; }
	}
	# サムネイルデータのサイズが最大値を超えてるとき
	if($thmdata && length($thmdata) > $maxthm*1024){
		if($thmoveralert==1){
			local $xthmsize = int((length($thmdata))*10/1024)/10;
			&alert_to("サムネイル$overcom\n$xthmsize/$maxthm(send-kb/max-kb)");
		}else{ $thmdata=''; }
	}
	# アニメーションデータのサイズが最大値を超えてるとき
	if($pchdata && length($pchdata) > $maxpch*1024){
		if($pchoveralert==1){
			local $xpchsize = int((length($pchdata))*10/1024)/10;
			&alert_to("アニメーション$overcom\n$xpchsize/$maxpch(send-kb/max-kb)");
		}else{ $pchdata=''; }
	}


	#--> 最終チェック ---------------------------------------------------
	# 読み込んだデータのサイズが、CONTENT_LENGTH と同じじゃないときエラー
	if($r_length ne $ENV{'CONTENT_LENGTH'}){
		&alert_to('投稿データが正常に送信されませんでした。'.$resendcom);
	}
	undef $overcom;
	undef $resendcom;

	# ログ記録用に変数をフック
	$exthead{'image_size'} = $imgsize;
	$exthead{'samnale_size'} = length($thmdata);
	$exthead{'animation_size'} = $xpchsize;

}




#-----------------------------------------------------------------------
##--> コール
#-----------------------------------------------------------
sub call {
	local @calls = @_;
	foreach $calz (@calls){ eval"\&$calz"; }
}


#-----------------------------------------------------------
##--> エラー処理
#-----------------------------------------------------------
sub alert_to {
	print "Content-type: text/plain\n\nerror\nERROR!!\n @_[0]";
	exit;
}

#--> relm.cgi - library2
$ver[2] = '2.35';

##--------------------##
##- お絵描き受け取り -##
##--------------------##
sub saveimg {

# $appdata : アプレットの種類 [PaintBBS,ShiPainter,ShiPainterPro] (〃)

	# 拡張ヘッダを展開
	our %ex;
	foreach $y (split(/\&/,$exthead)){
		my($yk,$yv) = split(/\=/,$y,2);
		($yv) = Mebius::escape("",$yv); 
		$yv =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$ex{$yk} = $yv;
		$exthead{$yk} = $ex{$yk};
	}

	# セッション名がない場合
	if($ex{'image_session'} eq ""){ &alert_to("お絵かきIDが指定されていません。"); }

	# セッション名からログデータを取得
	my(%image) = Mebius::Paint::Image("Get-hash",$ex{'image_session'});
	if(!$exthead{'sasikae'} && -f $image{'session_file_buffer'}){ &alert_to("このお絵かきID - $ex{'image_session'} - は既に使われています。ブラウザのキャッシュが残っているかもしれません。画面更新で正常になる可\能\性があります。"); }


	# 差し替え禁止の場合
	if($image{'deny_sasikae'} && $ex{'sasikae'}){ &alert_to("この絵は差し替え禁止されています。"); }

	# タイトルの長さチェック
	if(length($ex{'image_title'}) >= 2*20){ &alert_to("絵のタイトルは最大20文字までです。（全角）"); }

	# コール_1
	if(@saveimg_call_1){ &call(@saveimg_call_1); }

	# str_header 送信チェック
	if($ex{'loot'} eq 'sendcheck'){ &alert_to("str_header read ok."); }

	# 拡張子
	if($ex{'image_type'} =~ /png/i){ $image_tail = 'png'; }	# PNG-IMAGE
	elsif($ex{'image_type'} =~ /jpeg/i){ $image_tail = 'jpg'; }	# JPG-IMAGE
	else{
		&alert_to("画像タイプが指定されていません。");
		#if($imgdata =~ /^PNG/){ $ex{'ext'} = 'png'; }else{ $ex{'ext'} = 'jpg'; }
	}

	# PCH
	if($appdata =~ /ShiPainter/i){ $animation_tail ='spch'; }else{ $animation_tail ='pch'; }
	# THUMB
	if($ex{'thumbnail'} eq 'png'){ $samnale_tail ='png'; }else{ $samnale_tail ='jpg'; }

	# SIZE
	$ex{'imgs'} = $imgsize;

	# コール_2
	if(@saveimg_call_2){ &call(@saveimg_call_2); }

	# コール_1
	if(@logwrite_call_1){ &call(@logwrite_call_1); }

	# ステップ数の制限
	my($paint_need_steps);
	if($ex{'continue_type'}){ $paint_need_steps = 5; }
	elsif($main::myadmin_flag >= 5){ $paint_need_steps = 1; }
	else{ $paint_need_steps = 5; }
	if($ex{'count'} < $paint_need_steps){ &alert_to("ステップ数が少なくて一時保存できません。（ $ex{'count'}ステップ / $paint_need_stepsステップ）"); }

	# 時間があまりたっていない場合
	my $paint_need_second = 1*60;
	if($ex{'continue_type'}){ $paint_need_second = 1*60; }
	if($main::myadmin_flag >= 5){ $paint_need_second = 1*3; }
	
	my $lefttime_paint2 = $paint_need_second - int($ex{'timer'} / 1000);
	if($lefttime_paint2 >= 1 && !Mebius::alocal_judge()){ &alert_to("あまり短い時間では絵を一時保存できません。[A]（あと$lefttime_paint2秒）"); }

	my $lefttime_paint = ($ex{'paintstarttime'} + $paint_need_second) - time;
	if($lefttime_paint >= 1 && !Mebius::alocal_judge()){ &alert_to("あまり短い時間では絵を一時保存できません。[B]（あと$lefttime_paint秒）"); }

	# キャンバスサイズの違反チェック
	my($error_flag_canvassize) = Mebius::Paint::Canvas_size("Violation-check",$ex{'width'},$ex{'height'});
	if($error_flag_canvassize){ &alert_to("$error_flag_canvassize"); }

return(%ex);

}


#-----------------------------------------------------------
##--> お絵描き画像データ書き出し
#-----------------------------------------------------------
sub imgwrite{

my($basic_init) = Mebius::basic_init();
my $time = time;

	# 宣言
	my($image_file,$samnale_file,$animation_file);
	our(%ex);

	# コール
	if(@imgwrite_call){ &call(@imgwrite_call); }

	# ランダムファイル名
	our($image_id) = $time . int rand(999);
	our($image_session) = $ex{'image_session'};

	# ファイル定義
	$image_file = "$basic_init->{'paint_dir'}buffer/${image_id}.$image_tail";
	$samnale_file = "$basic_init->{'paint_dir'}buffer/${image_id}-samnale.$samnale_tail";
	$animation_file = "$basic_init->{'paint_dir'}buffer/${image_id}.$animation_tail";

	# データの有無をチェック
	if(!$imgdata){ &alert_to("画像データがありません。"); }
	if(!$thmdata){ &alert_to("サムネイルデータが送信されていません。"); }
	if(!$pchdata){ &alert_to("アニメーションデータが送信されていません。"); }

	# 画像等の二重書き込みを防止
	if(-e $image_file){ &alert_to("既に画像が存在します。"); }
	if(-e $samnale_file){ &alert_to("既にサムネイルが存在します。"); }
	if(-e $animation_file){ &alert_to("既にアニメーションデータが存在します。"); }

	# 画像
	if($imgdata){
		if(open(SAVE,">$image_file")){
			binmode SAVE;
			print SAVE $imgdata;
			close SAVE;
		}else{ &alert_to("画像データが保存されませんでした。"); }
	}

	# サムネイル
	if($thmdata){
		if(open(SAVE,">$samnale_file")){
			binmode SAVE;
			print SAVE $thmdata;
			close SAVE;
		}else{ &alert_to("サムネイルデータが保存されませんでした。"); }
	}

	# PCH
	if($pchdata){
		if(open(SAVE,">$animation_file")){
			binmode SAVE;
			print SAVE $pchdata;
			close SAVE;
		}else{ &alert_to("アニメーションデータが保存されませんでした。"); }
	}

}


1;