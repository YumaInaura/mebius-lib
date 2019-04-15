

#---------------------------------------------------------------------------
# Relm #2.35 (last update : 2004/10/27)
#  |-- (C) Snow Materia : URL : http://roo.to/materia/
#						: Mail: mindream@anet.ne.jp

##--> カウンター時とカウンター設定
$countjs = 'relm_c.js'; 	# ログファイル. cgiから.
$ipcheck = 1; 	# 0: IPチェックしない. 1:二重IPチェックする. 2:三重IPチェック.
#---------------------------------------------------------------------------
if($ENV{'QUERY_STRING'} =~ /mode=counter/){ &counter; exit;}	# いじらない
#---------------------------------------------------------------------------

##--> ファイルなどのパス. 
	# ここから先デフォルトのフォルダ構成のままなら変更しなくてよいです(笑) # # # -##
#---------------------------------------------------------------------------

$library1 = 'lib/relm1.pl';	# 閲覧プログラムの入ってるやつ全般.
$library2 = 'lib/relm2.pl';	# 投稿プログラムの入ってるやつ.
$library3 = 'lib/relm3.pl';	# 管理プログラムの入ってるやつ.
$library4 = 'lib/relm4.pl';	# 設定変更プログラムの入ってるやつ.
$paintpl  = 'lib/paint.pl'; # お絵描き画面のプログラム.

$configini= 'relm.ini';	# このCGIの設定のあるファイル. 
$paintini = 'paint.ini';	# お絵描き画面のCGIの設定のあるファイル. 

$jcode    = 'lib/jcode.pl';		# jcodeへのパス
$cgilib   = 'lib/cgi-lib.pl';	# アップ機能をつける際にフォームデータをもらうライブラリ

@ver = ('2.35'); 	# バージョン
#---------------------------------------------------------------------------


##---------------------------------------------------------------------------
##--> 以下スクリプト
##---------------------------------------------------------------------------
# 一定時間経過で強制終了
# eval 'alarm(120)';
# eval '$SIG{"ALRM"} = sub{ &error("120秒経過したのでタイムアウトしました。"); };';

#--> 表示ライブラリ読みこみ
eval "require \"$configini\";";
if($@){ print "Content-type: text/html\n\n"; print "$configiniが読みこめません."; exit; }
if($process){ ($user1,$syst1,$c_user1,$c_syst1,) = times(); }

# 設定修正ファイル読み込み
require "paint_ainit.cgi";


if($iconini){ 
	eval "require \"$iconini\";";
	if($@){ print"Content-type: text/html\n\n"; print"$iconiniが読みこめません."; exit; }
}

#--> 拡張ツール・ライブラリ
foreach (@librarys){ 
	if($_){ eval "require '$_';";  if($@){ $ler .= "$_ が読みこめません.<br>"; } }
}if($ler){ print "Content-type: text/html\n\n<br>$ler"; exit; }else{ undef $ler; }


# コール 1
if(@start_call_1){ &call(@start_call_1); }


