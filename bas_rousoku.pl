
sub init_start{

# ドメイン
$server_domain = "mb2.jp";

# 外部CSS
#$style = "/style/bas.css";

# ヘッダリンク
$head_link1_5 = qq(&gt; <a href="${base_url}gap/">ゲームコーナー</a>);
$head_link1 = qq(&gt; <a href="$base_url">通常</a>-<a href="$goraku_url">娯楽</a>);

# ＸＩＰを記録する数
$rousoku_xipcnt_max = 10;

# 連続投稿間隔(秒)
$rennzoku_sec = 300;

# ロウソクが最大数経ったとき、天国表示する日数
$heaven_day = 3;

# 天国モードの背景画像
$heaven_img = "http://mb2.jp/pct/rousoku_heaven.gif";

# 天国モードに到達するためのロウソク数（最大ロウソク数）
$max_rousoku = 1000;

# タイトル
$title = "ロウソ\ク立て";

# ヘッダタイトル
$sub_title = "願いを叶える、ロウソ\ク立て";

# スクリプト名定義
$moto = "rousoku";

$css_text = <<"EOM";
.body1{border-color:#000;}
.rousoku1{width:7px;height:20px;}
.rousoku10{width:8px;height:32px;}
.rousoku100{width:18px;height:60px;}
.rousoku1000{width:25px;height:90px;}
EOM

$ads1 = <<"EOM";
<br>
<script type="text/javascript"><!--
google_ad_client = "pub-7808967024392082";
/* ロウソク */
google_ad_slot = "2223327940";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
<br>
EOM
}


sub init_option{ }

#-----------------------------------------------------------
# スクリプトをスタート
#-----------------------------------------------------------

sub start{

# アクション先など調整
if($alocal_mode){ $script = "$moto.cgi"; }
else{ $script = "./"; }

# REFERER元調整
if($in{'referer'}){ $referer_url = $in{'referer'}; }
elsif($in{'action'} eq ""){$referer_url = $referer; }

# 局所化
local($top,$back_link,$form,$kaisetu,$submit,$now_text,$heaven_mode);

# ロウソクデータを開く
open(ROUSOKU_IN,"${int_dir}_rousoku/rousoku_data.cgi");
$top = <ROUSOKU_IN>;
close(ROUSOKU_IN);

# データがない場合、バックアップから開く
if($top eq ""){
open(BACKUP_IN,"${int_dir}_rousoku/rousoku_backup.cgi");
$top = <BACKUP_IN>;
($rousoku_num,$xip_list,$lasttime) = split (/<>/,$top);
close(BACKUP_IN);
}

# ロウソクデータからデータ認識
($rousoku_num,$xip_list,$lasttime) = split (/<>/,$top);

# 天国モード判定
if($rousoku_num >= $max_rousoku){ $heaven_mode = 1; }

# 天国モードの終了を判定
if($heaven_mode && $time > $lasttime + $heaven_day*24*60*60){ $heaven_mode_end = 1; }

# 天国モードが終わっている場合の判定、ロウソクを０本に
if($heaven_mode_end){
$heaven_mode = "";
$rousoku_num = 0 ;
}

# 天国モードの場合、背景画像をつける
if($heaven_mode) {
$css_text .= <<"EOM"
body{background-image: url(${heaven_img});

background-position:center;
}
EOM
}

# ヘッダリンクを定義
$head_link2 = "&gt; $title";
$thisis_bbstop = 1;


# 現在のロウソク本数テキストを定義

$now_text = qq(
今、$rousoku_num本のロウソ\クが立っています。 ( $thismonth月$today日 $thishour時$thismin分$thissec秒、この時を )
);

# 解説文を定義
$kaisetu = <<"EOM";
<br><br> 
時間をおいて１本ずつ、ロウソ\クを立てることが出来ます。<br>
「あなたの願い」を込めて、ロウソ\クを立ててみてください。<br>
ロウソ\クが <strong class="red">$max_rousoku本</strong> になると、願いが天に昇ります。<br>
EOM

# フォームを定義
$form = <<"EOM";
<br>
<form action="$script" method="post" class="nomargin">
<div>
<input type="hidden" name="referer" value="$referer_url">
<input type="submit" name="action" value="願いを込めて、あなたのロウソ\クを立てる">
</div>
</form>
EOM

# ロウソクがマックスの場合、フォームを消し、解説文を変更
if($heaven_mode){

$form = "";
$kaisetu = "";

$now_text = <<"EOM";
なんと、ついに <strong class="red">$max_rousoku本</strong> のロウソ\クが立ちました！<br>
皆の願いが、天に昇って行ってます。<br><br>
ロウソ\クを立ててくれたみんな、ありがとう！<br>
願いは <strong class="red">$heaven_day日間</strong> をかけて、空へと届くようです。<br>
EOM
}

# 戻るリンク定義

$back_link .= qq(<br>リンク - <a href="$home">$home_titleへ戻る</a>);
if($referer_url){
$back_link .= qq(　<a href="$referer_url">元のページへ戻る</a>);
}


# ロウソクを増やす
if($in{'action'}){ &plus_rousoku; $kaisetu = ""; $form = ""; }

# ロウソクを表示する
&rousoku_set;


my $print = <<"EOM";
$pri_rousoku
<br><br>
$now_text
$kaisetu
$action_text
$form
$ads1
$back_link
　素材提供 - <a href="http://icon.blog61.fc2.com/blog-entry-30.html">アイコン王のフリー素材</a>
 / <a href="http://skyline.skr.jp/">SkyLine -空の素材-</a>
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# ロウソクを表示する
#-----------------------------------------------------------

sub rousoku_set{

my($cnt1,$cnt10,$cnt100,$cnt1000);

# ロウソクの本数をサイズごとに数える
#$rousoku1000_num = int($rousoku_num / 1000);
#$rousoku100_num = int ( ($rousoku_num - ($rousoku1000_num * 1000) ) / 100 );

$rousoku100_num = int($rousoku_num / 100);
$rousoku10_num = int ( ($rousoku_num - ($rousoku1000_num * 1000) - ($rousoku100_num * 100) ) / 10 );
$rousoku1_num = $rousoku_num % 10;

# １０００本ロウソクを立てる
#while($cnt1000 < $rousoku1000_num)
#{
#$cnt1000++;
#$pri_rousoku .= qq(<img src="http://mb2.jp/pct/rousoku.gif" alt="ロウソ\ク1000本" class="rousoku1000">\n);
#}

# １００本ロウソクを立てる
while($cnt100 < $rousoku100_num)
{
$cnt100++;
$pri_rousoku .= qq(<img src="http://mb2.jp/pct/rousoku.gif" alt="ロウソ\ク100本" class="rousoku100">\n);
}

# １０本ロウソクを立てる
while($cnt10 < $rousoku10_num)
{
$cnt10++;
$pri_rousoku .= qq(<img src="http://mb2.jp/pct/rousoku.gif" alt="ロウソ\ク10本" class="rousoku10">\n);
}

# １本ロウソクを立てる
while($cnt1 < $rousoku1_num)
{
$cnt1++;
$pri_rousoku .= qq(<img src="http://mb2.jp/pct/rousoku.gif" alt="ロウソ\ク1本" class="rousoku1">\n);
}

}

#-----------------------------------------------------------
# ロウソクを立てる
#-----------------------------------------------------------

sub plus_rousoku{

my($line,$cnt,$put_xip_list);

# 時刻取得
$time = time;

# ロウソクがマックスの場合、処理リターン
if($heaven_mode){ return; }

# 実行者のXIPを、書き出しラインに追加
$put_xip_list .= "${xip_enc},";

# ＸＩＰで重複チェック
foreach( split (/,/,$xip_list) ){
$cnt++;
if($cnt < $rousoku_xipcnt_max){ $put_xip_list .= "${_},"; }

# XIP重複で制限実行　ただし、前回のロウソク立てから 
# $lasttime秒 以上経っている場合は、無条件で制限なしに

if(!$alocal_mode){
if($xip_enc eq $_ && $time < $lasttime + $rennzoku_sec){
$action_text = qq(<br><br>立てられるロウソ\クは、１本ずつです。<br>
焦らずに、しばらく時間を置いてから、また来てくださいね。<br>);
return;
}

}

}

# ロック開始
&lock("rousoku") if($lockkey);

### ファイルに書き出す
open(ROUSOKU_OUT,">${int_dir}_rousoku/rousoku_data.cgi");

# ロウソクを増やす
$rousoku_num += 1;

$line = "$rousoku_num<>$put_xip_list<>$time<><>\n";
print ROUSOKU_OUT $line;
close(ROUSOKU_OUT);

# 属性変更
Mebius::Chmod(undef,"${int_dir}_rousoku/rousoku_data.cgi");

# 一定確率で、バックアップを書き込む
if(rand(10) < 1){
open(BACKUP_OUT,">${int_dir}_rousoku/rousoku_backup.cgi");
print BACKUP_OUT $line;
close(BACKUP_OUT);
# 属性変更
Mebius::Chmod(undef,"${int_dir}_rousoku/rousoku_backup.cgi");
}

# ロック解除
&unlock("rousoku") if($lockkey);

# 現在本数テキストを変更
$now_text = qq(
今、$rousoku_num本のロウソ\クが立っています。
<br><br>
);

# ロウソクを立てた後のテキストを定義
$action_text = qq(あなたの願いを込めて、ロウソ\クが１本立ちました。<br>
しばらく目を閉じて、<strong class="red">$rousoku_num人分の願い</strong>に思いを馳せてみてください。<br>);

}


1;
