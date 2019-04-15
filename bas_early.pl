
# アイディア
# １位～３位の人には、特別賞金、金貨１００枚プレゼント
# 早起きコンボ
# 早起き優秀者（コンボ数、早起き総数）
# ステータス- 朝食、散歩、歯磨き、二度寝しました……
# 早起き者が１日に１００人を超えたら、王様から受勲

use Mebius::Export;

#-----------------------------------------------------------
# 基本設定
#-----------------------------------------------------------
sub init_start{

}


#-----------------------------------------------------------
# 処理スタート
#-----------------------------------------------------------

sub start{

# 設定
$early_starttime = 1257668046;
$title = $sub_title = "きょうの早起きさん";
$script = "./";
if($alocal_mode){ $script = "early.cgi"; }
else{ $style = '/style/blue1.css'; }
$head_link2 = qq( &gt; <a href="$script">$title</a> );
$moto = "early";
$early_dir = "${int_dir}_early/";
$head_link1 = qq(&gt; <a href="$base_url">メビウスリング</a> | <a href="$goraku_url">娯楽版</a> );

# CSS定義
$css_text .= qq(
h1{text-align:center;}
h2{font-size:120%;}
h2.menu{clear:both;}
table,th,tr,td{border-style:none;}
table{width:100%;}
th{text-align:left;padding:0.2em 0.2em 0.2em 0.4em;}
td{padding:0.5em 0.5em 0.5em 0.2em;}
div.stamp,form.stamp{text-align:center;}
div.stamp{font-size:130%;line-height:0.8em;}
input{font-size:80%;}
input.stamp{font-size:90%;}
.ads{text-align:center;margin:auto;}
.adsname{padding:0.3em;font-size:80%;background-color:#dee;width:728px;margin:2.5em auto 1.0em auto;text-align:center;}
.ads_right{float:right;width:165px;padding-left:3px;}
.contents{float:left;}
);

$ads_top = qq(
<div class="ads">
<br><br>
<script type="text/javascript"><!--
google_ad_client = "pub-7808967024392082";
/* 728x15, 早起きさん 09/11/08 */
google_ad_slot = "1470257233";
google_ad_width = 728;
google_ad_height = 15;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
</div>
);

$ads_right = qq(<script type="text/javascript"><!--
google_ad_client = "pub-7808967024392082";
/* 160x600, 早起きさん右 09/11/08 */
google_ad_slot = "9642307585";
google_ad_width = 160;
google_ad_height = 600;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
);

if($alocal_mode){ $ads_top = qq(<div class="adsname">スポンサードリンク</div><div class="ads" style="width:728px;height:90px;border:solid 1px #000;">広告</div>);
$ads_top = "";
}


# 開始時間、終了時間
$early_start_hour = 5;
$early_end_hour = 7;
$early_second_end_hour = 8;

# 送信を受け入れる環境
if(($k_access || $cookie) && !$bot_access){ $main::device{'level'} = 1; }

# スタンプを受け入れる日時
if($alocal_mode || ($thishour >= $early_start_hour && $thishour <= $early_end_hour) ){ $early_flag = 1; }
if($alocal_mode || ($thishour >= $early_start_hour && $thishour <= $early_second_end_hour) ){ $second_early_flag = 1; }

# モード振り分け
if($mode eq ""){ &index; }
elsif($submode1 eq "log"){ &index; }
elsif($mode eq "menu"){ &menu; }
elsif($mode eq "stamp"){ &stamp; }
else{ &error("表\示モードを指定してください。$in{'mode'} ( $title )"); }

}

#-----------------------------------------------------------
# 早起きを表示
#-----------------------------------------------------------

sub index{

# 局所化
my($form,$i,$hit,$myhandle,$mycomment,$mystatus,$submit_value1,$myform_flag,$topage_flag);

# ログを開く日付
my($early_year,$early_month,$early_day) = ($submode2,$submode3,$submode4);
if($mode eq ""){
$topage_flag = 1;
($early_year,$early_month,$early_day) = ($thisyear,$thismonth,$today);
} 

# 汚染チェック
$early_year =~ s/\D//g;
$early_month =~ s/\D//g;
$early_day =~ s/\D//g;



# 今日のファイルを開く
open(TODAY_IN,"${early_dir}_log_early/$early_year-$early_month-$early_day.cgi");
my $top = <TODAY_IN>;
while(<TODAY_IN>){
$i++;
chomp;
my($mark,$mark_breakfast,$mark_brush,$mark_readbook,$mark_walk,$flag);
my($key,$handle,$id,$trip,$xip2,$number,$account,$status,$comment,$hour,$min,$sec) = split(/<>/);
my($breakfast,$brush,$readbook,$walk) = split(/,/,$status);

if($pmfile || $cnumber){
if($account ne "" && $account eq $pmfile){ $flag = 1; }
if($number ne "" && $number eq $cnumber){ $flag = 1; }
}
elsif($xip2 eq $xip){ $flag = 1; }

if($flag){
$myform_flag = 1;
($myhandle,$mycomment,$mystatus) = ($handle,$comment,$status);
($mybreakfast,$mybrush,$myreadbook,$mywalk) = ($breakfast,$brush,$readbook,$walk);
}
$hit++;
my $name = $handle;
if($trip ne ""){ $name = qq($name☆$trip); }
if($account ne ""){ $name = qq(<a href="${auth_url}$account/">$name</a>); }
if($hit <= 3){
$mark = qq(<span class="fast1 red">最優秀早起きさん。</span>) if($hit == 1);
$mark = qq(<span class="fast2 red">２番目早起きさん。</span>) if($hit == 2);
$mark = qq(<span class="fast3 red">３番目早起きさん。</span>) if($hit == 3);
}
if($breakfast eq "1"){ $mark_breakfast = "○"; }
if($brush eq "1"){ $mark_brush = "○"; }
if($readbook eq "1"){ $mark_readbook = "○"; }
if($walk eq "1"){ $mark_walk = "○"; }
$line .= qq(<tr><td>$name</td><td><i>$id</i></td><td>$hour時$min分</td><td>$mark_breakfast</td><td>$mark_brush</td><td>$mark_readbook</td><td>$mark_walk</td><td>$mark</td></tr>);
}
close(TODAY_IN);

# 内容がない場合
if($mode ne "" && $line eq ""){ &error("この日のログはありません。"); }

# 整形
$line = qq(
<h2>早起き者リスト</h2>
<table summary="レイアウトテーブル">
<tr><td class="valign-top">
<table summary="早起き者リスト"><tr><th>筆名</th><th>ID</th><th>時間</th><th>朝食</th><th>歯磨き</th><th>読書</th><th>散歩</th><th>賞</th></tr>
$line
</table>
</td><td class="valign-top">
$ads_right</td></tr></table>
);

# 送信ボタン
if($k_access){ $sumit_value1 = qq(早起きしました！); }
else{ $submit_value1 = qq($thishour時$thismin分、早起きしました！); }
if($k_access){ $submit_value2 = qq(朝の準備しました！); }
else{ $submit_value2 = qq(朝の準備しました！); }

# 情報入力フォーム
if($myform_flag && $second_early_flag && $main::device{'level'} && $topage_flag){
my($check_breakfast,$check_readbook,$check_walk,$check_name,$check_submit,$hit);
if($mybreakfast eq "1"){ $check_breakfast = " checked disabled"; $hit++; }
if($mybrush eq "1"){ $check_brush = " checked disabled"; $hit++; }
if($myreadbook eq "1"){ $check_readbook = " checked disabled"; $hit++; }
if($mywalk eq "1"){ $check_walk = " checked disabled"; $hit++; }
#if($hit >= 4){ $check_submit = " disabled"; }

$form = qq(
<form action="$script" method="post" class="stamp"$sikibetu>
<div class="stamp">
<input type="hidden" name="mode" value="stamp">
<input type="hidden" name="name" value="$cnam">
<input type="checkbox" name="breakfast" value="1"$check_breakfast>朝食
<input type="checkbox" name="brush" value="1"$check_brush>歯磨き
<input type="checkbox" name="readbook" value="1"$check_readbook>読書
<input type="checkbox" name="walk" value="1"$check_walk>散歩
<br><br>
<input type="submit" value="$submit_value2" class="stamp"$check_submit>
</div>
</form>
);
}

# 早起きボタンフォーム
elsif($early_flag && $main::device{'level'} && $topage_flag){
$form = qq(
<form action="$script" method="post" class="stamp"$sikibetu>
<div class="stamp">
<input type="hidden" name="mode" value="stamp">
筆名 <input type="text" name="name" value="$cnam"><br><br>
<input type="submit" value="$submit_value1" class="stamp">
<br><br>
<span class="alert">※朝まで起きていた人は登録せず、また明日チャレンジしてください。</span>
</div>
</form>
);
}

# 時間を過ぎている場合
elsif($main::device{'level'}){
$form = qq(
<div class="stamp">
$early_start_hour時00分～$early_end_hour時59分まで早起き登録できます。
</div>
);

}

#<span class="guide">※ボタンを押すと早起き時間が記録されます。押せるのは$early_start_hour時00分～$early_end_hour時59分です。</span>

# 過去ログメニュー
my $other_menu = qq(<h2 class="menu">メニュー</h2><a href="$script?mode=menu">今までの早起きさん</a>);

# タイトル定義
if($mode eq ""){ $head_link2 = qq( &gt; $title ); }
else{
$head_link3 = qq( &gt; $early_year年 $early_month月$early_day日 );
$sub_title = qq($early_year年$early_month月$early_day日の早起きさん | $title); 
}

# 表示タイトル
my $page_title = $title;
if($mode ne ""){ $page_title = "$early_year年$early_month月$early_day日の早起きさん"; }

# HTML
my $print = qq(
<h1>$page_title</h1>
$form
$ads_top
$line
$other_menu
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# メニュー
#-----------------------------------------------------------
sub menu{

# 局所化
my($line,$hit);

my $thistime = $time;

# 日付リスト
while($thistime > $early_starttime){
$thistime -= 1*24*60*60;
my(undef,undef,$year,$month,$day) = Mebius::Getdate("",$thistime);
$hit++;
$line .= qq(<li><a href="log-$year-$month-$day.html">$year年 $month月$day日 の早起きさん</a>);
if($hit > 365){ last; }
}

# 整形
$line = qq(<ul>$line</ul>);

# タイトル定義
$sub_title = qq(今までの早起きさん | $title);
$head_link3 = qq( &gt; 今までの早起きさん );


# HTML
my $print = qq(
<h1>今までの早起きさん</h1>
$line
);

Mebius::Template::gzip_and_print_all({},$print);

exit;


}


#-----------------------------------------------------------
# スタンプを押す
#-----------------------------------------------------------
sub stamp{

# Cookieセットを禁止
$no_headerset = 1;

# 局所化
my(@line,$hit,$i_handle,$i_name,$i_handle,$enctrip,$i_name);

# GET送信を禁止
if(!$postflag){ &error("GET送信は出来ません。"); }

# 汚染チェック
$in{'breakfast'} =~ s/\D//g;
$in{'brush'} =~ s/\D//g;
$in{'walk'} =~ s/\D//g;
$in{'readbook'} =~ s/\D//g;

# 送信を禁止
if(!$main::device{'level'}){ &error("この環境では送信できません。"); }

# アクセス制限
&axscheck;

# ＩＤをつける
&id;

# トリップをつける
my($enctrip,$i_handle) = &trip($in{'name'});

# 各種エラー
if(!$second_early_flag){ &error("この時間帯はスタンプを押せません。"); }
require "${int_dir}regist_allcheck.pl";
($i_handle) = shift_jis(Mebius::Regist::name_check($i_handle));
#if($i_handle eq ""){ $i_handle = "早起きさん"; }
&error_view("AERROR");

# ロック開始
&lock($moto) if $lockkey;

# タイトル定義
$head_link3 = qq( &gt; スタンプを押す );

# 今日のファイルを開く
open(TODAY_IN,"${early_dir}_log_early/$thisyear-$thismonth-$today.cgi");

# TOPデータの処理
my $top = <TODAY_IN>; chomp $top;
my($none) = split(/<>/,$top);

while(<TODAY_IN>){
chomp;
my($key,$handle,$id,$trip,$xip2,$number,$account,$status,$comment,$hour,$min,$sec) = split(/<>/);
my($breakfast,$brush,$readbook,$walk) = split(/,/,$status);
my($flag);

if($pmfile || $cnumber){
if($account ne "" && $account eq $pmfile){ $flag = 1; }
if($number ne "" && $number eq $cnumber){ $flag = 1; }
}
elsif($xip2 eq $xip){ $flag = 1; }

if($flag){
if($in{'name'}){ ($handle,$trip) = ($i_handle,$enctrip); }
($id,$account,$xip2) = ($encid,$pmfile,$xip);
if($in{'breakfast'} eq "1"){ $breakfast = 1; }
if($in{'brush'} eq "1"){ $brush = 1; }
if($in{'readbook'} eq "1"){ $readbook = 1; }
if($in{'walk'} eq "1"){ $walk = 1; }
$status = "$breakfast,$brush,$readbook,$walk";
$hit = 1;
}
push(@line,"$key<>$handle<>$id<>$trip<>$xip2<>$number<>$account<>$status<>$comment<>$hour<>$min<>$sec<>\n");
}
close(TODAY_IN);

# 新規登録の場合
if(!$hit){ push(@line,"1<>$i_handle<>$encid<>$enctrip<>$xip<>$cnumber<>$pmfile<>$status<>$comment<>$thishour<>$thismin<>$thissec<>\n"); }

# トップデータを追加
unshift(@line,"$none<>\n");

# ファイルを書き込み
open(TODAY_OUT,">${early_dir}_log_early/$thisyear-$thismonth-$today.cgi");
print TODAY_OUT @line;
close(TODAY_OUT);
Mebius::Chmod(undef,"${early_dir}_log_early/$thisyear-$thismonth-$today.cgi");

# ロック解除
&unlock($moto) if $lockkey;

# Cookie をセット
Mebius::Cookie::set_main({ name => $in{'name'} },{ SaveToFile => 1 });

# ジャンプ先
$jump_url = "$script";
$jump_sec = 1;


# HTML
my $print =  qq(スタンプを押しました！（<a href="$script">→戻る</a>）);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



1;

