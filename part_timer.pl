use strict;

#-----------------------------------------------------------
# Javascript タイマーを取得 - strict
#-----------------------------------------------------------
sub get_timer{

# 宣言
my($type,$lefttime,$form_name) = @_;
my($javascript,$nexttime,$input_em,$day,$line_noscript);
my($leftminute,$leftsecond);
our($css_text,$time);

# リターン
$lefttime =~ s/\D//g;
if($lefttime < 0){ return; }

# 目標時刻を定義
$nexttime = $time + $lefttime + 1;

# CSSを調整 ( em : カウントダウン表示の幅 )
$input_em = 4.0;
if($lefttime >= 10*60){ $input_em += 0.5; }
if($type =~ /MILISECOND1/){ $input_em += 1; }
elsif($type =~ /MILISECOND2/){ $input_em += 1.5; }
if($lefttime > 1*60*60){ $input_em += 3; }
if($lefttime > 10*60*60){ $input_em += 0.5; }
$day = int $lefttime / (24*60*60);
if($day >= 1){ $input_em += length($day) / 2  + 1.5; }

# CSS定義 ( 基本 )
$css_text .= qq(
input.wait_input{font-size:95%;width:${input_em}em;border-style:none;text-align:center;color:#000;background:transparent;}
p.noscript{display:inline;}
);

# ヘッダのJavascript
$javascript .= qq(
<script type="text/javascript">
<!--
var showday;
window.onload=showday;

var nowdate_stop = new Date();
var nowtime_stop = nowdate_stop.getTime() / 1000;
var xtime = nowtime_stop + $lefttime + 1;

function showday() {

var date = new Date();
var nowtime = date.getTime();

var nowday = new Date();
var passtime1= (xtime*1000)-nowday.getTime();
var cnt_day = Math.floor(passtime1/(1000*60*60*24));

var passtime2 = passtime1 -(cnt_day*(1000*60*60*24));
var cnt_hour = Math.floor(passtime2/(1000*60*60));

var passtime3 = passtime2 -(cnt_hour*(1000*60*60));
var cnt_min = Math.floor(passtime3/(1000*60));

var passtime4 = passtime3 -(cnt_min*(1000*60));
var cnt_sec = Math.floor(passtime4/1000);

var passtime5 = passtime4 -(cnt_sec*(1000));
var cnt_millisec = Math.floor(passtime5/10);

if(cnt_min<10){cnt_min = '0' + cnt_min;}
if(cnt_sec<10){cnt_sec = '0' + cnt_sec;}
);

# ミリ秒の桁数を指定
if($type =~ /(MILISECOND1)/){
$javascript .= qq(
if(cnt_millisec<10){ cnt_millisec = '0' + cnt_millisec; }
cnt_millisec = Math.floor(cnt_millisec/10);
);
}
else{
$javascript .= qq(
if(cnt_millisec<10){ cnt_millisec = '0' + cnt_millisec; }
);
}

# どこまでの日付を表示するか
my($viewtime);
if($nexttime > $time + 24*60*60){ $viewtime .= qq(+cnt_day+"日 "); }
if($nexttime > $time + 60*60){ $viewtime .= qq(+cnt_hour+"時間 "); }
$viewtime .= qq(+cnt_min+"分");
$viewtime .= qq(+cnt_sec+"秒");
if($type =~ /(MILISECOND1|MILISECOND2)/){ $viewtime .= qq(+" "+cnt_millisec); }

$javascript .= qq(
if((xtime*1000 - nowtime) > 0){
document.$form_name.waitsecond.value = $viewtime;
}
);

# 整形
$javascript .= qq(
else {
document.$form_name.waitsecond.value = "0分0秒";
}
timerID = setTimeout( function() { showday(); } , 10);
}
// -->
</script>
);

# noscript 用の記述
($leftminute,$leftsecond) = &minsec("",$lefttime);
$line_noscript = qq($leftminute分$leftsecond秒);

# リターン
return($javascript,$line_noscript);

}

#-----------------------------------------------------------
# 時間を分 / 秒に計算
#-----------------------------------------------------------
sub do_minsec{

# 宣言
my($type,$lefttime) = @_;
my($leftminute,$leftsecond);

# リターン
if(!$lefttime){ return(0,0); }

# 計算
$leftminute = int($lefttime / 60);
$leftsecond = int($lefttime % 60);

# リターン
return($leftminute,$leftsecond);

}


1;