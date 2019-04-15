package main;
use Mebius::Export;

#-------------------------------------------------
# ＢＢＳの記事表示
#-------------------------------------------------
sub auth_bbs{

# 局所化
my($file,$ads1,$ads2,$form,$open,$deleted_flag,$adsflag,$onlyflag,$link1,$link2);

# 定義
my $maxmsg = 2500;

# １記事あたりのレスの最大表示数
my $maxview_res = 50;

# ＣＳＳ定義
$css_text .= qq(
.date{text-align:right;}
.dtextarea{width:95%;height:200px;}
.maxmsg{color:#f00;font-size:90%;}
.deleted{color:#f00;font-size:120%;}
.cdeleted{color:#f00;font-size:80%;}
a.me:link{color:#f00;}
a.me:visited{color:#f40;}
h1{color:#f50;}
);

# 汚染チェック１
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("開くファイルを指定してください。"); }

# 汚染チェック２
$open = $submode2;
$open =~ s/\D//g;
if($open eq ""){ &error("開くファイルを指定してください。"); }

# プロフィールを開く
&open($file);


# ユーザー色指定
if($ppcolor1){
$css_text .= qq(h2{background-color:#$ppcolor1;border-color:#$ppcolor1;});
}

# マイメビ状態取得
&checkfriend($file);

# BBSの表示制限
if($pplevel >= 1 || !$mebi_mode){
if($pposbbs eq "2"){
if(!$yetfriend && !$myprof_flag && !$myadmin_flag){ &error("日記が存在しません。"); }
$text1 = qq(<em class="green">●$friend_tagだけに記事公開中です</em><br><br>);
$onlyflag = 1;
}
elsif($pposbbs eq "0"){
if(!$myprof_flag && !$myadmin_flag){ &error("日記が存在しません。"); }
$text1 = qq(<em class="red">●自分だけに記事公開中です</em><br><br>);
$onlyflag = 1;
}
}

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# 記事ファイルを開く
open(BBS_IN,"<","${account_directory}bbs/${file}_bbs_${open}.cgi") || &error("記事が存在しません。");

my $dtop1 = <BBS_IN>;
my($key,$num,$sub,$res,$dates) = split(/<>/,$dtop1);
my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);
$pageyear = $year;
$pagemonth = $month;
$pagenum = $num;
$keydtop1 = $key;


# 記事本体が削除済みの場合
if($keydtop1 eq "2" || $keydtop1 eq "4"){
if($myadmin_flag) { $deleted_flag = qq(<strong class="deleted">この記事は削除済みです（管理者のみ閲覧可能\）</strong><br><br>); }
else{ &error("この記事は削除済みです。","410 Gone"); }
}

# 上部ナビリンク
$link1 .= $text1;
$link1 .= $deleted_flag;

$link2 = "$adir${file}/";
if($aurl_mode){ ($link2) = &aurl($link2); }
$link1 .= qq(<a href="$link2">プロフィールへ</a>);

if($file eq $pmfile || $myadmin_flag){
if($keydtop1 eq "1"){ $link1 .= qq( - <a href="$script?mode=keditbbs&amp;account=$file&amp;num=$open&amp;decide=lock">コメントロック</a>); }
elsif($keydtop1 eq "0"){ $link1 .= qq( - <a href="$script?mode=keditbbs&amp;account=$file&amp;num=$open&amp;decide=revive">コメントロック解除</a>); }
if($keydtop1 eq "2" || $keydtop1 eq "4"){ $link1 .= qq( - <a href="$script?mode=keditbbs&amp;account=$file&amp;num=$open&amp;decide=revive">記事の復活</a>); }
else{ $link1 .= qq( - <a href="$script?mode=keditbbs&amp;account=$file&amp;num=$open&amp;decide=delete&amp;preview=on">記事の削除</a>); }
}

$link1 .= qq( - <a href="${guide_url}%BA%EF%BD%FC%B0%CD%CD%EA%A1%CA%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A1%CB">削除依頼について</a>);

if($alocal_mode){ $link1 = &aurl($link1); }

$bbs .= qq(<h1>$sub - BBS</h1>$link1<h2>本文</h2>);

while(<BBS_IN>){

chomp $_; if(!$_){ next; }
my($key,$num,$account,$name,$id,$trip,$comment,$dates) = split(/<>/,$_);
my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);

my $link = qq($adir${account}/);
if($aurl_mode){ ($link) = &aurl($link); }

if($num eq "1"){
$bbs .= qq(<h2>コメント</h2>);
if($res > $maxview_res && $submode3 ne "all"){
my $cut = $res - $maxview_res;
my $link = "$adir$file/b-$open-all";
if($aurl_mode){ ($link) = &aurl($link); }
$bbs .= qq(（ <a href="$link">$cut件のレスが省略されています</a> ）<br><br>);

}
}

$iline++;
if($iline != 1 && $iline <= $res - $maxview_res + 1 && $submode3 ne "all"){ next; }

# 通常表示の場合
if($key eq "1"){
($comment) = &auth_auto_link($comment);
my($delete,$class);
if($account eq $file){ $class = qq( class="me"); }
if($myadmin_flag || $file eq $pmfile || $account eq $pmfile){ $delete = qq(<a href="$script?mode=skeditbbs&amp;account=$file&amp;num=$open&amp;number=$num&amp;decide=delete">削除</a> - ); }
$bbs .= qq(<p id="S$num"><a href="$link"$class>$name - $account</a><br><br>$comment</p><div class="date">$delete$year年$month月$day日 $hour時$min分 No.$num</div>);
if($key eq "1" && $adsflag1 < 2 && $num eq "0" && !$noads_mode){ $bbs .= qq($ads1); $adsflag1++; }
elsif($key eq "1" && $adsflag2 < 2 && $num eq $res && !$noads_mode){ $bbs .= qq($ads2); $adsflag2++; }
}

# 削除済みの場合
else{
my($deleted);
if($key eq "3"){ $deleted = qq(投稿者により削除); }
elsif($key eq "2"){ $deleted = qq(アカウント主により削除); }
elsif($key eq "4"){ $deleted = qq(管理者により削除); }
if($myadmin_flag){ $deleted .= qq(<br><br><span class="cdeleted">$comment<br>（削除済み。管理者にだけ見えます - <a href="$script?mode=skeditbbs&amp;account=$file&amp;num=$open&amp;number=$num&amp;decide=revive">復活</a>）</span>); }
$bbs .= qq(<p id="S$num">$account <a href="$link">*</a><br><br>$deleted</p><div class="date">$year年$month月$day日 $hour時$min分 No.$num</div>);
}

# 区切り線
if($num >= 1 && $num ne $res){ $bbs .= qq(<hr>); }

}
close(BBS_IN);

	Mebius::Fillter::fillter_and_error(utf8_return($sub));

my($form) = &auth_bbs_getform("",$file,$open);

# タイトル定義
$sub_title = qq($sub);


my $print = <<"EOM";
$footer_link

$bbs

$form
$footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-------------------------------------------------
# 記事のコメントフォーム
#-------------------------------------------------

sub auth_bbs_getform{

return("現在、BBSには書き込むことが出来ません。");

# 局所化
my($type,$file,$open) = @_;
my($stop,$form);

# コメント可否の判定
if($ppkey eq "2"){ $form .= qq(▼アカウントがロック中のため書き込めません<br><br>); $stop = 1; }
elsif($denyfriend){ $form .= qq(▼禁止設定中のためコメントできません。<br><br>); $stop = 1; }
elsif($ppobbs eq "0"){
$form .= qq(▼アカウント主だけがコメントできます。<br><br>);
if(!$myprof_flag){ $stop = 1; }
}
elsif($key eq "0"){ $form .= qq(▼この記事はコメントロック中のため、書き込めません。<br><br>); $stop = 1; }
elsif($ppobbs eq "2"){ $form .= qq(▼$friend_tagだけがコメントできます。<br><br>); 
if(!$yetfriend && !$myprof_flag){ $stop = 1; } 
}

# 管理者の場合
if($myadmin_flag){ $stop = ""; }

# 筆名未設定の場合
if($res >= $maxres_bbs){ $form = qq(▼コメントがいっぱいです。（最大$maxres_bbs件）<br><br>); $stop = 1; }
elsif(!$idcheck){ $form = qq(▼コメントするには<a href="$auth_url">ログイン（または新規登録）</a>してください。<br><br>); $stop = 1; }
elsif($birdflag){ $form = qq(▼コメントするには<a href="$auth_url$pmfile/#EDIT">あなたの筆名</a>を設定してください。<br><br>); $stop = 1; }


# コメントフォーム見出し
$form = qq(<h2>コメントフォーム</h2>$form);

# フォーム定義
if(!$stop){
$form .= <<"EOM";
<form action="$action" method="post"$sikibetu>
<div>
$ipalert<br>
<textarea name="comment" class="dtextarea" cols="25" rows="5"></textarea>
<br><br><input type="submit" value="この内容でコメントする"> <strong class="maxmsg">(全角$maxmsg文字まで)</strong>
<input type="hidden" name="mode" value="resbbs">
<input type="hidden" name="account" value="$file">
<input type="hidden" name="num" value="$open">
<br><br>
</div>
</form>
EOM
}

return($form);

}



1;