#--> 何か
	$title_ = $title;
	$rcut = $rescut;
	$pnepage = $onepage;
	$sort  = $psort;
	$ntres = $ptres;
	$nohtm = 0;
	$sform = $pform;
	$zigzag = 4 - $imgposition; 	# 4-3:左右交互に, 4-4:右左交互に.
	$refresh = 0;	# index.htmに書き込む
	$onload = '';	# onload=""
	$br =~ s/\\n/\n/ig;	# br
	@formdatas = (); 	# 拡張フォームデータ
	($formdata,$forminput,$comdata,$cominput) = ();
	@views = ('normal','catalog','light','noimage','list','mini');
	$view = $views[$mainview];
	$mini = 0;
	@words = ();
	@week = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');	# 日
	@defs = ($targetv,$targetm,$pform,$lform,$ptres);	# 設定変更用に設定を保存
	$tyosaku =~ s/\$ver\[0\]/$ver[0]/i; 	# 著作権

	($overw,$overh) = split(/\,/,$upover,2);	# max-width,height
	if(!$htmlcook){ $autocook=0; }	# no-htmlcook
	if(!$uptype){ $uppaintuse=0; }	# no-upload
	if(!$frame){ $targetw=''; }	# no-frame時 target消し
	if($notres==1){ ($pform,$sform,$lform,$ptres,$ntres)=(); }	# no-resの時フォーム消し
	if($jbguse){ $bground = "background:$jbgc url($jbg) $jbgr $jbga $jbgw $jbgh;"; }
	if($sttime eq ''){ $sttime=9; }	# 設定ないときは日本時間
	foreach (0 .. $#icon2){ $icons{"$icon2[$_]"} = $icon1[$_]; }	# icon名
	foreach (0 .. $#jcon2){ $jcons{"$jcon2[$_]"} = $jcon1[$_]; }	# jcon名

	# 簡単フォルダ変換
	if($basepass){	$based = 1;  @bases1 = ();
		foreach ($skindir,$index,$listhtm,$logdir,$karidir,$olddir,$oldlog,$scrdir,
			$icondir,$jsfile,$ptori){ push(@bases1,$_);  $_ = $basepass.$_; }
	}if($basehref){  @bases2 = ();
		foreach ($css,$prevjs,$cookiejs,$layerjs,$icondir_,$psasi){
			push(@bases2,$_);  if($_ !~ /^https?\:\/\//i){ $_ = $basehref.$_; } }
	}

	# クッキー
	@cooks = ('\$c_n','\$c_m','\$c_u','\$c_p','\$c_i','\$c_f','\$c_b','\$c_t','\$c_c',
			'\$c_e','\$c_j','\$cimg','\$cpch','\$cimt','\$cimw','\$cimh','\$capp');
	@layers1 = ('/*LAYER_SET_COOK*/','/*LAYER_GET_COOK*/',);
	@layers2 = ("$lcookset","$lcookget",);
	@cookis1 = ('/*SET_COOK*/','/*GET_COOK*/',);
	@cookis2 = ("$cookset","$cookget",);
	$previs1 = '/*PREVIEW*/';
	$previs2 = $preview;
	$lprevis1 = '/*LAYER_PREVIEW*/';
	$lprevis2 = $lpreview;

	# クッキーに一時セーブの外部JSファイルを読み込むタグ
	$cookiesrc = "<script type=\"text/javascript\" src=\"$cookiejs\"></script>\n";

	# レイヤーレスフォームの外部JSファイルを読み込むタグ
	$layersrc = "<script type=\"text/javascript\" src=\"$layerjs\"></script>\n";

	# プレビュー機能の外部JSファイルを読み込むタグ
	$previewsrc = "<script type=\"text/javascript\" src=\"$prevjs\"></script>\n";


# コール 2
if(@start_call_2){ &call(@start_call_2); }


#--> フォームデータ
if($ENV{'REQUEST_METHOD'} eq "GET") {
	$buffer = $ENV{'QUERY_STRING'};
	if($buffer =~ /id\=([\w]+)/i){ $sent=1;  &sent($1); }	# continue-reg
	if($buffer =~ /type\=refresh/){
		require $library1;
		&writer;
		&reload;
	}elsif($buffer =~ /type\=reload/){
		&reload;
	}elsif($buffer !~ /mode\=[^\&]+/){
		#--> IDのクッキーあったら
		local $sentdata='';
		local @cookies = split(/;/, $ENV{'HTTP_COOKIE'});
		foreach (@cookies){	local ($w,$x) = split(/\=/,$_,2);
			$w =~ s/\s//g;	if($w eq "$karick"){ $sentdata = $x; last; } }
		if($sentdata){ $sent=1;  &sent($sentdata); }
	}
}elsif(!$uptype || (
	$ENV{'CONTENT_TYPE'} !~ /multipart\/form-data/ && 
	$ENV{'CONTENT_TYPE'} !~ /boundary=\"([^\"]+)\"/ && 
	$ENV{'CONTENT_TYPE'} !~ /boundary=(\S+)/) ){
	read(STDIN,$buffer,$ENV{'CONTENT_LENGTH'});
}else{
	require $cgilib;
	$maxup = $maxup * 1024;
	$cgi_lib'maxdata = $maxup;#'
	&ReadParse;
}
if($buffer){
	local @buf = split(/&/,$buffer);
	foreach (@buf) {
		local ($key,$value) = split(/=/,$_,2);
		$value =~ tr/\+/ /;
		$in{$key} = $value;
	}
}else{
	$buffer = $ENV{'CONTENT_LENGTH'};
}

# コール 3
if(@start_call_3){ &call(@start_call_3); }

# フレーム
if(!$buffer && $frame){ &frame; }


#--> IP, HOSTアドレス, エージェント取得

$ip = $ENV{'REMOTE_ADDR'};
$host = $ENV{'REMOTE_HOST'};
$agent = $ENV{'HTTP_USER_AGENT'};
if($host eq "" || $host eq "$ip"){ $host = (gethostbyaddr(pack("C4",split(/\./,$ip)),2))[0]; }

#ホスト名チェック
if($host eq ""){ &error("ホスト名が取得できません。");}

# アクセス制御
if(join('',@dema)){
	local $dam=0;  local @dame = @dema;
	foreach (@dame) {
		if(!$_){ next; }  $_="\Q$_\E";	s/\\\*/\.\*/g;  s/\\\+/\[\^\\\.\]\*/g;  
		if($host =~ /^$_$/i || $ip =~ /^$_$/) { $dam=1; last; }
	}	if($dam){ &error("このCGIへのアクセスが認められていません。"); }
}
# ミニマムモード
if(@minis){
	local $dam=0;  local @miny = @minis;
	foreach (@miny) {
		if(!$_){ next; }  $_="\Q$_\E";	s/\\\*/\.\*/g;  s/\\\+/\[\^\\\.\]\*/g;  
		if($host =~ /^$_$/i || $ip =~ /^$_$/) { $dam=1; last; }
	}	if($dam){ $mini=1; }
}

# コール 4
if(@start_call_4){ &call(@start_call_4); }
#---------------------------------------------------------------------------


#--> 一般表示
if(!$buffer){
	# 基本フォームデータ
	&comdatain;

	require $library1;
	# コール
	if(@decode_call){ &call(@decode_call); }
	if(@mode_call){ &call(@mode_call); }
	if(!$frame){ &relm; exit; }
	if($frame){ &frame; exit; }
}


##--> データを
#----------------------------
#--> デコード
&decode_paint();

#--> 送信された後なら
if($in{'id'} && !$sent && $buffer !~ /mode\=[^\&]+/){ &sent; }

#--> 編集･削除モード時
if($type eq 'edit' && $ksent){ &kariload; } 	# 未コメ
if($type eq 'edit'){ $formdatas{'edit'} = 1; }
if($type eq '' && $in{'edit'}==1 && $mode ne 'regist'){ $type = 'edit'; }

#--> リフレッシュ
if($type eq 'refresh'){ $refresh=1; }
if($mode eq 'refresh'){ $refresh=1; $type = $in{'type'} = 'refresh'; $mode = 'adm'; }

#--> ノータイムレス
if($ntres eq ''){ $ntres = $ptres; }


#--> 管理的
if($in{'password'} ne ''){ &admformat; }	# フォーマット
if($formdatas{'password'} != 1){ $in{'password'} = ''; }
if($in{'source'} && ($in{'password'} != 1 || $pass ne $mpass)){ $in{'source'}=''; }


#--> 過去ログ
if($in{'old'} && ($olduse==2 || ($olduse==1 && $pass eq $mpass))){
	if(-e $oldlog){
		$old = 1;
		$formdatas{'old'} = '1';
		$logfile = $oldlog; $logdir = $olddir;
		($notres,$autocook,$rescut,$prevu,$lform,$sform,$ntres,$imgcontinue) = (1,0);
		if($type eq 'edit' && $in{'password'} != 1){ $type=''; }
	}else{
		&error('過去ログファイルがありません。')
	}
}




#--> 基本フォームデータ
&comdatain;

#--> 拡張フォームデータ
while (($fk,$fv) = each %formdatas){
	if($fv eq ''){ next; }
	$formdata  .= "&amp;$fk\=$fv";
	$forminput .= "\t<input type=\"hidden\" name=\"$fk\" value=\"$fv\">\n";
}	%formdatas = ();


#--> HTTP_REFERER 制限
if(join('',@referers)){
	local $dam=0;  local @refs = @referers;
	local $rfr = $ENV{'HTTP_REFERER'};
	$rfr =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	foreach (@refs){
		if(!$_ && !$rfr){ $dam=1; last; }elsif(!$_){ next; }
		$_="\Q$_\E";	s/\\\*/\.\*/g;  s/\\\+/\[\^\\\.\]\*/g;  
		if($_ && $rfr && $rfr =~ /^$_/i) { $dam=1; last; }
	}
	if($dam != 1){ &error("URL:指定URL以外からのアクセスは受け付けられません。($rfr)"); }
}


# コール
if(@mode_call){ &call(@mode_call); }
#----------------------------




##--> モード
#---------------------------------------------------------------------------
#--> ペイント
if($mode =~ /paint/i){
	if($ksent){ &kariload; }	# 未コメ
	&app_cookie;
	if($mastonly){
		if(!$pass){ &error('パスワードをいれてください','admm'); }
		if($pass ne $mpass){ &error('管理パスがちがいます','admm'); }
	}
	if($mode eq 'paint'){ $mode=''; }
	require $paintpl;
	if($no){
		$to{'no'} = $no;
		$to{'mode'} = 'replace';
		$ue{'type'} = 'refresh';
	}
	# コール
	if(@paint_call){ &call(@paint_call); }
	&paint($mode);
} 	# お絵描き
elsif($mode eq 'newpost')	{ &paintcheck('newpost'); }	# 続きから新規投稿
elsif($mode eq 'replace' && $replace_mode eq "deny"){ &error("この掲示板では差し替えは出来ません。"); }
elsif($mode eq 'replace'){ &paintcheck('replace'); }	# 続きから差し替え
elsif($mode eq 'animation')  { &animecheck; }	# 描画アニメーション
elsif($mode eq 'pchdownload'){ &animecheck('download'); }	# PCHダウンロード


#--> 一般
	require $library1;
if(!$mode){
	if($frame==3){ &frame; }	#- フレーム
	elsif($no){ &rwrite('no',$title_,$no); }	#- NO指定
	else{ &relm; }
}
elsif($mode eq 'relm')	{ $mode=''; &relm; }	#- 一般
elsif($mode eq 'preview')	{ &preview; }	#- プレビュー
elsif($mode eq 'search')	{ &relm('search'); }	#- 検索処理など
elsif($mode eq 'res')   	{ &rwrite('res',$restitle,$no); }	#- レス
elsif($mode eq 'continue')	{ &rwrite('continue',$contitle,$no); }	#- 続きから描く
elsif($mode eq 'write') 	{ &rwrite; }	#- 新規カキコ


#- ライブラリ2
#--> 登録系
if($mode eq 'regist' || $mode =~ /^delet/ || $mode eq 'edit'){
	require $library2;
	if($mode eq 'regist'){
		if($ENV{'REQUEST_METHOD'} eq "GET"){
#			local $rfr = $ENV{'HTTP_REFERER'};
#			$rfr =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
#			open(TEST,'>>test.txt'); print TEST "$ENV{'REQUEST_METHOD'} // $rfr // $ip // $host // $agent // $comm //\n"; close(TEST);
			&error('POST以外のREQUEST_METHODではデータを受け取れません。');
		}
		if($type eq 'res'){ &resreg; }
		elsif($type eq 'pati'){ &patireg; }
		elsif($type eq 'editer' || $type eq 'editmae' || $type eq 'editato'){ &editer; }
		elsif($type eq 'editeres'){ &deledit('editeres'); }
		elsif($type eq 'status'){ &editer($type); }
		else{ &regist; }
	}
	elsif($mode eq 'edit')		{ &edit; }
	elsif($mode eq 'delete')	{ &deletes; }
	elsif($mode eq 'deleter')	{ &deleter; }
	elsif($mode eq 'deleteres')	{ &deledit('deleteres'); }

	undef $no;
	$refresh=1;
	$mode = 'relm';

	if( ($type eq '' && $in{'edit'}==1) || 
		($in{'password'} ne '' && $pass eq $mpass) ){ $type = 'edit'; }
	&relm;
}

#--> そのほか
if($mode =~ /image$/ || $mode eq 'howto' || $mode eq 'adm' || 
   $mode =~ /^list/ || $mode =~ /^namech/ || $mode =~ /^log/ || $mode =~ /^set/ 
){


	require $library3;
	   if($mode =~ /^list/ || $mode =~ /^namech/ || $mode =~ /^log/ || $mode =~ /^set/ ||
		  $mode eq 'adm')	{ &adm; }   	#- 管理画面
	elsif($mode eq 'image')	{ &image; } 	#- アイコン一覧
	elsif($mode eq 'jimage'){ &image(1); }	#- カレンダーアイコン一覧
	elsif($mode eq 'howto')	{ &howto; } 	#- 掲示板の使い方
}
#--> 一般モード
$mode = 'relm';
&relm;
exit;




#---------------------------------------------------------------------------




##--> コール
sub call {
	local @calls = @_;
	foreach $calz (@calls){ eval"$calz"; }
}


##--> 基本フォームデータ
sub comdatain {
	if($mini==1){ $view = 'mini'; }  undef $mini;  	# mini
	local $inp = "\t<input type=\"hidden\" name=";
	if($view ne $views[$mainview]){ $comdata  .= "&view\=$view";
		$cominput .= "$inp\"view\" value=\"$view\">\n"; }
	if($sform ne $pform){ $comdata  .= "&sform\=$sform";
		$cominput .= "$inp\"sform\" value=\"$sform\">\n"; }
	if($sort ne $psort){ $comdata  .= "&sort\=$sort";
		$cominput .= "$inp\"sort\" value=\"$sort\">\n"; }
	if($ntres ne $ptres){ $comdata  .= "&ntres\=$ntres"; }
	if($ptres != 2){ $cominput .= "$inp\"ntres\" value=\"$ntres\">\n"; }
	if($view eq 'mini'){ ($w_skin,$mainskin,$rskinuse,$frame,$admpaint)=($n_skin); }
$comdata =~ s/&/&amp;/g;
}


#-----------------------------------------------------------
##--> デコード
#-----------------------------------------------------------
sub decode_paint {

# 局所化
my($check_query_line);


	require $jcode;
	$upari = 0;
	local $mbake = "  ゆうていみやおうきむこうほりいゆうじとりやまあきらぺ\n\n";

	while (($key,$value) = each %in) {

		# エラーチェック用
		$check_query_line .= qq( $key <=> $value );

		if($key eq 'up'){ if($value){ $upari=1; }  next; }
		if($hankana==1){ $value .= $mbake; }
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		&jcode'convert(*value,'sjis');


		if($hankana==1){ $value =~ s/$mbake$//g; }
#		$value =~ s/\,/&#44;/ig;
		$value =~ s/^undefined$//ig;
		if($notres != 1 && $key !~ /^source/ && $key !~ /^set_[ac]_/){
			$value =~ s/\&/\&amp\;/ig;
			$value =~ s/</&lt;/ig;
			if($tagok){
				$value =~ s/([\s]+on)([a-z]+\=)/$1 $2/ig;
				$value =~ s/<([^\<]*)>/&a_quot($1)/eg;
				foreach (@allowtag){ 
					$value=~ s/&lt;($_)(\s|\>)/<$1$2/ig;
					$value=~ s/&lt;\/($_)(\s|\>)/<\/$1$2/ig; 
				}
			}else{
				$value =~ s/>/&gt;/ig;
			}
			$value =~ s/\&amp\;/\&/ig;
		}else{
			$value =~ s/<>/&lt;&gt;/ig;
		}
		$in{$key} = $value;
	}


	$no 	= $in{'no'};
	$mo 	= $in{'mo'};
	$mode 	= $in{'mode'};
	$type	= $in{'type'};
	$page	= $in{'page'};
	$word	= $in{'word'};

	$name 	= $in{'name'};
	$mail 	= $in{'mail'};
	$url 	= $in{'url'};	$url =~ s/http\:\/\///ig;
	$pass 	= $in{'pass'};

	$title 	= $in{'titl'};
	$com	= $in{'comm'};
	$etcd 	= $in{'etc'};

	$ico 	= $in{'icon'};
	$jco 	= $in{'jcon'};
	$font 	= $in{'font'};
	$color 	= $in{'color'};
	$imgt 	= $in{'imgt'};
	$pch 	= $in{'pch'};

	$ntres 	= $in{'ntres'};

	$skp	= $in{'skp'};

	$width	= $in{'width'};
	$height	= $in{'height'};
	$anime	= $in{'anime'};
	$kake   = $in{'kakikake'};
	$passoff = $in{'passoff'};
	$ptimeoff = $in{'ptimeoff'};

	# ページ
	if(!$page || $page<1){ $page=1; }

	# 検索ワード
	if($word){ $word =~ s/　/ /g;  local $u=0;
		@words = split(/\s|\+/,$word);
		foreach $w (0 .. $#words){
			if($words[$w] eq ''){ next; }
			foreach $v (($w+1) .. $#words){
				if($words[$w] eq $words[$v]){ $words[$v] = ''; }
			}
			if($words[$w] ne ''){ $u++; }
		}
		if(!$u){ $word=''; @words=(); }
		$formdatas{'andor'} = $in{'andor'};
	}

	# 表示 | 過去 | 親順/レス順 | スレッドフォーム
	$view	= $in{'view'};
	$sort 	= $in{'sort'};
	$sform	= $in{'sform'};
	if($view eq ''){ $view = $views[$mainview]; }
	if($sort eq ''){ $sort = $psort; }
	if($sform eq ''){ $sform = $pform; }if($notres==1){ $sform = ''; }

	# ノータイムレス投稿時 / NOFRAME
	if($ntres == 3){ $ntres = 1;  $nohtm = 1; }	# ダミーiframeに投稿するとき
	if($word eq 'noframe'){
		$frame = 0; $word='';
	}elsif($word eq 'frame' && !$mode && !$in{'view'}){
		$frame = 3; $word=''; ($targetv,$targetm) = @defs;
	}elsif($word eq 'frame'){
		$frame = 1; $word=''; ($targetv,$targetm) = @defs;
	}

	# 改行
	$com =~ s/\r?\n/<br>/g;

	# 半角英数字羅列
	if($hanalpha >= 1){
		local $h = $hanalpha +1;
		local $r = '<br>';
		foreach ($com,$name,$title){
			local $i=0;
			while (s/([-\w\/\|\\.,~#!?&+=:;\%\$\@\[\]]{$h,})/\f\f/){
				local $c = $1;
				local $r = "\f" if($c =~ /s?https?\:\/\/|ftp\:\/\//);
				$c =~ s/([-\w\/\|\\.,~#!?&+=:;\%\$\@\[\]]{$hanalpha})/$1$r/g;
				s/\f\f/$c/;
				$i++; if($i>100){ last; }
			}
			s/\f//g;
		}
	}

	# 錬金術
	if($com && $jumon == 1){
		&renkinjutu;
	}

	#-- 自動リンク
	if($com && $autolink == 1){
		local ($u,$i)=(0,0);
		while($com =~ /([^-=\"\'\(\w\/\|\\.,~#!?&+=:;\%\$\@\[\]\f]|^)(s?https?\:|ftp\:)([-\w\/\|\\.,~#!?&+=:;\%\$\@\[\]]+)/i){
			local ($u1,$u2,$u3) = ($1,$2.$3,$2.$3);
			$u++;
			$u3 =~ s/\//\/<wbr>/g;
			$com =~ s/\Q$u1$u2\E/$u1<nobr><a href=\"$u2\" target=\"_blank\">\f$u3<\/a><\/nobr>/;
			$i++; if($i>100){ last; }
		}
		$com =~ s/\f//g;
	}

	# コール
	if(@decode_call){ &call(@decode_call); }
}


# 奇数 「'」「"」;
sub a_quot {
	local $_ = @_[0];
	if(tr/\"/\"/ % 2){ s/$/\"/i; }
	if(tr/\'/\'/ % 2){ s/$/\'/i; }
	return "<$_>";
}


##--> 錬金術機能
sub renkinjutu {
	&jcode'sjis2euc(*com);
	foreach (0 .. $#jumon1){ 
		local $jumonz1 = $jumon1[$_];
		local $jumonz2 = $jumon2[$_];
		&jcode'convert(*jumonz1,'euc');
		&jcode'convert(*jumonz2,'euc');
		local $jumonz1 = "\Q$jumonz1\E";
		$com  =~ s/$jumonz1/$jumonz2/ig;
	}
	foreach (0 .. $#mahou1){
		local $mahouz1 = $mahou1[$_];
		local $mahouz2 = $mahou2[$_];
		local $mahouz3 = $mahou3[$_];
		&jcode'convert(*mahouz1,'euc');
		&jcode'convert(*mahouz2,'euc');
		&jcode'convert(*mahouz3,'euc');
		local $mahouz1 = "\Q$mahouz1\E";
		if($com =~ /$mahouz1/){
			$com =~ s/([^=\"\'\(\;\<]|^)($mahouz1)([\w|\/\.\~\-\#\?\&\+\=\:\;\%\@\!]+)/$1$mahouz2$3$mahouz3/ig; 
		}
	}
	&jcode'euc2sjis(*com);
}




##--> 管理的フォーマット
sub admformat {

	if($pass ne $mpass){
		&get_cookie;  if($cookies[3] eq $mpass){ $pass = $cookies[3]; }
	}
	if($pass eq $mpass){
		# スキンプレビュー
		if($in{'set_skin'}) { $r_skin = $in{'set_skin'}; }
		if($in{'set_cata'}) { $c_skin = $in{'set_cata'}; }
		if($in{'set_form'}) { $w_skin = $in{'set_form'}; }
		if($in{'set_list'}) { $l_skin = $in{'set_list'}; }
		if($in{'set_paint'}){ $p_skin = $in{'set_paint'}; }
		if($in{'set_mini'}) { $n_skin = $in{'set_mini'}; }
		if($in{'set_css'})  {
			$css = $in{'css_dir'}.$in{'set_css'};
			if($css !~ /^https?\:\/\//i){ $css = $basehref.$css; }
		}
		foreach ('set_skin','set_cata','set_form','set_list','set_paint','set_mini', 'set_css','css_dir'){
			if($in{"$_"}){ $formdatas{"$_"} = $in{"$_"}; }
		}

		# EDIT
		if($type eq 'edit' || $mode eq 'regist'){
			if($mode ne 'regist'){ $type = 'edit'; }
			$formdatas{'edit'} = 1;
		}
		if($in{'password'} == 1){ $formdatas{'password'} = 1; }
	}


	#--> スキンソースプレビュー
	if($type eq 'skinsource' && $pass eq $mpass){
		if(!$in{'source'}){

			local $s = '';
			local @ss = keys %in;
			@ss = grep(s/^source_//,@ss);
			@ss = sort { $a <=> $b } @ss;
			foreach $r (@ss){
				local $_ = $in{"source_$r"};  delete $in{"source_$r"};
				s/\r//g;  s/^\n//;  s/\n$//;
				$s .= $_;  $s .= "\n" if($_ !~ /\n$/);
			}
			$in{'source'} = $s;
		}
		if($in{'source'}){
			local $_ = $in{'source'};
			s/\r//g;  s/\&amp\;/\&/g;  s/    /\t/g;  s/\&lt\;(\/?textarea)/<$1/ig;
			# SymRealWinOpen()?
			if($notsymreal==1 && /SymRealWinOpen/i){
				local ($s1,$s2) = ("\n<!--","//-->\n</script>\n");
				s/(\<script [^>]+\>$s1)[\s]+[^\n]*SymRealWinOpen[^\n]*[\s]+$s2//ig;
				if(/SymRealWinOpen/i){ s/[^\n]*SymRealWinOpen[^\n]*\n?//ig; }
			}
			$in{'source'} = $_;
		}
		if($in{'prevtype'}){	local $pv=$in{'prevtype'};
			   if($pv==1 || $pv==8) { $view='catalog'; }
			elsif($pv==2 || $pv==9) { $mode='write'; }
			elsif($pv==3 || $pv==10){ $view='list'; }
			elsif($pv==4 || $pv==11){ $mode='paint'; }
			elsif($pv==5 || $pv==13){ $view='mini'; }
			elsif($pv==6 || $pv==12){ $mode='edit';
				if(open(LOAD,"$logfile")){
					local $ls = <LOAD>;
					close(LOAD);
					$no = (split(/<>/,$ls))[8];
					if($no){ @logs=$ls; }
				}
			}
			if($pv>=7){ # css
				local $s ="<style type=\"text/css\"><!--\n".$in{'source'}."\n--></style>\n";
				$in{'source'}='';
				if($pv==7 || $pv==8 || $pv==10 || $pv==13){ $body_in .= $s; }
				elsif($pv==9 || $pv==12){ $write_in .= $s; }
				elsif($pv==11){ $paint_css = $s;
					push(@paint_call,'$paint_in .= $paint_css;'); }
			}
		}
	}
}




#--> paint
#---------------------------------------------------------------------------




##--> ペイントチェック
sub paintcheck {
	if($mastonly){
		if(!$pass){ &error('パスワードをいれてください','admm'); }
		if($pass ne $mpass){ &error('管理パスがちがいます','admm'); }
	}

	# LOGLOAD
	local ($logno,$zerror,$zdate,$ztime,$zlog,@zlogs) = &logload($no);

	local @zrogs = split(/<>/,$zlogs[0]);

	local $applet = $zrogs[29];
	$anime = $zrogs[27];
	# PAINT-TIME
	$ex{'painttime'} = time() - $zrogs[26];
	# IMAGE/PCH
	if($type eq 'pch'){
		if($zrogs[23] =~ /http\:\/\//){
			&error("PCHファイルが'$logdir'フォルダ内でないと読み込めません。"); }
		if(!-e "$logdir$zrogs[23]"){ &error("ファイル'$zrogs[23]'がありません"); }
		$ex{'pch_file'} = "$logdir$zrogs[23]";
	}else{
		$anime='';
		if($zrogs[18] =~ /http\:\/\//){
			&error("イメージファイルが'$logdir'フォルダ内でないと読み込めません。"); }
		if(!-e "$logdir$zrogs[18]"){&error("ファイル'$zrogs[18]'がありません");}
		$ex{'image_canvas'} = "$logdir$zrogs[18]";
	}
	if($zrogs[19]){ $width=$zrogs[19]; }
	if($zrogs[20]){ $height=$zrogs[20]; }

	# NEWPOST/REPLACE
	if(@_[0] eq 'newpost'){
		if($zerror){
			if((!$zrogs[24] && $newcontinue==2) || !$newcontinue){ 
				&error('続きから新規投稿ができるのは描いた人だけです'); }
		}
	}else{
		if($zerror){ &error('パスワードが違っています'); }
	}

	# library
	require $paintpl;

	# コール
	if(@paintcheck_call){ &call(@paintcheck_call); }

	# undef
	foreach($zerror,$zdate,$ztime,$zlog){ undef $_; } undef @zlogs; undef @zrogs;

	# NEWPOST/REPLACE
	if(@_[0] eq 'newpost'){
		$to{'no'} = $logno;
		&paint($applet);
	}else{
		$to{'no'} = $logno;
		$to{'mode'} = 'replace';
		$ue{'type'} = 'refresh';
		&paint($applet);
	}
}


##--> アニメーションチェック
sub animecheck {
	if(!$pch){ &error('アニメーションファイルが指定されていません'); }
	if($pch =~ /http\:\/\//){
		&error("PCHファイルが'$logdir'フォルダ内でないと読み込めません。"); }
	$pch =~ s/.*\/([^\/]*)$/$1/;
	if(!-e "$logdir$pch"){ &error("そのアニメーションファイルはありません.($pch)"); }

	# LOGLOAD
	local ($logno,$zerror,$zdate,$ztime,$zlog,@zlogs) = &logload($no);
	local ($xdate,$ximg,$ximgt,$xpch,$x,$x,$x,$x,$xno,$x,$x,$x,$anime,$kake)
	 = split(/<>/,$zlog);
	if(!-e "$logdir$xpch"){ &error("No\.$noのアニメーションファイルはありません"); }

	# 投稿者以外
	if(crypt($pass,"mn") ne (split(/<>/,$zlogs[0]))[4]){
		if($kake){ &error("No\.$noは今描きかけなので見ることができません"); }
		# アニメなしでも一応アニメ保存のとき
		if($animationpng && $animationuse==2){
			if(!$anime){ &error("No\.$noの描画アニメーションは見ることができません"); }
		}elsif(!$animationuse){ &error("描画アニメーションは見ることができません"); }
	}
	$pch = $logdir.$pch;
	local $img=$in{'img'};
	if($img eq $noimg || $img eq $logdir.$noimg){ $img = ''; }
	if($img){ $img = $logdir.$img; }

	if($ptori && $img){ $img =~ s/\Q$ptori\E/$psasi/i; }

	# library
	require $paintpl;

	# コール
	if(@animecheck_call){ &call(@animecheck_call); }

	# undef
	foreach($logno,$zerror,$zdate,$ztime,$zlog){ undef $_; } undef @zlogs;

	if(@_[0] eq 'download'){ &pchdownload; }
	else{ &animation; }
}




##--> 送信された後のデータ取得と行き先
sub sent {
	local $csend = @_[0];
	# IDをだす
	if($csend){
		$csend =~ s/.*(\&?id\=)([^\&]*)\&.*/$2/i;
		$csend =~ s/\W//g;
		$pass = $buffer;
		$pass =~ s/.*(\&?pass\=)([^\&]*)\&.*/$2/i;
		$pass =~ s/\W//g;
	}else{ $csend = $in{'id'}; }

	# コール_1
	if(@sent_call_1){ &call(@sent_call_1); }

	local ($ci,$sentdata,$cset,$mset)=();
	for($ci=0;$ci<3;$ci++){
		if(open(LOAD,"$karidir$csend\.txt")){
			$sentdata = <LOAD>;	close(LOAD); last;
		}else{
			sleep(1);
		}
	}
	# cookie-delete
	$cset  = "$karick=; expires=Sun, 31-12-2000 0:0:0 GMT";
	$mset = "<meta http-equiv=\"Set-Cookie\" content=\"$cset\">\n" if($metacook);
	$cset  = "Set-Cookie:$cset\n";

	# データがないとき
	if(!$sentdata && @_[0] && $csend ne @_[0]){ $sentdata = @_[0]; }	# クッキーから
	if(!$sentdata){
		print "$cset";  $setcook = $mset;
		return;	# cookie-delete, return
	}

	# データ
	local %ex;	local $looton=0;
	foreach $y (split(/\&/,$sentdata)){
		local ($yk,$yv) = split(/\=/,$y,2);
		$yv =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$ex{$yk} = $yv;
	}
	$ono = $ex{'ono'};

	# コール_2
	if(@sent_call_2){ &call(@sent_call_2); }

	if(!$ex{'id'} || $ex{'id'} ne $csend){ return; }

	if($ex{'loot'}){
		$looton=1;
		require $paintpl;
		foreach (split(/\,/,$ex{'loot'})){ eval"\&$_"; }	# 指定されたルート(道)へ
	}

	# NOがないとき無理やりだす
	if(!$ono && $ex{'painttime'}){
		$ono = &onosearch($csend,$ex{'painttime'});	# お絵描き開始時間よりは後
	}

	# ONOがないなら返す
	if(!$ono){
		print "$cset";  $setcook = $mset;
		return;
	}

	# WRITE?
	if($looton != 1){
		local $rog='';
		for($ci=0;$ci<3;$ci++){
			if(open(LOAD,"$logdir$logkan$ono\.log")){
				$rog = <LOAD>;	close(LOAD); last;
			}else{ sleep(1); }
		}

		# コール_3
		if(@sent_call_3){ &call(@sent_call_3); }
		if(!$rog){
			# クッキーだけあって、ログがなくて、画像なんかがただ残っているとき
			if(!$in{'id'} || $in{'id'} ne $csend){
				print "$cset";  $setcook = $mset;
				local @fz = (
					"$csend\.txt",
					"$imgkan$csend\.jpg","$imgkan$csend\.png","$pchkan$csend\.pch",
					"$pchkan$csend\.spch","$thmkan$csend\.jpg","$thmkan$csend\.jpg");
				foreach (@fz){ unlink $karidir.$_ if(-e $karidir.$_); }
			}
			&error("No\.$onoのログファイルが読み込めません");
		}

		if($rog){
			local ($xono,$xpno,$xrdate,$xname,$xpassd,$xtitle,$xmail,$xurl,$xcom,
			 $xntime,$xip,$xhost,$xfont,$xcolor,$xico,$xjco,$xetc,$xskp,
			   $ximg,$ximgw,$ximgh,$ximgs,$ximgt,$xpch,$xpassoff,$xptimeoff,
			     $xptime,$xanime,$xkake,$xapp,$xextension) = split(/<>/,$rog);
			$rog='';

			# もうコメントあるなら返す
			if($xcom){
				unlink "$karidir$csend\.txt" if(-e "$karidir$csend\.txt");
				print "$cset";  $setcook = $mset;  return;
			}

			# コール_4
			if(@sent_call_4){ &call(@sent_call_4); }

			if(crypt($csend,"mn") eq $xpassd || crypt($pass,"mn") eq $xpassd){ $rog=1; }
			($no,$mo,$in{'img'},$img,$pch,$imgt,$imgw,$imgh,$imgs,
				$ptime,$anime,$app,$ptimeoff,$passoff) = 
			  ($xono,$csend,$ximg,$ximg,$xpch,$ximgt,$ximgw,$ximgh,$ximgs,
				  $xptime,$xanime,$xapp,$xptimeoff,$xpassoff);
		#	@cookies = ($name,$mail,$url,$pass,$ico,$font,$color,$title,$com,$etc,$jco,);
		}

		if($rog==1 || @_[0]){ 
			if($karifile == 1){ 
				print "$cset";  $setcook = $mset;  }
			require $library1; &rwrite('paint','',$no,$csend);
		}
	}
}




##--> ログから$onoを無理やりだす
sub onosearch {
	local ($xid,$ltime) = @_;
	local ($lono)=();
	local $lip   = (split(/\./,$ip,2))[0];
	local $lhost = (split(/\./,$host,2))[1];
	open(LOAD,"$logfile");
	@logs = <LOAD>;
	close(LOAD);
	foreach (@logs){
		local $logno = (split(/<>/))[8];
		if((stat"$logdir$logkan$logno\.log")[9] < $ltime){ last; }
		if(open(LOAD,"$logdir$logkan$logno\.log")){
			local $rog = <LOAD>;
			close(LOAD);
			local @ls = split(/<>/,$rog);
			if($ls[8]){ next; } 	# comment
			local $lid = $ls[4];
			if(crypt($xid,"mn") eq $lid || crypt($pass,"mn") eq $lid || 
			   index($ls[10],$lip) >= 0 || index($ls[11],$lhost) >= 0){
				$lono = $logno;  last;
			}
		}
		if($lono){ last; }
	}
	return ($lono);
}




##--> 仮フォルダの処理
sub kariload {
	local @ktxts=();

	# フォルダからファイル読み取り
	opendir(DIR,"$karidir");
	local @kdirs = sort(readdir(DIR));
	close(DIR);

	if(!$kday){ $kday=7; }	# $karidirに保存しておく日数
	foreach (@kdirs){
		if(/^\./ || !-f "$karidir$_"){ next; }
		if((stat"$karidir$_")[9] < (time - 86400*$kday)){ unlink "$karidir$_"; next; }
		elsif(/^[\w]+\.txt$/){ push(@ktxts,$_); }
	}
	if(@kdirs && @_[0] ne 'adm'){ &karitxt(@ktxts); }
	if(@_[0] eq 'adm'){ return(@ktxts); }
}


##--> 未投稿データの処理
sub karitxt {
	local @ktxts = @_;
	local $kok=0;	local $kid='';
	local $zip=$ip;	$zip =~ s/\.[^\.]*$/\./;
	foreach $k (@ktxts){
		open(LOAD,"$karidir$k");
		local $_ = <LOAD>;
		close(LOAD);
		if(/\&ip\=([^\&]*)\&/){ $kip=$1; }
		if(/\&host\=([^\&]*)\&/){ $khost=$1; }
		if(($kip && $kip eq $ip) || ($khost && $khost eq $host)){
			if(/\&id\=([^\&]*)\&/){ $kid=$1; }
			$kok=1; last;
		}elsif($kip && $kip =~ /^$zip/){
			if($kok==1){ $kok=2; last; }
			else{ $kok=1; if(/\&id\=([^\&]*)\&/){ $kid=$1; } }
		}
	}
	if($kok==1 && $kid){ $buffer=''; &sent($kid); }
	elsif($kok==2){ require $library3; &karisend; }
}



#--> counter
#---------------------------------------------------------------------------




##--> プチカウンター
sub counter {
	# コール
	if(@counter_call){ &call(@counter_call); }

	$iphost  = 0; 	# 0: IPでチェック. 1:ホストでチェック..
	#--- Counter Program ---#
	$jss = 'counter = "';	$jse = '";';
	$ip  = $ENV{'REMOTE_ADDR'};	$ip2 = $ENV{'REMOTE_HOST'};	# IPアドレスを取得
	if($iphost){ $ip = $ip2; }	$noup='';
	$now = (localtime(time))[3];	$mon = (localtime(time))[4]+1;	# 日を取得
	open(LOAD,"$countjs") || die;	# ファイル読みこみ
	$data = <LOAD>;
	close(LOAD);
	($w,$count,$today,$yes,$day,$y,$ip1,$ip2,$z,) = split(/\,/,$data);
	if($ipcheck==1 && $ip eq $ip1){$noup=1;}
	if($ipcheck==2 && $ip eq $ip2){$noup=1;}
	if(!$noup){
		if($now != $day){ $yes = $today; $today=0; $day=$now;}	# 日替わり.
		$count++; $today++;		$ip2=$ip1;	$ip1=$ip;
		$data = "$jss,$count,$today,$yes,$day,$mon,$ip1,$ip2,$jse";
		open(SAVE,">$countjs") || die;		# ファイル書き出し
		print SAVE $data;
		close(SAVE);
	}
	if($ENV{'QUERY_STRING'} =~ /im/){ 
		#- IMAGE出力
		@noimgs = (71,73,70,56,57,97,1,0,1,0,128,0,0,192,192,192,0,0,0,
				   33,249,4,1,0,0,0,0,44,0,0,0,0,1,0,1,0,0,2,2,68,1,0,59);
		print "Content-type: image/gif\n\n";
		binmode(STDOUT);
		foreach (@noimgs){ print pack('C*',$_); }
	}else{
		#- JS出力
		print "Content-type: application/x-javascript\n\n";
		print $data;
	}
	exit;
}




#--> cgi,lib1,lib3,
#---------------------------------------------------------------------------




##--> LOGLOAD
sub logload {
	local ($zno) = @_;
	local ($zogno,$zerror,$zdate,$ztime,$zog) = ();
	local  @zogs = ();
	if(!@logs){
		open(LOAD,"$logfile") || &error("ログファイルが開けません");
		 @logs = <LOAD>;
		close(LOAD);
	}
	foreach (@logs) {
		local ($xdate,$ximg,$ximgt,$xpch,$xname,$xtitle,$xico,$xjco,$xno,$xlo,$xtime,
				$xskp,$xanime,$xkake) = split(/<>/);
		if($xno != $zno){ next; }
		# LOG
		$zog = $_;
		$zogno = $xno;
		$zdate = $xdate;
		$ztime = $xtime;
		if(!-e "$logdir$logkan$xno\.log"){ &error("指定のログ($xno)はありません."); }
		open(LOAD,"$logdir$logkan$xno\.log")||&error("指定のログ($xno)が読み込めません");
		 @zogs = <LOAD>;
		close(LOAD);
		local ($xno,$xmo,$x,$x,$xpassd) = split(/<>/,$zogs[0],6);
		if(($mo && crypt($mo,"mn") eq $xpassd) || crypt($pass,"mn") eq $xpassd || 
			 $pass eq $mpass){ $zerror=0; }else{ $zerror=1; }
		last;
	}
	# コール
	if(@logload_call){ &call(@logload_call); }

	return ($zogno,$zerror,$zdate,$ztime,$zog,@zogs);
}




#--> cgi,lib1,lib3,
#---------------------------------------------------------------------------




##--> アプレットクッキーセット
sub app_cookie {
	local ($gs,$gm,$gh,$gday,$gmon,$gyear,$gwday) = gmtime(time + 90*24*60*60);
	$gwday = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat')[$gwday];
	$gmon = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec') [$gmon];
	$gmt_date = sprintf("$gwday, %02d\-$gmon\-%04d %02d\:%02d\:%02d GMT" ,$gday,$gyear+1900,$gh,$gm,$gs);

	local $cookapp = join(',',
		($in{'width'},$in{'height'},$in{'mode'},$in{'anime'},$in{'ptimeoff'},
		 $in{'passoff'},$in{'quality'},$in{'image_format'},$in{'image_size'}));
	print "Set-Cookie:app_sm=$cookapp; expires=$gmt_date\n";
	$appcook = "<meta http-equiv=\"Set-Cookie\" content=\"app_sm=$cookapp; expires=$gmt_date\">\n";		# クッキー利かない時
}




##--> クッキーゲット
sub get_cookie {
	@cookies = split(/;/, $ENV{'HTTP_COOKIE'});
	foreach (@cookies){	local ($w,$x) = split(/\=/,$_,2);
		$w =~ s/\s//g;	if($w eq 'relm_sm'){ $cookie = $x; last; } }
	@cookies = split(/\,|\%00/,$cookie);
#	($name,$mail,$url,$pass,$ico,$font,$color,$title,$com,$etc,$jco,);
}




##--> 基本置換
sub areplace {
#	$source,$eyear,$emon,$year,$mon
	local ($_,$zetc,$zextension) = @_;
	s/<!--FORMINPUT-->/$forminput/ig;
	s/<!--COMINPUT-->/$cominput/ig;
	s/\$FORMDATA/$formdata/ig;
	s/\$COMDATA/$comdata/ig;
	s/\$TITLE/$title/ig;
	s/\$PASS/$pass/ig;
	s/\$WORD/$word/ig;
	s/\$PAGE/$page/ig;
	s/\$VIEW/$view/ig;
	s/\$SORT/$sort/ig;
	s/\$NTRES/$ntres/ig;
	s/\$SFORM/$sform/ig;
	s/\$LOG\_?NO/$no/ig;
	s/\$LOG\_?MO/$mo/ig;

	# ETC .. 親・レス共通 拡張スロット
	# EXTENSION .. 親専用 拡張スロット
	foreach $et ($zetc,$zextension){
		if(!$et){ next; }
		local %ex=();
		foreach $ew (split(/\&/,$et)){
			local ($ey,$ez) = split(/\=/,$ew,2);
			if(!$ey){ next; }
			$ez =~ s/\&amp\;/\&/g;
			s/\$$ey/$ez/ig;
		}
	}

	# コール
	if(@areplace_call){ &call(@areplace_call); }

	return $_;
}




#--> cgi,lib3
#---------------------------------------------------------------------------




##--> FRAME 表示
sub frame {
	local $script2 = $script;
	if(@_[0] == 2 && $frmhtm){ $frameset = $frameset2;  $script2 = $script_; }
	$frameset =~ s/\$script/$script2/ig;
	$frameset =~ s/\$fcr/$fcr/ig;
	$frameset =~ s/\$index/$index/ig;
	$frameset =~ s/\$listhtm/$listhtm/ig;
	$frameset =~ s/\Q$ptori\E/$psasi/ig if($ptori);
	if($frame == 3 && @_[0] != 2){
		$frameset =~ s/(src\=\"$script\?[^\"]+)(\")/$1\&word\=frame$2/ig;
	}

	# フレームソース
	$frmsource = <<"HTML";
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="content-type" content="text/html;charset=x-sjis">
<title>++ $title_ ++</title>
</head>
$frameset
<noframes>
<body>
	<p>なるべくフレーム対応ブラウザでご覧下さい。</p>
	<p>閲覧は<a href="$script?mode=relm">こちら</a>からどうぞ。</p>
</body>
</noframes>
</html>
HTML

	# コール
	if(@frame_call){ &call(@frame_call); }

	if(@_[0] == 2){
		if($frmed != 1){ 
			$frmed = 1;	# 足跡
			open (FILE, ">$frmhtm");
			print FILE $frmsource;
			close(FILE);
			chmod (0666,"$frmhtm");
		}
	}else{
		print "Content-type: text/html\n\n";
		print $frmsource;
		exit;
	}
}




##--> ヘッダーとフッター
sub headfoot {
	local ($askin,$snm)=();
	if(@_[0]){ $askin = @_[0]; }
	elsif($mainskin == 1){ $askin = $r_skin; $snm='l_skin'; }
	else{ $askin = $w_skin; $snm='l_form'; }

	# スキンがあるか
	if(!-f "$skindir$askin" && -f "$skindir$n_skin"){
		$comment .= "\skin($skindir$askin) がありません。<br>\n";
		$askin = $n_skin;
	}

	# コール 1
	if(@headfoot_call_1){ &call(@headfoot_call_1); }

	local $_ = '';
	$body3 = '';
	($mskin,$head,$foot,$body1,$body2,$painty)=();
	if($type eq 'skinsource' && $in{'source'} && $snm && $in{"skinf"} =~ /^$snm/i){
		$_ = $in{'source'};
	}else{
		if(open(SKIN,"$skindir$askin")){
			local $bite = (stat(SKIN))[7];
			read (SKIN,$_,$bite);
			close(SKIN);
		}else{ &error("\"$askin\"が開けません.",'nohead'); }
	}
	s/\$target/$targetm/ig;
	s/\$script/$script/ig;
	s/\$home/$home/ig;
	s/\$counter/$countjs/ig;
	s/\$tyosaku/$tyosaku/ig;

	# HEAD-FOOT-Source
	if(s/(<!--HEAD_START-->\n?)(.*)(<!--HEAD_END-->\n?)//iso){ $head=$2.$3; }
	if(s/(<!--FOOT_START-->\n?)(.*)(<!--FOOT_END-->\n?)//iso){ $foot=$1.$2; }
	if($view eq 'mini'){s/^.*(<!--WRITE_START-->)/$1/iso;s/(<!--WRITE_END-->).*$/$1/iso;}
	if(s/(<!--PAINT_START-->\n?)(.*)(<!--PAINT_END-->\n?)//iso){ $painty=$2.$3; }

	s/<!--(\/EDIT_DELETE)-->/\f<!--$1-->/ig;
	s/<!--(EDIT_DELETE)-->[^\f]*\f<!--\/\1-->//isg;

	s/<!--(\/PATI)-->/\f<!--$1-->/ig;
	s/<!--(PATI)-->[^\f]*\f<!--\/\1-->//isg;

	if($mainskin == 1){ 
		s/<!--LAYER_FORM_START-->.*<!--LAYER_FORM_END-->//iso;
		s/<!--(\/SEARCH)-->/\f<!--$1-->/ig;
		s/<!--(SEARCH)-->[^\f]*\f<!--\/\1-->//isg;
		if(s/^(.*)<!--PARENT_START-->//iso){ $body1=$1; }
		if(s/<!--PARENT_END-->(.*)$//iso)  { $body2=$1; }
	}else{ 
		s/<!--STATUS_START-->.*<!--STATUS_END-->//iso;
		s/<!--PARENT_START-->.*<!--PARENT_END-->//iso;
		if(s/^(.*)<!--FORM_START-->//iso){ $body1=$1; }
		if(s/<!--FORM_END-->(.*)$//iso)  { $body2=$1; }
	}

	$body3 = $_;
	$mskin = $_;	# skin-source
	$_ = '';	# delete

	$head =~ s/\$title/$title_/g;
	$head =~ s/\$BGROUND/$bground/ig;
	$head =~ s/\$CSS/$css/ig;

	# コール_2
	if(@headfoot_call_2){ &call(@headfoot_call_2); }
}




# HEADER
sub head {
	if(!$head){ &headfoot(''); }
	print "Content-type: text/html\n\n";
	print $head;

	# コール
	if(@head_call){ &call(@head_call); }

	$body1 = &areplace($body1);
	print $body1;
}
# FOOTER
sub foot {
	# コール
	if(@foot_call){ &call(@foot_call); }

	$body2 = &areplace($body2);
	print $body2;

	$foot  = &areplace($foot);
	print $foot;
	exit;
}




##------------##
##- プロセス -##
##------------##
sub process {
	local $ti='s,';
	local ($user2,$syst2,$c_user2,$c_syst2,) = times();
	printf("<div align=right><tt>プロセス消費時間 ＞ User:%5.2f$ti System:%5.2f$ti</tt></div>",($user2-$user1),($syst2-$syst1));
#	printf("<div align=right>プロセス消費時間 ＞ User:%5.2f$ti System:%5.2f$ti C_User:%5.2f$ti C_System:%5.2f$ti </div>",($user2-$user1),($syst2-$syst1),($c_user2-$c_user1),($c_syst2-$c_syst1));
}




##------------##
##- リロード -##
##------------##
sub reload {
	print "Content-type: text/html\n\n";
	&headfoot;
	if($head){
		local $title = "- Refresh -";
		print $head;
	}else{ print "<html>\n<head>\n</head>\n<body>\n<div align=center>"; }
	if($writehtm && $index){
		$script=$index; if($ptori){ $script=~s/\Q$ptori\E/$psasi/ig; }
	}
	if($script =~ /index\.html?$/i){ $script =~ s/index\.html?$//i; }
	print "<meta http-equiv=\"refresh\" content=\"0;url=$script\">\n";
	print "<p align=center>キャッシュをリフレッシュしようとしています。<br>\n";
	print "自動で飛ばない場合は<a href=\"$script\">→コチラ</a>。</p>";
	print "</div>\n</body>\n</html>\n";
	exit;
}




##----------##
##- エラー -##
##----------##
sub error {
	local @es = @_;
	local $et = '';
	if($lockon==1){ &unlock; }
	if($pass eq ''){
		&get_cookie;
		$cpass = $cookies[3];
		if($es[1] eq 'admm'){
			if($cpass eq $mpass){ $pass = $cpass; return $pass; }
			else{ $et = "(pass:$pass / cookie:$cpass)"; }
		}elsif($es[1] eq 'usee'){
			if($cpass){ $pass = $cpass; return $pass; }
			else{ $et = "(pass:$pass / cookie:$cpass)"; }
		}
		$pass = $cpass;
	}

	print "Content-type: text/html\n\n";
	# 瞬速レスの時
	if($nohtm){
		local $e = $es[0];
		$e =~ s/<br>/\\n/g;
		print "<html>\n<head>\n</head>\n<body>\nERROR！<br>\n投稿されませんでした。\n";
		print "<br><br>\n掲示板に戻るなら「<a href=\"$script\">こちら</a>」\n";
		print "<script type=\"text/javascript\"><!--\nalert('$e');\n//--></script>";
		print "\n</body></html>";
		exit;
	}

	# 一般
	if(!$head && $es[1] ne 'nohead'){ &headfoot(''); }
	if($head){
		local $title = "- ERROR -";
		print $head;
	}else{ print "<html>\n<head>\n</head>\n<body>\n<div align=center>"; }

	$com =~ s/<br>/\n/g;
	if($com || $es[2] =~ /comm\,?/){ 
		$es[2] =~ s/comm\,?//g;
		$comarea = "<br>\t* Comm: <textarea cols=50 rows=3 name=\"comm\">$com</textarea><br>";
	}else{ $comarea = '<input type="hidden" value="" name="comm">'; }

	# コール
	if(@error_call){ &call(@error_call); }

	if($in{'up'}){ $formtag = ' enctype="multipart/form-data"'; }
	else{ $formtag=''; }

	print <<"HTML";
$es[0] $et<br>
<form action="$script" method="post"$formtag>
HTML

	local @kys = sort(keys %in);
	foreach $key (@kys) {
		if(!$key || $key eq 'pass' || $key eq 'comm' || $key eq 'up'){ next; }
		if($es[2] && $key =~ /\,?$es[2]\,?/){ next; }
		print "\t".'<input type="hidden" name="'.$key.'" value="'.$in{$key}.'">'."\n";
	}
	if($es[2]){
		foreach $key (split(/\,/,$es[2])){
			print "\t"."* \u$key".': <input type="text" name="'.$key.'" size=27 value="'.$in{$key}.'"><br>'."\n";
		}
	}

	if($in{'up'}){
		$upf="\t".'<br>* Upload: <input type="file" name="up" size=27 value=""><br>'."\n"; }
	else{ $upf=''; }

	print <<"HTML";
	$comarea
	$upf
	<br>
	* Pass: <input type="password" name="pass" size=10 value="$pass">
	<input type="submit" value="submit" class="button"><br>
	<br>
</form>
	<a href="javascript:history.back();" style="cursor:hand;">→back</a>
	<a href="$script?type=reload">→reload</a>
HTML

	if(!$foot){ $foot = "</div>\n</body>\n</html>\n"; }
	else{ $foot  = &areplace($foot); }
	print $foot;
	exit;
}




exit;

#}

1;
